#!/usr/bin/env bash
# Master Marketing Video Recording Script
# Records all 9 FoT apps across iOS, watchOS, and macOS

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Source voice configuration
source "$SCRIPT_DIR/voice_config.sh"

log_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

log_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

log_error() {
    echo -e "${RED}✗${NC}  $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

# Check dependencies
check_dependencies() {
    log_header "Checking Dependencies"
    
    local all_good=true
    
    if ! command -v ffmpeg &> /dev/null; then
        log_error "ffmpeg not found. Install with: brew install ffmpeg"
        all_good=false
    else
        log_success "ffmpeg installed"
    fi
    
    if ! command -v python3 &> /dev/null; then
        log_error "python3 not found"
        all_good=false
    else
        log_success "python3 installed"
    fi
    
    if ! command -v xcrun &> /dev/null; then
        log_error "xcrun not found (Xcode required)"
        all_good=false
    else
        log_success "Xcode tools installed"
    fi
    
    if [ "$all_good" = false ]; then
        exit 1
    fi
}

# Setup output directory
setup_output_dir() {
    log_header "Setting Up Output Directory"
    
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/raw"
    mkdir -p "$OUTPUT_DIR/audio"
    mkdir -p "$OUTPUT_DIR/subtitles"
    mkdir -p "$OUTPUT_DIR/final"
    
    log_success "Output directory: $OUTPUT_DIR"
}

# Generate audio narration from script
generate_narration() {
    local script_file=$1
    local output_audio=$2
    local voice=${3:-"Samantha"}
    
    log_info "Generating narration: $(basename $output_audio)"
    
    if [ ! -f "$script_file" ]; then
        log_error "Script file not found: $script_file"
        return 1
    fi
    
    # Generate audio with say command
    say -v "$voice" -f "$script_file" -o "$output_audio" --data-format=LEF32@44100
    
    if [ -f "$output_audio" ]; then
        log_success "Audio generated: $(basename $output_audio)"
        return 0
    else
        log_error "Failed to generate audio"
        return 1
    fi
}

# Record iOS app
record_ios_app() {
    local app_name=$1
    local app_scheme=$2
    local narration_script=$3
    local output_name=$4
    local duration=${5:-300} # Default 5 minutes
    
    log_header "Recording iOS: $app_name"
    
    local sim_device="iPhone 15 Pro"
    local sim_id=$(xcrun simctl list devices available | grep "$sim_device" | head -1 | grep -oE '\(([A-F0-9-]+)\)' | tr -d '()')
    
    if [ -z "$sim_id" ]; then
        log_error "Simulator not found: $sim_device"
        return 1
    fi
    
    log_info "Using simulator: $sim_device ($sim_id)"
    
    # Boot simulator if needed
    local sim_state=$(xcrun simctl list devices | grep "$sim_id" | grep -oE '\((Booted|Shutdown)\)' | tr -d '()')
    if [ "$sim_state" != "Booted" ]; then
        log_info "Booting simulator..."
        xcrun simctl boot "$sim_id"
        sleep 5
    fi
    
    # Build and install app
    log_info "Building app..."
    cd "$PROJECT_ROOT/apps/${app_name}App/iOS"
    
    xcodebuild -scheme "$app_scheme" \
        -destination "platform=iOS Simulator,id=$sim_id" \
        -derivedDataPath build \
        build >/dev/null 2>&1
    
    # Find the app bundle
    local app_bundle=$(find build/Build/Products -name "*.app" -type d | head -1)
    
    if [ -z "$app_bundle" ]; then
        log_error "App bundle not found after build"
        return 1
    fi
    
    log_info "Installing app..."
    xcrun simctl install "$sim_id" "$app_bundle"
    
    # Get bundle ID
    local bundle_id=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$app_bundle/Info.plist")
    log_info "Bundle ID: $bundle_id"
    
    # Start recording
    local raw_video="$OUTPUT_DIR/raw/${output_name}_raw.mov"
    log_info "Starting screen recording..."
    xcrun simctl io "$sim_id" recordVideo --codec=h264 --force "$raw_video" &
    local record_pid=$!
    
    sleep 2
    
    # Launch app
    log_info "Launching app..."
    xcrun simctl launch "$sim_id" "$bundle_id"
    
    # Wait for duration
    log_info "Recording for $duration seconds..."
    sleep "$duration"
    
    # Stop recording
    log_info "Stopping recording..."
    kill -SIGINT "$record_pid" 2>/dev/null || true
    wait "$record_pid" 2>/dev/null || true
    
    # Generate narration audio
    local audio_file="$OUTPUT_DIR/audio/${output_name}.aiff"
    generate_narration "$narration_script" "$audio_file" "Samantha"
    
    # Combine video and audio
    local final_video="$OUTPUT_DIR/final/${output_name}.mp4"
    log_info "Combining video and audio..."
    
    ffmpeg -i "$raw_video" -i "$audio_file" \
        -c:v libx264 -preset slow -crf 18 \
        -c:a aac -b:a 192k \
        -pix_fmt yuv420p \
        -movflags +faststart \
        "$final_video" -y >/dev/null 2>&1
    
    if [ -f "$final_video" ]; then
        log_success "Video complete: $final_video"
        
        # Get duration
        local video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$final_video" | cut -d. -f1)
        log_info "Duration: ${video_duration}s"
        
        return 0
    else
        log_error "Failed to create final video"
        return 1
    fi
}

# Record macOS app
record_macos_app() {
    local app_name=$1
    local narration_script=$2
    local output_name=$3
    local duration=${4:-300}
    
    log_header "Recording macOS: $app_name"
    
    # Build app
    log_info "Building app..."
    cd "$PROJECT_ROOT/apps/${app_name}App/macOS"
    
    swift build --configuration release >/dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        log_error "Build failed"
        return 1
    fi
    
    log_success "Build complete"
    
    # Find executable
    local app_exec=$(find .build/release -type f -perm +111 | grep -v ".build" | head -1)
    
    if [ -z "$app_exec" ]; then
        log_error "Executable not found"
        return 1
    fi
    
    log_info "Found executable: $app_exec"
    
    # Start recording with QuickTime/screencapture
    local raw_video="$OUTPUT_DIR/raw/${output_name}_raw.mov"
    log_info "Starting screen recording..."
    
    # Use screencapture for recording
    screencapture -v -T 0 "$raw_video" &
    local record_pid=$!
    
    sleep 2
    
    # Launch app
    log_info "Launching app..."
    "$app_exec" &
    local app_pid=$!
    
    # Wait for duration
    log_info "Recording for $duration seconds..."
    sleep "$duration"
    
    # Stop app
    kill -SIGTERM "$app_pid" 2>/dev/null || true
    
    # Stop recording
    log_info "Stopping recording..."
    kill -SIGINT "$record_pid" 2>/dev/null || true
    wait "$record_pid" 2>/dev/null || true
    
    # Generate narration audio
    local audio_file="$OUTPUT_DIR/audio/${output_name}.aiff"
    generate_narration "$narration_script" "$audio_file" "Samantha"
    
    # Combine video and audio
    local final_video="$OUTPUT_DIR/final/${output_name}.mp4"
    log_info "Combining video and audio..."
    
    ffmpeg -i "$raw_video" -i "$audio_file" \
        -c:v libx264 -preset slow -crf 18 \
        -c:a aac -b:a 192k \
        -pix_fmt yuv420p \
        -movflags +faststart \
        "$final_video" -y >/dev/null 2>&1
    
    if [ -f "$final_video" ]; then
        log_success "Video complete: $final_video"
        return 0
    else
        log_error "Failed to create final video"
        return 1
    fi
}

# Generate video index page
generate_index() {
    log_header "Generating Video Index"
    
    local index_file="$OUTPUT_DIR/index.html"
    
    cat > "$index_file" << 'EOF'
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
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-top: 20px;
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
            margin-bottom: 15px;
        }
        .video-card video {
            width: 100%;
            border-radius: 10px;
            margin-bottom: 15px;
        }
        .video-info {
            display: flex;
            justify-content: space-between;
            font-size: 0.9rem;
            opacity: 0.8;
        }
        .platform-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.85rem;
            font-weight: bold;
        }
        .ios { background: #007AFF; }
        .watchos { background: #FF3B30; }
        .macos { background: #5856D6; }
        .download-btn {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            padding: 10px 20px;
            border-radius: 8px;
            text-decoration: none;
            color: #fff;
            font-weight: bold;
            transition: background 0.3s;
            margin-top: 10px;
        }
        .download-btn:hover {
            background: rgba(255,255,255,0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎬 Field of Truth Marketing Videos</h1>
        <p class="subtitle">Professional demo videos for all FoT commercial applications</p>
        
        <div class="domain-section">
            <h2>🏥 Clinician - Clinical Decision Support</h2>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iOS</h3>
                    <span class="platform-badge ios">iPhone & iPad</span>
                    <video controls>
                        <source src="final/Clinician_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>5:00</span>
                        <a href="final/Clinician_iOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>watchOS</h3>
                    <span class="platform-badge watchos">Apple Watch</span>
                    <video controls>
                        <source src="final/Clinician_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>3:00</span>
                        <a href="final/Clinician_watchOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>macOS</h3>
                    <span class="platform-badge macos">Mac</span>
                    <video controls>
                        <source src="final/Clinician_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>5:00</span>
                        <a href="final/Clinician_macOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="domain-section">
            <h2>⚖️ Legal US - Legal Practice Management</h2>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iOS</h3>
                    <span class="platform-badge ios">iPhone & iPad</span>
                    <video controls>
                        <source src="final/LegalUS_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>5:00</span>
                        <a href="final/LegalUS_iOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>watchOS</h3>
                    <span class="platform-badge watchos">Apple Watch</span>
                    <video controls>
                        <source src="final/LegalUS_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>3:00</span>
                        <a href="final/LegalUS_watchOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>macOS</h3>
                    <span class="platform-badge macos">Mac</span>
                    <video controls>
                        <source src="final/LegalUS_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>5:00</span>
                        <a href="final/LegalUS_macOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="domain-section">
            <h2>🎓 Education K-18 - Adaptive Learning</h2>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iOS</h3>
                    <span class="platform-badge ios">iPhone & iPad</span>
                    <video controls>
                        <source src="final/EducationK18_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>5:00</span>
                        <a href="final/EducationK18_iOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>watchOS</h3>
                    <span class="platform-badge watchos">Apple Watch</span>
                    <video controls>
                        <source src="final/EducationK18_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>3:00</span>
                        <a href="final/EducationK18_watchOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>macOS</h3>
                    <span class="platform-badge macos">Mac</span>
                    <video controls>
                        <source src="final/EducationK18_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span>5:00</span>
                        <a href="final/EducationK18_macOS.mp4" download class="download-btn">Download</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF
    
    log_success "Index page created: $index_file"
}

# Main execution
main() {
    log_header "FoT Marketing Video Production"
    log_info "Creating professional videos for all 9 apps"
    
    check_dependencies
    setup_output_dir
    
    # Record all iOS apps
    log_header "iOS Apps (3 videos)"
    record_ios_app "Clinician" "FoTClinician" "$SCRIPT_DIR/marketing_clinician_ios.txt" "Clinician_iOS" 300
    record_ios_app "LegalUS" "FoTLegalUS" "$SCRIPT_DIR/marketing_legalus_ios.txt" "LegalUS_iOS" 300
    record_ios_app "EducationK18" "FoTEducation" "$SCRIPT_DIR/marketing_education_ios.txt" "EducationK18_iOS" 300
    
    # Record all macOS apps
    log_header "macOS Apps (3 videos)"
    record_macos_app "Clinician" "$SCRIPT_DIR/marketing_clinician_macos.txt" "Clinician_macOS" 300
    record_macos_app "LegalUS" "$SCRIPT_DIR/marketing_legalus_macos.txt" "LegalUS_macOS" 300
    record_macos_app "EducationK18" "$SCRIPT_DIR/marketing_education_macos.txt" "EducationK18_macOS" 300
    
    # Generate index page
    generate_index
    
    log_header "Production Complete!"
    log_success "All videos created in: $OUTPUT_DIR/final"
    log_info "View gallery: open $OUTPUT_DIR/index.html"
    
    # Summary
    echo ""
    log_info "Video Summary:"
    ls -lh "$OUTPUT_DIR/final"/*.mp4 2>/dev/null || log_warning "No videos found"
}

# Run main
main "$@"

