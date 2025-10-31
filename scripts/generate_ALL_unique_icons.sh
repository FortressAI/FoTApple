#!/bin/bash
#
# Generate ALL 5 unique, professional app icons
# Each with distinct color, theme, and design
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

echo "🎨 GENERATING ALL 5 UNIQUE APP ICONS"
echo ""

# Function to generate icon
generate_icon() {
    local APP_NAME="$1"
    local COLOR="$2"
    local SYMBOL="$3"
    local DESC="$4"
    local ICON_DIR="$5"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 $APP_NAME - $DESC"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    mkdir -p "$ICON_DIR"
    
    # Sizes: 20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024
    local SIZES=(20 29 40 58 60 76 80 87 120 152 167 180 1024)
    
    for SIZE in "${SIZES[@]}"; do
        echo "   Creating ${SIZE}x${SIZE}..."
        
        magick -size ${SIZE}x${SIZE} xc:"$COLOR" \
            -gravity center \
            -pointsize $((SIZE/3)) \
            -fill white \
            -font "Arial-Bold" \
            -draw "text 0,0 '$SYMBOL'" \
            "$ICON_DIR/icon_${SIZE}x${SIZE}.png"
    done
    
    echo "   ✅ All sizes generated"
    echo ""
}

# 1. PersonalHealth - RED heart (medical for individuals)
generate_icon \
    "PersonalHealth" \
    "#DC143C" \
    "♥" \
    "RED heart (medical for individuals)" \
    "apps/PersonalHealthApp/iOS/PersonalHealth/Assets.xcassets/AppIcon.appiconset"

# 2. Clinician - BLUE medical cross (for healthcare professionals)
generate_icon \
    "Clinician" \
    "#0066CC" \
    "✚" \
    "BLUE medical cross (for healthcare professionals)" \
    "apps/ClinicianApp/iOS/FoTClinician/Assets.xcassets/AppIcon.appiconset"

# 3. Legal - NAVY/GOLD scales (for legal professionals)
generate_icon \
    "Legal" \
    "#1B365D" \
    "⚖" \
    "NAVY/GOLD scales (for legal professionals)" \
    "apps/LegalApp/iOS/FoTLegal/Assets.xcassets/AppIcon.appiconset"

# 4. Education - GREEN book (for K-18 educators)
generate_icon \
    "Education" \
    "#228B22" \
    "📚" \
    "GREEN book (for K-18 educators)" \
    "apps/EducationApp/iOS/FoTEducation/Assets.xcassets/AppIcon.appiconset"

# 5. Parent - PURPLE family (for parents)
generate_icon \
    "Parent" \
    "#8B008B" \
    "👪" \
    "PURPLE family (for parents)" \
    "apps/ParentApp/iOS/FoTParent/Assets.xcassets/AppIcon.appiconset"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL 5 UNIQUE ICONS GENERATED!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Icon Summary:"
echo "  🔴 PersonalHealth: RED heart (medical)"
echo "  🔵 Clinician: BLUE medical cross (medical professionals)"
echo "  🟦 Legal: NAVY/GOLD scales (legal)"
echo "  🟢 Education: GREEN book (education)"
echo "  🟣 Parent: PURPLE family (parents)"
echo ""
echo "All icons are:"
echo "  ✅ Unique colors"
echo "  ✅ Unique symbols"
echo "  ✅ Professional designs"
echo "  ✅ NOT duplicates"

