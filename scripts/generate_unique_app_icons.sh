#!/bin/bash
#
# Generate unique app icons for each FoT app
# Each icon will have a distinct color scheme and symbol
#

set -e

echo "🎨 Generating unique app icons for all Field of Truth apps..."
echo ""

# Create temporary directory for icon generation
ICON_TEMP_DIR="/tmp/fot_icons_$$"
mkdir -p "$ICON_TEMP_DIR"

# Base project directory
PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"

# Function to generate a colored icon with SF Symbol
generate_icon() {
    local APP_NAME="$1"
    local SF_SYMBOL="$2"
    local BG_COLOR="$3"
    local FG_COLOR="$4"
    local OUTPUT_DIR="$5"
    local SIZE="$6"
    
    echo "  Generating ${SIZE}x${SIZE} icon for $APP_NAME..."
    
    # Use sips and iconutil to create icons
    # For now, create a simple placeholder script that uses ImageMagick or Python PIL
    
    # Create icon using Python PIL (if available)
    python3 - <<PYTHON_SCRIPT
import sys
try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("ERROR: PIL/Pillow not installed. Run: pip3 install Pillow")
    sys.exit(1)

# Create image
size = ${SIZE}
img = Image.new('RGB', (size, size), color='${BG_COLOR}')
draw = ImageDraw.Draw(img)

# Draw a simple geometric shape as placeholder
# (In production, you'd use SF Symbols or custom artwork)
if '${APP_NAME}' == 'PersonalHealth':
    # Heart shape (simplified)
    draw.ellipse([size//4, size//4, 3*size//4, 3*size//4], fill='${FG_COLOR}')
elif '${APP_NAME}' == 'Clinician':
    # Medical cross
    bar_width = size // 5
    draw.rectangle([size//2-bar_width//2, size//5, size//2+bar_width//2, 4*size//5], fill='${FG_COLOR}')
    draw.rectangle([size//5, size//2-bar_width//2, 4*size//5, size//2+bar_width//2], fill='${FG_COLOR}')
elif '${APP_NAME}' == 'Legal':
    # Scales (simplified as triangle)
    draw.polygon([size//2, size//4, size//4, 3*size//4, 3*size//4, 3*size//4], fill='${FG_COLOR}')
elif '${APP_NAME}' == 'Education':
    # Book (rectangle with line)
    draw.rectangle([size//4, size//3, 3*size//4, 2*size//3], outline='${FG_COLOR}', width=size//20)
    draw.line([size//2, size//3, size//2, 2*size//3], fill='${FG_COLOR}', width=size//30)
elif '${APP_NAME}' == 'Parent':
    # Parent+child (two circles)
    draw.ellipse([size//4, size//5, 3*size//5, 3*size//5], fill='${FG_COLOR}')
    draw.ellipse([size//2, size//2, 4*size//5, 4*size//5], fill='${FG_COLOR}')

# Save
img.save('${OUTPUT_DIR}/icon_${SIZE}x${SIZE}.png')
print(f"Created ${OUTPUT_DIR}/icon_${SIZE}x${SIZE}.png")
PYTHON_SCRIPT
}

# Function to update AppIcon.appiconset
update_app_icon_set() {
    local APP_NAME="$1"
    local ICON_SET_PATH="$2"
    local BG_COLOR="$3"
    local FG_COLOR="$4"
    
    echo ""
    echo "📱 Updating $APP_NAME app icon..."
    
    # Create icon directory if it doesn't exist
    mkdir -p "$ICON_SET_PATH"
    
    # Generate all required sizes
    local SIZES=(20 29 40 58 60 76 80 87 120 152 167 180 1024)
    
    for SIZE in "${SIZES[@]}"; do
        generate_icon "$APP_NAME" "heart.fill" "$BG_COLOR" "$FG_COLOR" "$ICON_SET_PATH" "$SIZE"
    done
    
    # Create Contents.json
    cat > "$ICON_SET_PATH/Contents.json" <<JSON
{
  "images" : [
    {
      "filename" : "icon_40x40.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_60x60.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_58x58.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_87x87.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_80x80.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_120x120.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_120x120.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_180x180.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_1024x1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
    
    echo "✅ $APP_NAME icon set updated"
}

# Check if Python PIL is available
if ! python3 -c "from PIL import Image" 2>/dev/null; then
    echo "⚠️  PIL/Pillow not found. Installing..."
    pip3 install --user Pillow || {
        echo "❌ Failed to install Pillow. Please install manually: pip3 install Pillow"
        exit 1
    }
fi

# Generate icons for each app
echo ""
echo "🎨 Creating unique icons with distinct color schemes..."
echo ""

# Personal Health - Red/Pink theme
update_app_icon_set "PersonalHealth" \
    "$PROJECT_DIR/apps/PersonalHealthApp/iOS/PersonalHealth/Assets.xcassets/AppIcon.appiconset" \
    "#FF3B30" "#FFFFFF"

# Clinician - Blue theme
update_app_icon_set "Clinician" \
    "$PROJECT_DIR/apps/ClinicianApp/iOS/FoTClinician/Assets.xcassets/AppIcon.appiconset" \
    "#007AFF" "#FFFFFF"

# Legal - Navy/Gold theme
update_app_icon_set "Legal" \
    "$PROJECT_DIR/apps/LegalApp/iOS/FoTLegal/Assets.xcassets/AppIcon.appiconset" \
    "#1C3A5C" "#FFD700"

# Education - Green theme
update_app_icon_set "Education" \
    "$PROJECT_DIR/apps/EducationApp/iOS/FoTEducation/Assets.xcassets/AppIcon.appiconset" \
    "#34C759" "#FFFFFF"

# Parent - Purple theme
update_app_icon_set "Parent" \
    "$PROJECT_DIR/apps/ParentApp/iOS/FoTParent/Assets.xcassets/AppIcon.appiconset" \
    "#AF52DE" "#FFFFFF"

echo ""
echo "✅ ALL APP ICONS GENERATED"
echo ""
echo "Color schemes:"
echo "  • Personal Health: Red (#FF3B30) - Heart health theme"
echo "  • Clinician: Blue (#007AFF) - Medical professional theme"
echo "  • Legal: Navy/Gold (#1C3A5C/#FFD700) - Legal authority theme"
echo "  • Education: Green (#34C759) - Learning/growth theme"
echo "  • Parent: Purple (#AF52DE) - Family/nurturing theme"
echo ""
echo "🎯 Next step: Rebuild all apps and resubmit to Apple"

# Cleanup
rm -rf "$ICON_TEMP_DIR"

