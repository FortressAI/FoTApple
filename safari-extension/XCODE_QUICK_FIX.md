# 🔧 Xcode Quick Fix - Build Failing on iPhone

## ⚠️ Your Problem

Xcode is trying to build for **iPhone (iOS)** instead of **Mac (macOS)**

**Error you're seeing:**
- Build fails
- Mentions iPhone SDK
- Shows iOS targets

---

## ✅ The Fix (30 seconds)

### Visual Guide

```
┌──────────────────────────────────────────────────────────┐
│ Xcode Toolbar (Top Left)                                 │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ▶️ [QFOT Wallet (iOS) ▼] [iPhone 16 Pro ▼]            │
│      ^^^^^^^^^^^^^^^^^^^^                                 │
│      CLICK THIS DROPDOWN!                                 │
│                                                           │
└──────────────────────────────────────────────────────────┘

                    ↓ Change to ↓

┌──────────────────────────────────────────────────────────┐
│ Xcode Toolbar (Top Left)                                 │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ▶️ [QFOT Wallet (macOS) ▼] [My Mac ▼]                 │
│      ^^^^^^^^^^^^^^^^^^^^                                 │
│      ✅ CORRECT!                                         │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### Step-by-Step

**1. Find the Scheme Dropdown**
- Location: **Top left** of Xcode window
- Next to the Play (▶️) button
- Currently shows: `QFOT Wallet (iOS)` or `FoT Wallet (iOS)`

**2. Click the Dropdown**
- Click where it says "QFOT Wallet (iOS)"
- A menu will appear with options

**3. Select macOS**
- Look for: `QFOT Wallet (macOS)`
- Click it

**4. Verify Target**
- Right next to scheme, you should see: `My Mac`
- NOT "iPhone simulator" or "iPad"

**5. Build and Run**
- Press **⌘R** (or click Play ▶️ button)
- Should build successfully now!

---

## 🎯 What Happens After

Once you select the correct scheme and run:

**Xcode will:**
1. Compile the macOS app (10-20 seconds)
2. Launch the app
3. Show "Running QFOT Wallet" in status bar
4. Keep app running in background

**You will see:**
- Small window or dock icon for "QFOT Wallet"
- May say "no interface" - this is normal!
- Extension is the interface, not the app window

**Then in Safari:**
1. Quit Safari (⌘Q)
2. Reopen Safari
3. Safari → Preferences → Extensions
4. **NOW you'll see "QFOT Wallet"**
5. Enable it!

---

## 🏪 About "Extension Store" / App Store

You mentioned wanting it in the "extension store". Let me clarify:

### There Are Two Ways to Use Extensions

#### **Option A: Development Mode** (What We're Doing)
```
✅ Run from Xcode
✅ Works immediately
✅ Free
✅ No approval process
✅ All features work
❌ Only on YOUR Mac
```

**Best for:**
- Testing
- Personal use
- Development
- Learning how it works

#### **Option B: Mac App Store** (Public Distribution)
```
✅ Anyone can download
✅ Available to public
✅ Professional distribution
❌ Costs $99/year (Apple Developer)
❌ Requires code signing
❌ Apple review (1-2 weeks)
❌ Submission process
```

**Best for:**
- Public release
- Commercial product
- Wide distribution
- Professional apps

### Which Do You Need?

**If you just want to use it yourself:**
→ **Option A** (Development Mode)
→ What we're doing now
→ Works perfectly fine!

**If you want others to use it:**
→ **Option B** (App Store)
→ We can do this after testing
→ I'll help with submission

---

## 📊 Current Status

| Step | Status | What to Do |
|------|--------|------------|
| Build Extension | ✅ Done | Nothing |
| Genesis Wallets | ✅ Done | Nothing |
| Blockchain API | ✅ Running | Nothing |
| **Select macOS Scheme** | ⏳ **Your turn** | **Click dropdown in Xcode** |
| **Run from Xcode** | ⏳ **Your turn** | **Press ⌘R** |
| Enable in Safari | ⏳ Later | After app is running |

---

## 🚀 Quick Start (Right Now)

**In Xcode window (should be open):**

```
1. Look at top left corner
2. Find dropdown that says "QFOT Wallet (iOS)" or "FoT Wallet (iOS)"
3. Click it
4. Select "QFOT Wallet (macOS)"
5. Press ⌘R
```

**If you don't see "QFOT Wallet (macOS)" in dropdown:**

Try these options:
- `FoT Wallet (macOS)` (might have different name)
- Any option that ends with `(macOS)` not `(iOS)`

**Still not working?**

Show me what you see in the scheme dropdown and I'll help.

---

## 🔍 Common Issues

### "I don't see macOS option"
**Fix:** 
- Product → Scheme → Manage Schemes
- Check if "QFOT Wallet (macOS)" is listed
- Enable it

### "Build still fails"
**Fix:**
- Product → Clean Build Folder (⌘⇧K)
- Then build again (⌘B)

### "Can't find the dropdown"
**Location:**
- Very top left of Xcode window
- In the toolbar
- Between back button and Play button
- Shows current scheme name

---

## 💡 Why This Happens

The project has **both iOS and macOS targets**.

When you first open it, Xcode often defaults to iOS.

Safari extensions only work on macOS (not iPhone).

So we need to explicitly tell Xcode: "Build for Mac, not iPhone!"

---

## ✅ Success Looks Like

When it works, you'll see:

```
┌─────────────────────────────────────────┐
│ Xcode Status Bar                        │
├─────────────────────────────────────────┤
│  ▶️ Running QFOT Wallet                │
│     ^^^^^^^^^^                          │
│     Success!                            │
└─────────────────────────────────────────┘
```

And in your Mac dock, you'll see the QFOT Wallet app icon.

**Keep it running!** Don't stop it.

Then go to Safari and enable the extension.

---

## 📞 Still Stuck?

If you're still having issues:

1. **Take a screenshot of Xcode top toolbar**
   - Show me what's in the scheme dropdown
   
2. **Copy any error messages**
   - From the build log

3. **Tell me what options you see**
   - When you click the scheme dropdown

I'll help you get it working!

---

## 🎯 Bottom Line

**Problem:** Wrong target (iOS instead of macOS)  
**Solution:** Click dropdown, select macOS scheme  
**Result:** Build will work, app will run  
**Then:** Enable in Safari → Preferences → Extensions  

**You're ONE CLICK away from getting it working!** Just change that scheme dropdown! 🚀

