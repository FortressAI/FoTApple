#!/bin/bash

set -e

echo "🚀 AUTOMATED TESTFLIGHT UPLOAD - ALL 5 APPS"
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
    
    # Create export options plist
    cat > "$EXPORT_PATH-options.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>upload</string>
</dict>
</plist>
EOF

    # Export archive to IPA
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_PATH-options.plist" \
        > "build/logs/${APP_NAME}_export.log" 2>&1 && \
    echo "✅ $APP_NAME exported" || { echo "❌ $APP_NAME export failed"; cat "build/logs/${APP_NAME}_export.log" | tail -20; return 1; }
    
    # Find the IPA file
    IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -1)
    
    if [ -z "$IPA_FILE" ]; then
        echo "❌ No IPA file found for $APP_NAME"
        return 1
    fi
    
    echo "📤 Uploading $APP_NAME to App Store Connect..."
    
    # Upload using xcrun altool with API key
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$ISSUER_ID" \
        > "build/logs/${APP_NAME}_upload.log" 2>&1 && \
    echo "✅ $APP_NAME uploaded to TestFlight" || { echo "❌ $APP_NAME upload failed"; cat "build/logs/${APP_NAME}_upload.log" | tail -20; return 1; }
    
    echo ""
}

# Export and upload all 5 apps
export_and_upload "PersonalHealthApp"
export_and_upload "FoTClinicianApp"
export_and_upload "FoTLegalApp"
export_and_upload "FoTEducationApp"
export_and_upload "FoTParentApp"

echo "======================================="
echo "🎉 ALL 5 APPS UPLOADED TO TESTFLIGHT!"
echo ""
echo "✅ PersonalHealthApp"
echo "✅ FoTClinicianApp"
echo "✅ FoTLegalApp"
echo "✅ FoTEducationApp"
echo "✅ FoTParentApp"
echo ""
echo "📱 Apps will appear in TestFlight within 5-10 minutes"
echo "======================================="

