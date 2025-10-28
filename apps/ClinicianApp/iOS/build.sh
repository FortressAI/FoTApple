#!/usr/bin/env bash
# build.sh
# Build and test FoT Clinician iOS App

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Configuration
PROJECT="FoTClinicianApp.xcodeproj"
SCHEME="FoTClinicianApp"
DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1"
DERIVED_DATA_PATH="$SCRIPT_DIR/.build"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if project exists
if [ ! -d "$PROJECT" ]; then
    log_error "Project not found. Run ./setup.sh first."
    exit 1
fi

# Parse command line arguments
ACTION="${1:-build}"

case "$ACTION" in
    build)
        log_info "Building $SCHEME..."
        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -derivedDataPath "$DERIVED_DATA_PATH" \
            clean build \
            | xcbeautify || xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -derivedDataPath "$DERIVED_DATA_PATH" \
            clean build
        log_success "Build completed"
        ;;
    
    test)
        log_info "Running tests..."
        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -derivedDataPath "$DERIVED_DATA_PATH" \
            test \
            | xcbeautify || xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -derivedDataPath "$DERIVED_DATA_PATH" \
            test
        log_success "Tests passed"
        ;;
    
    run)
        log_info "Building and running $SCHEME..."
        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -derivedDataPath "$DERIVED_DATA_PATH" \
            build
        
        # Boot simulator if not running
        SIMULATOR_ID=$(xcrun simctl list devices | grep "iPhone 17 Pro" | grep "OS=26.1" | grep -v "unavailable" | head -1 | grep -oE '\([A-Z0-9-]+\)' | tr -d '()')
        
        if [ -n "$SIMULATOR_ID" ]; then
            xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
            
            # Install and launch app
            APP_PATH=$(find "$DERIVED_DATA_PATH" -name "FoTClinician.app" | head -1)
            if [ -n "$APP_PATH" ]; then
                xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
                xcrun simctl launch "$SIMULATOR_ID" com.fot.clinician.FoTClinician
                log_success "App launched"
                open -a Simulator
            else
                log_error "App not found"
                exit 1
            fi
        else
            log_error "Simulator not found"
            exit 1
        fi
        ;;
    
    clean)
        log_info "Cleaning..."
        rm -rf "$DERIVED_DATA_PATH"
        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            clean
        log_success "Clean completed"
        ;;
    
    archive)
        log_info "Archiving for release..."
        ARCHIVE_PATH="$SCRIPT_DIR/.build/FoTClinician.xcarchive"
        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -archivePath "$ARCHIVE_PATH" \
            archive
        log_success "Archive created at $ARCHIVE_PATH"
        ;;
    
    help)
        echo "FoT Clinician Build Script"
        echo ""
        echo "Usage: ./build.sh [command]"
        echo ""
        echo "Commands:"
        echo "  build    - Build the app (default)"
        echo "  test     - Run unit and UI tests"
        echo "  run      - Build and launch in simulator"
        echo "  clean    - Clean build artifacts"
        echo "  archive  - Create release archive"
        echo "  help     - Show this help"
        echo ""
        ;;
    
    *)
        log_error "Unknown command: $ACTION"
        echo "Run './build.sh help' for usage"
        exit 1
        ;;
esac

