#!/bin/bash

# Automated UAT Video Recording using XCUITest
# This uses Apple's native testing frameworks to automatically drive the app
# and record GxP-compliant validation videos

set -e

PROJECT_ROOT="/Users/richardgillespie/Documents/FoTApple"
EVIDENCE_DIR="$PROJECT_ROOT/UITests/FunctionalValidation/Evidence"
VIDEO_DIR="$PROJECT_ROOT/UITests/FunctionalValidation/UAT_Videos"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo ""
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <test_id> [app_name] [platform]"
    echo ""
    echo "Examples:"
    echo "  $0 UAT-CL-004                    # Run UAT-CL-004 for Clinician iOS"
    echo "  $0 UAT-CL-005 Clinician iOS      # Explicit parameters"
    echo ""
    echo "Available tests:"
    echo "  UAT-CL-004 - Drug Interaction Detection (CRITICAL SAFETY)"
    echo "  UAT-CL-005 - Allergy Alert Detection (CRITICAL SAFETY)"
    echo "  UAT-CL-006 - Contraindication Warnings (CRITICAL SAFETY)"
    echo ""
    exit 1
fi

TEST_ID="$1"
APP_NAME="${2:-Clinician}"
PLATFORM="${3:-iOS}"

# Determine test class and method based on TEST_ID
case "$TEST_ID" in
    UAT-CL-004)
        TEST_CLASS="UAT_DrugInteractionTests"
        TEST_METHOD="test_UAT_CL_004_DrugInteractionDetection"
        APP_SCHEME="FoTClinicianApp"
        APP_PROJECT="$PROJECT_ROOT/apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj"
        ;;
    UAT-CL-005)
        TEST_CLASS="UAT_AllergyTests"
        TEST_METHOD="test_UAT_CL_005_AllergyDetection"
        APP_SCHEME="FoTClinicianApp"
        APP_PROJECT="$PROJECT_ROOT/apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj"
        ;;
    *)
        log_error "Unknown test ID: $TEST_ID"
        log_info "Available tests: UAT-CL-004, UAT-CL-005"
        exit 1
        ;;
esac

# Setup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="$EVIDENCE_DIR/${APP_NAME}/${TEST_ID}_${TIMESTAMP}"
VIDEO_FILE="$VIDEO_DIR/${APP_NAME}/Raw/${TEST_ID}_${PLATFORM}_${TIMESTAMP}.mov"
FINAL_VIDEO="$VIDEO_DIR/${APP_NAME}/Final/${TEST_ID}_${PLATFORM}_${TIMESTAMP}.mp4"
PROOF_FILE="$OUTPUT_DIR/${TEST_ID}_proof.json"
TEST_RESULTS="$OUTPUT_DIR/${TEST_ID}_test_results.txt"

mkdir -p "$OUTPUT_DIR"/{Screenshots,NetworkLogs,DatabaseStates}
mkdir -p "$(dirname "$VIDEO_FILE")"
mkdir -p "$(dirname "$FINAL_VIDEO")"

log_header "🎬 Automated UAT Recording"
log_info "Test ID: $TEST_ID"
log_info "App: $APP_NAME"
log_info "Platform: $PLATFORM"
log_info "Test Class: $TEST_CLASS"
log_info "Test Method: $TEST_METHOD"
echo ""

# Check dependencies
log_info "Checking dependencies..."

if ! command -v xcodebuild &> /dev/null; then
    log_error "xcodebuild not found - install Xcode command line tools"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    log_warning "ffmpeg not found - video processing may be limited"
fi

log_success "Dependencies OK"
echo ""

# Get simulator device ID
log_info "Finding iOS Simulator..."
DEVICE_NAME="iPhone 17 Pro Max"
DEVICE_ID=$(xcrun simctl list devices available | grep "$DEVICE_NAME" | head -n1 | grep -o '[A-F0-9\-]\{36\}')

if [ -z "$DEVICE_ID" ]; then
    log_error "No suitable simulator found"
    log_info "Available devices:"
    xcrun simctl list devices | grep "iPhone"
    exit 1
fi

log_success "Simulator: $DEVICE_NAME ($DEVICE_ID)"
echo ""

# Boot simulator
log_info "Booting simulator..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator
sleep 5

log_success "Simulator booted"
echo ""

# Build for testing
log_header "📦 Building App for Testing"

xcodebuild \
    -project "$APP_PROJECT" \
    -scheme "$APP_SCHEME" \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath "$PROJECT_ROOT/build/DerivedData" \
    build-for-testing \
    2>&1 | grep -E '(Building|Compiling|Linking|error|warning|Build Succeeded)' || true

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    log_error "Build failed"
    exit 1
fi

log_success "Build complete"
echo ""

# Start network capture (background)
log_info "Starting network capture..."
if command -v tcpdump &> /dev/null; then
    sudo tcpdump -i any -w "$OUTPUT_DIR/NetworkLogs/network_${TIMESTAMP}.pcap" &
    TCPDUMP_PID=$!
    log_success "Network capture started (PID: $TCPDUMP_PID)"
else
    log_warning "tcpdump not available - skipping network capture"
    TCPDUMP_PID=""
fi

echo ""

# Start screen recording
log_header "🎥 Starting Recording & Test Execution"

log_info "Starting screen recording..."
xcrun simctl io "$DEVICE_ID" recordVideo \
    --codec=h264 \
    --force \
    "$VIDEO_FILE" &
RECORDING_PID=$!

log_success "Recording started (PID: $RECORDING_PID)"
sleep 2

# Run XCUITest (this drives the app automatically)
log_info "Running automated UAT test..."
log_warning "The test will drive the UI automatically - DO NOT INTERACT"
echo ""

xcodebuild \
    -project "$APP_PROJECT" \
    -scheme "$APP_SCHEME" \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath "$PROJECT_ROOT/build/DerivedData" \
    test-without-building \
    -only-testing:"${APP_SCHEME}UITests/${TEST_CLASS}/${TEST_METHOD}" \
    2>&1 | tee "$TEST_RESULTS" | grep -E '(Test Suite|Test Case|▶️|✅|⚠️|passed|failed|Checkpoint)'

TEST_EXIT_CODE=${PIPESTATUS[0]}

# Stop recording
sleep 2
log_info "Stopping recording..."
kill -INT $RECORDING_PID 2>/dev/null || true
wait $RECORDING_PID 2>/dev/null || true

# Stop network capture
if [ -n "$TCPDUMP_PID" ]; then
    sudo kill $TCPDUMP_PID 2>/dev/null || true
fi

sleep 2

if [ ! -f "$VIDEO_FILE" ]; then
    log_error "Video file was not created"
    exit 1
fi

log_success "Recording stopped"
echo ""

# Process test results
log_header "📊 Test Results"

if [ $TEST_EXIT_CODE -eq 0 ]; then
    log_success "All test assertions PASSED"
    TEST_STATUS="PASSED"
else
    log_error "Some test assertions FAILED"
    TEST_STATUS="FAILED"
    log_warning "Review test results in: $TEST_RESULTS"
fi

# Count critical checkpoints
CRITICAL_CHECKPOINTS=$(grep -c "CRITICAL CHECKPOINT PASSED" "$TEST_RESULTS" || echo "0")
TOTAL_CHECKPOINTS=$(grep -c "Checkpoint:" "$TEST_RESULTS" || echo "0")

log_info "Critical checkpoints passed: $CRITICAL_CHECKPOINTS"
log_info "Total checkpoints captured: $TOTAL_CHECKPOINTS"
echo ""

# Generate cryptographic proof
log_header "🔐 Generating Cryptographic Proof"

log_info "Calculating video hash..."
VIDEO_HASH=$(shasum -a 256 "$VIDEO_FILE" | awk '{print $1}')
VIDEO_SIZE=$(stat -f%z "$VIDEO_FILE" 2>/dev/null || stat -c%s "$VIDEO_FILE")
VIDEO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE" 2>/dev/null || echo "unknown")

log_success "Video hash: ${VIDEO_HASH:0:16}..."
log_info "Video size: $(numfmt --to=iec-i --suffix=B $VIDEO_SIZE 2>/dev/null || echo $VIDEO_SIZE bytes)"
log_info "Video duration: ${VIDEO_DURATION}s"
echo ""

# Generate proof bundle
log_info "Generating proof bundle..."

cat > "$PROOF_FILE" << EOF
{
  "test_id": "$TEST_ID",
  "test_class": "$TEST_CLASS",
  "test_method": "$TEST_METHOD",
  "app": "$APP_NAME",
  "platform": "$PLATFORM",
  "test_result": "$TEST_STATUS",
  "critical_checkpoints_passed": $CRITICAL_CHECKPOINTS,
  "total_checkpoints": $TOTAL_CHECKPOINTS,
  "execution_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "video_file": "$VIDEO_FILE",
  "video_hash_sha256": "$VIDEO_HASH",
  "video_size_bytes": $VIDEO_SIZE,
  "video_duration_seconds": $VIDEO_DURATION,
  "device_id": "$DEVICE_ID",
  "device_name": "$DEVICE_NAME",
  "xcode_version": "$(xcodebuild -version | head -n1)",
  "ios_version": "$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -oE 'iOS [0-9.]+' || echo 'unknown')",
  "tester": "$USER",
  "automated": true,
  "evidence_directory": "$OUTPUT_DIR",
  "test_results_file": "$TEST_RESULTS",
  "network_capture": "$([ -n "$TCPDUMP_PID" ] && echo "true" || echo "false")",
  "status": "validation_complete"
}
EOF

log_success "Proof bundle: $PROOF_FILE"
echo ""

# Process video (optional)
if command -v ffmpeg &> /dev/null; then
    log_info "Processing video..."
    
    # Add timestamp overlay
    ffmpeg -i "$VIDEO_FILE" \
        -vf "drawtext=text='UAT-CL-004 %{pts\\:hms}':x=10:y=10:fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5" \
        -c:v libx264 -preset fast -crf 23 \
        "$FINAL_VIDEO" \
        2>&1 | grep -E '(frame=|Duration|Output)' || true
    
    if [ -f "$FINAL_VIDEO" ]; then
        log_success "Final video: $FINAL_VIDEO"
    fi
else
    log_warning "ffmpeg not available - using raw video only"
    FINAL_VIDEO="$VIDEO_FILE"
fi

echo ""

# Extract screenshots from XCTest attachments
log_header "📸 Extracting Screenshots"

DERIVED_DATA="$PROJECT_ROOT/build/DerivedData"
XCRESULT=$(find "$DERIVED_DATA" -name "*.xcresult" -type d | head -n1)

if [ -n "$XCRESULT" ]; then
    log_info "Found test results: $XCRESULT"
    
    # Export screenshots from xcresult
    xcrun xcresulttool export \
        --path "$XCRESULT" \
        --output-path "$OUTPUT_DIR/Screenshots" \
        --type directory-attachments \
        2>&1 | grep -v "Warning" || true
    
    SCREENSHOT_COUNT=$(find "$OUTPUT_DIR/Screenshots" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Exported $SCREENSHOT_COUNT screenshots"
else
    log_warning "Could not find xcresult bundle"
fi

echo ""

# Summary
log_header "✅ UAT Recording Complete"

echo ""
echo "Test ID:           $TEST_ID"
echo "Status:            $TEST_STATUS"
echo "Video:             $VIDEO_FILE"
if [ "$FINAL_VIDEO" != "$VIDEO_FILE" ]; then
    echo "Processed Video:   $FINAL_VIDEO"
fi
echo "Proof Bundle:      $PROOF_FILE"
echo "Evidence:          $OUTPUT_DIR"
echo "Screenshots:       $SCREENSHOT_COUNT"
echo "Duration:          ${VIDEO_DURATION}s"
echo ""

if [ "$TEST_STATUS" = "PASSED" ]; then
    echo "🎉 All validation checkpoints PASSED"
    echo "📦 This video is ready for GxP submission"
else
    echo "⚠️  Some validation checkpoints FAILED"
    echo "📋 Review test results and re-run if needed"
fi

echo ""
echo "Next steps:"
echo "  1. Watch the video: open \"$VIDEO_FILE\""
echo "  2. Review proof bundle: cat \"$PROOF_FILE\""
echo "  3. Check screenshots: open \"$OUTPUT_DIR/Screenshots\""
echo ""

if [ "$TEST_STATUS" = "PASSED" ]; then
    echo "To run the next UAT test:"
    echo "  bash run_uat_automated.sh UAT-CL-005"
fi

echo ""

