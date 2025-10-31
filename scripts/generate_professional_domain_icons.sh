#!/bin/bash
#
# Generate Professional Domain-Specific Icons
# Cohesive design strategy with Personal vs Professional archetypes
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

echo "🎨 GENERATING PROFESSIONAL DOMAIN ICONS"
echo ""
echo "Design Strategy:"
echo "  📱 PERSONAL Apps: Rounded, warm colors, 'P' badge"
echo "  👔 PROFESSIONAL Apps: Sharp, authoritative, professional symbols"
echo ""

# Function to create icon with domain imagery
create_domain_icon() {
    local APP_NAME="$1"
    local BASE_COLOR="$2"
    local ACCENT_COLOR="$3"
    local SYMBOL="$4"
    local IS_PERSONAL="$5"
    local ICON_DIR="$6"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   Base: $BASE_COLOR"
    echo "   Accent: $ACCENT_COLOR"
    echo "   Symbol: $SYMBOL"
    echo "   Type: $IS_PERSONAL"
    echo ""
    
    mkdir -p "$ICON_DIR"
    
    # All required sizes
    local SIZES=(20 29 40 58 60 76 80 87 120 152 167 180 1024)
    
    for SIZE in "${SIZES[@]}"; do
        echo "   Creating ${SIZE}x${SIZE}..."
        
        if [ "$IS_PERSONAL" = "PERSONAL" ]; then
            # Personal apps: Rounded corners, 'P' badge, warm gradient
            magick -size ${SIZE}x${SIZE} \
                -define gradient:angle=135 \
                gradient:"$BASE_COLOR"-"$ACCENT_COLOR" \
                \( +clone -alpha extract \
                   -draw "fill black polygon 0,0 0,${SIZE} ${SIZE},${SIZE} ${SIZE},0" \
                   -blur 0x$((SIZE/40)) \
                \) -alpha off -compose CopyOpacity -composite \
                -gravity center \
                -pointsize $((SIZE/2)) \
                -fill white \
                -font "Arial-Bold" \
                -draw "text 0,0 '$SYMBOL'" \
                -gravity southeast \
                -pointsize $((SIZE/4)) \
                -fill "$ACCENT_COLOR" \
                -draw "circle $((SIZE*3/4)),$((SIZE*3/4)) $((SIZE*7/8)),$((SIZE*7/8))" \
                -fill white \
                -draw "text -$((SIZE/6)),-$((SIZE/12)) 'P'" \
                "$ICON_DIR/icon_${SIZE}x${SIZE}.png"
        else
            # Professional apps: Sharp corners, professional gradient, symbol only
            magick -size ${SIZE}x${SIZE} \
                -define gradient:angle=135 \
                gradient:"$BASE_COLOR"-"$ACCENT_COLOR" \
                -gravity center \
                -pointsize $((SIZE/2)) \
                -fill white \
                -font "Arial-Bold" \
                -draw "text 0,0 '$SYMBOL'" \
                -gravity northeast \
                -pointsize $((SIZE/6)) \
                -fill rgba\(255,255,255,0.3\) \
                -draw "rectangle $((SIZE*2/3)),0 ${SIZE},$((SIZE/3))" \
                "$ICON_DIR/icon_${SIZE}x${SIZE}.png"
        fi
    done
    
    echo "   ✅ Complete"
    echo ""
}

# 1. PersonalHealth - PERSONAL
# Warm red gradient, heart symbol, 'P' badge
create_domain_icon \
    "PersonalHealth" \
    "#E63946" \
    "#FF6B6B" \
    "♥" \
    "PERSONAL" \
    "apps/PersonalHealthApp/iOS/PersonalHealth/Assets.xcassets/AppIcon.appiconset"

# 2. Clinician - PROFESSIONAL  
# Medical blue-green gradient, caduceus/medical cross
create_domain_icon \
    "Clinician" \
    "#0077B6" \
    "#00B4D8" \
    "⚕" \
    "PROFESSIONAL" \
    "apps/ClinicianApp/iOS/FoTClinician/Assets.xcassets/AppIcon.appiconset"

# 3. Legal - PROFESSIONAL
# Deep navy to gold gradient, scales of justice
create_domain_icon \
    "Legal" \
    "#1B365D" \
    "#DAA520" \
    "⚖" \
    "PROFESSIONAL" \
    "apps/LegalApp/iOS/FoTLegal/Assets.xcassets/AppIcon.appiconset"

# 4. Education - PROFESSIONAL
# Vibrant green gradient, academic cap or book
create_domain_icon \
    "Education" \
    "#2A9D8F" \
    "#52B788" \
    "🎓" \
    "PROFESSIONAL" \
    "apps/EducationApp/iOS/FoTEducation/Assets.xcassets/AppIcon.appiconset"

# 5. Parent - PERSONAL
# Purple gradient, family/home symbol, 'P' badge
create_domain_icon \
    "Parent" \
    "#7209B7" \
    "#B185DB" \
    "👪" \
    "PERSONAL" \
    "apps/ParentApp/iOS/FoTParent/Assets.xcassets/AppIcon.appiconset"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL PROFESSIONAL DOMAIN ICONS GENERATED!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Design Cohesion:"
echo "  ✓ All use professional gradients"
echo "  ✓ All use domain-specific symbols"
echo "  ✓ Personal apps marked with 'P' badge"
echo "  ✓ Professional apps have subtle corner accent"
echo "  ✓ Consistent typography and layout"
echo ""
echo "Icon Summary:"
echo "  👤 PERSONAL:"
echo "     • PersonalHealth: Red gradient, heart ♥, 'P' badge"
echo "     • Parent: Purple gradient, family 👪, 'P' badge"
echo ""
echo "  👔 PROFESSIONAL:"
echo "     • Clinician: Medical blue, caduceus ⚕"
echo "     • Legal: Navy-Gold, scales ⚖"
echo "     • Education: Green, academic cap 🎓"
echo ""
echo "All icons are visually distinct, yet share a unified design language!"

