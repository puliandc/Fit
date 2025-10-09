#!/bin/bash
# dev-setup.sh
# Development environment setup script for Fit app
set -e

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

echo "🚀 Setting up Fit app development environment..."

# Change to script directory
cd "$(dirname "$0")/.."

# Check prerequisites
print_status "info" "Checking prerequisites..."

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_status "error" "This script requires macOS"
    exit 1
fi
print_status "success" "macOS detected"

# Check if Xcode is installed
if ! command -v xcodebuild >/dev/null 2>&1; then
    print_status "error" "Xcode is not installed or not in PATH"
    print_status "info" "Please install Xcode from the App Store"
    exit 1
fi
print_status "success" "Xcode found"

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | awk '{print $2}')
print_status "info" "Xcode version: $XCODE_VERSION"

# Check if we're in the right directory
if [[ ! -f "Fit.xcodeproj/project.pbxproj" ]]; then
    print_status "error" "Not in the Fit project directory"
    print_status "info" "Please run this script from the project root"
    exit 1
fi
print_status "success" "Project directory validated"

# Create necessary directories
print_status "info" "Creating necessary directories..."
mkdir -p logs
mkdir -p build-artifacts
mkdir -p test-results
print_status "success" "Directories created"

# Setup git hooks if git is initialized
if [[ -d ".git" ]]; then
    print_status "info" "Setting up git hooks..."

    # Create pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for Fit app

echo "🔍 Running pre-commit checks..."

# Run pre-build validation
if [[ -f "scripts/pre-build-check.sh" ]]; then
    ./scripts/pre-build-check.sh
else
    echo "⚠️ Pre-build check script not found"
fi

# Check for Swift formatting (if swiftformat is available)
if command -v swiftformat >/dev/null 2>&1; then
    echo "📝 Checking Swift formatting..."
    if ! swiftformat --lint Fit/; then
        echo "⚠️ Swift formatting issues found. Run 'swiftformat Fit/' to fix."
    fi
fi

# Check for trailing whitespace
if grep -r " $" Fit/ --exclude-dir=DerivedData; then
    echo "⚠️ Trailing whitespace found"
fi

echo "✅ Pre-commit checks completed"
EOF

    chmod +x .git/hooks/pre-commit
    print_status "success" "Pre-commit hook installed"
fi

# Setup scripts permissions
print_status "info" "Setting up script permissions..."
chmod +x scripts/*.sh
print_status "success" "Scripts made executable"

# Install additional tools (optional)
print_status "info" "Checking for additional development tools..."

# Check for Homebrew
if command -v brew >/dev/null 2>&1; then
    print_status "success" "Homebrew found"

    # Check for xcbeautify (build log formatter)
    if ! command -v xcbeautify >/dev/null 2>&1; then
        print_status "info" "Installing xcbeautify for better build logs..."
        brew install xcbeautify || print_status "warning" "Failed to install xcbeautify"
    else
        print_status "success" "xcbeautify already installed"
    fi

    # Check for swiftformat (code formatter)
    if ! command -v swiftformat >/dev/null 2>&1; then
        print_status "info" "Installing swiftformat..."
        brew install swiftformat || print_status "warning" "Failed to install swiftformat"
    else
        print_status "success" "swiftformat already installed"
    fi

    # Check for swiftlint (code analysis)
    if ! command -v swiftlint >/dev/null 2>&1; then
        print_status "info" "Installing swiftlint..."
        brew install swiftlint || print_status "warning" "Failed to install swiftlint"
    else
        print_status "success" "swiftlint already installed"
    fi
else
    print_status "warning" "Homebrew not found - skipping optional tools installation"
fi

# Create development configuration files
print_status "info" "Creating development configuration files..."

# Create .swiftlint.yml if it doesn't exist
if [[ ! -f ".swiftlint.yml" ]]; then
    cat > .swiftlint.yml << 'EOF'
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional

line_length:
  warning: 120
  error: 150

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500
EOF
    print_status "success" "SwiftLint configuration created"
fi

# Create .swiftformat if it doesn't exist
if [[ ! -f ".swiftformat" ]]; then
    cat > .swiftformat << 'EOF'
# SwiftFormat Configuration

--indent 4
--allman true
--selfrequired
--semicolons never
--wraparguments on
--wrapconditions on
--commas never
--exponentcase lowercase
--hexgrouping 4,8
--binarygrouping 4,8
--octalgrouping 4,8
--decimalgrouping 3,6
--typeproperties sorted
--emptybraces fast
--organizeimports
--importgrouping testable-bottom
EOF
    print_status "success" "SwiftFormat configuration created"
fi

# Create development aliases
print_status "info" "Creating development aliases..."

ALIASES_FILE=".dev-aliases"
cat > "$ALIASES_FILE" << 'EOF'
# Development aliases for Fit app
# Source this file in your shell: source .dev-aliases

# Build aliases
alias fit-build='./scripts/build.sh'
alias fit-build-debug='./scripts/build.sh Debug'
alias fit-build-release='./scripts/build.sh Release'
alias fit-build-clean='./scripts/build.sh Debug "platform=iOS Simulator,name=iPhone 16e" true'
alias fit-check='./scripts/pre-build-check.sh'

# Test aliases
alias fit-test='xcodebuild test -project Fit.xcodeproj -scheme Fit -destination "platform=iOS Simulator,name=iPhone 16e"'
alias fit-test-debug='xcodebuild test -project Fit.xcodeproj -scheme Fit -destination "platform=iOS Simulator,name=iPhone 16e" -configuration Debug'

# Clean aliases
alias fit-clean='xcodebuild clean -project Fit.xcodeproj -scheme Fit'
alias fit-clean-all='rm -rf DerivedData/ build-artifacts/ test-results/ logs/'

# Run aliases
alias fit-run='xcodebuild build -project Fit.xcodeproj -scheme Fit -destination "platform=iOS Simulator,name=iPhone 16e" && xcrun simctl install booted DerivedData/Build/Products/Debug-iphonesimulator/Fit.app && xcrun simctl launch booted Jason.Fit'

# Format and lint aliases
alias fit-format='swiftformat Fit/'
alias fit-lint='swiftlint'
alias fit-format-lint='swiftformat Fit/ && swiftlint'

# Log aliases
alias fit-logs='tail -f logs/build-$(date +%Y%m%d)*.log'
alias fit-error-logs='grep -i error logs/build-*.log'

# Project aliases
alias fit-open='open Fit.xcodeproj'
alias fit-status='git status && ./scripts/pre-build-check.sh'
EOF

print_status "success" "Development aliases created in $ALIASES_FILE"
print_status "info" "Run 'source $ALIASES_FILE' to load aliases"

# Run initial build test
print_status "info" "Running initial build test..."

if ./scripts/build.sh Debug 'platform=iOS Simulator,name=iPhone 16e' > /dev/null 2>&1; then
    print_status "success" "Initial build test passed"
else
    print_status "warning" "Initial build test failed - check project configuration"
fi

# Create README for development setup
cat > DEV_README.md << 'EOF'
# Fit App Development Setup

This document outlines the development setup and workflow for the Fit app.

## Quick Start

1. **Run the setup script:**
   ```bash
   ./scripts/dev-setup.sh
   ```

2. **Load development aliases:**
   ```bash
   source .dev-aliases
   ```

3. **Build the project:**
   ```bash
   fit-build-debug
   ```

## Development Workflow

### Daily Development
```bash
# Check project status
fit-status

# Make your changes...

# Build and test
fit-build-debug
fit-test

# Format code
fit-format-lint
```

### Before Committing
```bash
# Full clean build
fit-build-clean

# Run all tests
fit-test

# Check formatting and linting
fit-format-lint

# Commit changes
git add .
git commit -m "Your commit message"
```

### Build Commands

| Command | Description |
|---------|-------------|
| `fit-build` | Build with default settings (Debug) |
| `fit-build-debug` | Debug build |
| `fit-build-release` | Release build |
| `fit-build-clean` | Clean build |
| `fit-check` | Run pre-build validation |

### Test Commands

| Command | Description |
|---------|-------------|
| `fit-test` | Run all tests |
| `fit-test-debug` | Run tests in Debug configuration |

### Code Quality

| Command | Description |
|---------|-------------|
| `fit-format` | Format Swift code |
| `fit-lint` | Run SwiftLint |
| `fit-format-lint` | Format and lint code |

### Running the App

| Command | Description |
|---------|-------------|
| `fit-run` | Build and run in simulator |
| `fit-open` | Open project in Xcode |

## Troubleshooting

### Build Issues
1. **Clean build:** `fit-build-clean`
2. **Check environment:** `fit-check`
3. **Check logs:** `fit-error-logs`

### Simulator Issues
1. **Reset simulator:** `xcrun simctl erase all`
2. **Check available devices:** `xcrun simctl list devices`

### Code Quality Issues
1. **Auto-format:** `fit-format`
2. **Fix linting:** `fit-lint --fix`

## Project Structure

```
Fit/
├── Fit/                    # Source code
│   ├── FitApp.swift       # App entry point
│   ├── ContentView.swift  # Main view
│   └── Assets.xcassets    # App assets
├── scripts/               # Build and utility scripts
│   ├── build.sh          # Main build script
│   ├── pre-build-check.sh # Pre-build validation
│   └── analyze-build-errors.sh # Error analysis
├── .github/workflows/     # CI/CD configurations
└── logs/                  # Build logs and analysis
```

## Configuration Files

- `.swiftlint.yml` - SwiftLint rules
- `.swiftformat` - SwiftFormat configuration
- `.dev-aliases` - Development command aliases

## CI/CD

The project uses GitHub Actions for continuous integration:

- **Build and Test:** Runs on every push and PR
- **Security Scan:** Runs on PRs
- **Performance Test:** Runs on main branch
- **Simulator Deploy:** Runs on develop branch

View the workflow in `.github/workflows/ci.yml`.
EOF

print_status "success" "Development documentation created"

# Final setup summary
echo ""
echo "🎉 Development environment setup completed!"
echo ""
echo "Next steps:"
echo "1. Load development aliases: source .dev-aliases"
echo "2. Start developing: fit-build-debug"
echo "3. Read DEV_README.md for detailed instructions"
echo ""
echo "Useful commands:"
echo "- fit-status: Check project status"
echo "- fit-build-debug: Build the app"
echo "- fit-run: Build and run in simulator"
echo "- fit-format-lint: Format and lint code"
echo ""

print_status "success" "Setup completed successfully!"