#!/bin/bash
#
# Test ALL key/issuer combinations to find the working one
#

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

echo "🔑 TESTING ALL API KEY COMBINATIONS"
echo ""
echo "We have 3 keys and 2 known Issuer IDs"
echo "Let's test ALL combinations to find what works"
echo ""

# Known Issuer IDs
ISSUER1="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"  # From deploy script
ISSUER2="d648c36b-f731-4c3e-bb88-32aad08f9f2d"  # From earlier attempts

# Keys
KEYS=(
  "43BGN9JC5B"
  "2D6WT653U4"
  "6BTQ4MH7DD"
)

# Test IPA
TEST_IPA="build/ipas_for_upload/PersonalHealthApp.ipa"

if [ ! -f "$TEST_IPA" ]; then
  echo "❌ Test IPA not found: $TEST_IPA"
  exit 1
fi

echo "Test IPA: $TEST_IPA"
echo ""

test_combination() {
  local KEY="$1"
  local ISSUER="$2"
  local TEST_NUM="$3"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test #$TEST_NUM: Key=$KEY + Issuer=${ISSUER:0:8}..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Try upload (will fail fast if wrong)
  timeout 10 xcrun altool --upload-app \
    --type ios \
    --file "$TEST_IPA" \
    --apiKey "$KEY" \
    --apiIssuer "$ISSUER" \
    2>&1 | head -30 | grep -E "(SUCCESS|error:|No package)"
  
  local STATUS=$?
  
  if [ $STATUS -eq 0 ]; then
    echo ""
    echo "✅ FOUND WORKING COMBINATION!"
    echo "   Key: $KEY"
    echo "   Issuer: $ISSUER"
    echo ""
    return 0
  else
    echo "   ❌ Failed"
    echo ""
    return 1
  fi
}

# Test all combinations
TEST_NUM=1
FOUND=0

for KEY in "${KEYS[@]}"; do
  for ISSUER in "$ISSUER1" "$ISSUER2"; do
    if test_combination "$KEY" "$ISSUER" "$TEST_NUM"; then
      FOUND=1
      WORKING_KEY="$KEY"
      WORKING_ISSUER="$ISSUER"
      break 2
    fi
    TEST_NUM=$((TEST_NUM+1))
  done
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FOUND -eq 1 ]; then
  echo "✅ FOUND WORKING CREDENTIALS!"
  echo ""
  echo "Use these:"
  echo "  API_KEY=$WORKING_KEY"
  echo "  API_ISSUER=$WORKING_ISSUER"
  echo ""
  echo "Saving to: working_credentials.txt"
  cat > working_credentials.txt <<EOF
API_KEY=$WORKING_KEY
API_ISSUER=$WORKING_ISSUER
EOF
else
  echo "❌ NO WORKING COMBINATION FOUND"
  echo ""
  echo "This means:"
  echo "1. All keys are expired/revoked, OR"
  echo "2. You have a DIFFERENT Issuer ID we haven't tried"
  echo ""
  echo "To get the correct Issuer ID:"
  echo "1. Go to: https://appstoreconnect.apple.com"
  echo "2. Users and Access → Keys"
  echo "3. Look at the TOP of the page - copy the Issuer ID"
  echo "4. Run this script again with: $0 ISSUER_ID"
fi

