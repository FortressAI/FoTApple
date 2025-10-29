# 🚀 Quick Start Checklist

Copy this checklist and check off items as you complete them.

---

## 🔐 One-Time Setup (Do This Once)

### [ ] 1. Generate App Store Connect API Key
- [ ] Log in to [App Store Connect](https://appstoreconnect.apple.com/)
- [ ] Go to: Users and Access → Keys → App Store Connect API
- [ ] Click (+) and create new key with "App Manager" access
- [ ] **Save these values:**
  ```
  Key ID:     _______________________
  Issuer ID:  _______________________
  ```
- [ ] Download the `.p8` file (only chance to download!)

### [ ] 2. Install the API Key File
```bash
mkdir -p ~/.appstoreconnect/private_keys/
mv ~/Downloads/AuthKey_*.p8 ~/.appstoreconnect/private_keys/
ls ~/.appstoreconnect/private_keys/  # Verify it's there
```

### [ ] 3. Configure Environment Variables

**Option A - Add to ~/.zshrc (or ~/.bash_profile):**
```bash
export APP_STORE_API_KEY_ID="YOUR_KEY_ID"
export APP_STORE_API_ISSUER_ID="YOUR_ISSUER_ID"
```
Then: `source ~/.zshrc`

**Option B - Edit the script directly:**
Replace `YOUR_KEY_ID` and `YOUR_ISSUER_ID` in `deploy_to_testflight.sh`

### [ ] 4. Make Script Executable
```bash
chmod +x deploy_to_testflight.sh
```

### [ ] 5. Verify All Apps Exist in App Store Connect
- [ ] PersonalHealthApp (com.fot.PersonalHealth)
- [ ] ClinicianApp (com.fot.ClinicianApp)
- [ ] ParentApp (com.fot.ParentApp)
- [ ] EducationApp (com.fot.EducationApp)
- [ ] LegalApp (com.fot.LegalApp)

---

## 🏃 Every Deployment (Run This)

### [ ] 1. Run the Deployment Script
```bash
./deploy_to_testflight.sh
```

### [ ] 2. Wait for Completion
- Typical time: 10-30 minutes for all 5 apps
- Watch for: ✅ success or ❌ failure messages

### [ ] 3. Check App Store Connect
- Wait 5-15 minutes for processing
- Go to: https://appstoreconnect.apple.com/apps
- Check TestFlight tab for each app

### [ ] 4. Add Builds to Test Groups (if needed)
- TestFlight → Internal/External Testing
- Click (+) to add new builds
- Testers get auto-notified

---

## 🐛 If Something Goes Wrong

### Check Logs
```bash
# View all logs
ls -lh build/logs/

# View specific app's archive log
cat build/logs/PersonalHealthApp_archive.log

# View specific app's upload log
cat build/logs/PersonalHealthApp_export.log
```

### Common Fixes

**"API key file not found":**
```bash
ls ~/.appstoreconnect/private_keys/
# Should show: AuthKey_YOURKEY.p8
```

**"Archive failed":**
```bash
# Try building in Xcode first to see the error
# Then check: build/logs/*_archive.log
```

**"Upload failed":**
```bash
# Script auto-retries 3 times
# Check: build/logs/*_export.log
# Verify internet connection
# Check Apple System Status: https://developer.apple.com/system-status/
```

**"Directory not found":**
```bash
# Verify directory structure matches:
# apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj
# apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj
# etc.
```

---

## 📋 Quick Commands

```bash
# Run deployment
./deploy_to_testflight.sh

# Check if .p8 key exists
ls -la ~/.appstoreconnect/private_keys/

# View recent logs
tail -f build/logs/*.log

# Clean build directory
rm -rf build/

# Test single app manually
cd apps/PersonalHealthApp/iOS
xcodebuild -project PersonalHealthApp.xcodeproj -list

# Check environment variables
echo $APP_STORE_API_KEY_ID
echo $APP_STORE_API_ISSUER_ID
```

---

## 🎯 Expected Timeline

| Step | Duration |
|------|----------|
| Archive each app | 2-5 min |
| Export & Upload each app | 2-5 min |
| **Total deployment** | **10-30 min** |
| Processing in App Store Connect | 5-15 min |
| **Total until testable** | **15-45 min** |

---

## ✅ Success Indicators

You'll know it worked when you see:

```
🎉 SUCCESS! All 5 apps deployed to TestFlight!

Next steps:
  1. Check build processing:
     https://appstoreconnect.apple.com/apps
```

And in App Store Connect:
- All 5 apps show new builds in TestFlight tab
- Status shows "Processing" → "Ready to Test"

---

## 🔄 Automation Options

### Daily at 2 AM (Cron)
```bash
crontab -e
# Add: 0 2 * * * cd /path/to/project && ./deploy_to_testflight.sh
```

### GitHub Actions
See `SETUP_GUIDE.md` for full CI/CD examples

### Manual Trigger
```bash
./deploy_to_testflight.sh
```

---

## 📞 Help

- **Logs:** `build/logs/`
- **Apple Status:** https://developer.apple.com/system-status/
- **Full Guide:** See `SETUP_GUIDE.md`
- **Apple Docs:** https://developer.apple.com/testflight/

---

**Ready? Run: `./deploy_to_testflight.sh`** 🚀
