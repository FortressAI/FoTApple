#!/usr/bin/env bash
# record_watch_apps.sh
# Record all three watchOS apps

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR="$SCRIPT_DIR/../../FunctionalTestVideos/watchOS"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

mkdir -p "$OUTPUT_DIR"

echo "========================================="
echo "  watchOS VIDEO RECORDING"
echo "========================================="
echo ""

log_info "Recording watchOS apps..."
log_warn "Manual recording required for watchOS"
echo ""

echo "RECORDING INSTRUCTIONS:"
echo ""
echo "1. CLINICIAN WATCH (3 minutes)"
echo "   - Launch Xcode"
echo "   - Open: apps/ClinicianApp/watchOS/FoTClinicianWatch.xcodeproj"
echo "   - Select Watch scheme"
echo "   - Build and Run (⌘R)"
echo "   - Start QuickTime screen recording of Watch window"
echo "   - Demo: Quick vitals → Patient alerts → Patient list"
echo "   - Stop recording → Save to: $OUTPUT_DIR/Clinician_Watch_Demo.mov"
echo ""

echo "2. LEGAL US WATCH (3 minutes)"
echo "   - Open: apps/LegalUSApp/watchOS/FoTLegalWatch.xcodeproj"
echo "   - Select Watch scheme"
echo "   - Build and Run (⌘R)"
echo "   - Start QuickTime screen recording"
echo "   - Demo: Deadlines → Case lookup → Alerts"
echo "   - Stop recording → Save to: $OUTPUT_DIR/LegalUS_Watch_Demo.mov"
echo ""

echo "3. EDUCATION K-18 WATCH (3 minutes)"
echo "   - Open: apps/EducationK18App/watchOS/FoTEducationWatch.xcodeproj"
echo "   - Select Watch scheme"
echo "   - Build and Run (⌘R)"
echo "   - Start QuickTime screen recording"
echo "   - Demo: Assignments → Virtues → Study timer"
echo "   - Stop recording → Save to: $OUTPUT_DIR/EducationK18_Watch_Demo.mov"
echo ""

log_info "After recording all three, press Enter to continue..."
read

# Check if files exist
CLINICIAN_VIDEO="$OUTPUT_DIR/Clinician_Watch_Demo.mov"
LEGAL_VIDEO="$OUTPUT_DIR/LegalUS_Watch_Demo.mov"
EDUCATION_VIDEO="$OUTPUT_DIR/EducationK18_Watch_Demo.mov"

if [ -f "$CLINICIAN_VIDEO" ] && [ -f "$LEGAL_VIDEO" ] && [ -f "$EDUCATION_VIDEO" ]; then
    log_success "All watchOS videos recorded!"
    
    # Convert to MP4 if ffmpeg available
    if command -v ffmpeg &> /dev/null; then
        log_info "Converting to MP4..."
        ffmpeg -i "$CLINICIAN_VIDEO" -c:v libx264 -preset fast "$OUTPUT_DIR/Clinician_Watch_Demo.mp4" 2>/dev/null || true
        ffmpeg -i "$LEGAL_VIDEO" -c:v libx264 -preset fast "$OUTPUT_DIR/LegalUS_Watch_Demo.mp4" 2>/dev/null || true
        ffmpeg -i "$EDUCATION_VIDEO" -c:v libx264 -preset fast "$OUTPUT_DIR/EducationK18_Watch_Demo.mp4" 2>/dev/null || true
        log_success "Conversion complete!"
    fi
else
    log_warn "Some videos missing - please record manually"
fi

log_info "watchOS recording complete!"
log_info "Videos saved to: $OUTPUT_DIR"

