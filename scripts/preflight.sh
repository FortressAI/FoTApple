#!/usr/bin/env bash
# preflight.sh
# Pre-flight checks before building

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[PREFLIGHT]${NC} $1"; }
ok() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }

log "Running pre-flight checks..."

# Check Xcode
if ! command -v xcodebuild >/dev/null 2>&1; then
    fail "Xcode not found. Please install Xcode from the App Store."
    exit 1
fi
ok "Xcode installed"

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
log "Xcode version: $XCODE_VERSION"

# Check if xcodegen is available (optional but recommended)
if command -v xcodegen >/dev/null 2>&1; then
    ok "xcodegen installed"
else
    warn "xcodegen not found. Install with: brew install xcodegen"
fi

# Check if xcbeautify is available (optional)
if command -v xcbeautify >/dev/null 2>&1; then
    ok "xcbeautify installed"
else
    warn "xcbeautify not found. Install with: brew install xcbeautify"
fi

# Check Swift version
if command -v swift >/dev/null 2>&1; then
    SWIFT_VERSION=$(swift --version | head -n 1 | awk '{print $4}')
    ok "Swift $SWIFT_VERSION"
else
    fail "Swift not found"
    exit 1
fi

# Check if Package.swift exists
if [ -f "Package.swift" ]; then
    ok "Package.swift found"
else
    fail "Package.swift not found. Run this from the project root."
    exit 1
fi

# Check for required directories
REQUIRED_DIRS=("apps" "packages" "Sources" "Tests")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        ok "Directory $dir exists"
    else
        fail "Required directory $dir not found"
        exit 1
    fi
done

# Check for Makefile
if [ -f "Makefile" ]; then
    ok "Makefile found"
else
    warn "Makefile not found"
fi

# Check available simulators
log "Checking available simulators..."
if command -v xcrun >/dev/null 2>&1; then
    SIMULATORS=$(xcrun simctl list devices | grep -c "iPhone" || true)
    if [ "$SIMULATORS" -gt 0 ]; then
        ok "$SIMULATORS iPhone simulators available"
    else
        warn "No iPhone simulators found"
    fi
fi

# Check disk space
AVAILABLE_SPACE=$(df -h . | tail -1 | awk '{print $4}')
ok "Available disk space: $AVAILABLE_SPACE"

# Summary
echo ""
log "Pre-flight checks complete!"
ok "System is ready for building"

