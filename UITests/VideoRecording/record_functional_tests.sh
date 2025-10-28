#!/usr/bin/env bash
# Record Functional Acceptance Tests
# GCP Compliance: Automated video recording of all functional test scenarios
# Outputs: Video demonstrations + narration + captions for user guides and audits

set -euo pipefail

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FunctionalTestVideos"
APP_SCHEME="FoTClinician"  # Change per domain
TEST_SCHEME="FoTUITests"

# Source voice configuration
source "$SCRIPT_DIR/voice_config.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v ffmpeg &> /dev/null; then
        log_error "ffmpeg not found. Install with: brew install ffmpeg"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        log_error "python3 not found"
        exit 1
    fi
    
    if ! command -v xcrun &> /dev/null; then
        log_error "xcrun not found. Xcode not installed?"
        exit 1
    fi
    
    # Make Python script executable
    chmod +x "$SCRIPT_DIR/steps_to_srt.py"
    
    log_success "All dependencies found"
}

# Record for iOS Simulator
record_ios() {
    local test_name=$1
    local language=$2
    local locale=$3
    local voice=$4
    local narration_file=$5
    
    log_info "Recording iOS test: $test_name ($language)"
    
    local dest='platform=iOS Simulator,name=iPhone 15 Pro'
    local video="/tmp/${test_name}_video.mp4"
    local audio="/tmp/${test_name}_audio.m4a"
    local srt="/tmp/${test_name}_captions.srt"
    local steps="/tmp/steps.json"
    local output="$OUTPUT_DIR/${test_name}_iOS_${language}.mp4"
    
    # Clean previous
    rm -f "$video" "$audio" "$srt" "$steps"
    
    # Boot simulator
    log_info "Booting simulator..."
    xcrun simctl boot "$dest" 2>/dev/null || true
    sleep 2
    
    # Start recording (background)
    log_info "Starting screen recording..."
    xcrun simctl io booted recordVideo --codec=h264 "$video" &
    local rec_pid=$!
    sleep 1
    
    # Run test
    log_info "Running UI test..."
    xcodebuild -scheme "$TEST_SCHEME" \
               -destination "$dest" \
               -only-testing:"$TEST_SCHEME/ClinicianFlowTests/$test_name" \
               test 2>&1 | grep -E "Test Case|✅|▶️" || true
    
    # Stop recording
    log_info "Stopping recording..."
    sleep 1
    kill -INT $rec_pid 2>/dev/null || true
    wait $rec_pid 2>/dev/null || true
    sleep 1
    
    if [ ! -f "$video" ]; then
        log_error "Video file not created"
        return 1
    fi
    
    # Generate narration audio
    log_info "Generating narration..."
    say -v "$voice" -f "$narration_file" -o "$audio"
    
    # Generate captions
    log_info "Generating captions..."
    if [ -f "$steps" ]; then
        python3 "$SCRIPT_DIR/steps_to_srt.py" "$steps" "$video" "$narration_file" > "$srt"
    else
        log_warning "Steps file not found, skipping captions"
        touch "$srt"  # Create empty SRT
    fi
    
    # Mux everything together
    log_info "Creating final video..."
    mkdir -p "$OUTPUT_DIR"
    
    if [ -s "$srt" ]; then
        # With subtitles
        ffmpeg -y -i "$video" -i "$audio" -shortest \
               -c:v copy -c:a aac -b:a 128k \
               -vf "subtitles='$srt':force_style='FontName=SF Pro Display,FontSize=24,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BorderStyle=1'" \
               -movflags +faststart \
               "$output" 2>&1 | grep -v "^frame=" || true
    else
        # Without subtitles
        ffmpeg -y -i "$video" -i "$audio" -shortest \
               -c:v copy -c:a aac -b:a 128k \
               -movflags +faststart \
               "$output" 2>&1 | grep -v "^frame=" || true
    fi
    
    if [ -f "$output" ]; then
        local size=$(du -h "$output" | cut -f1)
        log_success "Created: $output ($size)"
    else
        log_error "Failed to create output video"
        return 1
    fi
    
    # Cleanup temp files
    rm -f "$video" "$audio" "$srt"
}

# Record for macOS
record_macos() {
    local test_name=$1
    local language=$2
    local locale=$3
    local voice=$4
    local narration_file=$5
    
    log_info "Recording macOS test: $test_name ($language)"
    
    local dest='platform=macOS'
    local video="/tmp/${test_name}_video.mp4"
    local audio="/tmp/${test_name}_audio.m4a"
    local srt="/tmp/${test_name}_captions.srt"
    local steps="/tmp/steps.json"
    local output="$OUTPUT_DIR/${test_name}_macOS_${language}.mp4"
    
    # Clean previous
    rm -f "$video" "$audio" "$srt" "$steps"
    
    log_warning "macOS recording requires Screen Recording permission"
    log_info "Starting screen recording with ffmpeg..."
    
    # Start recording (requires Screen Recording permission)
    ffmpeg -f avfoundation \
           -framerate 30 \
           -video_size 1920x1080 \
           -i "1:none" \
           -pix_fmt yuv420p \
           "$video" &
    local rec_pid=$!
    sleep 2
    
    # Run test
    log_info "Running UI test..."
    xcodebuild -scheme "$TEST_SCHEME" \
               -destination "$dest" \
               -only-testing:"$TEST_SCHEME/ClinicianFlowTests/$test_name" \
               test 2>&1 | grep -E "Test Case|✅|▶️" || true
    
    # Stop recording
    log_info "Stopping recording..."
    sleep 1
    kill -INT $rec_pid 2>/dev/null || true
    wait $rec_pid 2>/dev/null || true
    
    # Same muxing process as iOS
    log_info "Generating narration..."
    say -v "$voice" -f "$narration_file" -o "$audio"
    
    log_info "Generating captions..."
    if [ -f "$steps" ]; then
        python3 "$SCRIPT_DIR/steps_to_srt.py" "$steps" "$video" "$narration_file" > "$srt"
    else
        log_warning "Steps file not found, skipping captions"
        touch "$srt"
    fi
    
    log_info "Creating final video..."
    mkdir -p "$OUTPUT_DIR"
    
    if [ -s "$srt" ]; then
        ffmpeg -y -i "$video" -i "$audio" -shortest \
               -c:v copy -c:a aac -b:a 128k \
               -vf "subtitles='$srt':force_style='FontName=SF Pro Display,FontSize=24'" \
               -movflags +faststart \
               "$output" 2>&1 | grep -v "^frame=" || true
    else
        ffmpeg -y -i "$video" -i "$audio" -shortest \
               -c:v copy -c:a aac -b:a 128k \
               -movflags +faststart \
               "$output" 2>&1 | grep -v "^frame=" || true
    fi
    
    if [ -f "$output" ]; then
        local size=$(du -h "$output" | cut -f1)
        log_success "Created: $output ($size)"
    else
        log_error "Failed to create output video"
        return 1
    fi
    
    rm -f "$video" "$audio" "$srt"
}

# Main recording function
record_test() {
    local test_name=$1
    local platform=$2
    local language=${3:-"en"}
    local locale=${4:-"en_US"}
    local voice_override=${5:-""}
    
    # Auto-select best voice for locale
    local voice
    if [ -n "$voice_override" ]; then
        voice="$voice_override"
    else
        voice=$(select_voice "$locale")
    fi
    
    log_info "Using voice: $voice for locale: $locale"
    
    local narration_file="$SCRIPT_DIR/narration_clinician_${language}.txt"
    
    if [ ! -f "$narration_file" ]; then
        log_error "Narration file not found: $narration_file"
        return 1
    fi
    
    case $platform in
        ios)
            record_ios "$test_name" "$language" "$locale" "$voice" "$narration_file"
            ;;
        macos)
            record_macos "$test_name" "$language" "$locale" "$voice" "$narration_file"
            ;;
        *)
            log_error "Unknown platform: $platform"
            return 1
            ;;
    esac
}

# Record all tests
record_all() {
    log_info "Recording all functional acceptance tests..."
    log_info "Output directory: $OUTPUT_DIR"
    
    # Clinician tests
    log_info "\n=== CLINICIAN DOMAIN TESTS ==="
    
    record_test "test_completePatientEncounter_English" "ios" "en" "en_US" "Samantha"
    record_test "test_emergencyWorkflow_STEMI" "ios" "en" "en_US" "Samantha"
    record_test "test_drugInteractionDetection_Warfarin" "ios" "en" "en_US" "Samantha"
    
    # macOS versions (optional)
    # record_test "test_completePatientEncounter_English" "macos" "en" "en_US" "Samantha"
    
    log_success "\nAll recordings complete!"
    log_info "Videos saved to: $OUTPUT_DIR"
    
    # Generate index
    generate_index
}

# Generate HTML index
generate_index() {
    local index_file="$OUTPUT_DIR/index.html"
    
    log_info "Generating video index..."
    
    cat > "$index_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FoT Apple - Functional Acceptance Test Videos</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f7;
        }
        h1 {
            color: #1d1d1f;
            font-size: 48px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        h2 {
            color: #1d1d1f;
            font-size: 32px;
            font-weight: 600;
            margin-top: 40px;
            margin-bottom: 20px;
        }
        .subtitle {
            color: #6e6e73;
            font-size: 21px;
            margin-bottom: 40px;
        }
        .video-container {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .video-title {
            font-size: 24px;
            font-weight: 600;
            color: #1d1d1f;
            margin-bottom: 10px;
        }
        .video-description {
            color: #6e6e73;
            margin-bottom: 15px;
        }
        video {
            width: 100%;
            border-radius: 8px;
        }
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            margin-right: 8px;
        }
        .badge-critical {
            background: #ff3b30;
            color: white;
        }
        .badge-gcp {
            background: #007aff;
            color: white;
        }
        .badge-platform {
            background: #f5f5f7;
            color: #1d1d1f;
        }
    </style>
</head>
<body>
    <h1>🎯 FoT Apple Functional Tests</h1>
    <p class="subtitle">GCP-Compliant Video Documentation & User Guides</p>
    
    <h2>Clinician Domain</h2>
    
EOF
    
    # Find all videos and add them
    find "$OUTPUT_DIR" -name "*.mp4" -type f | while read video; do
        local basename=$(basename "$video" .mp4)
        local title=$(echo "$basename" | tr '_' ' ')
        
        cat >> "$index_file" << EOF
    <div class="video-container">
        <div class="video-title">$title</div>
        <div>
            <span class="badge badge-critical">CRITICAL</span>
            <span class="badge badge-gcp">GCP FAT</span>
            <span class="badge badge-platform">iOS</span>
        </div>
        <div class="video-description">
            Functional Acceptance Test - Demonstrates complete clinical workflow with audit trail
        </div>
        <video controls>
            <source src="$(basename "$video")" type="video/mp4">
            Your browser does not support the video tag.
        </video>
    </div>
    
EOF
    done
    
    cat >> "$index_file" << 'EOF'
</body>
</html>
EOF
    
    log_success "Index created: $index_file"
    log_info "Open with: open '$index_file'"
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [command] [options]

Commands:
    all                    Record all functional tests
    clinician             Record clinician domain tests only
    test <name> <platform> Record specific test
    
Platforms:
    ios                   iOS Simulator
    macos                 macOS native
    
Examples:
    $0 all
    $0 clinician
    $0 test test_completePatientEncounter_English ios
    
Environment:
    APP_SCHEME            Xcode scheme for app (default: FoTClinician)
    TEST_SCHEME           Xcode scheme for tests (default: FoTUITests)
    OUTPUT_DIR            Output directory (default: ./FunctionalTestVideos)
EOF
}

# Main
main() {
    check_dependencies
    
    case "${1:-all}" in
        all)
            record_all
            ;;
        clinician)
            record_test "test_completePatientEncounter_English" "ios" "en" "en_US" "Samantha"
            record_test "test_emergencyWorkflow_STEMI" "ios" "en" "en_US" "Samantha"
            record_test "test_drugInteractionDetection_Warfarin" "ios" "en" "en_US" "Samantha"
            generate_index
            ;;
        test)
            if [ $# -lt 3 ]; then
                usage
                exit 1
            fi
            record_test "$2" "$3" "en" "en_US" "Samantha"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"

