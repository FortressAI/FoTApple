# 🎬 Quick Clip Creation - Start Here!

## ⚡ Fastest Way to Create App Clips

### Step 1: Capture Screenshots (15 minutes)
```bash
cd /Users/richardgillespie/Documents/FoTApple
./scripts/capture_app_clip_sequence.sh
```

**Choose which app** and follow the prompts!  
The tool will tell you exactly what to click and when.

---

### Step 2: Create Video (5 minutes)

#### Option A: iMovie (Easiest, No Command Line)

1. **Open iMovie**
   ```bash
   open -a iMovie
   ```

2. **Create New Movie Project**

3. **Import Screenshots**
   - File → Import Media
   - Navigate to: `mac_screenshots_auto/[AppName]/clip_sequence/`
   - Select all 8 screenshots
   - Click Import

4. **Add to Timeline**
   - Drag all screenshots to timeline in order
   - They'll appear as 4-second clips by default

5. **Adjust Duration**
   - Select all clips (Cmd+A)
   - Click the speed/duration button (speedometer icon)
   - Set to 2.0 seconds each

6. **Add Transitions**
   - Click Transitions (top toolbar)
   - Drag "Cross Dissolve" between each clip
   - Set duration to 0.5 seconds

7. **Add Music** (Optional)
   - Click Audio (top toolbar)
   - Choose from Sound Effects or Music
   - Drag to timeline below video
   - Adjust volume to 20-30%

8. **Export**
   - File → Share → File
   - Resolution: 1080p
   - Quality: High
   - Click Next and Save

**Done! Your app clip is ready!**

---

#### Option B: Keynote (Super Simple)

1. **Open Keynote**
   ```bash
   open -a Keynote
   ```

2. **New Presentation**
   - Choose "Black" theme
   - Delete default text boxes

3. **Import Screenshots**
   - Drag all 8 screenshots from Finder
   - One per slide

4. **Set Timing**
   - Document → Presentation Type → Self-Playing
   - Delay: 2.0 seconds
   - Transition: Dissolve (1.0 second)

5. **Export as Movie**
   - File → Export To → Movie
   - Resolution: 1080p
   - Click Next and Save

**Done! Professional slideshow video created!**

---

#### Option C: Command Line (Fastest, Automated)

```bash
cd /Users/richardgillespie/Documents/FoTApple

# For PersonalHealthMac
cd mac_screenshots_auto/PersonalHealthMac/clip_sequence
ffmpeg -framerate 1/2 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -r 30 -preset slow -crf 18 \
  ../../PersonalHealthMac_demo.mp4

# For FoTClinicianMac  
cd ../../FoTClinicianMac/clip_sequence
ffmpeg -framerate 1/2 -pattern_type glob -i '*.png' \
  -c:v libx264 -pix_fmt yuv420p \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -r 30 -preset slow -crf 18 \
  ../../FoTClinicianMac_demo.mp4

# Open videos
open ../../*.mp4
```

**Parameters explained:**
- `-framerate 1/2` = 2 seconds per screenshot
- `-r 30` = 30fps output
- `-crf 18` = High quality
- `scale=1920:1080` = HD resolution

---

## 🎨 Quick Enhancements

### Add Title Card (First Frame)

1. Create a simple title image:
   ```bash
   # Use Preview or any image editor
   # Create 1920x1080 image with:
   # - App name
   # - Tagline
   # - Logo
   ```

2. Name it `00_title.png` and put in clip_sequence folder

3. It will automatically be first in the video!

### Add Music

**Free Music Sources:**
- Apple Loops (in GarageBand/iMovie)
- YouTube Audio Library
- Incompetech.com

**Quick add to existing video:**
```bash
ffmpeg -i video.mp4 -i music.mp3 \
  -c:v copy -c:a aac \
  -filter:a "volume=0.3" \
  -shortest \
  video_with_music.mp4
```

---

## 📊 What You'll Get

### Input:
- 8 PNG screenshots (high resolution)
- Showing complete app workflow

### Output:
- 15-20 second MP4 video
- 1920x1080 resolution
- 30fps smooth playback
- Ready for App Store or social media

---

## ✅ Quality Checklist

Before sharing/submitting:

- [ ] Video plays smoothly (no stuttering)
- [ ] All text is readable
- [ ] Transitions are smooth
- [ ] Duration is 15-30 seconds
- [ ] File size under 500MB
- [ ] Resolution is 1080p or higher
- [ ] No personal/sensitive data visible

---

## 🚀 Upload to App Store Connect

1. **Log in**: https://appstoreconnect.apple.com

2. **Navigate to App**
   - My Apps → [Your App]
   - App Store tab

3. **Add App Preview**
   - Scroll to App Previews section
   - Click "+"
   - Upload your video file
   - Select poster frame

4. **Save & Submit**

---

## 💡 Pro Tips

### Make It Pop:
- **Keep it fast**: 2 seconds per screenshot max
- **Show value**: Lead with your best feature
- **End strong**: Finish with success/completion
- **Test it**: Watch on different devices

### Common Mistakes to Avoid:
- ❌ Too slow (boring)
- ❌ Too fast (confusing)
- ❌ No clear story
- ❌ Low resolution
- ❌ Jarring transitions

### Good Practices:
- ✅ Smooth transitions
- ✅ Consistent timing
- ✅ Clear narrative flow
- ✅ Professional appearance
- ✅ Proper export settings

---

## 📞 Need Help?

**Check these guides:**
- `APP_CLIP_SCREENSHOT_GUIDE.md` - Comprehensive guide
- `MAC_SCREENSHOTS_CAPTURED.md` - Build status
- `scripts/capture_app_clip_sequence.sh` - Capture tool

**Quick commands:**
```bash
# View screenshots
open mac_screenshots_auto

# Run capture tool
./scripts/capture_app_clip_sequence.sh

# Check if ffmpeg is installed
ffmpeg -version
```

---

## 🎉 You're Ready!

Everything you need is set up:
1. ✅ Apps are built
2. ✅ Capture tool is ready
3. ✅ Instructions are clear
4. ✅ Multiple creation methods available

**Start now:**
```bash
./scripts/capture_app_clip_sequence.sh
```

---

**Happy clip creating! 🎬✨**

**Estimated time**: 20 minutes total (15 capture + 5 create)

