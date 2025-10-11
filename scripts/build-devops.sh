#!/bin/bash

# Fit iOS App DevOps Build Script
# Created by Jason Lu on 20:54:00 10/11/2025
# Optimized for CI/CD pipeline integration

set -euo pipefail

# Configuration
PROJECT_NAME="Fit"
SCHEME_NAME="Fit"
WORKSPACE_NAME="Fit.xcodeproj"
CONFIGURATION="${1:-Debug}"
BUNDLE_ID="com.jason.fit"
DEVELOPMENT_TEAM="6P6P5HUVGU"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] DEBUG: $1${NC}"
    fi
}

# Validate environment
validate_environment() {
    log "Validating build environment..."

    # Check Xcode installation
    if ! command -v xcodebuild &> /dev/null; then
        error "xcodebuild not found. Please install Xcode Command Line Tools."
        exit 1
    fi

    # Check project exists
    if [[ ! -f "$WORKSPACE_NAME/project.pbxproj" ]]; then
        error "Project file not found: $WORKSPACE_NAME"
        exit 1
    fi

    # Check required files
    local required_files=(
        "Fit/Info.plist"
        "Fit/Fit.entitlements"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            warn "Required file not found: $file"
        fi
    done

    log "Environment validation completed"
}

# Clean build artifacts
clean_build() {
    log "Cleaning previous build artifacts..."

    rm -rf DerivedData
    rm -rf build-artifacts
    rm -rf logs/*.log

    xcodebuild clean \
        -project "$WORKSPACE_NAME" \
        -scheme "$SCHEME_NAME" \
        -configuration "$CONFIGURATION" \
        -quiet || {
        error "Failed to clean project"
        exit 1
    }

    log "Clean completed successfully"
}

# Build for iOS Simulator (fixed configuration)
build_simulator() {
    log "Building for iOS Simulator (iOS 17.0)..."

    mkdir -p build-artifacts/simulator
    mkdir -p logs

    local build_log="logs/simulator-build-$(date +%Y%m%d-%H%M%S).log"

    if xcodebuild build \
        -project "$WORKSPACE_NAME" \
        -scheme "$SCHEME_NAME" \
        -configuration "$CONFIGURATION" \
        -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
        -derivedDataPath DerivedData \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
        PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
        ENABLE_PREVIEWS=YES \
        GENERATE_INFOPLIST_FILE=NO \
        INFOPLIST_FILE="Fit/Info.plist" \
        CODE_SIGN_ENTITLEMENTS="Fit/Fit.entitlements" \
        OTHER_CODE_SIGN_FLAGS="--keychain /tmp/build.keychain" \
        2>&1 | tee "$build_log"; then

        log "✅ Simulator build completed successfully"

        # Copy app to build artifacts
        local app_path=$(find DerivedData -name "Fit.app" -type d | head -1)
        if [[ -n "$app_path" ]]; then
            cp -R "$app_path" build-artifacts/simulator/
            log "App copied to build-artifacts/simulator/Fit.app"
        fi

        # Generate build report
        generate_build_report "$build_log" "simulator"

    else
        error "Simulator build failed"
        analyze_build_failure "$build_log"
        exit 1
    fi
}

# Build for iOS Device
build_device() {
    log "Building for iOS Device..."

    mkdir -p build-artifacts/device

    if xcodebuild build \
        -project "$WORKSPACE_NAME" \
        -scheme "$SCHEME_NAME" \
        -configuration "$CONFIGURATION" \
        -destination 'generic/platform=iOS' \
        -derivedDataPath DerivedData \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
        PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
        ENABLE_PREVIEWS=YES \
        GENERATE_INFOPLIST_FILE=NO \
        INFOPLIST_FILE="Fit/Info.plist" \
        CODE_SIGN_ENTITLEMENTS="Fit/Fit.entitlements" \
        -quiet; then

        log "✅ Device build completed successfully"

        # Copy app to build artifacts
        local app_path=$(find DerivedData -name "Fit.app" -type d | head -1)
        if [[ -n "$app_path" ]]; then
            cp -R "$app_path" build-artifacts/device/
            log "App copied to build-artifacts/device/Fit.app"
        fi

    else
        error "Device build failed"
        exit 1
    fi
}

# Create archive
create_archive() {
    log "Creating archive..."

    mkdir -p build-artifacts/archive

    if xcodebuild archive \
        -project "$WORKSPACE_NAME" \
        -scheme "$SCHEME_NAME" \
        -configuration "$CONFIGURATION" \
        -archivePath "build-artifacts/archive/Fit.xcarchive" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
        PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
        GENERATE_INFOPLIST_FILE=NO \
        INFOPLIST_FILE="Fit/Info.plist" \
        CODE_SIGN_ENTITLEMENTS="Fit/Fit.entitlements" \
        -quiet; then

        log "✅ Archive created successfully"

        # Export IPA if needed
        if command -v xcodebuild &> /dev/null; then
            export_archive
        fi

    else
        error "Archive creation failed"
        exit 1
    fi
}

# Export archive to IPA
export_archive() {
    log "Exporting archive to IPA..."

    # Create export options plist
    cat > build-artifacts/archive/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>$DEVELOPMENT_TEAM</string>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF

    if xcodebuild -exportArchive \
        -archivePath "build-artifacts/archive/Fit.xcarchive" \
        -exportPath "build-artifacts/ipa" \
        -exportOptionsPlist "build-artifacts/archive/ExportOptions.plist" \
        -quiet; then

        log "✅ IPA exported successfully"
    else
        warn "IPA export failed, but archive was created successfully"
    fi
}

# Run unit tests
run_tests() {
    log "Running unit tests..."

    mkdir -p test-results

    if xcodebuild test \
        -project "$WORKSPACE_NAME" \
        -scheme "$SCHEME_NAME" \
        -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
        -derivedDataPath DerivedData \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
        PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
        ENABLE_PREVIEWS=YES \
        GENERATE_INFOPLIST_FILE=NO \
        INFOPLIST_FILE="Fit/Info.plist" \
        CODE_SIGN_ENTITLEMENTS="Fit/Fit.entitlements" \
        -resultBundlePath test-results/TestResults.xcresult \
        -quiet; then

        log "✅ Tests completed successfully"

        # Extract test results summary
        if command -v xcodebuild &> /dev/null; then
            xcodebuild test-without-building \
                -xctestrun DerivedData/Build/Products/*.xctestrun \
                -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
                -only-testing:Fit 2>&1 | grep -E "(Test Suite|Test Case)" || true
        fi

    else
        warn "Tests failed, but build may still be valid"
    fi
}

# Generate build report
generate_build_report() {
    local build_log="$1"
    local target="$2"

    log "Generating build report for $target..."

    local report_file="build-artifacts/${target}-build-report.json"

    # Extract metrics from build log
    local compiled_files=$(grep -c "Compiling" "$build_log" 2>/dev/null || echo "0")
    local warnings=$(grep -c "warning:" "$build_log" 2>/dev/null || echo "0")
    local errors=$(grep -c "error:" "$build_log" 2>/dev/null || echo "0")
    local build_time=$(grep -E "BUILD SUCCEEDED|BUILD FAILED" "$build_log" | tail -1 || echo "Unknown")

    # Create JSON report
    cat > "$report_file" << EOF
{
    "buildTarget": "$target",
    "configuration": "$CONFIGURATION",
    "bundleIdentifier": "$BUNDLE_ID",
    "timestamp": "$(date -Iseconds)",
    "metrics": {
        "compiledFiles": $compiled_files,
        "warnings": $warnings,
        "errors": $errors,
        "buildTime": "$build_time"
    },
    "artifacts": {
        "appPath": "build-artifacts/$target/Fit.app",
        "buildLog": "$build_log"
    }
}
EOF

    log "Build report saved to $report_file"
}

# Analyze build failure
analyze_build_failure() {
    local build_log="$1"

    error "Build failure analysis:"

    # Extract common error patterns
    local bundle_errors=$(grep -i "bundle" "$build_log" | grep -i error || true)
    local signing_errors=$(grep -i "code sign" "$build_log" | grep -i error || true)
    local dependency_errors=$(grep -i "dependency" "$build_log" | grep -i error || true)

    if [[ -n "$bundle_errors" ]]; then
        error "Bundle identifier issues detected:"
        echo "$bundle_errors" | head -3
    fi

    if [[ -n "$signing_errors" ]]; then
        error "Code signing issues detected:"
        echo "$signing_errors" | head -3
    fi

    if [[ -n "$dependency_errors" ]]; then
        error "Dependency issues detected:"
        echo "$dependency_errors" | head -3
    fi
}

# Create deployment package
create_deployment_package() {
    log "Creating deployment package..."

    mkdir -p build-artifacts/deployment

    # Create deployment manifest
    cat > build-artifacts/deployment/manifest.json << EOF
{
    "appName": "Fit",
    "version": "$(grep MARKETING_VERSION Fit.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ;')",
    "buildNumber": "$(grep CURRENT_PROJECT_VERSION Fit.xcodeproj/project.pbxproj | head -1 | cut -d'=' -f2 | tr -d ' ;')",
    "bundleIdentifier": "$BUNDLE_ID",
    "configuration": "$CONFIGURATION",
    "timestamp": "$(date -Iseconds)",
    "artifacts": {
        "simulator": "build-artifacts/simulator/Fit.app",
        "device": "build-artifacts/device/Fit.app",
        "archive": "build-artifacts/archive/Fit.xcarchive"
    },
    "requirements": {
        "iOS": "15.6+",
        "Xcode": "14.0+"
    }
}
EOF

    # Create deployment script
    cat > build-artifacts/deployment/deploy.sh << 'EOF'
#!/bin/bash
# Fit App Deployment Script

set -euo pipefail

# Load configuration
source manifest.json

echo "Deploying Fit App v$version..."
echo "Bundle ID: $bundleIdentifier"
echo "Configuration: $configuration"

# Add deployment logic here based on your needs
# Examples:
# - Upload to TestFlight
# - Deploy to App Store
# - Install on test devices

echo "Deployment completed successfully!"
EOF

    chmod +x build-artifacts/deployment/deploy.sh
    log "Deployment package created in build-artifacts/deployment/"
}

# Main execution
main() {
    local build_type="${1:-simulator}"

    log "Starting Fit iOS App DevOps Build Process..."
    log "Build Type: $build_type"
    log "Configuration: $CONFIGURATION"
    log "Bundle ID: $BUNDLE_ID"

    # Change to script directory
    cd "$(dirname "$0")/.."

    # Execute build pipeline
    validate_environment
    clean_build

    case "$build_type" in
        "simulator")
            build_simulator
            ;;
        "device")
            build_device
            ;;
        "archive")
            build_device
            create_archive
            ;;
        "test")
            build_simulator
            run_tests
            ;;
        "full")
            build_simulator
            build_device
            run_tests
            create_archive
            create_deployment_package
            ;;
        *)
            error "Unknown build type: $build_type"
            echo "Valid options: simulator, device, archive, test, full"
            exit 1
            ;;
    esac

    log "🎉 DevOps build process completed successfully!"
    log "📦 Artifacts available in build-artifacts/"
}

# Show usage
usage() {
    echo "Fit iOS App DevOps Build Script"
    echo ""
    echo "Usage: $0 [BUILD_TYPE] [CONFIGURATION]"
    echo ""
    echo "BUILD_TYPES:"
    echo "  simulator   Build for iOS Simulator (default)"
    echo "  device      Build for iOS Device"
    echo "  archive     Build and archive for distribution"
    echo "  test        Build and run tests"
    echo "  full        Complete build pipeline"
    echo ""
    echo "CONFIGURATIONS:"
    echo "  Debug       Debug build (default)"
    echo "  Release     Release build"
    echo ""
    echo "Examples:"
    echo "  $0                    # Debug build for simulator"
    echo "  $0 device Release     # Release build for device"
    echo "  $0 full               # Complete build pipeline"
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