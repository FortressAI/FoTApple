#!/bin/bash
# Quick Functional Demo - Fast interactions showing real functionality

set -e

SIMULATOR_ID="6C9E9EF3-7148-48D0-A0BD-CC2CBF6650CE"
VIDEOS_DIR="/Users/richardgillespie/Documents/FoTApple/FoTApple.wiki/videos"

mkdir -p "$VIDEOS_DIR"

echo "🎬 Quick Functional Demo - 60 seconds"
echo "======================================"

# Start recording
VIDEO_FILE="$VIDEOS_DIR/FoT-Quick-Demo-$(date +%H%M%S).mp4"
echo "📹 Recording to: $(basename $VIDEO_FILE)"
xcrun simctl io "$SIMULATOR_ID" recordVideo --codec=h264 "$VIDEO_FILE" &
RECORD_PID=$!
sleep 2

echo "🎮 Simulating user interactions..."
echo ""

# Function to tap coordinates
tap() {
    local x=$1
    local y=$2
    local desc=$3
    echo "  👆 $desc"
    osascript -e "tell application \"Simulator\" to activate" 2>/dev/null || true
    # Use AppleScript to click at coordinates
    osascript <<EOF 2>/dev/null || true
tell application "System Events"
    tell process "Simulator"
        set frontmost to true
        click at {$x, $y}
    end tell
end tell
EOF
    sleep 1
}

# Get Simulator window position (assuming default position)
# These coordinates are for iPhone 17 Pro in Simulator

echo "1️⃣ Showing Glass UI Showcase (5s)"
sleep 5

echo "2️⃣ Tapping Patients tab"
tap 200 850 "Navigate to Patients"
sleep 3

echo "3️⃣ Scrolling patient list"
# Scroll down
osascript <<'EOF' 2>/dev/null || true
tell application "System Events"
    tell process "Simulator"
        set frontmost to true
        key code 125 -- down arrow
        delay 0.5
        key code 125
    end tell
end tell
EOF
sleep 2

echo "4️⃣ Selecting first patient"
tap 200 200 "Select patient with allergies"
sleep 3

echo "5️⃣ Opening Encounter tab"
tap 300 850 "Open clinical encounter"
sleep 3

echo "6️⃣ Showing encounter sections"
# Tap through encounter sections
tap 200 100 "Chief Complaint"
sleep 2
tap 300 100 "Vitals"
sleep 2
tap 400 100 "Assessment"
sleep 2

echo "7️⃣ Back to Showcase"
tap 100 850 "Return to showcase"
sleep 3

# Stop recording
echo ""
echo "⏹️  Stopping recording..."
kill -INT $RECORD_PID 2>/dev/null || true
wait $RECORD_PID 2>/dev/null || true
sleep 3

echo ""
echo "✅ Demo complete!"
ls -lh "$VIDEO_FILE" | awk '{print "📹 " $9 " (" $5 ")"}'

