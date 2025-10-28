# TestFlight Deployment Guide for Field of Truth Apps

## Current Status

✅ **All 5 apps build successfully** (Simulator builds)  
❌ **TestFlight requires additional setup**

## What's Needed for TestFlight

### 1. App Store Connect Setup (Required First)

Before you can archive and upload, you must:

1. **Go to [App Store Connect](https://appstoreconnect.apple.com/)**
2. **Create 5 new apps** (one for each):
   - Personal Health (com.fot.PersonalHealth)
   - Clinician (com.fot.ClinicianApp)
   - Parent (com.fot.ParentApp)
   - Education (com.fot.EducationApp)
   - Legal (com.fot.LegalApp)

3. **For each app, fill in**:
   - App Name
   - Primary Language
   - Bundle ID (use the ones listed above)
   - SKU (can be same as bundle ID)

### 2. Provisioning Profiles (Automatic or Manual)

**Option A: Automatic (Recommended)**
- Xcode will create profiles automatically
- Requires `-allowProvisioningUpdates` flag
- May require registering a device first

**Option B: Manual**
- Create App Store Distribution profiles in Apple Developer Portal
- Download and install them locally
- Configure in Xcode project settings

### 3. Current Error

```
error: Your team has no devices from which to generate a provisioning profile
```

**Solution**: For TestFlight distribution, we need to:
1. Use "App Store" distribution method (not "Development")
2. Or register at least one test device in Apple Developer Portal

### 4. Two Deployment Approaches

#### Approach A: Xcode GUI (Easiest)
1. Open project in Xcode
2. Select "Any iOS Device (arm64)" as destination
3. Product → Archive
4. Organizer → Distribute App → TestFlight & App Store
5. Follow prompts to upload

#### Approach B: Command Line (Automated)
```bash
# 1. Archive
xcodebuild archive \
  -project PersonalHealthApp.xcodeproj \
  -scheme PersonalHealthApp \
  -configuration Release \
  -archivePath PersonalHealthApp.xcarchive \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="WWQQB728U5"

# 2. Export
xcodebuild -exportArchive \
  -archivePath PersonalHealthApp.xcarchive \
  -exportPath ./export \
  -exportOptionsPlist ExportOptions.plist

# 3. Upload  
xcrun altool --upload-app \
  --type ios \
  --file export/PersonalHealthApp.ipa \
  --apiKey YOUR_KEY \
  --apiIssuer YOUR_ISSUER
```

### 5. Recommended Next Steps

1. **Create App Store Connect API Key** (for automated uploads):
   - App Store Connect → Users and Access → Keys
   - Generate new API key with "App Manager" role
   - Download key file (only available once!)
   - Note: Key ID and Issuer ID

2. **Register Test Device** (for development testing):
   - Apple Developer → Certificates, IDs & Profiles → Devices
   - Add your iPhone/iPad UDID
   - This enables Development signing

3. **Set Up Apps in App Store Connect**:
   - Go through wizard for each of 5 apps
   - This creates the bundle IDs and app records

4. **Use Xcode GUI for First Upload**:
   - Easier to troubleshoot
   - Handles certificate/profile creation
   - After first success, can automate

## Quick Start Command

```bash
# After App Store Connect setup, run this:
cd /Users/richardgillespie/Documents/FoTApple
./scripts/deploy_testflight.sh
```

## Troubleshooting

### "No profiles found"
- Create apps in App Store Connect first
- Or use manual provisioning profiles

### "No devices"
- Register a test device, or
- Use App Store distribution (for TestFlight)

### "Communication with Apple failed"
- Check internet connection
- Verify Team ID is correct (WWQQB728U5)
- Ensure Apple Developer account is active

## Current Bundle IDs

All apps use `com.fot.*` prefix:
- ✅ com.fot.PersonalHealth
- ✅ com.fot.ClinicianApp  
- ✅ com.fot.ParentApp
- ✅ com.fot.EducationApp
- ✅ com.fot.LegalApp

## Next Action

**You need to**:
1. Go to App Store Connect
2. Create the 5 apps with these bundle IDs
3. Then we can archive and upload

Or alternatively:
1. Open one app in Xcode
2. Use Archive + Distribute workflow
3. Let Xcode handle the setup automatically

