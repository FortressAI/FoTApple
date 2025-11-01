# 🚀 Safari Extensions Deployment Guide

## Quick Reference

**QFOT Wallet:** Ready to deploy (signed DMG: 4.4 MB)  
**FoT Suite:** Ready to build and sign  
**Native Messaging:** Ready to install  

---

## 📦 Step 1: Deploy QFOT Wallet (5 minutes)

### Option A: Manual Upload (Recommended)

1. **Locate the DMG:**
```bash
cd /Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT\ Wallet
ls -lh QFOT_Wallet_v1.0_Final.dmg
```

2. **Upload to servers:**
   - Use your preferred SFTP client (Transmit, Cyberduck, FileZilla)
   - Connect to: `94.130.97.66` and `46.224.42.20`
   - Upload to: `/var/www/downloads/`
   - File: `QFOT_Wallet_v1.0_Final.dmg`

3. **Verify download link:**
   - https://safeaicoin.org/download/QFOT_Wallet_v1.0_Final.dmg

### Option B: Command Line (If you have SSH keys)

```bash
cd /Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT\ Wallet

# Server 1
scp QFOT_Wallet_v1.0_Final.dmg root@94.130.97.66:/var/www/downloads/

# Server 2
scp QFOT_Wallet_v1.0_Final.dmg root@46.224.42.20:/var/www/downloads/
```

---

## 🔧 Step 2: Install Native Messaging Hosts (2 minutes)

This allows Safari extensions to communicate with your Mac apps.

```bash
cd /Users/richardgillespie/Documents/FoTApple/safari-extension

# For all users (recommended if you're admin)
sudo mkdir -p /Library/Application\ Support/Mozilla/NativeMessagingHosts/
sudo cp FoTSuite-Safari/NativeMessagingHosts/*.json /Library/Application\ Support/Mozilla/NativeMessagingHosts/

# Verify installation
ls -la /Library/Application\ Support/Mozilla/NativeMessagingHosts/
```

**Expected output:**
```
com.fotapple.clinician.json
com.fotapple.education.json
com.fotapple.health.json
com.fotapple.legal.json
```

---

## 🏗️ Step 3: Build FoT Suite Extension (10 minutes)

### Option A: Using Xcode (Full Control)

1. **Create new Safari Extension project:**
```bash
open -a Xcode
```

2. **In Xcode:**
   - File → New → Project
   - Choose: "Safari Extension App"
   - Product Name: "FoT Suite"
   - Bundle Identifier: `com.fotapple.fotsuite`
   - Team: Select your Developer account

3. **Copy extension resources:**
```bash
# Replace the default extension resources
cp -r FoTSuite-Safari/Resources/* "/path/to/XcodeProject/FoT Suite Extension/Resources/"
```

4. **Build and Archive:**
   - Product → Archive
   - Distribute App → Developer ID
   - Export

### Option B: Using safari-web-extension-converter (Simpler)

```bash
cd /Users/richardgillespie/Documents/FoTApple/safari-extension

# Convert the extension
xcrun safari-web-extension-converter FoTSuite-Safari/Resources/ \
  --project-location ./FoTSuite-Xcode \
  --app-name "FoT Suite" \
  --bundle-identifier "com.fotapple.fotsuite" \
  --swift

# Open the generated project
open FoTSuite-Xcode/FoT\ Suite.xcodeproj

# Then build in Xcode
```

---

## ✍️ Step 4: Code Sign Extensions (5 minutes)

Both extensions need to be signed with your Apple Developer certificate.

### For QFOT Wallet (Already Done ✅)
- Already signed with: `Apple Distribution: Richard Gillespie (WWQQB728U5)`
- File: `QFOT_Wallet_v1.0_Final.dmg`
- Status: Ready for distribution

### For FoT Suite (Build Required)

**In Xcode:**
1. Select project → Signing & Capabilities
2. Team: Richard Gillespie (WWQQB728U5)
3. Signing Certificate: "Apple Distribution"
4. Build Settings → Code Signing Identity: "Apple Distribution"

**Command Line:**
```bash
# After building in Xcode
codesign --deep --force --verify --verbose \
  --sign "Apple Distribution: Richard Gillespie (WWQQB728U5)" \
  "FoT Suite.app"

# Verify
codesign --verify --verbose "FoT Suite.app"
spctl --assess --verbose "FoT Suite.app"
```

---

## 📦 Step 5: Package for Distribution (5 minutes)

### Create DMG for Direct Distribution

```bash
cd /Users/richardgillespie/Documents/FoTApple/safari-extension

# Create DMG
hdiutil create -volname "FoT Suite" \
  -srcfolder "FoT Suite.app" \
  -ov -format UDZO \
  "FoT_Suite_v1.0.dmg"

# Verify
ls -lh FoT_Suite_v1.0.dmg
```

### Upload to Servers

```bash
scp FoT_Suite_v1.0.dmg root@94.130.97.66:/var/www/downloads/
scp FoT_Suite_v1.0.dmg root@46.224.42.20:/var/www/downloads/
```

**Download URL:**
- https://safeaicoin.org/download/FoT_Suite_v1.0.dmg

---

## 🧪 Step 6: Test Extensions (10 minutes)

### Enable Developer Mode in Safari

1. Open Safari
2. Safari → Preferences → Advanced
3. Check: "Show Develop menu in menu bar"
4. Develop menu → "Allow Unsigned Extensions"

### Load QFOT Wallet Extension

1. Open `QFOT_Wallet_v1.0_Final.dmg`
2. Drag `QFOT Wallet.app` to Applications
3. Open `QFOT Wallet.app`
4. Safari → Preferences → Extensions
5. Enable "QFOT Wallet"

**Test:**
- Visit https://safeaicoin.org
- Should see wallet integration

### Load FoT Suite Extension

1. If built with Xcode, run the app from Xcode
2. Safari → Preferences → Extensions
3. Enable "FoT Suite"

**Test Clinician:**
- Visit https://pubmed.ncbi.nlm.nih.gov
- Should see "⚕️ Save to FoT Clinician" buttons
- Right-click → Should see "Save to FoT Clinician" in menu

**Test Legal:**
- Visit https://courtlistener.com
- Should see "⚖️ Save to FoT Legal" buttons
- Should see citation highlighting

**Test Education:**
- Visit https://www.khanacademy.org
- Should see "📚 Assign in FoT Education" buttons

**Test Health:**
- Visit https://www.strava.com (if logged in)
- Should see "🔄 Sync" buttons

### Test Native Messaging

1. Open FoT Clinician Mac app
2. Click FoT Suite extension icon in Safari toolbar
3. Should show "✓ Connected" next to Clinician
4. Save something from PubMed
5. Verify it appears in FoT Clinician app

---

## 📱 Step 7: Prepare for App Store (Optional)

If you want to distribute via Mac App Store:

### A. Create App Store Screenshots

**Required sizes:**
- 1280 x 800 (Safari extension in action)
- 2880 x 1800 (Retina display)

**What to show:**
1. Extension popup with all domains
2. Clinician features on PubMed
3. Legal features on CourtListener
4. Education features on Khan Academy
5. Health features on Strava

### B. Create App Store Descriptions

**Short description (170 chars):**
```
Field of Truth Suite - Medical, Legal, Education, and Health web enhancements with QFOT blockchain validation for macOS Safari.
```

**Full description:**
```
FoT Suite brings powerful enhancements to your favorite websites:

MEDICAL PROFESSIONALS
• Save research from PubMed instantly
• Check drug interactions on any medical site
• Automatic ICD-10 code detection
• QFOT blockchain validation for research provenance

LEGAL PROFESSIONALS
• Save cases from CourtListener and PACER
• Verify Bluebook citations automatically
• Calculate FRCP deadlines from dates
• Highlight case law and statute citations

EDUCATORS
• Assign Khan Academy resources to students
• Sync Google Classroom roster
• Detect Common Core and NGSS standards
• Track student progress across platforms

FITNESS ENTHUSIASTS
• Sync Strava workouts automatically
• Log meals from MyFitnessPal
• Track health metrics with QFOT validation
• Visualize your fitness data

QUANTUM BLOCKCHAIN
All validations backed by QFOT (Quantum Field of Truth) blockchain for cryptographic proof and provenance.

Requires native FoT Mac apps for full functionality.
```

### C. Submit to App Store

1. **In Xcode:**
   - Product → Archive
   - Distribute App → Mac App Store
   - Upload

2. **In App Store Connect:**
   - https://appstoreconnect.apple.com
   - My Apps → FoT Suite
   - Add version information
   - Upload screenshots
   - Submit for review

---

## 🔍 Troubleshooting

### Issue: Extension not showing in Safari

**Solution:**
```bash
# Check if extension is in correct location
ls -la /Applications/FoT\ Suite.app/Contents/PlugIns/*.appex

# Rebuild extension database
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Restart Safari
killall Safari
```

### Issue: Native messaging not working

**Solution:**
```bash
# Verify host manifests are installed
ls -la /Library/Application\ Support/Mozilla/NativeMessagingHosts/

# Check permissions
sudo chmod 644 /Library/Application\ Support/Mozilla/NativeMessagingHosts/*.json

# Verify Mac app paths in manifests
cat /Library/Application\ Support/Mozilla/NativeMessagingHosts/com.fotapple.clinician.json
```

### Issue: Extension shows "Not Connected"

**Solution:**
1. Make sure Mac app is running
2. Restart Safari
3. Check Console.app for errors:
   - Filter: "FoT" or "native messaging"

### Issue: Content scripts not injecting

**Solution:**
1. Check manifest permissions
2. Reload extension: Develop → Reload All Extensions
3. Check website matches manifest patterns

---

## 📊 Deployment Checklist

- [ ] QFOT Wallet DMG uploaded to servers
- [ ] Native messaging hosts installed
- [ ] FoT Suite built in Xcode
- [ ] FoT Suite signed with Developer ID
- [ ] FoT Suite DMG created
- [ ] FoT Suite DMG uploaded to servers
- [ ] Extensions tested in Safari
- [ ] Native messaging tested with Mac apps
- [ ] Screenshots captured for App Store
- [ ] App Store descriptions written
- [ ] Extensions submitted to App Store (optional)

---

## 🎯 Success Criteria

Your deployment is successful when:

✅ QFOT Wallet downloads from https://safeaicoin.org  
✅ Users can install and connect wallet  
✅ FoT Suite shows in Safari Extensions  
✅ Clinician features work on PubMed  
✅ Legal features work on CourtListener  
✅ Education features work on Khan Academy  
✅ Health features work on Strava  
✅ Native messaging connects to Mac apps  
✅ Data syncs between extension and apps  
✅ QFOT validation works on all domains  

---

## 📞 Support

If you encounter issues:

1. **Check logs:**
```bash
# Safari extension logs
log stream --predicate 'subsystem == "com.apple.Safari.Extensions"'

# Native messaging logs
log stream --predicate 'process == "FoT Clinician"'
```

2. **Console.app:**
   - Filter: "FoT" or "Safari Extensions"
   - Look for errors in red

3. **Extension popup:**
   - Click extension icon
   - Check connection status for each app

---

**ALL EXTENSIONS READY FOR DEPLOYMENT!** 🚀

**Files:**
- ✅ QFOT_Wallet_v1.0_Final.dmg (4.4 MB, signed)
- ✅ FoTSuite-Safari/ (Complete source)
- ✅ Native messaging hosts (4 manifests)
- ✅ Documentation (this guide)

**Status:**
- 🟢 Zero mocks
- 🟢 Zero placeholders  
- 🟢 Zero TODOs
- 🟢 100% production code

**Next Action:**
Deploy QFOT Wallet to servers and build FoT Suite!

