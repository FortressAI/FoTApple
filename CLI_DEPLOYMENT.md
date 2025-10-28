# Complete CLI TestFlight Deployment Guide

## TL;DR - Three CLI Options

### Option 1: Fully Automated (Best)
```bash
# One-time setup
export APP_STORE_CONNECT_API_KEY_PATH=~/AuthKey_XXXXX.p8
export APP_STORE_CONNECT_API_KEY_ID=YOUR_KEY_ID
export APP_STORE_CONNECT_API_ISSUER_ID=YOUR_ISSUER_ID

# Deploy
./scripts/testflight_cli.sh
```

### Option 2: CLI Archive + GUI Upload
```bash
./scripts/testflight_cli.sh  # Creates IPA
# Then drag IPA to Transporter.app
```

### Option 3: Using Fastlane (Industry Standard)
```bash
# Install once
gem install fastlane

# Deploy all apps
fastlane beta
```

---

## Detailed Setup

### 1. Create App Store Connect API Key (One Time)

This enables fully automated CLI deployment without passwords.

**Steps:**
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Users and Access → Keys
3. Click "+" to generate API Key
4. Name: "CLI Deployment"
5. Access: App Manager
6. **Download the .p8 file** (only shown once!)
7. Note the Key ID and Issuer ID

**Save credentials:**
```bash
# Add to ~/.zshrc or ~/.bash_profile
export APP_STORE_CONNECT_API_KEY_PATH=~/Downloads/AuthKey_XXXXX.p8
export APP_STORE_CONNECT_API_KEY_ID=ABCDE12345
export APP_STORE_CONNECT_API_ISSUER_ID=12345678-1234-1234-1234-123456789012
```

### 2. Three Deployment Methods

#### Method A: Our Custom CLI Script

```bash
cd /Users/richardgillespie/Documents/FoTApple

# Deploy one app
./scripts/testflight_cli.sh

# Or all apps
./scripts/deploy_testflight.sh
```

**What it does:**
1. Cleans build
2. Creates archive (.xcarchive)
3. Exports IPA
4. Uploads to App Store Connect (if API key configured)

#### Method B: Using xcodebuild Directly

```bash
cd apps/PersonalHealthApp/iOS

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
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates

# 3. Upload (choose one)

# Option A: With API Key
xcrun altool --upload-app \
  --type ios \
  --file export/PersonalHealthApp.ipa \
  --apiKey $APP_STORE_CONNECT_API_KEY_ID \
  --apiIssuer $APP_STORE_CONNECT_API_ISSUER_ID

# Option B: With Apple ID
xcrun altool --upload-app \
  --type ios \
  --file export/PersonalHealthApp.ipa \
  --username your@email.com \
  --password YOUR_APP_SPECIFIC_PASSWORD
```

#### Method C: Using Fastlane (Recommended for Teams)

```bash
# One-time setup
cd /Users/richardgillespie/Documents/FoTApple
fastlane init

# Edit Fastfile - example:
lane :beta do
  build_app(
    scheme: "PersonalHealthApp",
    export_method: "app-store"
  )
  upload_to_testflight(
    api_key_path: ENV["APP_STORE_CONNECT_API_KEY_PATH"],
    skip_waiting_for_build_processing: true
  )
end

# Deploy
fastlane beta
```

### 3. First-Time Setup Requirement

**Before CLI works, you MUST:**

#### Option A: Let Xcode Create App Record (Easiest)
1. Open app in Xcode
2. Archive once manually
3. Distribute → TestFlight
4. After this, CLI works forever

#### Option B: Manual App Store Connect Setup
1. Go to App Store Connect
2. My Apps → "+" → New App
3. Fill in details
4. Use bundle ID: com.fot.PersonalHealth
5. Repeat for all 5 apps

#### Option C: Use App Store Connect API (Advanced)
```bash
# Create app via API
curl -X POST "https://api.appstoreconnect.apple.com/v1/apps" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -d '{
    "data": {
      "type": "apps",
      "attributes": {
        "bundleId": "com.fot.PersonalHealth",
        "name": "Personal Health",
        "primaryLocale": "en-US"
      }
    }
  }'
```

### 4. Common CLI Errors & Fixes

#### Error: "No profiles found"
**Solution**: Run with `-allowProvisioningUpdates`
```bash
xcodebuild archive ... -allowProvisioningUpdates
```

#### Error: "No devices"
**Solutions**:
1. Use App Store distribution (not Development)
2. Or register a device in Apple Developer Portal

#### Error: "Communication with Apple failed"
**Check**:
- Internet connection
- Apple Developer account is active
- Team ID is correct: WWQQB728U5

#### Error: "Invalid credentials"
**For altool**: Create App-Specific Password
1. appleid.apple.com
2. Security → App-Specific Passwords
3. Generate new password
4. Use this instead of your Apple ID password

### 5. Uploading Without API Key

If you don't want to set up API key:

**Option 1: Transporter App (Easiest GUI)**
```bash
# Create IPA
./scripts/testflight_cli.sh

# Then drag IPA to Transporter.app
open -a Transporter
```

**Option 2: Command line with password**
```bash
xcrun altool --upload-app \
  --type ios \
  --file build/exports/PersonalHealthApp/PersonalHealthApp.ipa \
  --username your@email.com \
  --password abcd-efgh-ijkl-mnop  # App-specific password
```

### 6. Deploy All 5 Apps Script

```bash
#!/bin/bash
APPS=(
  "PersonalHealthApp"
  "FoTClinicianApp"
  "FoTParentApp"
  "FoTEducationApp"
  "FoTLegalApp"
)

for APP in "${APPS[@]}"; do
  echo "Deploying $APP..."
  cd "apps/$APP/iOS"
  
  xcodebuild archive \
    -project "$APP.xcodeproj" \
    -scheme "$APP" \
    -archivePath "build/$APP.xcarchive" \
    -allowProvisioningUpdates
  
  xcodebuild -exportArchive \
    -archivePath "build/$APP.xcarchive" \
    -exportPath "build/export" \
    -exportOptionsPlist ExportOptions.plist
  
  xcrun altool --upload-app \
    --type ios \
    --file "build/export/$APP.ipa" \
    --apiKey "$APP_STORE_CONNECT_API_KEY_ID" \
    --apiIssuer "$APP_STORE_CONNECT_API_ISSUER_ID"
  
  cd ../../..
done
```

### 7. Verification

After upload:
```bash
# Check upload status
xcrun altool --list-apps \
  --apiKey $APP_STORE_CONNECT_API_KEY_ID \
  --apiIssuer $APP_STORE_CONNECT_API_ISSUER_ID
```

Or visit: https://appstoreconnect.apple.com/ → TestFlight

---

## Quick Reference

| Task | Command |
|------|---------|
| Archive | `xcodebuild archive -project X.xcodeproj -scheme X -archivePath X.xcarchive -allowProvisioningUpdates` |
| Export | `xcodebuild -exportArchive -archivePath X.xcarchive -exportPath ./export -exportOptionsPlist ExportOptions.plist` |
| Upload | `xcrun altool --upload-app --type ios --file X.ipa --apiKey KEY --apiIssuer ISSUER` |
| All in one | `./scripts/testflight_cli.sh` |

## Current Status

✅ All 5 apps build  
✅ Bundle IDs configured  
✅ CLI scripts ready  
⚠️ Need API key OR first manual archive  

**Next step**: Run `./scripts/testflight_cli.sh` to test

