#!/bin/bash
#
# Build archive and upload directly using xcrun notarytool/altool
# Bypass the problematic export step
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# Working credentials
API_KEY="706IRVGBDV3B"
API_ISSUER="0be0b98b-ed15-45d9-a644-9a1a26b22d31"

echo "🚀 BUILD & DIRECT UPLOAD (bypassing export)"
echo ""
echo "Strategy: Archive → Upload .xcarchive directly"
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
  echo "   [1/2] Archiving..."
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "build/archives/${APP_NAME}_v13_DIRECT.xcarchive" \
    -sdk iphoneos \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="WWQQB728U5" \
    SKIP_INSTALL=NO \
    -allowProvisioningUpdates \
    > "build/logs/${APP_NAME}_v13_archive_DIRECT.log" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "   ❌ Archive failed"
    tail -30 "build/logs/${APP_NAME}_v13_archive_DIRECT.log"
    return 1
  fi
  
  echo "   ✅ Archived"
  
  # Try to upload .xcarchive directly (newer Xcode versions support this)
  echo "   [2/2] Uploading archive to App Store Connect..."
  
  xcrun altool --validate-app \
    -f "build/archives/${APP_NAME}_v13_DIRECT.xcarchive" \
    -t ios \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER" \
    2>&1 | tee "build/logs/${APP_NAME}_v13_upload_DIRECT.log"
  
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "   ✅ Validated!"
    
    # Now upload
    xcrun altool --upload-app \
      -f "build/archives/${APP_NAME}_v13_DIRECT.xcarchive" \
      -t ios \
      --apiKey "$API_KEY" \
      --apiIssuer "$API_ISSUER" \
      2>&1 | tee -a "build/logs/${APP_NAME}_v13_upload_DIRECT.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
      echo ""
      echo "   ✅ UPLOADED TO TESTFLIGHT!"
      echo ""
      return 0
    else
      echo "   ❌ Upload failed (see log)"
      return 1
    fi
  else
    echo "   ❌ Validation failed - .xcarchive upload not supported"
    echo "   Trying manual IPA extraction..."
    
    # Fallback: Extract IPA from .xcarchive manually
    APP_PATH=$(find "build/archives/${APP_NAME}_v13_DIRECT.xcarchive/Products/Applications" -name "*.app" | head -1)
    
    if [ -z "$APP_PATH" ]; then
      echo "   ❌ Could not find .app in archive"
      return 1
    fi
    
    echo "   Found: $(basename "$APP_PATH")"
    
    # Create Payload directory and copy .app
    mkdir -p "build/manual_ipa/Payload"
    cp -R "$APP_PATH" "build/manual_ipa/Payload/"
    
    # Create IPA
    cd "build/manual_ipa"
    zip -r "../${APP_NAME}_v13_MANUAL.ipa" Payload
    cd "$PROJECT_DIR"
    
    echo "   📦 Created: build/${APP_NAME}_v13_MANUAL.ipa"
    
    # Upload IPA
    xcrun altool --upload-app \
      --type ios \
      --file "build/${APP_NAME}_v13_MANUAL.ipa" \
      --apiKey "$API_KEY" \
      --apiIssuer "$API_ISSUER" \
      2>&1 | tee "build/logs/${APP_NAME}_v13_upload_MANUAL.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
      echo ""
      echo "   ✅ UPLOADED TO TESTFLIGHT!"
      echo ""
      return 0
    else
      echo "   ❌ Upload failed"
      return 1
    fi
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
fi

