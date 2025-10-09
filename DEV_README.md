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
