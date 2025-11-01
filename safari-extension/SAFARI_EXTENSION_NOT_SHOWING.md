# 🔧 Safari Extension Not Showing? - Quick Fix

## ⚠️ Problem

You don't see "QFOT Wallet" in Safari → Preferences → Extensions

## ✅ Solution

The app needs to run from Xcode (development mode)

---

## 📋 Step-by-Step Fix

### 1️⃣ Open Xcode (Already Done)

Xcode should be opening now with the QFOT Wallet project.

### 2️⃣ Select the Right Scheme

At the **top left** of Xcode window:
- Click the scheme dropdown (next to Play button)
- Select: **"QFOT Wallet (macOS)"**
- Target should be: **"My Mac"** or **"My Mac (Designed for iPhone)"**

### 3️⃣ Run the App

Press **⌘R** (or click the Play ▶️ button at top left)

**What you'll see:**
- Xcode will compile (takes 10-20 seconds first time)
- Status bar will show: "Running QFOT Wallet"
- A small window may appear saying "QFOT Wallet" (no content - this is normal)
- **IMPORTANT:** Keep this running! Don't stop it!

### 4️⃣ Restart Safari

1. **Quit Safari completely:** Press **⌘Q** (or Safari → Quit Safari)
2. Wait 2 seconds
3. **Reopen Safari**

### 5️⃣ Enable Extension in Safari

1. Go to **Safari → Preferences** (or press **⌘,**)
2. Click **Extensions** tab (in the top toolbar)
3. Look in the **left sidebar** - you should NOW see:
   - ✅ **QFOT Wallet**
4. **Check the box** next to "QFOT Wallet"
5. Safari will ask for permissions:
   - Click **"Always Allow on Every Website"**
   - Or allow for specific sites: `safeaicoin.org`, `localhost`

### 6️⃣ Verify It's Working

Look at Safari's toolbar - you should see the **⚛️ icon**!

If you don't see it:
- Right-click Safari toolbar
- Click **"Customize Toolbar..."**
- Drag the **QFOT Wallet** icon to the toolbar

---

## 🎯 Why This Happens

**Development Extensions Need Parent App Running**

- Safari extensions require their parent app to be active
- Unsigned apps (like our development build) close immediately when double-clicked
- Running from Xcode keeps the app active in the background
- This is normal for development - production apps would be signed

---

## ✅ Checklist

Before checking Safari Extensions, make sure:

- [ ] Xcode is open with QFOT Wallet project
- [ ] Scheme is set to "QFOT Wallet (macOS)"
- [ ] App is RUNNING in Xcode (green indicator at top)
- [ ] You see "Running QFOT Wallet" in Xcode status bar
- [ ] Safari has been quit and reopened

---

## 🔍 Troubleshooting

### "I still don't see it in Safari Extensions"

**Check 1:** Is the app still running in Xcode?
- Look at Xcode top bar - should show "Running QFOT Wallet"
- If it stopped, press ⌘R again

**Check 2:** Did you quit Safari completely?
- Not just close windows - actually quit (⌘Q)
- Reopen Safari fresh

**Check 3:** Safari Develop menu
- Safari → Preferences → Advanced
- Check "Show Develop menu in menu bar"
- Develop → Allow Unsigned Extensions (if available)

### "The app keeps crashing in Xcode"

**Fix:** Select correct scheme
- Top left: Change from "QFOT Wallet (iOS)" to "QFOT Wallet (macOS)"

### "I see errors about code signing"

**Fix:** Disable code signing (already done in build)
- This is normal for development
- Production versions would be properly signed

---

## 🎉 Once It's Working

After enabling the extension:

1. **Click the ⚛️ icon** in Safari toolbar
2. You'll see the wallet interface:
   - Welcome screen
   - "Create New Wallet" button
   - "Import Existing Wallet" button
3. **Create a test wallet** or import your creator wallet
4. Navigate to **https://safeaicoin.org** to test

---

## 💡 Pro Tips

**Keep Xcode Running**
- Don't close Xcode while using the extension
- You can minimize it, but keep the app running

**Auto-Run on Startup** (Optional)
- Later, we can properly sign the app
- Then it can run without Xcode
- For now, Xcode method works perfectly

**Console Logging**
- In Xcode, open Console (⌘⇧Y)
- You'll see extension logs
- Useful for debugging

---

## 📞 Still Having Issues?

If the extension still doesn't show after following all steps:

1. Check Console in Xcode for errors
2. Try: Clean Build Folder (Product → Clean Build Folder)
3. Rebuild: ⌘B
4. Run again: ⌘R
5. Restart Safari

---

## ✅ Expected Final State

When everything is working:

✅ Xcode showing "Running QFOT Wallet"  
✅ Safari Extensions shows "QFOT Wallet" with checkmark  
✅ ⚛️ icon visible in Safari toolbar  
✅ Clicking icon shows wallet interface  
✅ Can create/import wallets  
✅ Extension works on websites  

---

**🎉 You're almost there! Just need to run it from Xcode!**

