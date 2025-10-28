#!/usr/bin/env bash
# build_all.sh
# Build all app schemes across all platforms

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[BUILD]${NC} $1"; }
ok() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }

FAILED_BUILDS=()
SUCCESSFUL_BUILDS=()

# Configuration
CONFIGURATION="${CONFIGURATION:-Debug}"
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')

log "Building all apps with configuration: $CONFIGURATION"
log "Xcode version: $XCODE_VERSION"

# Build Swift Package Manager packages first
log "Building Swift packages..."
if swift build -c ${CONFIGURATION,,}; then
    ok "Swift packages built successfully"
else
    fail "Swift package build failed"
    exit 1
fi

# Helper function to build an app
build_app() {
    local APP_NAME=$1
    local PLATFORM=$2
    local DESTINATION=$3
    local PROJECT_PATH=$4
    
    log "Building $APP_NAME ($PLATFORM)..."
    
    # Check if project exists
    if [ ! -d "$PROJECT_PATH" ]; then
        warn "Project not found: $PROJECT_PATH (skipping)"
        return 0
    fi
    
    # Find .xcodeproj or generate with xcodegen
    local PROJECT_FILE=""
    if ls "$PROJECT_PATH"/*.xcodeproj >/dev/null 2>&1; then
        PROJECT_FILE=$(ls -1 "$PROJECT_PATH"/*.xcodeproj | head -n1)
    elif [ -f "$PROJECT_PATH/project.yml" ] && command -v xcodegen >/dev/null 2>&1; then
        log "Generating Xcode project with xcodegen..."
        (cd "$PROJECT_PATH" && xcodegen generate)
        PROJECT_FILE=$(ls -1 "$PROJECT_PATH"/*.xcodeproj | head -n1)
    else
        warn "No Xcode project found for $APP_NAME ($PLATFORM)"
        return 0
    fi
    
    # Extract project name
    PROJECT_NAME=$(basename "$PROJECT_FILE" .xcodeproj)
    
    # Build
    if command -v xcbeautify >/dev/null 2>&1; then
        if xcodebuild \
            -project "$PROJECT_FILE" \
            -scheme "$PROJECT_NAME" \
            -destination "$DESTINATION" \
            -configuration "$CONFIGURATION" \
            clean build \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            | xcbeautify; then
            ok "$APP_NAME ($PLATFORM) built successfully"
            SUCCESSFUL_BUILDS+=("$APP_NAME ($PLATFORM)")
        else
            fail "$APP_NAME ($PLATFORM) build failed"
            FAILED_BUILDS+=("$APP_NAME ($PLATFORM)")
        fi
    else
        if xcodebuild \
            -project "$PROJECT_FILE" \
            -scheme "$PROJECT_NAME" \
            -destination "$DESTINATION" \
            -configuration "$CONFIGURATION" \
            clean build \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            > /dev/null 2>&1; then
            ok "$APP_NAME ($PLATFORM) built successfully"
            SUCCESSFUL_BUILDS+=("$APP_NAME ($PLATFORM)")
        else
            fail "$APP_NAME ($PLATFORM) build failed"
            FAILED_BUILDS+=("$APP_NAME ($PLATFORM)")
        fi
    fi
}

# Build Clinician App
build_app "FoTClinician" "iOS" "platform=iOS Simulator,name=iPhone 15 Pro,OS=latest" "apps/ClinicianApp/iOS"
# Note: macOS and watchOS apps use Swift Package Manager, already built above

# Build Education K-18 App
# Note: Currently only has Swift source files, no Xcode projects yet

# Build Legal US App
# Note: Currently only has Swift source files, no Xcode projects yet

# Summary
echo ""
log "Build summary:"
if [ ${#SUCCESSFUL_BUILDS[@]} -gt 0 ]; then
    ok "${#SUCCESSFUL_BUILDS[@]} builds succeeded:"
    for build in "${SUCCESSFUL_BUILDS[@]}"; do
        echo "  ✓ $build"
    done
fi

if [ ${#FAILED_BUILDS[@]} -gt 0 ]; then
    fail "${#FAILED_BUILDS[@]} builds failed:"
    for build in "${FAILED_BUILDS[@]}"; do
        echo "  ✗ $build"
    done
    exit 1
fi

ok "All builds completed successfully!"

