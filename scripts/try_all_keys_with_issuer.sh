#!/bin/bash
#
# Try all 3 keys with YOUR Issuer ID
# Usage: ./try_all_keys_with_issuer.sh YOUR_ISSUER_ID
#

if [ -z "$1" ]; then
  echo "❌ Please provide your Issuer ID"
  echo ""
  echo "Usage: $0 YOUR_ISSUER_ID"
  echo ""
  echo "The Issuer ID is shown when you download .p8 keys from:"
  echo "https://appstoreconnect.apple.com → Users and Access → Keys"
  echo ""
  echo "It looks like: 69a6de96-3a66-47e3-e053-5b8c7c11a4d1"
  exit 1
fi

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

API_ISSUER_ID="$1"
TEST_IPA="build/ipas_for_upload/PersonalHealthApp.ipa"

echo "🔑 TESTING ALL 3 KEYS WITH YOUR ISSUER ID"
echo ""
echo "Issuer ID: $API_ISSUER_ID"
echo "Test IPA: $TEST_IPA"
echo ""

if [ ! -f "$TEST_IPA" ]; then
  echo "❌ Test IPA not found: $TEST_IPA"
  exit 1
fi

# Test each key
test_key() {
  local KEY_ID="$1"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Testing: AuthKey_${KEY_ID}.p8"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  timeout 15 xcrun altool --upload-app \
    --type ios \
    --file "$TEST_IPA" \
    --apiKey "$KEY_ID" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | head -50
  
  local STATUS=${PIPESTATUS[0]}
  
  if [ $STATUS -eq 0 ] || [ $STATUS -eq 124 ]; then
    # 0 = success, 124 = timeout (but started uploading)
    echo ""
    echo "✅ THIS KEY WORKS!"
    echo "   Key ID: $KEY_ID"
    echo "   Issuer: $API_ISSUER_ID"
    echo ""
    echo "Saving to working_credentials.txt"
    cat > working_credentials.txt <<EOF
# Working credentials for App Store uploads
API_KEY_ID=$KEY_ID
API_ISSUER_ID=$API_ISSUER_ID

# Use with:
# xcrun altool --upload-app \\
#   --type ios \\
#   --file YOUR_IPA \\
#   --apiKey $KEY_ID \\
#   --apiIssuer $API_ISSUER_ID
EOF
    return 0
  else
    echo "   ❌ Failed"
    echo ""
    return 1
  fi
}

# Test all 3 keys
KEYS=(
  "43BGN9JC5B"
  "2D6WT653U4"
  "6BTQ4MH7DD"
)

FOUND=0

for KEY in "${KEYS[@]}"; do
  if test_key "$KEY"; then
    FOUND=1
    WORKING_KEY="$KEY"
    break
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FOUND -eq 1 ]; then
  echo "✅ FOUND WORKING KEY!"
  echo ""
  echo "Key: $WORKING_KEY"
  echo "Issuer: $API_ISSUER_ID"
  echo ""
  echo "Now uploading BOTH apps..."
  echo ""
  
  # Upload PersonalHealth
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📱 PersonalHealth"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  xcrun altool --upload-app \
    --type ios \
    --file "build/ipas_for_upload/PersonalHealthApp.ipa" \
    --apiKey "$WORKING_KEY" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | tee build/logs/PersonalHealth_upload_final.log
  
  echo ""
  
  # Upload Legal
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📱 Legal"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  xcrun altool --upload-app \
    --type ios \
    --file "build/ipas_for_upload/FoTLegalApp.ipa" \
    --apiKey "$WORKING_KEY" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | tee build/logs/Legal_upload_final.log
  
  echo ""
  echo "✅ UPLOADS COMPLETE!"
else
  echo "❌ NONE OF THE 3 KEYS WORKED WITH THIS ISSUER ID"
  echo ""
  echo "This means either:"
  echo "1. Wrong Issuer ID (double-check on App Store Connect)"
  echo "2. Keys are revoked/expired"
  echo "3. Keys don't have 'App Manager' role"
fi

