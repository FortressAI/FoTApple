# 🚗 CarPlay Legal App - Quick Start Guide

**Get accident documentation running in CarPlay in < 30 minutes**

---

## ⚡ Prerequisites

1. **Apple Developer Account** with CarPlay entitlement
2. **Xcode 15+**
3. **iOS 17+ target**
4. **CarPlay Simulator** (included in Xcode)

---

## 🚀 5-Step Implementation

### **Step 1: Request CarPlay Entitlement** (5 min)

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Select "Certificates, IDs & Profiles"
3. Select your Legal App ID
4. Click "Edit"
5. Enable "CarPlay"
6. **Justification:** "Emergency accident documentation and evidence capture for legal proceedings"
7. Submit (approval takes 1-2 days)

---

### **Step 2: Configure Xcode Project** (10 min)

#### **2.1 Add CarPlay Capability**

1. Open `FoTLegal.xcodeproj`
2. Select Legal app target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "CarPlay"

#### **2.2 Update Info.plist**

Add to `apps/LegalApp/iOS/FoTLegal/Info.plist`:

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UISceneConfigurations</key>
    <dict>
        <!-- Existing UIWindowSceneSessionRoleApplication -->
        
        <!-- ADD THIS: -->
        <key>CPTemplateApplicationSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneClassName</key>
                <string>CPTemplateApplicationScene</string>
                <key>UISceneConfigurationName</key>
                <string>CarPlay</string>
                <key>UISceneDelegateClassName</key>
                <string>FoTLegal.CarPlaySceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>

<!-- CarPlay Audio Category -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

#### **2.3 Add CarPlay Framework**

In your target's "Frameworks, Libraries, and Embedded Content":
- Click "+"
- Add `CarPlay.framework`

---

### **Step 3: Add CarPlay Scene Delegate** (5 min)

The file is already created at:
```
apps/LegalApp/CarPlay/CarPlaySceneDelegate.swift
```

**Just add it to your Xcode project:**
1. Right-click "FoTLegal" folder in Xcode
2. Select "Add Files to FoTLegal..."
3. Navigate to `apps/LegalApp/CarPlay/`
4. Select `CarPlaySceneDelegate.swift`
5. Ensure "Copy items if needed" is checked
6. Click "Add"

---

### **Step 4: Test in CarPlay Simulator** (5 min)

#### **4.1 Enable CarPlay Simulator**

1. In Xcode, go to **Xcode > Open Developer Tool > More Developer Tools...**
2. Download "Hardware IO Tools for Xcode"
3. Open "CarPlay Simulator.app"

#### **4.2 Run App**

1. Select any iOS simulator in Xcode
2. Build and run (⌘R)
3. Open CarPlay Simulator
4. Your Legal app should appear in CarPlay interface

#### **4.3 Test Voice Commands**

In simulator, activate Siri and say:
- "Document accident"
- "Traffic stop"
- "Quick evidence"

---

### **Step 5: Test on Real Device** (5 min)

#### **5.1 Connect iPhone to CarPlay**

**Option A: Real Car**
- Connect iPhone via USB or wireless CarPlay
- Your app should appear in CarPlay menu

**Option B: CarPlay Head Unit** (for development)
- Purchase a portable CarPlay head unit ($100-200)
- Connects to iPhone via USB
- Perfect for development testing

#### **5.2 Real-World Test**

1. While parked, open Legal app in CarPlay
2. Tap "Document Accident"
3. Follow voice prompts
4. Verify:
   - GPS location captured
   - Timestamp recorded
   - Voice recording works
   - Photo capture triggers iPhone camera
   - Cryptographic proof generated

---

## ✅ Success Checklist

After completing setup, verify:

- [ ] CarPlay capability enabled in Xcode
- [ ] Info.plist configured correctly
- [ ] CarPlaySceneDelegate added to project
- [ ] App builds without errors
- [ ] App appears in CarPlay Simulator
- [ ] Voice commands work
- [ ] Main menu shows all options:
  - 🚨 Document Accident
  - 🚔 Traffic Stop
  - 📸 Quick Evidence
  - 🎤 Voice Note
  - 📋 Active Incidents
- [ ] GPS location captured (real, not simulated)
- [ ] Voice assistant speaks prompts
- [ ] Cryptographic proof generated

---

## 🎯 Next Steps

### **Immediate (Next 2 Weeks):**

1. **Polish UI** - Refine button sizes and layout
2. **Add Photo Review** - Show captured photos in CarPlay
3. **Implement Evidence List** - View all captured evidence
4. **Add Emergency 911** - Quick dial integration

### **Short-Term (Next Month):**

1. **Dashcam Integration** - Import video from compatible dashcams
2. **Insurance Quick-Share** - One-tap send to insurance
3. **Attorney Portal** - Direct evidence sharing
4. **Offline Mode** - Full functionality without cell signal

### **Long-Term (Next Quarter):**

1. **Multi-Vehicle Accidents** - Support for complex incidents
2. **Witness Statements** - Structured interview mode
3. **Police Report OCR** - Scan and attach reports
4. **Blockchain Proof** - Immutable evidence ledger

---

## 🐛 Troubleshooting

### **App doesn't appear in CarPlay Simulator**

**Fix:**
1. Check Info.plist has `CPTemplateApplicationSceneSessionRoleApplication`
2. Verify CarPlay capability is enabled
3. Clean build folder (⇧⌘K)
4. Rebuild and relaunch

### **Voice commands don't work**

**Fix:**
1. Check `NSSpeechRecognitionUsageDescription` in Info.plist
2. Verify microphone permission granted
3. Check CarPlay audio routing in Settings
4. Test with real Siri, not simulator

### **GPS location not captured**

**Fix:**
1. Check `NSLocationWhenInUseUsageDescription` in Info.plist
2. Grant location permission to app
3. Ensure CoreLocation framework is linked
4. Test in area with good GPS signal

### **Cryptographic proof fails**

**Fix:**
1. Verify FoTCore is properly linked
2. Check blockchain service is initialized
3. Review debug logs for specific error
4. Ensure device has secure enclave access

---

## 📚 Additional Resources

- **Apple CarPlay Documentation:** [CarPlay Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/carplay)
- **CarPlay Templates Reference:** [CPTemplate Class Reference](https://developer.apple.com/documentation/carplay/cptemplateapplicationscene)
- **FoT Voice Commands:** [VOICE_FIRST_COMPLETE.md](VOICE_FIRST_COMPLETE.md)
- **App Intents Integration:** [APP_INTENTS_COMPLETE.md](APP_INTENTS_COMPLETE.md)

---

## 🚀 Let's Ship This!

**CarPlay + Legal App = Game Changer for Accident Documentation**

Questions? Check the full design doc: [CARPLAY_LEGAL_APP_DESIGN.md](CARPLAY_LEGAL_APP_DESIGN.md)

---

**Built with ❤️ by Fortress of Truth • Zero Simulations • 100% Real**

