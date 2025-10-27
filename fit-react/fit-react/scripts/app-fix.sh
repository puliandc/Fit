#!/bin/bash

#created by Jason Lu on 14:45:00 10/27/2025
# Application Fix Script
# Usage: ./scripts/app-fix.sh [option]

set -euo pipefail

# Configuration
PROJECT_NAME="fit-react"
DEFAULT_PORT=3000

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        "INFO")  echo -e "${GREEN}[INFO]${NC}  ${timestamp} - $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC}  ${timestamp} - $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} ${timestamp} - $message" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} ${timestamp} - $message" ;;
    esac
}

# Function to restart development server
restart_dev_server() {
    log "INFO" "Restarting development server..."

    # Stop existing processes
    log "INFO" "Stopping existing Vite processes..."
    pkill -f "vite" 2>/dev/null || true

    # Wait for processes to stop
    sleep 2

    # Check if port is still in use
    if lsof -ti:$DEFAULT_PORT >/dev/null 2>&1; then
        log "WARN" "Port $DEFAULT_PORT still in use, force cleanup..."
        lsof -ti:$DEFAULT_PORT | xargs -I {} kill -9 {} 2>/dev/null || true
        sleep 1
    fi

    # Start fresh development server
    log "INFO" "Starting fresh development server..."
    npm run dev &

    # Wait for server to start
    sleep 3

    # Verify server started
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$DEFAULT_PORT/ | grep -q "200"; then
        log "INFO" "Development server started successfully"
        echo "🌐 Server available at: http://localhost:$DEFAULT_PORT"
    else
        log "ERROR" "Failed to start development server"
        return 1
    fi
}

# Function to check application content
check_app_content() {
    log "INFO" "Checking application content..."

    # Check critical files
    CRITICAL_FILES=(
        "src/main.tsx"
        "src/context/NavigationContext.tsx"
        "src/components/MainScreen.tsx"
        "src/styles.css"
        "src/index.css"
        "index.html"
    )

    missing_files=()
    for file in "${CRITICAL_FILES[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log "ERROR" "Missing critical files:"
        for file in "${missing_files[@]}"; do
            echo "   ❌ $file"
        done
        return 1
    else
        log "INFO" "All critical files present"
    fi

    # Check if files have content
    empty_files=()
    for file in "${CRITICAL_FILES[@]}"; do
        if [[ -f "$file" && ! -s "$file" ]]; then
            empty_files+=("$file")
        fi
    done

    if [[ ${#empty_files[@]} -gt 0 ]]; then
        log "WARN" "Empty files found:"
        for file in "${empty_files[@]}"; do
            echo "   ⚠️ $file"
        done
    fi

    return 0
}

# Function to validate package.json
validate_package_json() {
    log "INFO" "Validating package.json..."

    if [[ ! -f "package.json" ]]; then
        log "ERROR" "package.json not found"
        return 1
    fi

    # Check for required dependencies
    REQUIRED_DEPS=("react" "react-dom" "vite")
    MISSING_DEPS=()

    for dep in "${REQUIRED_DEPS[@]}"; do
        if ! grep -q "\"$dep\"" package.json; then
            MISSING_DEPS+=("$dep")
        fi
    done

    if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
        log "ERROR" "Missing required dependencies:"
        for dep in "${MISSING_DEPS[@]}"; do
            echo "   ❌ $dep"
        done
        return 1
    else
        log "INFO" "All required dependencies found in package.json"
    fi

    return 0
}

# Function to fix import issues
fix_imports() {
    log "INFO" "Checking and fixing import issues..."

    # Check main.tsx imports
    if [[ -f "src/main.tsx" ]]; then
        # Check for missing CSS imports
        if ! grep -q "import.*styles" src/main.tsx; then
            log "WARN" "styles.css import not found in main.tsx"
        fi

        if ! grep -q "import.*index" src/main.tsx; then
            log "WARN" "index.css import not found in main.tsx"
        fi

        # Check for component imports
        COMPONENTS=("MainScreen" "NavigationContext")
        for component in "${COMPONENTS[@]}"; do
            if ! grep -q "import.*$component" src/main.tsx; then
                log "WARN" "$component import not found in main.tsx"
            fi
        done
    fi

    return 0
}

# Function to clean and reinstall
clean_reinstall() {
    log "INFO" "Performing clean reinstallation..."

    # Remove node_modules and lock file
    log "INFO" "Removing node_modules and package-lock.json..."
    rm -rf node_modules package-lock.json

    # Clear npm cache
    log "INFO" "Clearing npm cache..."
    npm cache clean --force

    # Reinstall dependencies
    log "INFO" "Reinstalling dependencies..."
    npm install

    if [[ $? -eq 0 ]]; then
        log "INFO" "Dependencies reinstalled successfully"
    else
        log "ERROR" "Failed to reinstall dependencies"
        return 1
    fi
}

# Function to run health check
run_health_check() {
    log "INFO" "Running comprehensive health check..."
    ./scripts/dev-health-check.sh
}

# Main script logic
case "${1:-}" in
    "restart")
        echo -e "${BLUE}=== Application Restart ===${NC}"
        restart_dev_server
        ;;

    "check")
        echo -e "${BLUE}=== Application Check ===${NC}"
        check_app_content
        validate_package_json
        fix_imports
        ;;

    "fix")
        echo -e "${BLUE}=== Application Fix ===${NC}"
        check_app_content
        validate_package_json
        fix_imports
        restart_dev_server
        ;;

    "clean")
        echo -e "${BLUE}=== Clean Reinstall ===${NC}"
        clean_reinstall
        ;;

    "health")
        echo -e "${BLUE}=== Health Check ===${NC}"
        run_health_check
        ;;

    "full")
        echo -e "${BLUE}=== Full Application Fix ===${NC}"
        log "INFO" "Running full application fix process..."

        # Step 1: Check files
        check_app_content || {
            log "ERROR" "File check failed. Please restore missing files."
            exit 1
        }

        # Step 2: Validate package.json
        validate_package_json || {
            log "ERROR" "Package validation failed."
            exit 1
        }

        # Step 3: Fix imports
        fix_imports

        # Step 4: Clean reinstall (optional)
        if [[ "${2:-}" == "--deep" ]]; then
            clean_reinstall
        fi

        # Step 5: Restart server
        restart_dev_server

        # Step 6: Health check
        sleep 2
        run_health_check

        log "INFO" "Full application fix completed!"
        ;;

    *)
        echo "Usage: $0 {restart|check|fix|clean|health|full} [--deep]"
        echo ""
        echo "Commands:"
        echo "  restart - Restart development server"
        echo "  check    - Check application files and configuration"
        echo "  fix      - Fix common application issues"
        echo "  clean    - Clean reinstall dependencies"
        echo "  health    - Run health check"
        echo "  full     - Run complete fix process"
        echo "  full --deep - Full fix with dependency reinstallation"
        echo ""
        echo "Examples:"
        echo "  $0 restart     # Restart the development server"
        echo "  $0 check       # Check application status"
        echo "  $0 full        # Run complete fix process"
        echo "  $0 full --deep # Complete fix with clean reinstall"
        exit 1
        ;;
esac