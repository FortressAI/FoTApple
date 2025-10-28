#!/usr/bin/env bash
# Create Professional Marketing Videos with Optimized Built-in Voices
# Uses Samantha at optimal rate for most natural sound

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
mkdir -p "$OUTPUT_DIR"/{audio_professional,final_professional,recordings}

# Samantha is excellent for professional narration - using optimal rate
VOICE="Samantha"
RATE=175  # Optimal for natural, professional speech

log_header "🎤 Professional Voice Generation"
log_info "Voice: $VOICE (Apple Neural TTS)"
log_info "Rate: $RATE WPM (optimized for clarity and naturalness)"

# Generate audio with optimal settings
generate_audio() {
    local script_file=$1
    local output_file=$2
    local name=$3
    
    log_info "Generating: $name"
    
    # Use Samantha at optimal rate for natural speech
    say -v "$VOICE" -r "$RATE" -o "$output_file" -f "$script_file"
    
    if [ -f "$output_file" ]; then
        local duration=$(afinfo "$output_file" 2>/dev/null | grep "estimated duration" | awk '{print $3}' | cut -d. -f1 || echo "N/A")
        log_success "$name (${duration}s)"
        return 0
    else
        return 1
    fi
}

# Create professional video
create_video() {
    local audio_file=$1
    local title=$2
    local subtitle=$3
    local platform=$4
    local output_file=$5
    
    log_info "Creating: $title - $platform"
    
    # Get audio duration
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null)
    
    # Platform-specific colors
    local color1="0x667eea"
    local color2="0x764ba2"
    
    case $platform in
        iOS)     color1="0x007AFF"; color2="0x5856D6" ;;
        watchOS) color1="0xFF3B30"; color2="0xFF9500" ;;
        macOS)   color1="0x5856D6"; color2="0x00C7BE" ;;
    esac
    
    # Create professional video with smooth animations
    ffmpeg -f lavfi -i "color=c=${color1}:s=1920x1080:d=${duration}" \
        -f lavfi -i "color=c=${color2}:s=1920x1080:d=${duration}" \
        -i "$audio_file" \
        -filter_complex "\
            [0:v][1:v]blend=all_mode=overlay:all_opacity=0.5[bg]; \
            [bg]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='$title':\
                fontcolor=white:\
                fontsize=72:\
                x=(w-text_w)/2:\
                y=(h-text_h)/2-100:\
                shadowcolor=black@0.8:\
                shadowx=3:\
                shadowy=3:\
                alpha='if(lt(t,1),t,if(lt(t,${duration%.*}-2),1,(${duration%.*}-t)/2))'[t1]; \
            [t1]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='$subtitle':\
                fontcolor=white:\
                fontsize=40:\
                x=(w-text_w)/2:\
                y=(h-text_h)/2:\
                alpha='if(lt(t,1.5),(t-0.5)*2,if(lt(t,${duration%.*}-2),1,(${duration%.*}-t)/2))'[t2]; \
            [t2]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='$platform Edition':\
                fontcolor=white@0.95:\
                fontsize=32:\
                x=(w-text_w)/2:\
                y=(h-text_h)/2+70:\
                box=1:\
                boxcolor=black@0.4:\
                boxborderw=15:\
                alpha='if(lt(t,2),(t-1),if(lt(t,${duration%.*}-2),1,(${duration%.*}-t)/2))'[t3]; \
            [t3]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='foundation-of-truth.com':\
                fontcolor=white@0.6:\
                fontsize=24:\
                x=(w-text_w)/2:\
                y=h-80:\
                alpha='if(lt(t,3),(t-2),if(lt(t,${duration%.*}-2),1,(${duration%.*}-t)/2))'[final]" \
        -map "[final]" -map 2:a \
        -c:v libx264 -preset slow -crf 17 -profile:v high \
        -c:a aac -b:a 192k -ar 44100 \
        -pix_fmt yuv420p \
        -movflags +faststart \
        -t "$duration" \
        -y "$output_file" 2>&1 | grep -E "(frame=|time=)" | tail -2 || true
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Complete: $(basename $output_file) ($size)"
        return 0
    else
        return 1
    fi
}

# Generate all audio
log_header "Step 1/2: Audio Generation"

generate_audio "$SCRIPT_DIR/marketing_clinician_ios.txt" \
    "$OUTPUT_DIR/audio_professional/Clinician_iOS.aiff" "Clinician iOS"

generate_audio "$SCRIPT_DIR/marketing_legalus_ios.txt" \
    "$OUTPUT_DIR/audio_professional/LegalUS_iOS.aiff" "Legal US iOS"

generate_audio "$SCRIPT_DIR/marketing_education_ios.txt" \
    "$OUTPUT_DIR/audio_professional/EducationK18_iOS.aiff" "Education K-18 iOS"

generate_audio "$SCRIPT_DIR/marketing_clinician_watchos.txt" \
    "$OUTPUT_DIR/audio_professional/Clinician_watchOS.aiff" "Clinician watchOS"

generate_audio "$SCRIPT_DIR/marketing_legalus_watchos.txt" \
    "$OUTPUT_DIR/audio_professional/LegalUS_watchOS.aiff" "Legal US watchOS"

generate_audio "$SCRIPT_DIR/marketing_education_watchos.txt" \
    "$OUTPUT_DIR/audio_professional/EducationK18_watchOS.aiff" "Education watchOS"

generate_audio "$SCRIPT_DIR/marketing_clinician_macos.txt" \
    "$OUTPUT_DIR/audio_professional/Clinician_macOS.aiff" "Clinician macOS"

generate_audio "$SCRIPT_DIR/marketing_legalus_macos.txt" \
    "$OUTPUT_DIR/audio_professional/LegalUS_macOS.aiff" "Legal US macOS"

generate_audio "$SCRIPT_DIR/marketing_education_macos.txt" \
    "$OUTPUT_DIR/audio_professional/EducationK18_macOS.aiff" "Education macOS"

# Create all videos
log_header "Step 2/2: Professional Video Creation"

# iOS
create_video "$OUTPUT_DIR/audio_professional/Clinician_iOS.aiff" \
    "FoT Clinician" "Clinical Decision Support That Proves Its Work" "iOS" \
    "$OUTPUT_DIR/final_professional/Clinician_iOS.mp4"

create_video "$OUTPUT_DIR/audio_professional/LegalUS_iOS.aiff" \
    "FoT Legal US" "Legal Practice Management With Proof" "iOS" \
    "$OUTPUT_DIR/final_professional/LegalUS_iOS.mp4"

create_video "$OUTPUT_DIR/audio_professional/EducationK18_iOS.aiff" \
    "FoT Education K-18" "Virtue-Guided Learning For Every Student" "iOS" \
    "$OUTPUT_DIR/final_professional/EducationK18_iOS.mp4"

# watchOS
create_video "$OUTPUT_DIR/audio_professional/Clinician_watchOS.aiff" \
    "FoT Clinician" "Critical Clinical Data On Your Wrist" "watchOS" \
    "$OUTPUT_DIR/final_professional/Clinician_watchOS.mp4"

create_video "$OUTPUT_DIR/audio_professional/LegalUS_watchOS.aiff" \
    "FoT Legal US" "Legal Alerts At Your Fingertips" "watchOS" \
    "$OUTPUT_DIR/final_professional/LegalUS_watchOS.mp4"

create_video "$OUTPUT_DIR/audio_professional/EducationK18_watchOS.aiff" \
    "FoT Education" "Learning Companion For Young Minds" "watchOS" \
    "$OUTPUT_DIR/final_professional/EducationK18_watchOS.mp4"

# macOS
create_video "$OUTPUT_DIR/audio_professional/Clinician_macOS.aiff" \
    "FoT Clinician" "Comprehensive Clinical Workspace" "macOS" \
    "$OUTPUT_DIR/final_professional/Clinician_macOS.mp4"

create_video "$OUTPUT_DIR/audio_professional/LegalUS_macOS.aiff" \
    "FoT Legal US" "Complete Legal Practice Suite" "macOS" \
    "$OUTPUT_DIR/final_professional/LegalUS_macOS.mp4"

create_video "$OUTPUT_DIR/audio_professional/EducationK18_macOS.aiff" \
    "FoT Education" "Complete Adaptive Learning Environment" "macOS" \
    "$OUTPUT_DIR/final_professional/EducationK18_macOS.mp4"

log_header "✅ Professional Videos Complete!"
log_success "Location: $OUTPUT_DIR/final_professional/"
echo ""
log_info "📊 Final Videos:"
ls -lh "$OUTPUT_DIR/final_professional"/*.mp4 2>/dev/null | awk '{print "   " $9 " - " $5}' || true

echo ""
log_info "🎬 Videos use:"
log_info "   • Voice: Samantha (Apple Neural TTS)"
log_info "   • Rate: 175 WPM (professional clarity)"
log_info "   • Quality: 1080p, H.264, AAC 192kbps"
log_info "   • Platform-specific branding colors"
log_info "   • Smooth fade in/out animations"
echo ""
log_info "🚀 Ready for:"
log_info "   • Investor presentations"
log_info "   • Customer demos"
log_info "   • Website embedding"
log_info "   • YouTube/Vimeo upload"

