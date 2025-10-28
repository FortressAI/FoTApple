#!/usr/bin/env bash
# Simple recording runner for Clinician iOS
# Uses simctl to record while you manually interact

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIO_FILE="$PROJECT_ROOT/FoTMarketingVideos/audio_natural/Clinician_iOS.aiff"
OUTPUT_FILE="$PROJECT_ROOT/FoTMarketingVideos/raw_recordings/Clinician_iOS.mp4"
DEVICE="iPhone 17 Pro"

echo "🎬 Recording Clinician iOS"
echo ""

# Get audio duration
DURATION=$(afinfo "$AUDIO_FILE" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "230")
echo "Duration: ${DURATION}s"
echo ""

# Boot simulator
echo "🔄 Booting simulator..."
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator
sleep 5

# Launch app
echo "🚀 Launching Clinician app..."
BUNDLE_ID="com.fot.clinician.FoTClinician"

xcrun simctl launch "$DEVICE" "$BUNDLE_ID" || {
    echo "⚠️  App not installed. Installing..."
    # Try to find and install the app
    APP_PATH=$(find "$PROJECT_ROOT/apps/ClinicianApp/iOS/.build" -name "FoTClinician.app" -type d | head -1)
    if [ -z "$APP_PATH" ]; then
        # Try alternative build location
        APP_PATH=$(find "$PROJECT_ROOT/build" -name "FoTClinician.app" -type d | head -1)
    fi
    
    if [ -n "$APP_PATH" ]; then
        echo "Found app: $APP_PATH"
        xcrun simctl install "$DEVICE" "$APP_PATH"
        sleep 2
        xcrun simctl launch "$DEVICE" "$BUNDLE_ID"
    else
        echo "❌ Could not find app. Build it first with:"
        echo "   bash build_for_recording.sh"
        exit 1
    fi
}

sleep 3

# Play audio in background
echo "🎵 Playing narration audio..."
afplay "$AUDIO_FILE" &
AUDIO_PID=$!

# Start recording
echo "📹 Recording screen for ${DURATION}s..."
echo ""
echo "👉 FOLLOW THESE ACTIONS IN THE APP:"
echo "   0:10 - Tap John Doe patient"
echo "   0:20 - Show allergy alert"
echo "   0:30 - Navigate to medications"
echo "   0:40 - Add Warfarin medication"
echo "   1:00 - Show drug interaction alert"
echo "   1:30 - Create SOAP note"
echo "   2:00 - Show cryptographic proof"
echo "   2:30 - Show privacy features"
echo ""

xcrun simctl io "$DEVICE" recordVideo --codec=h264 --force "$OUTPUT_FILE" &
RECORD_PID=$!

# Wait for audio to finish
wait $AUDIO_PID

# Stop recording
echo ""
echo "⏹️  Stopping recording..."
kill -SIGINT $RECORD_PID 2>/dev/null || true
sleep 3

if [ -f "$OUTPUT_FILE" ]; then
    SIZE=$(du -h "$OUTPUT_FILE" | awk '{print $1}')
    echo "✅ Recording complete: $OUTPUT_FILE ($SIZE)"
    echo ""
    echo "Next step: Create tutorial video"
    echo "   bash UITests/VideoRecording/create_all_professional_tutorials.sh"
else
    echo "❌ Recording failed"
    exit 1
fi
