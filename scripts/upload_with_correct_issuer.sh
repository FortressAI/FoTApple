#!/bin/bash
#
# Upload with correct Issuer ID
# Usage: ./upload_with_correct_issuer.sh YOUR_ISSUER_ID
#

if [ -z "$1" ]; then
  echo "❌ Please provide Issuer ID"
  echo ""
  echo "Usage: $0 YOUR_ISSUER_ID"
  echo ""
  echo "To get your Issuer ID:"
  echo "1. Go to: https://appstoreconnect.apple.com"
  echo "2. Click: Users and Access → Keys"
  echo "3. Look at TOP of page for 'Issuer ID'"
  echo "4. Copy it and run:"
  echo "   $0 YOUR_ISSUER_ID"
  exit 1
fi

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

API_ISSUER_ID="$1"
API_KEY_PH="2D6WT653U4"  # New key for PersonalHealth
API_KEY_LEGAL="6BTQ4MH7DD"  # New key for Legal

echo "🚀 UPLOADING WITH YOUR ISSUER ID"
echo ""
echo "Issuer ID: $API_ISSUER_ID"
echo "Keys: $API_KEY_PH, $API_KEY_LEGAL"
echo ""

# Upload PersonalHealth
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 PersonalHealth"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "build/ipas_for_upload/PersonalHealthApp.ipa" ]; then
  xcrun altool --upload-app \
    --type ios \
    --file "build/ipas_for_upload/PersonalHealthApp.ipa" \
    --apiKey "$API_KEY_PH" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | tee build/logs/PersonalHealth_upload_correct_issuer.log
  
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ PersonalHealth UPLOADED!"
  else
    echo "❌ PersonalHealth failed"
    echo "Check: build/logs/PersonalHealth_upload_correct_issuer.log"
  fi
else
  echo "⚠️  IPA not found"
fi

echo ""

# Upload Legal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Legal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "build/ipas_for_upload/FoTLegalApp.ipa" ]; then
  xcrun altool --upload-app \
    --type ios \
    --file "build/ipas_for_upload/FoTLegalApp.ipa" \
    --apiKey "$API_KEY_LEGAL" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | tee build/logs/Legal_upload_correct_issuer.log
  
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Legal UPLOADED!"
  else
    echo "❌ Legal failed"
    echo "Check: build/logs/Legal_upload_correct_issuer.log"
  fi
else
  echo "⚠️  IPA not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DONE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

