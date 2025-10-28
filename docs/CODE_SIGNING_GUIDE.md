# Code Signing Guide - Field of Truth Apple

## 🔐 Available Certificates (Verified)

### ✅ Certificates in Keychain

#### 1. Developer ID Application
```
Identity: D1842BEC051218DFD29CA65657A31122C093CE7E
Name: "Developer ID Application: Richard Gillespie (WWQQB728U5)"
Team ID: WWQQB728U5
```

**Purpose:** Sign macOS apps for distribution **outside** the Mac App Store  
**Use for:**
- macOS Clinician app
- macOS Education app
- macOS Legal app
- Safari Extension (optional)

**Not used for:** iOS apps, watchOS apps

---

#### 2. Apple Development
```
Name: "Apple Development: Richard Gillespie (BP2AQNQ522)"
Team ID: WWQQB728U5
```

**Purpose:** Development and testing on physical devices  
**Use for:**
- Testing iOS apps on iPhone/iPad
- Testing watchOS apps on Apple Watch
- Local development builds
- Internal team testing

**Requires:** Provisioning profile for each app

---

#### 3. Apple Distribution
```
Name: "Apple Distribution: Richard Gillespie"
Team ID: WWQQB728U5
```

**Purpose:** App Store and TestFlight distribution  
**Use for:**
- Submitting to App Store
- TestFlight beta testing
- Production builds

**Requires:** App Store provisioning profile

---

## 📱 Provisioning Profiles Status

**Current Status:** ⚠️ No provisioning profiles found

**Location checked:** `~/Library/MobileDevice/Provisioning Profiles/`

**What this means:**
- ✅ **Simulator builds:** Work perfectly (no profiles needed)
- ❌ **Physical device testing:** Need to create profiles
- ❌ **App Store submission:** Need to create profiles

---

## 🎯 Code Signing Strategy by Build Type

### 1. Simulator Builds (Current - Working ✅)

**Command:**
```bash
xcodebuild -project FoTClinicianApp.xcodeproj \
  -scheme FoTClinicianApp \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1" \
  -derivedDataPath .build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build
```

**Why it works:**
- Simulator doesn't verify signatures
- No provisioning profile needed
- Fastest iteration cycle

**Use for:**
- Development
- UI testing
- Screenshots
- Demo videos

---

### 2. Physical Device Testing (Requires Setup)

**Prerequisites:**
1. Register device UDID in Apple Developer portal
2. Create iOS App Development provisioning profile
3. Download and install profile
4. Update Xcode project settings

**Command:**
```bash
xcodebuild -project FoTClinicianApp.xcodeproj \
  -scheme FoTClinicianApp \
  -destination "generic/platform=iOS" \
  -derivedDataPath .build \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Apple Development: Richard Gillespie (BP2AQNQ522)" \
  PROVISIONING_PROFILE_SPECIFIER="<profile_name>" \
  DEVELOPMENT_TEAM=WWQQB728U5 \
  build
```

**Use for:**
- Real hardware testing
- Camera/GPS sensor testing
- Performance validation
- User acceptance testing

---

### 3. TestFlight / App Store Distribution (Future)

**Prerequisites:**
1. Create App Store provisioning profile
2. Configure app in App Store Connect
3. Set up app privacy details
4. Configure in-app purchases (if any)

**Command:**
```bash
xcodebuild -project FoTClinicianApp.xcodeproj \
  -scheme FoTClinicianApp \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -derivedDataPath .build \
  -archivePath FoTClinicianApp.xcarchive \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Apple Distribution: Richard Gillespie" \
  PROVISIONING_PROFILE_SPECIFIER="<app_store_profile>" \
  DEVELOPMENT_TEAM=WWQQB728U5 \
  archive
```

Then export for App Store:
```bash
xcodebuild -exportArchive \
  -archivePath FoTClinicianApp.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

---

### 4. macOS App Distribution

**Using Developer ID Application:**
```bash
xcodebuild -project FoTClinicianMac.xcodeproj \
  -scheme FoTClinicianMac \
  -configuration Release \
  CODE_SIGN_IDENTITY="Developer ID Application: Richard Gillespie (WWQQB728U5)" \
  build
```

**Then notarize:**
```bash
# Create DMG or ZIP
# Submit for notarization
xcrun notarytool submit FoTClinicianMac.dmg \
  --apple-id your@email.com \
  --team-id WWQQB728U5 \
  --password @keychain:AC_PASSWORD

# Staple notarization ticket
xcrun stapler staple FoTClinicianMac.dmg
```

---

## 📋 Creating Provisioning Profiles

### Method 1: Xcode Automatic (Recommended for Development)

1. Open Xcode
2. Go to project settings → Signing & Capabilities
3. Select team: "Richard Gillespie (WWQQB728U5)"
4. Check "Automatically manage signing"
5. Xcode will create and download profiles

### Method 2: Manual via Developer Portal

1. Go to https://developer.apple.com/account/
2. Navigate to Certificates, Identifiers & Profiles
3. Create App IDs:
   - `com.fot.ClinicianApp`
   - `com.fot.EducationApp`
   - `com.fot.LegalApp`
4. Register test devices (get UDID from Finder)
5. Create provisioning profiles:
   - iOS App Development (for testing)
   - App Store (for distribution)
6. Download `.mobileprovision` files
7. Double-click to install

---

## 🔧 Troubleshooting Code Signing Issues

### Issue 1: "resource fork, Finder information, or similar detritus not allowed"

**Cause:** Extended attributes on files from downloads or cloud sync

**Fix:**
```bash
cd /Users/richardgillespie/Documents/FoTApple
xattr -rc apps/
find . -name ".DS_Store" -delete
```

---

### Issue 2: "No valid signing identity"

**Check identities:**
```bash
security find-identity -v -p codesigning
```

**Verify expiration:**
```bash
security find-certificate -a -c "Apple Development" -p | openssl x509 -text -noout | grep "Not After"
```

---

### Issue 3: "Provisioning profile doesn't include signing certificate"

**Fix:**
1. Regenerate provisioning profile in Developer portal
2. Include your current development certificate
3. Download and install new profile

---

## 🎯 Recommended Workflow

### For Development (Current)
✅ **Use simulator** - No signing needed, fastest iteration

```bash
cd apps/ClinicianApp/iOS
./build.sh build  # Already configured for simulator
./build.sh run    # Launches in simulator
```

### For Device Testing
1. Get device UDID: Connect iPhone → Finder → Click device → Copy identifier
2. Add device to Developer portal
3. Create development provisioning profile
4. Update `project.yml`:
```yaml
settings:
  base:
    DEVELOPMENT_TEAM: WWQQB728U5
    CODE_SIGN_IDENTITY: "Apple Development: Richard Gillespie (BP2AQNQ522)"
    PROVISIONING_PROFILE_SPECIFIER: "FoT Clinician Development"
```
5. Regenerate Xcode project: `xcodegen generate`
6. Build and deploy to device

### For App Store (Future)
1. Complete app metadata in App Store Connect
2. Create App Store provisioning profile
3. Build and archive
4. Upload via Xcode or `xcrun altool`
5. Submit for review

---

## 🔐 Security Best Practices

### DO:
✅ Keep certificates backed up in secure location  
✅ Use Keychain for storing credentials  
✅ Enable "Automatically manage signing" for development  
✅ Use separate profiles for dev/distribution  
✅ Rotate certificates before expiration  

### DON'T:
❌ Commit provisioning profiles to git (add to .gitignore)  
❌ Share private keys  
❌ Use distribution certificates for development  
❌ Disable code signing in production builds  
❌ Skip notarization for macOS apps  

---

## 📝 Current Build Configuration

### Working (Simulator) ✅
```yaml
# apps/ClinicianApp/iOS/project.yml
settings:
  base:
    CODE_SIGN_IDENTITY: ""
    CODE_SIGNING_REQUIRED: NO
    CODE_SIGNING_ALLOWED: NO
```

### For Device (To Be Configured)
```yaml
settings:
  base:
    DEVELOPMENT_TEAM: WWQQB728U5
    CODE_SIGN_STYLE: Manual
    CODE_SIGN_IDENTITY: "Apple Development: Richard Gillespie (BP2AQNQ522)"
    PROVISIONING_PROFILE_SPECIFIER: "FoT Clinician Development"
  configs:
    Debug:
      # Development signing
    Release:
      # Distribution signing
      CODE_SIGN_IDENTITY: "Apple Distribution: Richard Gillespie"
      PROVISIONING_PROFILE_SPECIFIER: "FoT Clinician App Store"
```

---

## 🎬 Next Steps

### Immediate (Simulator Development) - Current ✅
- Continue using simulator builds
- No additional setup needed
- Perfect for UI development and screenshots

### Short-term (Device Testing)
1. [ ] Register test devices in Developer portal
2. [ ] Create iOS App Development profiles for all 3 apps
3. [ ] Update project.yml files with signing config
4. [ ] Test camera/GPS on real iPhone

### Medium-term (TestFlight)
1. [ ] Create App Store profiles
2. [ ] Configure apps in App Store Connect
3. [ ] Add privacy policy
4. [ ] Submit for TestFlight beta

### Long-term (Public Release)
1. [ ] Complete app review requirements
2. [ ] Add screenshots and descriptions
3. [ ] Set pricing
4. [ ] Submit for App Store review

---

## 📞 Certificate Management Commands

### List all certificates
```bash
security find-identity -v -p codesigning
```

### Check certificate expiration
```bash
security find-certificate -a -c "Apple Development" -p | openssl x509 -text -noout | grep "Not After"
```

### Remove expired certificates
```bash
security delete-certificate -c "Old Certificate Name"
```

### Import certificate
```bash
security import certificate.p12 -k ~/Library/Keychains/login.keychain-db
```

### List provisioning profiles
```bash
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/
```

### View profile details
```bash
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision
```

---

## ✅ Summary: You're All Set for Simulator Development

**Current Status:**
- ✅ Valid Apple Development certificate
- ✅ Valid Apple Distribution certificate  
- ✅ Valid Developer ID Application certificate (macOS)
- ✅ Simulator builds working perfectly
- ⚠️ No provisioning profiles (not needed for simulator)

**What You Can Do Now:**
- ✅ Develop and test all iOS apps in simulator
- ✅ Take screenshots and record videos
- ✅ Build and sign macOS apps
- ✅ Continue with glass UI development

**What Requires Setup:**
- ⏳ Physical device testing (need profiles)
- ⏳ TestFlight distribution (need profiles)
- ⏳ App Store submission (need profiles + app metadata)

**Recommendation:**  
Continue with simulator development for now. Create provisioning profiles when you're ready for:
1. Real device sensor testing (camera, GPS, accelerometer)
2. Beta testing with users
3. App Store submission

---

*Last Updated: October 28, 2025*  
*Status: Ready for simulator development ✅*

