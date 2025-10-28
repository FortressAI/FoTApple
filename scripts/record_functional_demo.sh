#!/bin/bash
# Record Functional Demo - Actually DRIVES the app with XCUITest
# Shows real workflows, not just splash screens

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_DIR="$PROJECT_ROOT/apps/ClinicianApp/iOS"
VIDEOS_DIR="$PROJECT_ROOT/FoTApple.wiki/videos"
SCREENSHOTS_DIR="$PROJECT_ROOT/FoTApple.wiki/screenshots/automated"

SIMULATOR_ID="6C9E9EF3-7148-48D0-A0BD-CC2CBF6650CE"
PROJECT="FoTClinicianApp.xcodeproj"
SCHEME="FoTClinicianApp"

mkdir -p "$VIDEOS_DIR"
mkdir -p "$SCREENSHOTS_DIR"

echo "🎬 FoT Clinician - Functional Demo Recording"
echo "============================================"
echo ""
echo "This will DRIVE the app automatically to show:"
echo "  ✓ Real clinical workflow"
echo "  ✓ Patient selection"
echo "  ✓ Vitals entry"
echo "  ✓ Diagnosis assessment"
echo "  ✓ Drug interactions"
echo "  ✓ Treatment planning"
echo "  ✓ SOAP note generation"
echo ""

cd "$APP_DIR"

# Build the app and tests
echo "🔨 Building app and UI tests..."
xcodebuild build-for-testing \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath .build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  > /dev/null 2>&1

echo "✅ Build complete"
echo ""

# Boot simulator
echo "📱 Booting simulator..."
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || echo "Simulator already booted"
sleep 3

# Start video recording in background
echo "📹 Starting video recording..."
VIDEO_FILE="$VIDEOS_DIR/FoT-Functional-Demo-$(date +%Y%m%d-%H%M%S).mp4"
xcrun simctl io "$SIMULATOR_ID" recordVideo --codec=h264 "$VIDEO_FILE" &
RECORD_PID=$!
sleep 2
echo "Recording started (PID: $RECORD_PID)"
echo ""

# Run the UI tests (this drives the app!)
echo "🎮 Running automated UI tests (driving the app)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath .build \
  -only-testing:FoTClinicianUITests/ClinicianWorkflowTests/testCompleteClinicianWorkflow \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | grep -E "^(Test|📸|🎬|✅|⚠️)" || true

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Stop video recording
echo "⏹️  Stopping video recording..."
kill -INT $RECORD_PID 2>/dev/null || true
wait $RECORD_PID 2>/dev/null || true
sleep 2

# Extract screenshots from test results
echo "📸 Extracting screenshots from test results..."
XCRESULT=$(find .build -name "*.xcresult" -type d | head -1)
if [ -n "$XCRESULT" ]; then
    xcrun xcresulttool export --type directory \
        --path "$XCRESULT" \
        --output-path "$SCREENSHOTS_DIR/temp_export" 2>/dev/null || true
    
    # Find and copy screenshots
    find "$SCREENSHOTS_DIR/temp_export" -name "*.png" -exec cp {} "$SCREENSHOTS_DIR/" \; 2>/dev/null || true
    rm -rf "$SCREENSHOTS_DIR/temp_export"
    
    SCREENSHOT_COUNT=$(ls -1 "$SCREENSHOTS_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Extracted $SCREENSHOT_COUNT screenshots"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Functional Demo Recording Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📹 Video:"
ls -lh "$VIDEO_FILE" | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "📸 Screenshots:"
ls -1 "$SCREENSHOTS_DIR"/*.png 2>/dev/null | head -5 | awk '{print "   " $0}'
TOTAL=$(ls -1 "$SCREENSHOTS_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL" -gt 5 ]; then
    echo "   ... and $(($TOTAL - 5)) more"
fi
echo ""
echo "✅ This video shows REAL app functionality:"
echo "   • Patient selection with allergy alerts"
echo "   • Clinical encounter workflow"
echo "   • Vitals entry"
echo "   • Differential diagnosis"
echo "   • Treatment planning"
echo "   • SOAP note generation"
echo ""

