#!/usr/bin/env bash
# Automated Marketing Video Recording
# Uses XCUITest to drive apps programmatically while recording video

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

log_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; }

mkdir -p "$OUTPUT_DIR"/{screen_recordings_auto,final_automated}

IPHONE_SIM="iPhone 17 Pro"
DEVICE_ID=""

# Boot simulator
boot_simulator() {
    log_info "Booting $IPHONE_SIM..."
    
    DEVICE_ID=$(xcrun simctl list devices | grep "$IPHONE_SIM" | grep -v "Preparing" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
    
    if [ -z "$DEVICE_ID" ]; then
        log_error "Device '$IPHONE_SIM' not found"
        exit 1
    fi
    
    STATE=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "Booted" || echo "Shutdown")
    if [ "$STATE" != "Booted" ]; then
        xcrun simctl boot "$DEVICE_ID"
        sleep 3
    fi
    
    log_success "Simulator ready: $DEVICE_ID"
    open -a Simulator
    sleep 2
}

# Run XCUITest and record video
record_automated_demo() {
    local app_name=$1
    local test_class=$2
    local test_method=$3
    
    log_header "🤖 Automated Recording: $app_name"
    
    # Get audio duration for reference
    local audio_file="$OUTPUT_DIR/audio_professional/${app_name}_iOS.aiff"
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null | cut -d. -f1)
    duration=$((duration + 10))  # Add buffer
    
    log_info "Expected duration: ${duration}s"
    
    # Output files
    local screen_file="$OUTPUT_DIR/screen_recordings_auto/${app_name}_iOS_auto.mov"
    local final_file="$OUTPUT_DIR/final_automated/${app_name}_iOS_AUTO.mp4"
    
    log_info "Starting video recording..."
    
    # Start screen recording in background
    xcrun simctl io "$DEVICE_ID" recordVideo \
        --codec=h264 \
        --force \
        "$screen_file" &
    
    local record_pid=$!
    log_info "Recording started (PID: $record_pid)"
    
    sleep 2  # Let recording stabilize
    
    # Run XCUITest that drives the app
    log_info "Launching automated UI test..."
    log_warning "The test will drive the app automatically"
    
    cd "$PROJECT_ROOT/apps/${app_name}App/iOS"
    
    xcodebuild test \
        -scheme "FoT${app_name}" \
        -destination "platform=iOS Simulator,name=$IPHONE_SIM" \
        -only-testing:"FoT${app_name}UITests/${test_class}/${test_method}" \
        2>&1 | grep -E "(Test Case|passed|failed)" || true
    
    local test_result=$?
    
    # Stop recording
    log_info "Stopping recording..."
    kill -INT $record_pid 2>/dev/null || true
    wait $record_pid 2>/dev/null || true
    
    sleep 2
    
    if [ -f "$screen_file" ]; then
        local size=$(du -h "$screen_file" | awk '{print $1}')
        log_success "Screen recording complete: $size"
        
        # Combine with audio
        log_info "Combining screen + audio..."
        
        local audio_duration=$(ffprobe -v error -show_entries format=duration \
            -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null)
        
        ffmpeg -i "$screen_file" \
            -i "$audio_file" \
            -filter_complex "\
                [0:v]scale=1920:1080:force_original_aspect_ratio=decrease,\
                pad=1920:1080:(ow-iw)/2:(oh-ih)/2,\
                fade=t=in:st=0:d=1,\
                fade=t=out:st=$((${audio_duration%.*}-2)):d=2[v]" \
            -map "[v]" -map 1:a \
            -c:v libx264 -preset slow -crf 17 -profile:v high \
            -c:a aac -b:a 192k -ar 44100 \
            -pix_fmt yuv420p \
            -movflags +faststart \
            -t "$audio_duration" \
            -y "$final_file" 2>&1 | grep -E "time=" | tail -2 || true
        
        if [ -f "$final_file" ]; then
            local final_size=$(du -h "$final_file" | awk '{print $1}')
            log_success "Final video complete: $final_size"
            
            log_info "Playing result..."
            open "$final_file"
            
            return 0
        else
            log_error "Failed to create final video"
            return 1
        fi
    else
        log_error "Screen recording failed"
        return 1
    fi
}

# Main
log_header "🤖 Automated Marketing Video System"
log_info "This system uses XCUITest to drive apps automatically"
log_info "The app will be controlled programmatically to match audio timeline"
echo ""

# Boot simulator
boot_simulator

echo ""
log_info "Select app to record:"
echo ""
echo "  1) Clinician iOS (automated)"
echo "  2) Legal US iOS (automated)"
echo "  3) Education K-18 iOS (automated)"
echo ""
echo "  0) Exit"
echo ""
read -p "Choice: " choice

case $choice in
    1)
        record_automated_demo "Clinician" "ClinicianMarketingTests" "test_ClinicianMarketingDemo"
        ;;
    2)
        log_warning "Legal US automated test not yet implemented"
        log_info "Use manual recording for now"
        ;;
    3)
        log_warning "Education K-18 automated test not yet implemented"
        log_info "Use manual recording for now"
        ;;
    0)
        exit 0
        ;;
    *)
        log_error "Invalid choice"
        exit 1
        ;;
esac

log_header "✅ Automated Recording Complete!"
log_info "The app was driven programmatically to perfectly sync with audio"
log_info "Output: $OUTPUT_DIR/final_automated/"

