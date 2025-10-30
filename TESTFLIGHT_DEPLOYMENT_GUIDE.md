# 🚀 TestFlight Deployment Guide

## Quick Start - Deploy All Apps

I've created a comprehensive deployment script that will build, archive, and upload all 5 apps to TestFlight automatically!

---

## ⚡ One-Command Deployment

```bash
cd /Users/richardgillespie/Documents/FoTApple
chmod +x deploy_all_testflight.sh
./deploy_all_testflight.sh
```

**That's it!** The script will:
1. ✅ Build all 5 apps
2. ✅ Increment build numbers
3. ✅ Create archives
4. ✅ Export for App Store
5. ✅ Validate each app
6. ✅ Upload to TestFlight
7. ✅ Show you a summary

**Time Required**: ~30-45 minutes for all 5 apps

---

## 📋 Prerequisites

Before running the script, ensure you have:

### 1. **App Store Connect API Key** ✅
- Already found: `AuthKey_43BGN9JC5B.p8`
- Location: `/Users/richardgillespie/Documents/FoTApple/`

### 2. **Update API Issuer ID**

⚠️ **IMPORTANT**: You need to update your API Issuer ID in the script!

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click your name → **Keys** (under Users and Access)
3. Copy your **Issuer ID**
4. Edit `deploy_all_testflight.sh` line 23:
   ```bash
   API_ISSUER_ID="YOUR-ISSUER-ID-HERE"  # Replace this!
   ```

### 3. **Code Signing**
- Team ID: `Y428L3AX98` (already configured)
- Using Automatic signing
- Ensure provisioning profiles are up to date

### 4. **Xcode**
- Version 15+ recommended
- Command line tools installed:
  ```bash
  xcode-select --install
  ```

---

## 🎯 What The Script Does

### For Each App:

#### Step 1: Increment Build Number
- Automatically bumps CFBundleVersion
- Keeps track in Info.plist
- Ensures uniqueness for App Store

#### Step 2: Archive
- Cleans previous builds
- Creates Release configuration
- Generates .xcarchive file
- Saves to `build/archives/`

#### Step 3: Export
- Creates ExportOptions.plist
- Exports for App Store distribution
- Generates .ipa file
- Saves to `build/exports/`

#### Step 4: Validate
- Checks code signing
- Validates entitlements
- Verifies App Store requirements
- Logs any warnings

#### Step 5: Upload
- Uploads to App Store Connect
- Uses API authentication
- Shows upload progress
- Confirms success

---

## 📱 Apps Being Deployed

1. **Personal Health** - Personal health monitoring
2. **Clinician** - Clinical decision support (94.2% USMLE accuracy)
3. **Legal** - Legal practice management
4. **Education** - K-18 education platform
5. **Parent** - Parenting and family management

All apps now include:
- ✅ Beautiful animated splash screens
- ✅ Siri-guided onboarding
- ✅ 69+ voice commands
- ✅ Interactive help system

---

## 🔍 Monitoring Progress

### Watch in Real-Time

The script shows:
- Current step for each app
- Build progress
- Export status
- Upload confirmation
- Summary at the end

### Check Logs

If something fails, check:
```bash
# View recent logs
ls -lth build/logs/

# Read specific app log
cat build/logs/PersonalHealth_archive.log
cat build/logs/Clinician_export.log
cat build/logs/Legal_upload.log
```

---

## ✅ After Successful Upload

### 1. **Wait for Processing** (10-15 min per app)

Go to [App Store Connect](https://appstoreconnect.apple.com):
- My Apps → [App Name] → TestFlight
- Watch for "Processing" → "Ready to Test"

### 2. **Add Beta Testers**

#### Internal Testing (Fast)
- Add up to 100 internal testers
- No review required
- Instant access after processing

#### External Testing (Requires Review)
- Add up to 10,000 external testers
- Requires beta app review (~24 hours)
- Fill out "What to Test" form

### 3. **Submit for Beta Review**

For external testers:
1. Click "Submit for Review"
2. Fill in test information
3. Export compliance: "No" (unless crypto)
4. Wait for approval (~24 hours)

### 4. **Send Invites**

Once approved:
1. Select test group
2. Click "Add Testers"
3. Enter email addresses
4. TestFlight invites sent automatically

---

## 🔧 Troubleshooting

### Common Issues

#### 1. **"No such file or directory" Error**
```bash
# Verify you're in the right directory
cd /Users/richardgillespie/Documents/FoTApple
pwd  # Should show FoTApple directory
```

#### 2. **Code Signing Failed**
```bash
# Check your Apple Developer account
open "https://developer.apple.com/account/"

# Verify certificates and profiles
# Settings → Your Name → Developer → Manage Certificates
```

#### 3. **Build Failed for Specific App**
```bash
# Build manually to see detailed errors
cd apps/PersonalHealthApp/iOS
xcodebuild -project PersonalHealthApp.xcodeproj \
  -scheme PersonalHealthApp \
  -configuration Release \
  clean build
```

#### 4. **Upload Timeout**
- Check internet connection
- Script will retry automatically
- Or upload manually via Xcode Organizer

#### 5. **API Authentication Failed**
- Verify API Key is in correct location
- Check API Issuer ID is correct
- Ensure API Key has "Admin" or "Developer" role

---

## 🎨 Manual Upload (If Script Fails)

### Using Xcode Organizer

1. **Open Xcode**
2. **Window → Organizer** (Cmd+Shift+Option+O)
3. Select your archive
4. Click **Distribute App**
5. Choose **App Store Connect**
6. Select **Upload**
7. Follow wizard
8. Repeat for each app

---

## 📊 Deployment Checklist

### Before Running Script
- [ ] API Issuer ID updated in script
- [ ] API Key file exists
- [ ] Xcode command line tools installed
- [ ] Logged into Xcode with Apple ID
- [ ] Internet connection stable
- [ ] All apps build successfully locally

### After Upload
- [ ] Check App Store Connect for processing
- [ ] Wait for "Ready to Test" status
- [ ] Add internal testers
- [ ] Test on real devices
- [ ] Submit for external beta review
- [ ] Add external testers
- [ ] Collect feedback
- [ ] Iterate based on usage

---

## 🎯 What Testers Will See

### 1. **TestFlight Invitation Email**
- Link to install TestFlight app
- Your app icon and description
- "Start Testing" button

### 2. **Beautiful First Launch**
- Animated splash screen (3 seconds)
- Siri greets them: "Welcome to [App]..."
- Siri explains 5 key features with voice
- Smooth transition to app

### 3. **Ongoing Experience**
- 69+ Siri voice commands work
- Interactive help always available
- Tooltips guide them
- Professional, polished UX

### 4. **Send Feedback**
- TestFlight app has built-in feedback
- Screenshot annotation
- Crash reports automatically sent
- Direct communication channel

---

## 📝 Release Notes Template

When submitting to TestFlight, use this for "What to Test":

```
New in This Build:

✨ MAJOR UX UPGRADE ✨

🎙️ Siri Integration
- 69+ voice commands across all apps
- "Log my mood in Personal Health"
- "Generate diagnosis in Clinician"
- "Search case law in Legal"
- "Show my students in Education"
- "Log milestone in Parent"

✨ Beautiful Onboarding
- Siri-guided feature tour with voice narration
- Animated splash screens
- Smooth, professional experience

💡 Interactive Help
- Smart tooltips guide you
- Searchable help system
- Never get lost

🔧 What to Test:
1. Complete onboarding flow (first launch)
2. Try Siri voice commands
3. Use help screens
4. General functionality
5. Report any issues via TestFlight feedback

Known Issues:
- None currently

Privacy Note:
All health/legal/education data stored locally on your device. 
Optional QFOT blockchain sharing requires explicit opt-in.
```

---

## 🚀 Advanced Options

### Deploy Single App

Edit `deploy_all_testflight.sh` to comment out apps you don't want:

```bash
declare -A APPS=(
    ["PersonalHealth"]="apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj:PersonalHealthApp"
    # ["Clinician"]="apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj:FoTClinicianApp"  # Skip
    # ["Legal"]="apps/LegalApp/iOS/FoTLegalApp.xcodeproj:FoTLegalApp"  # Skip
    # ["Education"]="apps/EducationApp/iOS/FoTEducationApp.xcodeproj:FoTEducationApp"  # Skip
    # ["Parent"]="apps/ParentApp/iOS/FoTParentApp.xcodeproj:FoTParentApp"  # Skip
)
```

### Dry Run (Archive Only)

Comment out upload section to test archiving without uploading:

```bash
# Step 5: Upload
# if upload_to_testflight "$app_name"; then
#     successful_uploads+=("$app_name")
# else
#     failed_uploads+=("$app_name")
# fi
```

### Custom Build Configuration

Edit archive commands to use different configurations:

```bash
-configuration Debug  # For testing
-configuration Release  # For production (default)
```

---

## 📞 App Store Connect Links

Quick access:
- **Main Dashboard**: https://appstoreconnect.apple.com
- **TestFlight**: https://appstoreconnect.apple.com/apps/testflight
- **Users & Access**: https://appstoreconnect.apple.com/access/users
- **API Keys**: https://appstoreconnect.apple.com/access/api

---

## 🎉 Success Indicators

You'll know it worked when:

1. ✅ Script shows "All apps uploaded successfully! 🎉"
2. ✅ App Store Connect shows 5 new builds processing
3. ✅ Email confirmation from Apple
4. ✅ "Ready to Test" status appears (after processing)
5. ✅ Testers can install and test

---

## 🔄 Next Deployment

For future updates:

1. Make your code changes
2. Test locally
3. Run the same script:
   ```bash
   ./deploy_all_testflight.sh
   ```
4. Build numbers auto-increment
5. New builds appear in TestFlight

---

## 💡 Pro Tips

1. **Internal Testing First**
   - Test with internal testers before external review
   - Catch issues early
   - Faster iteration

2. **Staggered Rollout**
   - Deploy one app at a time to test the script
   - Once confident, deploy all 5

3. **Version Management**
   - Keep marketing version (1.0, 1.1, 2.0) in Xcode
   - Let script auto-increment build numbers (1, 2, 3...)

4. **Backup Archives**
   - Archives saved in `build/archives/`
   - Keep them for debugging
   - Can re-export without rebuilding

5. **Monitor Crashes**
   - Check TestFlight crash reports
   - Organizer shows symbolicated crashes
   - Fix before App Store release

---

## 🎯 Timeline

### Today (Now)
- Run deployment script: **30-45 min**

### Today (1-2 hours later)
- Apps finish processing: **10-15 min per app**
- Add internal testers: **5 min**
- Internal testers can start testing: **Immediate**

### Tomorrow (24 hours)
- Submit for external beta review: **5 min**
- Beta review approval: **~24 hours**

### Day 3
- Add external testers: **5 min**
- Collect feedback: **Ongoing**

### Week 2
- Iterate based on feedback
- Deploy updates
- Prepare for App Store submission

---

## ✅ Ready to Deploy?

Run this now:

```bash
cd /Users/richardgillespie/Documents/FoTApple

# Make script executable
chmod +x deploy_all_testflight.sh

# Update API Issuer ID in the script first!
nano deploy_all_testflight.sh
# (Edit line 23, save with Ctrl+X)

# Deploy!
./deploy_all_testflight.sh
```

**Grab a coffee ☕ and watch the magic happen!**

The script will handle everything automatically and show you a nice summary at the end.

---

## 🆘 Need Help?

If something goes wrong:

1. **Check the logs**: `ls -lth build/logs/`
2. **Read the error**: Most errors are self-explanatory
3. **Common fixes**: See Troubleshooting section above
4. **Manual upload**: Use Xcode Organizer as fallback

---

**Your apps are ready to ship to TestFlight!** 🚀

*This deployment includes all the new UX enhancements: beautiful splash screens, Siri-guided onboarding, 69+ voice commands, and interactive help system.*

