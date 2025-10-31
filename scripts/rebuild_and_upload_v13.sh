#!/bin/bash
#
# Rebuild with v13 and upload with working personal key
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# Working credentials!
API_KEY="706IRVGBDV3B"
API_ISSUER="0be0b98b-ed15-45d9-a644-9a1a26b22d31"

echo "🚀 REBUILD & UPLOAD - VERSION 13"
echo ""
echo "Using YOUR personal API key ✅"
echo ""

build_and_upload() {
  local APP_NAME="$1"
  local PROJECT="$2"
  local SCHEME="$3"
  local ICON="$4"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$ICON $APP_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Archive
  echo "   [1/3] Archiving..."
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "build/archives/${APP_NAME}_v13.xcarchive" \
    -sdk iphoneos \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="WWQQB728U5" \
    SKIP_INSTALL=NO \
    -allowProvisioningUpdates \
    > "build/logs/${APP_NAME}_v13_archive.log" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "   ❌ Archive failed"
    tail -30 "build/logs/${APP_NAME}_v13_archive.log"
    return 1
  fi
  
  echo "   ✅ Archived"
  
  # Export
  echo "   [2/3] Exporting..."
  
  /usr/libexec/PlistBuddy -c "Clear dict" "/tmp/Export_${APP_NAME}_v13.plist" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :method string app-store" "/tmp/Export_${APP_NAME}_v13.plist"
  /usr/libexec/PlistBuddy -c "Add :teamID string WWQQB728U5" "/tmp/Export_${APP_NAME}_v13.plist"
  /usr/libexec/PlistBuddy -c "Add :uploadSymbols bool true" "/tmp/Export_${APP_NAME}_v13.plist"
  /usr/libexec/PlistBuddy -c "Add :signingStyle string automatic" "/tmp/Export_${APP_NAME}_v13.plist"
  
  xcodebuild -exportArchive \
    -archivePath "build/archives/${APP_NAME}_v13.xcarchive" \
    -exportPath "build/exports_v13/${APP_NAME}" \
    -exportOptionsPlist "/tmp/Export_${APP_NAME}_v13.plist" \
    -allowProvisioningUpdates \
    > "build/logs/${APP_NAME}_v13_export.log" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "   ❌ Export failed"
    tail -30 "build/logs/${APP_NAME}_v13_export.log"
    return 1
  fi
  
  echo "   ✅ Exported"
  
  # Find IPA
  IPA_FILE=$(find "build/exports_v13/${APP_NAME}" -name "*.ipa" | head -1)
  
  if [ ! -f "$IPA_FILE" ]; then
    echo "   ❌ IPA not found"
    return 1
  fi
  
  echo "   📦 $(du -h "$IPA_FILE" | cut -f1)"
  
  # Upload
  echo "   [3/3] Uploading to TestFlight..."
  
  xcrun altool --upload-app \
    --type ios \
    --file "$IPA_FILE" \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER" \
    2>&1 | tee "build/logs/${APP_NAME}_v13_upload.log"
  
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "   ✅ UPLOADED TO TESTFLIGHT!"
    echo ""
    return 0
  else
    echo ""
    echo "   ❌ Upload failed"
    tail -20 "build/logs/${APP_NAME}_v13_upload.log"
    echo ""
    return 1
  fi
}

# Build and upload PersonalHealth
build_and_upload \
  "PersonalHealth" \
  "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" \
  "PersonalHealthApp" \
  "🔴"

PH=$?

# Build and upload Legal
build_and_upload \
  "Legal" \
  "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" \
  "FoTLegalApp" \
  "🟦"

LEGAL=$?

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "FINAL RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $PH -eq 0 ]; then
  echo "✅ 🔴 PersonalHealth: UPLOADED"
else
  echo "❌ 🔴 PersonalHealth: FAILED"
fi

if [ $LEGAL -eq 0 ]; then
  echo "✅ 🟦 Legal: UPLOADED"
else
  echo "❌ 🟦 Legal: FAILED"
fi

if [ $PH -eq 0 ] && [ $LEGAL -eq 0 ]; then
  echo ""
  echo "🎉 BOTH APPS UPLOADED TO TESTFLIGHT!"
  echo ""
  echo "Next: Submit response to Apple Review"
  echo "      from APPLE_REVIEW_RESPONSE.md"
fi

