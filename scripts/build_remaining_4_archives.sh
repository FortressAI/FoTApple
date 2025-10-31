#!/bin/bash
#
# Build archives for remaining 4 apps (Clinician, Legal, Education, Parent)
# Then upload via Xcode Organizer GUI
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

TEAM_ID="WWQQB728U5"
VERSION="13"

echo "🏗️  BUILDING REMAINING 4 APP ARCHIVES"
echo ""
echo "After this completes, upload via Xcode Organizer GUI"
echo ""

build_archive() {
  local APP_NAME="$1"
  local PROJECT="$2"
  local SCHEME="$3"
  local ICON="$4"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$ICON $APP_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "build/archives/${APP_NAME}_v${VERSION}.xcarchive" \
    -sdk iphoneos \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    SKIP_INSTALL=NO \
    -allowProvisioningUpdates \
    > "build/logs/${APP_NAME}_v${VERSION}_archive_GUI.log" 2>&1
  
  if [ $? -eq 0 ]; then
    echo "   ✅ Archived!"
    echo "   Location: build/archives/${APP_NAME}_v${VERSION}.xcarchive"
  else
    echo "   ❌ Failed"
    tail -30 "build/logs/${APP_NAME}_v${VERSION}_archive_GUI.log"
    return 1
  fi
  
  echo ""
}

# Build all 4
build_archive "Clinician" "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" "FoTClinicianApp" "🔵"
build_archive "Legal" "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" "FoTLegalApp" "🟦"
build_archive "Education" "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" "FoTEducationApp" "🟢"
build_archive "Parent" "apps/ParentApp/iOS/FoTParentApp.xcodeproj" "FoTParentApp" "🟣"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL 4 ARCHIVES BUILT!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Archives location: build/archives/"
echo ""
echo "🎯 NEXT STEPS:"
echo "   1. Open Xcode: open -a Xcode"
echo "   2. Window → Organizer (⌘⇧2)"
echo "   3. Select each archive → Distribute App → Upload"
echo "   4. Takes ~5 min per app"
echo ""
echo "PersonalHealth v13 is already archived - upload that one first!"

