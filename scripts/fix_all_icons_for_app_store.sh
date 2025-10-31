#!/bin/bash

set -e

echo "🔧 FIXING ALL APP ICONS FOR APP STORE VALIDATION"
echo "======================================="
echo ""

cd "$(dirname "$0")/.."

# Function to fix icon Contents.json
fix_icon_json() {
    local APP_PATH=$1
    local ICON_PATH="${APP_PATH}/Assets.xcassets/AppIcon.appiconset"
    
    echo "📝 Fixing $(basename "$APP_PATH")..."
    
    cat > "${ICON_PATH}/Contents.json" << 'EOF'
{
  "images": [
    {
      "filename": "icon_40x40.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "20x20"
    },
    {
      "filename": "icon_60x60.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "20x20"
    },
    {
      "filename": "icon_58x58.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "29x29"
    },
    {
      "filename": "icon_87x87.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "29x29"
    },
    {
      "filename": "icon_80x80.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "40x40"
    },
    {
      "filename": "icon_120x120.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "40x40"
    },
    {
      "filename": "icon_120x120.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "60x60"
    },
    {
      "filename": "icon_180x180.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "60x60"
    },
    {
      "filename": "icon_20x20.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "20x20"
    },
    {
      "filename": "icon_40x40.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "20x20"
    },
    {
      "filename": "icon_29x29.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "29x29"
    },
    {
      "filename": "icon_58x58.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "29x29"
    },
    {
      "filename": "icon_40x40.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "40x40"
    },
    {
      "filename": "icon_80x80.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "40x40"
    },
    {
      "filename": "icon_76x76.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "76x76"
    },
    {
      "filename": "icon_152x152.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "76x76"
    },
    {
      "filename": "icon_167x167.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "83.5x83.5"
    },
    {
      "filename": "icon_1024x1024.png",
      "idiom": "ios-marketing",
      "scale": "1x",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
EOF

    echo "✅ Fixed $(basename "$APP_PATH")"
}

# Function to remove alpha channel from icons
remove_alpha_channel() {
    local APP_PATH=$1
    local ICON_PATH="${APP_PATH}/Assets.xcassets/AppIcon.appiconset"
    
    echo "🎨 Removing alpha channel from $(basename "$APP_PATH") icons..."
    
    # Use sips to remove alpha channel from all PNG files
    for icon in "${ICON_PATH}"/*.png; do
        if [ -f "$icon" ]; then
            # Create temp file without alpha
            sips -s format png -s formatOptions normal --deleteColorManagementProperties "$icon" --out "$icon.tmp" > /dev/null 2>&1
            # Remove alpha channel
            sips -s hasAlpha no "$icon.tmp" --out "$icon" > /dev/null 2>&1
            rm -f "$icon.tmp"
        fi
    done
    
    echo "✅ Removed alpha from $(basename "$APP_PATH")"
}

# Fix all 5 apps
APP_PATHS=(
    "apps/PersonalHealthApp/iOS/PersonalHealth"
    "apps/ClinicianApp/iOS/FoTClinician"
    "apps/LegalApp/iOS/FoTLegal"
    "apps/EducationApp/iOS/FoTEducation"
    "apps/ParentApp/iOS/FoTParent"
)

for APP in "${APP_PATHS[@]}"; do
    fix_icon_json "$APP"
    remove_alpha_channel "$APP"
    echo ""
done

echo "======================================="
echo "✅ ALL ICONS FIXED"
echo ""
echo "Changes made:"
echo "  ✅ Added 120x120 icon reference to Contents.json"
echo "  ✅ Removed alpha channels from all icons"
echo "  ✅ Proper iOS icon sizes configured"
echo ""
echo "Ready to rebuild and re-upload!"
echo "======================================="

