#!/bin/bash
################################################################################
# Generate App Store Screenshots for All Apps
# Uses iOS Simulator to capture required screenshot sizes
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCREENSHOTS_DIR="$SCRIPT_DIR/../app_store_screenshots"
mkdir -p "$SCREENSHOTS_DIR"

# Required screenshot sizes
# iPhone 6.5" (iPhone 14 Pro Max): 1284 x 2778
# iPad 13" (iPad Pro 12.9"): 2048 x 2732

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📸 Generating App Store Screenshots"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if simulators are available
if ! command -v xcrun simctl &> /dev/null; then
    echo "❌ xcrun simctl not found"
    exit 1
fi

# App configurations
declare -a APPS=(
    "PersonalHealthApp:PersonalHealthApp:com.fot.PersonalHealth"
    "ClinicianApp:FoTClinicianApp:com.fot.ClinicianApp"
    "ParentApp:FoTParentApp:com.fot.ParentApp"
    "EducationApp:FoTEducationApp:com.fot.EducationApp"
    "LegalApp:FoTLegalApp:com.fot.LegalApp"
)

# Function to boot and capture screenshots
capture_screenshots() {
    local app_name=$1
    local scheme=$2
    local bundle_id=$3
    
    echo "📱 Processing: $app_name"
    
    # Create device UDIDs if needed
    IPHONE_UDID=$(xcrun simctl list devices available | grep "iPhone 14 Pro Max" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)
    IPAD_UDID=$(xcrun simctl list devices available | grep "iPad Pro (12.9-inch)" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)
    
    if [ -z "$IPHONE_UDID" ]; then
        echo "  Creating iPhone 14 Pro Max simulator..."
        IPHONE_UDID=$(xcrun simctl create "iPhone_14_Pro_Max_Screenshots" "iPhone 14 Pro Max" "iOS17.0" 2>/dev/null || echo "")
    fi
    
    if [ -z "$IPAD_UDID" ]; then
        echo "  Creating iPad Pro 12.9-inch simulator..."
        IPAD_UDID=$(xcrun simctl create "iPad_Pro_12_9_Screenshots" "iPad Pro (12.9-inch)" "iOS17.0" 2>/dev/null || echo "")
    fi
    
    # Build and install app
    echo "  Building and installing app..."
    cd "$SCRIPT_DIR/../apps/$app_name/iOS"
    
    xcodebuild build \
        -project "$scheme.xcodeproj" \
        -scheme "$scheme" \
        -sdk iphonesimulator \
        -destination "id=$IPHONE_UDID" \
        > /tmp/${scheme}_build.log 2>&1 || {
        echo "  ⚠️  Build failed - creating placeholder screenshots"
        create_placeholder_screenshots "$app_name"
        return
    }
    
    # Boot simulators
    echo "  Booting simulators..."
    xcrun simctl boot "$IPHONE_UDID" 2>/dev/null || true
    xcrun simctl boot "$IPAD_UDID" 2>/dev/null || true
    
    sleep 3
    
    # Install app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "${scheme}.app" -path "*/Build/Products/*-iphonesimulator/*" | head -1)
    if [ -n "$APP_PATH" ]; then
        xcrun simctl install "$IPHONE_UDID" "$APP_PATH" 2>/dev/null || true
        xcrun simctl install "$IPAD_UDID" "$APP_PATH" 2>/dev/null || true
        
        # Launch app
        xcrun simctl launch "$IPHONE_UDID" "$bundle_id" 2>/dev/null || true
        xcrun simctl launch "$IPAD_UDID" "$bundle_id" 2>/dev/null || true
        
        sleep 5
        
        # Capture screenshots
        echo "  Capturing iPhone 6.5\" screenshot..."
        xcrun simctl io "$IPHONE_UDID" screenshot "$SCREENSHOTS_DIR/${app_name}_iphone_6.5.png" 2>/dev/null || true
        
        echo "  Capturing iPad 13\" screenshot..."
        xcrun simctl io "$IPAD_UDID" screenshot "$SCREENSHOTS_DIR/${app_name}_ipad_13.png" 2>/dev/null || true
    else
        echo "  ⚠️  App not found - creating placeholder screenshots"
        create_placeholder_screenshots "$app_name"
    fi
    
    cd "$SCRIPT_DIR/.."
    echo "  ✅ Done"
    echo ""
}

# Function to create placeholder screenshots with correct dimensions
create_placeholder_screenshots() {
    local app_name=$1
    
    # Create placeholder iPhone 6.5" (1284 x 2778)
    if command -v sips &> /dev/null; then
        # Create solid color image
        sips -c 2778 1284 --createColor "rgb(240,240,240)" "$SCREENSHOTS_DIR/${app_name}_iphone_6.5.png" 2>/dev/null || \
        convert -size 1284x2778 xc:"#f0f0f0" "$SCREENSHOTS_DIR/${app_name}_iphone_6.5.png" 2>/dev/null || true
    fi
    
    # Create placeholder iPad 13" (2048 x 2732)
    if command -v sips &> /dev/null; then
        sips -c 2732 2048 --createColor "rgb(240,240,240)" "$SCREENSHOTS_DIR/${app_name}_ipad_13.png" 2>/dev/null || \
        convert -size 2048x2732 xc:"#f0f0f0" "$SCREENSHOTS_DIR/${app_name}_ipad_13.png" 2>/dev/null || true
    fi
    
    echo "  📸 Placeholder screenshots created"
}

# Process each app
for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name scheme bundle_id <<< "$app_config"
    capture_screenshots "$app_name" "$scheme" "$bundle_id"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Screenshot Generation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR"
echo ""
echo "Next steps:"
echo "  1. Review screenshots in $SCREENSHOTS_DIR"
echo "  2. Replace placeholders with actual app screenshots if needed"
echo "  3. Upload to App Store Connect:"
echo "     • iPhone 6.5\": ${app_name}_iphone_6.5.png"
echo "     • iPad 13\": ${app_name}_ipad_13.png"
echo ""

