#!/usr/bin/env bash
# record_all_platforms.sh
# Master script to record all platform videos

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FunctionalTestVideos"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Create output directories
mkdir -p "$OUTPUT_DIR"/{watchOS,iOS,iPadOS,macOS,Combined}

echo "========================================="
echo "  FoT COMPLETE VIDEO RECORDING SYSTEM"
echo "========================================="
echo ""
log_info "This will record demos for all 12 platform implementations"
log_info "Output directory: $OUTPUT_DIR"
echo ""

# Estimate time
log_info "Estimated recording time: 4-5 hours"
log_info "Estimated video duration: ~63 minutes total"
echo ""

# Check prerequisites
log_info "Checking prerequisites..."

if ! command -v xcrun &> /dev/null; then
    log_error "Xcode command line tools not found"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    log_warn "ffmpeg not found - some features may be limited"
    log_info "Install with: brew install ffmpeg"
fi

log_success "Prerequisites OK"
echo ""

# Recording menu
echo "Select recording mode:"
echo "  1) Record ALL platforms (watchOS + iOS + iPadOS + macOS) - 4-5 hours"
echo "  2) Record watchOS only - 45 min"
echo "  3) Record iOS only - 65 min"
echo "  4) Record iPadOS only - 65 min"
echo "  5) Record macOS only - 90 min"
echo "  6) Record specific app on specific platform"
echo ""
read -p "Enter choice [1-6]: " choice

case $choice in
    1)
        log_info "Recording ALL platforms..."
        "$SCRIPT_DIR/record_watch_apps.sh"
        "$SCRIPT_DIR/record_functional_tests.sh"  # iOS (existing)
        "$SCRIPT_DIR/record_ipad_apps.sh"
        "$SCRIPT_DIR/record_mac_apps.sh"
        ;;
    2)
        log_info "Recording watchOS apps..."
        "$SCRIPT_DIR/record_watch_apps.sh"
        ;;
    3)
        log_info "Recording iOS apps..."
        "$SCRIPT_DIR/record_functional_tests.sh"
        ;;
    4)
        log_info "Recording iPadOS apps..."
        "$SCRIPT_DIR/record_ipad_apps.sh"
        ;;
    5)
        log_info "Recording macOS apps..."
        "$SCRIPT_DIR/record_mac_apps.sh"
        ;;
    6)
        echo "Available apps: clinician, legal, education"
        read -p "Enter app name: " app
        echo "Available platforms: watch, ios, ipad, mac"
        read -p "Enter platform: " platform
        log_info "Recording $app on $platform..."
        "$SCRIPT_DIR/record_single.sh" "$app" "$platform"
        ;;
    *)
        log_error "Invalid choice"
        exit 1
        ;;
esac

log_success "Recording complete!"
log_info "Videos saved to: $OUTPUT_DIR"
echo ""
log_info "Next steps:"
echo "  1. Review videos for quality"
echo "  2. Edit and add title cards"
echo "  3. Combine into platform showcases"
echo "  4. Upload to YouTube/Vimeo"

