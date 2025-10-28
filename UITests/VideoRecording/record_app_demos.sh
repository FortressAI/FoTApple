#!/usr/bin/env bash
# Record Live App Demonstrations for Professional Tutorials
# Launches apps in simulators and records screen for tutorial videos

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIO_DIR="$PROJECT_ROOT/FoTMarketingVideos/audio_natural"
RAW_RECORDINGS_DIR="$PROJECT_ROOT/FoTMarketingVideos/raw_recordings"
BUILD_DIR="$PROJECT_ROOT/build"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; }

mkdir -p "$RAW_RECORDINGS_DIR"

# Get audio duration for an app
get_audio_duration() {
    local audio_file=$1
    
    if [ -f "$audio_file" ]; then
        afinfo "$audio_file" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+10}' || echo "180"
    else
        echo "180"  # Default 3 minutes
    fi
}

# Record iOS app
record_ios_app() {
    local app_name=$1
    local bundle_id=$2
    local duration=$3
    
    log_info "Recording $app_name on iOS (${duration}s)..."
    
    local device="iPhone 15 Pro"
    local output_file="$RAW_RECORDINGS_DIR/${app_name}_iOS.mp4"
    
    # Boot simulator
    log_info "Booting simulator: $device"
    xcrun simctl boot "$device" 2>/dev/null || true
    open -a Simulator
    sleep 5
    
    # Install app if built
    local app_path="$BUILD_DIR/Debug-iphonesimulator/${app_name}.app"
    if [ -d "$app_path" ]; then
        log_info "Installing $app_name..."
        xcrun simctl install "$device" "$app_path" 2>/dev/null || true
    fi
    
    # Launch app
    log_info "Launching $app_name..."
    xcrun simctl launch "$device" "$bundle_id" || {
        log_error "Failed to launch $bundle_id"
        log_warning "Make sure the app is built for simulator"
        return 1
    }
    sleep 3
    
    # Start recording
    log_info "Recording for ${duration} seconds..."
    log_warning "👉 INTERACT WITH THE APP NOW - FOLLOW THE NARRATION SCRIPT"
    
    xcrun simctl io "$device" recordVideo --codec=h264 --force "$output_file" &
    local record_pid=$!
    
    # Show countdown
    for i in $(seq 1 $((duration / 10))); do
        echo -n "."
        sleep 10
    done
    echo ""
    
    # Stop recording
    log_info "Stopping recording..."
    kill -SIGINT $record_pid 2>/dev/null || true
    wait $record_pid 2>/dev/null || true
    sleep 3
    
    # Verify recording
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "$app_name iOS recorded ($size)"
        return 0
    else
        log_error "Failed to create recording"
        return 1
    fi
}

# Record macOS app
record_macos_app() {
    local app_name=$1
    local bundle_id=$2
    local duration=$3
    
    log_info "Recording $app_name on macOS (${duration}s)..."
    
    local app_path="$BUILD_DIR/Debug/${app_name}.app"
    local output_file="$RAW_RECORDINGS_DIR/${app_name}_macOS.mp4"
    
    if [ ! -d "$app_path" ]; then
        log_error "App not found: $app_path"
        log_warning "Build the macOS app first"
        return 1
    fi
    
    # Launch app
    log_info "Launching $app_name..."
    open "$app_path"
    sleep 3
    
    # Get app window bounds
    log_info "Recording for ${duration} seconds..."
    log_warning "👉 INTERACT WITH THE APP NOW - FOLLOW THE NARRATION SCRIPT"
    
    # Use screencapture with countdown
    # Record entire screen (we'll crop in post-production)
    ffmpeg -f avfoundation -i "1:none" -t "$duration" -r 30 -y "$output_file" 2>/dev/null &
    local record_pid=$!
    
    # Show countdown
    for i in $(seq 1 $((duration / 10))); do
        echo -n "."
        sleep 10
    done
    echo ""
    
    # Stop recording
    wait $record_pid 2>/dev/null || true
    
    # Quit app
    osascript -e "tell application \"$app_name\" to quit" 2>/dev/null || {
        killall "$app_name" 2>/dev/null || true
    }
    
    # Verify recording
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "$app_name macOS recorded ($size)"
        return 0
    else
        log_error "Failed to create recording"
        return 1
    fi
}

# Main recording workflow
main() {
    log_header "🎬 RECORD LIVE APP DEMONSTRATIONS"
    
    echo ""
    log_warning "IMPORTANT: You need to interact with each app during recording!"
    log_info "Follow the narration scripts in UITests/VideoRecording/marketing_*.txt"
    echo ""
    read -p "Press ENTER when ready to start recording..."
    echo ""
    
    # iOS Apps
    log_header "iOS APP RECORDINGS"
    
    local clinician_ios_duration=$(get_audio_duration "$AUDIO_DIR/Clinician_iOS.aiff")
    record_ios_app "FoTClinician" "com.fot.clinician" "$clinician_ios_duration"
    echo ""
    read -p "Press ENTER to continue to next app..."
    
    local legalus_ios_duration=$(get_audio_duration "$AUDIO_DIR/LegalUS_iOS.aiff")
    record_ios_app "FoTLegalUS" "com.fot.legalus" "$legalus_ios_duration"
    echo ""
    read -p "Press ENTER to continue to next app..."
    
    local education_ios_duration=$(get_audio_duration "$AUDIO_DIR/EducationK18_iOS.aiff")
    record_ios_app "FoTEducationK18" "com.fot.educationk18" "$education_ios_duration"
    echo ""
    
    # macOS Apps
    log_header "macOS APP RECORDINGS"
    
    local clinician_macos_duration=$(get_audio_duration "$AUDIO_DIR/Clinician_macOS.aiff")
    record_macos_app "FoTClinicianMac" "com.fot.clinician" "$clinician_macos_duration"
    echo ""
    read -p "Press ENTER to continue to next app..."
    
    local legalus_macos_duration=$(get_audio_duration "$AUDIO_DIR/LegalUS_macOS.aiff")
    record_macos_app "FoTLegalUSMac" "com.fot.legalus" "$legalus_macos_duration"
    echo ""
    read -p "Press ENTER to continue to next app..."
    
    local education_macos_duration=$(get_audio_duration "$AUDIO_DIR/EducationK18_macOS.aiff")
    record_macos_app "FoTEducationK18Mac" "com.fot.educationk18" "$education_macos_duration"
    echo ""
    
    # Summary
    log_header "✅ RECORDING COMPLETE"
    log_success "Raw recordings saved to: $RAW_RECORDINGS_DIR"
    echo ""
    log_info "Next steps:"
    echo "  1. Review recordings: open $RAW_RECORDINGS_DIR"
    echo "  2. Re-record any apps if needed"
    echo "  3. Run create_all_professional_tutorials.sh to combine with audio"
    echo ""
}

main "$@"

