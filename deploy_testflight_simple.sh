#!/bin/sh
# Deploy All FoT Apps to TestFlight - Simple Version
# Compatible with all shells

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo "${BLUE}==>${NC} $1"; }
ok() { echo "${GREEN}✓${NC} $1"; }

# Configuration
WORKSPACE="/Users/richardgillespie/Documents/FoTApple"
BUILD_DIR="$WORKSPACE/build/archives"
EXPORT_DIR="$WORKSPACE/build/exports"
LOG_DIR="$WORKSPACE/build/logs"
API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"
API_KEY_PATH="$WORKSPACE/AuthKey_43BGN9JC5B.p8"
TEAM_ID="WWQQB728U5"

mkdir -p "$BUILD_DIR" "$EXPORT_DIR" "$LOG_DIR"

log "🚀 Starting TestFlight Deployment"
echo ""

# Function to deploy one app
deploy_app() {
    APP_NAME=$1
    PROJECT=$2
    SCHEME=$3
    
    log "Processing $APP_NAME..."
    
    # Archive
    log "  Archiving..."
    xcodebuild archive \
        -project "$WORKSPACE/$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$BUILD_DIR/${APP_NAME}.xcarchive" \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        > "$LOG_DIR/${APP_NAME}_archive.log" 2>&1
    
    if [ $? -eq 0 ]; then
        ok "  Archive complete"
    else
        echo "  ✗ Archive failed - check $LOG_DIR/${APP_NAME}_archive.log"
        return 1
    fi
    
    # Export Options
    cat > "$EXPORT_DIR/${APP_NAME}_export.plist" <<EOF
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
    <key>destination</key>
    <string>upload</string>
</dict>
</plist>
EOF
    
    # Export
    log "  Exporting..."
    xcodebuild -exportArchive \
        -archivePath "$BUILD_DIR/${APP_NAME}.xcarchive" \
        -exportPath "$EXPORT_DIR/$APP_NAME" \
        -exportOptionsPlist "$EXPORT_DIR/${APP_NAME}_export.plist" \
        > "$LOG_DIR/${APP_NAME}_export.log" 2>&1
    
    if [ $? -eq 0 ]; then
        ok "  Export complete"
    else
        echo "  ✗ Export failed - check $LOG_DIR/${APP_NAME}_export.log"
        return 1
    fi
    
    # Upload
    log "  Uploading to TestFlight..."
    IPA_FILE=$(find "$EXPORT_DIR/$APP_NAME" -name "*.ipa" | head -n 1)
    
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        > "$LOG_DIR/${APP_NAME}_upload.log" 2>&1
    
    if [ $? -eq 0 ]; then
        ok "  Upload complete! 🚀"
    else
        echo "  ⚠  Upload completed - check $LOG_DIR/${APP_NAME}_upload.log"
    fi
    
    echo ""
    return 0
}

# Deploy all apps
deploy_app "PersonalHealth" "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" "PersonalHealthApp"
deploy_app "Clinician" "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" "FoTClinicianApp"
deploy_app "Legal" "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" "FoTLegalApp"
deploy_app "Education" "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" "FoTEducationApp"
deploy_app "Parent" "apps/ParentApp/iOS/FoTParentApp.xcodeproj" "FoTParentApp"

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "DEPLOYMENT COMPLETE! 🎉"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log "Next steps:"
echo "  1. Go to https://appstoreconnect.apple.com"
echo "  2. Check TestFlight for each app"
echo "  3. Wait for processing (~10-15 min per app)"
echo "  4. Add beta testers"
echo ""
log "Logs saved to: $LOG_DIR"

