# Field of Truth - Troubleshooting Guide

**Solutions to common problems across all FoT applications**

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Build & Compilation Problems](#build--compilation-problems)
3. [Runtime Errors](#runtime-errors)
4. [Database Issues](#database-issues)
5. [VQbit Engine Problems](#vqbit-engine-problems)
6. [Network & API Issues](#network--api-issues)
7. [Performance Problems](#performance-problems)
8. [Platform-Specific Issues](#platform-specific-issues)
9. [Data & Privacy](#data--privacy)
10. [Getting Additional Help](#getting-additional-help)

---

## Installation Issues

### Problem: "xcodebuild: command not found"

**Symptoms:**
```
make: xcodebuild: command not found
```

**Cause:** Xcode not installed or command line tools not configured

**Solution:**
```bash
# 1. Install Xcode from App Store (if not installed)

# 2. Set Xcode path
sudo xcode-select --switch /Applications/Xcode.app

# 3. Verify
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# 4. Install command line tools
xcode-select --install
```

---

### Problem: "swift: command not found"

**Symptoms:**
```
swift: command not found
```

**Cause:** Swift toolchain not in PATH

**Solution:**
```bash
# Check if Xcode is installed
xcode-select -p

# If Xcode is installed, add to PATH
export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"

# Add to ~/.zshrc or ~/.bash_profile to make permanent
echo 'export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

---

### Problem: "Unable to resolve package dependencies"

**Symptoms:**
```
error: Dependencies could not be resolved
```

**Cause:** Network issues, incorrect Package.swift, or cache problems

**Solution:**
```bash
# 1. Clear package cache
rm -rf ~/.swiftpm
rm -rf .build

# 2. Reset package
swift package reset

# 3. Try resolving again
swift package resolve

# 4. If still failing, check Package.swift syntax
swift package dump-package

# 5. Check network connection
ping github.com
```

---

### Problem: "No available simulators"

**Symptoms:**
```
xcodebuild: error: Unable to find a device matching...
Available destinations: (none)
```

**Cause:** Simulators not installed or Xcode needs full installation

**Solution:**
```bash
# 1. Open Xcode
open /Applications/Xcode.app

# 2. Go to Preferences → Components
# Install iOS simulators

# 3. Or install via command line
xcodebuild -downloadPlatform iOS

# 4. List available simulators
xcrun simctl list devices

# 5. If empty, reinstall Xcode or run
sudo xcode-select --reset
```

---

## Build & Compilation Problems

### Problem: Build fails with "Module not found"

**Symptoms:**
```
error: no such module 'FoTCore'
error: no such module 'VQbitSubstrate'
```

**Cause:** Package dependencies not resolved or build order issue

**Solution:**
```bash
# 1. Clean build
swift package clean

# 2. Resolve dependencies
swift package resolve

# 3. Build in correct order
swift build

# 4. For Xcode projects, regenerate
cd apps/ClinicianApp/iOS
xcodegen generate

# 5. Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

---

### Problem: "Resource not found" warnings

**Symptoms:**
```
warning: Invalid Resource 'Resources': File not found
warning: Invalid Resource 'Shaders': File not found
```

**Cause:** Resources declared in Package.swift but files don't exist

**Solution:**
```bash
# 1. Check if resource directories exist
ls packages/FoTCore/Sources/Resources
ls packages/VQbitSubstrate/Sources/Shaders

# 2. If directories don't exist, create them or remove from Package.swift

# 3. For FoTCore Resources (optional):
mkdir -p packages/FoTCore/Sources/Resources

# 4. For VQbit Shaders (Metal shaders, not yet implemented):
mkdir -p packages/VQbitSubstrate/Sources/Shaders

# 5. Rebuild
swift build
```

---

### Problem: "Source files should be located under Tests/"

**Symptoms:**
```
warning: Source files for target FoTEducationK18Tests should be...
```

**Cause:** Test targets declared but test files don't exist

**Solution:**
```bash
# Option 1: Create test directories
mkdir -p packages/FoTEducationK18/Tests
mkdir -p packages/FoTLegalUS/Tests

# Option 2: Remove test target declarations from Package.swift
# (Already fixed in updated Package.swift)
```

---

### Problem: Swift version mismatch

**Symptoms:**
```
error: package requires Swift 5.9 but you have Swift 5.8
```

**Cause:** Outdated Xcode version

**Solution:**
1. Update Xcode to latest version (App Store)
2. Or specify older Swift version in Package.swift (not recommended)
3. Check Swift version:
   ```bash
   swift --version
   # Should be 5.9 or later
   ```

---

## Runtime Errors

### Problem: App crashes on launch

**Symptoms:**
- App opens briefly then closes
- Simulator shows black screen
- Console shows crash log

**Diagnosis:**
```bash
# Check console logs
# iOS Simulator:
xcrun simctl spawn booted log stream --level debug | grep FoT

# Device:
# Connect device, open Console.app, filter by process name
```

**Common Causes & Solutions:**

#### 1. Database Initialization Failure

```swift
// Error in logs:
fatal error: unable to create database

// Solution: Check Application Support directory
// iOS: Settings → General → iPhone Storage → App → Delete
// macOS: ~/Library/Application Support/FoTClinician/
```

#### 2. VQbit Engine Initialization Failure

```swift
// Error in logs:
VQbitEngineError.notConfigured

// Solution: Reduce dimension or disable GPU
AppConfig.shared.vqbit.dimension = 2048
AppConfig.shared.vqbit.useGPU = false
```

#### 3. Missing Entitlements

```
error: Entitlements file missing
```

**Solution:**
- Regenerate Xcode project: `xcodegen generate`
- Check Info.plist exists
- Verify signing settings

---

### Problem: "Thread 1: Fatal error: Unexpectedly found nil"

**Symptoms:**
- Crash when accessing patient/student/case data
- Nil pointer exception

**Cause:** Optional unwrapping of nil value

**Solution:**
```swift
// Check for nil before using
if let patient = appState.currentPatient {
    // Use patient safely
} else {
    // Handle nil case
    print("No patient selected")
}
```

---

## Database Issues

### Problem: "Database is locked"

**Symptoms:**
```
error: database is locked
SQLite error code 5: SQLITE_BUSY
```

**Cause:** Multiple simultaneous access attempts or unclosed connections

**Solution:**
```bash
# 1. Force quit app
killall FoTClinicianApp

# 2. Delete database (⚠️ WARNING: Deletes all data)
# iOS Simulator:
xcrun simctl get_app_container booted com.fot.ClinicianApp data
# Navigate to directory and delete fot.db

# macOS:
rm ~/Library/Application\ Support/FoTClinician/fot.db*

# 3. Restart app (will recreate database)
```

**Prevention:**
- Always close database connections
- Use `defer { db.close() }`
- Don't share database handle across threads

---

### Problem: "Database migration failed"

**Symptoms:**
```
error: GRDB migration failed
error: column not found
```

**Cause:** Database schema changed but migration not applied

**Solution:**
```bash
# Option 1: Delete database and start fresh (⚠️ loses data)
rm fot.db*

# Option 2: Manual migration (for production)
# Write migration script in PatientStore.swift
```

---

### Problem: Data not persisting

**Symptoms:**
- Data entered but disappears on app restart
- Changes not saved

**Diagnosis:**
```swift
// Check if database is writable
let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
print("Database location: \(url)")
```

**Solutions:**
1. Check file permissions
2. Ensure save() is called
3. Check for errors in save methods
4. Verify Application Support directory exists

---

## VQbit Engine Problems

### Problem: "VQbit Engine initialization failed"

**Symptoms:**
```
⚠️ VQbit Engine initialization failed
error: VQbitEngineError.outOfMemory
```

**Cause:** Insufficient RAM for requested dimension

**Solution:**
```swift
// Reduce dimension based on device

// Option 1: Let engine auto-detect
let engine = try await VQbitEngineFactory.create()

// Option 2: Manual dimension
let config = VQbitConfig(dimension: 2048) // Down from 8096
let engine = try await VQbitEngineFactory.create(config: config)

// Option 3: Force CPU (no GPU)
let config = VQbitConfig(useGPU: false)
let engine = try await VQbitEngineFactory.create(config: config)
```

---

### Problem: "Metal device not found"

**Symptoms:**
```
warning: Metal device not available, using CPU fallback
```

**Cause:** Device doesn't support Metal or Metal is disabled

**Solution:**
```swift
// This is expected on some devices - CPU fallback works fine
// To suppress warning, explicitly use CPU:

let config = VQbitConfig(useGPU: false)
let engine = try await VQbitEngineFactory.create(config: config)
```

---

### Problem: VQbit operations very slow

**Symptoms:**
- Long delays (>5 seconds) for decisions
- UI freezing
- High CPU usage

**Solutions:**
```swift
// 1. Reduce dimension
AppConfig.shared.vqbit.dimension = 2048 // or lower

// 2. Use deterministic mode (faster)
AppConfig.shared.vqbit.seed = 42

// 3. Disable VQbit suggestions
AppConfig.shared.features.vqbitSuggestions = false

// 4. Check device capability
let device = VQbitEngineFactory.detectDevice()
print("Device: \(device)")
// Adjust dimension accordingly
```

---

## Network & API Issues

### Problem: RxNav API calls failing

**Symptoms:**
```
error: serverError(404)
error: serverError(400)
[Network] Drug interaction check failed
```

**Cause:** RxNav API unavailable, rate limited, or API changed

**Solution:**
```bash
# 1. Check RxNav status
curl https://rxnav.nlm.nih.gov/REST/version

# 2. Verify internet connection
ping rxnav.nlm.nih.gov

# 3. Check API limits (RxNav is free but has rate limits)
# Wait 1 minute and try again

# 4. Update RxNavClient if API changed
# Check https://lhncbc.nlm.nih.gov/RxNav/APIs/

# 5. Skip network tests
swift test --skip RxNavClientTests
```

---

### Problem: "Network request timed out"

**Symptoms:**
```
error: URLError.timedOut
error: The request timed out
```

**Cause:** Slow network, firewall, or API down

**Solution:**
1. Check internet connection
2. Try different network (cellular vs. Wi-Fi)
3. Check firewall settings
4. Increase timeout:
   ```swift
   var request = URLRequest(url: url)
   request.timeoutInterval = 30 // Increase from default
   ```

---

## Performance Problems

### Problem: App running slowly

**Symptoms:**
- UI lag
- Slow scrolling
- Delayed response to taps
- High battery drain

**Diagnosis:**
```bash
# Profile with Instruments
1. Open Xcode
2. Product → Profile (Cmd+I)
3. Select "Time Profiler" or "Allocations"
4. Run and identify bottlenecks
```

**Solutions:**

#### 1. VQbit Dimension Too High

```swift
// Reduce dimension
AppConfig.shared.vqbit.dimension = 2048
```

#### 2. Database Queries Not Optimized

```swift
// Add indexes
try db.create(index: "idx_patients_mrn", on: "patients", columns: ["mrn"])
```

#### 3. Too Much Data in Memory

```swift
// Implement pagination
let pageSize = 20
let patients = try Patient.fetchAll(db, limit: pageSize, offset: currentPage * pageSize)
```

#### 4. Background Tasks on Main Thread

```swift
// Move heavy work off main thread
Task.detached {
    let result = await heavyComputation()
    await MainActor.run {
        self.updateUI(result)
    }
}
```

---

### Problem: High memory usage

**Symptoms:**
- App using >500MB RAM
- Memory warnings
- App killed by system

**Solutions:**

```swift
// 1. Reduce VQbit dimension
AppConfig.shared.vqbit.dimension = 1024

// 2. Release unused objects
weak var weakSelf = self

// 3. Clear caches periodically
URLCache.shared.removeAllCachedResponses()

// 4. Profile with Instruments (Leaks, Allocations)
```

---

## Platform-Specific Issues

### iOS-Specific Problems

#### Problem: "Developer Mode disabled"

**iOS 16+ Requirement:**

1. Go to **Settings** → **Privacy & Security**
2. Scroll to **Developer Mode**
3. Enable **Developer Mode**
4. Restart device
5. Confirm when prompted

#### Problem: "Untrusted Enterprise Developer"

1. Go to **Settings** → **General** → **VPN & Device Management**
2. Tap your developer certificate
3. Tap **Trust "[Your Name]"**
4. Confirm

---

### macOS-Specific Problems

#### Problem: "App is damaged and can't be opened"

**Cause:** Gatekeeper blocking unsigned app

**Solution:**
```bash
# Remove quarantine attribute
xattr -cr /Applications/FoTClinician.app

# Or allow in System Preferences
# System Preferences → Security & Privacy → General
# Click "Open Anyway"
```

#### Problem: Sandbox restrictions

**Symptoms:**
```
error: Operation not permitted
error: Sandbox violation
```

**Solution:**
- Add entitlements in Xcode
- Or disable sandbox (development only)
- Check Console.app for sandboxd errors

---

### watchOS-Specific Problems

#### Problem: "Waiting for Apple Watch to become available"

**Solutions:**
1. Ensure watch is paired with iPhone
2. Wake up watch (tap screen)
3. Trust computer on watch
4. Restart Xcode

---

## Data & Privacy

### Problem: Unable to access patient data (HIPAA)

**Symptoms:**
```
error: Access denied
error: PHI encryption key not found
```

**Cause:** Device not configured for HIPAA compliance

**Solution:**
```swift
// 1. Enable HIPAA mode
AppConfig.shared.compliance.hipaa = true

// 2. Ensure device encryption enabled
// iOS: Settings → Face ID/Touch ID & Passcode → Data Protection
// Should say "Data protection is enabled"

// 3. Regenerate encryption keys
// Delete and reinstall app (⚠️ loses data)
```

---

### Problem: FERPA consent not recorded

**Symptoms:**
```
warning: Student data accessed without guardian consent
```

**Solution:**
```swift
// Require consent before access
guard student.guardianConsent else {
    showConsentRequired()
    return
}
```

---

## Getting Additional Help

### Diagnostic Information to Collect

When reporting issues, include:

```bash
# 1. System Information
sw_vers
xcodebuild -version
swift --version

# 2. App Version
# From app: Settings → About

# 3. Console Logs
# iOS Simulator: Terminal → `xcrun simctl spawn booted log stream`
# macOS: Console.app → filter by "FoT"

# 4. Crash Reports
# ~/Library/Logs/DiagnosticReports/

# 5. Database Schema (if data issue)
sqlite3 fot.db ".schema"

# 6. VQbit Status
# From app logs: Look for "VQbit Engine initialized"
```

---

### Support Channels

1. **GitHub Issues**
   - https://github.com/FortressAI/FoTApple/issues
   - Include diagnostic info above
   - Tag with appropriate label (bug, question, etc.)

2. **GitHub Discussions**
   - https://github.com/FortressAI/FoTApple/discussions
   - For questions and community support

3. **Documentation**
   - https://github.com/FortressAI/FoTApple/wiki
   - Check FAQ and known issues

4. **Stack Overflow**
   - Tag: `field-of-truth` and `swiftui`

---

### Emergency Procedures

#### Complete Reset (⚠️ Loses ALL Data)

```bash
# iOS Simulator
xcrun simctl erase all

# iOS Device
# Settings → General → Transfer or Reset iPhone → Erase All Content and Settings

# macOS
rm -rf ~/Library/Application\ Support/FoTClinician/
rm -rf ~/Library/Caches/com.fot.ClinicianApp/

# Reinstall app
```

#### Export Data Before Reset

*Future Feature - Coming Q1 2026*

Planned:
- Export to JSON
- Export to CSV
- Export receipts
- Backup database file

---

### Common Error Codes

| Error Code | Meaning | Solution |
|------------|---------|----------|
| **SQLITE_BUSY (5)** | Database locked | Force quit, restart |
| **SQLITE_LOCKED (6)** | Table locked | Close other connections |
| **SQLITE_NOMEM (7)** | Out of memory | Free memory, reduce data |
| **SQLITE_READONLY (8)** | Database read-only | Check file permissions |
| **SQLITE_CORRUPT (11)** | Database corrupt | Restore from backup or reset |
| **VQbitEngineError.notConfigured** | Engine not initialized | Restart app |
| **VQbitEngineError.outOfMemory** | RAM insufficient | Reduce dimension |
| **NetworkError.timeout** | Request timeout | Check internet, retry |
| **NetworkError.serverError(400)** | Bad API request | Update app |
| **NetworkError.serverError(404)** | API endpoint not found | Check API status |
| **NetworkError.serverError(500)** | Server error | Retry later |

---

## Preventive Maintenance

### Weekly Tasks

- ✅ Backup database
- ✅ Clear cache if >100MB
- ✅ Update to latest version
- ✅ Review crash logs

### Monthly Tasks

- ✅ Export audit logs
- ✅ Archive old data
- ✅ Vacuum database
- ✅ Review performance

### Quarterly Tasks

- ✅ Full data export
- ✅ Test disaster recovery
- ✅ Update documentation
- ✅ Security audit

---

**Keep Field of Truth running smoothly! If issues persist after trying these solutions, please open a GitHub issue with full diagnostic information.**

