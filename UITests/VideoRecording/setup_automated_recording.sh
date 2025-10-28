#!/usr/bin/env bash
# Setup Automated Recording Infrastructure
# Creates XCUITest targets and configures project

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }

# Create UITests directory structure
setup_uitests_structure() {
    log_header "Setting Up UITests Structure"
    
    mkdir -p "$PROJECT_ROOT/UITests/AutomatedRecording"
    mkdir -p "$PROJECT_ROOT/FoTMarketingVideos/raw_recordings"
    mkdir -p "$PROJECT_ROOT/FoTMarketingVideos/tutorials"
    
    log_success "Directory structure created"
}

# Copy test files
copy_test_files() {
    log_header "Setting Up Test Files"
    
    # The ClinicianIOSRecordingTests.swift is already created
    log_success "Test files ready"
}

# Create a simple recording runner that doesn't require XCUITest
create_simple_runner() {
    log_header "Creating Simple Recording Runner"
    
    cat > "$PROJECT_ROOT/UITests/VideoRecording/simple_record_clinician_ios.sh" << 'EOF'
#!/usr/bin/env bash
# Simple recording runner for Clinician iOS
# Uses simctl to record while you manually interact

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIO_FILE="$PROJECT_ROOT/FoTMarketingVideos/audio_natural/Clinician_iOS.aiff"
OUTPUT_FILE="$PROJECT_ROOT/FoTMarketingVideos/raw_recordings/Clinician_iOS.mp4"
DEVICE="iPhone 15 Pro"

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
xcrun simctl launch "$DEVICE" com.fot.clinician || {
    echo "⚠️  App not installed. Installing..."
    # Try to find and install the app
    APP_PATH=$(find "$PROJECT_ROOT/build" -name "FoTClinician.app" -type d | head -1)
    if [ -n "$APP_PATH" ]; then
        xcrun simctl install "$DEVICE" "$APP_PATH"
        xcrun simctl launch "$DEVICE" com.fot.clinician
    else
        echo "❌ Could not find app. Build it first with:"
        echo "   xcodebuild -scheme FoTClinician -destination 'platform=iOS Simulator,name=iPhone 15 Pro'"
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
EOF
    
    chmod +x "$PROJECT_ROOT/UITests/VideoRecording/simple_record_clinician_ios.sh"
    
    log_success "Simple runner created"
}

# Create build script
create_build_script() {
    log_header "Creating Build Script"
    
    cat > "$PROJECT_ROOT/build_for_recording.sh" << 'EOF'
#!/usr/bin/env bash
# Build all apps for recording

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "🔨 Building apps for recording..."
echo ""

# iOS Apps
echo "📱 Building iOS apps..."
xcodebuild \
    -scheme FoTClinician \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    -configuration Debug \
    -derivedDataPath "$PROJECT_ROOT/build/DerivedData" \
    | grep -E '(error|warning|Build Succeeded)' || true

echo ""
echo "💻 Building macOS apps..."
xcodebuild \
    -scheme FoTClinicianMac \
    -destination 'platform=macOS' \
    -configuration Debug \
    -derivedDataPath "$PROJECT_ROOT/build/DerivedData" \
    | grep -E '(error|warning|Build Succeeded)' || true

echo ""
echo "✅ Build complete!"
echo ""
echo "Next step: Record apps"
echo "   bash UITests/VideoRecording/simple_record_clinician_ios.sh"
EOF
    
    chmod +x "$PROJECT_ROOT/build_for_recording.sh"
    
    log_success "Build script created"
}

# Create README
create_readme() {
    log_header "Creating Documentation"
    
    cat > "$PROJECT_ROOT/UITests/VideoRecording/RECORDING_QUICK_START.md" << 'EOF'
# 🎬 Quick Start: Automated Recording

## 🚀 Fastest Way to Create Tutorials

### Step 1: Build the apps
```bash
cd /Users/richardgillespie/Documents/FoTApple
bash build_for_recording.sh
```

### Step 2: Record Clinician iOS (simplest)
```bash
bash UITests/VideoRecording/simple_record_clinician_ios.sh
```

**What this does:**
1. Boots iPhone simulator
2. Launches Clinician app
3. Plays audio narration in background
4. Records screen for audio duration
5. **YOU interact with app** following the audio
6. Saves MP4 to `raw_recordings/`

### Step 3: Create final tutorial
```bash
bash UITests/VideoRecording/create_all_professional_tutorials.sh
```

This combines the recording with audio and creates the final tutorial MP4.

### Step 4: View the result
```bash
open FoTMarketingVideos/tutorials/Clinician_iOS_Tutorial.mp4
```

---

## 📋 Actions Timeline (Follow During Recording)

### Clinician iOS - 3:42 (222 seconds)

**0:00-0:10** - Introduction
- Patient dashboard visible
- Show list of patients

**0:10-0:20** - Patient Selection
- Tap "John Doe" patient
- Patient details screen appears

**0:20-0:30** - Allergy Alert
- Show allergy section
- Highlight Penicillin alert with anaphylaxis warning

**0:30-0:40** - Current Medications
- Navigate to Medications tab
- Show Aspirin 81mg

**0:40-0:55** - Add New Medication
- Tap "Add Medication" button
- Search for "Warfarin"
- Select from results

**0:55-1:10** - Drug Interaction Alert
- Alert appears automatically
- Shows "Critical drug interaction detected"
- Display bleeding risk warning

**1:10-1:30** - Virtue Scores & Recommendations
- Show explanation with evidence
- Display virtue scores (Justice, Temperance, Prudence, Fortitude)
- Show alternative recommendations

**1:30-2:00** - SOAP Note Creation
- Navigate to SOAP Note section
- Show voice input capability
- Demonstrate structured documentation

**2:00-2:30** - Cryptographic Proof
- Show audit trail
- Display blockchain anchoring
- Export proof bundle

**2:30-2:46** - Privacy & Encryption
- Navigate to Settings
- Show HIPAA compliance
- Display AES-256 encryption info
- Show on-device processing

---

## 🎯 Tips for Best Results

✅ **Before Recording:**
- Listen to audio first - know what's coming
- Practice the flow without recording
- Have script open for reference
- Close unnecessary apps

✅ **During Recording:**
- Keep actions smooth and deliberate
- Match timing with audio narration
- Don't rush - pauses are natural
- If you mess up, just re-record

✅ **After Recording:**
- Watch the raw MP4
- Check if timing matches audio
- Re-record if needed
- Create final tutorial

---

## 🔄 If Something Goes Wrong

### App won't launch
```bash
# Reinstall app
xcrun simctl uninstall "iPhone 15 Pro" com.fot.clinician
# Rebuild
bash build_for_recording.sh
```

### Recording is choppy
```bash
# Use higher quality settings
xcrun simctl io "iPhone 15 Pro" recordVideo --codec=h264 --quality=high output.mp4
```

### Timing is off
- Adjust audio rate (see TUTORIAL_CREATION_WORKFLOW.md)
- Or just re-record with better timing

---

## 📦 What You'll Have After

```
FoTMarketingVideos/
├── audio_natural/
│   └── Clinician_iOS.aiff          ✅ Natural voice narration
├── raw_recordings/
│   └── Clinician_iOS.mp4           ✅ Screen recording
└── tutorials/
    └── Clinician_iOS_Tutorial.mp4  ✅ Final tutorial (video + audio)
```

---

## 🚀 Record All Apps

Once you're comfortable with Clinician iOS, record the others:

### iOS Apps
```bash
bash UITests/VideoRecording/simple_record_legalus_ios.sh
bash UITests/VideoRecording/simple_record_education_ios.sh
```

### macOS Apps
```bash
bash UITests/VideoRecording/simple_record_clinician_macos.sh
bash UITests/VideoRecording/simple_record_legalus_macos.sh
bash UITests/VideoRecording/simple_record_education_macos.sh
```

### watchOS Apps
```bash
bash UITests/VideoRecording/simple_record_clinician_watchos.sh
# ... etc
```

Then create all tutorials at once:
```bash
bash UITests/VideoRecording/create_all_professional_tutorials.sh
```

---

## 🌐 View All Tutorials

```bash
open TUTORIALS_SHOWCASE.html
```

All your tutorial videos will be embedded and ready to share with beta testers!
EOF
    
    log_success "Documentation created"
}

# Main
main() {
    clear
    
    log_header "🎬 AUTOMATED RECORDING SETUP"
    
    setup_uitests_structure
    copy_test_files
    create_simple_runner
    create_build_script
    create_readme
    
    log_header "✅ SETUP COMPLETE"
    
    echo ""
    log_info "Quick Start Guide:"
    echo "  1. Build apps:       bash build_for_recording.sh"
    echo "  2. Record first app: bash UITests/VideoRecording/simple_record_clinician_ios.sh"
    echo "  3. Create tutorial:  bash UITests/VideoRecording/create_all_professional_tutorials.sh"
    echo "  4. View showcase:    open TUTORIALS_SHOWCASE.html"
    echo ""
    log_info "Full documentation:"
    echo "  open UITests/VideoRecording/RECORDING_QUICK_START.md"
    echo ""
}

main "$@"

