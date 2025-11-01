#!/bin/bash

# ==============================================================================
# APP STORE MARKETING MATERIALS GENERATOR
# Creates App Store screenshots, app previews, and marketing materials
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/appstore_marketing"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_create() { echo -e "${MAGENTA}🎨 $1${NC}"; }

# ==============================================================================
# SETUP
# ==============================================================================

setup_structure() {
    log_info "Creating directory structure..."
    
    mkdir -p "$OUTPUT_DIR"/{PersonalHealthMac,FoTClinicianMac,FoTLegalMac}/{screenshots,previews,marketing}
    
    # Create subdirectories for different formats
    for app in PersonalHealthMac FoTClinicianMac FoTLegalMac; do
        mkdir -p "$OUTPUT_DIR/$app/screenshots"/{raw,1280x800,1440x900,2560x1600,2880x1800}
        mkdir -p "$OUTPUT_DIR/$app/previews"/{15sec,30sec}
        mkdir -p "$OUTPUT_DIR/$app/marketing"/{social,web,print}
    done
    
    log_success "Directory structure created"
}

# ==============================================================================
# SCREENSHOT REQUIREMENTS GUIDE
# ==============================================================================

create_requirements_guide() {
    local guide_file="$OUTPUT_DIR/APP_STORE_REQUIREMENTS.md"
    
    log_info "Creating requirements guide..."
    
    cat > "$guide_file" << 'EOF'
# 📱 Mac App Store Screenshot & Preview Requirements

## 🖼️ Screenshot Requirements

### Required Sizes for macOS Apps:

| Size | Resolution | Aspect Ratio | Required |
|------|------------|--------------|----------|
| Small | 1280 x 800 | 16:10 | Recommended |
| Medium | 1440 x 900 | 16:10 | Recommended |
| Large | 2560 x 1600 | 16:10 | **Required** |
| Extra Large | 2880 x 1800 | 16:10 | Recommended |

### Screenshot Guidelines:

1. **Minimum Required**: 1 screenshot
2. **Maximum Allowed**: 10 screenshots
3. **Recommended**: 3-5 screenshots showing key features
4. **Format**: PNG or JPEG
5. **Color Space**: RGB
6. **File Size**: Under 500MB per screenshot

### Content Best Practices:

✅ **DO:**
- Show your app's main interface
- Highlight unique features
- Use high-quality, in-focus images
- Show realistic content
- Demonstrate the value proposition

❌ **DON'T:**
- Include unreadable text
- Show copyrighted content
- Use outdated screenshots
- Include personal information
- Show error messages

---

## 🎥 App Preview Requirements

### Video Specifications:

| Property | Requirement |
|----------|-------------|
| **Duration** | 15-30 seconds |
| **Format** | M4V, MOV, or MP4 |
| **Codec** | H.264 or HEVC |
| **Resolution** | 1920 x 1080 or higher |
| **Frame Rate** | 25-30 fps |
| **File Size** | Under 500MB |

### App Preview Guidelines:

1. **Maximum**: 3 previews per localization
2. **Audio**: Optional but recommended
3. **Content**: Must accurately represent the app
4. **Branding**: Can include logo/branding elements

### Content Best Practices:

✅ **DO:**
- Show app in action
- Demonstrate key features
- Use smooth transitions
- Include subtle background music
- Add text overlays for clarity

❌ **DON'T:**
- Show loading screens
- Include placeholder content
- Use copyrighted music
- Show other apps
- Include price information

---

## 🎨 Marketing Assets

### Social Media Sizes:

| Platform | Size | Aspect Ratio |
|----------|------|--------------|
| Twitter | 1200 x 675 | 16:9 |
| Facebook | 1200 x 630 | 1.91:1 |
| Instagram | 1080 x 1080 | 1:1 |
| LinkedIn | 1200 x 627 | 1.91:1 |

### Web Sizes:

| Usage | Size |
|-------|------|
| Hero Image | 2400 x 1350 |
| Feature Image | 1200 x 800 |
| Thumbnail | 600 x 400 |

---

## 📋 Checklist

### Before Submission:

- [ ] Created 3-5 screenshots per app
- [ ] Resized to all required dimensions
- [ ] Verified color accuracy
- [ ] Removed personal/sensitive information
- [ ] Checked text readability
- [ ] Created app previews (15-30 seconds)
- [ ] Verified video quality
- [ ] Tested on target devices
- [ ] Prepared localized versions (if applicable)
- [ ] Created backup copies

### Quality Check:

- [ ] All text is readable
- [ ] UI is clean and professional
- [ ] Content is up-to-date
- [ ] No copyrighted material
- [ ] Consistent branding
- [ ] High resolution (no pixelation)
- [ ] Proper aspect ratios
- [ ] Under file size limits

---

## 🚀 Upload Process

1. **Log into App Store Connect**
   - Go to: https://appstoreconnect.apple.com
   - Navigate to: My Apps → [Your App] → App Store

2. **Upload Screenshots**
   - Click on the appropriate App Store section
   - Drag and drop screenshots
   - Arrange in desired order
   - Add captions (optional)

3. **Upload App Previews**
   - Click "App Previews"
   - Upload video files
   - Select poster frame
   - Add captions

4. **Save and Submit**
   - Review all materials
   - Save changes
   - Submit for review

---

## 📞 Support

For questions or issues:
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Developer Forums: https://developer.apple.com/forums/
- Support: https://developer.apple.com/contact/

---

**Last Updated**: $(date)
EOF

    log_success "Requirements guide created: $guide_file"
}

# ==============================================================================
# SCREENSHOT TEMPLATE GENERATOR
# ==============================================================================

create_screenshot_template() {
    local app_name=$1
    local template_file="$OUTPUT_DIR/$app_name/SCREENSHOT_TEMPLATE.md"
    
    cat > "$template_file" << EOF
# Screenshot Plan: $app_name

## 🎯 Target Screenshots (3-5 required)

### Screenshot 1: Main Interface
- **Purpose**: Show the app's home screen/main view
- **Focus**: Overall layout and primary features
- **Caption**: "${app_name} - Your [key benefit]"

### Screenshot 2: Key Feature #1
- **Purpose**: Demonstrate primary functionality
- **Focus**: [Describe the feature]
- **Caption**: "[Feature benefit/description]"

### Screenshot 3: Key Feature #2
- **Purpose**: Show secondary important feature
- **Focus**: [Describe the feature]
- **Caption**: "[Feature benefit/description]"

### Screenshot 4: Integration/Workflow
- **Purpose**: Demonstrate how features work together
- **Focus**: User workflow or data integration
- **Caption**: "[Workflow benefit]"

### Screenshot 5: Results/Output
- **Purpose**: Show the value delivered to users
- **Focus**: Final output, reports, or achievements
- **Caption**: "[Results/benefits]"

---

## 📝 Preparation Checklist

- [ ] App is built and running smoothly
- [ ] Sample data is loaded and looks realistic
- [ ] UI is clean (no developer tools, debug info, etc.)
- [ ] All text is professional and error-free
- [ ] Window size is appropriate
- [ ] macOS appearance is set (light/dark mode)
- [ ] Screenshots follow brand guidelines
- [ ] High-resolution display used (Retina preferred)

---

## 🎨 Visual Guidelines

### Style:
- Clean, uncluttered interface
- Professional sample content
- Consistent color scheme
- Clear typography
- Adequate white space

### Technical:
- Resolution: 2880 x 1800 (minimum)
- Format: PNG (preferred)
- Color space: sRGB or Display P3
- No compression artifacts

---

## ✅ Quality Check

After capturing screenshots, verify:
- [ ] All text is readable at thumbnail size
- [ ] No personal/sensitive information visible
- [ ] UI elements are properly aligned
- [ ] Colors are accurate and vibrant
- [ ] No glitches or rendering issues
- [ ] Consistent window size across screenshots
- [ ] Proper focus and no blur

---

**Created**: $(date)
EOF

    log_success "Template created for $app_name"
}

# ==============================================================================
# AUTOMATED SCREENSHOT FRAMING
# ==============================================================================

create_framed_screenshot() {
    local input_image=$1
    local output_image=$2
    local title=$3
    local subtitle=$4
    
    # Check if ImageMagick is installed
    if ! command -v convert &> /dev/null; then
        log_warning "ImageMagick not installed. Install with: brew install imagemagick"
        return 1
    fi
    
    log_create "Creating framed screenshot..."
    
    # Create a marketing frame around the screenshot
    convert "$input_image" \
        -resize 2880x1800 \
        -gravity center \
        -extent 2880x1800 \
        -bordercolor "#667eea" \
        -border 3 \
        "$output_image"
    
    # Add title if provided
    if [ -n "$title" ]; then
        convert "$output_image" \
            -gravity south \
            -background "#667eea" \
            -splice 0x150 \
            -font Helvetica-Bold \
            -pointsize 60 \
            -fill white \
            -gravity south \
            -annotate +0+50 "$title" \
            "$output_image"
    fi
    
    log_success "Framed screenshot created"
}

# ==============================================================================
# APP PREVIEW STORYBOARD
# ==============================================================================

create_preview_storyboard() {
    local app_name=$1
    local storyboard_file="$OUTPUT_DIR/$app_name/APP_PREVIEW_STORYBOARD.md"
    
    cat > "$storyboard_file" << EOF
# App Preview Storyboard: $app_name

## 🎬 15-Second Preview Plan

**Total Duration**: 15 seconds  
**Target**: Quick feature overview

### Timeline:

| Time | Scene | Action | Voiceover/Text |
|------|-------|--------|----------------|
| 0-3s | Opening | App logo animation → Main screen | "$app_name - [Tagline]" |
| 3-6s | Feature 1 | Show primary feature in action | "Easily [key benefit]" |
| 6-9s | Feature 2 | Demonstrate secondary feature | "Powerful [feature]" |
| 9-12s | Integration | Show workflow/integration | "Seamlessly integrated" |
| 12-15s | Call-to-Action | App icon + download prompt | "Download today" |

---

## 🎥 30-Second Preview Plan

**Total Duration**: 30 seconds  
**Target**: Comprehensive feature showcase

### Timeline:

| Time | Scene | Action | Voiceover/Text |
|------|-------|--------|----------------|
| 0-3s | Opening | Branded intro, app logo | "$app_name" |
| 3-6s | Problem | Show user pain point | "Tired of [problem]?" |
| 6-10s | Solution | Introduce app interface | "Meet $app_name" |
| 10-15s | Feature 1 | Deep dive into main feature | "[Feature] makes it easy" |
| 15-20s | Feature 2 | Show additional capabilities | "Plus [additional features]" |
| 20-25s | Results | Happy user, success metrics | "Join [X] satisfied users" |
| 25-30s | Call-to-Action | Download prompt, logo | "Download now on Mac App Store" |

---

## 🎨 Visual Style Guide

### Color Palette:
- Primary: #667eea (Purple-Blue)
- Secondary: #764ba2 (Purple)
- Accent: #ffffff (White)
- Background: #f8f9fa (Light Gray)

### Typography:
- Title: San Francisco Display Bold, 72pt
- Subtitle: San Francisco Display Regular, 48pt
- Body: San Francisco Text Regular, 36pt

### Animation Style:
- Smooth transitions (0.3s ease)
- Gentle zoom effects
- Fade in/out for text
- Cursor movement to guide attention

### Audio:
- Background music: Upbeat, professional (royalty-free)
- Volume: -20dB (subtle background)
- Sound effects: UI interactions (optional)

---

## 📋 Recording Checklist

### Pre-Production:
- [ ] Storyboard approved
- [ ] App is in demo-ready state
- [ ] Sample data prepared
- [ ] Screen recording software configured
- [ ] Audio track selected/created
- [ ] Text overlays designed

### Production:
- [ ] Record in high resolution (1920x1080+)
- [ ] Use 30fps for smooth playback
- [ ] Keep cursor movements smooth
- [ ] Ensure no notifications/interruptions
- [ ] Record multiple takes
- [ ] Capture clean audio

### Post-Production:
- [ ] Edit for timing and flow
- [ ] Add text overlays
- [ ] Mix background music
- [ ] Color correction
- [ ] Add transitions
- [ ] Export in required format
- [ ] Test playback quality

---

## 🎯 Success Metrics

A great app preview should:
- ✅ Clearly show the app's value proposition
- ✅ Demonstrate 2-3 key features
- ✅ Be visually appealing and professional
- ✅ Include clear call-to-action
- ✅ Run smoothly without stuttering
- ✅ Engage viewers in first 3 seconds
- ✅ Match the app's actual functionality

---

**Created**: $(date)
EOF

    log_success "Preview storyboard created for $app_name"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    clear
    
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        APP STORE MARKETING MATERIALS GENERATOR               ║
║                                                              ║
║           Field of Truth - Professional Assets               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

    log_info "Creating marketing materials structure..."
    echo ""
    
    setup_structure
    create_requirements_guide
    
    # Create templates for each app
    for app in PersonalHealthMac FoTClinicianMac FoTLegalMac; do
        echo ""
        log_info "Creating templates for $app..."
        create_screenshot_template "$app"
        create_preview_storyboard "$app"
    done
    
    # Create README
    cat > "$OUTPUT_DIR/README.md" << 'EOF'
# 📱 App Store Marketing Materials

This directory contains all marketing materials for Mac App Store submission.

## 📁 Directory Structure

```
appstore_marketing/
├── PersonalHealthMac/
│   ├── screenshots/       # App Store screenshots
│   ├── previews/          # App preview videos
│   └── marketing/         # Social media & web assets
├── FoTClinicianMac/
│   ├── screenshots/
│   ├── previews/
│   └── marketing/
├── FoTLegalMac/
│   ├── screenshots/
│   ├── previews/
│   └── marketing/
└── APP_STORE_REQUIREMENTS.md  # Complete requirements guide
```

## 🚀 Quick Start

### 1. Generate Screenshots
```bash
# Automated screenshot capture
./scripts/auto_screenshot_mac_apps.sh

# Manual screenshot capture with guidance
./scripts/create_mac_screenshots_and_clips.sh
```

### 2. Create App Previews
Follow the storyboards in each app's directory:
- `[AppName]/APP_PREVIEW_STORYBOARD.md`

### 3. Review & Submit
1. Check APP_STORE_REQUIREMENTS.md for specifications
2. Upload to App Store Connect
3. Submit for review

## 📚 Resources

- [App Store Connect](https://appstoreconnect.apple.com)
- [Screenshot Guidelines](https://developer.apple.com/app-store/product-page/)
- [App Preview Guidelines](https://developer.apple.com/app-store/app-previews/)

---

**Created**: $(date)
EOF

    # Summary
    echo ""
    echo ""
    cat << EOF

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                  ✅ SETUP COMPLETE ✅                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

📁 Output Directory:
   $OUTPUT_DIR

📄 Key Files Created:
   ✅ APP_STORE_REQUIREMENTS.md - Complete guidelines
   ✅ Screenshot templates for each app
   ✅ App preview storyboards
   ✅ Directory structure for all assets

🎯 Next Steps:

1. Review APP_STORE_REQUIREMENTS.md

2. Capture screenshots:
   ./scripts/auto_screenshot_mac_apps.sh

3. Record app previews using the storyboards

4. Upload to App Store Connect

EOF

    log_success "Marketing materials structure created!"
    
    # Open the output directory
    open "$OUTPUT_DIR"
}

main "$@"

