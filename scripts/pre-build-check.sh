#!/bin/bash
# pre-build-check.sh
# Pre-build validation script for Fit app
set -e

echo "🔍 Running pre-build validation for Fit app..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
            echo -e "ℹ️  $message"
            ;;
    esac
}

# Check if we're in the right directory
if [[ ! -f "Fit.xcodeproj/project.pbxproj" ]]; then
    print_status "error" "Not in the project directory. Fit.xcodeproj not found."
    exit 1
fi

print_status "success" "Project structure validated"

# Check Xcode version
REQUIRED_XCODE_MAJOR="26"
CURRENT_XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | awk '{print $2}' | cut -d. -f1)

if [[ "$CURRENT_XCODE_VERSION" < "$REQUIRED_XCODE_MAJOR" ]]; then
    print_status "error" "Xcode version $CURRENT_XCODE_VERSION is below required $REQUIRED_XCODE_MAJOR.x"
    exit 1
fi
print_status "success" "Xcode version check passed ($CURRENT_XCODE_VERSION)"

# Check for required SDK
IOS_SDK="26.0"
if ! xcodebuild -showsdks | grep -q "iphoneos$IOS_SDK"; then
    print_status "error" "iOS SDK $IOS_SDK not found"
    exit 1
fi
print_status "success" "iOS SDK $IOS_SDK available"

# Check Swift source files syntax
print_status "info" "Checking Swift source file syntax..."

SWIFT_FILES=$(find ./Fit -name "*.swift" 2>/dev/null || true)
if [[ -z "$SWIFT_FILES" ]]; then
    print_status "error" "No Swift source files found in Fit directory"
    exit 1
fi

SYNTAX_ERRORS=0
for file in $SWIFT_FILES; do
    if ! swift -frontend -parse "$file" >/dev/null 2>&1; then
        print_status "error" "Syntax error in $file"
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done

if [[ $SYNTAX_ERRORS -gt 0 ]]; then
    print_status "error" "Found $SYNTAX_ERRORS Swift syntax errors"
    exit 1
fi
print_status "success" "Swift syntax validation passed"

# Check for required project files
REQUIRED_FILES=(
    "Fit.xcodeproj/project.pbxproj"
    "Fit/FitApp.swift"
    "Fit/ContentView.swift"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        print_status "error" "Required file missing: $file"
        exit 1
    fi
done

# Check for required directories
REQUIRED_DIRS=(
    "Fit/Assets.xcassets"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        print_status "error" "Required directory missing: $dir"
        exit 1
    fi
done
print_status "success" "All required project files present"

# Check build settings
print_status "info" "Validating build settings..."

# Check deployment target
DEPLOYMENT_TARGET=$(xcodebuild -project Fit.xcodeproj -scheme Fit -showBuildSettings | grep "IPHONEOS_DEPLOYMENT_TARGET" | awk '{print $3}')
if [[ -z "$DEPLOYMENT_TARGET" ]]; then
    print_status "warning" "Deployment target not explicitly set"
else
    print_status "success" "Deployment target: $DEPLOYMENT_TARGET"
fi

# Check Swift version
SWIFT_VERSION=$(xcodebuild -project Fit.xcodeproj -scheme Fit -showBuildSettings | grep "SWIFT_VERSION" | awk '{print $3}')
if [[ -z "$SWIFT_VERSION" ]]; then
    print_status "warning" "Swift version not explicitly set"
else
    print_status "success" "Swift version: $SWIFT_VERSION"
fi

# Check code signing
CODE_SIGN_IDENTITY=$(xcodebuild -project Fit.xcodeproj -scheme Fit -showBuildSettings | grep "CODE_SIGN_IDENTITY" | awk '{print $3}')
if [[ "$CODE_SIGN_IDENTITY" == "Apple Development" ]]; then
    print_status "success" "Code signing identity configured"
else
    print_status "warning" "Code signing may not be properly configured"
fi

# Check available simulators
AVAILABLE_SIMULATORS=$(xcrun simctl list devices available | grep "iPhone" | grep -E "iOS|simulator" | wc -l)
if [[ $AVAILABLE_SIMULATORS -eq 0 ]]; then
    print_status "warning" "No iPhone simulators available"
else
    print_status "success" "$AVAILABLE_SIMULATORS iPhone simulators available"
fi

# Check for git status (optional)
if command -v git >/dev/null 2>&1 && [[ -d ".git" ]]; then
    if [[ -n $(git status --porcelain) ]]; then
        print_status "warning" "Git working directory has uncommitted changes"
    else
        print_status "success" "Git working directory is clean"
    fi
fi

# Check disk space (at least 1GB free)
if command -v df >/dev/null 2>&1; then
    FREE_SPACE=$(df -h . | awk 'NR==2 {print $4}' | sed 's/G//g' | sed 's/M//g' | sed 's/K//g')
    if [[ -n "$FREE_SPACE" && "$FREE_SPACE" =~ ^[0-9]+$ ]]; then
        if [[ ${FREE_SPACE} -lt 1024 ]]; then  # Less than 1GB in MB
            print_status "warning" "Low disk space: ${FREE_SPACE}MB available"
        else
            GB_SPACE=$((FREE_SPACE / 1024))
            if [[ $GB_SPACE -lt 1 ]]; then
                print_status "warning" "Low disk space: ${FREE_SPACE} available"
            else
                print_status "success" "Sufficient disk space: ${GB_SPACE}GB available"
            fi
        fi
    else
        print_status "warning" "Unable to determine disk space"
    fi
else
    print_status "warning" "df command not available for disk space check"
fi

print_status "success" "Pre-build validation completed successfully"
echo "🚀 Ready to build Fit app!"