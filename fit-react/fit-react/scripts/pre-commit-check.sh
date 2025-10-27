#!/bin/bash

#created by Jason Lu on 09:55:00 10/27/2025
# Git pre-commit hook for development environment cleanup
# Ensures clean state before commits

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Pre-commit Environment Check${NC}"
echo "==============================="

# Check if development server is running
if lsof -ti:3000 >/dev/null 2>&1 || lsof -ti:3001 >/dev/null 2>&1 || lsof -ti:3002 >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Development server is running${NC}"
    echo -e "${YELLOW}   Consider stopping it before committing for clean state${NC}"

    read -p "Do you want to stop development servers? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/dev-cleanup.sh stop
        echo -e "${GREEN}✅ Development servers stopped${NC}"
    fi
fi

# Check for uncommitted changes in tracked files
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes${NC}"
    echo -e "${YELLOW}   Please stage or commit all changes before proceeding${NC}"
    git status --porcelain
    exit 1
fi

# Run basic tests
echo -e "${BLUE}🧪 Running basic checks...${NC}"
if npx tsc --noEmit --skipLibCheck; then
    echo -e "${GREEN}✅ TypeScript check passed${NC}"
else
    echo -e "${RED}❌ TypeScript errors found${NC}"
    exit 1
fi

# Check for large files
echo -e "${BLUE}📊 Checking file sizes...${NC}"
large_files=$(git diff --cached --name-only | xargs ls -la 2>/dev/null | awk '$5 > 1024*1024 {print "Large file detected: " $9 " (" $5/1024/1024 "MB)"}')

if [[ -n "$large_files" ]]; then
    echo -e "${YELLOW}⚠️  Large files detected in commit:${NC}"
    echo "$large_files"
    echo -e "${YELLOW}   Consider using git-lfs or reducing file size${NC}"
fi

# Check for console.log statements
if git diff --cached --name-only | xargs grep -l "console.log" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  console.log statements found in commit${NC}"
    echo -e "${YELLOW}   Consider removing or commenting them out${NC}"
fi

# Check for TODO/FIXME comments
if git diff --cached --name-only | xargs grep -l -E "(TODO|FIXME)" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  TODO/FIXME comments found in commit${NC}"
    echo -e "${YELLOW}   Consider addressing them before committing${NC}"
fi

echo -e "${GREEN}✅ Pre-commit checks completed${NC}"
exit 0