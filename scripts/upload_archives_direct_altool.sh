#!/bin/bash
#
# Upload archives directly with altool (bypass broken exportArchive in Xcode 26 beta)
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# Working credentials
API_KEY="706IRVGBDV3B"
API_ISSUER="0be0b98b-ed15-45d9-a644-9a1a26b22d31"
TEAM_ID="WWQQB728U5"

echo "🚀 UPLOAD ALL 5 APPS - DIRECT altool METHOD (Xcode 26 beta workaround)"
echo ""
echo "Strategy: Build → Upload .xcarchive with altool --validate-app --upload-package"
echo ""

build_and_upload() {
  local APP_NAME="$1"
  local PROJECT="$2"
  local SCHEME="$3"
  local ICON="$4"
  local VERSION="13"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$ICON $APP_NAME (v$VERSION)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Archive
  echo "   [1/2] Archiving..."
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "build/archives/${APP_NAME}_v${VERSION}_FINAL.xcarchive" \
    -sdk iphoneos \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    SKIP_INSTALL=NO \
    -allowProvisioningUpdates \
    > "build/logs/${APP_NAME}_v${VERSION}_archive_FINAL.log" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "   ❌ Archive failed"
    return 1
  fi
  
  echo "   ✅ Archived"
  
  # Upload using altool with --upload-package (works with Xcode 26 beta)
  echo "   [2/2] Uploading to App Store Connect..."
  
  # Try uploading the .xcarchive directly (API key auth only, no --apple-id)
  xcrun altool --upload-package "build/archives/${APP_NAME}_v${VERSION}_FINAL.xcarchive" \
    --type ios \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER" \
    2>&1 | tee "build/logs/${APP_NAME}_v${VERSION}_upload_FINAL.log"
  
  UPLOAD_RESULT=${PIPESTATUS[0]}
  
  if [ $UPLOAD_RESULT -eq 0 ]; then
    echo "   ✅ UPLOADED!"
    return 0
  else
    echo "   ⚠️  Direct upload failed (exit $UPLOAD_RESULT), trying validation..."
    
    # Alternative: use --validate-app
    xcrun altool --validate-app \
      -f "build/archives/${APP_NAME}_v${VERSION}_FINAL.xcarchive" \
      -t ios \
      --apiKey "$API_KEY" \
      --apiIssuer "$API_ISSUER" \
      2>&1 | tee -a "build/logs/${APP_NAME}_v${VERSION}_upload_FINAL.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
      echo "   ✅ Validated, now uploading..."
      xcrun altool --upload-app \
        -f "build/archives/${APP_NAME}_v${VERSION}_FINAL.xcarchive" \
        -t ios \
        --apiKey "$API_KEY" \
        --apiIssuer "$API_ISSUER" \
        2>&1 | tee -a "build/logs/${APP_NAME}_v${VERSION}_upload_FINAL.log"
      
      if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "   ✅ UPLOADED!"
        return 0
      fi
    fi
    
    echo "   ❌ Upload failed (Xcode 26 beta issue - recommend Xcode GUI)"
    return 1
  fi
}

# Build and upload all 5
build_and_upload "PersonalHealth" "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" "PersonalHealthApp" "🔴"
PH=$?

build_and_upload "Clinician" "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" "FoTClinicianApp" "🔵"
CLIN=$?

build_and_upload "Legal" "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" "FoTLegalApp" "🟦"
LEGAL=$?

build_and_upload "Education" "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" "FoTEducationApp" "🟢"
EDU=$?

build_and_upload "Parent" "apps/ParentApp/iOS/FoTParentApp.xcodeproj" "FoTParentApp" "🟣"
PARENT=$?

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "FINAL RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ $PH -eq 0 ] && echo "✅ 🔴 PersonalHealth" || echo "❌ 🔴 PersonalHealth"
[ $CLIN -eq 0 ] && echo "✅ 🔵 Clinician" || echo "❌ 🔵 Clinician"
[ $LEGAL -eq 0 ] && echo "✅ 🟦 Legal" || echo "❌ 🟦 Legal"
[ $EDU -eq 0 ] && echo "✅ 🟢 Education" || echo "❌ 🟢 Education"
[ $PARENT -eq 0 ] && echo "✅ 🟣 Parent" || echo "❌ 🟣 Parent"

SUCCESS=$(( ($PH == 0) + ($CLIN == 0) + ($LEGAL == 0) + ($EDU == 0) + ($PARENT == 0) ))
echo ""
echo "UPLOADED: $SUCCESS / 5 apps"

if [ $SUCCESS -lt 5 ]; then
  echo ""
  echo "⚠️  Xcode 26 beta has command-line upload issues"
  echo "   Recommend: Use Xcode Organizer GUI for remaining apps"
  echo "   See: STATUS_AND_RECOMMENDATION.md"
fi

