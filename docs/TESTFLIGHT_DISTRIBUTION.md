# TestFlight Distribution Guide

## Overview

TestFlight lets you distribute beta versions of your iOS, iPadOS, macOS, and visionOS apps to testers before releasing to the App Store. With your **App Store Connect API Key**, you can automate the entire process.

## ✅ What You Have

### 🔑 AuthKey_43BGN9JC5B.p8
- **Location:** `.apple-keys/AuthKey_43BGN9JC5B.p8` (git-ignored)
- **Type:** App Store Connect API Key (ECDSA P-256)
- **Key ID:** `43BGN9JC5B`
- **Issuer ID:** Found in App Store Connect → Keys → Issuer ID

### What This Key Enables:
✅ Upload builds to App Store Connect (no Xcode required!)  
✅ Distribute to TestFlight testers  
✅ Manage app metadata  
✅ Submit for App Store review  
✅ Access App Store Connect API  
✅ Fully automated CI/CD pipelines  

---

## 🚀 Quick Start: Distribute to TestFlight

### Step 1: Build for iOS Device

```bash
# Personal Health App
cd apps/PersonalHealthApp/iOS

# Build archive for device
xcodebuild archive \
  -project PersonalHealthApp.xcodeproj \
  -scheme PersonalHealthApp \
  -destination "generic/platform=iOS" \
  -archivePath PersonalHealthApp.xcarchive \
  CODE_SIGN_IDENTITY="Apple Development" \
  DEVELOPMENT_TEAM="WWQQB728U5"

# Export IPA for TestFlight
xcodebuild -exportArchive \
  -archivePath PersonalHealthApp.xcarchive \
  -exportPath Export \
  -exportOptionsPlist ExportOptions.plist
```

### Step 2: Upload to App Store Connect

Using **xcrun altool** (older, still works):

```bash
xcrun altool --upload-app \
  --type ios \
  --file Export/PersonalHealthApp.ipa \
  --apiKey 43BGN9JC5B \
  --apiIssuer YOUR_ISSUER_ID
```

Using **xcrun notarytool** (newer, faster):

```bash
xcrun notarytool submit Export/PersonalHealthApp.ipa \
  --key .apple-keys/AuthKey_43BGN9JC5B.p8 \
  --key-id 43BGN9JC5B \
  --issuer YOUR_ISSUER_ID \
  --wait
```

### Step 3: Manage Testers

Via **App Store Connect** web interface:
1. Go to **My Apps** → Your App → **TestFlight**
2. Click **Internal Testing** or **External Testing**
3. Add testers by email
4. They'll receive an email with TestFlight link

Via **App Store Connect API** (automated):

```bash
# Add tester
curl -X POST \
  https://api.appstoreconnect.apple.com/v1/betaTesters \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "betaTesters",
      "attributes": {
        "email": "tester@example.com",
        "firstName": "John",
        "lastName": "Doe"
      }
    }
  }'
```

---

## 🔐 Export Options Plist

Create `apps/PersonalHealthApp/iOS/ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>WWQQB728U5</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.fot.PersonalHealth</key>
        <string>Personal Health App Store Profile</string>
    </dict>
</dict>
</plist>
```

---

## 📦 What Apps Can Be Distributed

### ✅ Ready for TestFlight:

1. **Personal Health App (iOS)**
   - Bundle ID: `com.fot.PersonalHealth`
   - For individuals to track health
   - Camera, sensors, receipts

2. **Personal Health App (macOS)**
   - Bundle ID: `com.fot.PersonalHealthMac`
   - Desktop version
   - Detailed entry & analysis

3. **FoT Clinician (iOS)**
   - Bundle ID: `com.fot.ClinicianApp`
   - For doctors/nurses
   - Patient management, SOAP notes

### 🔄 Coming Soon:
- Education K-18 App
- Legal US App
- visionOS versions

---

## 🤖 CI/CD Automation (GitHub Actions)

Add to `.github/workflows/testflight-release.yml`:

```yaml
name: TestFlight Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  testflight:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up signing
        env:
          APPLE_AUTH_KEY: ${{ secrets.APPLE_AUTH_KEY_P8 }}
          KEY_ID: "43BGN9JC5B"
          ISSUER_ID: ${{ secrets.APPLE_ISSUER_ID }}
        run: |
          mkdir -p ~/.apple-keys
          echo "$APPLE_AUTH_KEY" > ~/.apple-keys/AuthKey_$KEY_ID.p8
          chmod 600 ~/.apple-keys/AuthKey_$KEY_ID.p8
      
      - name: Build and archive
        run: |
          xcodebuild archive \
            -project apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj \
            -scheme PersonalHealthApp \
            -destination "generic/platform=iOS" \
            -archivePath PersonalHealthApp.xcarchive \
            CODE_SIGN_IDENTITY="Apple Development" \
            DEVELOPMENT_TEAM="WWQQB728U5"
      
      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath PersonalHealthApp.xcarchive \
            -exportPath Export \
            -exportOptionsPlist apps/PersonalHealthApp/iOS/ExportOptions.plist
      
      - name: Upload to TestFlight
        env:
          KEY_ID: "43BGN9JC5B"
          ISSUER_ID: ${{ secrets.APPLE_ISSUER_ID }}
        run: |
          xcrun notarytool submit Export/PersonalHealthApp.ipa \
            --key ~/.apple-keys/AuthKey_$KEY_ID.p8 \
            --key-id $KEY_ID \
            --issuer $ISSUER_ID \
            --wait
```

### GitHub Secrets to Add:
1. `APPLE_AUTH_KEY_P8` - Contents of AuthKey_43BGN9JC5B.p8
2. `APPLE_ISSUER_ID` - Your Issuer ID from App Store Connect

---

## 🔍 Finding Your Issuer ID

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Users and Access** → **Keys**
3. Look for **Issuer ID** at the top (format: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`)

---

## 🧪 Testing the Setup

### Local Test (Dry Run):

```bash
# Verify key is readable
cat .apple-keys/AuthKey_43BGN9JC5B.p8

# Build for simulator first (no signing needed)
cd apps/PersonalHealthApp/iOS
xcodebuild -project PersonalHealthApp.xcodeproj \
  -scheme PersonalHealthApp \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  build

# If simulator build succeeds, try device build
xcodebuild archive \
  -project PersonalHealthApp.xcodeproj \
  -scheme PersonalHealthApp \
  -destination "generic/platform=iOS" \
  -archivePath PersonalHealthApp.xcarchive \
  CODE_SIGN_IDENTITY="Apple Development" \
  DEVELOPMENT_TEAM="WWQQB728U5"
```

---

## 📋 Troubleshooting

### Error: "No identity found"
**Solution:** Install Apple Development certificate:
```bash
# Download from developer.apple.com or:
security find-identity -v -p codesigning
```

### Error: "Provisioning profile doesn't match"
**Solution:** Use automatic signing:
- Set `CODE_SIGN_STYLE=Automatic`
- Ensure team ID is correct: `WWQQB728U5`

### Error: "App Store Connect API error"
**Solution:** Verify Issuer ID:
```bash
# Test API access
curl -H "Authorization: Bearer $JWT_TOKEN" \
  https://api.appstoreconnect.apple.com/v1/apps
```

---

## 🎯 Next Steps

1. **Find your Issuer ID** from App Store Connect
2. **Create ExportOptions.plist** for each app
3. **Test local build** for iOS device
4. **Upload first build** to TestFlight
5. **Add yourself as tester** to verify
6. **Automate with CI/CD** once manual process works

---

## 📚 References

- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [Generating JWTs for API](https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests)

---

**Your AuthKey is secured and ready. Time to ship! 🚀**

