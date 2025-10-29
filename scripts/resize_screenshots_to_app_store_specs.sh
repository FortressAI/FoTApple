#!/bin/bash
################################################################################
# Resize Screenshots to App Store Connect Required Dimensions
# Required: 1284 × 2778px (iPhone 6.5")
#          2048 × 2732px (iPad 13")
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCREENSHOTS_DIR="$SCRIPT_DIR/../app_store_screenshots"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📐 Resizing Screenshots to App Store Specs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Required dimensions
IPHONE_WIDTH=1284
IPHONE_HEIGHT=2778
IPAD_WIDTH=2048
IPAD_HEIGHT=2732

resize_screenshot() {
    local file=$1
    local width=$2
    local height=$3
    local output=$4
    
    if [ ! -f "$file" ]; then
        echo "  ⚠️  File not found: $file"
        return 1
    fi
    
    # Check current dimensions
    current_dim=$(sips -g pixelWidth -g pixelHeight "$file" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    current_w=$(echo $current_dim | cut -d'x' -f1)
    current_h=$(echo $current_dim | cut -d'x' -f2)
    
    echo "  Resizing: $file"
    echo "    Current: ${current_w}x${current_h}"
    echo "    Target:  ${width}x${height}"
    
    if [ "$current_w" = "$width" ] && [ "$current_h" = "$height" ]; then
        echo "    ✅ Already correct size"
        if [ "$file" != "$output" ]; then
            cp "$file" "$output"
        fi
        return 0
    fi
    
    # Resize using sips (macOS built-in)
    sips -z $height $width "$file" --out "$output" > /dev/null 2>&1 || {
        echo "    ❌ Resize failed"
        return 1
    }
    
    # Verify dimensions
    new_dim=$(sips -g pixelWidth -g pixelHeight "$output" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    new_w=$(echo $new_dim | cut -d'x' -f1)
    new_h=$(echo $new_dim | cut -d'x' -f2)
    
    if [ "$new_w" = "$width" ] && [ "$new_h" = "$height" ]; then
        echo "    ✅ Resized successfully to ${new_w}x${new_h}"
    else
        echo "    ⚠️  Dimensions: ${new_w}x${new_h} (expected ${width}x${height})"
    fi
}

# Process iPhone screenshots
echo "▶ Processing iPhone 6.5\" screenshots..."
for file in "$SCREENSHOTS_DIR"/*_iphone_6.5.png "$SCREENSHOTS_DIR"/*_iphone*.png; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        output="$SCREENSHOTS_DIR/${basename%.*}_resized.png"
        resize_screenshot "$file" $IPHONE_WIDTH $IPHONE_HEIGHT "$file"
    fi
done

echo ""
echo "▶ Processing iPad 13\" screenshots..."
for file in "$SCREENSHOTS_DIR"/*_ipad_13.png "$SCREENSHOTS_DIR"/*_ipad*.png; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        resize_screenshot "$file" $IPAD_WIDTH $IPAD_HEIGHT "$file"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Screenshot Resize Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Verifying dimensions..."
echo ""

for file in "$SCREENSHOTS_DIR"/*.png; do
    if [ -f "$file" ]; then
        dim=$(sips -g pixelWidth -g pixelHeight "$file" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        echo "  $(basename "$file"): $dim"
    fi
done

echo ""
echo "✅ All screenshots are now App Store Connect compatible!"
echo ""

