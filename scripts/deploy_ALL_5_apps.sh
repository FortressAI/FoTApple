#!/bin/bash
#
# Deploy ALL 5 apps with unique icons - Version 9
# Using NEW API keys
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# NEW API Keys - using the first one for all (or specify different ones if needed)
API_KEY_PH="2D6WT653U4"
API_KEY_CLINICIAN="2D6WT653U4"  # Using same key - update if different
API_KEY_LEGAL="6BTQ4MH7DD"
API_KEY_EDUCATION="2D6WT653U4"  # Using same key - update if different
API_KEY_PARENT="2D6WT653U4"     # Using same key - update if different
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"

echo "🚀 DEPLOYING ALL 5 APPS - VERSION 9"
echo ""
echo "All apps have UNIQUE icons:"
echo "  🔴 PersonalHealth: RED heart"
echo "  🔵 Clinician: BLUE medical cross"
echo "  🟦 Legal: NAVY/GOLD scales"
echo "  🟢 Education: GREEN book"
echo "  🟣 Parent: PURPLE family"
echo ""

# Function to deploy one app
deploy_app() {
    local APP_NAME="$1"
    local PROJECT="$2"
    local SCHEME="$3"
    local API_KEY="$4"
    local ICON_DESC="$5"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$ICON_DESC $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Archive
    echo "   [1/3] Archiving..."
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "build/archives/${APP_NAME}_v9_final.xcarchive" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="84V9JRQRRN" \
        SKIP_INSTALL=NO \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_v9_final_archive.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ❌ Archive failed"
        tail -30 "build/logs/${APP_NAME}_v9_final_archive.log"
        return 1
    fi
    
    echo "   ✅ Archived"
    
    # Export
    echo "   [2/3] Exporting..."
    
    cat > "/tmp/Export_${APP_NAME}_v9_final.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>84V9JRQRRN</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
    
    xcodebuild -exportArchive \
        -archivePath "build/archives/${APP_NAME}_v9_final.xcarchive" \
        -exportPath "build/exports_v9_final/${APP_NAME}" \
        -exportOptionsPlist "/tmp/Export_${APP_NAME}_v9_final.plist" \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_v9_final_export.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ❌ Export failed"
        tail -30 "build/logs/${APP_NAME}_v9_final_export.log"
        return 1
    fi
    
    echo "   ✅ Exported"
    
    # Find IPA
    IPA_FILE=$(find "build/exports_v9_final/${APP_NAME}" -name "*.ipa" | head -1)
    
    if [ ! -f "$IPA_FILE" ]; then
        echo "   ❌ IPA not found"
        return 1
    fi
    
    echo "   IPA: $(basename $IPA_FILE) ($(du -h "$IPA_FILE" | cut -f1))"
    
    # Upload
    echo "   [3/3] Uploading to TestFlight..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "build/logs/${APP_NAME}_v9_final_upload.log"
    
    UPLOAD_STATUS=${PIPESTATUS[0]}
    
    if [ $UPLOAD_STATUS -eq 0 ]; then
        echo ""
        echo "   ✅ UPLOADED TO TESTFLIGHT!"
        echo ""
        return 0
    else
        echo ""
        echo "   ❌ Upload failed"
        tail -20 "build/logs/${APP_NAME}_v9_final_upload.log"
        echo ""
        return 1
    fi
}

# Deploy all 5 apps
deploy_app \
    "PersonalHealth" \
    "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" \
    "PersonalHealthApp" \
    "$API_KEY_PH" \
    "🔴"

PH_STATUS=$?

deploy_app \
    "Clinician" \
    "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" \
    "FoTClinicianApp" \
    "$API_KEY_CLINICIAN" \
    "🔵"

CLINICIAN_STATUS=$?

deploy_app \
    "Legal" \
    "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" \
    "FoTLegalApp" \
    "$API_KEY_LEGAL" \
    "🟦"

LEGAL_STATUS=$?

deploy_app \
    "Education" \
    "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" \
    "FoTEducationApp" \
    "$API_KEY_EDUCATION" \
    "🟢"

EDUCATION_STATUS=$?

deploy_app \
    "Parent" \
    "apps/ParentApp/iOS/FoTParentApp.xcodeproj" \
    "FoTParentApp" \
    "$API_KEY_PARENT" \
    "🟣"

PARENT_STATUS=$?

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 DEPLOYMENT SUMMARY - ALL 5 APPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SUCCESS_COUNT=0

if [ $PH_STATUS -eq 0 ]; then
    echo "✅ 🔴 PersonalHealth: UPLOADED"
    SUCCESS_COUNT=$((SUCCESS_COUNT+1))
else
    echo "❌ 🔴 PersonalHealth: FAILED"
fi

if [ $CLINICIAN_STATUS -eq 0 ]; then
    echo "✅ 🔵 Clinician: UPLOADED"
    SUCCESS_COUNT=$((SUCCESS_COUNT+1))
else
    echo "❌ 🔵 Clinician: FAILED"
fi

if [ $LEGAL_STATUS -eq 0 ]; then
    echo "✅ 🟦 Legal: UPLOADED"
    SUCCESS_COUNT=$((SUCCESS_COUNT+1))
else
    echo "❌ 🟦 Legal: FAILED"
fi

if [ $EDUCATION_STATUS -eq 0 ]; then
    echo "✅ 🟢 Education: UPLOADED"
    SUCCESS_COUNT=$((SUCCESS_COUNT+1))
else
    echo "❌ 🟢 Education: FAILED"
fi

if [ $PARENT_STATUS -eq 0 ]; then
    echo "✅ 🟣 Parent: UPLOADED"
    SUCCESS_COUNT=$((SUCCESS_COUNT+1))
else
    echo "❌ 🟣 Parent: FAILED"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $SUCCESS_COUNT -eq 5 ]; then
    echo "🎉 PERFECT! ALL 5 APPS UPLOADED TO TESTFLIGHT!"
    echo ""
    echo "Next steps:"
    echo "1. Wait 15 minutes for Apple processing"
    echo "2. Go to appstoreconnect.apple.com → Resolution Center"
    echo "3. Submit response from APPLE_REVIEW_RESPONSE.md"
    echo ""
    echo "Expected: Apple approval in 24-48 hours! ✅"
elif [ $SUCCESS_COUNT -gt 0 ]; then
    echo "⚠️  Partial success: $SUCCESS_COUNT/5 apps uploaded"
    echo "   Check logs above for failed apps"
else
    echo "❌ All uploads failed - check logs above"
fi

echo ""
echo "All apps have UNIQUE icons - no duplicates!"
echo ""

