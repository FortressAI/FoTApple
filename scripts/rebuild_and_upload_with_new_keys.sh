#!/bin/bash
#
# Rebuild apps with version 9 and upload with NEW API keys
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# NEW API Keys (just downloaded)
# Note: We need the Issuer ID - assuming it's the same for both keys
# If you have DIFFERENT Issuer IDs for each key, update below
API_KEY_PH="2D6WT653U4"  # PersonalHealth
API_KEY_LEGAL="6BTQ4MH7DD"  # Legal
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"  # Using the one from deploy script

echo "🚀 REBUILD AND UPLOAD WITH NEW API KEYS"
echo ""
echo "Version: 9 (incremented from 8)"
echo "PersonalHealth Key: $API_KEY_PH"
echo "Legal Key: $API_KEY_LEGAL"
echo "Issuer ID: $API_ISSUER_ID"
echo ""

# Function to build and upload
build_and_upload() {
    local APP_NAME="$1"
    local PROJECT="$2"
    local SCHEME="$3"
    local API_KEY="$4"
    local BUNDLE_ID="$5"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Clean
    echo "   Cleaning..."
    xcodebuild clean \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        > "build/logs/${APP_NAME}_clean_v9.log" 2>&1
    
    # Archive
    echo "   Archiving..."
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "build/archives/${APP_NAME}_v9.xcarchive" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="84V9JRQRRN" \
        SKIP_INSTALL=NO \
        > "build/logs/${APP_NAME}_archive_v9.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ❌ Archive failed"
        tail -30 "build/logs/${APP_NAME}_archive_v9.log"
        return 1
    fi
    
    echo "   ✅ Archived"
    
    # Export
    echo "   Exporting..."
    
    cat > "/tmp/ExportOptions_${APP_NAME}_v9.plist" <<EOF
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
        -archivePath "build/archives/${APP_NAME}_v9.xcarchive" \
        -exportPath "build/exports_v9/${APP_NAME}" \
        -exportOptionsPlist "/tmp/ExportOptions_${APP_NAME}_v9.plist" \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_export_v9.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ❌ Export failed"
        tail -30 "build/logs/${APP_NAME}_export_v9.log"
        return 1
    fi
    
    echo "   ✅ Exported"
    
    # Find IPA
    IPA_FILE=$(find "build/exports_v9/${APP_NAME}" -name "*.ipa" | head -1)
    
    if [ ! -f "$IPA_FILE" ]; then
        echo "   ❌ IPA not found"
        return 1
    fi
    
    echo "   IPA: $IPA_FILE"
    echo "   Size: $(du -h "$IPA_FILE" | cut -f1)"
    
    # Upload
    echo "   Uploading to TestFlight..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "build/logs/${APP_NAME}_upload_v9.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo ""
        echo "   ✅ UPLOADED TO TESTFLIGHT!"
        echo ""
        return 0
    else
        echo ""
        echo "   ❌ Upload failed - check logs"
        tail -20 "build/logs/${APP_NAME}_upload_v9.log"
        echo ""
        return 1
    fi
}

# Build and upload PersonalHealth
build_and_upload \
    "PersonalHealth" \
    "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" \
    "PersonalHealthApp" \
    "$API_KEY_PH" \
    "com.fot.PersonalHealth"

# Build and upload Legal
build_and_upload \
    "Legal" \
    "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" \
    "FoTLegalApp" \
    "$API_KEY_LEGAL" \
    "com.fot.LegalApp"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL DONE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next: Wait 15 minutes, then submit response to Apple"
echo "      from APPLE_REVIEW_RESPONSE.md"

