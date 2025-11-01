# 🔐 QFOT Wallet - Notarization (Fixed)

## ❌ Problem: Username/Password Authentication Failed

The old script asked for username/password every time, which is:
- ❌ Inconvenient (enter password repeatedly)
- ❌ Insecure (password in terminal history)
- ❌ Not how Apple recommends it

## ✅ Solution: Keychain Storage (Like Your Certificates)

Just like your signing certificates are stored in Keychain and work automatically, your notarization credentials should be too.

---

## 🚀 How to Fix (2 Simple Steps)

### Step 1: Store Credentials (One-Time Setup)

```bash
cd "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet"
./setup_notarization.sh
```

**You'll need:**
1. Your Apple ID (email)
2. **App-Specific Password** (not your regular password!)

**Get App-Specific Password:**
1. Go to https://appleid.apple.com
2. Click **Security**
3. Click **App-Specific Passwords**
4. Click **Generate Password**
5. Name it: "QFOT Notarization"
6. Copy the password (format: `xxxx-xxxx-xxxx-xxxx`)

**The script will:**
- Prompt for Apple ID
- Prompt for App-Specific Password
- Store in macOS Keychain (secure)
- Create profile: `qfot-notarization`

---

### Step 2: Notarize (Uses Stored Credentials)

```bash
./notarize_with_stored_credentials.sh
```

**That's it!** The script will:
1. Create ZIP of app
2. Submit to Apple (using keychain credentials)
3. Wait for approval (~5-10 min)
4. Staple notarization ticket
5. Create distributable DMG
6. Notarize DMG
7. Staple DMG

**Result:** `QFOT_Wallet_v1.0.dmg` ready to distribute!

---

## 🔐 Security Benefits

| Old Way (Username/Password) | New Way (Keychain) |
|---|---|
| ❌ Enter password every time | ✅ Enter once, stored securely |
| ❌ Password in terminal history | ✅ Password in encrypted Keychain |
| ❌ Password in scripts | ✅ No password in scripts |
| ❌ Not Apple's recommendation | ✅ Apple's recommended method |

---

## 📋 What Gets Stored

**Profile Name:** `qfot-notarization`

**Contains:**
- Apple ID (email)
- App-Specific Password (encrypted)
- Team ID: WWQQB728U5

**Stored In:**
- macOS Keychain (same as your certificates)
- Only accessible by you
- Encrypted at rest

---

## 🛠️ Troubleshooting

### "Invalid credentials" error

**Problem:** Using regular Apple ID password instead of App-Specific Password

**Fix:**
1. Go to https://appleid.apple.com → Security → App-Specific Passwords
2. Generate new password
3. Run `./setup_notarization.sh` again with App-Specific Password

---

### "No Keychain password item found"

**Problem:** Credentials not stored yet

**Fix:**
```bash
./setup_notarization.sh
```

---

### View stored credentials

```bash
xcrun notarytool history --keychain-profile "qfot-notarization"
```

---

### Delete stored credentials (to reset)

```bash
xcrun notarytool history --keychain-profile "qfot-notarization" --delete-profile
```

Then run `./setup_notarization.sh` again.

---

## ✅ Complete Workflow

```bash
# One-time setup (store credentials)
cd "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet"
./setup_notarization.sh

# Notarize and package (anytime)
./notarize_with_stored_credentials.sh

# Test the DMG
open QFOT_Wallet_v1.0.dmg

# Deploy to server
scp QFOT_Wallet_v1.0.dmg root@94.130.97.66:/var/www/downloads/
scp QFOT_Wallet_v1.0.dmg root@46.224.42.20:/var/www/downloads/
```

---

## 🎯 Why This Works

This is the **exact same approach** as your signing certificates:

**Signing Certificates:**
- Stored in Keychain ✅
- Used automatically ✅
- No password prompts ✅

**Notarization Credentials (Now):**
- Stored in Keychain ✅
- Used automatically ✅
- No password prompts ✅

---

## 📚 Apple Documentation

- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Using notarytool](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow)

---

## ✅ Ready?

Run this now:
```bash
./setup_notarization.sh
```

Then notarize:
```bash
./notarize_with_stored_credentials.sh
```

**Done! No more password prompts.** 🎉

