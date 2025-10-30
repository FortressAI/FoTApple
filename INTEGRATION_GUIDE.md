# UX Enhancement Integration Guide

## 🎯 Quick Start

This guide shows you how to integrate the new **Siri-guided UX enhancements** into each Field of Truth app.

---

## 📋 What Was Built

✅ **Animated Splash Screens** - Beautiful launch experience  
✅ **Siri-Guided Onboarding** - Voice-first feature introduction  
✅ **Interactive Help System** - Context-aware tooltips and searchable help  
✅ **Siri Knowledge Base** - Comprehensive app understanding for Siri  
✅ **Enhanced App Intents** - Natural voice commands throughout  
✅ **Guided UI** - Tooltips that appear automatically to guide users  

---

## 🔧 Integration Steps for Each App

### Step 1: Update Package.swift

Add the new files to your FoTUI and FoTCore targets:

```swift
// In Package.swift, ensure these are in the appropriate targets:

// FoTUI target
.target(
    name: "FoTUI",
    dependencies: ["FoTCore"],
    path: "packages/FoTUI"
),

// FoTCore target
.target(
    name: "FoTCore",
    dependencies: [],
    path: "packages/FoTCore"
),
```

### Step 2: Import Required Frameworks

In each app's main file, add:

```swift
import SwiftUI
import FoTUI
import FoTCore
import AppIntents
import AVFoundation  // For voice narration
```

### Step 3: Integrate Onboarding Flow

#### Personal Health App Example

```swift
// apps/PersonalHealthApp/iOS/PersonalHealthApp.swift

import SwiftUI
import FoTUI

@main
struct PersonalHealthApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                PersonalHealthOnboardingFlow {
                    hasCompletedOnboarding = true
                }
            } else {
                MainDashboardView()
                    .interactiveHelp(.personalHealthDashboard)
            }
        }
    }
}
```

#### Apply Same Pattern to All Apps:

1. **Clinician**: Use `ClinicianOnboardingFlow`
2. **Legal**: Use `LegalOnboardingFlow`
3. **Education**: Use `EducationOnboardingFlow`
4. **Parent**: Use `ParentOnboardingFlow`

### Step 4: Add Help to Key Screens

Add `.interactiveHelp()` modifier to important views:

```swift
// Example: Personal Health Check-In Screen
struct HealthCheckInView: View {
    var body: some View {
        VStack {
            // Your existing UI
        }
        .interactiveHelp(.personalHealthCheckIn)
    }
}

// Example: Clinician Encounter Screen
struct EncounterView: View {
    var body: some View {
        VStack {
            // Your existing UI
        }
        .interactiveHelp(.clinicianEncounter)
    }
}
```

### Step 5: Add Help Button to Navigation

Add a help button to your navigation bar:

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showHelp = true }) {
            Image(systemName: "questionmark.circle")
        }
    }
}
.sheet(isPresented: $showHelp) {
    HelpScreenView(context: .personalHealthDashboard)
}
```

### Step 6: Register App Intents

Each app needs to register its App Intents in the AppIntents target.

Create or update `AppIntents.swift` in each app:

```swift
// apps/PersonalHealthApp/iOS/AppIntents.swift

import AppIntents
import FoTCore

// Register all Personal Health intents
@available(iOS 16.0, *)
struct PersonalHealthAppIntents: AppIntent {
    static var title: LocalizedStringResource = "Personal Health"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// Register shortcuts
@available(iOS 16.0, *)
struct PersonalHealthShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        PersonalHealthShortcuts.appShortcuts
    }
}
```

### Step 7: Update Info.plist

Add required permissions:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Siri uses speech recognition to provide voice-guided help and commands.</string>

<key>NSMicrophoneUsageDescription</key>
<string>The app uses your microphone for Siri voice commands.</string>

<key>AppIntents</key>
<array>
    <!-- Your app's intents will be listed here automatically -->
</array>
```

### Step 8: Enable Siri & App Intents

In Xcode:

1. Select your app target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **Siri**
5. Add **App Intents**

---

## 📱 App-Specific Integration Details

### Personal Health App

**Onboarding File**: `apps/PersonalHealthApp/iOS/PersonalHealthOnboarding.swift` ✅  
**App Intents**: `packages/FoTCore/AppIntents/PersonalHealthIntents.swift` ✅  
**Help Contexts**: Defined in `PersonalHealthOnboarding.swift`

**Key Siri Commands**:
- "Log my mood in Personal Health"
- "Get crisis support in Personal Health"
- "Should I see a doctor in Personal Health"
- "Record my vitals in Personal Health"
- "Summarize my health in Personal Health"

**Views That Need Help**:
- Dashboard → `.interactiveHelp(.personalHealthDashboard)`
- Check-In → `.interactiveHelp(.personalHealthCheckIn)`
- Guidance → `.interactiveHelp(.personalHealthGuidance)`

---

### Clinician App

**Onboarding File**: `apps/ClinicianApp/iOS/ClinicianOnboarding.swift` ✅  
**App Intents**: `packages/FoTCore/AppIntents/ClinicianIntents.swift` ✅  
**Help Contexts**: Defined in `ClinicianOnboarding.swift`

**Key Siri Commands**:
- "Create new patient in Clinician"
- "Start encounter in Clinician"
- "Generate diagnosis in Clinician"
- "Check drug interactions in Clinician"
- "Generate SOAP note in Clinician"

**Views That Need Help**:
- Dashboard → `.interactiveHelp(.clinicianDashboard)`
- Encounter → `.interactiveHelp(.clinicianEncounter)`
- Diagnosis → `.interactiveHelp(.clinicianDiagnosis)`

---

### Legal App

**Onboarding File**: `apps/LegalApp/iOS/LegalOnboarding.swift` ✅  
**App Intents**: `packages/FoTCore/AppIntents/LegalIntents.swift` ✅  
**Help Contexts**: Defined in `LegalOnboarding.swift`

**Key Siri Commands**:
- "Create new case in Legal"
- "Search case law in Legal"
- "Show my deadlines in Legal"
- "Message client in Legal"

**Views That Need Help**:
- Dashboard → `.interactiveHelp(.legalDashboard)`
- Case → `.interactiveHelp(.legalCase)`
- Research → `.interactiveHelp(.legalResearch)`

---

### Education App

**Onboarding File**: `apps/EducationApp/iOS/EducationOnboarding.swift` ✅  
**App Intents**: `packages/FoTCore/AppIntents/EducationIntents.swift` ✅  
**Help Contexts**: Defined in `EducationOnboarding.swift`

**Key Siri Commands**:
- "Show my students in Education"
- "Create assignment in Education"
- "Show learning insights in Education"
- "Message parents in Education"

**Views That Need Help**:
- Dashboard → `.interactiveHelp(.educationDashboard)`
- Assignment → `.interactiveHelp(.educationAssignment)`

---

### Parent App

**Onboarding File**: `apps/ParentApp/iOS/ParentOnboarding.swift` ✅  
**App Intents**: `packages/FoTCore/AppIntents/ParentIntents.swift` ✅  
**Help Contexts**: Defined in `ParentOnboarding.swift`

**Key Siri Commands**:
- "Log milestone in Parent"
- "Show health records in Parent"
- "Get parenting advice in Parent"
- "Show family calendar in Parent"

**Views That Need Help**:
- Dashboard → `.interactiveHelp(.parentDashboard)`
- Milestone → `.interactiveHelp(.parentMilestone)`

---

## 🧪 Testing Checklist

### On-Device Testing (Required for Siri)

Siri features **only work on physical devices**, not simulators.

1. **Test Splash Screen**
   - [ ] Open app for first time
   - [ ] Verify logo animates smoothly
   - [ ] Check particles render correctly
   - [ ] Confirm transition to onboarding

2. **Test Siri Onboarding**
   - [ ] Verify Siri speaks introduction
   - [ ] Check wave animation syncs with speech
   - [ ] Test Previous/Next navigation
   - [ ] Test Replay button
   - [ ] Verify completion saves flag

3. **Test Tooltips**
   - [ ] Confirm tooltip appears on first visit
   - [ ] Verify it auto-dismisses after 5s
   - [ ] Check it doesn't appear again
   - [ ] Test manual dismissal

4. **Test Help Screen**
   - [ ] Open help from button
   - [ ] Test search functionality
   - [ ] Navigate to help topics
   - [ ] Test "Read Aloud" feature
   - [ ] Check video tutorial links

5. **Test Siri Commands** (On device with Siri enabled)
   - [ ] Say "Log my mood in Personal Health"
   - [ ] Say "Create new patient in Clinician"
   - [ ] Say "Search case law in Legal"
   - [ ] Say "Show my students in Education"
   - [ ] Say "Log milestone in Parent"
   - [ ] Verify each opens correct screen

6. **Test Siri Help**
   - [ ] Say "Explain app features in [App Name]"
   - [ ] Ask "How do I [feature] in [App Name]?"
   - [ ] Verify Siri provides helpful answers

---

## 🎨 Customization

### Change Splash Screen Colors

Edit the onboarding flow in each app:

```swift
AnimatedSplashScreen(
    appName: "Your App",
    appIcon: "your.icon.name",
    primaryColor: .yourColor,      // Change this
    secondaryColor: .anotherColor, // And this
    onComplete: { /* ... */ }
)
```

### Modify Onboarding Features

Edit the features array in each `*Onboarding.swift` file:

```swift
private var yourAppFeatures: [OnboardingFeature] {
    [
        OnboardingFeature(
            icon: "icon.name",
            title: "Your Feature",
            description: "Description here",
            siriCommand: "Your Siri command"
        ),
        // Add more features...
    ]
}
```

### Add More Help Topics

Extend `HelpContext` in your onboarding file:

```swift
extension HelpContext {
    static let yourNewContext = HelpContext(
        id: "unique_id",
        tooltipTitle: "Tooltip Title",
        tooltipMessage: "Helpful message",
        siriCommand: "Siri command",
        helpTopics: [
            HelpTopic(
                icon: "icon",
                title: "Topic Title",
                content: "Full content here",
                steps: ["Step 1", "Step 2"],
                relatedSiriCommand: "Command"
            )
        ],
        siriCommands: [
            SiriCommandHelp(
                command: "Command",
                description: "What it does"
            )
        ]
    )
}
```

### Disable Tooltips Temporarily

For testing or power users:

```swift
HelpManager.shared.tooltipsEnabled = false

// Or reset all tooltips:
HelpManager.shared.resetTooltips()
```

---

## 🚀 Deployment Checklist

Before releasing to production:

- [ ] Test all Siri commands on device
- [ ] Verify voice narration works
- [ ] Check splash screen on all device sizes
- [ ] Test help search with real content
- [ ] Add actual video tutorial URLs
- [ ] Complete knowledge base for all apps
- [ ] Test with VoiceOver for accessibility
- [ ] Test in different languages (if localized)
- [ ] Verify all tooltips appear once
- [ ] Test onboarding skip functionality

---

## 📊 Analytics (Optional)

Track user engagement with the new features:

```swift
// In HelpManager or your analytics service
func trackHelpUsage() {
    // Log which help topics are viewed most
    // Track Siri command usage
    // Measure onboarding completion rate
    // Track tooltip dismissal patterns
}
```

---

## 🐛 Troubleshooting

### Siri Commands Not Working

1. **Check Device Settings**
   - Settings → Siri & Search → Enable "Listen for 'Hey Siri'"
   - Settings → [Your App] → Siri & Shortcuts → Verify enabled

2. **Rebuild App Intents**
   - Clean build folder (Cmd+Shift+K)
   - Delete derived data
   - Rebuild project

3. **Check Info.plist**
   - Verify speech recognition permission is set
   - Ensure App Intents capability is added

### Voice Narration Not Playing

1. **Check Permissions**
   - App needs speech synthesis permission
   - Test on physical device (not simulator)

2. **Volume Settings**
   - Ensure device volume is up
   - Check silent mode is off

### Tooltips Not Appearing

1. **Check First Visit**
   - Tooltips only show once per ID
   - Reset with `HelpManager.shared.resetTooltips()`

2. **Check Flag**
   - Ensure `tooltipsEnabled` is true
   - Verify UserDefaults isn't corrupted

---

## 📚 Additional Resources

- **Full Documentation**: `UX_ENHANCEMENT_COMPLETE.md`
- **Splash Screens**: `packages/FoTUI/SplashScreen/AnimatedSplashScreen.swift`
- **Onboarding**: `packages/FoTUI/Onboarding/SiriGuidedOnboarding.swift`
- **Help System**: `packages/FoTUI/GuidedUI/InteractiveHelpSystem.swift`
- **Siri Knowledge**: `packages/FoTCore/AppIntents/SiriKnowledgeBase.swift`
- **App Intents**: `packages/FoTCore/AppIntents/*Intents.swift`

---

## ✅ Summary

You now have:

1. ✅ Beautiful splash screens for all apps
2. ✅ Siri-guided onboarding with voice narration
3. ✅ Context-aware help system with tooltips
4. ✅ Comprehensive Siri knowledge base
5. ✅ Natural voice commands throughout
6. ✅ Integration files for all 5 apps

**Next Steps:**

1. Integrate onboarding into each app's main file
2. Add `.interactiveHelp()` modifiers to key views
3. Register App Intents in each app
4. Test Siri commands on device
5. Add video tutorial recordings
6. Deploy to TestFlight for beta testing

**Your apps now have world-class UX!** 🎉

---

## 🆘 Need Help?

If you encounter issues:

1. Check this integration guide
2. Review `UX_ENHANCEMENT_COMPLETE.md` for details
3. Search Xcode console for errors
4. Test individual components in preview
5. Verify all files are in correct targets

**The UX enhancement is complete and ready for integration!** 🚀

