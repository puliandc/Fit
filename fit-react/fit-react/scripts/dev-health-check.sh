#!/bin/bash

#created by Jason Lu on 14:40:00 10/27/2025
# Application Health Check Script
# Usage: ./scripts/dev-health-check.sh

set -euo pipefail

# Configuration
PROJECT_NAME="fit-react"
DEFAULT_PORT=3000
LOG_FILE="/tmp/vite-${PROJECT_NAME}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Development Environment Health Check ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Port: $DEFAULT_PORT"
echo ""

# 1. Port Status Check
echo -e "${BLUE}🔌 Port Status:${NC}"
if lsof -ti:$DEFAULT_PORT >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Port $DEFAULT_PORT is in use${NC}"
    lsof -ti:$DEFAULT_PORT | xargs -I {} ps -p {} -o pid=,command= | while read line; do
        echo "   $line"
    done
else
    echo -e "${RED}❌ Port $DEFAULT_PORT is not in use${NC}"
fi
echo ""

# 2. Process Status
echo -e "${BLUE}⚙️ Process Status:${NC}"
VITE_PROCESSES=$(ps aux | grep "[v]ite" | grep -v grep || true)
if [[ -n "$VITE_PROCESSES" ]]; then
    echo -e "${GREEN}✅ Vite processes found:${NC}"
    echo "$VITE_PROCESSES" | while read line; do
        echo "   $line"
    done
else
    echo -e "${RED}❌ No Vite processes found${NC}"
fi
echo ""

# 3. HTTP Response Check
echo -e "${BLUE}🌐 HTTP Response:${NC}"
if command -v curl >/dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$DEFAULT_PORT/ 2>/dev/null || echo "000")
    RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" http://localhost:$DEFAULT_PORT/ 2>/dev/null || echo "0.000")

    if [[ "$HTTP_CODE" == "200" ]]; then
        echo -e "${GREEN}✅ HTTP Status: $HTTP_CODE${NC}"
        echo -e "${GREEN}✅ Response Time: ${RESPONSE_TIME}s${NC}"
    else
        echo -e "${RED}❌ HTTP Status: $HTTP_CODE${NC}"
        echo -e "${YELLOW}⚠️ Response Time: ${RESPONSE_TIME}s${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ curl not available for HTTP check${NC}"
fi
echo ""

# 4. Application Content Check
echo -e "${BLUE}📱 Application Content:${NC}"
if command -v curl >/dev/null 2>&1; then
    RESPONSE=$(curl -s http://localhost:$DEFAULT_PORT/ 2>/dev/null || echo "")
    if [[ -n "$RESPONSE" ]]; then
        if [[ "$RESPONSE" == *"<div id=\"root\">"* ]]; then
            echo -e "${GREEN}✅ HTML structure valid${NC}"
        else
            echo -e "${RED}❌ HTML structure invalid${NC}"
        fi

        if [[ "$RESPONSE" == *"main.tsx"* ]]; then
            echo -e "${GREEN}✅ Main script reference found${NC}"
        else
            echo -e "${RED}❌ Main script reference missing${NC}"
        fi

        if [[ "$RESPONSE" == *"styles.css"* ]]; then
            echo -e "${GREEN}✅ CSS reference found${NC}"
        else
            echo -e "${YELLOW}⚠️ CSS reference missing${NC}"
        fi
    else
        echo -e "${RED}❌ No response from server${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Cannot check content without curl${NC}"
fi
echo ""

# 5. Git Status Check
echo -e "${BLUE}📦 Git Status:${NC}"
if [[ -d ".git" ]]; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
    if [[ "$UNCOMMITTED" == "0" ]]; then
        echo -e "${GREEN}✅ No uncommitted changes${NC}"
    else
        echo -e "${YELLOW}⚠️ $UNCOMMITTED uncommitted files${NC}"
        echo "   Recent changes:"
        git status --porcelain | head -5 | while read line; do
            echo "   $line"
        done
    fi

    # Check if current branch is main
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    if [[ "$CURRENT_BRANCH" == "main" ]]; then
        echo -e "${GREEN}✅ On main branch${NC}"
    else
        echo -e "${YELLOW}⚠️ On branch: $CURRENT_BRANCH${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Not a Git repository${NC}"
fi
echo ""

# 6. Dependencies Check
echo -e "${BLUE}📋 Dependencies:${NC}"
if [[ -f "package.json" ]]; then
    if [[ -d "node_modules" ]]; then
        NODE_MODULES_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1 || echo "unknown")
        echo -e "${GREEN}✅ node_modules exists ($NODE_MODULES_SIZE)${NC}"

        # Check for common critical dependencies
        CRITICAL_DEPS=("react" "react-dom" "vite")
        for dep in "${CRITICAL_DEPS[@]}"; do
            if [[ -d "node_modules/$dep" ]]; then
                echo -e "${GREEN}✅ $dep installed${NC}"
            else
                echo -e "${RED}❌ $dep missing${NC}"
            fi
        done
    else
        echo -e "${RED}❌ node_modules not found${NC}"
        echo -e "${YELLOW}💡 Run 'npm install'${NC}"
    fi
else
    echo -e "${RED}❌ package.json not found${NC}"
fi
echo ""

# 7. Log File Check
echo -e "${BLUE}📄 Log Files:${NC}"
if [[ -f "$LOG_FILE" ]]; then
    LOG_SIZE=$(du -sh "$LOG_FILE" 2>/dev/null | cut -f1 || echo "0")
    LAST_MODIFIED=$(stat -f "%Sm" "$LOG_FILE" 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✅ Log file exists ($LOG_SIZE)${NC}"
    echo "   Last modified: $LAST_MODIFIED"

    # Show last few lines
    echo "   Recent log entries:"
    tail -3 "$LOG_FILE" 2>/dev/null | while read line; do
        echo "   $line"
    done
else
    echo -e "${YELLOW}⚠️ No log file found${NC}"
fi
echo ""

# 8. Overall Health Score
echo -e "${BLUE}🏥 Overall Health Score:${NC}"
SCORE=0
TOTAL=8

# Port
if lsof -ti:$DEFAULT_PORT >/dev/null 2>&1; then
    SCORE=$((SCORE + 1))
fi

# Process
if ps aux | grep "[v]ite" >/dev/null; then
    SCORE=$((SCORE + 1))
fi

# HTTP
if command -v curl >/dev/null 2>&1 && [[ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$DEFAULT_PORT/ 2>/dev/null)" == "200" ]]; then
    SCORE=$((SCORE + 1))
fi

# App Content (simplified check)
if command -v curl >/dev/null 2>&1 && [[ "$(curl -s http://localhost:$DEFAULT_PORT/ 2>/dev/null)" == *"root"* ]]; then
    SCORE=$((SCORE + 1))
fi

# Git
if [[ -d ".git" ]]; then
    SCORE=$((SCORE + 1))
fi

# Dependencies
if [[ -f "package.json" && -d "node_modules" ]]; then
    SCORE=$((SCORE + 1))
fi

# Config files
if [[ -f "vite.config.ts" && -f "tsconfig.json" ]]; then
    SCORE=$((SCORE + 1))
fi

# Dev scripts
if [[ -f "scripts/dev-cleanup.sh" ]]; then
    SCORE=$((SCORE + 1))
fi

PERCENTAGE=$((SCORE * 100 / TOTAL))
if [[ $PERCENTAGE -ge 80 ]]; then
    echo -e "${GREEN}✅ Health Score: $SCORE/$TOTAL ($PERCENTAGE%) - Excellent${NC}"
elif [[ $PERCENTAGE -ge 60 ]]; then
    echo -e "${YELLOW}⚠️ Health Score: $SCORE/$TOTAL ($PERCENTAGE%) - Good${NC}"
else
    echo -e "${RED}❌ Health Score: $SCORE/$TOTAL ($PERCENTAGE%) - Needs Attention${NC}"
fi

echo ""
echo -e "${BLUE}=== Health Check Complete ===${NC}"