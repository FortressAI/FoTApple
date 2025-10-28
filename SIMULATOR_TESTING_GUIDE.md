# 📱 Simulator Testing Guide

**Purpose:** Launch and test all 5 apps in iOS Simulator with Siri integration

---

## 🚀 Quick Start

### 1. Boot Simulator
```bash
# List available simulators
xcrun simctl list devices | grep "iPhone"

# Boot iPhone 17 (iOS 26.1)
xcrun simctl boot "iPhone 17"

# Open Simulator app
open -a Simulator
```

### 2. Install Apps
```bash
cd /Users/richardgillespie/Documents/FoTApple

# Install Personal Health App
cd apps/PersonalHealthApp/iOS
xcodebuild -project PersonalHealthApp.xcodeproj \
           -scheme PersonalHealthApp \
           -destination 'name=iPhone 17' \
           -sdk iphonesimulator \
           CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Install Clinician App
cd ../../../apps/ClinicianApp/iOS
xcodebuild -project FoTClinicianApp.xcodeproj \
           -scheme FoTClinicianApp \
           -destination 'name=iPhone 17' \
           -sdk iphonesimulator \
           CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Install Parent App
cd ../../../apps/ParentApp/iOS
xcodebuild -project FoTParentApp.xcodeproj \
           -scheme FoTParentApp \
           -destination 'name=iPhone 17' \
           -sdk iphonesimulator \
           CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Install Education App
cd ../../../apps/EducationApp/iOS
xcodebuild -project FoTEducationApp.xcodeproj \
           -scheme FoTEducationApp \
           -destination 'name=iPhone 17' \
           -sdk iphonesimulator \
           CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Install Legal App
cd ../../../apps/LegalApp/iOS
xcodebuild -project FoTLegalApp.xcodeproj \
           -scheme FoTLegalApp \
           -destination 'name=iPhone 17' \
           -sdk iphonesimulator \
           CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

### 3. Launch Apps
```bash
# Launch Personal Health
xcrun simctl launch booted com.fot.PersonalHealth

# Launch Clinician
xcrun simctl launch booted com.fot.ClinicianApp

# Launch Parent
xcrun simctl launch booted com.fot.ParentApp

# Launch Education
xcrun simctl launch booted com.fot.EducationApp

# Launch Legal
xcrun simctl launch booted com.fot.LegalApp
```

---

## 🎤 Testing Siri Integration

### Method 1: macOS Siri (Easiest)
1. Press `Cmd+Space` to activate Siri on Mac
2. Say: "Hey Siri, log my blood pressure in Personal Health"
3. Siri will send the command to the simulator app

### Method 2: Shortcuts App
1. Open Shortcuts app on Mac
2. Click `+` to create new shortcut
3. Search for "Personal Health" or other app names
4. You should see all App Intents available
5. Add intent to shortcut and test

### Method 3: Xcode Console
1. Set breakpoint in App Intent `perform()` method
2. Run app from Xcode with debugger
3. Trigger Siri command
4. Watch execution in debugger

---

## 📹 Recording Video Demos

### Setup Screen Recording
```bash
# Start screen recording of simulator
xcrun simctl io booted recordVideo --codec=h264 ~/Desktop/app_demo.mp4 &

# Get recording PID
RECORDING_PID=$!

# ... interact with app ...

# Stop recording (after demo complete)
kill -INT $RECORDING_PID
```

### Video Recording Script
```bash
#!/bin/bash
# record_demo.sh - Record app demo video

APP_NAME=$1
DEMO_DURATION=${2:-30}  # Default 30 seconds

echo "📹 Recording $APP_NAME demo for $DEMO_DURATION seconds..."

# Start recording
xcrun simctl io booted recordVideo \
    --codec=h264 \
    --force \
    ~/Desktop/${APP_NAME}_demo_$(date +%Y%m%d_%H%M%S).mp4 &

RECORDING_PID=$!
echo "Recording PID: $RECORDING_PID"

# Launch app
xcrun simctl launch booted com.fot.$APP_NAME

# Wait for demo duration
sleep $DEMO_DURATION

# Stop recording
kill -INT $RECORDING_PID

echo "✅ Recording complete!"
```

---

## 🧪 Functional Testing Checklist

### Personal Health App
- [ ] Launch app successfully
- [ ] Navigate to health metrics screen
- [ ] Try "log blood pressure" Siri command
- [ ] Verify cryptographic receipt displays
- [ ] Check VQbit AI insight appears
- [ ] Test crisis support button
- [ ] Verify data persists after restart

### Clinician App
- [ ] Launch app successfully
- [ ] Start new patient encounter
- [ ] Try "add patient vitals" Siri command
- [ ] Record diagnosis
- [ ] Prescribe medication
- [ ] Check drug interactions
- [ ] End encounter with receipt
- [ ] Verify HIPAA compliance indicators

### Parent App
- [ ] Launch app successfully
- [ ] View child's progress dashboard
- [ ] Try "check my child's grades" Siri command
- [ ] View homework assignments
- [ ] Schedule parent-teacher meeting
- [ ] Check attendance record
- [ ] Verify FERPA compliance

### Education App (Teacher Mode)
- [ ] Launch app in teacher mode
- [ ] Record attendance
- [ ] Try "grade assignment" Siri command
- [ ] Document behavior incident
- [ ] Send class announcement
- [ ] Create lesson plan
- [ ] Update progress report

### Education App (Student Mode)
- [ ] Launch app in student mode
- [ ] View class schedule
- [ ] Try "log study session" Siri command
- [ ] Check grades
- [ ] Request assignment extension
- [ ] Reflect on virtue
- [ ] Ask teacher question

### Legal App (Personal Mode)
- [ ] Launch app in personal mode
- [ ] Document incident
- [ ] Try "record evidence" Siri command
- [ ] Upload supporting document
- [ ] Track complaint status
- [ ] Find legal help
- [ ] View case summary

### Legal App (Attorney Mode)
- [ ] Launch app in attorney mode
- [ ] Create client case
- [ ] Try "record billable time" Siri command
- [ ] Schedule deposition
- [ ] File court document
- [ ] Search case law
- [ ] Generate legal memo
- [ ] Verify attorney-client privilege protection

---

## 🐛 Debugging Tips

### Check App Installation
```bash
xcrun simctl listapps booted | grep "com.fot"
```

### View App Logs
```bash
xcrun simctl spawn booted log stream --predicate 'process == "PersonalHealth"'
```

### Check App Intents Registration
```bash
# App Intents should appear in Settings > Siri & Search
# Open Settings in simulator and verify apps are listed
```

### Reset Simulator (if needed)
```bash
xcrun simctl erase "iPhone 17"
xcrun simctl boot "iPhone 17"
```

### Check for Crashes
```bash
xcrun simctl diagnose
```

---

## 📊 Performance Testing

### App Launch Time
```bash
# Measure cold start time
time xcrun simctl launch booted com.fot.PersonalHealth
```

### Memory Usage
```bash
# Monitor memory while app is running
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.apple.system.memory"'
```

### Intent Execution Time
```bash
# Add timing logs in App Intent perform() method
let start = Date()
// ... intent logic ...
let duration = Date().timeIntervalSince(start)
print("Intent executed in \(duration)s")
```

---

## 🎥 Video Production Workflow

### For Each of 55 Video Scripts:

1. **Prepare**
   - Read script from `VIDEO_SCRIPTS_APP_INTENTS.md`
   - Boot simulator
   - Install app
   - Set up screen recording

2. **Record**
   - Start screen recording
   - Launch app
   - Perform actions from script
   - Trigger Siri commands
   - Capture key moments (receipts, AI insights)
   - Stop recording after 30-60 seconds

3. **Post-Process**
   - Trim video to key content
   - Add narration from script
   - Add captions for Siri commands
   - Export as MP4

4. **Organize**
   - Save to `FoTMarketingVideos/final/`
   - Name: `{AppName}_{IntentName}_demo.mp4`
   - Add to video catalog

---

## ✅ Testing Success Criteria

### App Installation
- ✓ All 5 apps install without errors
- ✓ All app icons appear on simulator home screen
- ✓ All apps launch within 2 seconds

### App Functionality
- ✓ All UI elements render correctly
- ✓ All navigation works
- ✓ All data persists correctly
- ✓ No crashes or freezes

### Siri Integration
- ✓ All 64 intents discoverable by Siri
- ✓ All intents execute correctly
- ✓ All responses include cryptographic receipts
- ✓ All responses include VQbit AI insights
- ✓ All intents appear in Shortcuts app

### Performance
- ✓ App launch < 2 seconds
- ✓ Intent execution < 1 second
- ✓ Memory usage < 100MB
- ✓ No memory leaks

### Compliance
- ✓ HIPAA indicators visible (Health/Clinician)
- ✓ FERPA indicators visible (Education)
- ✓ Attorney-client privilege indicators visible (Legal)
- ✓ All receipts cryptographically signed

---

## 🚀 Next Steps After Testing

1. **Fix any bugs discovered**
   - Document in GitHub Issues
   - Prioritize by severity
   - Fix and re-test

2. **Capture screenshots**
   - For App Store listing
   - 6.5" iPhone display (1284 x 2778)
   - Show key features
   - Include Siri integration

3. **Create marketing videos**
   - Use recorded demos
   - Add professional narration
   - Add captions
   - Upload to YouTube/website

4. **Prepare TestFlight**
   - Add code signing
   - Create archive
   - Upload to App Store Connect
   - Invite beta testers

5. **App Store submission**
   - Complete metadata
   - Add screenshots
   - Submit for review

---

## 📱 Simulator Commands Quick Reference

```bash
# List devices
xcrun simctl list devices

# Boot device
xcrun simctl boot "iPhone 17"

# Install app
xcrun simctl install booted path/to/app.app

# Launch app
xcrun simctl launch booted com.fot.AppName

# Open URL in app
xcrun simctl openurl booted "fotapp://action"

# Take screenshot
xcrun simctl io booted screenshot screenshot.png

# Record video
xcrun simctl io booted recordVideo video.mp4

# Get app container path
xcrun simctl get_app_container booted com.fot.AppName

# Uninstall app
xcrun simctl uninstall booted com.fot.AppName

# Erase all data
xcrun simctl erase "iPhone 17"

# Shutdown
xcrun simctl shutdown "iPhone 17"
```

---

*Simulator Testing Guide*  
*Updated: October 28, 2025*  
*Ready for comprehensive app testing!*

