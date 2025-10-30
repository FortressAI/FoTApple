# 🎬 Record Your First UAT Video - Quick Instructions

## ✅ Setup Complete!

Your environment is ready. Let's record the first critical safety UAT video.

---

## 📋 What You're About to Record

**Test ID:** UAT-CL-004  
**Test Name:** Drug-Drug Interaction Detection  
**App:** FoT Clinician  
**Platform:** iOS  
**Critical to Safety:** ⚠️ **YES**  
**Duration:** ~10-15 minutes  

**What this proves:** Your app correctly detects dangerous drug interactions using the real RxNav API and prevents unsafe prescribing.

---

## 🚀 Quick Start (3 Steps)

### Step 1: Build & Launch the Clinician App (5 min)

```bash
# Navigate to the Clinician app
cd /Users/richardgillespie/Documents/FoTApple/apps/ClinicianApp/iOS

# Open in Xcode
open FoTClinicianApp.xcodeproj

# In Xcode:
# 1. Select iPhone 17 Pro Max simulator (already booted!)
# 2. Product → Build (⌘B)
# 3. Product → Run (⌘R)
# 4. Wait for app to launch in simulator
```

### Step 2: Start Recording (1 min)

```bash
# Open a new terminal window
cd /Users/richardgillespie/Documents/FoTApple/UITests/FunctionalValidation

# Start the recording script
bash record_uat_video.sh UAT-CL-004 Clinician iOS

# The script will:
# ✅ Detect the booted simulator
# ✅ Start network capture
# ✅ Wait for you to press ENTER
# ✅ Start screen recording when you're ready
```

**When prompted, press ENTER to begin recording.**

### Step 3: Perform the Test (10-15 min)

**Open the pilot test procedure (already opened for you):**
```
UAT-CL-004_DrugInteraction_Procedure.md
```

**Follow these 10 steps while speaking aloud:**

1. **Launch app** → Select patient "John Doe" (or create test patient if needed)
2. **Start encounter** → Tap "New Encounter"
3. **Navigate to Medications** → Tap "Medications" tab
4. **Add Warfarin** → Search "Warfarin", select "Warfarin 5mg"
5. **Add Aspirin** → Search "Aspirin", select "Aspirin 81mg"
6. **⚠️ CRITICAL:** Interaction alert should appear!
7. **Verify alert** → Check for "CRITICAL", "bleeding risk", "RxNav"
8. **View alternatives** → Tap "View Alternatives"
9. **Override with justification** → Enter clinical reasoning
10. **View proof bundle** → Verify cryptographic receipt

**Narrate each action as you perform it:**
> "Step 1: Launching FoT Clinician app. Selecting patient John Doe..."
> "Step 5: Adding Aspirin to medication list. This should trigger interaction warning..."
> "Step 6: CRITICAL CHECKPOINT - Drug interaction alert has appeared..."

**When finished, return to terminal and press ENTER to stop recording.**

---

## 📊 What Happens After Recording

The script automatically:
- ✅ Stops screen recording
- ✅ Stops network capture
- ✅ Generates SHA-256 hash of video
- ✅ Creates cryptographic proof bundle
- ✅ Organizes all evidence files

**You'll get:**
```
Evidence/Clinician/UAT-CL-004_[timestamp]/
├── UAT-CL-004_iOS_[timestamp].mov (your video)
├── UAT-CL-004_proof.json (cryptographic proof)
├── Screenshots/ (if captured)
└── NetworkLogs/ (network capture)
```

---

## 🎯 Success Criteria

✅ **Video shows complete workflow** (all 10 steps visible)  
✅ **Drug interaction alert appeared** (CRITICAL)  
✅ **Alert showed severity and mechanism** (bleeding risk)  
✅ **RxNav API attribution visible**  
✅ **Audio narration clear** (you spoke each step)  
✅ **Cryptographic proof generated** (automatic)  

---

## ⚠️ Common Issues & Solutions

### Issue: "Simulator not found"
**Solution:** Run `xcrun simctl list devices` to see available simulators. Edit the script to use your device ID.

### Issue: "App doesn't launch"
**Solution:** Build the app in Xcode first (⌘B then ⌘R)

### Issue: "Network capture fails"
**Solution:** Run with `sudo`:
```bash
sudo bash record_uat_video.sh UAT-CL-004 Clinician iOS
```

### Issue: "No test patient exists"
**Solution:** Create a test patient in the app:
- Name: John Doe
- MRN: 12345
- Current Medication: Warfarin 5mg daily

---

## 📝 Detailed Test Procedure

**For complete step-by-step instructions with expected results, screenshots, and validation checkpoints, see:**

```
UITests/FunctionalValidation/UAT-CL-004_DrugInteraction_Procedure.md
```

(Already opened for you!)

---

## 🎬 Recording Tips

### Before Recording:
- [ ] Close unnecessary windows
- [ ] Turn off notifications
- [ ] Check audio input is working
- [ ] Have test procedure visible on another screen

### During Recording:
- ✅ Speak clearly and describe each action
- ✅ Pause briefly after each critical step
- ✅ If something fails, document it (that's part of validation!)
- ✅ Don't worry about perfection - unedited is required

### After Recording:
- [ ] Watch the video to verify all steps visible
- [ ] Check audio quality
- [ ] Verify cryptographic proof was generated
- [ ] Note any issues for re-recording if needed

---

## 🚀 Ready to Start?

### Terminal 1: Build & run the app
```bash
cd /Users/richardgillespie/Documents/FoTApple/apps/ClinicianApp/iOS
open FoTClinicianApp.xcodeproj
# Build and run in Xcode
```

### Terminal 2: Start recording
```bash
cd /Users/richardgillespie/Documents/FoTApple/UITests/FunctionalValidation
bash record_uat_video.sh UAT-CL-004 Clinician iOS
```

### Follow the test procedure (already open)
```
UAT-CL-004_DrugInteraction_Procedure.md
```

---

## ⏱️ Time Estimate

- **Setup:** 5 minutes (build app)
- **Recording:** 10-15 minutes (perform test)
- **Review:** 5 minutes (watch video)
- **Total:** ~20-25 minutes

---

## 🎉 After Your First Video

Once you complete this first video:

1. **Review the recording** (check quality)
2. **Validate the proof** (check proof.json)
3. **Decide:** Re-record or proceed to next 4 safety videos

**Next 4 safety-critical videos:**
- UAT-CL-005: Allergy alerts
- UAT-CL-009: Contraindication warnings
- UAT-PH-004: Crisis support
- UAT-PH-005: AI triage guidance

---

**You're ready to record your first GxP-compliant UAT video!** 🎬

**Good luck! Remember: Speak clearly, show all steps, and don't worry about perfection.**

