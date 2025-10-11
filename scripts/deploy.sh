#!/bin/bash

# Fit iOS App Deployment Script
# Created by Jason Lu on 20:57:00 10/11/2025

set -euo pipefail

# Configuration
APP_NAME="Fit"
BUNDLE_ID="com.jason.fit"
DEVELOPMENT_TEAM="6P6P5HUVGU"
ENVIRONMENT="${1:-staging}"
CONFIGURATION="${2:-Debug}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Validate deployment environment
validate_environment() {
    log "Validating deployment environment..."

    # Check required tools
    local required_tools=("xcodebuild" "xcrun")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "Required tool not found: $tool"
            exit 1
        fi
    done

    # Check build artifacts
    if [[ ! -d "build-artifacts" ]]; then
        error "Build artifacts not found. Please run build first."
        exit 1
    fi

    log "Environment validation completed"
}

# Deploy to TestFlight
deploy_testflight() {
    log "Deploying to TestFlight..."

    # Check for TestFlight credentials
    if [[ -z "${APPLE_ID:-}" || -z "${APPLE_APP_SPECIFIC_PASSWORD:-}" || -z "${APPLE_TEAM_ID:-}" ]]; then
        error "Missing Apple credentials. Set APPLE_ID, APPLE_APP_SPECIFIC_PASSWORD, and APPLE_TEAM_ID environment variables."
        exit 1
    fi

    # Find the latest archive
    local archive_path=$(find build-artifacts -name "*.xcarchive" -type d | head -1)
    if [[ -z "$archive_path" ]]; then
        error "No archive found for deployment"
        exit 1
    fi

    log "Using archive: $archive_path"

    # Upload to TestFlight
    if xcrun altool --upload-app \
        --type ios \
        --file "$archive_path" \
        --username "$APPLE_ID" \
        --password "$APPLE_APP_SPECIFIC_PASSWORD" \
        --asc-provider "$APPLE_TEAM_ID"; then

        log "✅ Successfully uploaded to TestFlight"

        # Get TestFlight information
        local app_info=$(xcrun altool --list-apps --username "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --asc-provider "$APPLE_TEAM_ID" 2>/dev/null || echo "")

        if [[ -n "$app_info" ]]; then
            log "TestFlight information updated"
        fi

    else
        error "Failed to upload to TestFlight"
        exit 1
    fi
}

# Deploy to App Store
deploy_appstore() {
    log "Deploying to App Store..."

    # Find the latest archive
    local archive_path=$(find build-artifacts -name "*.xcarchive" -type d | head -1)
    if [[ -z "$archive_path" ]]; then
        error "No archive found for deployment"
        exit 1
    fi

    # Create export options for App Store
    cat > build-artifacts/appstore-export-options.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$DEVELOPMENT_TEAM</string>
    <key>destination</key>
    <string>export</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF

    # Export for App Store
    local export_path="build-artifacts/appstore-export"
    mkdir -p "$export_path"

    if xcodebuild -exportArchive \
        -archivePath "$archive_path" \
        -exportPath "$export_path" \
        -exportOptionsPlist "build-artifacts/appstore-export-options.plist"; then

        log "✅ Archive exported for App Store"

        # Upload to App Store
        local ipa_path=$(find "$export_path" -name "*.ipa" | head -1)
        if [[ -n "$ipa_path" ]]; then
            log "Uploading to App Store: $ipa_path"

            if xcrun altool --upload-app \
                --type ios \
                --file "$ipa_path" \
                --username "${APPLE_ID:-}" \
                --password "${APPLE_APP_SPECIFIC_PASSWORD:-}" \
                --asc-provider "$DEVELOPMENT_TEAM"; then

                log "✅ Successfully uploaded to App Store"
            else
                error "Failed to upload to App Store"
                exit 1
            fi
        fi

    else
        error "Failed to export archive for App Store"
        exit 1
    fi
}

# Deploy to staging server
deploy_staging() {
    log "Deploying to staging server..."

    # Find the simulator build
    local app_path=$(find build-artifacts -name "Fit.app" -type d | head -1)
    if [[ -z "$app_path" ]]; then
        error "No app found for staging deployment"
        exit 1
    fi

    # Create staging package
    local staging_dir="build-artifacts/staging"
    mkdir -p "$staging_dir"

    # Copy app to staging
    cp -R "$app_path" "$staging_dir/"

    # Create deployment manifest
    cat > "$staging_dir/deployment-info.json" << EOF
{
    "appName": "$APP_NAME",
    "bundleIdentifier": "$BUNDLE_ID",
    "version": "$(grep MARKETING_VERSION Fit.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ;')",
    "buildNumber": "$(grep CURRENT_PROJECT_VERSION Fit.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ;')",
    "configuration": "$CONFIGURATION",
    "environment": "$ENVIRONMENT",
    "timestamp": "$(date -Iseconds)",
    "appPath": "$staging_dir/Fit.app"
}
EOF

    log "✅ Staging package created at $staging_dir"

    # You can add additional staging deployment logic here
    # Examples:
    # - Upload to internal server
    # - Deploy to testing devices
    # - Create QR codes for easy access
}

# Create deployment rollback
create_rollback() {
    log "Creating rollback package..."

    local rollback_dir="build-artifacts/rollback"
    mkdir -p "$rollback_dir"

    # Save current build information
    cat > "$rollback_dir/rollback-info.json" << EOF
{
    "appName": "$APP_NAME",
    "bundleIdentifier": "$BUNDLE_ID",
    "version": "$(grep MARKETING_VERSION Fit.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ;')",
    "buildNumber": "$(grep CURRENT_PROJECT_VERSION Fit.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ;')",
    "rollbackTimestamp": "$(date -Iseconds)",
    "previousBuild": "build-artifacts/previous-build"
}
EOF

    log "✅ Rollback package created"
}

# Monitor deployment
monitor_deployment() {
    local deployment_type="$1"
    log "Monitoring $deployment_type deployment..."

    # Add monitoring logic here
    # Examples:
    # - Check App Store processing status
    # - Monitor TestFlight review progress
    # - Track download statistics
    # - Monitor crash reports

    log "Deployment monitoring initiated"
}

# Notify deployment
notify_deployment() {
    local deployment_type="$1"
    local status="$2"

    log "Notifying deployment status: $status"

    # Add notification logic here
    # Examples:
    # - Send Slack notifications
    # - Send email alerts
    # - Update project management tools
    # - Post to team chat

    case "$status" in
        "success")
            log "🎉 Deployment to $deployment_type completed successfully!"
            ;;
        "failure")
            error "❌ Deployment to $deployment_type failed!"
            ;;
        "rollback")
            warn "⚠️ Deployment to $deployment_type rolled back!"
            ;;
    esac
}

# Main deployment function
main() {
    local deployment_target="${1:-staging}"

    log "Starting Fit iOS App Deployment..."
    log "Target: $deployment_target"
    log "Environment: $ENVIRONMENT"
    log "Configuration: $CONFIGURATION"

    # Change to script directory
    cd "$(dirname "$0")/.."

    # Validate environment
    validate_environment

    # Execute deployment based on target
    case "$deployment_target" in
        "testflight")
            deploy_testflight
            monitor_deployment "TestFlight"
            notify_deployment "TestFlight" "success"
            ;;
        "appstore")
            deploy_appstore
            monitor_deployment "App Store"
            notify_deployment "App Store" "success"
            ;;
        "staging")
            deploy_staging
            notify_deployment "Staging" "success"
            ;;
        "rollback")
            create_rollback
            notify_deployment "Rollback" "success"
            ;;
        *)
            error "Unknown deployment target: $deployment_target"
            echo "Valid targets: testflight, appstore, staging, rollback"
            exit 1
            ;;
    esac

    log "🚀 Deployment process completed successfully!"
}

# Show usage
usage() {
    echo "Fit iOS App Deployment Script"
    echo ""
    echo "Usage: $0 [TARGET] [ENVIRONMENT] [CONFIGURATION]"
    echo ""
    echo "TARGETS:"
    echo "  testflight   Deploy to TestFlight"
    echo "  appstore     Deploy to App Store"
    echo "  staging      Deploy to staging server"
    echo "  rollback     Create rollback package"
    echo ""
    echo "ENVIRONMENTS:"
    echo "  staging      Staging environment (default)"
    echo "  production   Production environment"
    echo ""
    echo "CONFIGURATIONS:"
    echo "  Debug        Debug configuration (default)"
    echo "  Release      Release configuration"
    echo ""
    echo "Examples:"
    echo "  $0 testflight production Release    # Deploy to TestFlight for production"
    echo "  $0 staging staging Debug            # Deploy to staging server"
    echo "  $0 appstore production Release      # Deploy to App Store"
    echo ""
    echo "Environment Variables Required for App Store/TestFlight:"
    echo "  APPLE_ID                    Apple ID email"
    echo "  APPLE_APP_SPECIFIC_PASSWORD  App-specific password"
    echo "  APPLE_TEAM_ID               Team ID (default: 6P6P5HUVGU)"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac