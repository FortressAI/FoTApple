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
