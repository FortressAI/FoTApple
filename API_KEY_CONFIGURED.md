# 🔑 API Key Configuration Complete

## ✅ Setup Summary

The new App Store Connect API key has been moved to the correct location and configured for deployment.

---

## 📁 Files Created/Updated

| File | Purpose | Status |
|------|---------|--------|
| `private_keys/AuthKey_A746Z2JSK2.p8` | App Manager API key | ✅ Configured |
| `.deployment_config` | Central deployment configuration | ✅ Created |
| `scripts/deploy_watch_apps.sh` | Watch app deployment script | ✅ Ready |
| `.gitignore` | Excludes sensitive files from git | ✅ Updated |

---

## 🔑 API Key Details

```
Key ID:     A746Z2JSK2
Issuer ID:  d648c36b-f731-4c3e-bb88-32aad08f9f2d
Team ID:    WWQQB728U5
Key Path:   private_keys/AuthKey_A746Z2JSK2.p8
```

**Expected Role:** App Manager (allows Watch app provisioning)

---

## 📱 Current Deployment Status

### ✅ iOS Apps (5/5 - 100% Complete)

| # | App Name | Bundle ID | Version | SKU | Upload UUID | Status |
|---|----------|-----------|---------|-----|-------------|--------|
| 1 | PersonalHealthApp | `com.akashic.PersonalHealth` | 13 | PersonalHealth* | `2d353531-8710...` | ✅ LIVE |
| 2 | FoTLegalApp | `com.akashic.FoTLegal` | 13 | FoTLegal* | `d6af3f9e-f8a7...` | ✅ LIVE |
| 3 | FoTEducationApp | `com.akashic.FoTEducation` | 9 | FoTEducation* | `b0d3ead9-c272...` | ✅ LIVE |
| 4 | FoTParentApp | `com.akashic.FoTParent` | 9 | FoTParent* | `11c89b4c-ed0c...` | ✅ LIVE |
| 5 | FoTClinicianApp | `com.fot.ClinicianApp` | 9 | ClinicianApp* | `e1214c3e-e311...` | ✅ LIVE |

\*SKUs are best estimates based on Bundle IDs. Verify exact SKUs at:
**App Store Connect → My Apps → [App Name] → App Information → SKU**

### ⏳ Watch Apps (0/5 - Ready to Deploy)

| # | Watch App | Parent Bundle ID | Status |
|---|-----------|------------------|--------|
| 1 | PersonalHealth Watch | `com.akashic.PersonalHealth` | ⏳ Ready |
| 2 | Legal Watch | `com.akashic.FoTLegal` | ⏳ Ready |
| 3 | Education Watch | `com.akashic.FoTEducation` | ⏳ Ready |
| 4 | Parent Watch | `com.akashic.FoTParent` | ⏳ Ready |
| 5 | Clinician Watch | `com.fot.ClinicianApp` | ⏳ Ready |

---

## 🚀 How to Deploy Watch Apps

### Option 1: Automated Deployment (Recommended)

```bash
cd /Users/richardgillespie/Documents/FoTApple
./scripts/deploy_watch_apps.sh
```

This will:
1. Build all 5 Watch app archives
2. Export IPAs for each Watch app
3. Upload to App Store Connect using the new API key
4. Provide detailed status for each app

### Option 2: Individual Watch App Deployment

If you need to deploy one Watch app at a time, edit the script to comment out apps you don't want to deploy.

---

## 📝 Notes

### About SKUs
- SKUs are set when you first create an app in App Store Connect
- They cannot be changed after creation
- The exact SKUs for your apps can only be verified in App Store Connect:
  1. Go to https://appstoreconnect.apple.com
  2. Select **My Apps**
  3. Click on each app
  4. Go to **App Information**
  5. Look for the **SKU** field

### API Key Security
- ✅ API key is stored in `private_keys/` (excluded from git)
- ✅ Configuration file is excluded from git
- ✅ Never commit `.p8` files or `private_keys/` directory

### Watch App Requirements
- Watch apps must have the same Team ID as parent iOS apps
- Watch apps use separate bundle IDs (e.g., `com.akashic.PersonalHealth.watchkitapp`)
- The new API key should have "App Manager" role to create Watch app provisioning profiles

---

## ✅ What's Different with This API Key?

**Previous Key (`706IRVGBDV3B`):**
- Role: Developer
- ❌ Could not provision Watch apps via CLI
- ✅ Successfully deployed all 5 iOS apps

**New Key (`A746Z2JSK2`):**
- Role: App Manager (assumed)
- ✅ Should be able to provision Watch apps via CLI
- ✅ Ready for Watch app deployment

---

## 🎯 Next Steps

1. **Verify API Key Role**
   - Go to App Store Connect → Users and Access → Keys
   - Confirm `A746Z2JSK2` has "App Manager" role

2. **Deploy Watch Apps**
   ```bash
   ./scripts/deploy_watch_apps.sh
   ```

3. **Monitor Progress**
   - Check `build/logs/` for detailed logs
   - Watch for "UPLOAD SUCCEEDED" messages

4. **Verify in App Store Connect**
   - Navigate to each app
   - Check for Watch app builds in TestFlight

---

## 🔗 Quick Links

- **App Store Connect:** https://appstoreconnect.apple.com
- **API Keys Management:** https://appstoreconnect.apple.com/access/api
- **TestFlight:** https://appstoreconnect.apple.com/apps (select app → TestFlight)

---

**Last Updated:** November 1, 2025 (Saturday)  
**Status:** ✅ Ready for Watch App Deployment

