# 🚀 Automated TestFlight Deployment System

Complete, production-ready system for deploying 5 iOS apps to TestFlight with **zero human interaction**.

---

## 📦 What's Included

This package contains everything you need for fully automated TestFlight deployments:

| File | Purpose |
|------|---------|
| `deploy_to_testflight.sh` | **Main script** - Deploys all 5 apps automatically |
| `deploy_single_app.sh` | **Single app script** - Deploy one app at a time |
| `SETUP_GUIDE.md` | **Complete setup guide** - Step-by-step instructions |
| `QUICK_START.md` | **Quick reference** - Checklist and common commands |
| `README.md` | This file - Overview and quick start |

---

## ⚡ Quick Start (3 Steps)

### 1️⃣ Get Your API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate: **Users and Access** → **Keys** → **App Store Connect API**
3. Create a new key with **App Manager** access
4. Download the `.p8` file and note your **Key ID** and **Issuer ID**

### 2️⃣ Install the Key

```bash
mkdir -p ~/.appstoreconnect/private_keys/
mv ~/Downloads/AuthKey_*.p8 ~/.appstoreconnect/private_keys/
```

### 3️⃣ Configure and Run

```bash
# Set your credentials
export APP_STORE_API_KEY_ID="YOUR_KEY_ID"
export APP_STORE_API_ISSUER_ID="YOUR_ISSUER_ID"

# Make executable
chmod +x deploy_to_testflight.sh

# Deploy all 5 apps!
./deploy_to_testflight.sh
```

**That's it!** The script handles everything else automatically.

---

## 🎯 Features

### ✅ Fully Automated
- No manual intervention required
- Auto-increments build numbers
- Automatic code signing
- Direct upload to TestFlight
- Comprehensive error handling

### ✅ Robust & Reliable
- Validates credentials before starting
- 3 automatic retry attempts for uploads
- Detailed logging for debugging
- Clean error messages
- Exit codes for CI/CD integration

### ✅ Production Ready
- Works with CI/CD systems (GitHub Actions, GitLab CI, etc.)
- Supports scheduled deployments (cron)
- Parallel-safe for multiple apps
- Configurable via environment variables

### ✅ Developer Friendly
- Clear progress indicators
- Detailed logs for each app
- Summary report at completion
- Individual app deployment option

---

## 📱 Apps Included

The system is configured for 5 apps:

1. **PersonalHealthApp** (`com.fot.PersonalHealth`)
2. **ClinicianApp** (`com.fot.ClinicianApp`)
3. **ParentApp** (`com.fot.ParentApp`)
4. **EducationApp** (`com.fot.EducationApp`)
5. **LegalApp** (`com.fot.LegalApp`)

All apps must be registered in App Store Connect before deployment.

---

## 🚀 Usage

### Deploy All 5 Apps

```bash
./deploy_to_testflight.sh
```

**Time:** 10-30 minutes depending on app sizes

### Deploy Single App

```bash
./deploy_single_app.sh 1   # PersonalHealthApp
./deploy_single_app.sh 2   # ClinicianApp
./deploy_single_app.sh 3   # ParentApp
./deploy_single_app.sh 4   # EducationApp
./deploy_single_app.sh 5   # LegalApp
```

**Time:** 2-6 minutes per app

---

## 📊 What Happens During Deployment

```
For each app:
  1. ✅ Validate credentials and files
  2. ✅ Auto-increment build number
  3. ✅ Clean previous builds
  4. ✅ Create archive (.xcarchive)
  5. ✅ Sign with automatic provisioning
  6. ✅ Export as .ipa
  7. ✅ Upload to TestFlight
  8. ✅ Retry up to 3 times if needed

After upload:
  • Builds appear in App Store Connect
  • Processing takes 5-15 minutes
  • Ready for testing after processing
```

---

## 📋 Expected Output

### Success:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Deploying: PersonalHealthApp
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ Incrementing build number...
  Build number: 23 → 24
▶ Creating archive...
  ✅ Archive created successfully
▶ Exporting and uploading to TestFlight...
  ✅ Successfully uploaded to TestFlight!
  ⏱️  Time taken: 142s

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 DEPLOYMENT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Success: 5
❌ Failed: 0

🎉 SUCCESS! All 5 apps deployed to TestFlight!
```

---

## 🔧 Configuration

### Environment Variables (Recommended)

Add to `~/.zshrc` or `~/.bash_profile`:

```bash
export APP_STORE_API_KEY_ID="A1B2C3D4E5"
export APP_STORE_API_ISSUER_ID="12345678-1234-1234-1234-123456789abc"
```

### Hardcoded in Script (Alternative)

Edit the scripts and replace:
- `YOUR_KEY_ID` with your actual Key ID
- `YOUR_ISSUER_ID` with your actual Issuer ID

---

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
name: Deploy to TestFlight
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Install API Key
      run: |
        mkdir -p ~/.appstoreconnect/private_keys/
        echo "${{ secrets.P8_KEY }}" > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.KEY_ID }}.p8
    
    - name: Deploy
      env:
        APP_STORE_API_KEY_ID: ${{ secrets.KEY_ID }}
        APP_STORE_API_ISSUER_ID: ${{ secrets.ISSUER_ID }}
      run: ./deploy_to_testflight.sh
```

### Scheduled Deployments

Daily at 2 AM:

```bash
crontab -e
# Add: 0 2 * * * cd /path/to/project && ./deploy_to_testflight.sh
```

See `SETUP_GUIDE.md` for more CI/CD examples (GitLab, Fastlane, etc.)

---

## 📂 Directory Structure

```
your-project/
├── apps/
│   ├── PersonalHealthApp/
│   │   └── iOS/
│   │       ├── PersonalHealthApp.xcodeproj
│   │       └── PersonalHealthApp/
│   ├── ClinicianApp/
│   │   └── iOS/
│   │       └── FoTClinicianApp.xcodeproj
│   └── ... (other apps)
│
├── deploy_to_testflight.sh      ← Main deployment script
├── deploy_single_app.sh          ← Single app deployment
├── SETUP_GUIDE.md                ← Complete setup instructions
├── QUICK_START.md                ← Quick reference
└── README.md                     ← This file

Generated during deployment:
├── build/
│   ├── archives/                 ← .xcarchive files
│   ├── export/                   ← .ipa files
│   ├── logs/                     ← Detailed logs
│   └── ExportOptions_*.plist     ← Export configurations
```

---

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "API key file not found" | Verify file at `~/.appstoreconnect/private_keys/AuthKey_*.p8` |
| "Archive failed" | Check logs in `build/logs/` - usually build errors |
| "Upload failed" | Script auto-retries 3 times, check internet/App Store status |
| "Directory not found" | Verify directory structure matches expected layout |

### Check Logs

```bash
# View all logs
ls -lh build/logs/

# View specific app log
cat build/logs/PersonalHealthApp_archive.log
cat build/logs/PersonalHealthApp_export.log
```

### Validate Setup

```bash
# Check API key file
ls -la ~/.appstoreconnect/private_keys/

# Check environment variables
echo $APP_STORE_API_KEY_ID
echo $APP_STORE_API_ISSUER_ID

# Test Xcode command line tools
xcodebuild -version
```

---

## 📚 Documentation

- **`SETUP_GUIDE.md`** - Complete setup instructions with CI/CD examples
- **`QUICK_START.md`** - Quick reference checklist and commands
- **Apple Docs**: [TestFlight](https://developer.apple.com/testflight/) | [API](https://developer.apple.com/documentation/appstoreconnectapi)

---

## ⏱️ Timeline

| Phase | Duration |
|-------|----------|
| **One-time setup** | 15-30 minutes |
| **Per deployment** | 10-30 minutes |
| **Processing in App Store Connect** | 5-15 minutes |
| **Total until testable** | 15-45 minutes |

---

## ✅ Prerequisites

- macOS with Xcode installed
- Xcode Command Line Tools
- Active Apple Developer Program membership
- All 5 apps registered in App Store Connect
- App Store Connect API Key with "App Manager" access

---

## 🎯 Best Practices

1. **Version Management**
   - Script auto-increments build numbers
   - Manually update version numbers for releases

2. **Testing Flow**
   - Deploy to TestFlight (automated)
   - Internal testing first
   - External testing when stable

3. **Build Frequency**
   - Daily for active development
   - Weekly for stable releases
   - On-demand for critical fixes

---

## 🔐 Security Notes

- The `.p8` key file is sensitive - never commit to git
- Store API credentials as environment variables or CI secrets
- The `.p8` file has permanent access - rotate if compromised
- Add `.p8` files and credentials to `.gitignore`

---

## 🆘 Support

1. Check `QUICK_START.md` for common issues
2. Review logs in `build/logs/`
3. See `SETUP_GUIDE.md` for detailed troubleshooting
4. Check [Apple System Status](https://developer.apple.com/system-status/)

---

## 📝 Customization

### Add More Apps

Edit the `APPS` array in `deploy_to_testflight.sh`:

```bash
declare -a APPS=(
    "YourApp:YourScheme:com.your.bundleid"
    # Add more apps here
)
```

### Change Build Settings

Modify the ExportOptions.plist generation section to customize:
- Code signing
- Bitcode settings
- Symbol upload
- Other export options

### Adjust Retry Logic

Change these variables:

```bash
MAX_UPLOAD_RETRIES=3
RETRY_DELAY=10
```

---

## 🎉 Ready to Deploy?

1. **Read**: `QUICK_START.md` for the checklist
2. **Setup**: Follow the 5 setup steps (takes 15 minutes)
3. **Run**: `./deploy_to_testflight.sh`
4. **Relax**: Script handles everything automatically!

---

**Questions?** See `SETUP_GUIDE.md` for comprehensive documentation.

**Need help?** Check `QUICK_START.md` for troubleshooting.

**Ready to automate?** Run the script and watch it work! 🚀
