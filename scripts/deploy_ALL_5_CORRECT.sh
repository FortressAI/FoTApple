#!/bin/bash
#
# Deploy ALL 5 FoT Apple Apps - The CORRECT Apple Way
# Using destination:upload for direct App Store Connect upload
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# Working credentials
API_KEY="706IRVGBDV3B"
API_ISSUER="0be0b98b-ed15-45d9-a644-9a1a26b22d31"
TEAM_ID="WWQQB728U5"

echo "🚀 DEPLOY ALL 5 FoT APPS - CORRECT APPLE METHOD"
echo ""
echo "Using: destination=upload (export + upload in one step)"
echo ""

deploy_app() {
  local APP_NAME="$1"
  local PROJECT="$2"
  local SCHEME="$3"
  local BUNDLE_ID="$4"
  local ICON="$5"
  local VERSION="$6"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$ICON $APP_NAME (v$VERSION)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Set version
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" \
    "$(dirname "$PROJECT")/$(echo "$SCHEME" | sed 's/App$//')/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" \
    "$(dirname "$PROJECT")/$SCHEME/Info.plist" 2>/dev/null || true
  
  echo "   Version: $VERSION"
  
  # Archive
  echo "   [1/2] Archiving..."
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
    > "build/logs/${APP_NAME}_v${VERSION}_archive.log" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "   ❌ Archive failed"
    tail -30 "build/logs/${APP_NAME}_v${VERSION}_archive.log"
    return 1
  fi
  
  echo "   ✅ Archived"
  
  # Export + Upload (ONE STEP with destination:upload)
  echo "   [2/2] Uploading to App Store Connect..."
  
  # Create export plist with PlistBuddy (ensures proper XML)
  EXPORT_PLIST="/tmp/Export_${APP_NAME}_v${VERSION}.plist"
  rm -f "$EXPORT_PLIST"
  /usr/libexec/PlistBuddy -c "Add :destination string upload" "$EXPORT_PLIST"
  /usr/libexec/PlistBuddy -c "Add :method string app-store" "$EXPORT_PLIST"
  /usr/libexec/PlistBuddy -c "Add :teamID string $TEAM_ID" "$EXPORT_PLIST"
  /usr/libexec/PlistBuddy -c "Add :uploadSymbols bool true" "$EXPORT_PLIST"
  /usr/libexec/PlistBuddy -c "Add :signingStyle string automatic" "$EXPORT_PLIST"
  
  # Export with destination:upload (automatically uploads to App Store Connect)
  xcodebuild -exportArchive \
    -archivePath "build/archives/${APP_NAME}_v${VERSION}.xcarchive" \
    -exportPath "build/exports_v${VERSION}/${APP_NAME}" \
    -exportOptionsPlist "/tmp/Export_${APP_NAME}_v${VERSION}.plist" \
    -allowProvisioningUpdates \
    > "build/logs/${APP_NAME}_v${VERSION}_export.log" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "   ❌ Export/Upload failed"
    tail -50 "build/logs/${APP_NAME}_v${VERSION}_export.log" | grep -i "error" || tail -30 "build/logs/${APP_NAME}_v${VERSION}_export.log"
    return 1
  fi
  
  echo "   ✅ UPLOADED TO APP STORE CONNECT!"
  echo ""
  return 0
}

# Deploy all 5 apps
echo "🔴 PersonalHealth"
deploy_app \
  "PersonalHealth" \
  "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" \
  "PersonalHealthApp" \
  "com.fot.myhealth" \
  "🔴" \
  "13"
PH=$?

echo ""
echo "🔵 Clinician"
deploy_app \
  "Clinician" \
  "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" \
  "FoTClinicianApp" \
  "com.fot.clinician" \
  "🔵" \
  "13"
CLIN=$?

echo ""
echo "🟦 Legal"
deploy_app \
  "Legal" \
  "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" \
  "FoTLegalApp" \
  "com.fot.legal" \
  "🟦" \
  "13"
LEGAL=$?

echo ""
echo "🟢 Education"
deploy_app \
  "Education" \
  "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" \
  "FoTEducationApp" \
  "com.fot.education" \
  "🟢" \
  "13"
EDU=$?

echo ""
echo "🟣 Parent"
deploy_app \
  "Parent" \
  "apps/ParentApp/iOS/FoTParentApp.xcodeproj" \
  "FoTParentApp" \
  "com.fot.parent" \
  "🟣" \
  "13"
PARENT=$?

# Final summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "FINAL RESULTS - ALL 5 APPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

[ $PH -eq 0 ] && echo "✅ 🔴 PersonalHealth: UPLOADED" || echo "❌ 🔴 PersonalHealth: FAILED"
[ $CLIN -eq 0 ] && echo "✅ 🔵 Clinician: UPLOADED" || echo "❌ 🔵 Clinician: FAILED"
[ $LEGAL -eq 0 ] && echo "✅ 🟦 Legal: UPLOADED" || echo "❌ 🟦 Legal: FAILED"
[ $EDU -eq 0 ] && echo "✅ 🟢 Education: UPLOADED" || echo "❌ 🟢 Education: FAILED"
[ $PARENT -eq 0 ] && echo "✅ 🟣 Parent: UPLOADED" || echo "❌ 🟣 Parent: FAILED"

SUCCESS_COUNT=$(( ($PH == 0) + ($CLIN == 0) + ($LEGAL == 0) + ($EDU == 0) + ($PARENT == 0) ))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "UPLOADED: $SUCCESS_COUNT / 5 apps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $SUCCESS_COUNT -eq 5 ]; then
  echo ""
  echo "🎉 ALL 5 APPS UPLOADED TO APP STORE CONNECT!"
  echo ""
  echo "Next steps:"
  echo "  1. Apps will appear in App Store Connect within 5-10 minutes"
  echo "  2. They will process for TestFlight (15-30 minutes)"
  echo "  3. Submit for App Review via App Store Connect"
fi

