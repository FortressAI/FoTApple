#!/bin/bash

set -e

echo "🚀 TESTFLIGHT UPLOAD VIA TRANSPORTER - ALL 5 APPS"
echo "======================================="
echo ""

cd "$(dirname "$0")/.."

# API credentials
API_KEY_ID="706IRVGBDV3B"
API_KEY_PATH="/Users/richardgillespie/Documents/FoTApple/keys/ApiKey_706IRVGBDV3B.p8"
ISSUER_ID="69a6de95-fd71-47e3-e053-5b8c7c11a4d1"
TEAM_ID="WWQQB728U5"

mkdir -p build/exports

# Function to export and upload an archive
export_and_upload() {
    local APP_NAME=$1
    local ARCHIVE_PATH="build/archives/${APP_NAME}_v13.xcarchive"
    local EXPORT_PATH="build/exports/${APP_NAME}_v13"
    
    echo "📦 Exporting $APP_NAME..."
    
    # Create export options plist with updated method
    cat > "$EXPORT_PATH-options.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
</dict>
</plist>
EOF

    # Export archive to IPA
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_PATH-options.plist" \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_export.log" 2>&1 && \
    echo "✅ $APP_NAME exported" || { echo "⚠️  $APP_NAME export issue, checking..."; cat "build/logs/${APP_NAME}_export.log" | tail -30; }
    
    # Find the IPA file
    IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" 2>/dev/null | head -1)
    
    if [ -z "$IPA_FILE" ]; then
        echo "❌ No IPA file found for $APP_NAME, trying direct upload from archive..."
        
        # Try using xcrun notarytool / altool directly on the archive
        xcrun altool --upload-app \
            --type ios \
            --file "$ARCHIVE_PATH" \
            --apiKey "$API_KEY_ID" \
            --apiIssuer "$ISSUER_ID" \
            2>&1 | tee "build/logs/${APP_NAME}_upload_direct.log" || {
            echo "❌ Direct upload also failed for $APP_NAME"
            return 1
        }
        
        echo "✅ $APP_NAME uploaded via direct method"
        return 0
    fi
    
    echo "📤 Uploading $APP_NAME to App Store Connect..."
    echo "   IPA: $IPA_FILE"
    
    # Upload using xcrun altool with API key
    xcrun altool --upload-package "$IPA_FILE" \
        --type ios \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$ISSUER_ID" \
        2>&1 | tee "build/logs/${APP_NAME}_upload.log" && \
    echo "✅ $APP_NAME uploaded to TestFlight" || {
        echo "⚠️  Upload issue for $APP_NAME, trying alternative method..."
        
        # Try with iTMSTransporter
        xcrun iTMSTransporter -m upload \
            -assetFile "$IPA_FILE" \
            -jwt \
            -apiKey "$API_KEY_ID" \
            -apiIssuer "$ISSUER_ID" \
            2>&1 | tee "build/logs/${APP_NAME}_upload_itms.log" || {
            echo "❌ All upload methods failed for $APP_NAME"
            return 1
        }
        echo "✅ $APP_NAME uploaded via iTMSTransporter"
    }
    
    echo ""
}

# Export and upload all 5 apps
APPS=("PersonalHealthApp" "FoTClinicianApp" "FoTLegalApp" "FoTEducationApp" "FoTParentApp")
SUCCESS_COUNT=0
FAILED_APPS=()

for APP in "${APPS[@]}"; do
    if export_and_upload "$APP"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        FAILED_APPS+=("$APP")
    fi
done

echo "======================================="
echo "📊 UPLOAD RESULTS:"
echo "   ✅ Successful: $SUCCESS_COUNT/5"
if [ ${#FAILED_APPS[@]} -gt 0 ]; then
    echo "   ❌ Failed: ${FAILED_APPS[@]}"
fi
echo ""

if [ $SUCCESS_COUNT -eq 5 ]; then
    echo "🎉 ALL 5 APPS UPLOADED TO TESTFLIGHT!"
    echo ""
    echo "✅ PersonalHealthApp"
    echo "✅ FoTClinicianApp"
    echo "✅ FoTLegalApp"
    echo "✅ FoTEducationApp"
    echo "✅ FoTParentApp"
    echo ""
    echo "📱 Apps will appear in TestFlight within 5-10 minutes"
else
    echo "⚠️  Some apps failed to upload. Check logs in build/logs/"
fi
echo "======================================="

