#!/bin/bash
#
# Automatic upload of all apps to TestFlight
# NO MANUAL STEPS REQUIRED
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# API credentials
API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="d648c36b-f731-4c3e-bb88-32aad08f9f2d"
API_KEY_PATH="$PROJECT_DIR/AuthKey_${API_KEY_ID}.p8"
TEAM_ID="84V9JRQRRN"

echo "🚀 AUTOMATIC TESTFLIGHT UPLOAD - ALL APPS"
echo ""
echo "Using API Key: $API_KEY_ID"
echo "Issuer ID: $API_ISSUER_ID"
echo ""

# Function to export and upload an archive
upload_archive() {
    local ARCHIVE_PATH="$1"
    local APP_NAME="$2"
    local BUNDLE_ID="$3"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ ! -d "$ARCHIVE_PATH" ]; then
        echo "⚠️  Archive not found: $ARCHIVE_PATH"
        return 1
    fi
    
    local EXPORT_DIR="$PROJECT_DIR/build/exports/$(basename $ARCHIVE_PATH .xcarchive)"
    mkdir -p "$EXPORT_DIR"
    
    # Create export options plist
    cat > /tmp/ExportOptions_${APP_NAME}.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>upload</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>${BUNDLE_ID}</key>
        <string>match AppStore ${BUNDLE_ID}</string>
    </dict>
</dict>
</plist>
EOF
    
    echo "   Exporting..."
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_DIR" \
        -exportOptionsPlist /tmp/ExportOptions_${APP_NAME}.plist \
        -allowProvisioningUpdates \
        > "$PROJECT_DIR/build/logs/${APP_NAME}_export_auto.log" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Export complete"
        
        # Find the IPA
        IPA_FILE=$(find "$EXPORT_DIR" -name "*.ipa" | head -1)
        
        if [ -f "$IPA_FILE" ]; then
            echo "   Uploading to TestFlight..."
            
            xcrun altool --upload-app \
                --type ios \
                --file "$IPA_FILE" \
                --apiKey "$API_KEY_ID" \
                --apiIssuer "$API_ISSUER_ID" \
                > "$PROJECT_DIR/build/logs/${APP_NAME}_upload_auto.log" 2>&1
            
            if [ $? -eq 0 ]; then
                echo "   ✅ UPLOADED TO TESTFLIGHT!"
                return 0
            else
                echo "   ⚠️  Upload failed - check logs"
                tail -20 "$PROJECT_DIR/build/logs/${APP_NAME}_upload_auto.log"
                return 1
            fi
        else
            echo "   ⚠️  No IPA found in $EXPORT_DIR"
            return 1
        fi
    else
        echo "   ⚠️  Export failed"
        tail -20 "$PROJECT_DIR/build/logs/${APP_NAME}_export_auto.log"
        return 1
    fi
}

# Upload all successful archives
echo "🎯 Step 1: Upload existing successful archives"
echo ""

upload_archive \
    "$PROJECT_DIR/build/archives/PersonalHealth_iOS.xcarchive" \
    "PersonalHealth" \
    "com.fotapple.personalhealth"

upload_archive \
    "$PROJECT_DIR/build/archives/Legal_iOS.xcarchive" \
    "Legal" \
    "com.fotapple.legal"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ UPLOAD PHASE COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

