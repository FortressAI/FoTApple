#!/bin/bash
#
# REAL CLI UPLOAD - Use new API keys to upload existing IPAs
# NO XCODE GUI REQUIRED
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# NEW API Keys (working ones you just downloaded)
API_KEY_PH="2D6WT653U4"
API_KEY_LEGAL="6BTQ4MH7DD"
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"

echo "🚀 UPLOADING WITH NEW API KEYS - PURE CLI"
echo ""
echo "API Keys:"
echo "  PersonalHealth: $API_KEY_PH"
echo "  Legal: $API_KEY_LEGAL"
echo "  Issuer: $API_ISSUER_ID"
echo ""

# Function to upload IPA
upload_ipa() {
    local APP_NAME="$1"
    local IPA_PATH="$2"
    local API_KEY="$3"
    
    if [ ! -f "$IPA_PATH" ]; then
        echo "⚠️  $APP_NAME: IPA not found at $IPA_PATH"
        return 1
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   IPA: $IPA_PATH"
    echo "   Size: $(du -h "$IPA_PATH" | cut -f1)"
    echo ""
    echo "   Uploading..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_PATH" \
        --apiKey "$API_KEY" \
        --apiIssuer "$API_ISSUER_ID" \
        --verbose \
        2>&1 | tee "build/logs/${APP_NAME}_upload_new_keys.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo ""
        echo "   ✅ UPLOADED!"
        echo ""
        return 0
    else
        echo ""
        echo "   ❌ Upload failed"
        echo ""
        return 1
    fi
}

# Upload existing IPAs
SUCCESS=0
TOTAL=0

# Try PersonalHealth
if [ -f "build/ipas_for_upload/PersonalHealthApp.ipa" ]; then
    TOTAL=$((TOTAL+1))
    upload_ipa "PersonalHealth" "build/ipas_for_upload/PersonalHealthApp.ipa" "$API_KEY_PH" && SUCCESS=$((SUCCESS+1))
fi

# Try Legal
if [ -f "build/ipas_for_upload/FoTLegalApp.ipa" ]; then
    TOTAL=$((TOTAL+1))
    upload_ipa "Legal" "build/ipas_for_upload/FoTLegalApp.ipa" "$API_KEY_LEGAL" && SUCCESS=$((SUCCESS+1))
elif [ -f "build/exports_simple/Legal/FoTLegalApp.ipa" ]; then
    TOTAL=$((TOTAL+1))
    upload_ipa "Legal" "build/exports_simple/Legal/FoTLegalApp.ipa" "$API_KEY_LEGAL" && SUCCESS=$((SUCCESS+1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESULTS: $SUCCESS/$TOTAL uploaded"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $SUCCESS -gt 0 ]; then
    echo ""
    echo "✅ At least some apps uploaded!"
    echo ""
    echo "Next: Build remaining apps using fastlane or citool"
else
    echo ""
    echo "❌ Uploads failed - API keys may still be invalid"
    echo "   Check error logs above"
fi

