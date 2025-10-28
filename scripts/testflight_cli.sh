#!/bin/bash
# Full CLI TestFlight Deployment (No Xcode GUI Required)
# Uses xcodebuild + App Store Connect API

set -e

TEAM_ID="WWQQB728U5"
APP_NAME="PersonalHealthApp"
PROJECT_PATH="apps/PersonalHealthApp/iOS"
SCHEME="PersonalHealthApp"
BUNDLE_ID="com.fot.PersonalHealth"

# Configuration
ARCHIVE_PATH="./build/archives/${SCHEME}.xcarchive"
EXPORT_PATH="./build/exports/${SCHEME}"
IPA_PATH="${EXPORT_PATH}/${SCHEME}.ipa"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CLI TestFlight Deployment: ${APP_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for API credentials
if [ -z "$APP_STORE_CONNECT_API_KEY_PATH" ]; then
    echo "⚠️  APP_STORE_CONNECT_API_KEY_PATH not set"
    echo ""
    echo "To use CLI deployment, you need:"
    echo "1. Create API Key in App Store Connect → Users and Access → Keys"
    echo "2. Download the .p8 file"
    echo "3. Export environment variables:"
    echo ""
    echo "   export APP_STORE_CONNECT_API_KEY_PATH=/path/to/AuthKey_XXXXX.p8"
    echo "   export APP_STORE_CONNECT_API_KEY_ID=YOUR_KEY_ID"
    echo "   export APP_STORE_CONNECT_API_ISSUER_ID=YOUR_ISSUER_ID"
    echo ""
    echo "Or use the manual method below..."
    echo ""
fi

# Create directories
mkdir -p "$(dirname "$ARCHIVE_PATH")"
mkdir -p "$EXPORT_PATH"

cd "$PROJECT_PATH"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Clean Build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

xcodebuild clean \
    -project "${SCHEME}.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Create Archive"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

xcodebuild archive \
    -project "${SCHEME}.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "../../../${ARCHIVE_PATH}" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Automatic \
    CODE_SIGN_IDENTITY="Apple Distribution" \
    PROVISIONING_PROFILE_SPECIFIER=""

if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully"
else
    echo "❌ Archive failed"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Export IPA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create ExportOptions.plist
cat > "../../../${EXPORT_PATH}/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>destination</key>
    <string>upload</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "../../../${ARCHIVE_PATH}" \
    -exportPath "../../../${EXPORT_PATH}" \
    -exportOptionsPlist "../../../${EXPORT_PATH}/ExportOptions.plist" \
    -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    echo "✅ IPA exported successfully"
else
    echo "❌ Export failed"
    exit 1
fi

cd ../../..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Upload to App Store Connect"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$APP_STORE_CONNECT_API_KEY_PATH" ]; then
    echo "Using App Store Connect API..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_PATH" \
        --apiKey "$APP_STORE_CONNECT_API_KEY_ID" \
        --apiIssuer "$APP_STORE_CONNECT_API_ISSUER_ID"
    
    if [ $? -eq 0 ]; then
        echo "✅ Upload successful!"
    else
        echo "❌ Upload failed"
        exit 1
    fi
else
    echo "⚠️  No API credentials configured"
    echo ""
    echo "Manual upload options:"
    echo ""
    echo "Option 1: Using xcrun notarytool (requires authentication)"
    echo "  xcrun notarytool submit \"$IPA_PATH\" \\"
    echo "    --apple-id YOUR_APPLE_ID \\"
    echo "    --team-id $TEAM_ID \\"
    echo "    --password YOUR_APP_SPECIFIC_PASSWORD"
    echo ""
    echo "Option 2: Using Transporter app"
    echo "  1. Open Transporter.app"
    echo "  2. Drag and drop: $IPA_PATH"
    echo "  3. Sign in and deliver"
    echo ""
    echo "Option 3: Using altool (older method)"
    echo "  xcrun altool --upload-app \\"
    echo "    --type ios \\"
    echo "    --file \"$IPA_PATH\" \\"
    echo "    --username YOUR_APPLE_ID \\"
    echo "    --password YOUR_APP_SPECIFIC_PASSWORD"
    echo ""
    echo "IPA ready at: $IPA_PATH"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next: Check App Store Connect → TestFlight"
echo "Processing time: ~5-15 minutes"
echo ""

