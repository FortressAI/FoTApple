# 🎬 App Clip Screenshot Sequence Guide

## 🎯 Purpose
Create screenshot sequences that can be combined into demo clips/videos for your Mac apps.

---

## 🚀 Quick Start

### Run the Interactive Tool:
```bash
cd /Users/richardgillespie/Documents/FoTApple
./scripts/capture_app_clip_sequence.sh
```

This tool will:
1. Open your Mac app
2. Guide you through capturing 8 screenshots
3. Tell you what to click/show at each step
4. Save everything in organized folders

---

## 📸 Recommended Screenshot Sequences

### PersonalHealthMac (Health Monitor)

**Story**: "Track your health effortlessly"

1. **Dashboard** - Main screen with overview
2. **Records List** - View past health entries
3. **New Entry** - Click "Add" button
4. **Recording Vitals** - Form being filled
5. **Timeline** - Health history over time
6. **Analytics** - Charts and trends
7. **Detail View** - Specific record details
8. **Success** - Confirmation message

**Duration**: 15-20 seconds (2-3 seconds per screenshot)

---

### FoTClinicianMac (Clinical Tools)

**Story**: "Professional clinical tools for modern healthcare"

1. **Dashboard** - Main clinical interface
2. **Patient List** - Schedule/patient roster
3. **Patient Record** - Individual patient view
4. **Assessment** - Clinical evaluation tools
5. **Clinical Feature** - Drug checker or guidelines
6. **Documentation** - Note-taking interface
7. **Reports** - Analytics and insights
8. **Complete** - Workflow finished

**Duration**: 15-20 seconds (2-3 seconds per screenshot)

---

## 🎨 Creating App Clips from Screenshots

### Method 1: iMovie (Easy, Free)

```bash
# 1. Open iMovie
open -a iMovie

# 2. Create New Movie
# 3. Import all screenshots from clip_sequence folder
# 4. Drag them to timeline in order (01, 02, 03...)
# 5. Set each photo duration to 2-3 seconds
# 6. Add transitions between photos (Dissolve, 0.5s)
# 7. Add background music (optional)
# 8. File → Share → File → 1080p
```

**Result**: Smooth slideshow-style demo video

---

### Method 2: Keynote (Super Easy)

```bash
# 1. Open Keynote
open -a Keynote

# 2. Create new presentation (Black theme)
# 3. Import screenshots as full-slide images
# 4. Set automatic advance (2 seconds per slide)
# 5. Add transitions (Magic Move or Dissolve)
# 6. File → Export → Movie
# 7. Choose 1080p quality
```

**Result**: Clean presentation-style video

---

### Method 3: ffmpeg (Command Line, Fast)

```bash
# Navigate to clip sequence folder
cd mac_screenshots_auto/PersonalHealthMac/clip_sequence

# Create video from screenshots
ffmpeg -framerate 1/2 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p -vf scale=1920:1080 \
  -r 30 PersonalHealthMac_demo.mp4

# Result: 2 seconds per screenshot, 30fps output
```

**Result**: Quick automated video

---

### Method 4: Final Cut Pro (Professional)

1. Import screenshots
2. Add to timeline (2-3 seconds each)
3. Add Ken Burns effect (subtle zoom)
4. Add transitions
5. Color grade
6. Add music and sound effects
7. Export as ProRes or H.264

**Result**: Professional-quality demo

---

## 📐 App Store Requirements

### Video Specs for App Previews:
- **Format**: M4V, MOV, or MP4
- **Duration**: 15-30 seconds
- **Resolution**: 1920 x 1080 or higher
- **Frame Rate**: 25-30 fps
- **File Size**: Under 500MB
- **Codec**: H.264 or HEVC

### Your Screenshots Are:
- ✅ High resolution (Retina)
- ✅ PNG format (perfect for video)
- ✅ Properly sequenced
- ✅ Showing actual app UI

---

## 🎵 Adding Background Music

### Free Resources:
- **YouTube Audio Library**: royalty-free music
- **Apple Loops**: built into GarageBand/iMovie
- **Incompetech**: free music (attribution)

### Tips:
- Keep volume low (-20dB to -30dB)
- Choose upbeat, professional music
- Avoid music with lyrics
- Fade in/out at start/end

---

## ✨ Pro Tips for Great App Clips

### Visual Enhancement:
1. **Smooth Transitions**: Use dissolve or crossfade (0.5-1s)
2. **Ken Burns Effect**: Subtle zoom on key screenshots
3. **Text Overlays**: Add feature names (optional)
4. **Highlight Cursor**: Show what's being clicked
5. **Consistent Timing**: 2-3 seconds per screenshot

### Storytelling:
1. **Start Strong**: Show most impressive feature first
2. **Show Flow**: Demonstrate a complete workflow
3. **End Clear**: Finish with success/completion
4. **Call to Action**: Last frame with logo/name

### Technical:
1. **Export Quality**: Always 1080p minimum
2. **File Format**: H.264 for compatibility
3. **Test Playback**: Watch before submitting
4. **Multiple Versions**: Create 15s and 30s versions

---

## 📁 File Organization

After running the capture tool:

```
mac_screenshots_auto/
├── PersonalHealthMac/
│   ├── clip_sequence/
│   │   ├── 01_dashboard.png
│   │   ├── 02_records_list.png
│   │   ├── 03_new_entry.png
│   │   ├── 04_recording_vitals.png
│   │   ├── 05_timeline.png
│   │   ├── 06_analytics.png
│   │   ├── 07_detail_view.png
│   │   └── 08_success.png
│   └── [other screenshots]
└── FoTClinicianMac/
    ├── clip_sequence/
    │   ├── 01_dashboard.png
    │   ├── 02_patient_list.png
    │   ├── 03_patient_record.png
    │   ├── 04_assessment.png
    │   ├── 05_clinical_feature.png
    │   ├── 06_documentation.png
    │   ├── 07_reports.png
    │   └── 08_complete.png
    └── [other screenshots]
```

---

## 🎬 Example Timeline (15 seconds)

| Time | Screenshot | Duration | Transition |
|------|------------|----------|------------|
| 0-2s | 01_dashboard | 2s | Dissolve |
| 2-4s | 02_records | 2s | Dissolve |
| 4-6s | 03_new_entry | 2s | Dissolve |
| 6-8s | 04_recording | 2s | Dissolve |
| 8-10s | 05_timeline | 2s | Dissolve |
| 10-12s | 06_analytics | 2s | Dissolve |
| 12-14s | 07_detail | 2s | Dissolve |
| 14-15s | 08_success | 1s | Fade out |

**Total**: 15 seconds

---

## 🎯 Different Clip Styles

### Style 1: Fast Showcase (15s)
- 1.5 seconds per screenshot
- Quick cuts, no transitions
- Energetic music
- Shows breadth of features

### Style 2: Tutorial (30s)
- 3-4 seconds per screenshot
- Smooth transitions
- Calm music
- Shows depth of workflow

### Style 3: Marketing (20s)
- Variable timing (2-4s)
- Text overlays
- Upbeat music
- Highlights best features

---

## 🚀 Automation Script

For quick video creation:

```bash
#!/bin/bash
# auto_create_clip.sh

APP_NAME=$1  # e.g., "PersonalHealthMac"
INPUT_DIR="mac_screenshots_auto/$APP_NAME/clip_sequence"
OUTPUT_FILE="mac_app_clips/${APP_NAME}_demo.mp4"

mkdir -p mac_app_clips

# Create video from screenshots (2 seconds each)
ffmpeg -y \
  -framerate 1/2 \
  -pattern_type glob \
  -i "${INPUT_DIR}/*.png" \
  -c:v libx264 \
  -pix_fmt yuv420p \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -r 30 \
  -preset slow \
  -crf 18 \
  "$OUTPUT_FILE"

echo "✅ Video created: $OUTPUT_FILE"
open "$OUTPUT_FILE"
```

**Usage**:
```bash
chmod +x auto_create_clip.sh
./auto_create_clip.sh PersonalHealthMac
./auto_create_clip.sh FoTClinicianMac
```

---

## 📊 Quality Checklist

Before submitting app clips:

- [ ] All screenshots are high resolution
- [ ] Sequence tells a clear story
- [ ] Transitions are smooth (not jarring)
- [ ] Duration is 15-30 seconds
- [ ] Music is professional (if used)
- [ ] Text is readable (if overlays)
- [ ] No personal/sensitive data visible
- [ ] File size under 500MB
- [ ] Video plays smoothly
- [ ] Exported in correct format (H.264)

---

## 🎉 Ready to Create!

You now have:
✅ Screenshot capture tool (`capture_app_clip_sequence.sh`)
✅ Organized folders for sequences
✅ Multiple creation methods
✅ Professional guidelines
✅ Automation scripts

**Start capturing:**
```bash
./scripts/capture_app_clip_sequence.sh
```

**Or view existing screenshots:**
```bash
open mac_screenshots_auto
```

---

**Happy clip creating! 🎬✨**

