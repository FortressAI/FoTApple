#!/bin/bash

set -e

echo "🔧 FIXING ICON CONFIGURATIONS FOR ALL 5 APPS"
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

    echo "✅ Fixed $(basename "$APP_PATH") Contents.json"
}

# Fix all 5 apps
fix_icon_json "apps/PersonalHealthApp/iOS/PersonalHealth"
fix_icon_json "apps/ClinicianApp/iOS/FoTClinician"
fix_icon_json "apps/LegalApp/iOS/FoTLegal"
fix_icon_json "apps/EducationApp/iOS/FoTEducation"
fix_icon_json "apps/ParentApp/iOS/FoTParent"

echo ""
echo "======================================="
echo "✅ ALL ICON CONFIGURATIONS FIXED"
echo ""
echo "Added proper 120x120 icon references to all apps"
echo "Ready to rebuild!"
echo "======================================="

