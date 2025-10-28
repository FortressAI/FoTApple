#!/usr/bin/env bash
# Create Final Professional Marketing Videos
# Uses best built-in macOS voices with optimal settings

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }

# Setup
mkdir -p "$OUTPUT_DIR"/{audio_enhanced,final}

# Select best available voice with fallback
select_voice() {
    # Try premium voices first, fall back to basic
    for voice in "Samantha" "Alex" "Victoria" "Daniel"; do
        if say -v "$voice" "" 2>/dev/null; then
            echo "$voice"
            return 0
        fi
    done
    echo "Samantha"  # Default fallback
}

VOICE=$(select_voice)
log_info "Using voice: $VOICE (optimized for natural speech)"

# Generate enhanced audio with natural settings
generate_enhanced_audio() {
    local script_file=$1
    local output_file=$2
    local rate=${3:-180}  # Slightly slower for clarity
    
    log_info "Generating: $(basename $output_file)"
    
    # Generate with optimal settings for natural speech
    say -v "$VOICE" \
        -r "$rate" \
        -o "$output_file" \
        -f "$script_file"
    
    if [ -f "$output_file" ]; then
        local duration=$(afinfo "$output_file" 2>/dev/null | grep "estimated duration" | awk '{print $3}' || echo "N/A")
        log_success "Created: $(basename $output_file) (${duration}s)"
        return 0
    else
        return 1
    fi
}

# Create professional video from app screen recording + audio
create_video_from_recording() {
    local screen_recording=$1
    local audio_file=$2
    local title=$3
    local subtitle=$4
    local output_file=$5
    
    log_info "Creating professional video: $title"
    
    # Get audio duration
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null || echo "180")
    
    if [ -f "$screen_recording" ]; then
        # We have a screen recording - use it!
        log_info "Using screen recording: $(basename $screen_recording)"
        
        # Combine screen recording with audio, add intro/outro titles
        ffmpeg -i "$screen_recording" -i "$audio_file" \
            -filter_complex "\
                [0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,\
                fade=t=in:st=0:d=1,fade=t=out:st=$((${duration%.*}-2)):d=2,\
                drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                    text='$title':\
                    fontcolor=white:\
                    fontsize=60:\
                    x=(w-text_w)/2:\
                    y=50:\
                    shadowcolor=black@0.8:\
                    shadowx=2:\
                    shadowy=2:\
                    box=1:\
                    boxcolor=black@0.5:\
                    boxborderw=10:\
                    enable='between(t,0,3)'[v]" \
            -map "[v]" -map 1:a \
            -c:v libx264 -preset slow -crf 18 -profile:v high \
            -c:a aac -b:a 192k -ar 44100 \
            -pix_fmt yuv420p \
            -movflags +faststart \
            -t "$duration" \
            -y "$output_file" 2>&1 | grep -E "(frame=|time=)" | tail -5 || true
    else
        # No screen recording yet - create professional title card
        log_info "Creating title card video (record app screen later for final version)"
        
        # Create gradient background based on platform
        local color1="0x667eea"
        local color2="0x764ba2"
        
        if [[ "$title" == *"iOS"* ]] || [[ "$title" == *"iPhone"* ]]; then
            color1="0x007AFF"; color2="0x5856D6"
        elif [[ "$title" == *"watchOS"* ]] || [[ "$title" == *"Watch"* ]]; then
            color1="0xFF3B30"; color2="0xFF9500"
        elif [[ "$title" == *"macOS"* ]] || [[ "$title" == *"Mac"* ]]; then
            color1="0x5856D6"; color2="0x00C7BE"
        fi
        
        ffmpeg -f lavfi -i "color=c=${color1}:s=1920x1080:d=${duration}" \
            -f lavfi -i "color=c=${color2}:s=1920x1080:d=${duration}" \
            -i "$audio_file" \
            -filter_complex "\
                [0:v][1:v]blend=all_mode=overlay:all_opacity=0.5[bg]; \
                [bg]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                    text='$title':\
                    fontcolor=white:\
                    fontsize=80:\
                    x=(w-text_w)/2:\
                    y=(h-text_h)/2-120:\
                    shadowcolor=black:\
                    shadowx=3:\
                    shadowy=3:\
                    alpha='if(lt(t,1),t,if(lt(t,${duration%.*}-2),1,(${duration%.*}-t)/2))'[t1]; \
                [t1]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                    text='$subtitle':\
                    fontcolor=white:\
                    fontsize=42:\
                    x=(w-text_w)/2:\
                    y=(h-text_h)/2-20:\
                    alpha='if(lt(t,1.5),(t-0.5)*2,if(lt(t,${duration%.*}-2),1,(${duration%.*}-t)/2))'[final]" \
            -map "[final]" -map 2:a \
            -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
            -c:a aac -b:a 192k -ar 44100 \
            -movflags +faststart \
            -t "$duration" \
            -y "$output_file" 2>&1 | grep -E "(frame=|time=)" | tail -3 || true
    fi
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Complete: $(basename $output_file) ($size)"
        return 0
    else
        return 1
    fi
}

# Generate all enhanced audio
log_header "Step 1: Generating Enhanced Audio"
log_info "Using $VOICE voice at optimal rate for natural speech"

generate_enhanced_audio "$SCRIPT_DIR/marketing_clinician_ios.txt" "$OUTPUT_DIR/audio_enhanced/Clinician_iOS.aiff" 175
generate_enhanced_audio "$SCRIPT_DIR/marketing_legalus_ios.txt" "$OUTPUT_DIR/audio_enhanced/LegalUS_iOS.aiff" 175
generate_enhanced_audio "$SCRIPT_DIR/marketing_education_ios.txt" "$OUTPUT_DIR/audio_enhanced/EducationK18_iOS.aiff" 170

generate_enhanced_audio "$SCRIPT_DIR/marketing_clinician_watchos.txt" "$OUTPUT_DIR/audio_enhanced/Clinician_watchOS.aiff" 180
generate_enhanced_audio "$SCRIPT_DIR/marketing_legalus_watchos.txt" "$OUTPUT_DIR/audio_enhanced/LegalUS_watchOS.aiff" 180
generate_enhanced_audio "$SCRIPT_DIR/marketing_education_watchos.txt" "$OUTPUT_DIR/audio_enhanced/EducationK18_watchOS.aiff" 175

generate_enhanced_audio "$SCRIPT_DIR/marketing_clinician_macos.txt" "$OUTPUT_DIR/audio_enhanced/Clinician_macOS.aiff" 175
generate_enhanced_audio "$SCRIPT_DIR/marketing_legalus_macos.txt" "$OUTPUT_DIR/audio_enhanced/LegalUS_macOS.aiff" 170
generate_enhanced_audio "$SCRIPT_DIR/marketing_education_macos.txt" "$OUTPUT_DIR/audio_enhanced/EducationK18_macOS.aiff" 170

# Create videos
log_header "Step 2: Creating Professional Videos"

# iOS Videos
create_video_from_recording \
    "$OUTPUT_DIR/recordings/Clinician_iOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/Clinician_iOS.aiff" \
    "FoT Clinician for iOS" \
    "Clinical Decision Support That Proves Its Work" \
    "$OUTPUT_DIR/final/Clinician_iOS_FINAL.mp4"

create_video_from_recording \
    "$OUTPUT_DIR/recordings/LegalUS_iOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/LegalUS_iOS.aiff" \
    "FoT Legal US for iOS" \
    "Legal Practice Management With Proof" \
    "$OUTPUT_DIR/final/LegalUS_iOS_FINAL.mp4"

create_video_from_recording \
    "$OUTPUT_DIR/recordings/EducationK18_iOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/EducationK18_iOS.aiff" \
    "FoT Education K-18 for iOS" \
    "Virtue-Guided Learning For Every Student" \
    "$OUTPUT_DIR/final/EducationK18_iOS_FINAL.mp4"

# watchOS Videos
create_video_from_recording \
    "$OUTPUT_DIR/recordings/Clinician_watchOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/Clinician_watchOS.aiff" \
    "FoT Clinician for watchOS" \
    "Critical Clinical Data On Your Wrist" \
    "$OUTPUT_DIR/final/Clinician_watchOS_FINAL.mp4"

create_video_from_recording \
    "$OUTPUT_DIR/recordings/LegalUS_watchOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/LegalUS_watchOS.aiff" \
    "FoT Legal US for watchOS" \
    "Legal Alerts At Your Fingertips" \
    "$OUTPUT_DIR/final/LegalUS_watchOS_FINAL.mp4"

create_video_from_recording \
    "$OUTPUT_DIR/recordings/EducationK18_watchOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/EducationK18_watchOS.aiff" \
    "FoT Education for watchOS" \
    "Learning Companion For Young Minds" \
    "$OUTPUT_DIR/final/EducationK18_watchOS_FINAL.mp4"

# macOS Videos
create_video_from_recording \
    "$OUTPUT_DIR/recordings/Clinician_macOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/Clinician_macOS.aiff" \
    "FoT Clinician for macOS" \
    "Comprehensive Clinical Workspace" \
    "$OUTPUT_DIR/final/Clinician_macOS_FINAL.mp4"

create_video_from_recording \
    "$OUTPUT_DIR/recordings/LegalUS_macOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/LegalUS_macOS.aiff" \
    "FoT Legal US for macOS" \
    "Complete Legal Practice Suite" \
    "$OUTPUT_DIR/final/LegalUS_macOS_FINAL.mp4"

create_video_from_recording \
    "$OUTPUT_DIR/recordings/EducationK18_macOS_screen.mov" \
    "$OUTPUT_DIR/audio_enhanced/EducationK18_macOS.aiff" \
    "FoT Education for macOS" \
    "Complete Adaptive Learning Environment" \
    "$OUTPUT_DIR/final/EducationK18_macOS_FINAL.mp4"

log_header "✅ Production Complete!"
log_success "Videos created in: $OUTPUT_DIR/final/"
log_info ""
log_info "📊 Final Videos:"
ls -lh "$OUTPUT_DIR/final"/*FINAL.mp4 2>/dev/null | awk '{print "   " $9 " - " $5}' || true

log_info ""
log_info "🎬 Next: To add real screen recordings:"
log_info "   1. Record apps: ./record_app_screens.sh"
log_info "   2. Re-run this script to combine screen + audio"
log_info "   3. Get professional final videos!"

