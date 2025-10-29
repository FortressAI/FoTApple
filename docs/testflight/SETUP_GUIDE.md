# 🚀 Automated TestFlight Deployment - Setup Guide

This guide will help you set up **fully automated, zero-human-interaction** TestFlight deployments for all 5 apps.

---

## 📋 Prerequisites Checklist

### ✅ 1. Apple Developer Account Setup

- [ ] Active Apple Developer Program membership ($99/year)
- [ ] All 5 apps registered in App Store Connect
- [ ] Bundle IDs match your script configuration:
  - `com.fot.PersonalHealth`
  - `com.fot.ClinicianApp`
  - `com.fot.ParentApp`
  - `com.fot.EducationApp`
  - `com.fot.LegalApp`

### ✅ 2. App Store Connect API Key Setup

1. **Generate the API Key:**
   - Log in to [App Store Connect](https://appstoreconnect.apple.com/)
   - Navigate to: **Users and Access** → **Keys** → **App Store Connect API**
   - Click the **(+)** button
   - Name: "TestFlight Automation" (or whatever you prefer)
   - Access: **App Manager** (minimum required)
   - Click **Generate**

2. **Save Your Credentials:**
   - **Key ID**: Copy this (e.g., `A1B2C3D4E5`)
   - **Issuer ID**: Copy this UUID
   - **Download** the `.p8` file (only downloadable ONCE!)
   - Store safely - you cannot re-download this file

3. **Install the Key File:**
   ```bash
   # Create the directory
   mkdir -p ~/.appstoreconnect/private_keys/
   
   # Move your downloaded key file there
   # Replace YOUR_KEY_ID with your actual Key ID
   mv ~/Downloads/AuthKey_YOUR_KEY_ID.p8 ~/.appstoreconnect/private_keys/
   
   # Verify it's there
   ls -la ~/.appstoreconnect/private_keys/
   ```

### ✅ 3. Xcode & Command Line Tools

```bash
# Install Xcode Command Line Tools (if not already installed)
xcode-select --install

# Verify installation
xcodebuild -version
```

---

## 🔧 Script Configuration

### Option A: Environment Variables (Recommended for CI/CD)

Add to your `~/.zshrc` or `~/.bash_profile`:

```bash
export APP_STORE_API_KEY_ID="YOUR_KEY_ID"
export APP_STORE_API_ISSUER_ID="YOUR_ISSUER_ID"
```

Then reload:
```bash
source ~/.zshrc  # or ~/.bash_profile
```

### Option B: Hardcode in Script (Quick Setup)

Edit `deploy_to_testflight.sh` and replace:

```bash
API_KEY_ID="${APP_STORE_API_KEY_ID:-YOUR_KEY_ID}"
API_ISSUER_ID="${APP_STORE_API_ISSUER_ID:-YOUR_ISSUER_ID}"
```

With your actual values:

```bash
API_KEY_ID="A1B2C3D4E5"
API_ISSUER_ID="12345678-1234-1234-1234-123456789abc"
```

---

## 🏃 Running the Script

### First Time Setup

1. **Make the script executable:**
   ```bash
   chmod +x deploy_to_testflight.sh
   ```

2. **Do a test run:**
   ```bash
   ./deploy_to_testflight.sh
   ```

### What Happens During Deployment

The script will automatically:

1. ✅ Validate API credentials and .p8 key file
2. ✅ Auto-increment build numbers for each app
3. ✅ Clean previous builds
4. ✅ Create archives for all 5 apps
5. ✅ Sign apps with automatic provisioning
6. ✅ Export IPAs with proper configuration
7. ✅ Upload to TestFlight (with 3 retry attempts)
8. ✅ Provide detailed logs and final report

**No human interaction required!**

---

## 📊 Understanding the Output

### Success Output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Deploying: PersonalHealthApp
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ Incrementing build number...
  Build number: 15 → 16
▶ Cleaning previous builds...
▶ Creating archive...
  ✅ Archive created successfully
▶ Creating export options...
  ✅ Export options configured
▶ Exporting and uploading to TestFlight...
  ✅ Successfully uploaded to TestFlight!
  ⏱️  Time taken: 127s
```

### Final Summary:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 DEPLOYMENT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Successful: 5
❌ Failed: 0

🎉 SUCCESS! All 5 apps deployed to TestFlight!
```

### Logs Location:
All detailed logs are saved in `build/logs/`:
- `PersonalHealthApp_archive.log`
- `PersonalHealthApp_export.log`
- (etc. for each app)

---

## 🔄 CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/testflight.yml`:

```yaml
name: Deploy to TestFlight

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: latest-stable
    
    - name: Install Apple Certificate
      env:
        P8_KEY: ${{ secrets.APP_STORE_API_P8_KEY }}
        KEY_ID: ${{ secrets.APP_STORE_API_KEY_ID }}
      run: |
        mkdir -p ~/.appstoreconnect/private_keys/
        echo "$P8_KEY" > ~/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8
    
    - name: Deploy to TestFlight
      env:
        APP_STORE_API_KEY_ID: ${{ secrets.APP_STORE_API_KEY_ID }}
        APP_STORE_API_ISSUER_ID: ${{ secrets.APP_STORE_API_ISSUER_ID }}
      run: |
        chmod +x ./deploy_to_testflight.sh
        ./deploy_to_testflight.sh
    
    - name: Upload Logs
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: deployment-logs
        path: build/logs/
```

**Required GitHub Secrets:**
- `APP_STORE_API_KEY_ID`: Your Key ID
- `APP_STORE_API_ISSUER_ID`: Your Issuer ID
- `APP_STORE_API_P8_KEY`: Contents of your .p8 file

### GitLab CI Example

Create `.gitlab-ci.yml`:

```yaml
deploy_testflight:
  stage: deploy
  tags:
    - macos
  only:
    - main
  script:
    - mkdir -p ~/.appstoreconnect/private_keys/
    - echo "$APP_STORE_API_P8_KEY" > ~/.appstoreconnect/private_keys/AuthKey_${APP_STORE_API_KEY_ID}.p8
    - chmod +x ./deploy_to_testflight.sh
    - ./deploy_to_testflight.sh
  artifacts:
    when: always
    paths:
      - build/logs/
    expire_in: 1 week
```

### Fastlane Integration (Alternative)

If you prefer Fastlane, create a `Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Deploy all apps to TestFlight"
  lane :deploy_all do
    apps = [
      { scheme: "PersonalHealthApp", bundle_id: "com.fot.PersonalHealth" },
      { scheme: "FoTClinicianApp", bundle_id: "com.fot.ClinicianApp" },
      { scheme: "FoTParentApp", bundle_id: "com.fot.ParentApp" },
      { scheme: "FoTEducationApp", bundle_id: "com.fot.EducationApp" },
      { scheme: "FoTLegalApp", bundle_id: "com.fot.LegalApp" }
    ]
    
    apps.each do |app|
      deploy_app(
        scheme: app[:scheme],
        bundle_id: app[:bundle_id]
      )
    end
  end
  
  desc "Deploy single app"
  lane :deploy_app do |options|
    increment_build_number(
      xcodeproj: "#{options[:scheme]}.xcodeproj"
    )
    
    build_app(
      scheme: options[:scheme],
      export_method: "app-store"
    )
    
    upload_to_testflight(
      api_key_path: "~/.appstoreconnect/private_keys/AuthKey_#{ENV['APP_STORE_API_KEY_ID']}.p8",
      skip_waiting_for_build_processing: true
    )
  end
end
```

---

## 🐛 Troubleshooting

### Error: "API key file not found"
```bash
# Verify the file exists
ls -la ~/.appstoreconnect/private_keys/

# Check the filename matches your Key ID
# Should be: AuthKey_YOUR_KEY_ID.p8
```

### Error: "No signing identity found"
```bash
# Make sure you're using automatic signing
# Check your Xcode project settings:
# Project → Signing & Capabilities → "Automatically manage signing" is checked
```

### Error: "Archive failed"
```bash
# Check detailed logs
cat build/logs/YourApp_archive.log

# Common issues:
# - Missing dependencies (run pod install if using CocoaPods)
# - Build errors in code
# - Missing certificates
```

### Error: "Upload failed"
```bash
# Check export log
cat build/logs/YourApp_export.log

# The script automatically retries 3 times
# If still failing:
# - Verify internet connection
# - Check App Store Connect status: https://developer.apple.com/system-status/
# - Ensure app is registered in App Store Connect
```

### Slow Upload Times
- Normal upload time: 2-5 minutes per app
- Large apps (>500MB): 5-15 minutes per app
- The script shows progress and retry attempts

---

## 📅 Scheduled Deployments

### Cron Job (macOS/Linux)

Deploy every day at 2 AM:

```bash
# Edit crontab
crontab -e

# Add this line (adjust path to your script)
0 2 * * * cd /path/to/your/project && ./deploy_to_testflight.sh >> /tmp/testflight_deploy.log 2>&1
```

### Launch Agent (macOS)

Create `~/Library/LaunchAgents/com.yourdomain.testflight.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yourdomain.testflight</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/deploy_to_testflight.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>WorkingDirectory</key>
    <string>/path/to/your/project</string>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.yourdomain.testflight.plist
```

---

## ✅ Post-Deployment

### In App Store Connect

1. **Check Build Processing:**
   - Go to: https://appstoreconnect.apple.com/apps
   - Select each app
   - Navigate to **TestFlight** tab
   - Builds typically process in 5-15 minutes

2. **Add to Test Groups:**
   - Once processed, go to **TestFlight** → **Internal Testing** or **External Testing**
   - Click **(+)** to add builds to test groups
   - Testers will be automatically notified

3. **Submit for Review (if needed):**
   - For external testing, you may need App Review
   - Submit from: TestFlight → External Testing → Submit for Review

### Automated Tester Notifications

Once builds are added to test groups, TestFlight automatically:
- ✅ Sends push notifications to testers
- ✅ Sends email notifications
- ✅ Shows "New Build Available" in TestFlight app

---

## 🎯 Best Practices

### Version Management
- Script auto-increments **build numbers** (CFBundleVersion)
- Manually update **version numbers** (CFBundleShortVersionString) when releasing new features
- Format: Version `1.2.3`, Build `45`

### Testing Strategy
1. Deploy to TestFlight (automated)
2. Internal testers test first (your team)
3. Once stable, add to external testing groups
4. Collect feedback
5. Iterate

### Build Frequency
- **Daily**: Continuous development
- **Weekly**: Stable releases
- **On-demand**: Critical fixes

### Monitoring
- Check deployment logs regularly
- Monitor TestFlight crash reports
- Track feedback from testers

---

## 📚 Additional Resources

- [App Store Connect API Documentation](https://developer.apple.com/documentation/appstoreconnectapi)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

---

## 🆘 Support

If you encounter issues not covered in this guide:

1. Check detailed logs in `build/logs/`
2. Review Apple's System Status: https://developer.apple.com/system-status/
3. Consult App Store Connect documentation
4. Contact Apple Developer Support

---

**🎉 You're all set! Run `./deploy_to_testflight.sh` to deploy all 5 apps automatically!**
