#!/bin/sh
# Deploy ALL FoT Apps to TestFlight - ALL PLATFORMS
# iOS, macOS, watchOS

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo "${BLUE}==>${NC} $1"; }
ok() { echo "${GREEN}✓${NC} $1"; }
warn() { echo "${YELLOW}⚠${NC} $1"; }

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

log "🚀 Starting Multi-Platform TestFlight Deployment"
log "Platforms: iOS, macOS, watchOS"
echo ""

# Function to deploy one app
deploy_app() {
    APP_NAME=$1
    PROJECT=$2
    SCHEME=$3
    PLATFORM=$4
    DESTINATION=$5
    
    log "[$PLATFORM] $APP_NAME ($SCHEME)..."
    
    # Archive
    log "  Archiving..."
    xcodebuild archive \
        -project "$WORKSPACE/$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$BUILD_DIR/${APP_NAME}_${PLATFORM}.xcarchive" \
        -destination "$DESTINATION" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        > "$LOG_DIR/${APP_NAME}_${PLATFORM}_archive.log" 2>&1
    
    if [ $? -eq 0 ]; then
        ok "  Archive complete"
    else
        warn "  Archive failed - check $LOG_DIR/${APP_NAME}_${PLATFORM}_archive.log"
        return 1
    fi
    
    # Export Options
    cat > "$EXPORT_DIR/${APP_NAME}_${PLATFORM}_export.plist" <<EOF
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
        -archivePath "$BUILD_DIR/${APP_NAME}_${PLATFORM}.xcarchive" \
        -exportPath "$EXPORT_DIR/${APP_NAME}_${PLATFORM}" \
        -exportOptionsPlist "$EXPORT_DIR/${APP_NAME}_${PLATFORM}_export.plist" \
        > "$LOG_DIR/${APP_NAME}_${PLATFORM}_export.log" 2>&1
    
    if [ $? -eq 0 ]; then
        ok "  Export complete"
    else
        warn "  Export failed - check $LOG_DIR/${APP_NAME}_${PLATFORM}_export.log"
        return 1
    fi
    
    # Upload
    log "  Uploading to TestFlight..."
    
    # Find appropriate file (.ipa for iOS/watchOS, .pkg for macOS)
    if [ "$PLATFORM" = "macOS" ]; then
        APP_FILE=$(find "$EXPORT_DIR/${APP_NAME}_${PLATFORM}" -name "*.pkg" | head -n 1)
        FILE_TYPE="osx"
    else
        APP_FILE=$(find "$EXPORT_DIR/${APP_NAME}_${PLATFORM}" -name "*.ipa" | head -n 1)
        FILE_TYPE="ios"
    fi
    
    if [ -z "$APP_FILE" ]; then
        warn "  No package found in $EXPORT_DIR/${APP_NAME}_${PLATFORM}"
        return 1
    fi
    
    xcrun altool --upload-app \
        --type $FILE_TYPE \
        --file "$APP_FILE" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        > "$LOG_DIR/${APP_NAME}_${PLATFORM}_upload.log" 2>&1
    
    if [ $? -eq 0 ]; then
        ok "  Upload complete! 🚀"
    else
        warn "  Upload completed - check $LOG_DIR/${APP_NAME}_${PLATFORM}_upload.log"
    fi
    
    echo ""
    return 0
}

# =============================================================================
# PERSONAL HEALTH - iOS + macOS
# =============================================================================

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "PERSONAL HEALTH (2 platforms)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

deploy_app "PersonalHealth" \
    "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" \
    "PersonalHealthApp" \
    "iOS" \
    "generic/platform=iOS"

deploy_app "PersonalHealthMac" \
    "apps/PersonalHealthApp/macOS/PersonalHealthMac.xcodeproj" \
    "PersonalHealthMac" \
    "macOS" \
    "generic/platform=macOS"

# =============================================================================
# CLINICIAN - iOS + macOS + watchOS
# =============================================================================

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "CLINICIAN (3 platforms)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

deploy_app "Clinician" \
    "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" \
    "FoTClinicianApp" \
    "iOS" \
    "generic/platform=iOS"

deploy_app "ClinicianMac" \
    "apps/ClinicianApp/macOS/FoTClinicianMac.xcodeproj" \
    "FoTClinicianMac" \
    "macOS" \
    "generic/platform=macOS"

deploy_app "ClinicianWatch" \
    "apps/ClinicianApp/watchOS/FoTClinicianWatch.xcodeproj" \
    "FoTClinicianWatch" \
    "watchOS" \
    "generic/platform=watchOS"

# =============================================================================
# LEGAL - iOS + macOS
# =============================================================================

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "LEGAL (2 platforms)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

deploy_app "Legal" \
    "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" \
    "FoTLegalApp" \
    "iOS" \
    "generic/platform=iOS"

deploy_app "LegalMac" \
    "apps/LegalApp/macOS/FoTLegalMac.xcodeproj" \
    "FoTLegalMac" \
    "macOS" \
    "generic/platform=macOS"

# =============================================================================
# EDUCATION - iOS only
# =============================================================================

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "EDUCATION (1 platform)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

deploy_app "Education" \
    "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" \
    "FoTEducationApp" \
    "iOS" \
    "generic/platform=iOS"

# =============================================================================
# PARENT - iOS only
# =============================================================================

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "PARENT (1 platform)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

deploy_app "Parent" \
    "apps/ParentApp/iOS/FoTParentApp.xcodeproj" \
    "FoTParentApp" \
    "iOS" \
    "generic/platform=iOS"

# =============================================================================
# SUMMARY
# =============================================================================

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "MULTI-PLATFORM DEPLOYMENT COMPLETE! 🎉"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

log "Total Platforms Deployed:"
echo "  • Personal Health: iOS + macOS = 2"
echo "  • Clinician: iOS + macOS + watchOS = 3"
echo "  • Legal: iOS + macOS = 2"
echo "  • Education: iOS = 1"
echo "  • Parent: iOS = 1"
echo "  ────────────────────────────────"
echo "  TOTAL: 9 platform builds"
echo ""

ok "All apps deployed to TestFlight across ALL platforms!"
echo ""

log "Next steps:"
echo "  1. Go to https://appstoreconnect.apple.com"
echo "  2. Check TestFlight for each app"
echo "  3. Each platform appears as separate build"
echo "  4. Wait for processing (~10-15 min per platform)"
echo "  5. Add beta testers to each platform"
echo ""

log "Logs saved to: $LOG_DIR"
log "Archives saved to: $BUILD_DIR"
log "Exports saved to: $EXPORT_DIR"

