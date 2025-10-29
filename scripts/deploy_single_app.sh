#!/bin/bash
################################################################################
# SINGLE APP TESTFLIGHT DEPLOYMENT
# Deploy one app at a time to TestFlight
################################################################################

set -e

################################################################################
# CONFIGURATION
################################################################################

TEAM_ID="WWQQB728U5"
API_KEY_ID="${APP_STORE_API_KEY_ID:-YOUR_KEY_ID}"
API_ISSUER_ID="${APP_STORE_API_ISSUER_ID:-YOUR_ISSUER_ID}"

################################################################################
# APP SELECTION
################################################################################

if [ $# -eq 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Deploy Single App to TestFlight"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Usage: $0 <app_number>"
    echo ""
    echo "Available apps:"
    echo "  1) PersonalHealthApp"
    echo "  2) ClinicianApp"
    echo "  3) ParentApp"
    echo "  4) EducationApp"
    echo "  5) LegalApp"
    echo ""
    echo "Example: $0 1    # Deploys PersonalHealthApp"
    echo ""
    exit 1
fi

APP_NUMBER=$1

case $APP_NUMBER in
    1)
        DIR="PersonalHealthApp"
        SCHEME="PersonalHealthApp"
        BUNDLE_ID="com.fot.PersonalHealth"
        ;;
    2)
        DIR="ClinicianApp"
        SCHEME="FoTClinicianApp"
        BUNDLE_ID="com.fot.ClinicianApp"
        ;;
    3)
        DIR="ParentApp"
        SCHEME="FoTParentApp"
        BUNDLE_ID="com.fot.ParentApp"
        ;;
    4)
        DIR="EducationApp"
        SCHEME="FoTEducationApp"
        BUNDLE_ID="com.fot.EducationApp"
        ;;
    5)
        DIR="LegalApp"
        SCHEME="FoTLegalApp"
        BUNDLE_ID="com.fot.LegalApp"
        ;;
    *)
        echo "❌ Invalid app number: $APP_NUMBER"
        echo "Please choose 1-5"
        exit 1
        ;;
esac

################################################################################
# VALIDATION
################################################################################

if [[ "$API_KEY_ID" == "YOUR_KEY_ID" ]] || [[ "$API_ISSUER_ID" == "YOUR_ISSUER_ID" ]]; then
    echo "❌ ERROR: API credentials not configured!"
    echo ""
    echo "Set environment variables:"
    echo "  export APP_STORE_API_KEY_ID='your_key_id'"
    echo "  export APP_STORE_API_ISSUER_ID='your_issuer_id'"
    exit 1
fi

P8_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8"
if [ ! -f "$P8_KEY_PATH" ]; then
    echo "❌ ERROR: API key file not found at: $P8_KEY_PATH"
    exit 1
fi

################################################################################
# SETUP
################################################################################

BUILD_DIR="build"
LOG_DIR="$BUILD_DIR/logs"
EXPORT_DIR="$BUILD_DIR/export"
ARCHIVE_DIR="$BUILD_DIR/archives"

mkdir -p "$LOG_DIR" "$EXPORT_DIR" "$ARCHIVE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Deploying: $SCHEME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Bundle ID: $BUNDLE_ID"
echo "Directory: apps/$DIR/iOS"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

START_TIME=$(date +%s)

################################################################################
# DEPLOYMENT
################################################################################

cd "apps/$DIR/iOS"

# Auto-increment build
echo "▶ Incrementing build number..."
INFO_PLIST="$SCHEME/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST" 2>/dev/null || echo "1")
    NEW_BUILD=$((CURRENT_BUILD + 1))
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$INFO_PLIST"
    echo "  Build: $CURRENT_BUILD → $NEW_BUILD"
else
    echo "  ⚠️  Info.plist not found"
fi

# Clean
echo ""
echo "▶ Cleaning..."
xcodebuild clean \
    -project "$SCHEME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    > /dev/null 2>&1 || true

# Archive
echo ""
echo "▶ Creating archive..."
ARCHIVE_PATH="../../../$ARCHIVE_DIR/$SCHEME.xcarchive"

if xcodebuild archive \
    -project "$SCHEME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    > "../../../$LOG_DIR/${SCHEME}_archive.log" 2>&1; then
    
    echo "  ✅ Archive created"
    
    # Create ExportOptions
    echo ""
    echo "▶ Configuring export..."
    
    EXPORT_OPTIONS="../../../$BUILD_DIR/ExportOptions_${SCHEME}.plist"
    
    cat > "$EXPORT_OPTIONS" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>destination</key>
    <string>upload</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>authentication</key>
    <dict>
        <key>apiIssuer</key>
        <string>$API_ISSUER_ID</string>
        <key>apiKey</key>
        <string>$API_KEY_ID</string>
    </dict>
</dict>
</plist>
EOF
    
    # Export and Upload
    echo ""
    echo "▶ Uploading to TestFlight..."
    echo "  (This may take several minutes...)"
    
    if xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "../../../$EXPORT_DIR/$SCHEME" \
        -exportOptionsPlist "$EXPORT_OPTIONS" \
        -allowProvisioningUpdates \
        > "../../../$LOG_DIR/${SCHEME}_export.log" 2>&1; then
        
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        MINUTES=$((DURATION / 60))
        SECONDS=$((DURATION % 60))
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ SUCCESS!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "App: $SCHEME"
        echo "Time: ${MINUTES}m ${SECONDS}s"
        echo "Completed: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "Next steps:"
        echo "  1. Build will process in 5-15 minutes"
        echo "  2. Check: https://appstoreconnect.apple.com/apps"
        echo "  3. Add to test groups in TestFlight tab"
        echo ""
        exit 0
    else
        echo ""
        echo "❌ Upload failed"
        echo "Check log: $LOG_DIR/${SCHEME}_export.log"
        exit 1
    fi
else
    echo ""
    echo "❌ Archive failed"
    echo "Check log: $LOG_DIR/${SCHEME}_archive.log"
    exit 1
fi
