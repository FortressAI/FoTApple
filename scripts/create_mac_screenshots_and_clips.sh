#!/bin/bash

# ==============================================================================
# MAC PRODUCTS SCREENSHOT & APP CLIP GENERATOR
# Creates professional screenshots and demo clips for all Mac products
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCREENSHOTS_DIR="$PROJECT_ROOT/mac_screenshots"
APP_CLIPS_DIR="$PROJECT_ROOT/mac_app_clips"
BUILD_DIR="$PROJECT_ROOT/build/mac_products"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Mac apps to process
declare -A MAC_APPS=(
    ["PersonalHealthMac"]="apps/PersonalHealthApp/macOS/PersonalHealthMac.xcodeproj"
    ["FoTClinicianMac"]="apps/ClinicianApp/macOS/FoTClinicianMac.xcodeproj"
    ["FoTLegalMac"]="apps/LegalApp/macOS/FoTLegalMac.xcodeproj"
)

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ==============================================================================
# SETUP
# ==============================================================================

setup_directories() {
    log_info "Setting up directories..."
    
    mkdir -p "$SCREENSHOTS_DIR"
    mkdir -p "$APP_CLIPS_DIR"
    mkdir -p "$BUILD_DIR"
    
    for app in "${!MAC_APPS[@]}"; do
        mkdir -p "$SCREENSHOTS_DIR/$app"
        mkdir -p "$APP_CLIPS_DIR/$app"
    done
    
    log_success "Directories created"
}

# ==============================================================================
# BUILD MAC APPS
# ==============================================================================

build_mac_app() {
    local app_name=$1
    local project_path=$2
    local full_project_path="$PROJECT_ROOT/$project_path"
    
    log_info "Building $app_name..."
    
    if [ ! -f "$full_project_path/project.pbxproj" ]; then
        log_error "Project not found: $full_project_path"
        return 1
    fi
    
    cd "$(dirname "$full_project_path")"
    
    # Build for macOS
    xcodebuild clean build \
        -project "$(basename "$full_project_path")" \
        -scheme "$app_name" \
        -configuration Release \
        -derivedDataPath "$BUILD_DIR/$app_name" \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        | grep -E "Build|error|warning|succeeded|failed" || true
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_success "$app_name built successfully"
        return 0
    else
        log_error "Failed to build $app_name"
        return 1
    fi
}

build_all_apps() {
    log_info "Building all Mac apps..."
    
    local success_count=0
    local total_count=${#MAC_APPS[@]}
    
    for app in "${!MAC_APPS[@]}"; do
        if build_mac_app "$app" "${MAC_APPS[$app]}"; then
            ((success_count++))
        fi
    done
    
    log_success "Built $success_count/$total_count Mac apps"
    
    if [ $success_count -eq 0 ]; then
        log_error "No apps built successfully. Exiting."
        exit 1
    fi
}

# ==============================================================================
# LAUNCH APP AND WAIT FOR WINDOW
# ==============================================================================

launch_app() {
    local app_name=$1
    local app_path="$BUILD_DIR/$app_name/Build/Products/Release/$app_name.app"
    
    log_info "Launching $app_name..."
    
    if [ ! -d "$app_path" ]; then
        log_error "App not found: $app_path"
        return 1
    fi
    
    # Launch the app
    open "$app_path"
    
    # Wait for app to fully launch (give it 5 seconds)
    sleep 5
    
    # Check if app is running
    if pgrep -f "$app_name" > /dev/null; then
        log_success "$app_name launched"
        return 0
    else
        log_error "Failed to launch $app_name"
        return 1
    fi
}

quit_app() {
    local app_name=$1
    
    log_info "Quitting $app_name..."
    
    osascript -e "quit app \"$app_name\"" 2>/dev/null || true
    
    # Force quit if still running after 2 seconds
    sleep 2
    pkill -f "$app_name" 2>/dev/null || true
    
    sleep 1
    log_success "$app_name quit"
}

# ==============================================================================
# SCREENSHOT CAPTURE
# ==============================================================================

capture_screenshots() {
    local app_name=$1
    local output_dir="$SCREENSHOTS_DIR/$app_name"
    
    log_info "Capturing screenshots for $app_name..."
    
    # Give app time to settle
    sleep 2
    
    # Capture main window
    log_info "  📸 Capturing main view..."
    screencapture -w -o "$output_dir/01_main_view.png" 2>/dev/null || {
        log_warning "Interactive window selection - click on the $app_name window"
        screencapture -W -o "$output_dir/01_main_view.png"
    }
    
    sleep 1
    
    # Capture multiple states (user will need to interact)
    log_info "  📸 Preparing for multiple screenshots..."
    
    cat << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   INTERACTIVE SCREENSHOT CAPTURE: $app_name
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please interact with the app to show different features.
After each interaction, press ENTER to capture a screenshot.

Screenshots will be saved to:
$output_dir

EOF
    
    for i in {2..5}; do
        echo -e "${YELLOW}📸 Screenshot $i/5${NC}"
        echo "   1. Navigate to a different view or feature"
        echo "   2. Press ENTER when ready to capture"
        read -p "   "
        
        screencapture -w -o "$output_dir/0${i}_feature_view.png" 2>/dev/null || {
            screencapture -W -o "$output_dir/0${i}_feature_view.png"
        }
        
        log_success "  Screenshot $i captured"
        sleep 1
    done
    
    log_success "All screenshots captured for $app_name"
}

# ==============================================================================
# APP CLIPS (SCREEN RECORDINGS)
# ==============================================================================

create_app_clip() {
    local app_name=$1
    local output_file="$APP_CLIPS_DIR/$app_name/${app_name}_demo.mov"
    
    log_info "Creating app clip for $app_name..."
    
    cat << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   APP CLIP RECORDING: $app_name
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

We'll now record a 30-second demo clip of the app.

RECORDING INSTRUCTIONS:
  1. Press ENTER to start recording
  2. Demonstrate key features for 30 seconds
  3. Recording will stop automatically
  
The clip will be saved to:
$output_file

EOF
    
    read -p "Press ENTER to start recording..."
    
    log_info "🎥 Recording started (30 seconds)..."
    
    # Record screen using ffmpeg (more reliable than screencapture for video)
    if command -v ffmpeg &> /dev/null; then
        # Get the window ID of the app
        window_id=$(osascript -e "tell application \"System Events\" to get the id of window 1 of process \"$app_name\"" 2>/dev/null || echo "")
        
        # Record with ffmpeg
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
            "$output_file" \
            -y \
            2>&1 | grep -v "frame=" || true
        
        log_success "Recording complete"
    else
        log_warning "ffmpeg not found. Install with: brew install ffmpeg"
        log_info "Alternative: Use QuickTime Player to record manually"
        log_info "  1. Open QuickTime Player"
        log_info "  2. File → New Screen Recording"
        log_info "  3. Record the $app_name window"
        log_info "  4. Save as: $output_file"
        
        read -p "Press ENTER when you've completed the manual recording..."
    fi
}

# ==============================================================================
# GENERATE SUMMARY REPORT
# ==============================================================================

generate_report() {
    local report_file="$PROJECT_ROOT/MAC_SCREENSHOTS_REPORT.md"
    
    log_info "Generating summary report..."
    
    cat > "$report_file" << 'EOF'
# 📱 Mac Products Screenshots & App Clips Report

## 🎯 Overview

This report contains screenshots and demo clips for all Mac products in the Field of Truth suite.

**Generated**: $(date)

---

## 📸 Screenshots

EOF

    for app in "${!MAC_APPS[@]}"; do
        cat >> "$report_file" << EOF

### $app

**Location**: \`mac_screenshots/$app/\`

EOF
        
        if [ -d "$SCREENSHOTS_DIR/$app" ]; then
            screenshot_count=$(find "$SCREENSHOTS_DIR/$app" -name "*.png" | wc -l | xargs)
            cat >> "$report_file" << EOF
**Screenshots captured**: $screenshot_count

EOF
            
            # List screenshots
            for screenshot in "$SCREENSHOTS_DIR/$app"/*.png; do
                if [ -f "$screenshot" ]; then
                    filename=$(basename "$screenshot")
                    cat >> "$report_file" << EOF
- ![$filename](mac_screenshots/$app/$filename)

EOF
                fi
            done
        else
            cat >> "$report_file" << EOF
⚠️ No screenshots found

EOF
        fi
    done
    
    cat >> "$report_file" << 'EOF'

---

## 🎥 App Clips (Demo Videos)

EOF

    for app in "${!MAC_APPS[@]}"; do
        cat >> "$report_file" << EOF

### $app

**Location**: \`mac_app_clips/$app/${app}_demo.mov\`

EOF
        
        if [ -f "$APP_CLIPS_DIR/$app/${app}_demo.mov" ]; then
            file_size=$(du -h "$APP_CLIPS_DIR/$app/${app}_demo.mov" | cut -f1)
            cat >> "$report_file" << EOF
**Status**: ✅ Created  
**Size**: $file_size

EOF
        else
            cat >> "$report_file" << EOF
**Status**: ⚠️ Not created

EOF
        fi
    done
    
    cat >> "$report_file" << 'EOF'

---

## 📊 Summary Statistics

EOF

    local total_screenshots=0
    local total_clips=0
    
    for app in "${!MAC_APPS[@]}"; do
        if [ -d "$SCREENSHOTS_DIR/$app" ]; then
            count=$(find "$SCREENSHOTS_DIR/$app" -name "*.png" | wc -l | xargs)
            total_screenshots=$((total_screenshots + count))
        fi
        
        if [ -f "$APP_CLIPS_DIR/$app/${app}_demo.mov" ]; then
            total_clips=$((total_clips + 1))
        fi
    done
    
    cat >> "$report_file" << EOF

| Metric | Count |
|--------|-------|
| Mac Apps | ${#MAC_APPS[@]} |
| Total Screenshots | $total_screenshots |
| Total App Clips | $total_clips |

---

## 📁 Directory Structure

\`\`\`
mac_screenshots/
$(cd "$PROJECT_ROOT" && tree -L 2 mac_screenshots 2>/dev/null || find mac_screenshots -type f | head -20)

mac_app_clips/
$(cd "$PROJECT_ROOT" && tree -L 2 mac_app_clips 2>/dev/null || find mac_app_clips -type f | head -20)
\`\`\`

---

## 🚀 Next Steps

### For App Store Submission:
1. Review all screenshots for quality
2. Select the best 3-5 screenshots per app
3. Crop/resize for App Store requirements (varies by category)
4. Upload to App Store Connect

### For Marketing:
1. Edit app clips to 15-30 second highlights
2. Add captions/annotations if needed
3. Export in multiple formats (MP4, GIF)
4. Share on social media and website

---

**Report generated**: $(date)
EOF

    log_success "Report generated: $report_file"
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

main() {
    clear
    
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        MAC PRODUCTS SCREENSHOT & APP CLIP GENERATOR          ║
║                                                              ║
║              Field of Truth - Mac Applications               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

    log_info "Starting screenshot and app clip generation..."
    echo ""
    
    # Setup
    setup_directories
    
    # Build all apps
    build_all_apps
    
    # Process each app
    for app in "${!MAC_APPS[@]}"; do
        echo ""
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Processing: $app"
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Launch app
        if ! launch_app "$app"; then
            log_warning "Skipping $app (failed to launch)"
            continue
        fi
        
        # Capture screenshots
        capture_screenshots "$app"
        
        # Create app clip
        echo ""
        read -p "$(echo -e ${YELLOW}Create app clip for $app? [Y/n]:${NC} )" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            create_app_clip "$app"
        else
            log_info "Skipping app clip for $app"
        fi
        
        # Quit app
        quit_app "$app"
        
        echo ""
        log_success "Completed processing $app"
        sleep 2
    done
    
    # Generate report
    echo ""
    generate_report
    
    # Final summary
    echo ""
    echo ""
    cat << EOF

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                     ✅ ALL COMPLETE ✅                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

📁 Screenshots saved to:
   $SCREENSHOTS_DIR

🎥 App clips saved to:
   $APP_CLIPS_DIR

📄 Report generated:
   $PROJECT_ROOT/MAC_SCREENSHOTS_REPORT.md

EOF

    log_success "Screenshot and app clip generation complete!"
}

# ==============================================================================
# RUN
# ==============================================================================

main "$@"

