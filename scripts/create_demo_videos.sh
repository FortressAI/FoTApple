#!/bin/bash
# Automated Demo Video Creation with Audio Narration
# Creates professional demo videos for all FoT apps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VIDEOS_DIR="$PROJECT_ROOT/FoTApple.wiki/videos"
AUDIO_DIR="$PROJECT_ROOT/FoTApple.wiki/audio"

mkdir -p "$VIDEOS_DIR"
mkdir -p "$AUDIO_DIR"

SIMULATOR_ID="6C9E9EF3-7148-48D0-A0BD-CC2CBF6650CE"

echo "🎬 FoT Apple - Automated Demo Video Creator"
echo "==========================================="

# Function to create narration audio using macOS text-to-speech
create_narration() {
    local text="$1"
    local output_file="$2"
    
    echo "🎙️  Creating narration: ${output_file##*/}"
    say "$text" -o "$output_file" -v Samantha
}

# Function to record app demo
record_app_demo() {
    local app_name="$1"
    local duration="$2"
    local output_file="$3"
    
    echo "📹 Recording $app_name for ${duration}s..."
    
    # Start recording in background
    xcrun simctl io "$SIMULATOR_ID" recordVideo --codec=h264 "$output_file" &
    RECORD_PID=$!
    
    # Wait for recording to start
    sleep 2
    
    # Let app run for duration
    sleep "$duration"
    
    # Stop recording
    kill -INT $RECORD_PID
    wait $RECORD_PID 2>/dev/null || true
    
    echo "✅ Recorded: ${output_file##*/}"
}

# Function to combine video and audio
combine_video_audio() {
    local video_file="$1"
    local audio_file="$2"
    local output_file="$3"
    
    echo "🎬 Combining video and audio..."
    
    # Check if ffmpeg is available
    if command -v ffmpeg &> /dev/null; then
        ffmpeg -i "$video_file" -i "$audio_file" \
            -c:v copy -c:a aac -strict experimental \
            -shortest "$output_file" -y 2>/dev/null
        echo "✅ Created: ${output_file##*/}"
    else
        echo "⚠️  ffmpeg not found - install with: brew install ffmpeg"
        echo "📹 Video saved without audio: ${video_file##*/}"
        cp "$video_file" "$output_file"
    fi
}

# =============================================================================
# CLINICIAN APP DEMO
# =============================================================================

echo ""
echo "🏥 Creating Clinician App Demo"
echo "--------------------------------"

# Narration script
CLINICIAN_NARRATION="Welcome to Field of Truth Clinician App. \
This is a HIPAA-compliant clinical decision support system built on an 8096-dimensional quantum substrate. \
The showcase tab displays our beautiful glass morphism interface with runtime asset verification. \
Every feature is backed by cryptographic receipts for medical-legal protection. \
Navigate to the Patients tab to see our patient list with real-time allergy alerts. \
Each patient record is encrypted with PHI protection. \
When you open an encounter, you get a complete clinical workflow: chief complaint, vitals, assessment, medications, and treatment plan. \
The system provides drug interaction screening powered by RxNav API integration. \
All clinical decisions are traceable through VQbit collapse receipts. \
This is not a simulation - this is production-ready AI you can trust and prove."

# Create audio narration
create_narration "$CLINICIAN_NARRATION" "$AUDIO_DIR/clinician-narration.aiff"

# Record video (30 seconds)
record_app_demo "Clinician" 30 "$VIDEOS_DIR/clinician-raw.mp4"

# Combine
combine_video_audio \
    "$VIDEOS_DIR/clinician-raw.mp4" \
    "$AUDIO_DIR/clinician-narration.aiff" \
    "$VIDEOS_DIR/FoT-Clinician-Demo.mp4"

# Cleanup raw files
rm -f "$VIDEOS_DIR/clinician-raw.mp4"

# =============================================================================
# SHOWCASE ONLY (Quick Demo)
# =============================================================================

echo ""
echo "✨ Creating Glass UI Showcase Demo"
echo "-----------------------------------"

SHOWCASE_NARRATION="Field of Truth Apple features a stunning glass morphism design system. \
Notice the animated gradient background with blue, cyan, and teal transitions. \
The glass cards use backdrop blur effects for a modern, professional appearance. \
System status is verified in real-time, showing VQbit engine readiness. \
All assets are cryptographically attested with receipts. \
This same glass UI scales across iOS, macOS, watchOS, and visionOS. \
Every interaction is beautiful, fast, and verifiable."

create_narration "$SHOWCASE_NARRATION" "$AUDIO_DIR/showcase-narration.aiff"

record_app_demo "Showcase" 15 "$VIDEOS_DIR/showcase-raw.mp4"

combine_video_audio \
    "$VIDEOS_DIR/showcase-raw.mp4" \
    "$AUDIO_DIR/showcase-narration.aiff" \
    "$VIDEOS_DIR/FoT-Glass-UI-Showcase.mp4"

rm -f "$VIDEOS_DIR/showcase-raw.mp4"

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo "🎉 Demo Videos Created Successfully!"
echo "====================================="
echo ""
echo "📹 Videos:"
ls -lh "$VIDEOS_DIR"/*.mp4 | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "🎙️  Audio:"
ls -lh "$AUDIO_DIR"/*.aiff | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "✅ Ready for wiki and marketing!"

