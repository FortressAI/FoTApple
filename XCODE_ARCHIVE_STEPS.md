# Xcode Archive to TestFlight - Step by Step

Xcode is now open with PersonalHealthApp. Follow these steps:

## Step-by-Step Archive Process

### 1. Select Destination
- At the top of Xcode window, click the device/simulator selector
- Choose **"Any iOS Device (arm64)"** from the dropdown
- This enables the Archive option

### 2. Start Archive
- Menu: **Product → Archive**
- Or keyboard shortcut: **⌘⇧B** (Cmd + Shift + B)
- Status bar will show "Archiving PersonalHealthApp..."
- Wait ~2-3 minutes for completion

### 3. Organizer Opens Automatically
- When archive completes, the Organizer window appears
- You'll see your archive listed with date/time
- Click **"Distribute App"** button on the right

### 4. Distribution Method
- Select **"TestFlight & App Store"**
- Click **Next**

### 5. Distribution Options
- Select **"Upload"** (not Export)
- Click **Next**

### 6. App Store Connect Options
- **Automatically manage signing** ✓ (recommended)
- Click **Next**
- Xcode will:
  - Create App Store Connect app record
  - Generate distribution certificate
  - Create provisioning profile

### 7. Review and Upload
- Review the app details
- Click **Upload**
- Wait 2-5 minutes for upload
- Status shows "Upload Successful" ✓

### 8. Verification
- Go to https://appstoreconnect.apple.com/
- Click "My Apps"
- You should see "Personal Health Monitor"
- Click TestFlight tab
- Build will show "Processing" for 5-15 minutes
- When ready, status changes to "Ready to Test"

## After First Success

Once PersonalHealthApp uploads successfully:

### Deploy Remaining 4 Apps via CLI
```bash
# Update script to do all 4 remaining apps
cd /Users/richardgillespie/Documents/FoTApple

# Clinician
./scripts/testflight_cli.sh  # Edit to change APP_NAME

# Or use Xcode for each:
open apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj
open apps/ParentApp/iOS/FoTParentApp.xcodeproj
open apps/EducationApp/iOS/FoTEducationApp.xcodeproj
open apps/LegalApp/iOS/FoTLegalApp.xcodeproj
```

## Troubleshooting

### "No code signing identities found"
- Xcode → Settings → Accounts
- Click your Apple ID
- Click "Download Manual Profiles"

### "Failed to create provisioning profile"
- Make sure you're logged in: Xcode → Settings → Accounts
- Verify Team ID is correct (WWQQB728U5)

### "Archive option is grayed out"
- Make sure "Any iOS Device" is selected (not a simulator)
- Try Product → Clean Build Folder first

### "Upload Failed"
- Check internet connection
- Verify Apple Developer account is active
- Try again (sometimes Apple servers are busy)

## Success Indicators

✅ Archive completes without errors  
✅ Organizer shows your archive  
✅ Upload shows "Upload Successful"  
✅ App appears in App Store Connect  

## Next Steps After All Apps Upload

1. **Add Beta Testers** in App Store Connect
2. **Write Test Instructions** for testers
3. **Monitor Crashes** in TestFlight dashboard
4. **Collect Feedback** from beta testers
5. **Iterate** and upload new builds via CLI

---

**Current Status:** PersonalHealthApp opened in Xcode  
**Next Action:** Archive → Distribute → Upload  
**Time Estimate:** 10 minutes total

