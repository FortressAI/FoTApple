#!/bin/bash
# Archive apps for App Store without signing issues
# Uses Xcode's credentials for automatic signing

set -e

APP_NAME=$1
PROJECT_DIR=$2
SCHEME=$3

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app_name> <project_dir> <scheme>"
    exit 1
fi

TEAM_ID="WWQQB728U5"
BUILD_DIR="$(pwd)/build"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Archiving $APP_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$PROJECT_DIR"

# Clean first
echo "Cleaning..."
xcodebuild clean \
    -project "$SCHEME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    > /tmp/${APP_NAME}_clean.log 2>&1

# Archive with explicit App Store export intent
echo "Archiving for App Store..."
xcodebuild archive \
    -project "$SCHEME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$BUILD_DIR/${APP_NAME}.xcarchive" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    > /tmp/${APP_NAME}_archive.log 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Archive created: $BUILD_DIR/${APP_NAME}.xcarchive"
    
    # Create ExportOptions.plist for App Store
    cat > "$BUILD_DIR/ExportOptions_${APP_NAME}.plist" <<EOF
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
    <string>export</string>
</dict>
</plist>
EOF
    
    # Export IPA
    echo "Exporting IPA..."
    xcodebuild -exportArchive \
        -archivePath "$BUILD_DIR/${APP_NAME}.xcarchive" \
        -exportPath "$BUILD_DIR/IPAs" \
        -exportOptionsPlist "$BUILD_DIR/ExportOptions_${APP_NAME}.plist" \
        -allowProvisioningUpdates \
        > /tmp/${APP_NAME}_export.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ IPA exported: $BUILD_DIR/IPAs/${APP_NAME}.ipa"
        echo ""
        echo "Ready for Transporter!"
        exit 0
    else
        echo "❌ Export failed"
        tail -20 /tmp/${APP_NAME}_export.log
        exit 1
    fi
else
    echo "❌ Archive failed"
    echo ""
    echo "Last 30 lines of log:"
    tail -30 /tmp/${APP_NAME}_archive.log
    exit 1
fi

