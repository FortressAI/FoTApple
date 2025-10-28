#!/usr/bin/env bash
# Generate all marketing video narrations
# This creates the audio tracks for all 9 marketing videos

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos/audio"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Generating Marketing Video Narrations${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to generate audio
generate_audio() {
    local script_file=$1
    local output_file=$2
    local voice=$3
    
    echo -e "${BLUE}Generating:${NC} $(basename $output_file) (voice: $voice)"
    
    if [ ! -f "$script_file" ]; then
        echo "  ✗ Script file not found: $script_file"
        return 1
    fi
    
    # Generate with say command (AIFF format for quality)
    say -v "$voice" -f "$script_file" -o "$output_file"
    
    if [ -f "$output_file" ]; then
        # Get duration
        local duration=$(afinfo "$output_file" 2>/dev/null | grep "estimated duration" | awk '{print $3}')
        echo -e "  ${GREEN}✓${NC} Created: $(basename $output_file) (${duration}s)"
        return 0
    else
        echo "  ✗ Failed to generate audio"
        return 1
    fi
}

echo "📱 iOS Apps (Samantha voice)"
echo "─────────────────────────────"
generate_audio "$SCRIPT_DIR/marketing_clinician_ios.txt" "$OUTPUT_DIR/Clinician_iOS.aiff" "Samantha"
generate_audio "$SCRIPT_DIR/marketing_legalus_ios.txt" "$OUTPUT_DIR/LegalUS_iOS.aiff" "Samantha"
generate_audio "$SCRIPT_DIR/marketing_education_ios.txt" "$OUTPUT_DIR/EducationK18_iOS.aiff" "Samantha"

echo ""
echo "⌚ watchOS Apps (Alex voice)"
echo "─────────────────────────────"
generate_audio "$SCRIPT_DIR/marketing_clinician_watchos.txt" "$OUTPUT_DIR/Clinician_watchOS.aiff" "Alex"
generate_audio "$SCRIPT_DIR/marketing_legalus_watchos.txt" "$OUTPUT_DIR/LegalUS_watchOS.aiff" "Alex"
generate_audio "$SCRIPT_DIR/marketing_education_watchos.txt" "$OUTPUT_DIR/EducationK18_watchOS.aiff" "Alex"

echo ""
echo "💻 macOS Apps (Victoria voice)"
echo "─────────────────────────────"
generate_audio "$SCRIPT_DIR/marketing_clinician_macos.txt" "$OUTPUT_DIR/Clinician_macOS.aiff" "Victoria"
generate_audio "$SCRIPT_DIR/marketing_legalus_macos.txt" "$OUTPUT_DIR/LegalUS_macOS.aiff" "Victoria"
generate_audio "$SCRIPT_DIR/marketing_education_macos.txt" "$OUTPUT_DIR/EducationK18_macOS.aiff" "Victoria"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  All Narrations Generated!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo "📂 Audio files created in:"
echo "   $OUTPUT_DIR"
echo ""
echo "📊 Summary:"
ls -lh "$OUTPUT_DIR"/*.aiff 2>/dev/null | awk '{print "   " $9 " - " $5}'

echo ""
echo "🎬 Next Steps:"
echo "   1. Listen to audio files to verify quality"
echo "   2. Record screen videos for each app"
echo "   3. Combine video + audio with ffmpeg"
echo ""
echo "💡 To listen to a narration:"
echo "   afplay $OUTPUT_DIR/Clinician_iOS.aiff"

