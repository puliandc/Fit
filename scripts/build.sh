#!/bin/bash
# build.sh
# Universal build script for Fit app
set -e

# Default values
PROJECT="Fit.xcodeproj"
SCHEME="Fit"
CONFIGURATION=${1:-Debug}
DESTINATION=${2:-'platform=iOS Simulator,name=iPhone 17'}
DERIVED_DATA_PATH="DerivedData"
CLEAN_BUILD=${3:-false}
VERBOSE=${4:-false}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "info")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [CONFIGURATION] [DESTINATION] [CLEAN_BUILD] [VERBOSE]"
    echo ""
    echo "Arguments:"
    echo "  CONFIGURATION   Debug (default) or Release"
    echo "  DESTINATION     Build destination (default: 'platform=iOS Simulator,name=iPhone 16e')"
    echo "  CLEAN_BUILD     true or false (default: false)"
    echo "  VERBOSE         true or false (default: false)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Debug build for iPhone 16e simulator"
    echo "  $0 Release                             # Release build for iPhone 16e simulator"
    echo "  $0 Debug 'platform=iOS Simulator,name=iPhone 17' true  # Clean debug build for iPhone 17"
    echo "  $0 Release 'platform=iOS Simulator,name=iPhone 17' true true  # Verbose clean release build"
}

# Parse command line arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

echo "🔨 Building Fit App..."
echo "Configuration: $CONFIGURATION"
echo "Destination: $DESTINATION"
echo "Clean Build: $CLEAN_BUILD"
echo "Verbose: $VERBOSE"
echo ""

# Change to script directory
cd "$(dirname "$0")/.."

# Run pre-build checks
print_status "info" "Running pre-build validation..."
if [[ -f "scripts/pre-build-check.sh" ]]; then
    ./scripts/pre-build-check.sh
else
    print_status "warning" "Pre-build check script not found, skipping validation"
fi

# Clean if requested
if [[ "$CLEAN_BUILD" == "true" ]]; then
    print_status "info" "Cleaning previous build..."
    xcodebuild clean \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION"
    print_status "success" "Clean completed"
fi

# Prepare build command
BUILD_CMD="xcodebuild build"
BUILD_ARGS=(
    "-project" "$PROJECT"
    "-scheme" "$SCHEME"
    "-configuration" "$CONFIGURATION"
    "-destination" "$DESTINATION"
    "-derivedDataPath" "$DERIVED_DATA_PATH"
)

# Add verbose flag if requested
if [[ "$VERBOSE" == "true" ]]; then
    BUILD_ARGS+=("-verbose")
fi

# Create build log directory
mkdir -p logs
BUILD_LOG="logs/build-$(date +%Y%m%d-%H%M%S).log"

print_status "info" "Starting build process..."
print_status "info" "Build log: $BUILD_LOG"

# Execute build and capture output
START_TIME=$(date +%s)

if xcodebuild "${BUILD_ARGS[@]}" 2>&1 | tee "$BUILD_LOG"; then
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))

    print_status "success" "Build completed successfully in ${BUILD_TIME}s"

    # Extract build metrics
    print_status "info" "Analyzing build metrics..."

    # Count compiled files
    COMPILED_FILES=$(grep -c "Compiling" "$BUILD_LOG" 2>/dev/null || echo "0")
    print_status "info" "Compiled $COMPILED_FILES Swift files"

    # Check for warnings
    WARNING_COUNT=$(grep -c "warning:" "$BUILD_LOG" 2>/dev/null || echo "0")
    if [[ $WARNING_COUNT -gt 0 ]]; then
        print_status "warning" "Build completed with $WARNING_COUNT warnings"
        print_status "info" "Check build log for detailed warnings"
    else
        print_status "success" "No warnings detected"
    fi

    # Show app location
    if [[ -d "$DERIVED_DATA_PATH" ]]; then
        APP_PATH=$(find "$DERIVED_DATA_PATH" -name "Fit.app" -type d 2>/dev/null | head -1)
        if [[ -n "$APP_PATH" ]]; then
            print_status "success" "App built at: $APP_PATH"

            # Show app size
            if command -v du >/dev/null 2>&1; then
                APP_SIZE=$(du -sh "$APP_PATH" 2>/dev/null | awk '{print $1}')
                if [[ -n "$APP_SIZE" ]]; then
                    print_status "info" "App size: $APP_SIZE"
                fi
            fi
        else
            print_status "info" "App build completed (location not found in DerivedData)"
        fi
    fi

    # Run post-build analysis if script exists
    if [[ -f "scripts/post-build-analysis.sh" ]]; then
        print_status "info" "Running post-build analysis..."
        ./scripts/post-build-analysis.sh "$BUILD_LOG" "$CONFIGURATION"
    fi

    print_status "success" "🎉 Fit app build completed successfully!"

else
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))

    print_status "error" "Build failed after ${BUILD_TIME}s"

    # Analyze build errors if script exists
    if [[ -f "scripts/analyze-build-errors.sh" ]]; then
        print_status "info" "Analyzing build errors..."
        ./scripts/analyze-build-errors.sh "$BUILD_LOG"
    else
        # Basic error analysis
        ERROR_COUNT=$(grep -c "error:" "$BUILD_LOG" || echo "0")
        print_status "error" "Found $ERROR_COUNT errors"

        # Show first few errors
        print_status "info" "First 5 errors:"
        grep "error:" "$BUILD_LOG" | head -5 | while read -r line; do
            echo -e "${RED}  $line${NC}"
        done
    fi

    exit 1
fi