# TestFlight Quick Start Guide

## 🎯 What You Have Now

### ✅ COMPLETE - Personal Health App
**Platforms:** iOS + macOS  
**Bundle IDs:** 
- iOS: `com.fot.PersonalHealth`
- macOS: `com.fot.PersonalHealthMac`

**Features:**
- ✅ Physical health tracking (vitals, symptoms)
- ✅ Mental health & wellness (mood, sleep, stress, journal)
- ✅ Crisis support resources (988, hotlines)
- ✅ **NEW: Interactive "When Do I Need Help?" Navigator**
  - Asks 10 questions about health concerns
  - Recommends professional help with urgency levels
  - Medical, mental health, legal, educational guidance
- ✅ Cryptographic receipts for every entry
- ✅ Doctor sharing with temporary access
- ✅ Beautiful Glass UI

### ✅ COMPLETE - FoT Clinician App
**Platform:** iOS  
**Bundle ID:** `com.fot.ClinicianApp`

**Features:**
- ✅ Patient management
- ✅ Clinical encounters & SOAP notes
- ✅ Drug interaction checking (RxNav)
- ✅ Cryptographic receipts
- ✅ Functional demo video created

---

## 📱 Getting to TestFlight (3 Steps)

### Step 1: Get Your Issuer ID (5 minutes)

1. Go to **[App Store Connect](https://appstoreconnect.apple.com/)**
2. Click **Users and Access** → **Keys**
3. Find **Issuer ID** at the top (looks like: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`)
4. Copy it

### Step 2: Create App Entries (10 minutes)

In [App Store Connect](https://appstoreconnect.apple.com/):

1. Click **Apps** → **➕ (Add App)**
2. Fill in:
   - **Name:** Personal Health
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** Select `com.fot.PersonalHealth`
   - **SKU:** `personalhealth-001`
3. Repeat for **FoT Clinician** with Bundle ID `com.fot.ClinicianApp`

### Step 3: Upload to TestFlight (Automated!)

1. Edit the upload script:
```bash
nano scripts/upload_to_testflight.sh
# Set ISSUER_ID="your-uuid-from-step-1"
```

2. Run the script:
```bash
./scripts/upload_to_testflight.sh
```

3. Wait 5-30 minutes for App Store Connect to process

4. Go to **App Store Connect** → **Your App** → **TestFlight**

5. Add **beta app description** and submit for TestFlight review (if external testing)

---

## 👥 Inviting Testers

### Internal Testers (Up to 100)
- Your team members with App Store Connect roles
- Navigate to: **TestFlight** → **Internal Testing**
- Click **Add Testers** → Select team members
- ✅ They can install immediately (no review needed)

### External Testers (Up to 10,000)

#### Option A: Email Invites
- Navigate to: **TestFlight** → **External Testing** → **Add Tester**
- Enter email addresses
- They receive email with TestFlight link

#### Option B: Public Link (Best for Mass Testing!)
- Navigate to: **TestFlight** → **External Testing** → **Public Link**
- Enable link and copy URL
- Share on:
  - Twitter/X
  - Email campaigns
  - Your website
  - Forums/Reddit
- Set criteria (optional):
  - Device type (iPhone only, iPad only, etc.)
  - OS version (iOS 17+, etc.)

**Benefits of Public Link:**
- Don't need email addresses
- Easy to share widely
- Can track how many viewed vs installed
- Can disable when full

---

## 📋 What Testers Will See

1. **Receive invite** (email or public link)
2. **Install TestFlight app** from App Store (if they don't have it)
3. **Accept invite** and install your beta
4. **Use the app** and provide feedback
5. **Take screenshots** and report issues directly in TestFlight

---

## 🎯 Beta App Description (Required for External Testing)

Here's a suggested description for **Personal Health**:

```
Personal Health - Complete Mind & Body Health Monitor

Track your physical and mental health with cryptographic proof of every entry.

NEW in this beta:
• Interactive "When Do I Need Help?" Navigator
• Personalized guidance for medical, mental health, legal, and educational concerns
• 10-question assessment with urgency levels and specific next steps
• Crisis support resources always available (988, hotlines)

Also includes:
• Physical health tracking (vitals, symptoms, photos)
• Mental health journaling (mood, sleep, stress, gratitude)
• Private daily journal with encryption
• Cryptographic receipts for legal protection
• Share with doctors via temporary access
• Beautiful Glass UI

What to test:
✓ Try the "When Do I Need Help?" navigator from Today screen
✓ Track your mood and vitals
✓ Use the mental health journal
✓ Test the crisis resources button
✓ Check if assets load correctly
✓ Report any crashes or UI issues

Your feedback helps us ensure this app truly helps people manage their health!
```

---

## 🚀 After TestFlight

Once you've tested and refined:

1. **Submit for App Store Review**
   - In App Store Connect → Your App → App Store
   - Add screenshots, description, keywords
   - Submit for review

2. **Release to App Store**
   - Apple reviews in 1-3 days typically
   - Fix any issues they find
   - Hit "Release" when approved

3. **Marketing**
   - Tweet the App Store link
   - Submit to Product Hunt
   - Post in relevant subreddits
   - Email your list

---

## 🔧 Troubleshooting

### "No matching provisioning profiles found"
- Let Xcode handle this automatically
- Or manually: Developer Portal → Certificates, IDs & Profiles → Profiles

### "AuthKey permission denied"
```bash
chmod 600 .apple-keys/AuthKey_43BGN9JC5B.p8
```

### "Upload failed: authentication error"
- Double-check Issuer ID is correct
- Verify Auth Key path is correct
- Ensure Key ID is `43BGN9JC5B`

### "App not found in App Store Connect"
- Create app entry first (Step 2 above)
- Bundle ID must match exactly

---

## 📊 Current Status

| App | Platform | Status | Next Step |
|-----|----------|--------|-----------|
| Personal Health | iOS | ✅ Built | Upload to TestFlight |
| Personal Health | macOS | ✅ Built | Upload to TestFlight |
| FoT Clinician | iOS | ✅ Built | Upload to TestFlight |
| Education K-18 | iOS | 🟡 Core ready | Build app |
| Legal US | iOS | 🟡 Core ready | Build app |

---

## 💡 Pro Tips

1. **Start with Internal Testing**
   - Test with your team first
   - Fix obvious bugs before external release
   - Internal testers can install immediately

2. **Use Public Link for Beta Launch**
   - Share on Twitter/X: "Join the Personal Health beta! [link]"
   - Easy to go viral if useful
   - No email collection needed

3. **Monitor Feedback Closely**
   - Check TestFlight feedback daily
   - Respond to crash reports quickly
   - Thank testers for their feedback

4. **Iterate Fast**
   - Upload new builds frequently
   - Each build goes to existing testers automatically (if you enable auto-update)
   - Aim for 1-2 builds per week during beta

5. **Track Metrics**
   - App Store Connect shows:
     - How many invited vs installed
     - Session counts
     - Crash rates
     - Feedback volume
   - Use this to improve before App Store

---

## 📞 Questions?

- **AuthKey issues:** Check `.apple-keys/` directory
- **Build failures:** Run `make test` to verify core functionality
- **TestFlight help:** [developer.apple.com/testflight](https://developer.apple.com/testflight/)
- **App Store Connect:** [help.apple.com/app-store-connect](https://help.apple.com/app-store-connect/)

---

**You're almost there! Just need that Issuer ID and you're live on TestFlight! 🚀**

