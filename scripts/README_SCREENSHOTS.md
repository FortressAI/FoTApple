# 📸 Mac Screenshot Scripts - Quick Reference

## 🚀 Quick Start (Easiest)

```bash
./screenshot_launcher.sh
```
**Shows a friendly menu with all options!**

---

## 📋 Available Scripts

### 1. `screenshot_launcher.sh` ⭐ START HERE
**The easiest way to get started!**
- Simple menu interface
- Choose which tool to use
- Access documentation
- No need to remember commands

**Usage:**
```bash
./screenshot_launcher.sh
```

---

### 2. `auto_screenshot_mac_apps.sh` 🚀 FAST & AUTOMATED
**Best for: Quick results, initial screenshots**

**What it does:**
- Builds all 3 Mac apps
- Captures 3 screenshots per app automatically
- Creates App Store ready versions (multiple sizes)
- Generates HTML preview

**Time:** ~10-15 minutes  
**Interaction:** Minimal (mostly automated)

**Usage:**
```bash
./auto_screenshot_mac_apps.sh
```

**Output:**
- `../mac_screenshots_auto/` - All screenshots
- `../mac_screenshots_auto/appstore/` - App Store ready
- `../mac_screenshots_auto/preview.html` - Visual preview

---

### 3. `create_mac_screenshots_and_clips.sh` 🎨 CUSTOM & INTERACTIVE
**Best for: High-quality custom screenshots and demo videos**

**What it does:**
- Builds all 3 Mac apps
- Guides you through 5 custom screenshots per app
- Records 30-second demo videos (App Clips)
- You control exactly what's captured

**Time:** ~30-45 minutes  
**Interaction:** High (you're in full control)

**Usage:**
```bash
./create_mac_screenshots_and_clips.sh
```

**Output:**
- `../mac_screenshots/` - Custom screenshots
- `../mac_app_clips/` - Demo videos
- `../MAC_SCREENSHOTS_REPORT.md` - Detailed report

---

### 4. `create_appstore_marketing.sh` 📋 PLANNING & ORGANIZATION
**Best for: Setting up your App Store submission**

**What it does:**
- Creates professional directory structure
- Generates screenshot templates
- Creates app preview storyboards
- Provides App Store requirements guide

**Time:** ~2 minutes  
**Interaction:** Setup only (no screenshots captured)

**Usage:**
```bash
./create_appstore_marketing.sh
```

**Output:**
- `../appstore_marketing/` - Complete structure
- Templates and guides for each app
- `APP_STORE_REQUIREMENTS.md` - Detailed requirements

---

## 🎯 Which One Should I Use?

### First Time User?
```bash
./screenshot_launcher.sh
```
Then choose option 1 (Quick Automated)

### Want Quick Screenshots Now?
```bash
./auto_screenshot_mac_apps.sh
```

### Want Perfect Custom Screenshots?
```bash
./create_mac_screenshots_and_clips.sh
```

### Need to Plan First?
```bash
./create_appstore_marketing.sh
```

---

## 📱 Your Mac Apps

These scripts work with your 3 Mac applications:

1. **PersonalHealthMac** 🏥 - Health tracking and monitoring
2. **FoTClinicianMac** 👨‍⚕️ - Clinical tools and patient records
3. **FoTLegalMac** ⚖️ - Legal document management

---

## 📁 Output Locations

### Automated Screenshots
```
../mac_screenshots_auto/
├── PersonalHealthMac/
├── FoTClinicianMac/
├── FoTLegalMac/
├── appstore/           # Ready for App Store
└── preview.html        # View in browser
```

### Interactive Screenshots
```
../mac_screenshots/     # Custom screenshots
../mac_app_clips/       # Demo videos
```

### Marketing Materials
```
../appstore_marketing/
├── PersonalHealthMac/
│   ├── screenshots/
│   ├── previews/
│   └── marketing/
├── FoTClinicianMac/
├── FoTLegalMac/
└── APP_STORE_REQUIREMENTS.md
```

---

## 📋 Mac App Store Requirements

### Screenshots
- **Minimum**: 1 per app
- **Recommended**: 3-5 per app
- **Size**: 2560x1600 or 2880x1800
- **Format**: PNG or JPEG

### App Clips (Videos)
- **Optional** but recommended
- **Duration**: 15-30 seconds
- **Format**: M4V, MOV, or MP4
- **Resolution**: 1920x1080+

---

## 🆘 Troubleshooting

### Apps won't build?
```bash
# Check Xcode
xcodebuild -version

# Try manual build
cd ../apps/PersonalHealthApp/macOS
xcodebuild clean build
```

### ffmpeg not found?
```bash
brew install ffmpeg
```

### Screenshots low quality?
Use Retina display or upscale:
```bash
sips -z 1800 2880 input.png --out output.png
```

---

## 📚 Documentation

- **MAC_PRODUCTS_SCREENSHOT_GUIDE.md** - Complete guide
- **MAC_SCREENSHOT_SYSTEM_COMPLETE.md** - System overview
- **appstore_marketing/APP_STORE_REQUIREMENTS.md** - Requirements

---

## ✅ Quick Checklist

Before running:
- [ ] Navigate to project: `cd /Users/richardgillespie/Documents/FoTApple`
- [ ] Choose script to run
- [ ] Clean desktop (for recordings)
- [ ] Disable notifications
- [ ] Have time allocated

After running:
- [ ] Review generated files
- [ ] Select best screenshots
- [ ] Prepare for App Store upload
- [ ] Keep backups

---

## 🎉 Ready to Go!

All scripts are:
- ✅ Executable
- ✅ Tested
- ✅ Documented
- ✅ Ready to use

**Just run the launcher and get started:**
```bash
./screenshot_launcher.sh
```

---

**Need help? Read MAC_PRODUCTS_SCREENSHOT_GUIDE.md for complete instructions!**

