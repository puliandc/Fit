#!/bin/bash

#created by Jason Lu on 09:40:00 10/27/2025
# Pre-development environment health check
# This script runs automatically before dev server starts

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Pre-Development Environment Check${NC}"
echo "================================="

# Check Node.js version
node_version=$(node --version)
echo -e "${GREEN}✓ Node.js:${NC} $node_version"

# Check npm version
npm_version=$(npm --version)
echo -e "${GREEN}✓ npm:${NC} $npm_version"

# Check if essential files exist
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found${NC}"
    exit 1
else
    echo -e "${GREEN}✓ package.json found${NC}"
fi

if [ ! -f "vite.config.ts" ]; then
    echo -e "${RED}❌ vite.config.ts not found${NC}"
    exit 1
else
    echo -e "${GREEN}✓ vite.config.ts found${NC}"
fi

# Check if node_modules exists and is complete
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠️  node_modules not found, installing...${NC}"
    npm install
else
    # Check if node_modules has essential Vite files
    if [ ! -d "node_modules/.vite" ]; then
        echo -e "${YELLOW}⚠️  Vite cache not found, running fresh install...${NC}"
        rm -rf node_modules
        npm install
    else
        echo -e "${GREEN}✓ node_modules found and complete${NC}"
    fi
fi

# Check for port conflicts
default_port=3000
if lsof -ti:$default_port >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port $default_port is in use${NC}"
    echo -e "${YELLOW}   Run './scripts/dev-cleanup.sh stop' to clear conflicts${NC}"

    # Ask user if they want to clean up
    read -p "Do you want to automatically clear port conflicts? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔧 Cleaning up port conflicts...${NC}"
        ./scripts/dev-cleanup.sh stop
        sleep 2
    else
        echo -e "${YELLOW}   You can manually specify a different port:${NC}"
        echo -e "${YELLOW}   npm run dev:3001${NC}"
    fi
else
    echo -e "${GREEN}✓ Port $default_port is available${NC}"
fi

# Check system resources
available_memory=$(sysctl -n hw.memsize | awk '{printf "%.0f", $1/1024/1024/1024}')
if [ "$available_memory" -lt 4 ]; then
    echo -e "${YELLOW}⚠️  Low memory detected (${available_memory}GB)${NC}"
    echo -e "${YELLOW}   Consider closing other applications${NC}"
else
    echo -e "${GREEN}✓ Sufficient memory available (${available_memory}GB)${NC}"
fi

# Check disk space
disk_usage=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 90 ]; then
    echo -e "${RED}❌ Low disk space (${disk_usage}% used)${NC}"
    exit 1
elif [ "$disk_usage" -gt 80 ]; then
    echo -e "${YELLOW}⚠️  High disk usage (${disk_usage}% used)${NC}"
else
    echo -e "${GREEN}✓ Sufficient disk space${NC}"
fi

# Check for TypeScript errors
if npx tsc --noEmit --skipLibCheck 2>/dev/null; then
    echo -e "${GREEN}✓ TypeScript compilation check passed${NC}"
else
    echo -e "${YELLOW}⚠️  TypeScript warnings/errors detected${NC}"
    echo -e "${YELLOW}   Check with 'npx tsc --noEmit'${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Environment check completed!${NC}"
echo -e "${BLUE}Ready to start development server${NC}"
echo ""

exit 0