# Privacy Policy Information for Field of Truth Apps

## Quick Setup Guide

### Option 1: Use Existing Privacy Policy URL
If you have a privacy policy URL already:
- Add it to each app in App Store Connect → App Privacy → Privacy Policy URL

### Option 2: Create Privacy Policy Page

**Recommended URL structure:**
```
https://fieldoftruth.com/privacy-policy
```

**Or app-specific:**
```
https://fieldoftruth.com/apps/personalhealth/privacy
https://fieldoftruth.com/apps/clinician/privacy
https://fieldoftruth.com/apps/education/privacy
https://fieldoftruth.com/apps/parent/privacy
https://fieldoftruth.com/apps/legal/privacy
```

### Required Privacy Policy Content (Apple Requirements):

At minimum, your privacy policy must state:
1. What data the app collects
2. How the data is used
3. How the data is shared (if at all)
4. How users can request deletion of their data
5. Contact information for privacy questions

### Quick Privacy Policy Template:

```
Privacy Policy for Field of Truth Apps

Effective Date: [Date]

1. Data Collection
   - [App] collects [list of data types]
   - Data is stored locally on your device
   - No data is transmitted to external servers

2. Data Usage
   - Data is used solely for app functionality
   - Used to provide [app-specific features]

3. Data Sharing
   - We do not share your data with third parties
   - Data remains on your device

4. Data Deletion
   - Users can delete all data via app settings
   - Uninstalling the app removes all local data

5. Contact
   - Privacy questions: privacy@fieldoftruth.com
```

### To Add Privacy Policy URL in App Store Connect:

For each app:
1. Go to https://appstoreconnect.apple.com/apps
2. Select your app
3. Click "App Privacy" in left sidebar
4. Click "Edit" on Privacy Policy URL field
5. Enter your privacy policy URL
6. Click "Save"

---

## Age Rating Requirements

Each app needs age rating with content descriptions.

### Recommended Settings:

**Medical Apps (PersonalHealthApp, ClinicianApp):**
- Medical/Treatment Information: Frequent/Intense
- All other content: None
- **Result**: Likely 4+ or 12+ (Apple will determine)

**Education Apps:**
- All content: None (unless specific content warrants)
- **Result**: 4+

**Legal App:**
- All content: None
- **Result**: 4+

### To Set Age Rating:

1. Go to App Store Connect → Your App
2. Click "App Information"
3. Scroll to "Age Rating"
4. Click "Edit"
5. Answer all content questions
6. Apple will assign age rating automatically
7. Click "Save"

---

## Primary Category Selection

### For Each App:

1. Go to App Store Connect → Your App
2. Click "App Information"
3. Find "Primary Category"
4. Select appropriate category:
   - **PersonalHealthApp**: Medical
   - **ClinicianApp**: Medical
   - **EducationApp**: Education
   - **ParentApp**: Education
   - **LegalApp**: Reference

---

## Screenshot Requirements

**Required for iOS apps:**

1. **iPhone 6.5"** (iPhone 14 Pro Max): 1284 x 2778 pixels
2. **iPad 13"** (iPad Pro 12.9"): 2048 x 2732 pixels

**To generate:**
```bash
./scripts/generate_app_store_screenshots.sh
```

**Or manually:**
1. Run app in appropriate simulator
2. Take screenshots (Cmd+S)
3. Upload to App Store Connect → App Store → Screenshots

---

## Complete Checklist

For each app, ensure:
- [ ] Screenshots uploaded (iPhone 6.5" and iPad 13")
- [ ] Primary category selected
- [ ] Privacy Policy URL entered
- [ ] Age Rating completed (all questions answered)
- [ ] App description written
- [ ] Keywords added
- [ ] App icon uploaded (already done ✅)
- [ ] Support URL added (optional but recommended)

