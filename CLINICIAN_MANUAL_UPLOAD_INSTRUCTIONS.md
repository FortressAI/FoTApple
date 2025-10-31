# 📱 CLINICIAN MANUAL UPLOAD - STEP BY STEP

**You're right!** You need `.ipa` files, not `.xcarchive` files for manual upload.

The CLI couldn't export Clinician to IPA because of Watch app provisioning profiles.

---

## ✅ **OPTION 1: XCODE ORGANIZER (EASIEST - 5 MINUTES)**

Xcode Organizer will:
1. Export `.xcarchive` → `.ipa` automatically
2. Handle Watch app provisioning profiles automatically
3. Upload to App Store Connect

### **Steps:**

1. **Open Xcode**
   ```bash
   open -a Xcode
   ```

2. **Open Organizer**
   - Go to: **Window** → **Organizer** (or press `⌘⇧2`)

3. **Select Archives tab**
   - You'll see: `FoTClinicianApp_v13_fixed` (October 31, 2025)

4. **Distribute App**
   - Click **"Distribute App"** button
   - Select **"TestFlight & App Store"**
   - Click **"Next"**

5. **Upload**
   - Select **"Upload"**
   - Click **"Next"**

6. **Automatic Signing**
   - Select **"Automatically manage signing"**
   - Click **"Next"**

7. **Review**
   - Review app info
   - Click **"Upload"**

8. **Wait**
   - Xcode will:
     - Generate Watch app provisioning profile ✅
     - Export to IPA ✅
     - Upload to App Store Connect ✅
   - Takes 2-5 minutes

9. **Done!**
   - You'll see "Upload Successful"
   - Clinician will appear in TestFlight in 5-10 minutes

---

## ⚠️ **OPTION 2: CLI EXPORT WITH APPLE ID (ADVANCED)**

If you want to try CLI one more time with your Apple ID credentials:

```bash
cd /Users/richardgillespie/Documents/FoTApple

# Export (will prompt for Apple ID)
xcodebuild -exportArchive \
  -archivePath "build/archives/FoTClinicianApp_v13_fixed.xcarchive" \
  -exportPath "build/exports/FoTClinicianApp_FINAL_IPA" \
  -exportOptionsPlist "build/exports/PersonalHealthApp_export_options.plist"

# Find IPA
find build/exports/FoTClinicianApp_FINAL_IPA -name "*.ipa"

# Upload
xcrun altool --upload-package build/exports/FoTClinicianApp_FINAL_IPA/*.ipa \
  --type ios \
  --apiKey "706IRVGBDV3B" \
  --apiIssuer "69a6de95-fd71-47e3-e053-5b8c7c11a4d1"
```

**Note:** This will ask for your Apple ID credentials interactively, which is why the automation failed.

---

## 📋 **CURRENT STATUS:**

✅ **Already Live (4 apps):**
- PersonalHealthApp
- FoTLegalApp
- FoTEducationApp
- FoTParentApp

⏳ **Ready to Upload:**
- FoTClinicianApp (archive ready, just needs Xcode Organizer)

---

## 🎯 **RECOMMENDATION:**

**Use Xcode Organizer (Option 1)** - It's the fastest and handles everything automatically.

Archive location: `build/archives/FoTClinicianApp_v13_fixed.xcarchive`

Total time: ~5 minutes

---

**Once Clinician is uploaded, all 5 apps will be live on App Store Connect and ready for TestFlight!** 🎉

