#!/bin/bash
#
# Upload existing IPAs directly without re-export
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# Working credentials
API_KEY="706IRVGBDV3B"
API_ISSUER="0be0b98b-ed15-45d9-a644-9a1a26b22d31"

echo "🚀 UPLOAD EXISTING IPAs"
echo ""
echo "Using YOUR personal API key ✅"
echo ""

# Upload PersonalHealth
if [ -f "build/ipas_for_upload/PersonalHealthApp.ipa" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔴 PersonalHealth (existing IPA)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "   📦 $(du -h build/ipas_for_upload/PersonalHealthApp.ipa | cut -f1)"
  echo "   Uploading to TestFlight..."
  
  xcrun altool --upload-app \
    --type ios \
    --file "build/ipas_for_upload/PersonalHealthApp.ipa" \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER" \
    2>&1 | tee build/logs/PersonalHealth_upload_EXISTING.log
  
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "   ✅ UPLOADED!"
  else
    echo "   ❌ Upload failed"
  fi
else
  echo "❌ PersonalHealthApp.ipa not found"
fi

echo ""

# Upload Legal
if [ -f "build/ipas_for_upload/FoTLegalApp.ipa" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🟦 Legal (existing IPA)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "   📦 $(du -h build/ipas_for_upload/FoTLegalApp.ipa | cut -f1)"
  echo "   Uploading to TestFlight..."
  
  xcrun altool --upload-app \
    --type ios \
    --file "build/ipas_for_upload/FoTLegalApp.ipa" \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER" \
    2>&1 | tee build/logs/Legal_upload_EXISTING.log
  
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "   ✅ UPLOADED!"
  else
    echo "   ❌ Upload failed"
  fi
else
  echo "❌ FoTLegalApp.ipa not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DONE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

