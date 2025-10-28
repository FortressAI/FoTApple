#!/usr/bin/env bash
# Record with On-Screen Prompts
# Shows you what to do at each timestamp while recording

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_time() { echo -e "${CYAN}⏱ [$1]${NC}  $2"; }
log_action() { echo -e "${YELLOW}👉${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }

# Clinician iOS Demo Script
demo_clinician_ios() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  🎬 Clinician iOS Recording Guide${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    log_time "0:00-0:10" "INTRO - Show patient dashboard"
    log_action "Have app open with patient list visible"
    echo ""
    
    log_time "0:10-0:20" "SELECT PATIENT - Tap John Doe"
    log_action "Show patient details screen"
    echo ""
    
    log_time "0:20-0:30" "ALLERGY ALERT - Scroll to allergies"
    log_action "Show Penicillin allergy with red indicator"
    echo ""
    
    log_time "0:30-0:40" "MEDICATIONS - Navigate to meds tab"
    log_action "Show Aspirin 81mg prescription"
    echo ""
    
    log_time "0:40-0:55" "ADD MEDICATION - Tap 'Add Medication'"
    log_action "Search 'Warfarin', select, enter 5mg, save"
    echo ""
    
    log_time "0:55-1:10" "API CALL - Loading appears"
    log_action "Wait for 'Checking interactions...'"
    echo ""
    
    log_time "1:10-1:25" "INTERACTION ALERT - Red alert appears"
    log_action "Show critical warning: Aspirin + Warfarin"
    echo ""
    
    log_time "1:25-1:40" "EXPLANATION - Tap 'Details'"
    log_action "Show why, alternatives, evidence"
    echo ""
    
    log_time "1:40-1:55" "VIRTUES - Show virtue scores"
    log_action "Justice, Temperance, Prudence, Fortitude bars"
    echo ""
    
    log_time "1:55-2:10" "SOAP NOTE - Tap 'New Encounter'"
    log_action "Show voice input, chief complaint field"
    echo ""
    
    log_time "2:10-2:25" "AI ASSIST - Fill SOAP sections"
    log_action "Show AI suggestions, manual edits"
    echo ""
    
    log_time "2:25-2:40" "CRYPTO RECEIPT - Tap 'View Proof'"
    log_action "Show hash, signature, blockchain badge"
    echo ""
    
    log_time "2:40-2:55" "EXPORT - Tap 'Export Bundle'"
    log_action "Show progress, confirmation"
    echo ""
    
    log_time "2:55-3:06" "PRIVACY - Go to Settings"
    log_action "Show on-device badge, HIPAA, encryption"
    echo ""
    
    log_time "3:06-3:15" "CONNECTED - Return to main"
    log_action "Smooth navigation, responsive UI"
    echo ""
    
    log_time "3:15-3:26" "CLOSING - Final dashboard view"
    log_action "Professional interface, fade out"
    echo ""
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Legal US iOS Demo Script
demo_legalus_ios() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  ⚖️ Legal US iOS Recording Guide${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    log_time "0:00-0:15" "INTRO - Show case list"
    log_action "Display active cases"
    echo ""
    
    log_time "0:15-0:40" "SELECT CASE - Tap case"
    log_action "Show case details, parties, dates"
    echo ""
    
    log_time "0:40-1:10" "DEADLINE CALC - Use calculator"
    log_action "Select trigger date, show deadline"
    echo ""
    
    log_time "1:10-1:40" "JURISDICTION - Show rules"
    log_action "Display state-specific requirements"
    echo ""
    
    log_time "1:40-2:00" "GENERATE DOC - Create document"
    log_action "Show template, fill fields"
    echo ""
    
    log_time "2:00-2:20" "PROOF - Show signature"
    log_action "Cryptographic hash, blockchain anchor"
    echo ""
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Education K18 iOS Demo Script
demo_education_ios() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  📚 Education K-18 iOS Recording Guide${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    log_time "0:00-0:20" "INTRO - Student dashboard"
    log_action "Show learning path overview"
    echo ""
    
    log_time "0:20-0:50" "LEARNING PATH - Navigate path"
    log_action "Show curriculum, progress indicators"
    echo ""
    
    log_time "0:50-1:30" "LESSON - Start lesson"
    log_action "Show content, answer questions"
    echo ""
    
    log_time "1:30-2:00" "VIRTUES - Show tracking"
    log_action "Aristotelian virtues, growth chart"
    echo ""
    
    log_time "2:00-2:30" "ANALYTICS - Progress view"
    log_action "Mastery levels, recommendations"
    echo ""
    
    log_time "2:30-3:00" "ADAPTIVE - Difficulty adjust"
    log_action "Show personalization, adaptation"
    echo ""
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Record with prompts
record_with_guide() {
    local app=$1
    local platform=$2
    
    # Show demo script
    case "$app-$platform" in
        Clinician-iOS)     demo_clinician_ios ;;
        LegalUS-iOS)       demo_legalus_ios ;;
        EducationK18-iOS)  demo_education_ios ;;
        *) echo "Demo script not yet created for $app $platform" ;;
    esac
    
    echo ""
    echo -e "${BLUE}ℹ${NC}  Read the timeline above"
    echo -e "${BLUE}ℹ${NC}  Practice once without recording"
    echo -e "${BLUE}ℹ${NC}  Then press ENTER to start recording"
    echo ""
    read -p "Press ENTER when ready: "
    
    # Boot simulator
    local DEVICE_NAME="iPhone 17 Pro"
    local DEVICE_ID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -v "Preparing" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
    
    if [ -z "$DEVICE_ID" ]; then
        echo "Error: Device not found"
        return 1
    fi
    
    # Boot if needed
    STATE=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "Booted" || echo "Shutdown")
    if [ "$STATE" != "Booted" ]; then
        xcrun simctl boot "$DEVICE_ID"
        sleep 3
    fi
    
    open -a Simulator
    sleep 2
    
    echo ""
    echo -e "${YELLOW}⚠${NC}  Open the $app app in the simulator now"
    echo -e "${YELLOW}⚠${NC}  Get to the starting screen"
    echo ""
    read -p "Press ENTER to start recording: "
    
    # Get duration from audio
    local audio_file="$OUTPUT_DIR/audio_professional/${app}_${platform}.aiff"
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null | cut -d. -f1)
    duration=$((duration + 5))
    
    # Start recording
    local output_file="$OUTPUT_DIR/screen_recordings/${app}_${platform}_screen.mov"
    mkdir -p "$OUTPUT_DIR/screen_recordings"
    
    echo ""
    echo -e "${GREEN}🔴${NC}  RECORDING - Follow the timeline!"
    echo ""
    
    # Record
    timeout "$duration" xcrun simctl io "$DEVICE_ID" recordVideo \
        --codec=h264 \
        --force \
        "$output_file" 2>/dev/null || true
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Recording complete: $size"
        
        # Combine with audio
        local final_file="$OUTPUT_DIR/final_with_screens/${app}_${platform}_LIVE.mp4"
        mkdir -p "$OUTPUT_DIR/final_with_screens"
        
        echo ""
        echo -e "${BLUE}ℹ${NC}  Combining screen + audio..."
        
        ffmpeg -stream_loop -1 -i "$output_file" \
            -i "$audio_file" \
            -filter_complex "\
                [0:v]scale=1920:1080:force_original_aspect_ratio=decrease,\
                pad=1920:1080:(ow-iw)/2:(oh-ih)/2,\
                fade=t=in:st=0:d=1,\
                fade=t=out:st=$((duration-7)):d=2[v]" \
            -map "[v]" -map 1:a \
            -c:v libx264 -preset slow -crf 17 -profile:v high \
            -c:a aac -b:a 192k -ar 44100 \
            -pix_fmt yuv420p \
            -movflags +faststart \
            -shortest \
            -y "$final_file" 2>&1 | grep -E "time=" | tail -2 || true
        
        if [ -f "$final_file" ]; then
            log_success "Final video created!"
            echo ""
            echo -e "${BLUE}ℹ${NC}  Playing result..."
            open "$final_file"
        fi
    else
        echo "Error: Recording failed"
        return 1
    fi
}

# Main menu
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  🎬 Guided Recording System${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Select app to record:"
echo ""
echo "  1) Clinician iOS"
echo "  2) Legal US iOS"
echo "  3) Education K-18 iOS"
echo ""
echo "  0) Exit"
echo ""
read -p "Choice: " choice

case $choice in
    1) record_with_guide "Clinician" "iOS" ;;
    2) record_with_guide "LegalUS" "iOS" ;;
    3) record_with_guide "EducationK18" "iOS" ;;
    0) exit 0 ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

