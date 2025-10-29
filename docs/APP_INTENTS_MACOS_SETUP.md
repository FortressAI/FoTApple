# macOS App Intents Setup & Testing

## ✅ Completed Setup

### PersonalHealthMac
- ✅ Created `HealthAppShortcuts.swift` with 6 app shortcuts
- ✅ Added `NSAppIntentsPackages` to `Info.plist`
- ✅ Added `FoT continues dependency to `project.yml`
- ✅ Regenerated Xcode project

### FoTClinicianMac
- ✅ Created `ClinicianAppShortcuts.swift` with 6 app shortcuts
- ✅ Added `NSAppIntentsPackages` to `Info.plist`
- ✅ Added `FoTAppIntents` dependency to `project.yml`
- ✅ Regenerated Xcode project

## 🧪 Testing App Intents

### Prerequisites
1. Build the macOS apps from Xcode
2. Install apps on macOS device (App Intents require real device, not simulator)
3. Enable Siri on macOS: System Settings → Siri & Spotlight

### Test Commands

#### PersonalHealthMac - "My Health"
Try these Siri commands:
```
"Hey Siri, record health check-in in My Health"
"Hey Siri, log my health in My Health"
"Hey Siri, record my vitals in My Health"
"Hey Siri, log my mood in My Health"
"Hey Siri, get crisis support in My Health"
"Hey Siri, get health guidance in My Health"
```

#### FoTClinicianMac - "FoT Clinician"
Try these Siri commands:
```
"Hey Siri, start patient encounter in FoT Clinician"
"Hey Siri, add patient vitals in FoT Clinician"
"Hey Siri, record diagnosis in FoT Clinician"
"Hey Siri, prescribe medication in FoT Clinician"
"Hey Siri, summarize patient in FoT Clinician"
"Hey Siri, end encounter in FoT Clinician"
```

### Discovery Test
To see all available shortcuts:
```
"Hey Siri, what can I do in [App Name]?"
```

This will list all registered App Shortcuts.

## 🔍 Troubleshooting

### Siri doesn't recognize the app
1. **Check app is installed**: Apps must be installed (not just built) for Siri to discover intents
2. **Wait for indexing**: macOS may need a few minutes to index App Intents after installation
3. **Restart Siri**: System Settings → Siri → Disable and re-enable
4. **Use full app name**: Make sure to use the exact app name as shown in Applications folder

### App Shortcuts not appearing
1. **Verify Info.plist**: Check `NSAppIntentsPackages` contains "FieldOfTruth"
2. **Verify project.yml**: Ensure `FoTAppIntents` is in dependencies
3. **Regenerate project**: Run `xcodegen generate` in the app directory
4. **Clean build**: Xcode → Product → Clean Build Folder (Shift+Cmd+K)

### Build errors
1. **Missing import**: Ensure shortcuts file imports `FoTAppIntents`
2. **Intent not found**: Verify intent names match those in `packages/FoTCore/AppIntents/`
3. **Availability check**: Ensure `@available(iOS 16.0, macOS 13.0, watchOS 9.就无法, *)` is present

## 📝 Next Steps

1. Test all voice commands on actual macOS device
2. Verify each intent performs correctly
3. Test on macOS 13.0+ (required for App Intents)
4. Document any issues or improvements needed

## ✅ Verification Checklist

- [ ] PersonalHealthMac builds successfully
- [ ] FoTClinicianMac builds successfully
- [ ] Apps install on macOS device
- [ ] Siri recognizes app name
- [ ] At least one voice command works
- [ ] "What can I do" command lists shortcuts
- [ ] All 6 shortcuts for each app are discoverable

