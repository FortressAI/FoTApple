#!/usr/bin/env bash
# Reset Apps for Video Recording - Force Onboarding with Siri Voice

set -e

echo "🎬 Resetting FoT Apps for Video Recording with Siri Voice Narration"
echo ""

# Get booted simulator
SIMULATOR=$(xcrun simctl list devices | grep "(Booted)" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')

if [ -z "$SIMULATOR" ]; then
    echo "❌ No booted simulator found!"
    echo "Please start a simulator first."
    exit 1
fi

echo "✅ Found simulator: $SIMULATOR"
echo ""

# Apps to reset
APPS=(
    "com.fot.PersonalHealth|Personal Health"
    "com.fot.ClinicianApp|Clinician"
    "com.fot.LegalApp|Legal"
    "com.fot.EducationApp|Education"
    "com.fot.ParentApp|Parent"
)

for APP_INFO in "${APPS[@]}"; do
    BUNDLE_ID="${APP_INFO%|*}"
    APP_NAME="${APP_INFO#*|}"
    
    echo "🔄 Resetting $APP_NAME..."
    
    # Uninstall app (this clears all app data including @AppStorage)
    xcrun simctl uninstall "$SIMULATOR" "$BUNDLE_ID" 2>/dev/null || echo "  (App not installed yet)"
    
    echo "  ✅ $APP_NAME reset - onboarding will show with Siri voice on next launch!"
done

echo ""
echo "🎉 All apps reset!"
echo ""
echo "📝 Next steps:"
echo "  1. Build and run the app you want to record"
echo "  2. Siri voice narration will play automatically"
echo "  3. Record your video"
echo "  4. Run this script again before next recording"
echo ""
echo "🔊 Make sure:"
echo "  - Mac volume is up"
echo "  - Simulator volume is enabled"
echo "  - Not in silent mode"

