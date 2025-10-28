# Field of Truth - Installation & Setup Guide

**Complete guide for installing and configuring FoT Apps on Apple platforms**

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Developer Setup](#developer-setup)
3. [Installing from Source](#installing-from-source)
4. [Building Apps](#building-apps)
5. [Running in Simulator](#running-in-simulator)
6. [Deploying to Device](#deploying-to-device)
7. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Development Machine

| Component | Requirement |
|-----------|-------------|
| **Operating System** | macOS Sonoma (14.0) or later |
| **Xcode** | 15.2 or later (26.0.1 recommended) |
| **Swift** | 5.9 or later (6.2 recommended) |
| **RAM** | 8 GB minimum, 16 GB recommended |
| **Storage** | 10 GB free space minimum |
| **CPU** | Apple Silicon (M1/M2/M3) or Intel Core i5+ |

### Target Devices

| Platform | Minimum Version | Recommended |
|----------|-----------------|-------------|
| **iOS / iPadOS** | 17.0 | 17.4 or later |
| **macOS** | 14.0 (Sonoma) | 14.4 or later |
| **watchOS** | 10.0 | 10.4 or later |
| **visionOS** | 1.0 | 1.1 or later |

---

## Developer Setup

### 1. Install Xcode

1. Open the **App Store** app
2. Search for "Xcode"
3. Click **Get** or **Install**
4. Wait for download (≈13 GB)
5. Once installed, open Xcode
6. Accept the license agreement
7. Wait for additional components to install

### 2. Install Command Line Tools

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer
```

### 3. Install Homebrew (Optional but Recommended)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify installation
brew --version
```

### 4. Install Optional Development Tools

```bash
# Install xcodegen (for generating Xcode projects)
brew install xcodegen

# Install xcbeautify (for prettier build output)
brew install xcbeautify

# Install SwiftLint (for code style checking)
brew install swiftlint
```

---

## Installing from Source

### Clone the Repository

```bash
# Create a directory for your projects
mkdir -p ~/Projects
cd ~/Projects

# Clone the repository
git clone https://github.com/FortressAI/FoTApple.git
cd FoTApple

# Verify you're on the main branch
git branch
```

### Run Bootstrap

```bash
# Run pre-flight checks and resolve dependencies
make bootstrap
```

**Expected Output:**
```
[PREFLIGHT] Running pre-flight checks...
✓ Xcode installed
[PREFLIGHT] Xcode version: 26.0.1
✓ xcodegen installed
✓ xcbeautify installed
✓ Swift 6.2
✓ Package.swift found
✓ Directory apps exists
✓ Directory packages exists
✓ Directory Sources exists
✓ Directory Tests exists
✓ Makefile found
[PREFLIGHT] Checking available simulators...
✓ 10 iPhone simulators available
✓ Available disk space: 1.1Ti

[PREFLIGHT] Pre-flight checks complete!
✓ System is ready for building
```

---

## Building Apps

### Build All Targets

```bash
# Build everything (Swift packages + iOS apps)
make build
```

### Build Specific Apps

#### Clinician iOS App

```bash
cd apps/ClinicianApp/iOS

# Generate Xcode project (if not already generated)
xcodegen generate

# Build
./build.sh build

# Output:
# ✅ Build completed
```

#### Education K-18 iOS App

```bash
cd apps/EducationK18App/iOS

# The app structure exists but needs Xcode project generation
# This will be added in future releases
```

#### Legal US iOS App

```bash
cd apps/LegalUSApp/iOS

# The app structure exists but needs Xcode project generation
# This will be added in future releases
```

### Build Configurations

FoT supports three build configurations:

1. **Debug** (default)
   - Fast compilation
   - Debug symbols included
   - Logging enabled
   - Assertions enabled

2. **Release**
   - Optimized code
   - No debug symbols
   - Reduced logging
   - Smaller binary size

3. **Regulated**
   - Maximum compliance checks
   - Audit logging enabled
   - Enhanced security
   - Cryptographic receipts mandatory

```bash
# Build with specific configuration
CONFIGURATION=Release make build

# Build with Regulated profile
make regulated
```

---

## Running in Simulator

### Using Build Script

```bash
cd apps/ClinicianApp/iOS

# Build and launch in simulator
./build.sh run
```

**What happens:**
1. Builds the app
2. Boots iPhone 17 Pro simulator (if not running)
3. Installs the app
4. Launches the app
5. Opens Simulator.app

### Using Xcode

1. Open the project:
   ```bash
   cd apps/ClinicianApp/iOS
   open FoTClinicianApp.xcodeproj
   ```

2. In Xcode:
   - Select target: **FoTClinicianApp**
   - Select simulator: **iPhone 17 Pro** or **iPhone 17**
   - Click **Run** button (▶) or press `Cmd+R`

### Simulator Controls

| Action | Shortcut | Description |
|--------|----------|-------------|
| **Rotate Device** | `Cmd+←` or `Cmd+→` | Rotate simulator |
| **Home Button** | `Cmd+Shift+H` | Go to home screen |
| **Lock Screen** | `Cmd+L` | Lock the device |
| **Screenshot** | `Cmd+S` | Save screenshot |
| **Record Video** | `Cmd+R` | Record simulator video |
| **Shake Device** | `Ctrl+Cmd+Z` | Shake gesture |

---

## Deploying to Device

### Prerequisites

1. **Apple Developer Account** (free or paid)
2. **iPhone/iPad running iOS 17+**
3. **Lightning/USB-C cable**

### Setup Steps

#### 1. Connect Device

1. Connect your device to Mac with cable
2. Trust the computer on your device
3. Enter device passcode

#### 2. Configure Signing in Xcode

1. Open project in Xcode
2. Select project in Navigator
3. Select **FoTClinicianApp** target
4. Go to **Signing & Capabilities** tab
5. Check **Automatically manage signing**
6. Select your **Team** (Apple Developer Account)
7. Xcode will create provisioning profile automatically

#### 3. Build and Run

1. Select your physical device from destination menu
2. Click **Run** (▶) or press `Cmd+R`
3. First time: Enter device passcode when prompted
4. App installs and launches on device

#### 4. Trust Developer Certificate (First Time Only)

On your device:
1. Go to **Settings** → **General** → **VPN & Device Management**
2. Tap on your developer certificate
3. Tap **Trust "[Your Name]"**
4. Tap **Trust** in confirmation dialog

---

## Configuration

### Database Location

FoT apps store data locally on device:

```
iOS/iPadOS:
  Application Support/FoTClinician/fot.db

macOS:
  ~/Library/Application Support/FoTClinician/fot.db

watchOS:
  Synced from paired iPhone
```

### App Settings

Configure app behavior in `FoTClinicianApp.swift`:

```swift
init() {
    // Configure features
    AppConfig.shared.features.useLocalLLM = false
    AppConfig.shared.features.vqbitSuggestions = true
    
    // Configure VQbit engine
    AppConfig.shared.vqbit.dimension = 8096  // Auto-detects device
    AppConfig.shared.vqbit.useGPU = true     // Use Metal if available
}
```

### Compliance Settings

For regulated environments:

```swift
// Enable HIPAA compliance
AppConfig.shared.compliance.hipaa = true

// Enable audit logging
AppConfig.shared.compliance.auditLogging = true

// Enable cryptographic receipts
AppConfig.shared.compliance.mandatoryReceipts = true
```

---

## Running Tests

### All Tests

```bash
# Run all test suites
make test
```

### Specific Test Suites

```bash
# Swift package tests only
swift test

# Specific package
swift test --filter FoTCoreTests

# Specific test
swift test --filter testVirtueCollapse
```

### iOS App Tests

```bash
cd apps/ClinicianApp/iOS
./build.sh test
```

---

## Build Artifacts

After building, find artifacts at:

```
apps/ClinicianApp/iOS/.build/
├── Build/
│   └── Products/
│       └── Debug-iphonesimulator/
│           └── FoTClinicianApp.app   ← Your app bundle
└── Logs/
    └── Build/                         ← Build logs
```

---

## Clean Build

If you encounter build issues:

```bash
# Clean specific app
cd apps/ClinicianApp/iOS
./build.sh clean

# Clean Swift packages
swift package clean

# Clean all (nuclear option)
rm -rf .build
rm -rf apps/*/iOS/.build
swift package clean
```

---

## Verification Checklist

After installation, verify everything works:

- [ ] `make bootstrap` runs without errors
- [ ] `make build` completes successfully
- [ ] `make test` passes (except network-dependent tests)
- [ ] Simulator launches FoT Clinician app
- [ ] App displays patient list
- [ ] Can create new encounter
- [ ] SOAP note generation works
- [ ] VQbit engine initializes (check logs)
- [ ] Database created in Application Support

---

## Next Steps

After successful installation:

1. **Read User Guides**
   - [FoT Clinician User Guide](FOT_CLINICIAN_USER_GUIDE.md)
   - [FoT Education K-18 User Guide](FOT_EDUCATION_USER_GUIDE.md)
   - [FoT Legal US User Guide](FOT_LEGAL_USER_GUIDE.md)

2. **Configure for Your Use Case**
   - Set up HIPAA compliance (Clinician)
   - Configure FERPA settings (Education)
   - Add jurisdiction rules (Legal)

3. **Customize**
   - Modify domain rules
   - Add custom virtue weights
   - Configure VQbit dimensions

---

## Support

- **Documentation:** https://github.com/FortressAI/FoTApple/wiki
- **Issues:** https://github.com/FortressAI/FoTApple/issues
- **Discussions:** https://github.com/FortressAI/FoTApple/discussions

---

**Installation complete! You're ready to use Field of Truth. 🎉**

