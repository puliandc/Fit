#!/bin/bash
# analyze-build-errors.sh
# Build error analysis script for Fit app
set -e

BUILD_LOG=${1:-build.log}
ERROR_SUMMARY_FILE="logs/error-summary.json"
ERROR_REPORT_FILE="logs/error-report.md"

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

# Function to categorize errors
categorize_error() {
    local error_line="$1"

    if [[ "$error_line" =~ "compilation failed" ]]; then
        echo "compilation"
    elif [[ "$error_line" =~ "linker" || "$error_line" =~ "ld:" ]]; then
        echo "linking"
    elif [[ "$error_line" =~ "asset" || "$error_line" =~ "actool" ]]; then
        echo "assets"
    elif [[ "$error_line" =~ "signing" || "$error_line" =~ "codesign" ]]; then
        echo "code-signing"
    elif [[ "$error_line" =~ "provisioning" || "$error_line" =~ "profile" ]]; then
        echo "provisioning"
    elif [[ "$error_line" =~ "dependency" ]]; then
        echo "dependencies"
    else
        echo "other"
    fi
}

echo "📊 Analyzing build errors..."

# Create logs directory
mkdir -p logs

# Check if build log exists
if [[ ! -f "$BUILD_LOG" ]]; then
    print_status "error" "Build log not found: $BUILD_LOG"
    exit 1
fi

# Extract all errors and warnings
ERRORS=$(grep -E "error:|failed:|Error:" "$BUILD_LOG" || true)
WARNINGS=$(grep -E "warning:|Warning:" "$BUILD_LOG" || true)

# Count errors and warnings
ERROR_COUNT=$(echo "$ERRORS" | grep -c "error:" || echo "0")
FAILED_COUNT=$(echo "$ERRORS" | grep -c "failed:" || echo "0")
WARNING_COUNT=$(echo "$WARNINGS" | grep -c "warning:" || echo "0")

print_status "info" "Build Analysis Summary:"
print_status "error" "Errors: $ERROR_COUNT"
print_status "error" "Failed operations: $FAILED_COUNT"
print_status "warning" "Warnings: $WARNING_COUNT"

# Categorize errors
print_status "info" "Categorizing errors..."

declare -A error_categories
compilation_errors=0
linking_errors=0
asset_errors=0
signing_errors=0
provisioning_errors=0
dependency_errors=0
other_errors=0

while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        category=$(categorize_error "$line")
        case $category in
            "compilation")
                compilation_errors=$((compilation_errors + 1))
                ;;
            "linking")
                linking_errors=$((linking_errors + 1))
                ;;
            "assets")
                asset_errors=$((asset_errors + 1))
                ;;
            "code-signing")
                signing_errors=$((signing_errors + 1))
                ;;
            "provisioning")
                provisioning_errors=$((provisioning_errors + 1))
                ;;
            "dependencies")
                dependency_errors=$((dependency_errors + 1))
                ;;
            *)
                other_errors=$((other_errors + 1))
                ;;
        esac
    fi
done <<< "$ERRORS"

# Display error categories
print_status "info" "Error Categories:"
[[ $compilation_errors -gt 0 ]] && print_status "error" "Compilation: $compilation_errors"
[[ $linking_errors -gt 0 ]] && print_status "error" "Linking: $linking_errors"
[[ $asset_errors -gt 0 ]] && print_status "error" "Assets: $asset_errors"
[[ $signing_errors -gt 0 ]] && print_status "error" "Code Signing: $signing_errors"
[[ $provisioning_errors -gt 0 ]] && print_status "error" "Provisioning: $provisioning_errors"
[[ $dependency_errors -gt 0 ]] && print_status "error" "Dependencies: $dependency_errors"
[[ $other_errors -gt 0 ]] && print_status "error" "Other: $other_errors"

# Generate detailed error report
cat > "$ERROR_REPORT_FILE" << EOF
# Build Error Report

**Generated:** $(date)
**Build Log:** $BUILD_LOG

## Summary
- **Errors:** $ERROR_COUNT
- **Failed Operations:** $FAILED_COUNT
- **Warnings:** $WARNING_COUNT

## Error Categories
- **Compilation:** $compilation_errors
- **Linking:** $linking_errors
- **Assets:** $asset_errors
- **Code Signing:** $signing_errors
- **Provisioning:** $provisioning_errors
- **Dependencies:** $dependency_errors
- **Other:** $other_errors

## Detailed Errors

EOF

# Add detailed errors to report
if [[ $ERROR_COUNT -gt 0 ]]; then
    echo "### Error Details" >> "$ERROR_REPORT_FILE"
    echo "" >> "$ERROR_REPORT_FILE"

    error_num=1
    while IFS= read -r line; do
        if [[ -n "$line" && "$line" =~ "error:" ]]; then
            echo "**$error_num.** $line" >> "$ERROR_REPORT_FILE"

            # Try to extract context (next 2 lines)
            context=$(grep -A 2 -F "$line" "$BUILD_LOG" | tail -2)
            if [[ -n "$context" ]]; then
                echo "\`\`\`" >> "$ERROR_REPORT_FILE"
                echo "$context" >> "$ERROR_REPORT_FILE"
                echo "\`\`\`" >> "$ERROR_REPORT_FILE"
            fi
            echo "" >> "$ERROR_REPORT_FILE"
            error_num=$((error_num + 1))
        fi
    done <<< "$ERRORS"
fi

# Add warnings to report
if [[ $WARNING_COUNT -gt 0 ]]; then
    echo "### Warnings" >> "$ERROR_REPORT_FILE"
    echo "" >> "$ERROR_REPORT_FILE"

    warning_num=1
    while IFS= read -r line; do
        if [[ -n "$line" && "$line" =~ "warning:" ]]; then
            echo "**$warning_num.** $line" >> "$ERROR_REPORT_FILE"
            warning_num=$((warning_num + 1))
        fi
    done <<< "$WARNINGS"
    echo "" >> "$ERROR_REPORT_FILE"
fi

# Add recommendations based on error types
echo "## Recommendations" >> "$ERROR_REPORT_FILE"
echo "" >> "$ERROR_REPORT_FILE"

if [[ $compilation_errors -gt 0 ]]; then
    echo "- **Compilation Errors:** Check Swift syntax, imports, and type annotations" >> "$ERROR_REPORT_FILE"
fi

if [[ $linking_errors -gt 0 ]]; then
    echo "- **Linking Errors:** Verify framework dependencies and target membership" >> "$ERROR_REPORT_FILE"
fi

if [[ $asset_errors -gt 0 ]]; then
    echo "- **Asset Errors:** Check image formats, asset catalog structure, and naming" >> "$ERROR_REPORT_FILE"
fi

if [[ $signing_errors -gt 0 ]]; then
    echo "- **Code Signing Errors:** Verify development team, bundle ID, and certificates" >> "$ERROR_REPORT_FILE"
fi

if [[ $provisioning_errors -gt 0 ]]; then
    echo "- **Provisioning Errors:** Check provisioning profiles and device registration" >> "$ERROR_REPORT_FILE"
fi

if [[ $dependency_errors -gt 0 ]]; then
    echo "- **Dependency Errors:** Verify package manager configurations and version compatibility" >> "$ERROR_REPORT_FILE"
fi

# Add general debugging tips
echo "" >> "$ERROR_REPORT_FILE"
echo "### Debugging Tips" >> "$ERROR_REPORT_FILE"
echo "1. Clean the build folder: \`xcodebuild clean\`" >> "$ERROR_REPORT_FILE"
echo "2. Check for Xcode updates" >> "$ERROR_REPORT_FILE"
echo "3. Verify simulator/device availability" >> "$ERROR_REPORT_FILE"
echo "4. Run with verbose logging: \`xcodebuild -verbose\`" >> "$ERROR_REPORT_FILE"
echo "5. Check the full build log for detailed error context" >> "$ERROR_REPORT_FILE"

print_status "success" "Error analysis completed"
print_status "info" "Detailed report saved to: $ERROR_REPORT_FILE"

# Create JSON summary for automation
cat > "$ERROR_SUMMARY_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "build_log": "$BUILD_LOG",
  "summary": {
    "errors": $ERROR_COUNT,
    "failed_operations": $FAILED_COUNT,
    "warnings": $WARNING_COUNT
  },
  "categories": {
    "compilation": $compilation_errors,
    "linking": $linking_errors,
    "assets": $asset_errors,
    "code_signing": $signing_errors,
    "provisioning": $provisioning_errors,
    "dependencies": $dependency_errors,
    "other": $other_errors
  },
  "report_file": "$ERROR_REPORT_FILE"
}
EOF

print_status "success" "JSON summary saved to: $ERROR_SUMMARY_FILE"

# Show quick fix suggestions for common errors
if [[ $ERROR_COUNT -gt 0 ]]; then
    print_status "info" "Quick fix suggestions:"

    if echo "$ERRORS" | grep -q "No such module"; then
        print_status "warning" "- Missing module error: Check package dependencies and import statements"
    fi

    if echo "$ERRORS" | grep -q "Use of undeclared"; then
        print_status "warning" "- Undeclared identifier: Check variable declarations and scope"
    fi

    if echo "$ERRORS" | grep -q "Cannot find"; then
        print_status "warning" "- Cannot find error: Verify file paths and target membership"
    fi

    if echo "$ERRORS" | grep -q "Code signing"; then
        print_status "warning" "- Code signing error: Check development team and provisioning profiles"
    fi
fi