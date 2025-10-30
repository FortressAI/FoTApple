# 🚀 Quick Start - UX Enhancement

## 5-Minute Integration Guide

Get beautiful splash screens, Siri-guided onboarding, and interactive help in **30 minutes per app**.

---

## Step 1: Update Your App's Main File (5 min)

### Personal Health Example

```swift
// apps/PersonalHealthApp/iOS/PersonalHealthApp.swift

import SwiftUI
import FoTUI  // ← Add this import

@main
struct PersonalHealthApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                // ← Add onboarding flow
                PersonalHealthOnboardingFlow {
                    hasCompletedOnboarding = true
                }
            } else {
                MainDashboardView()
                    .interactiveHelp(.personalHealthDashboard)  // ← Add help
            }
        }
    }
}
```

**That's it!** You now have:
- ✅ Beautiful animated splash screen
- ✅ Siri-guided onboarding with voice narration
- ✅ Interactive help on dashboard

---

## Step 2: Add Help to Key Screens (10 min)

Add `.interactiveHelp()` to important views:

```swift
// Personal Health Check-In Screen
struct HealthCheckInView: View {
    var body: some View {
        Form {
            // Your existing UI
        }
        .navigationTitle("Health Check-In")
        .interactiveHelp(.personalHealthCheckIn)  // ← Add this line
    }
}
```

**Available help contexts per app:**

### Personal Health
- `.personalHealthDashboard`
- `.personalHealthCheckIn`
- `.personalHealthGuidance`

### Clinician
- `.clinicianDashboard`
- `.clinicianEncounter`
- `.clinicianDiagnosis`

### Legal
- `.legalDashboard`
- `.legalCase`
- `.legalResearch`

### Education
- `.educationDashboard`
- `.educationAssignment`

### Parent
- `.parentDashboard`
- `.parentMilestone`

---

## Step 3: Register App Intents (10 min)

Create `AppIntents.swift` in your app:

```swift
// apps/PersonalHealthApp/iOS/AppIntents.swift

import AppIntents
import FoTCore

@available(iOS 16.0, *)
struct PersonalHealthIntentsProvider: AppIntentsProvider {
    static var appShortcuts: [AppShortcut] {
        PersonalHealthShortcuts.appShortcuts
    }
}
```

---

## Step 4: Enable Siri Capability (5 min)

In Xcode:
1. Select app target
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **Siri**
5. Add **App Intents**

---

## Step 5: Test (5 min)

### Test Onboarding
1. Delete app from simulator/device
2. Reinstall
3. Watch splash screen animate
4. Listen to Siri guide you through features

### Test Siri Commands (on device only)
- Say: "Log my mood in Personal Health"
- Say: "Explain app features in Personal Health"
- Say: "Get crisis support in Personal Health"

### Test Help
1. Tap dashboard
2. See tooltip appear
3. Tap "?" button
4. Search help topics

---

## 🎉 Done!

You've integrated:
- ✅ Animated splash screen
- ✅ Siri-guided onboarding
- ✅ Interactive help system
- ✅ Voice commands

**Total time: ~30 minutes per app**

---

## 📱 Repeat for Other Apps

Use the same pattern for each app:

### Clinician App
```swift
if !hasCompletedOnboarding {
    ClinicianOnboardingFlow {
        hasCompletedOnboarding = true
    }
} else {
    MainView()
        .interactiveHelp(.clinicianDashboard)
}
```

### Legal App
```swift
if !hasCompletedOnboarding {
    LegalOnboardingFlow {
        hasCompletedOnboarding = true
    }
} else {
    MainView()
        .interactiveHelp(.legalDashboard)
}
```

### Education App
```swift
if !hasCompletedOnboarding {
    EducationOnboardingFlow {
        hasCompletedOnboarding = true
    }
} else {
    MainView()
        .interactiveHelp(.educationDashboard)
}
```

### Parent App
```swift
if !hasCompletedOnboarding {
    ParentOnboardingFlow {
        hasCompletedOnboarding = true
    }
} else {
    MainView()
        .interactiveHelp(.parentDashboard)
}
```

---

## 🐛 Troubleshooting

### "Cannot find 'PersonalHealthOnboardingFlow' in scope"
- Make sure you imported `FoTUI`
- Clean build folder (Cmd+Shift+K)

### "Siri commands not working"
- Siri only works on physical devices
- Check Settings → Siri & Search → Enable "Hey Siri"
- Rebuild app after adding App Intents

### "Tooltips not appearing"
- They only show once per screen
- Reset with: `HelpManager.shared.resetTooltips()`

### "Voice narration not playing"
- Test on physical device (not simulator)
- Check device volume
- Ensure silent mode is off

---

## 📚 More Information

- **Full Details**: `UX_ENHANCEMENT_COMPLETE.md`
- **Integration Guide**: `INTEGRATION_GUIDE.md`
- **All Siri Commands**: `SIRI_COMMANDS_COMPLETE_LIST.md`
- **Executive Summary**: `UX_ENHANCEMENT_SUMMARY.md`

---

## ✅ Checklist

Before deploying:

- [ ] Integrated onboarding into all 5 apps
- [ ] Added help to key screens
- [ ] Registered App Intents
- [ ] Enabled Siri capability
- [ ] Tested splash screen
- [ ] Tested onboarding voice narration
- [ ] Tested Siri commands on device
- [ ] Tested help screens
- [ ] Tested tooltips

---

**Your apps now have world-class UX!** 🎉

Ready to deploy to TestFlight? Follow your existing deployment process - no special steps needed.

