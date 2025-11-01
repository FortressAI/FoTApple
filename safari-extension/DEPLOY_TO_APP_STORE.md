# 🚀 QFOT Wallet - App Store Deployment Guide

## ✅ Current Status

**✅ SUCCESSFULLY BUILT & SIGNED**

- **Archive:** `build/QFOT_Wallet_macOS.xcarchive`
- **Exported App:** `build/export/QFOT Wallet.app`
- **Signing:** Developer ID Application (verified)
- **Ready for:** Direct distribution OR App Store (after provisioning profiles)

---

## 🎯 Two Deployment Options

### Option 1: Direct Distribution (Developer ID) ✅ READY NOW

**Pros:**
- ✅ No App Store review process
- ✅ Immediate distribution
- ✅ Full control over updates
- ✅ No App Store fees

**Steps:**

#### 1️⃣ Notarize the App (Required for macOS Gatekeeper)

```bash
cd "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet"

# Create a ZIP for notarization
ditto -c -k --keepParent "build/export/QFOT Wallet.app" "build/export/QFOT_Wallet.zip"

# Submit for notarization
xcrun notarytool submit "build/export/QFOT_Wallet.zip" \
  --apple-id YOUR_APPLE_ID@example.com \
  --password YOUR_APP_SPECIFIC_PASSWORD \
  --team-id WWQQB728U5 \
  --wait

# After approval, staple the notarization ticket
xcrun stapler staple "build/export/QFOT Wallet.app"
```

**Note:** Get your App-Specific Password from https://appleid.apple.com → Security → App-Specific Passwords

#### 2️⃣ Create a DMG for Distribution

```bash
hdiutil create -volname "QFOT Wallet" \
  -srcfolder "build/export/QFOT Wallet.app" \
  -ov -format UDZO \
  "QFOT_Wallet_v1.0.dmg"
```

#### 3️⃣ Distribute

- Upload to your website: `safeaicoin.org/download/QFOT_Wallet_v1.0.dmg`
- Users download, mount DMG, drag app to Applications
- Extension appears in Safari after running app

---

### Option 2: Mac App Store Distribution 🛒 REQUIRES PROVISIONING PROFILES

**Pros:**
- 🌟 Official App Store presence
- 🔍 Built-in discovery/search
- 🔐 Apple's review = trust signal
- 🔄 Automatic updates

**Steps:**

#### 1️⃣ Create Provisioning Profiles

Go to https://developer.apple.com/account/resources/profiles/add

**Create TWO profiles:**

##### Profile 1: QFOT Wallet App
- **Type:** macOS App Store
- **App ID:** `com.fotapple.qfot.wallet`
- **Certificate:** Apple Distribution: Richard Gillespie (WWQQB728U5)
- **Download:** Save as `QFOT_Wallet_App.provisionprofile`

##### Profile 2: QFOT Wallet Extension
- **Type:** macOS App Store
- **App ID:** `com.fotapple.qfot.wallet.Extension`
- **Certificate:** Apple Distribution: Richard Gillespie (WWQQB728U5)
- **Download:** Save as `QFOT_Wallet_Extension.provisionprofile`

#### 2️⃣ Install Provisioning Profiles

```bash
# Copy profiles to correct location
open ~/Library/MobileDevice/Provisioning\ Profiles/

# Or install via command:
cp QFOT_Wallet_App.provisionprofile ~/Library/MobileDevice/Provisioning\ Profiles/
cp QFOT_Wallet_Extension.provisionprofile ~/Library/MobileDevice/Provisioning\ Profiles/
```

#### 3️⃣ Update Export Options

The `ExportOptions.plist` needs provisioning profile UUIDs:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>WWQQB728U5</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>destination</key>
    <string>upload</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.fotapple.qfot.wallet</key>
        <string>QFOT Wallet App Profile Name</string>
        <key>com.fotapple.qfot.wallet.Extension</key>
        <string>QFOT Wallet Extension Profile Name</string>
    </dict>
</dict>
</plist>
```

#### 4️⃣ Export for App Store

```bash
cd "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet"

xcodebuild -exportArchive \
  -archivePath "./build/QFOT_Wallet_macOS.xcarchive" \
  -exportPath "./build/app_store_export" \
  -exportOptionsPlist "ExportOptions.plist" \
  -allowProvisioningUpdates
```

#### 5️⃣ Upload to App Store Connect

**Using Transporter (Easiest):**
```bash
open -a Transporter build/app_store_export/
```

**Using Command Line:**
```bash
xcrun altool --upload-package build/app_store_export/QFOT_Wallet.pkg \
  --type macos \
  --apple-id YOUR_APPLE_ID@example.com \
  --password YOUR_APP_SPECIFIC_PASSWORD
```

#### 6️⃣ Complete App Store Connect Metadata

Go to https://appstoreconnect.apple.com

1. **App Information:**
   - Name: QFOT Wallet
   - Subtitle: Secure QFOT Token Management
   - Category: Finance or Utilities

2. **Description:**
```
QFOT Wallet is the official wallet for managing QFOT (Quantum Field of Truth) tokens. 
Securely store, send, and receive QFOT tokens directly in Safari.

Features:
• Secure Ed25519 key generation
• BIP39 mnemonic seed phrases
• AES-GCM encrypted storage
• Safari browser integration
• Real-time balance updates
• Transaction history
• Connect to safeaicoin.org blockchain
```

3. **Keywords:**
```
qfot, wallet, blockchain, crypto, tokens, safari, extension
```

4. **Screenshots** (Required):
   - 1280x800 pixels
   - 1440x900 pixels
   - 2880x1800 pixels (Retina)

5. **Privacy Policy URL:**
   - https://safeaicoin.org/privacy

6. **Support URL:**
   - https://safeaicoin.org/support

#### 7️⃣ Submit for Review

---

## 🎯 Recommended Approach

### Phase 1: Direct Distribution (NOW)
1. ✅ Notarize current build
2. ✅ Create DMG
3. ✅ Deploy to safeaicoin.org/download
4. ✅ Test with real users
5. ✅ Gather feedback

### Phase 2: App Store Submission (After Testing)
1. Create provisioning profiles
2. Rebuild for App Store
3. Create screenshots & metadata
4. Submit for review
5. Launch on Mac App Store

---

## 📋 Quick Commands

### Test Current Build Locally
```bash
cd "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet"
open "build/export/QFOT Wallet.app"
```

### Notarize & Create DMG (One-liner)
```bash
cd "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet" && \
ditto -c -k --keepParent "build/export/QFOT Wallet.app" "build/export/QFOT_Wallet.zip" && \
xcrun notarytool submit "build/export/QFOT_Wallet.zip" \
  --apple-id YOUR_APPLE_ID \
  --password YOUR_APP_SPECIFIC_PASSWORD \
  --team-id WWQQB728U5 \
  --wait && \
xcrun stapler staple "build/export/QFOT Wallet.app" && \
hdiutil create -volname "QFOT Wallet" \
  -srcfolder "build/export/QFOT Wallet.app" \
  -ov -format UDZO \
  "QFOT_Wallet_v1.0.dmg"
```

### Rebuild from Scratch
```bash
cd "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet"
rm -rf build/
xcodebuild -project "QFOT Wallet.xcodeproj" \
  -scheme "QFOT Wallet (macOS)" \
  -configuration Release \
  -archivePath "./build/QFOT_Wallet_macOS.xcarchive" \
  CODE_SIGN_IDENTITY="Apple Distribution: Richard Gillespie (WWQQB728U5)" \
  DEVELOPMENT_TEAM="WWQQB728U5" \
  CODE_SIGN_STYLE=Manual \
  -allowProvisioningUpdates \
  archive
```

---

## 🔐 Security Checklist

- ✅ Developer ID Application certificate: ACTIVE
- ✅ Apple Distribution certificate: ACTIVE  
- ✅ Code signing: VERIFIED
- ✅ Hardened runtime: ENABLED
- ✅ Sandbox: ENABLED
- ⏳ Notarization: PENDING (run after testing)
- ⏳ App Store provisioning profiles: NEEDED (for App Store only)

---

## 📞 Need Help?

**Apple Developer Support:**
- https://developer.apple.com/support/

**Notarization Guide:**
- https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution

**App Store Review Guidelines:**
- https://developer.apple.com/app-store/review/guidelines/

---

## ✅ What You Have NOW

**Ready for immediate distribution:**
- Properly signed macOS app
- Developer ID certificate (verified)
- Universal binary (arm64 + x86_64)
- Safari Extension included
- All QFOT wallet features working

**Next immediate step:** Notarize and deploy to safeaicoin.org

