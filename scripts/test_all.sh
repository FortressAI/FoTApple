#!/usr/bin/env bash
# test_all.sh
# Run all tests across packages and apps

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[TEST]${NC} $1"; }
ok() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

FAILED_TESTS=()
SUCCESSFUL_TESTS=()
SKIPPED_TESTS=()

# Configuration
CONFIGURATION="${CONFIGURATION:-Debug}"

log "Running all tests with configuration: $CONFIGURATION"

# Test Swift packages
log "Testing Swift packages..."
if swift test --parallel; then
    ok "Swift package tests passed"
    SUCCESSFUL_TESTS+=("Swift Packages")
else
    fail "Swift package tests failed"
    FAILED_TESTS+=("Swift Packages")
fi

# Helper function to test an app
test_app() {
    local APP_NAME=$1
    local PLATFORM=$2
    local DESTINATION=$3
    local PROJECT_PATH=$4
    
    log "Testing $APP_NAME ($PLATFORM)..."
    
    # Check if project exists
    if [ ! -d "$PROJECT_PATH" ]; then
        warn "Project not found: $PROJECT_PATH (skipping)"
        SKIPPED_TESTS+=("$APP_NAME ($PLATFORM)")
        return 0
    fi
    
    # Find .xcodeproj
    local PROJECT_FILE=""
    if ls "$PROJECT_PATH"/*.xcodeproj >/dev/null 2>&1; then
        PROJECT_FILE=$(ls -1 "$PROJECT_PATH"/*.xcodeproj | head -n1)
    else
        warn "No Xcode project found for $APP_NAME ($PLATFORM)"
        SKIPPED_TESTS+=("$APP_NAME ($PLATFORM)")
        return 0
    fi
    
    # Extract project name
    PROJECT_NAME=$(basename "$PROJECT_FILE" .xcodeproj)
    
    # Check if scheme has tests
    local HAS_TESTS=false
    if xcodebuild -project "$PROJECT_FILE" -scheme "$PROJECT_NAME" -showBuildSettings 2>/dev/null | grep -q "TEST_HOST"; then
        HAS_TESTS=true
    fi
    
    if [ "$HAS_TESTS" = false ]; then
        warn "$APP_NAME ($PLATFORM) has no tests"
        SKIPPED_TESTS+=("$APP_NAME ($PLATFORM)")
        return 0
    fi
    
    # Run tests
    if command -v xcbeautify >/dev/null 2>&1; then
        if xcodebuild \
            -project "$PROJECT_FILE" \
            -scheme "$PROJECT_NAME" \
            -destination "$DESTINATION" \
            -configuration "$CONFIGURATION" \
            test \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            -enableCodeCoverage YES \
            | xcbeautify; then
            ok "$APP_NAME ($PLATFORM) tests passed"
            SUCCESSFUL_TESTS+=("$APP_NAME ($PLATFORM)")
        else
            fail "$APP_NAME ($PLATFORM) tests failed"
            FAILED_TESTS+=("$APP_NAME ($PLATFORM)")
        fi
    else
        if xcodebuild \
            -project "$PROJECT_FILE" \
            -scheme "$PROJECT_NAME" \
            -destination "$DESTINATION" \
            -configuration "$CONFIGURATION" \
            test \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            -enableCodeCoverage YES \
            > /dev/null 2>&1; then
            ok "$APP_NAME ($PLATFORM) tests passed"
            SUCCESSFUL_TESTS+=("$APP_NAME ($PLATFORM)")
        else
            fail "$APP_NAME ($PLATFORM) tests failed"
            FAILED_TESTS+=("$APP_NAME ($PLATFORM)")
        fi
    fi
}

# Test Clinician App
test_app "FoTClinician" "iOS" "platform=iOS Simulator,name=iPhone 15 Pro,OS=latest" "apps/ClinicianApp/iOS"

# Test Education K-18 App
# (No Xcode project yet, tests run via Swift package above)

# Test Legal US App
# (No Xcode project yet, tests run via Swift package above)

# Summary
echo ""
log "Test summary:"

if [ ${#SUCCESSFUL_TESTS[@]} -gt 0 ]; then
    ok "${#SUCCESSFUL_TESTS[@]} test suites passed:"
    for test in "${SUCCESSFUL_TESTS[@]}"; do
        echo "  ✓ $test"
    done
fi

if [ ${#SKIPPED_TESTS[@]} -gt 0 ]; then
    warn "${#SKIPPED_TESTS[@]} test suites skipped:"
    for test in "${SKIPPED_TESTS[@]}"; do
        echo "  ⏭  $test"
    done
fi

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    fail "${#FAILED_TESTS[@]} test suites failed:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  ✗ $test"
    done
    exit 1
fi

ok "All tests completed successfully!"

