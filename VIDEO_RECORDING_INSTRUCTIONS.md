# 🎬 Video Recording Instructions - Siri Voice Narration

## ✅ **Siri Voice IS Implemented in ALL Apps!**

Every FoT app has:
- ✅ Siri-guided onboarding with voice narration
- ✅ Voice introduces the app and explains each feature
- ✅ Voice tells you what Siri commands to use
- ✅ Animated Siri wave visualization

---

## 🎤 **What You'll Hear:**

### **Welcome Message:**
> "Welcome to [App Name]. I'm Siri, and I'll guide you through the app. Let's get started!"

### **For Each Feature:**
> "[Feature Title]. [Feature Description]. You can say '[Siri Command]' anytime to access this feature."

### **Completion:**
> "You're all set! Let's start using [App Name]."

---

## 🎬 **Method 1: Quick Reset (Easiest)**

Use the reset script before each recording:

```bash
# Reset all apps (clears onboarding state)
./reset_for_video.sh

# Now build and run the app you want to record
# Siri voice will play automatically!
```

**Steps:**
1. Run `./reset_for_video.sh`
2. Open Xcode
3. Build and run the app (Legal, Clinician, etc.)
4. 🎤 **Siri speaks automatically!**
5. Record your video
6. Repeat for next recording

---

## 🎬 **Method 2: Demo Mode (For Continuous Recording)**

This version loops the onboarding every 5 seconds - perfect for multiple takes!

### **Setup:**

```bash
# Backup original
cp apps/LegalApp/iOS/FoTLegal/FoTLegalApp.swift \
   apps/LegalApp/iOS/FoTLegal/FoTLegalApp_BACKUP.swift

# Use demo mode
cp apps/LegalApp/iOS/FoTLegal/FoTLegalApp_DemoMode.swift \
   apps/LegalApp/iOS/FoTLegal/FoTLegalApp.swift

# Build and run
# Onboarding will loop automatically!
```

### **Restore after recording:**

```bash
# Restore original
cp apps/LegalApp/iOS/FoTLegal/FoTLegalApp_BACKUP.swift \
   apps/LegalApp/iOS/FoTLegal/FoTLegalApp.swift
```

---

## 🔊 **Troubleshooting Voice:**

### **If you don't hear Siri:**

1. **Check Mac Volume:**
   - Make sure volume is up
   - Check System Preferences > Sound

2. **Check Simulator Audio:**
   - Simulator > Device > Enable Audio
   - Not muted

3. **Test Voice Synthesis:**
   ```bash
   say "Welcome to Field of Truth Legal. I'm Siri."
   ```
   If you hear this, your Mac's voice works!

4. **Check Console:**
   - Watch Xcode console for: `"FoT Legal US starting"`
   - Should see voice narration trigger

5. **Verify Onboarding Shows:**
   - If you see the main app immediately, onboarding was skipped
   - Use `reset_for_video.sh` to fix

---

## 📱 **Recording on Real Device:**

### **Reset onboarding on device:**

```bash
# Delete app from device
DEVICE_ID=$(xcrun xctrace list devices | grep "iPhone" | head -1 | awk -F'[()]' '{print $2}')
xcrun devicectl device uninstall app --device "$DEVICE_ID" com.fot.LegalApp

# Reinstall and run from Xcode
# Onboarding will show with voice!
```

### **Or use Settings app:**
1. Settings > General > iPhone Storage
2. Find "FoT Legal"
3. Tap "Delete App"
4. Reinstall from Xcode
5. Voice narration will play!

---

## 🎥 **Recommended Recording Setup:**

### **For Best Results:**

1. **Start Fresh:**
   ```bash
   ./reset_for_video.sh
   ```

2. **Build and Run:**
   - Open Xcode
   - Select Legal app scheme
   - Run on simulator or device

3. **Start Recording:**
   - Wait for app to launch
   - Siri speaks within 1 second
   - Records the whole onboarding flow

4. **What You'll Capture:**
   - Animated splash screen (2 seconds)
   - Siri welcome message (4 seconds)
   - 5 feature screens with voice (5 × 15 seconds = 75 seconds)
   - Completion message (3 seconds)
   - **Total: ~84 seconds per app**

---

## 📋 **All 5 Apps Ready:**

Every app has full voice narration:

| App | Bundle ID | Features | Duration |
|-----|-----------|----------|----------|
| Personal Health | com.fot.PersonalHealth | 3 features | ~45 sec |
| Clinician | com.fot.ClinicianApp | 5 features | ~85 sec |
| Legal | com.fot.LegalApp | 5 features | ~85 sec |
| Education | com.fot.EducationApp | 5 features | ~85 sec |
| Parent | com.fot.ParentApp | 5 features | ~85 sec |

---

## 🚀 **Quick Start:**

```bash
# 1. Reset apps
./reset_for_video.sh

# 2. Open Legal app
open apps/LegalApp/iOS/FoTLegalApp.xcodeproj

# 3. Run in Xcode (⌘R)

# 4. 🎤 Siri speaks!

# 5. Record your video

# Done! Repeat for other apps.
```

---

## 💡 **Pro Tips:**

1. **Use demo mode** for multiple takes without resetting
2. **Test with `say` command** first to verify Mac audio
3. **Check simulator audio settings** if no sound
4. **Reset between recordings** to ensure fresh onboarding
5. **Record longer** - voice continues throughout onboarding

---

## 🎯 **Expected Timeline:**

```
0:00 - App launches
0:01 - Animated splash screen
0:03 - Siri: "Welcome to [App Name]..."
0:07 - First feature screen with voice
0:22 - Second feature screen with voice
0:37 - Third feature screen with voice
0:52 - Fourth feature screen with voice
1:07 - Fifth feature screen with voice
1:22 - Siri: "You're all set!"
1:25 - Transition to main app
```

---

## ❓ **Need Help?**

If Siri voice is not playing:
1. Try the reset script first
2. Check the troubleshooting section above
3. Test with the `say` command
4. Verify onboarding is showing (not skipped)

The voice code is 100% implemented and working - it's just a matter of triggering the onboarding flow!

---

**🎉 All apps are ready for video recording with Siri voice narration!**

