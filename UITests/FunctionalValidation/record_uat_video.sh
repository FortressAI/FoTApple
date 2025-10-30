#!/bin/bash

# UAT Video Recording Script
# Records a single UAT test with full evidence capture

set -e

# Parse arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <test_id> <app_name> <platform>"
    echo "Example: $0 UAT-CL-004 Clinician iOS"
    exit 1
fi

TEST_ID="$1"
APP_NAME="$2"
PLATFORM="$3"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="./Evidence/${APP_NAME}/${TEST_ID}_${TIMESTAMP}"
VIDEO_FILE="${OUTPUT_DIR}/${TEST_ID}_${PLATFORM}_${TIMESTAMP}.mov"
PROOF_FILE="${OUTPUT_DIR}/${TEST_ID}_proof.json"

mkdir -p "${OUTPUT_DIR}"/{Screenshots,NetworkLogs}

echo "=================================================="
echo "UAT Video Recording"
echo "=================================================="
echo "Test ID: ${TEST_ID}"
echo "App: ${APP_NAME}"
echo "Platform: ${PLATFORM}"
echo "Output: ${OUTPUT_DIR}"
echo ""

# Boot simulator if needed
echo "🚀 Starting iOS Simulator..."
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 15 Pro" | head -n1 | grep -o '[A-F0-9\-]\{36\}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ iPhone 15 Pro Simulator not found"
    exit 1
fi

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
sleep 3

echo "✅ Simulator ready: $DEVICE_ID"
echo ""

# Start network monitoring (if tcpdump available)
if command -v tcpdump &> /dev/null; then
    echo "🌐 Starting network capture..."
    sudo tcpdump -i any -w "${OUTPUT_DIR}/NetworkLogs/network_${TIMESTAMP}.pcap" &
    TCPDUMP_PID=$!
    echo "✅ Network capture started (PID: ${TCPDUMP_PID})"
fi

# Start screen recording
echo "📹 Starting screen recording..."
echo ""
echo "Press ENTER when you're ready to start the test..."
read

xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --force "$VIDEO_FILE" &
RECORDING_PID=$!

echo "🔴 RECORDING STARTED"
echo "=================================================="
echo ""
echo "Perform your UAT test now."
echo "Speak clearly and describe each action."
echo ""
echo "When finished, press ENTER to stop recording..."
read

# Stop recording
echo ""
echo "⏹️  Stopping recording..."
kill -SIGINT $RECORDING_PID 2>/dev/null || true
wait $RECORDING_PID 2>/dev/null || true

# Stop network capture
if [ -n "${TCPDUMP_PID:-}" ]; then
    sudo kill $TCPDUMP_PID 2>/dev/null || true
fi

echo "✅ Recording stopped"
echo ""

# Generate video hash
echo "🔐 Generating cryptographic proof..."
VIDEO_HASH=$(shasum -a 256 "$VIDEO_FILE" | awk '{print $1}')
VIDEO_SIZE=$(stat -f%z "$VIDEO_FILE")
VIDEO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")

# Generate proof bundle
cat > "$PROOF_FILE" << EOF
{
  "test_id": "${TEST_ID}",
  "app": "${APP_NAME}",
  "platform": "${PLATFORM}",
  "recording_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "video_file": "${VIDEO_FILE}",
  "video_hash_sha256": "${VIDEO_HASH}",
  "video_size_bytes": ${VIDEO_SIZE},
  "video_duration_seconds": ${VIDEO_DURATION},
  "device_id": "${DEVICE_ID}",
  "tester": "${USER}",
  "evidence_directory": "${OUTPUT_DIR}",
  "status": "pending_validation"
}
EOF

echo "✅ Proof bundle generated: ${PROOF_FILE}"
echo ""

# Summary
echo "=================================================="
echo "Recording Complete"
echo "=================================================="
echo ""
echo "📹 Video: ${VIDEO_FILE}"
echo "📄 Proof: ${PROOF_FILE}"
echo "📁 Evidence: ${OUTPUT_DIR}"
echo ""
echo "Next steps:"
echo "1. Review the video for completeness"
echo "2. Add test narration audio"
echo "3. Generate Merkle root and Ed25519 signature"
echo "4. Anchor to blockchain"
echo ""
