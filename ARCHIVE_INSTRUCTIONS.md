# 📦 Archive & Upload Instructions - PersonalHealth & Legal

## ✅ **2 Apps Ready for TestFlight:**
1. **PersonalHealthApp** - Built successfully
2. **FoTLegalApp** - Built successfully

Both apps include:
- ✅ Enhanced domain services integration
- ✅ Unique professional icons
- ✅ Version 13
- ✅ ZERO SIMULATION validation
- ✅ Cryptographic audit trails

---

## 🎯 **RECOMMENDED: Xcode Organizer (GUI)**

Xcode 26 has a CLI export bug, so GUI is most reliable.

### **Step 1: Archive Both Apps**

```bash
# Archive PersonalHealthApp
xcodebuild archive \
  -project apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj \
  -scheme PersonalHealthApp \
  -sdk iphoneos \
  -configuration Release \
  -archivePath "build/archives/PersonalHealthApp_v13.xcarchive" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=WWQQB728U5

# Archive FoTLegalApp
xcodebuild archive \
  -project apps/LegalApp/iOS/FoTLegalApp.xcodeproj \
  -scheme FoTLegalApp \
  -sdk iphoneos \
  -configuration Release \
  -archivePath "build/archives/FoTLegalApp_v13.xcarchive" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=WWQQB728U5
```

### **Step 2: Open Xcode Organizer**

```bash
open -a Xcode
```

Then:
1. Go to **Window** → **Organizer** → **Archives**
2. Find **PersonalHealthApp** and **FoTLegalApp** archives
3. Select each archive
4. Click **"Distribute App"**
5. Choose **"TestFlight & App Store"**
6. Choose **"Upload"**
7. Select **"Automatically manage signing"**
8. Click **"Upload"**

---

## 🔑 **Credentials (if needed manually):**

- **API Key:** `ApiKey_706IRVGBDV3B.p8`
- **API Key ID:** `706IRVGBDV3B`
- **Issuer ID:** `69a6de95-fd71-47e3-e053-5b8c7c11a4d1`
- **Team ID:** `WWQQB728U5`

---

## 📊 **Bundle IDs:**

- **PersonalHealth:** `com.akashic.PersonalHealth`
- **Legal:** `com.akashic.FoTLegal`

---

## 🎤 **Siri Commands to Test After Upload:**

### **Legal App:**
```
"Hey Siri, search case law for Fourth Amendment in Legal"
"Hey Siri, search federal statutes for civil rights in Legal"
"Hey Siri, calculate deadline for answer to complaint in Legal"
```

These commands will call **LIVE QFOT Domain Services** and return **REAL legal data** from the mainnet!

---

## 🔨 **Meanwhile:**

3 other apps (Clinician, Education, Parent) are rebuilding with fixes:
- Monitor: `tail -f build/logs/rebuild_3_master.log`

Once they're done, they can be archived the same way.

---

**Ready to upload 2 apps to TestFlight with enhanced domain services! 🚀**

