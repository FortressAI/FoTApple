#!/bin/bash
#
# Upload with CORRECT API Issuer ID from deploy_all_platforms_testflight.sh
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# CORRECT API credentials - found in deploy_all_platforms_testflight.sh
API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"  # THE CORRECT ONE!

echo "🚀 UPLOADING WITH CORRECT API ISSUER ID"
echo ""
echo "API Key: $API_KEY_ID"
echo "Issuer: $API_ISSUER_ID (CORRECT from deploy script)"
echo ""

# Upload PersonalHealth
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 PersonalHealth (RED icon)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Uploading..."

xcrun altool --upload-app \
    --type ios \
    --file "build/ipas_for_upload/PersonalHealthApp.ipa" \
    --apiKey "$API_KEY_ID" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | tee build/logs/PersonalHealth_upload_CORRECT.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "   ✅ PERSONALHEALTH UPLOADED TO TESTFLIGHT!"
    echo ""
else
    echo ""
    echo "   ❌ PersonalHealth upload failed"
    tail -20 build/logs/PersonalHealth_upload_CORRECT.log
    echo ""
fi

# Upload Legal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Legal (NAVY/GOLD icon)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Uploading..."

xcrun altool --upload-app \
    --type ios \
    --file "build/exports_simple/Legal/FoTLegalApp.ipa" \
    --apiKey "$API_KEY_ID" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | tee build/logs/Legal_upload_CORRECT.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "   ✅ LEGAL UPLOADED TO TESTFLIGHT!"
    echo ""
else
    echo ""
    echo "   ❌ Legal upload failed"
    tail -20 build/logs/Legal_upload_CORRECT.log
    echo ""
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ UPLOAD COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Wait 15 minutes for Apple processing"
echo "2. Check App Store Connect → TestFlight"
echo "3. Submit response to Apple Review"
echo ""
echo "🎉 ON THE WAY TO APPROVAL!"

