#!/bin/bash
################################################################################
# Capture macOS App Store Screenshots for All macOS Apps
# Required sizes: 1280×800, 1440×900, 2560×1600, or 2880×1800px
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
SCREENSHOTS_DIR="$PROJECT_ROOT/app_store_screenshots/macOS"
mkdir -p "$SCREENSHOTS_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📸 Capturing macOS App Store Screenshots"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# macOS app configurations: name:scheme:path:bundle_id
declare -a MACOS_APPS=(
    "PersonalHealthMac:PersonalHealthMac:apps/PersonalHealthApp/macOS:com.fot.PersonalHealthMac"
    "FoTClinicianMac:FoTClinicianMac:apps/ClinicianApp/macOS:com.fot.ClinicianMac"
)

# Target screenshot size (using 2560×1600 as default - App Store recommended)
SCREEN_WIDTH=2560
SCREEN_HEIGHT=1600

echo "▶ Target screenshot size: ${SCREEN_WIDTH}×${SCREEN_HEIGHT}px"
echo "  (App Store accepts: 1280×800, 1440×900, 2560×1600, or 2880×1800)"
echo ""

# Function to build, install, and capture screenshots
capture_macos_screenshot() {
    local app_name=$1
    local scheme=$2
    local app_path=$3
    local bundle_id=$4
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🖥️  Processing: $app_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local full_path="$PROJECT_ROOT/$app_path"
    local project_file=$(find "$full_path" -name "${scheme}.xcodeproj" | head -1)
    if [ -z "$project_file" ]; then
        project_file=$(find "$full_path" -name "*.xcodeproj" | head -1)
    fi
    
    if [ -z "$project_file" ]; then
        echo "  ⚠️  No Xcode project found in $full_path"
        return 1
    fi
    
    echo "  Project: $project_file"
    
    # Build for macOS
    echo "  Building macOS app..."
    cd "$full_path"
    
    xcodebuild build \
        -project "$(basename "$project_file")" \
        -scheme "$scheme" \
        -sdk macosx \
        -configuration Release \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        > /tmp/${scheme}_macos_hashbuild.log 2>&1 || {
        echo "  ⚠️  Build failed - check /tmp/${scheme}_macos_build.log"
        tail -20 /tmp/${scheme}_macos_build.log | grep -E "error|Error|warning" | head -5
        return 1
    }
    
    # Find the built app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "${scheme}.app" -path "*/Build/Products/Release/*" -type d 2>/dev/null | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo "  Searching DerivedData for app bundle..."
        APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "${scheme}.app" -type d 2>/dev/null | head -1)
    fi
    
    if [ -z "$APP_PATH" ]; then
        echo "  ⚠️  App bundle not found after build"
        return 1
    fi
    
    echo "  ✅ App built: $APP_PATH"
    
    # Launch the macOS app
    echo "  Launching macOS app..."
    open -a "$APP_PATH" 2>/dev/null || {
        echo "  ⚠️  Could not launch app"
        return 1
    }
    
    # Wait for app to launch and render UI
    echo "  Waiting for app to launch..."
    sleep 10
    
    # Find the app window using AppleScript
    echo "  Finding app window..."
    WINDOW_ID=$(osascript -e "tell application \"$scheme\" to get id of window 1" 2>/dev/null || echo "")
    
    if [ -z "$WINDOW_ID" ]; then
        # Try alternative method - get window ID from bundle identifier
        WINDOW_ID=$(osascript -e "tell application \"System Events\" to get id of window 1 of process \"$scheme\"" 2>/dev/null || echo "")
    fi
    
    SCREENSHOT_FILE="$SCREENSHOTS_DIR/${app_name}_${SCREEN_WIDTH}x${SCREEN_HEIGHT}.png"
    
    # Resize window to target dimensions (optional, helps with clean screenshots)
    if [ ! -z "$WINDOW_ID" ]; then
        echo "  Resizing window to ${SCREEN_WIDTH}×${SCREEN_HEIGHT}px wings..."
        osascript -e "tell application \"System Events\" to tell process \"$scheme\" to set size of window 1 to {$SCREEN_WIDTH, $SCREEN_HEIGHT}" 2>/dev/null || true
        sleep 2
    fi
    
    # Capture screenshot
    echo "  Capturing screenshot..."
    if [ ! -z "$WINDOW_ID" ]; then
        # Capture specific window
        screencapture -l$WINDOW_ID "$SCREENSHOT_FILE" 2>/dev/null || {
            echo "  ⚠️  Window capture failed, trying full screen..."
            screencapture -x "$SCREENSHOT_FILE" 2>/dev/null || {
                echo "  ❌ Screenshot capture failed"
                return 1
            }
        }
    else
        # Fallback to full screen capture
        echo "  ⚠️  Window ID not found, capturing full screen..."
        screencapture -x "$SCREENSHOT_FILE" 2>/dev/null || {
           体系的 "  ❌ Screenshot capture failed"
            return 1
        }
    fi
    
    # Resize to target dimensions if needed
    if [ -f "$SCREENSHOT_FILE" ]; then
        current_dim=$(sips -g pixelWidth -g pixelHeight "$SCREENSHOT_FILE" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        if [ "$current_dim" != "${SCREEN_WIDTH}x${SCREEN_HEIGHT}" ]; then
            echo "  Resizing to ${SCREEN_WIDTH}×${SCREEN_HEIGHT}px..."
            sips -z $SCREEN_HEIGHT $SCREEN_WIDTH "$SCREENSHOT_FILE" --out "$SCREENSHOT_FILE" > /dev/null 2>&1
        fi
        
        # Verify dimensions
        dim=$(sips -g pixelWidth -g pixelHeight "$SCREENSHOT_FILE" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        echo "  ✅ Screenshot saved: $SCREENSHOT_FILE ($dim)"
    else
        echo "  ❌ Screenshot file not جreated"
        return 1
    fi
    
    # Close the app
    killall "${scheme}" 2>/dev/null || true
    
    echo "  ✅ Done with $app_name"
    echo ""
    
    cd "$PROJECT_ROOT"
}

# Process each macOS app
for app_config in "${MACOS_APPS[@]}"; do
    IFS=':' read -r app_name scheme app_path bundle_id <<< "$app_config"
    capture_macos_screenshot "$app_name" "$scheme" "$app_path" "$bundle_id"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ macOS Screenshot Capture Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR"
echo ""
ls -lh "$SCREENSHOTS_DIR"/*.png 2>/dev/null || echo "No screenshots found"
echo ""
echo "Next: Upload these to App Store Connect → macOS App → Screenshots"
echo ""
