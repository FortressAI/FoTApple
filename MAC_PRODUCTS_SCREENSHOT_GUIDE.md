# 📱 Mac Products Screenshot & App Clip Guide

Complete guide for creating professional screenshots and demo clips for all your Mac products.

**Generated**: November 1, 2025

---

## 🎯 Overview

This guide provides everything you need to create App Store quality screenshots and marketing materials for your Mac applications:

- **PersonalHealthMac** - Personal Health Monitor
- **FoTClinicianMac** - Clinical Practice Tools
- **FoTLegalMac** - Legal Services Platform

---

## 🚀 Quick Start

### Option 1: Fully Automated (Recommended for Quick Results)

```bash
cd /Users/richardgillespie/Documents/FoTApple
./scripts/auto_screenshot_mac_apps.sh
```

**What it does:**
- ✅ Builds all Mac apps
- ✅ Launches each app automatically
- ✅ Captures screenshots
- ✅ Creates App Store formatted versions
- ✅ Generates HTML preview
- ⏱️ Takes ~10-15 minutes

### Option 2: Interactive (Best for Custom Screenshots)

```bash
cd /Users/richardgillespie/Documents/FoTApple
./scripts/create_mac_screenshots_and_clips.sh
```

**What it does:**
- ✅ Builds all Mac apps
- ✅ Guides you through capturing 5 screenshots per app
- ✅ Records 30-second demo clips
- ✅ Interactive - you control what's captured
- ⏱️ Takes ~30-45 minutes

### Option 3: Marketing Materials Setup

```bash
cd /Users/richardgillespie/Documents/FoTApple
./scripts/create_appstore_marketing.sh
```

**What it does:**
- ✅ Creates complete directory structure
- ✅ Generates screenshot templates
- ✅ Creates app preview storyboards
- ✅ Provides App Store requirements guide
- ⏱️ Takes ~2 minutes (setup only)

---

## 📁 Output Locations

### Automated Screenshots
```
/Users/richardgillespie/Documents/FoTApple/mac_screenshots_auto/
├── PersonalHealthMac/
│   ├── 01_main_window.png
│   ├── 02_health_records.png
│   └── 03_health_vitals.png
├── FoTClinicianMac/
│   ├── 01_main_window.png
│   ├── 02_patient_view.png
│   └── 03_clinical_tools.png
├── FoTLegalMac/
│   ├── 01_main_window.png
│   ├── 02_legal_documents.png
│   └── 03_legal_search.png
├── appstore/
│   └── [App Store ready screenshots in multiple sizes]
└── preview.html (Open this in browser to see all screenshots)
```

### Interactive Screenshots & Clips
```
/Users/richardgillespie/Documents/FoTApple/mac_screenshots/
├── PersonalHealthMac/
│   ├── 01_main_view.png
│   ├── 02_feature_view.png
│   ├── 03_feature_view.png
│   ├── 04_feature_view.png
│   └── 05_feature_view.png
├── [Same for other apps]
└── MAC_SCREENSHOTS_REPORT.md

/Users/richardgillespie/Documents/FoTApple/mac_app_clips/
├── PersonalHealthMac/
│   └── PersonalHealthMac_demo.mov
├── FoTClinicianMac/
│   └── FoTClinicianMac_demo.mov
└── FoTLegalMac/
    └── FoTLegalMac_demo.mov
```

### Marketing Materials
```
/Users/richardgillespie/Documents/FoTApple/appstore_marketing/
├── PersonalHealthMac/
│   ├── screenshots/
│   │   ├── raw/
│   │   ├── 1280x800/
│   │   ├── 1440x900/
│   │   ├── 2560x1600/
│   │   └── 2880x1800/
│   ├── previews/
│   │   ├── 15sec/
│   │   └── 30sec/
│   ├── marketing/
│   │   ├── social/
│   │   ├── web/
│   │   └── print/
│   ├── SCREENSHOT_TEMPLATE.md
│   └── APP_PREVIEW_STORYBOARD.md
├── [Same structure for other apps]
├── APP_STORE_REQUIREMENTS.md
└── README.md
```

---

## 📋 Mac App Store Requirements

### Screenshot Specifications

| Size | Resolution | Status |
|------|------------|--------|
| **Required** | 2560 x 1600 | Minimum 1 required |
| Recommended | 2880 x 1800 | Best quality |
| Recommended | 1440 x 900 | Standard displays |
| Optional | 1280 x 800 | Older Macs |

### Key Guidelines

✅ **DO:**
- Use PNG or JPEG format
- Show actual app interface
- Demonstrate key features
- Use realistic content
- Keep under 500MB per file
- Upload 3-5 screenshots per app

❌ **DON'T:**
- Include personal information
- Show copyrighted content
- Use outdated UI
- Include error messages
- Show development tools

### App Preview (Demo Video) Specifications

| Property | Requirement |
|----------|-------------|
| **Duration** | 15-30 seconds |
| **Format** | M4V, MOV, or MP4 |
| **Resolution** | 1920 x 1080 minimum |
| **Frame Rate** | 25-30 fps |
| **File Size** | Under 500MB |
| **Maximum** | 3 previews per app |

---

## 🎨 Pro Tips for Great Screenshots

### 1. Prepare Your Mac
```bash
# Clean desktop (for screen recordings)
# Set appearance
System Settings → Appearance → Light (or Dark)

# Disable notifications
System Settings → Notifications → Do Not Disturb
```

### 2. Optimize App Window Size
- Use standard display resolutions
- Resize window to show content clearly
- Avoid clutter in interface
- Ensure text is readable

### 3. Use Realistic Data
- Load sample data that looks professional
- Avoid "Lorem ipsum" placeholder text
- Use realistic names, dates, numbers
- Show actual features in use

### 4. Highlight Key Features
- Screenshot 1: Main dashboard/home
- Screenshot 2: Primary feature
- Screenshot 3: Secondary feature
- Screenshot 4: Integration/workflow
- Screenshot 5: Results/output

### 5. Post-Processing (Optional)
```bash
# Install ImageMagick for advanced editing
brew install imagemagick

# Resize screenshot
sips -z 1800 2880 input.png --out output.png

# Add border
convert input.png -bordercolor "#667eea" -border 3 output.png
```

---

## 🎥 Creating App Clips (Demo Videos)

### Quick Method: Use QuickTime Player

1. **Open QuickTime Player**
2. **File → New Screen Recording**
3. **Options:**
   - Show Mouse Clicks: ON
   - Quality: Maximum
   - Microphone: OFF (unless adding voiceover)
4. **Click record button**
5. **Select app window to record**
6. **Demonstrate features for 15-30 seconds**
7. **Stop recording**
8. **File → Export As → 1080p**

### Advanced Method: Use ffmpeg (Automated)

```bash
# The interactive script includes ffmpeg recording
./scripts/create_mac_screenshots_and_clips.sh

# Or install ffmpeg for manual recording
brew install ffmpeg

# Record specific window
ffmpeg -f avfoundation \
  -capture_cursor 1 \
  -capture_mouse_clicks 1 \
  -i "1:0" \
  -t 30 \
  -r 30 \
  -s 1920x1080 \
  -c:v libx264 \
  -preset ultrafast \
  -pix_fmt yuv420p \
  output.mov
```

### Post-Production Editing

**Recommended Tools:**
- **iMovie** (Free, pre-installed)
- **Final Cut Pro** (Professional)
- **DaVinci Resolve** (Free, powerful)

**Editing Checklist:**
- ✅ Trim to 15-30 seconds
- ✅ Add title card (first 2 seconds)
- ✅ Add text overlays for features
- ✅ Include background music (low volume)
- ✅ End with call-to-action
- ✅ Export as 1080p H.264

---

## 🖼️ Screenshot Best Practices by App

### PersonalHealthMac

**Screenshot Ideas:**
1. **Main Dashboard** - Health records overview
2. **Health Entry** - Adding new vital signs
3. **History View** - Timeline of health data
4. **Reports** - Health trends and insights
5. **Integration** - Sync with health devices

**Key Message**: "Effortlessly track and manage your health"

---

### FoTClinicianMac

**Screenshot Ideas:**
1. **Patient Dashboard** - Patient list and overview
2. **Patient Record** - Detailed patient information
3. **Clinical Tools** - Diagnostic features
4. **Drug Interaction** - Safety checking
5. **Reports** - Clinical analytics

**Key Message**: "Professional clinical tools for modern healthcare"

---

### FoTLegalMac

**Screenshot Ideas:**
1. **Document Library** - Legal document management
2. **Search Interface** - Advanced legal search
3. **Case Management** - Organize cases and clients
4. **Templates** - Legal document templates
5. **Collaboration** - Team features

**Key Message**: "Streamline your legal practice"

---

## 📤 Uploading to App Store Connect

### Step-by-Step Process

1. **Log into App Store Connect**
   ```
   https://appstoreconnect.apple.com
   ```

2. **Navigate to App**
   - Click "My Apps"
   - Select your app
   - Click on version (or create new version)

3. **Add Screenshots**
   - Scroll to "App Store" section
   - Click platform (macOS)
   - Drag and drop screenshots
   - Arrange in desired order
   - Add captions (optional but recommended)

4. **Add App Previews**
   - Click "App Previews" section
   - Upload video files
   - Select poster frame (what users see before playing)
   - Add captions

5. **Save Changes**
   - Click "Save" at top
   - Review all materials
   - Submit for review

### Screenshot Upload Order

**Recommended order (first screenshot is primary):**
1. Most compelling feature
2. Main interface/dashboard
3. Key functionality
4. Secondary features
5. Integration/results

---

## 🔧 Troubleshooting

### Issue: Screenshots are too small
**Solution**: Use Retina display or resize with sips
```bash
sips -z 1800 2880 screenshot.png --out resized.png
```

### Issue: Apps won't build
**Solution**: Check Xcode and dependencies
```bash
cd apps/[AppName]/macOS
xcodebuild -list  # Check available schemes
xcodebuild clean build  # Try manual build
```

### Issue: Screen recording is laggy
**Solution**: 
- Close other applications
- Record at 720p, upscale in post
- Use external SSD for recording destination

### Issue: ffmpeg not found
**Solution**: Install via Homebrew
```bash
brew install ffmpeg
```

### Issue: Screenshots have wrong aspect ratio
**Solution**: Use App Store required dimensions
```bash
# Convert to 2880x1800 (16:10)
sips -z 1800 2880 input.png --out output.png
```

---

## 📊 Checklist

### Before Starting
- [ ] All apps build successfully
- [ ] Sample data is loaded in apps
- [ ] Mac is set to desired appearance (light/dark)
- [ ] Notifications are disabled
- [ ] Screen recording tools are ready
- [ ] Retina display available (if possible)

### During Capture
- [ ] Window size is appropriate
- [ ] No personal/sensitive data visible
- [ ] UI is clean and professional
- [ ] Text is readable
- [ ] Features are clearly demonstrated
- [ ] Mouse movements are smooth (for videos)

### After Capture
- [ ] Review all screenshots for quality
- [ ] Verify correct dimensions
- [ ] Check for any issues (glitches, errors)
- [ ] Create multiple size versions
- [ ] Organize files properly
- [ ] Generate HTML preview
- [ ] Review app clips for smoothness
- [ ] Add music/captions to videos (optional)

### Before Upload
- [ ] 3-5 screenshots per app
- [ ] All screenshots under 500MB
- [ ] Correct dimensions (2560x1600 minimum)
- [ ] No copyrighted content
- [ ] No personal information
- [ ] Professional appearance
- [ ] App previews are 15-30 seconds
- [ ] Videos are under 500MB
- [ ] Tested playback quality

---

## 🎯 Success Metrics

Your screenshots and app clips should:

✅ **Clearly communicate** the app's purpose  
✅ **Demonstrate** 2-3 key features  
✅ **Look professional** and polished  
✅ **Use realistic** sample data  
✅ **Be high resolution** and crisp  
✅ **Follow brand guidelines** consistently  
✅ **Match the actual app** (no misleading content)  
✅ **Engage users** in the first 3 seconds  

---

## 🆘 Getting Help

### Resources
- **App Store Connect**: https://appstoreconnect.apple.com
- **Guidelines**: https://developer.apple.com/app-store/product-page/
- **Support**: https://developer.apple.com/contact/

### Common Questions

**Q: How many screenshots do I need?**  
A: Minimum 1, recommended 3-5, maximum 10 per app.

**Q: Are app previews required?**  
A: No, but highly recommended. They increase downloads by ~20%.

**Q: Can I use the same screenshots for iOS and Mac?**  
A: No, Mac requires different dimensions and showing macOS UI.

**Q: What if my app looks different on different Macs?**  
A: Use the highest resolution available, App Store will scale down.

**Q: Can I update screenshots after app is live?**  
A: Yes! You can update screenshots anytime without submitting a new version.

---

## 📈 Next Steps

After creating your screenshots and app clips:

1. **Review Quality**
   - Check all files in preview.html
   - Verify dimensions and quality
   - Get feedback from others

2. **Prepare for Upload**
   - Organize files by app
   - Name files clearly
   - Create backup copies

3. **Upload to App Store Connect**
   - Follow the upload guide above
   - Add descriptions and captions
   - Save and submit

4. **Monitor Performance**
   - Track conversion rates
   - A/B test different screenshots
   - Update based on user feedback

---

## 🎉 Summary

You now have three powerful tools:

1. **Automated Screenshots** - Quick, efficient, good quality
2. **Interactive Capture** - Custom, detailed, highest quality
3. **Marketing Setup** - Professional, organized, App Store ready

Choose the method that best fits your needs and timeline!

---

**Created**: November 1, 2025  
**Scripts Location**: `/Users/richardgillespie/Documents/FoTApple/scripts/`  
**Documentation**: This file

**Ready to start? Run your preferred script!**

```bash
# Quick automated
./scripts/auto_screenshot_mac_apps.sh

# Full interactive
./scripts/create_mac_screenshots_and_clips.sh

# Marketing materials setup
./scripts/create_appstore_marketing.sh
```

---

**Good luck with your Mac App Store submission! 🚀**

