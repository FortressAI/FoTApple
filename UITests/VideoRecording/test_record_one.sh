#!/usr/bin/env bash
# Quick test: Record ONE app to verify the process works

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos/screen_recordings"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }

mkdir -p "$OUTPUT_DIR"

DEVICE_NAME="iPhone 17 Pro"
RECORD_TIME=180  # 3 minutes

echo ""
log_info "Quick Screen Recording Test"
echo ""
log_info "Device: $DEVICE_NAME"
log_info "Duration: ${RECORD_TIME}s"
echo ""

# Get device ID
log_info "Finding simulator..."
DEVICE_ID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -v "Preparing" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')

if [ -z "$DEVICE_ID" ]; then
    echo "Error: Device '$DEVICE_NAME' not found"
    exit 1
fi

log_success "Found: $DEVICE_ID"

# Boot simulator
log_info "Booting simulator..."
STATE=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "Booted" || echo "Shutdown")
if [ "$STATE" != "Booted" ]; then
    xcrun simctl boot "$DEVICE_ID"
    sleep 3
fi

# Open simulator UI
log_info "Opening Simulator.app..."
open -a Simulator

sleep 2

log_success "Simulator ready!"
echo ""
log_warning "NEXT STEPS:"
echo "  1. The Simulator should now be visible"
echo "  2. Manually navigate to and open your Clinician app"
echo "  3. Get it to the main screen you want to show"
echo "  4. Press ENTER here to start recording..."
echo ""
read -p "Press ENTER when ready: "

# Start recording
OUTPUT_FILE="$OUTPUT_DIR/test_recording.mov"
log_info "Recording for ${RECORD_TIME}s..."
log_warning "Demo your app now! Recording will stop automatically."
echo ""

# Record with timeout
timeout "$RECORD_TIME" xcrun simctl io "$DEVICE_ID" recordVideo \
    --codec=h264 \
    --force \
    "$OUTPUT_FILE" 2>/dev/null || true

if [ -f "$OUTPUT_FILE" ]; then
    SIZE=$(du -h "$OUTPUT_FILE" | awk '{print $1}')
    log_success "Recording complete!"
    echo ""
    log_info "File: $OUTPUT_FILE"
    log_info "Size: $SIZE"
    echo ""
    log_info "Playing recording..."
    open "$OUTPUT_FILE"
else
    echo "Error: Recording failed"
    exit 1
fi

echo ""
log_success "Test complete! If this worked, we can record all apps."

