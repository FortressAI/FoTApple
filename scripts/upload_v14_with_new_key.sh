#!/bin/bash
set -e

# ================================================================
# 🚀 UPLOAD v14 IPAs WITH NEW API KEY
# ================================================================
# Uses API Key: 4D2JDDUK2S
# Uploads already-built IPAs from build/ipas/
# ================================================================

PROJECT_ROOT="/Users/richardgillespie/Documents/FoTApple"
API_KEY_PATH="$PROJECT_ROOT/private_keys/AuthKey_4D2JDDUK2S.p8"
API_KEY_ID="4D2JDDUK2S"
API_ISSUER_ID="0be0b98b-ed15-45d9-a644-9a1a26b22d31"
VERSION="14"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$PROJECT_ROOT"

echo "================================================================"
echo "🚀 UPLOADING v14 IPAS WITH NEW API KEY"
echo "================================================================"
echo ""
echo "🔑 API Key: $API_KEY_ID"
echo "🔑 Issuer ID: $API_ISSUER_ID"
echo "📦 Version: $VERSION"
echo ""

# Verify API key exists
if [ ! -f "$API_KEY_PATH" ]; then
    echo -e "${RED}❌ ERROR: API key not found at $API_KEY_PATH${NC}"
    exit 1
fi

echo "✅ API key verified"
echo ""

# Function to upload an IPA
upload_ipa() {
    local APP_NAME=$1
    local IPA_DIR="build/ipas/${APP_NAME}_v${VERSION}"
    
    echo "================================================================"
    echo "📱 $APP_NAME"
    echo "================================================================"
    
    # Find the IPA file
    IPA_FILE=$(find "$IPA_DIR" -name "*.ipa" 2>/dev/null | head -1)
    
    if [ -z "$IPA_FILE" ]; then
        echo -e "${RED}❌ IPA not found in $IPA_DIR${NC}"
        echo "   Looking for IPAs..."
        find build/ipas -name "*.ipa" -type f 2>/dev/null | grep -i "$APP_NAME" || echo "   No IPAs found for $APP_NAME"
        return 1
    fi
    
    echo "📦 Found IPA: $(basename "$IPA_FILE")"
    echo "🚀 Uploading to App Store Connect..."
    echo ""
    
    if xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "build/logs/${APP_NAME}_upload_v14_NEW_KEY.log"; then
        
        echo ""
        echo -e "${GREEN}✅ $APP_NAME UPLOADED SUCCESSFULLY${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}❌ $APP_NAME UPLOAD FAILED${NC}"
        return 1
    fi
}

# Create logs directory
mkdir -p build/logs

# Upload all apps
SUCCESS=0
FAILED=0

upload_ipa "PersonalHealthApp" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
upload_ipa "FoTLegalApp" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
upload_ipa "FoTEducationApp" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
upload_ipa "FoTParentApp" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
upload_ipa "FoTClinicianApp" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))

echo ""
echo "================================================================"
echo "🎯 UPLOAD COMPLETE"
echo "================================================================"
echo ""
echo "✅ Successful: $SUCCESS/5"
echo "❌ Failed: $FAILED/5"
echo ""

if [ $SUCCESS -eq 5 ]; then
    echo -e "${GREEN}🎉 ALL v14 APPS UPLOADED SUCCESSFULLY!${NC}"
    echo ""
    echo "📱 All 5 apps now have version 14 with new icons"
    echo "🔗 Check App Store Connect: https://appstoreconnect.apple.com"
    exit 0
elif [ $SUCCESS -gt 0 ]; then
    echo -e "${BLUE}⚠️  PARTIAL SUCCESS - $SUCCESS/5 apps uploaded${NC}"
    exit 1
else
    echo -e "${RED}❌ ALL UPLOADS FAILED${NC}"
    echo ""
    echo "Check logs in build/logs/ for details"
    exit 1
fi

