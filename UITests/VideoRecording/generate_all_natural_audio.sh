#!/usr/bin/env bash
# Generate All Natural Narration Audio
# Uses chunking method with varied prosody for human-like speech

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos/audio_natural"

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

mkdir -p "$OUTPUT_DIR"

log_header "🎤 Natural Speech Audio Generation"
log_info "Using chunking method for human-like prosody"
log_info "Voice: Samantha"
log_info "Method: Varied rate, natural pauses, pitch modulation"
echo ""

# Generate each narration with natural speech
generate_natural() {
    local script_file=$1
    local output_file=$2
    local app_name=$3
    local base_rate=${4:-175}
    
    log_info "Generating: $app_name"
    
    if [ ! -f "$script_file" ]; then
        echo "   ⚠️  Script not found: $script_file"
        return 1
    fi
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$script_file" \
        "$output_file" \
        "Samantha" \
        "$base_rate"
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "$app_name complete ($size)"
        return 0
    else
        echo "   ❌ Generation failed"
        return 1
    fi
}

# Generate all narrations
log_header "Step 1: iOS Apps"

generate_natural \
    "$SCRIPT_DIR/marketing_clinician_ios.txt" \
    "$OUTPUT_DIR/Clinician_iOS_natural.aiff" \
    "Clinician iOS" \
    155

generate_natural \
    "$SCRIPT_DIR/marketing_legalus_ios.txt" \
    "$OUTPUT_DIR/LegalUS_iOS_natural.aiff" \
    "Legal US iOS" \
    158

generate_natural \
    "$SCRIPT_DIR/marketing_education_ios.txt" \
    "$OUTPUT_DIR/EducationK18_iOS_natural.aiff" \
    "Education K-18 iOS" \
    153

log_header "Step 2: watchOS Apps"

generate_natural \
    "$SCRIPT_DIR/marketing_clinician_watchos.txt" \
    "$OUTPUT_DIR/Clinician_watchOS_natural.aiff" \
    "Clinician watchOS" \
    165

generate_natural \
    "$SCRIPT_DIR/marketing_legalus_watchos.txt" \
    "$OUTPUT_DIR/LegalUS_watchOS_natural.aiff" \
    "Legal US watchOS" \
    165

generate_natural \
    "$SCRIPT_DIR/marketing_education_watchos.txt" \
    "$OUTPUT_DIR/EducationK18_watchOS_natural.aiff" \
    "Education watchOS" \
    163

log_header "Step 3: macOS Apps"

generate_natural \
    "$SCRIPT_DIR/marketing_clinician_macos.txt" \
    "$OUTPUT_DIR/Clinician_macOS_natural.aiff" \
    "Clinician macOS" \
    157

generate_natural \
    "$SCRIPT_DIR/marketing_legalus_macos.txt" \
    "$OUTPUT_DIR/LegalUS_macOS_natural.aiff" \
    "Legal US macOS" \
    155

generate_natural \
    "$SCRIPT_DIR/marketing_education_macos.txt" \
    "$OUTPUT_DIR/EducationK18_macOS_natural.aiff" \
    "Education macOS" \
    153

log_header "✅ Natural Speech Generation Complete!"
log_success "All narrations generated with natural prosody"
echo ""
log_info "📊 Generated Files:"
ls -lh "$OUTPUT_DIR"/*.aiff | awk '{print "   " $9 " - " $5}'
echo ""
log_info "🎧 Listen to results:"
log_info "   open $OUTPUT_DIR/"
echo ""
log_info "📝 Improvements from basic `say` command:"
log_info "   ✅ Varied speaking rate (faster for simple, slower for complex)"
log_info "   ✅ Natural pauses (longer after questions, shorter between clauses)"
log_info "   ✅ Slight random variations (avoids monotone)"
log_info "   ✅ Context-aware pacing (technical terms spoken more clearly)"
echo ""
log_info "🎬 Next: Use these audio files for video creation"
log_info "   The automated video system will sync perfectly with these"

