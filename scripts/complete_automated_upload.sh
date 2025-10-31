#!/bin/bash
#
# Complete automated build and upload - Version 9
# With NEW API keys
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# NEW API Keys
API_KEY_PH="2D6WT653U4"
API_KEY_LEGAL="6BTQ4MH7DD"
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"

echo "🚀 COMPLETE AUTOMATED UPLOAD - VERSION 9"
echo ""
echo "New API Keys:"
echo "  PersonalHealth: $API_KEY_PH"
echo "  Legal: $API_KEY_LEGAL"
echo "  Issuer: $API_ISSUER_ID"
echo ""

# Function to build, export, and upload
automated_deploy() {
    local APP_NAME="$1"
    local PROJECT="$2"
    local SCHEME="$3"
    local API_KEY="$4"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 $APP_NAME - Full Automated Deploy"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Archive
    echo "   [1/3] Archiving..."
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "build/archives/${APP_NAME}_v9_auto.xcarchive" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="84V9JRQRRN" \
        SKIP_INSTALL=NO \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_v9_auto_archive.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ❌ Archive failed"
        tail -30 "build/logs/${APP_NAME}_v9_auto_archive.log"
        return 1
    fi
    
    echo "   ✅ Archived"
    
    # Export
    echo "   [2/3] Exporting..."
    
    cat > "/tmp/Export_${APP_NAME}_v9.plist" <<EOF
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
        -archivePath "build/archives/${APP_NAME}_v9_auto.xcarchive" \
        -exportPath "build/exports_v9_auto/${APP_NAME}" \
        -exportOptionsPlist "/tmp/Export_${APP_NAME}_v9.plist" \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_v9_auto_export.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ❌ Export failed"
        tail -30 "build/logs/${APP_NAME}_v9_auto_export.log"
        return 1
    fi
    
    echo "   ✅ Exported"
    
    # Find IPA
    IPA_FILE=$(find "build/exports_v9_auto/${APP_NAME}" -name "*.ipa" | head -1)
    
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
        2>&1 | tee "build/logs/${APP_NAME}_v9_auto_upload.log"
    
    UPLOAD_STATUS=${PIPESTATUS[0]}
    
    if [ $UPLOAD_STATUS -eq 0 ]; then
        echo ""
        echo "   ✅ UPLOADED TO TESTFLIGHT!"
        echo ""
        return 0
    else
        echo ""
        echo "   ❌ Upload failed"
        tail -20 "build/logs/${APP_NAME}_v9_auto_upload.log"
        echo ""
        return 1
    fi
}

# Deploy PersonalHealth
automated_deploy \
    "PersonalHealth" \
    "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" \
    "PersonalHealthApp" \
    "$API_KEY_PH"

PH_STATUS=$?

# Deploy Legal
automated_deploy \
    "Legal" \
    "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" \
    "FoTLegalApp" \
    "$API_KEY_LEGAL"

LEGAL_STATUS=$?

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 DEPLOYMENT SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $PH_STATUS -eq 0 ]; then
    echo "✅ PersonalHealth: UPLOADED TO TESTFLIGHT"
else
    echo "❌ PersonalHealth: FAILED"
fi

if [ $LEGAL_STATUS -eq 0 ]; then
    echo "✅ Legal: UPLOADED TO TESTFLIGHT"
else
    echo "❌ Legal: FAILED"
fi

echo ""

if [ $PH_STATUS -eq 0 ] && [ $LEGAL_STATUS -eq 0 ]; then
    echo "🎉 SUCCESS! Both apps uploaded!"
    echo ""
    echo "Next steps:"
    echo "1. Wait 15 minutes for Apple processing"
    echo "2. Go to appstoreconnect.apple.com → Resolution Center"
    echo "3. Submit response from APPLE_REVIEW_RESPONSE.md"
    echo ""
    echo "Expected: Apple approval in 24-48 hours! ✅"
elif [ $PH_STATUS -eq 0 ] || [ $LEGAL_STATUS -eq 0 ]; then
    echo "⚠️  Partial success - at least one app uploaded"
else
    echo "❌ All uploads failed - check logs above"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

