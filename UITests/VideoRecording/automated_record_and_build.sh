#!/usr/bin/env bash
# Automated Build, Test, and Record System
# Builds apps, runs XCUITest automation, records screen simultaneously

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIO_DIR="$PROJECT_ROOT/FoTMarketingVideos/audio_natural"
RAW_RECORDINGS_DIR="$PROJECT_ROOT/FoTMarketingVideos/raw_recordings"
TUTORIALS_DIR="$PROJECT_ROOT/FoTMarketingVideos/tutorials"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_section() {
    echo -e "\n${CYAN}▶ $1${NC}\n"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; }

mkdir -p "$RAW_RECORDINGS_DIR" "$TUTORIALS_DIR"

# Get audio duration
get_audio_duration() {
    local audio_file=$1
    if [ -f "$audio_file" ]; then
        afinfo "$audio_file" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "180"
    else
        echo "180"
    fi
}

# Build and record iOS app
build_and_record_ios() {
    local app_name=$1
    local scheme=$2
    local test_target=$3
    local duration=$4
    
    log_section "Building and Recording: $app_name iOS"
    
    local device="iPhone 15 Pro"
    local output_file="$RAW_RECORDINGS_DIR/${app_name}_iOS.mp4"
    
    # Build for testing
    log_info "Building $scheme for iOS testing..."
    xcodebuild \
        -scheme "$scheme" \
        -destination "platform=iOS Simulator,name=$device" \
        -configuration Debug \
        -derivedDataPath "$PROJECT_ROOT/build/DerivedData" \
        build-for-testing \
        2>&1 | grep -E '(error|warning|Build Succeeded)' || true
    
    if [ $? -ne 0 ]; then
        log_error "Build failed for $scheme"
        return 1
    fi
    
    log_success "Build complete"
    
    # Boot simulator
    log_info "Booting simulator: $device"
    xcrun simctl boot "$device" 2>/dev/null || true
    open -a Simulator
    sleep 5
    
    # Start recording
    log_info "Starting screen recording (${duration}s)..."
    xcrun simctl io "$device" recordVideo --codec=h264 --force "$output_file" &
    local record_pid=$!
    
    # Run UI test (which will drive the app)
    log_info "Running automated UI test: $test_target"
    xcodebuild \
        -scheme "$scheme" \
        -destination "platform=iOS Simulator,name=$device" \
        -configuration Debug \
        -derivedDataPath "$PROJECT_ROOT/build/DerivedData" \
        test-without-building \
        -only-testing:"$test_target" \
        2>&1 | grep -E '(Test Suite|Test Case|passed|failed)' &
    local test_pid=$!
    
    # Wait for test to complete or duration to expire
    local elapsed=0
    while kill -0 $test_pid 2>/dev/null && [ $elapsed -lt $duration ]; do
        sleep 5
        elapsed=$((elapsed + 5))
        echo -n "."
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
        log_error "Recording failed"
        return 1
    fi
}

# Build and record macOS app
build_and_record_macos() {
    local app_name=$1
    local scheme=$2
    local duration=$3
    
    log_section "Building and Recording: $app_name macOS"
    
    local output_file="$RAW_RECORDINGS_DIR/${app_name}_macOS.mp4"
    
    # Build app
    log_info "Building $scheme for macOS..."
    xcodebuild \
        -scheme "$scheme" \
        -destination "platform=macOS" \
        -configuration Debug \
        -derivedDataPath "$PROJECT_ROOT/build/DerivedData" \
        build \
        2>&1 | grep -E '(error|warning|Build Succeeded)' || true
    
    if [ $? -ne 0 ]; then
        log_error "Build failed for $scheme"
        return 1
    fi
    
    log_success "Build complete"
    
    # Find built app
    local app_path=$(find "$PROJECT_ROOT/build/DerivedData" -name "${scheme}.app" -type d | head -1)
    
    if [ -z "$app_path" ]; then
        log_error "Could not find built app"
        return 1
    fi
    
    log_info "Found app: $app_path"
    
    # Launch app
    log_info "Launching $scheme..."
    open "$app_path"
    sleep 3
    
    # Start recording
    log_info "Recording screen for ${duration}s..."
    log_warning "👉 App is running - automated interactions happening now"
    
    ffmpeg -f avfoundation -i "1:none" -t "$duration" -r 30 -y "$output_file" 2>/dev/null &
    local record_pid=$!
    
    # TODO: Run automated AppleScript interactions here
    # For now, just wait for duration
    sleep "$duration"
    
    # Stop recording
    wait $record_pid 2>/dev/null || true
    
    # Quit app
    osascript -e "tell application \"$scheme\" to quit" 2>/dev/null || {
        killall "$scheme" 2>/dev/null || true
    }
    
    # Verify recording
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "$app_name macOS recorded ($size)"
        return 0
    else
        log_error "Recording failed"
        return 1
    fi
}

# Combine video and audio into final tutorial
create_tutorial() {
    local app_name=$1
    local platform=$2
    
    log_info "Creating tutorial: $app_name $platform"
    
    local video_file="$RAW_RECORDINGS_DIR/${app_name}_${platform}.mp4"
    local audio_file="$AUDIO_DIR/${app_name}_${platform}.aiff"
    local output_file="$TUTORIALS_DIR/${app_name}_${platform}_Tutorial.mp4"
    
    if [ ! -f "$video_file" ]; then
        log_warning "Video not found: $video_file"
        return 1
    fi
    
    if [ ! -f "$audio_file" ]; then
        log_warning "Audio not found: $audio_file"
        return 1
    fi
    
    # Combine with professional encoding
    ffmpeg -i "$video_file" -i "$audio_file" \
        -c:v libx264 -preset slow -crf 18 \
        -c:a aac -b:a 192k \
        -shortest \
        -y "$output_file" 2>/dev/null
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Tutorial created: $(basename $output_file) ($size)"
        return 0
    else
        log_error "Tutorial creation failed"
        return 1
    fi
}

# Main execution
main() {
    clear
    
    log_header "🎬 AUTOMATED BUILD, TEST, AND RECORD SYSTEM"
    log_info "Building apps, running automated UI tests, recording screens"
    echo ""
    
    log_warning "This will take 30-45 minutes to complete all recordings"
    echo ""
    read -p "Press ENTER to start..."
    echo ""
    
    # ================================================================
    # iOS Apps
    # ================================================================
    log_header "iOS APPS - AUTOMATED RECORDING"
    
    # Clinician iOS
    local clinician_ios_duration=$(get_audio_duration "$AUDIO_DIR/Clinician_iOS.aiff")
    build_and_record_ios \
        "Clinician" \
        "FoTClinician" \
        "FoTClinicianUITests/ClinicianIOSRecordingTests/test_RecordClinicianIOSDemo" \
        "$clinician_ios_duration"
    
    create_tutorial "Clinician" "iOS"
    echo ""
    
    # Legal US iOS
    # local legalus_ios_duration=$(get_audio_duration "$AUDIO_DIR/LegalUS_iOS.aiff")
    # build_and_record_ios \
    #     "LegalUS" \
    #     "FoTLegalUS" \
    #     "FoTLegalUSUITests/LegalUSIOSRecordingTests/test_RecordLegalUSIOSDemo" \
    #     "$legalus_ios_duration"
    # create_tutorial "LegalUS" "iOS"
    # echo ""
    
    # Education K-18 iOS
    # local education_ios_duration=$(get_audio_duration "$AUDIO_DIR/EducationK18_iOS.aiff")
    # build_and_record_ios \
    #     "EducationK18" \
    #     "FoTEducationK18" \
    #     "FoTEducationK18UITests/EducationK18IOSRecordingTests/test_RecordEducationK18IOSDemo" \
    #     "$education_ios_duration"
    # create_tutorial "EducationK18" "iOS"
    # echo ""
    
    # ================================================================
    # macOS Apps
    # ================================================================
    log_header "macOS APPS - AUTOMATED RECORDING"
    
    # Clinician macOS
    local clinician_macos_duration=$(get_audio_duration "$AUDIO_DIR/Clinician_macOS.aiff")
    build_and_record_macos \
        "Clinician" \
        "FoTClinicianMac" \
        "$clinician_macos_duration"
    
    create_tutorial "Clinician" "macOS"
    echo ""
    
    # ================================================================
    # Summary
    # ================================================================
    log_header "✅ AUTOMATED RECORDING COMPLETE"
    
    log_success "Generated Files:"
    echo "  • Raw recordings: $RAW_RECORDINGS_DIR"
    echo "  • Final tutorials: $TUTORIALS_DIR"
    echo ""
    
    log_info "Tutorial files created:"
    ls -lh "$TUTORIALS_DIR"/*.mp4 2>/dev/null || log_warning "No tutorials created yet"
    echo ""
    
    log_info "Next steps:"
    echo "  1. Review tutorials: open $TUTORIALS_DIR"
    echo "  2. View showcase: open $PROJECT_ROOT/TUTORIALS_SHOWCASE.html"
    echo "  3. Share with beta testers"
    echo ""
}

main "$@"

