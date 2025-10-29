#!/bin/bash
################################################################################
# Capture Real App Store Screenshots for All iOS Apps
# Builds, runs, and captures screenshots from actual apps
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
SCREENSHOTS_DIR="$PROJECT_ROOT/app_store_screenshots"
mkdir -p "$SCREENSHOTS_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📸 Capturing Real App Store Screenshots"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# App configurations: name:scheme:path:bundle_id
declare -a APPS=(
    "PersonalHealthApp:PersonalHealthApp:apps/PersonalHealthApp/iOS:com.fot.PersonalHealth"
    "ClinicianApp:FoTClinicianApp:apps/ClinicianApp/iOS:com.fot.ClinicianApp"
    "ParentApp:FoTParentApp:apps/ParentApp/iOS:com.fot.ParentApp"
    "EducationApp:FoTEducationApp:apps/EducationApp/iOS:com.fot.EducationApp"
    "LegalApp:FoTLegalApp:apps/LegalApp/iOS:com.fot.LegalApp"
)

# Get available simulator devices
echo "▶ Setting up simulators..."

# Get iPhone Pro Max (any available)
IPHONE_UDID=$(xcrun simctl list devices available | grep -iE "iPhone.*Pro Max" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)

# Get iPad Pro 12.9" or largest iPad available
IPAD_UDID=$(xcrun simctl list devices available | grep -iE "iPad.*Pro" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)
if [ -z "$IPAD_UDID" ]; then
    IPAD_UDID=$(xcrun simctl list devices available | grep -iE "iPad" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)
fi

if [ -z "$IPHONE_UDID" ]; then
    echo "  ❌ No iPhone Pro Max simulator found"
    echo "  Available iPhones:"
    xcrun simctl list devices available | grep -i "iPhone" | head -5
    exit 1
fi

if [ -z "$IPAD_UDID" ]; then
    echo "  ❌ No iPad simulator found"
    echo "  Available iPads:"
    xcrun simctl list devices available | grep -i "iPad" | head -5
    exit 1
fi

echo "  ✅ iPhone UDID: $IPHONE_UDID"
echo "  ✅ iPad UDID: $IPAD_UDID"
echo ""

# Function to build, install, and capture screenshots
capture_app_screenshots() {
    local app_name=$1
    local scheme=$2
    local app_path=$3
    local bundle_id=$4
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 Processing: $app_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local full_path="$PROJECT_ROOT/$app_path"
    # Try to find project by scheme name first, then any project
    local project_file=$(find "$full_path" -name "${scheme}.xcodeproj" | head -1)
    if [ -z "$project_file" ]; then
        project_file=$(find "$full_path" -name "*.xcodeproj" | head -1)
    fi
    if [ -z "$project_file" ]; then
        project_file=$(find "$full_path" -name "*.xcworkspace" | head -1)
    fi
    
    if [ -z "$project_file" ]; then
        echo "  ⚠️  No Xcode project found in $full_path"
        echo "     Tried: ${scheme}.xcodeproj, *.xcodeproj, *.xcworkspace"
        return 1
    fi
    
    echo "  Project: $project_file"
    
    # Build for simulator
    echo "  Building for simulator..."
    cd "$full_path"
    
    # Build command
    echo "  Building with xcodebuild..."
    if [[ "$project_file" == *.xcworkspace ]]; then
        xcodebuild build \
            -workspace "$(basename "$project_file")" \
            -scheme "$scheme" \
            -sdk iphonesimulator \
            -destination "id=$IPHONE_UDID" \
            -configuration Release \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            > /tmp/${scheme}_build.log 2>&1 || {
            echo "  ⚠️  Build failed - check /tmp/${scheme}_build.log"
            tail -20 /tmp/${scheme}_build.log | grep -E "error|Error|warning" | head -5
            return 1
        }
    else
        xcodebuild build \
            -project "$(basename "$project_file")" \
            -scheme "$scheme" \
            -sdk iphonesimulator \
            -destination "id=$IPHONE_UDID" \
            -configuration Release \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            > /tmp/${scheme}_build.log 2>&1 || {
            echo "  ⚠️  Build failed - check /tmp/${scheme}_build.log"
            tail -20 /tmp/${scheme}_build.log | grep -E "error|Error|warning" | head -5
            return 1
        }
    fi
    
    # Find the built app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "${scheme}.app" -path "*/Build/Products/*-iphonesimulator/*" -type d 2>/dev/null | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo "  ⚠️  App bundle not found after build"
        return 1
    fi
    
    echo "  ✅ App built: $APP_PATH"
    
    # Boot simulators if not running
    echo "  Booting simulators..."
    xcrun simctl boot "$IPHONE_UDID" 2>/dev/null || true
    xcrun simctl boot "$IPAD_UDID" 2>/dev/null || true
    sleep 2
    
    # Install on both simulators
    echo "  Installing app on simulators..."
    xcrun simctl install "$IPHONE_UDID" "$APP_PATH" 2>/dev/null || true
    xcrun simctl install "$IPAD_UDID" "$APP_PATH" 2>/dev/null || true
    
    # Wait a moment for installation
    sleep 2
    
    # Launch app and wait for UI to load
    echo "  Launching app on iPhone..."
    xcrun simctl launch "$IPHONE_UDID" "$bundle_id" 2>&1 || true
    sleep 5
    
    echo "  Capturing iPhone 6.5\" screenshot..."
    xcrun simctl io "$IPHONE_UDID" screenshot "$SCREENSHOTS_DIR/${app_name}_iphone_6.5.png" 2>&1
    
    if [ -f "$SCREENSHOTS_DIR/${app_name}_iphone_6.5.png" ]; then
        echo "  ✅ iPhone screenshot saved"
    else
        echo "  ⚠️  iPhone screenshot failed"
    fi
    
    echo "  Launching app on iPad..."
    xcrun simctl launch "$IPAD_UDID" "$bundle_id" 2>&1 || true
    sleep 5
    
    echo "  Capturing iPad 13\" screenshot..."
    xcrun simctl io "$IPAD_UDID" screenshot "$SCREENSHOTS_DIR/${app_name}_ipad_13.png" 2>&1
    
    if [ -f "$SCREENSHOTS_DIR/${app_name}_ipad_13.png" ]; then
        echo "  ✅ iPad screenshot saved"
    else
        echo "  ⚠️  iPad screenshot failed"
    fi
    
    echo "  ✅ Done with $app_name"
    echo ""
    
    cd "$PROJECT_ROOT"
}

# Process each app
for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name scheme app_path bundle_id <<< "$app_config"
    capture_app_screenshots "$app_name" "$scheme" "$app_path" "$bundle_id"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Screenshot Capture Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR"
echo ""
ls -lh "$SCREENSHOTS_DIR"worm/*.png 2>/dev/null || echo "Screenshots directory: $SCREENSHOTS_DIR"
echo ""
echo "Next: Upload these to App Store Connect → Your App → Screenshots"
echo ""

