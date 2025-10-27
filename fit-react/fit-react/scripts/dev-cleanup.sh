#!/bin/bash

#created by Jason Lu on 09:30:00 10/27/2025
# DevOps Process Management Script for Vite Development Server
# Usage: ./scripts/dev-cleanup.sh [start|stop|restart|status|clean]

set -euo pipefail

# Configuration
PROJECT_NAME="fit-react"
DEFAULT_PORT=3000
LOCK_FILE="/tmp/vite-${PROJECT_NAME}.lock"
LOG_FILE="/tmp/vite-${PROJECT_NAME}.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

    # Log to file
    echo "${timestamp} [${level}] $message" >> "$LOG_FILE"
}

# Check if port is in use
check_port() {
    local port=${1:-$DEFAULT_PORT}
    if lsof -ti:$port >/dev/null 2>&1; then
        log "INFO" "Port $port is in use"
        return 0
    else
        log "INFO" "Port $port is free"
        return 1
    fi
}

# Get processes using the port
get_port_processes() {
    local port=${1:-$DEFAULT_PORT}
    lsof -ti:$port 2>/dev/null || true
}

# Kill processes gracefully
kill_process_gracefully() {
    local pid=$1
    local timeout=10
    local count=0

    if ! kill -0 "$pid" 2>/dev/null; then
        log "WARN" "Process $pid is not running"
        return 0
    fi

    log "INFO" "Attempting to gracefully stop process $pid"

    # Send SIGTERM first
    kill -TERM "$pid" 2>/dev/null || true

    # Wait for process to stop
    while kill -0 "$pid" 2>/dev/null && [ $count -lt $timeout ]; do
        sleep 1
        count=$((count + 1))
        if [ $count -eq 5 ]; then
            log "WARN" "Process $pid not responding to SIGTERM"
        fi
    done

    # If still running, force kill
    if kill -0 "$pid" 2>/dev/null; then
        log "WARN" "Force killing process $pid"
        kill -KILL "$pid" 2>/dev/null || true
        sleep 1
    fi

    # Verify process is dead
    if ! kill -0 "$pid" 2>/dev/null; then
        log "INFO" "Process $pid successfully terminated"
        return 0
    else
        log "ERROR" "Failed to kill process $pid"
        return 1
    fi
}

# Clean up all related processes
cleanup_processes() {
    local port=${1:-$DEFAULT_PORT}
    local pids=$(get_port_processes "$port")

    if [ -z "$pids" ]; then
        log "INFO" "No processes found using port $port"
        return 0
    fi

    log "INFO" "Found processes using port $port: $pids"

    local killed_count=0
    local failed_count=0

    for pid in $pids; do
        if kill_process_gracefully "$pid"; then
            killed_count=$((killed_count + 1))
        else
            failed_count=$((failed_count + 1))
        fi
    done

    log "INFO" "Cleanup completed: $killed_count killed, $failed_count failed"

    # Remove lock file
    if [ -f "$LOCK_FILE" ]; then
        rm -f "$LOCK_FILE"
        log "INFO" "Removed lock file"
    fi
}

# Start development server
start_dev() {
    local port=${1:-$DEFAULT_PORT}

    log "INFO" "Starting development server on port $port"

    # Check if already running
    if check_port "$port"; then
        log "ERROR" "Port $port is already in use. Run '$0 stop' to stop existing processes"
        exit 1
    fi

    # Create lock file
    echo "$$" > "$LOCK_FILE"

    # Start Vite in background with proper signal handling
    {
        trap 'cleanup_processes "$port"' EXIT
        trap 'cleanup_processes "$port"' INT
        trap 'cleanup_processes "$port"' TERM

        log "INFO" "Starting Vite server..."
        npm run dev &
        vite_pid=$!

        # Wait for Vite to start or fail
        sleep 3

        if check_port "$port"; then
            log "INFO" "Vite server started successfully (PID: $vite_pid, Port: $port)"
            echo "$vite_pid" >> "$LOCK_FILE"
        else
            log "ERROR" "Vite server failed to start"
            exit 1
        fi

        # Keep script running
        wait $vite_pid
    } &

    dev_script_pid=$!
    log "INFO" "Development server started (Script PID: $dev_script_pid)"
    echo "Server is running at http://localhost:$port"
    echo "Press Ctrl+C to stop the server"

    # Wait for the background process
    wait $dev_script_pid
}

# Stop development server
stop_dev() {
    local port=${1:-$DEFAULT_PORT}
    log "INFO" "Stopping development server on port $port"
    cleanup_processes "$port"
}

# Restart development server
restart_dev() {
    local port=${1:-$DEFAULT_PORT}
    log "INFO" "Restarting development server on port $port"
    stop_dev "$port"
    sleep 2
    start_dev "$port"
}

# Show status
show_status() {
    local port=${1:-$DEFAULT_PORT}

    echo "=== Development Server Status ==="
    echo "Project: $PROJECT_NAME"
    echo "Port: $port"
    echo "Lock File: $([ -f "$LOCK_FILE" ] && echo "Exists" || echo "Not found")"
    echo ""

    if check_port "$port"; then
        local pids=$(get_port_processes "$port")
        echo "Status: RUNNING"
        echo "Processes:"

        for pid in $pids; do
            local cmd=$(ps -p $pid -o command= 2>/dev/null || echo "Process not found")
            local start_time=$(ps -p $pid -o lstart= 2>/dev/null || echo "Unknown")
            echo "  PID: $pid | Command: $cmd | Started: $start_time"
        done

        echo ""
        echo "Server URL: http://localhost:$port"
    else
        echo "Status: STOPPED"
        echo "No processes found using port $port"
    fi
}

# Clean all resources
clean_all() {
    log "INFO" "Performing deep cleanup of all development resources"

    # Kill all vite processes
    log "INFO" "Killing all Vite processes..."
    pkill -f "vite" 2>/dev/null || true

    # Clean up port
    cleanup_processes "$DEFAULT_PORT"

    # Remove temp files
    log "INFO" "Cleaning up temporary files..."
    rm -f "$LOCK_FILE"

    # Clean node modules cache if needed
    if [ "${1:-}" == "--deep" ]; then
        log "INFO" "Performing deep cache cleanup..."
        rm -rf node_modules/.vite
        rm -rf dist
        npm cache clean --force
        log "INFO" "Deep cache cleanup completed"
    fi

    log "INFO" "Cleanup completed"
}

# Main script logic
case "${1:-}" in
    "start")
        start_dev "${2:-$DEFAULT_PORT}"
        ;;
    "stop")
        stop_dev "${2:-$DEFAULT_PORT}"
        ;;
    "restart")
        restart_dev "${2:-$DEFAULT_PORT}"
        ;;
    "status")
        show_status "${2:-$DEFAULT_PORT}"
        ;;
    "clean")
        clean_all "$2"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|clean} [port]"
        echo ""
        echo "Commands:"
        echo "  start   - Start development server"
        echo "  stop    - Stop development server"
        echo "  restart - Restart development server"
        echo "  status  - Show server status"
        echo "  clean   - Clean all processes and temporary files"
        echo ""
        echo "Examples:"
        echo "  $0 start          # Start on default port (3000)"
        echo "  $0 start 3001     # Start on port 3001"
        echo "  $0 status         # Show current status"
        echo "  $0 clean --deep   # Deep cleanup including caches"
        exit 1
        ;;
esac