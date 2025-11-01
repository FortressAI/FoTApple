# 🔄 Extension ↔ App Sync Guide

**Purpose:** Keep browser extensions perfectly aligned with Mac/iOS apps  
**Last Updated:** November 1, 2025  
**Status:** ✅ **100% Synced**

---

## 🎯 Quick Sync Check

```bash
cd /Users/richardgillespie/Documents/FoTApple
./safari-extension/sync_extensions_with_apps.sh
```

This automated script checks:
- ✅ Version parity across apps and extensions
- ✅ Native messaging hosts installation
- ✅ App Intents availability
- ✅ QFOT integration status
- ✅ DataMode implementation

---

## 📋 Sync Workflow

### Scenario 1: Adding New Feature to Mac/iOS App

**Example:** Adding "Export to PDF" feature to Clinician app

1. **Design & Implement in App**
   ```swift
   // In ClinicianApp/macOS/FoTClinicianMac/Views/PDFExportView.swift
   func exportToPDF() {
       // Implementation
   }
   ```

2. **Update Feature Parity Matrix**
   ```bash
   cd safari-extension
   # Edit FEATURE_PARITY_MATRIX.md
   # Add "PDF Export" row to Clinician features table
   ```

3. **Design Browser Integration** (if applicable)
   - Can users export web content to PDF via extension?
   - Should extension trigger Mac app's PDF export?
   - Update native messaging protocol

4. **Implement in Extension** (if applicable)
   ```javascript
   // In FoTSuite-Chrome/scripts/domains/clinician.js
   function exportToPDF() {
       // Send message to Mac app
       browser.runtime.sendNativeMessage('com.fotapple.clinician', {
           action: 'export_pdf',
           data: extractPageContent()
       });
   }
   ```

5. **Test Integration**
   ```bash
   # Load unpacked extension in browser
   # Test native messaging with Mac app
   # Verify PDF generation
   ```

6. **Bump Versions**
   ```bash
   # Update version in all manifests
   # apps/ClinicianApp/iOS/FoTClinician/Info.plist: 1.0.0 → 1.1.0
   # safari-extension/FoTSuite-Chrome/manifest.json: "version": "1.1.0"
   # Do the same for Firefox, Edge, Safari
   ```

7. **Re-package Extensions**
   ```bash
   cd safari-extension/FoTSuite-Chrome
   zip -r ../FoTSuite_Chrome_v1.1.zip . -x "*.DS_Store"
   # Repeat for Firefox and Edge
   ```

8. **Submit Updates**
   - Chrome Web Store: Upload new ZIP
   - Firefox Add-ons: Upload new ZIP
   - Microsoft Edge: Upload new ZIP
   - Safari: Build new DMG

9. **Update Documentation**
   ```bash
   # Update store listings with "New: PDF Export"
   # Update README.md
   # Update FEATURE_PARITY_MATRIX.md
   ```

---

### Scenario 2: Updating Browser Extension Only

**Example:** Adding better error handling to extension

1. **Make Extension Changes**
   ```javascript
   // Improve error handling in extension
   try {
       // Extension logic
   } catch (error) {
       console.error('Extension error:', error);
       showUserFriendlyErrorMessage();
   }
   ```

2. **Test on All Browsers**
   - Chrome: Load unpacked
   - Firefox: Load temporary add-on
   - Edge: Load unpacked
   - Safari: Rebuild and test

3. **Bump Extension Version Only**
   ```json
   // manifest.json: "version": "1.0.0" → "1.0.1"
   ```

4. **Re-package and Submit**
   - No need to update Mac/iOS apps
   - Only submit extension updates
   - Update FEATURE_PARITY_MATRIX.md with "Extension improvements" note

---

### Scenario 3: Adding New Voice Command

**Example:** Adding "Schedule Appointment" voice command to Clinician

1. **Create App Intent**
   ```swift
   // packages/FoTAppIntents/Sources/Clinician/ScheduleAppointmentIntent.swift
   @available(iOS 16.0, macOS 13.0, *)
   struct ScheduleAppointmentIntent: AppIntent {
       static var title: LocalizedStringResource = "Schedule Appointment"
       // Implementation
   }
   ```

2. **Register in App Shortcuts**
   ```swift
   // apps/ClinicianApp/iOS/FoTClinician/ClinicianAppShortcuts.swift
   AppShortcut(
       intent: ScheduleAppointmentIntent(),
       phrases: ["Schedule appointment in \(.applicationName)"],
       shortTitle: "Schedule",
       systemImageName: "calendar.badge.plus"
   )
   ```

3. **Update Extension** (if needed)
   - Add calendar detection in extension
   - Add "Schedule with FoT Clinician" context menu
   - Implement native messaging

4. **Update Documentation**
   ```markdown
   # FEATURE_PARITY_MATRIX.md
   Add to "Voice Commands Matrix" → Clinician (11 commands now)
   11. "Schedule appointment in FoT Clinician"
   ```

5. **Test Voice Command**
   ```bash
   # On Mac: "Hey Siri, schedule appointment in FoT Clinician"
   # On iOS: "Hey Siri, schedule appointment in FoT Clinician"
   # Verify intent fires correctly
   ```

---

## 🔗 Native Messaging Protocol

### Adding New Message Type

**Example:** Adding "Import Calendar" message

1. **Define Protocol in Matrix**
   ```markdown
   # FEATURE_PARITY_MATRIX.md - Clinician Native Messaging
   
   // Browser → Mac App
   {
       "action": "import_calendar",
       "data": {
           "event_title": "Patient Appointment",
           "event_date": "2024-11-15T14:00:00Z",
           "patient_id": "uuid",
           "duration": 30
       }
   }
   
   // Mac App → Browser
   {
       "status": "success",
       "message": "Appointment scheduled",
       "event_id": "uuid"
   }
   ```

2. **Implement in Extension**
   ```javascript
   // FoTSuite-Chrome/scripts/domains/clinician.js
   async function importCalendar(eventData) {
       const response = await browser.runtime.sendNativeMessage(
           'com.fotapple.clinician',
           {
               action: 'import_calendar',
               data: eventData
           }
       );
       return response;
   }
   ```

3. **Implement in Mac App**
   ```swift
   // ClinicianApp/macOS/FoTClinicianMac/NativeMessaging/MessageHandler.swift
   case "import_calendar":
       let eventData = message["data"] as? [String: Any]
       // Create calendar event
       return ["status": "success", "message": "Appointment scheduled"]
   ```

4. **Test Integration**
   ```bash
   # Test native messaging between browser and Mac app
   # Verify calendar event creation
   ```

---

## 🧪 Testing Checklist

### When Syncing Features

- [ ] **Mac App:** Feature works correctly
- [ ] **iOS App:** Feature works correctly (if applicable)
- [ ] **Browser Extension (Chrome):** Feature integrated correctly
- [ ] **Browser Extension (Firefox):** Feature integrated correctly
- [ ] **Browser Extension (Edge):** Feature integrated correctly
- [ ] **Browser Extension (Safari):** Feature integrated correctly
- [ ] **Native Messaging:** Communication working Mac ↔ Browser
- [ ] **Offline Mode:** Extension works without Mac app running
- [ ] **Voice Commands:** Siri integration working (if applicable)
- [ ] **QFOT Integration:** Blockchain validation working (if applicable)
- [ ] **Data Mode:** Respects Training/Live mode (apps only)
- [ ] **Documentation:** All docs updated

---

## 📚 Documentation Updates

### Files to Update When Syncing

1. **FEATURE_PARITY_MATRIX.md**
   - Add new feature to appropriate domain table
   - Update version numbers
   - Document native messaging protocol
   - Update voice commands if applicable

2. **Store Listings** (if user-facing feature)
   - Chrome Web Store: Update description
   - Firefox Add-ons: Update description
   - Microsoft Edge: Update description
   - Safari App Store: Update app description

3. **README.md** (main repo)
   - Update feature list
   - Update screenshots if UI changed

4. **CHANGELOG.md** (create if doesn't exist)
   ```markdown
   ## [1.1.0] - 2024-11-15
   
   ### Added
   - PDF export functionality in Clinician app
   - "Export to PDF" browser extension integration
   - Calendar import via native messaging
   
   ### Changed
   - Improved error handling in all extensions
   
   ### Fixed
   - Native messaging timeout issue on slow connections
   ```

---

## 🎯 Version Number Strategy

### Semantic Versioning

Format: `MAJOR.MINOR.PATCH`

**MAJOR (1.x.x):** Breaking changes
- New incompatible native messaging protocol
- Major UI redesign
- Platform requirement changes

**MINOR (x.1.x):** New features (backward compatible)
- New voice command
- New extension capability
- New website support

**PATCH (x.x.1):** Bug fixes (backward compatible)
- Error handling improvements
- Performance optimizations
- UI polish

### Keep Versions Aligned

**Rule:** Browser extensions should match Mac/iOS app major.minor versions

Example:
- Mac App: `v1.2.0` → Extensions: `v1.2.0` or `v1.2.1`
- If extension has bug fixes independent of app: `v1.2.1`
- If app has new features not yet in extension: Mark in FEATURE_PARITY_MATRIX.md

---

## 🚨 Common Issues & Solutions

### Issue 1: Native Messaging Not Working

**Symptoms:**
- Extension can't communicate with Mac app
- "Native host has exited" error

**Solutions:**
1. **Check host manifest is installed:**
   ```bash
   ls -la "$HOME/Library/Application Support/Safari/NativeMessagingHosts/"
   ls -la "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/"
   ls -la "$HOME/Library/Application Support/Mozilla/NativeMessagingHosts/"
   ```

2. **Verify Mac app path in manifest:**
   ```json
   {
       "path": "/Applications/FoT Clinician.app/Contents/MacOS/FoT Clinician"
   }
   ```

3. **Ensure Mac app is running:**
   - Native messaging requires Mac app to be running
   - Extension should gracefully handle offline mode

### Issue 2: Version Mismatch

**Symptoms:**
- Extension expects feature that doesn't exist in app
- App sends message extension doesn't understand

**Solutions:**
1. **Run sync check:**
   ```bash
   ./safari-extension/sync_extensions_with_apps.sh
   ```

2. **Update both to same version:**
   - Bump app version
   - Bump extension version
   - Re-build and re-package both

3. **Implement backward compatibility:**
   ```javascript
   // Extension checks app version
   const appVersion = await getAppVersion();
   if (compareVersions(appVersion, '1.2.0') >= 0) {
       // Use new feature
   } else {
       // Use old feature or fallback
   }
   ```

### Issue 3: Feature Works in App But Not Extension

**Symptoms:**
- Feature available in Mac/iOS app
- Extension can't trigger it

**Solutions:**
1. **Check native messaging protocol:**
   - Is message action defined in Mac app?
   - Is extension sending correct message format?

2. **Add to extension:**
   - Implement feature in extension content script
   - Add UI elements (buttons, context menus)
   - Test on all supported websites

3. **Update documentation:**
   - Add to FEATURE_PARITY_MATRIX.md
   - Mark as "Extension support added"

---

## 📊 Sync Frequency

### Recommended Schedule

**Daily (if active development):**
- Quick version check
- Native messaging test
- Basic feature verification

**Weekly:**
- Full sync check via script
- Review FEATURE_PARITY_MATRIX.md
- Update any documentation gaps

**Before Each Release:**
- Complete sync check
- Test all integration points
- Update all version numbers
- Review all documentation

---

## ✅ Current Sync Status

**Last Full Sync:** November 1, 2025

### Apps
- ✅ Clinician Mac: v1.0.0
- ✅ Clinician iOS: v1.0.0
- ✅ Legal Mac: v1.0.0
- ✅ Legal iOS: v1.0.0
- ✅ Education Mac: v1.0.0
- ✅ Education iOS: v1.0.0
- ✅ Personal Health Mac: v1.0.0
- ✅ Personal Health iOS: v1.0.0

### Extensions
- ✅ FoT Suite Chrome: v1.0.0
- ✅ FoT Suite Firefox: v1.0.0
- ✅ FoT Suite Edge: v1.0.0
- ✅ FoT Suite Safari: v1.0.0
- ✅ QFOT Wallet Chrome: v1.0.0
- ✅ QFOT Wallet Firefox: v1.0.0
- ✅ QFOT Wallet Edge: v1.0.0
- ✅ QFOT Wallet Safari: v1.0.0

### Native Messaging
- ✅ Safari: 4 hosts installed
- ✅ Chrome: 4 hosts installed
- ✅ Firefox: 4 hosts installed

**Feature Parity: 100%** 🎉

---

## 🔗 Related Documentation

- **FEATURE_PARITY_MATRIX.md** - Complete feature comparison
- **CROSS_BROWSER_EXTENSIONS_COMPLETE.md** - Browser extension overview
- **DEPLOYMENT_GUIDE.md** - Safari deployment process
- **CHROME_WEB_STORE_SUBMISSION.md** - Chrome submission guide
- **FIREFOX_ADDONS_SUBMISSION.md** - Firefox submission guide

---

**Keep this guide updated as your sync process evolves!**

