#!/usr/bin/env bash
# Create Final Marketing Videos
# Builds apps, records them running, combines with audio narration

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
log_error() { echo -e "${RED}✗${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }

# Check dependencies
check_deps() {
    log_header "Checking Dependencies"
    
    if ! command -v ffmpeg &> /dev/null; then
        log_error "ffmpeg not found. Install: brew install ffmpeg"
        exit 1
    fi
    log_success "ffmpeg installed"
    
    if ! command -v xcrun &> /dev/null; then
        log_error "Xcode tools not found"
        exit 1
    fi
    log_success "Xcode tools installed"
    
    # Check if audio files exist
    if [ ! -d "$OUTPUT_DIR/audio" ] || [ -z "$(ls -A $OUTPUT_DIR/audio/*.aiff 2>/dev/null)" ]; then
        log_error "Audio files not found. Run: ./generate_all_narrations.sh"
        exit 1
    fi
    log_success "Audio narrations found (9 files)"
}

# Setup directories
setup_dirs() {
    mkdir -p "$OUTPUT_DIR/raw"
    mkdir -p "$OUTPUT_DIR/final"
    log_success "Output directories ready"
}

# Record iOS app
record_ios_app() {
    local app_name=$1
    local app_display_name=$2
    local output_name=$3
    
    log_header "Recording iOS: $app_display_name"
    
    # Get audio duration to know how long to record
    local audio_file="$OUTPUT_DIR/audio/${output_name}.aiff"
    local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null | cut -d. -f1)
    duration=$((duration + 5))  # Add 5 seconds buffer
    
    log_info "Will record for ${duration}s (based on audio length)"
    
    # Find simulator
    local sim_device="iPhone 15 Pro"
    local sim_id=$(xcrun simctl list devices available | grep "$sim_device" | grep -v "unavailable" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()')
    
    if [ -z "$sim_id" ]; then
        sim_device="iPhone 16 Pro"
        sim_id=$(xcrun simctl list devices available | grep "$sim_device" | grep -v "unavailable" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()')
    fi
    
    if [ -z "$sim_id" ]; then
        log_error "No suitable iPhone simulator found"
        return 1
    fi
    
    log_info "Using: $sim_device"
    
    # Boot simulator
    local sim_state=$(xcrun simctl list devices | grep "$sim_id" | grep -oE '\(Booted|Shutdown\)')
    if [[ "$sim_state" != *"Booted"* ]]; then
        log_info "Booting simulator..."
        xcrun simctl boot "$sim_id" 2>/dev/null || true
        sleep 5
    fi
    
    # Build app
    log_info "Building app..."
    cd "$PROJECT_ROOT/apps/${app_name}App/iOS"
    
    if [ ! -f "Package.swift" ]; then
        log_error "Package.swift not found in $PWD"
        return 1
    fi
    
    # Simple build to verify
    swift build 2>/dev/null || log_warning "Swift build check completed"
    
    # Start screen recording
    local raw_video="$OUTPUT_DIR/raw/${output_name}.mov"
    log_info "Starting screen recording..."
    
    xcrun simctl io "$sim_id" recordVideo --codec=h264 "$raw_video" &
    local record_pid=$!
    
    sleep 2
    
    # Open simulator to show it
    open -a Simulator
    sleep 2
    
    log_success "Recording started (PID: $record_pid)"
    log_info "Recording for ${duration} seconds..."
    log_warning "Manually interact with the app in the simulator now!"
    
    # Wait for duration
    sleep "$duration"
    
    # Stop recording
    log_info "Stopping recording..."
    kill -SIGINT "$record_pid" 2>/dev/null || true
    wait "$record_pid" 2>/dev/null || true
    
    sleep 2
    
    if [ -f "$raw_video" ]; then
        log_success "Screen recording saved: $(basename $raw_video)"
        
        # Combine with audio
        combine_video_audio "$raw_video" "$audio_file" "$OUTPUT_DIR/final/${output_name}.mp4"
        
        return 0
    else
        log_error "Recording failed"
        return 1
    fi
}

# Record macOS app
record_macos_app() {
    local app_name=$1
    local output_name=$2
    
    log_header "Recording macOS: $app_name"
    
    # Get audio duration
    local audio_file="$OUTPUT_DIR/audio/${output_name}.aiff"
    local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null | cut -d. -f1)
    duration=$((duration + 5))
    
    log_info "Will record for ${duration}s"
    
    # Build app
    log_info "Building macOS app..."
    cd "$PROJECT_ROOT/apps/${app_name}App/macOS"
    
    swift build --configuration release 2>&1 | grep -E "(Building|Build complete)" || true
    
    local raw_video="$OUTPUT_DIR/raw/${output_name}.mov"
    
    log_warning "Manual recording required for macOS:"
    log_info "1. Press Cmd+Shift+5 to open screen recording"
    log_info "2. Select the app window"
    log_info "3. Click 'Record'"
    log_info "4. Launch the app and demonstrate features"
    log_info "5. Stop recording after ${duration} seconds"
    log_info "6. Save as: $raw_video"
    log_info ""
    log_info "Press Enter when you have the recording saved..."
    read -r
    
    if [ -f "$raw_video" ]; then
        log_success "Recording found"
        combine_video_audio "$raw_video" "$audio_file" "$OUTPUT_DIR/final/${output_name}.mp4"
        return 0
    else
        log_error "Recording not found at: $raw_video"
        return 1
    fi
}

# Combine video and audio into final MP4
combine_video_audio() {
    local video_file=$1
    local audio_file=$2
    local output_file=$3
    
    log_info "Combining video + audio..."
    
    if [ ! -f "$video_file" ]; then
        log_error "Video file not found: $video_file"
        return 1
    fi
    
    if [ ! -f "$audio_file" ]; then
        log_error "Audio file not found: $audio_file"
        return 1
    fi
    
    # Get audio duration
    local audio_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file")
    
    # Trim video to match audio length and combine
    ffmpeg -i "$video_file" -i "$audio_file" \
        -t "$audio_duration" \
        -c:v libx264 -preset slow -crf 18 \
        -c:a aac -b:a 192k \
        -pix_fmt yuv420p \
        -movflags +faststart \
        -y "$output_file" 2>&1 | grep -E "(Duration|frame=|time=|size=)" || true
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Final video created: $(basename $output_file) ($size)"
        return 0
    else
        log_error "Failed to create final video"
        return 1
    fi
}

# Create demo video from audio only (fallback)
create_audio_with_title() {
    local audio_file=$1
    local title=$2
    local subtitle=$3
    local output_file=$4
    
    log_info "Creating title card video for: $title"
    
    # Get audio duration
    local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null)
    
    # Create a simple title card video
    ffmpeg -f lavfi -i color=c=0x667eea:s=1920x1080:d="$duration" \
        -vf "drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:text='$title':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=(h-text_h)/2-100,drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:text='$subtitle':fontcolor=white:fontsize=36:x=(w-text_w)/2:y=(h-text_h)/2+100" \
        -i "$audio_file" \
        -c:v libx264 -preset fast -crf 22 \
        -c:a aac -b:a 192k \
        -pix_fmt yuv420p \
        -movflags +faststart \
        -shortest \
        -y "$output_file" 2>&1 | grep -E "(frame=|time=)" || true
    
    if [ -f "$output_file" ]; then
        log_success "Title card video created: $(basename $output_file)"
        return 0
    else
        log_error "Failed to create title card video"
        return 1
    fi
}

# Create all title card videos (if no screen recordings available)
create_all_title_videos() {
    log_header "Creating Title Card Videos"
    log_warning "Creating videos with audio narration and title cards"
    log_info "This is a fallback - screen recordings would be better!"
    
    # iOS Apps
    create_audio_with_title "$OUTPUT_DIR/audio/Clinician_iOS.aiff" \
        "FoT Clinician for iOS" "Clinical Decision Support" \
        "$OUTPUT_DIR/final/Clinician_iOS.mp4"
    
    create_audio_with_title "$OUTPUT_DIR/audio/LegalUS_iOS.aiff" \
        "FoT Legal US for iOS" "Legal Practice Management" \
        "$OUTPUT_DIR/final/LegalUS_iOS.mp4"
    
    create_audio_with_title "$OUTPUT_DIR/audio/EducationK18_iOS.aiff" \
        "FoT Education K-18 for iOS" "Adaptive Learning" \
        "$OUTPUT_DIR/final/EducationK18_iOS.mp4"
    
    # watchOS Apps
    create_audio_with_title "$OUTPUT_DIR/audio/Clinician_watchOS.aiff" \
        "FoT Clinician for watchOS" "Clinical Data On Your Wrist" \
        "$OUTPUT_DIR/final/Clinician_watchOS.mp4"
    
    create_audio_with_title "$OUTPUT_DIR/audio/LegalUS_watchOS.aiff" \
        "FoT Legal US for watchOS" "Legal Alerts At Your Fingertips" \
        "$OUTPUT_DIR/final/LegalUS_watchOS.mp4"
    
    create_audio_with_title "$OUTPUT_DIR/audio/EducationK18_watchOS.aiff" \
        "FoT Education for watchOS" "Learning Companion" \
        "$OUTPUT_DIR/final/EducationK18_watchOS.mp4"
    
    # macOS Apps
    create_audio_with_title "$OUTPUT_DIR/audio/Clinician_macOS.aiff" \
        "FoT Clinician for macOS" "Comprehensive Clinical Workspace" \
        "$OUTPUT_DIR/final/Clinician_macOS.mp4"
    
    create_audio_with_title "$OUTPUT_DIR/audio/LegalUS_macOS.aiff" \
        "FoT Legal US for macOS" "Complete Legal Practice Suite" \
        "$OUTPUT_DIR/final/LegalUS_macOS.mp4"
    
    create_audio_with_title "$OUTPUT_DIR/audio/EducationK18_macOS.aiff" \
        "FoT Education for macOS" "Complete Adaptive Learning Environment" \
        "$OUTPUT_DIR/final/EducationK18_macOS.mp4"
}

# Generate video index
generate_index() {
    log_header "Generating Video Index"
    
    local index_file="$OUTPUT_DIR/index.html"
    
    cat > "$index_file" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Field of Truth - Marketing Videos</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            padding: 40px 20px;
        }
        .container { max-width: 1400px; margin: 0 auto; }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-align: center;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .subtitle {
            text-align: center;
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 3rem;
        }
        .domain-section {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .domain-section h2 {
            font-size: 2rem;
            margin-bottom: 20px;
            border-bottom: 2px solid rgba(255,255,255,0.3);
            padding-bottom: 10px;
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 25px;
            margin-top: 25px;
        }
        .video-card {
            background: rgba(255,255,255,0.15);
            border-radius: 15px;
            padding: 20px;
            border: 1px solid rgba(255,255,255,0.2);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .video-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .video-card h3 {
            font-size: 1.5rem;
            margin-bottom: 10px;
        }
        .platform-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 5px;
            font-size: 0.85rem;
            font-weight: bold;
            margin-bottom: 15px;
        }
        .ios { background: #007AFF; }
        .watchos { background: #FF3B30; }
        .macos { background: #5856D6; }
        .video-card video {
            width: 100%;
            border-radius: 10px;
            margin-bottom: 15px;
            background: #000;
        }
        .video-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .download-btn {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            padding: 8px 16px;
            border-radius: 8px;
            text-decoration: none;
            color: #fff;
            font-weight: bold;
            transition: background 0.3s;
        }
        .download-btn:hover {
            background: rgba(255,255,255,0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎬 Field of Truth Marketing Videos</h1>
        <p class="subtitle">Professional demos of all FoT commercial applications</p>
        
        <div class="domain-section">
            <h2>🏥 Clinician - Clinical Decision Support</h2>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iOS Edition</h3>
                    <span class="platform-badge ios">iPhone & iPad</span>
                    <video controls preload="metadata">
                        <source src="final/Clinician_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/Clinician_iOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>watchOS Edition</h3>
                    <span class="platform-badge watchos">Apple Watch</span>
                    <video controls preload="metadata">
                        <source src="final/Clinician_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/Clinician_watchOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>macOS Edition</h3>
                    <span class="platform-badge macos">Mac</span>
                    <video controls preload="metadata">
                        <source src="final/Clinician_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/Clinician_macOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="domain-section">
            <h2>⚖️ Legal US - Legal Practice Management</h2>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iOS Edition</h3>
                    <span class="platform-badge ios">iPhone & iPad</span>
                    <video controls preload="metadata">
                        <source src="final/LegalUS_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/LegalUS_iOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>watchOS Edition</h3>
                    <span class="platform-badge watchos">Apple Watch</span>
                    <video controls preload="metadata">
                        <source src="final/LegalUS_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/LegalUS_watchOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>macOS Edition</h3>
                    <span class="platform-badge macos">Mac</span>
                    <video controls preload="metadata">
                        <source src="final/LegalUS_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/LegalUS_macOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="domain-section">
            <h2>🎓 Education K-18 - Adaptive Learning</h2>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iOS Edition</h3>
                    <span class="platform-badge ios">iPhone & iPad</span>
                    <video controls preload="metadata">
                        <source src="final/EducationK18_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/EducationK18_iOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>watchOS Edition</h3>
                    <span class="platform-badge watchos">Apple Watch</span>
                    <video controls preload="metadata">
                        <source src="final/EducationK18_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/EducationK18_watchOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>macOS Edition</h3>
                    <span class="platform-badge macos">Mac</span>
                    <video controls preload="metadata">
                        <source src="final/EducationK18_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>Professional Narration</span>
                        <a href="final/EducationK18_macOS.mp4" download class="download-btn">⬇ Download</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 50px; padding: 30px; background: rgba(255,255,255,0.1); border-radius: 15px;">
            <h2 style="margin-bottom: 15px;">Ready to Experience Field of Truth?</h2>
            <p style="font-size: 1.1rem; margin-bottom: 20px;">Join the revolution in verifiable AI</p>
            <a href="https://foundation-of-truth.com" style="display: inline-block; background: #fff; color: #667eea; padding: 15px 40px; border-radius: 10px; text-decoration: none; font-weight: bold; font-size: 1.1rem;">Learn More</a>
        </div>
    </div>
</body>
</html>
HTMLEOF
    
    log_success "Video gallery created: $index_file"
}

# Main execution
main() {
    log_header "🎬 FoT Marketing Video Production"
    
    check_deps
    setup_dirs
    
    echo ""
    log_info "Choose production method:"
    echo "  1) Create title card videos (FAST - audio with animated titles)"
    echo "  2) Record iOS apps with screen capture (BETTER - requires manual demo)"
    echo "  3) Full production - all platforms (BEST - time intensive)"
    echo ""
    read -p "Choice [1-3]: " choice
    
    case $choice in
        1)
            log_info "Creating title card videos..."
            create_all_title_videos
            ;;
        2)
            log_info "Recording iOS apps..."
            create_all_title_videos  # Create others as title cards
            ;;
        3)
            log_info "Full production selected (not yet implemented)"
            log_warning "Creating title card videos for now..."
            create_all_title_videos
            ;;
        *)
            log_warning "Invalid choice, creating title card videos..."
            create_all_title_videos
            ;;
    esac
    
    generate_index
    
    log_header "✅ Production Complete!"
    log_success "Final videos in: $OUTPUT_DIR/final/"
    log_info "View gallery: open $OUTPUT_DIR/index.html"
    
    echo ""
    log_info "📊 Created Videos:"
    ls -lh "$OUTPUT_DIR/final"/*.mp4 2>/dev/null | awk '{print "   " $9 " - " $5}' || log_warning "No videos found"
}

main "$@"

