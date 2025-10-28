#!/bin/bash
# Upload Personal Health App to TestFlight

set -e

# Configuration  
APP_NAME="PersonalHealthApp"
SCHEME="PersonalHealthApp"
PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple/apps/PersonalHealthApp/iOS"
AUTH_KEY="$HOME/Documents/FoTApple/.apple-keys/AuthKey_43BGN9JC5B.p8"
KEY_ID="43BGN9JC5B"
ISSUER_ID=""  # TO BE FILLED: Get from App Store Connect → Users and Access → Keys

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}▶${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

log_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Check for Issuer ID
if [ -z "$ISSUER_ID" ]; then
    error "ISSUER_ID not set. Get it from App Store Connect → Users and Access → Keys"
fi

# Check Auth Key exists
if [ ! -f "$AUTH_KEY" ]; then
    error "Auth Key not found at $AUTH_KEY"
fi

log_header "Building Personal Health App for TestFlight"

cd "$PROJECT_DIR"

# Step 1: Generate Xcode project
log "Generating Xcode project..."
xcodegen generate

# Step 2: Clean
log "Cleaning previous builds..."
rm -rf build
rm -rf *.xcarchive

# Step 3: Build Archive
log "Building archive for App Store..."
xcodebuild archive \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -archivePath "./$APP_NAME.xcarchive" \
    -configuration Release \
    DEVELOPMENT_TEAM="WWQQB728U5" \
    CODE_SIGN_STYLE="Automatic" \
    | xcpretty || xcodebuild archive \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -archivePath "./$APP_NAME.xcarchive" \
    -configuration Release \
    DEVELOPMENT_TEAM="WWQQB728U5" \
    CODE_SIGN_STYLE="Automatic"

log "✅ Archive created: $APP_NAME.xcarchive"

# Step 4: Export IPA
log "Exporting IPA for App Store..."
xcodebuild -exportArchive \
    -archivePath "./$APP_NAME.xcarchive" \
    -exportPath "./build" \
    -exportOptionsPlist "./ExportOptions.plist"

log "✅ IPA exported: build/$APP_NAME.ipa"

# Step 5: Upload to App Store Connect
log_header "Uploading to TestFlight"

log "Using Auth Key: $AUTH_KEY"
log "Key ID: $KEY_ID"
log "Issuer ID: $ISSUER_ID"

xcrun notarytool submit "./build/$APP_NAME.ipa" \
    --key "$AUTH_KEY" \
    --key-id "$KEY_ID" \
    --issuer "$ISSUER_ID" \
    --wait

log_header "Upload Complete!"

echo ""
echo "✅ Personal Health App uploaded to TestFlight!"
echo ""
echo "📱 Next steps:"
echo "   1. Go to App Store Connect → Your App → TestFlight"
echo "   2. Wait for processing (5-30 minutes)"
echo "   3. Add beta app description"
echo "   4. Submit for TestFlight review (if external testing)"
echo "   5. Invite testers via email or public link"
echo ""
echo "🎯 You can invite:"
echo "   • Up to 100 internal testers (team members)"
echo "   • Up to 10,000 external testers (anyone)"
echo ""
echo "📧 Testers will receive email with TestFlight link"
echo "📲 They install TestFlight app and join your beta"
echo ""

