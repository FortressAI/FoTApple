#!/usr/bin/env bash
# Record Live Apps Running in Simulators
# This creates real screen recordings of your apps in action

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

mkdir -p "$OUTPUT_DIR"/{screen_recordings,final_with_screens}

# Simulator configurations
IPHONE_SIM="iPhone 17 Pro"
WATCH_SIM="Apple Watch Ultra (49mm)"

log_header "📱 Live App Screen Recording System"

# Function to boot simulator
boot_simulator() {
    local device_name=$1
    local device_type=$2
    
    log_info "Booting $device_name..."
    
    # Get device ID
    local device_id=$(xcrun simctl list devices | grep "$device_name" | grep -v "Preparing" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
    
    if [ -z "$device_id" ]; then
        log_error "Device '$device_name' not found"
        return 1
    fi
    
    # Boot if not already booted
    local state=$(xcrun simctl list devices | grep "$device_id" | grep -o "Booted" || echo "Shutdown")
    if [ "$state" != "Booted" ]; then
        xcrun simctl boot "$device_id" 2>/dev/null || true
        sleep 3
    fi
    
    echo "$device_id"
}

# Function to build and install app
build_and_install() {
    local app_name=$1
    local platform=$2
    local device_id=$3
    
    log_info "Building $app_name for $platform..."
    
    cd "$PROJECT_ROOT/apps/${app_name}App/$platform"
    
    # Determine destination
    local destination=""
    case $platform in
        iOS)
            destination="platform=iOS Simulator,name=$IPHONE_SIM"
            ;;
        watchOS)
            destination="platform=watchOS Simulator,name=$WATCH_SIM"
            ;;
    esac
    
    # Build
    xcodebuild \
        -scheme "FoT${app_name}" \
        -destination "$destination" \
        -configuration Debug \
        clean build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | grep -E "(Building|Succeeded|Failed)" | tail -5 || true
    
    if [ $? -eq 0 ]; then
        log_success "Build complete"
        return 0
    else
        log_error "Build failed"
        return 1
    fi
}

# Function to launch app
launch_app() {
    local bundle_id=$1
    local device_id=$2
    
    log_info "Launching app: $bundle_id"
    xcrun simctl launch "$device_id" "$bundle_id" 2>/dev/null || true
    sleep 2
}

# Function to record screen
record_screen() {
    local device_id=$1
    local output_file=$2
    local duration=$3
    local app_name=$4
    
    log_info "Recording screen for ${duration}s..."
    log_warning "Please interact with the app now!"
    echo ""
    echo "  Show these features:"
    echo "  - Main interface"
    echo "  - Key functionality"
    echo "  - Navigation flow"
    echo ""
    
    # Start recording
    timeout "$duration" xcrun simctl io "$device_id" recordVideo \
        --codec=h264 \
        --force \
        "$output_file" 2>/dev/null || true
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Recording complete: $(basename $output_file) ($size)"
        return 0
    else
        log_error "Recording failed"
        return 1
    fi
}

# Function to combine screen recording with audio
combine_with_audio() {
    local screen_file=$1
    local audio_file=$2
    local output_file=$3
    
    log_info "Combining screen + audio: $(basename $output_file)"
    
    # Get audio duration
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null)
    
    # Combine: loop screen if needed, match audio duration
    ffmpeg -stream_loop -1 -i "$screen_file" \
        -i "$audio_file" \
        -filter_complex "\
            [0:v]scale=1920:1080:force_original_aspect_ratio=decrease,\
            pad=1920:1080:(ow-iw)/2:(oh-ih)/2,\
            fade=t=in:st=0:d=1,\
            fade=t=out:st=$((${duration%.*}-2)):d=2[v]" \
        -map "[v]" -map 1:a \
        -c:v libx264 -preset slow -crf 17 -profile:v high \
        -c:a aac -b:a 192k -ar 44100 \
        -pix_fmt yuv420p \
        -movflags +faststart \
        -t "$duration" \
        -shortest \
        -y "$output_file" 2>&1 | grep -E "(frame=|time=)" | tail -2 || true
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Final video: $(basename $output_file) ($size)"
        return 0
    else
        log_error "Combining failed"
        return 1
    fi
}

# Record iOS apps
record_ios_app() {
    local app_name=$1
    local display_name=$2
    local bundle_id="com.fot.$(echo $app_name | tr '[:upper:]' '[:lower:]')"
    
    log_header "Recording: $display_name iOS"
    
    # Boot simulator
    local device_id=$(boot_simulator "$IPHONE_SIM" "iOS")
    if [ -z "$device_id" ]; then
        return 1
    fi
    
    # Build and install (skip if already built)
    # build_and_install "$app_name" "iOS" "$device_id" || return 1
    
    # Launch app
    # launch_app "$bundle_id" "$device_id"
    
    log_warning "MANUAL STEPS:"
    echo "  1. Open Simulator (should be running)"
    echo "  2. Launch the $display_name app manually"
    echo "  3. Press ENTER when ready to start recording..."
    read -r
    
    # Record screen (get duration from audio)
    local audio_file="$OUTPUT_DIR/audio_professional/${app_name}_iOS.aiff"
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null | cut -d. -f1)
    duration=$((duration + 5))  # Add 5s buffer
    
    local screen_file="$OUTPUT_DIR/screen_recordings/${app_name}_iOS_screen.mov"
    record_screen "$device_id" "$screen_file" "$duration" "$app_name"
    
    # Combine with audio
    local final_file="$OUTPUT_DIR/final_with_screens/${app_name}_iOS_LIVE.mp4"
    if [ -f "$audio_file" ]; then
        combine_with_audio "$screen_file" "$audio_file" "$final_file"
    fi
}

# Record watchOS apps
record_watch_app() {
    local app_name=$1
    local display_name=$2
    local bundle_id="com.fot.$(echo $app_name | tr '[:upper:]' '[:lower:]').watchkitapp"
    
    log_header "Recording: $display_name watchOS"
    
    # Boot watch simulator
    local device_id=$(boot_simulator "$WATCH_SIM" "watchOS")
    if [ -z "$device_id" ]; then
        return 1
    fi
    
    log_warning "MANUAL STEPS:"
    echo "  1. Open Watch Simulator"
    echo "  2. Launch the $display_name app manually"
    echo "  3. Press ENTER when ready to start recording..."
    read -r
    
    # Record screen
    local audio_file="$OUTPUT_DIR/audio_professional/${app_name}_watchOS.aiff"
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null | cut -d. -f1)
    duration=$((duration + 5))
    
    local screen_file="$OUTPUT_DIR/screen_recordings/${app_name}_watchOS_screen.mov"
    record_screen "$device_id" "$screen_file" "$duration" "$app_name"
    
    # Combine with audio
    local final_file="$OUTPUT_DIR/final_with_screens/${app_name}_watchOS_LIVE.mp4"
    if [ -f "$audio_file" ]; then
        combine_with_audio "$screen_file" "$audio_file" "$final_file"
    fi
}

# Main menu
show_menu() {
    echo ""
    log_header "📱 Record Live Apps"
    echo "Select what to record:"
    echo ""
    echo "  iOS Apps:"
    echo "    1) Clinician iOS"
    echo "    2) Legal US iOS"
    echo "    3) Education K-18 iOS"
    echo ""
    echo "  watchOS Apps:"
    echo "    4) Clinician watchOS"
    echo "    5) Legal US watchOS"
    echo "    6) Education K-18 watchOS"
    echo ""
    echo "  Batch:"
    echo "    7) Record ALL iOS apps"
    echo "    8) Record ALL watchOS apps"
    echo "    9) Record EVERYTHING"
    echo ""
    echo "    0) Exit"
    echo ""
    read -p "Choice: " choice
    echo ""
    
    case $choice in
        1) record_ios_app "Clinician" "FoT Clinician" ;;
        2) record_ios_app "LegalUS" "FoT Legal US" ;;
        3) record_ios_app "EducationK18" "FoT Education K-18" ;;
        4) record_watch_app "Clinician" "FoT Clinician" ;;
        5) record_watch_app "LegalUS" "FoT Legal US" ;;
        6) record_watch_app "EducationK18" "FoT Education" ;;
        7) 
            record_ios_app "Clinician" "FoT Clinician"
            record_ios_app "LegalUS" "FoT Legal US"
            record_ios_app "EducationK18" "FoT Education K-18"
            ;;
        8)
            record_watch_app "Clinician" "FoT Clinician"
            record_watch_app "LegalUS" "FoT Legal US"
            record_watch_app "EducationK18" "FoT Education"
            ;;
        9)
            record_ios_app "Clinician" "FoT Clinician"
            record_ios_app "LegalUS" "FoT Legal US"
            record_ios_app "EducationK18" "FoT Education K-18"
            record_watch_app "Clinician" "FoT Clinician"
            record_watch_app "LegalUS" "FoT Legal US"
            record_watch_app "EducationK18" "FoT Education"
            ;;
        0) exit 0 ;;
        *) log_error "Invalid choice"; show_menu ;;
    esac
    
    # Show menu again
    show_menu
}

# Show introduction
log_header "🎬 Live App Recording System"
log_info "This will record your actual apps running in simulators"
log_info ""
log_info "Process:"
log_info "  1. Select app to record"
log_info "  2. Simulator boots automatically"
log_info "  3. Launch app manually when prompted"
log_info "  4. Recording starts when you press ENTER"
log_info "  5. Interact with app during recording"
log_info "  6. Recording stops automatically"
log_info "  7. Video combines with professional audio"
log_info ""
log_warning "Tip: Plan your demo flow before recording!"

show_menu

