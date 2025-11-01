#!/bin/bash
set -e

echo "════════════════════════════════════════════════════════════"
echo "🔐 QFOT Wallet - Notarization Setup (One-Time)"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "This will securely store your Apple credentials in Keychain."
echo "You'll only need to do this ONCE."
echo ""
echo "─────────────────────────────────────────────────────────────"
echo "📝 What you need:"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "1. Your Apple ID (email)"
echo "2. App-Specific Password (NOT your regular password)"
echo ""
echo "   Create an App-Specific Password:"
echo "   → https://appleid.apple.com"
echo "   → Security"
echo "   → App-Specific Passwords"
echo "   → Generate Password"
echo ""
echo "─────────────────────────────────────────────────────────────"
echo ""

# Team ID is already known
TEAM_ID="WWQQB728U5"

echo "Team ID: $TEAM_ID ✅"
echo ""

# Get Apple ID
echo "Enter your Apple ID (email):"
read APPLE_ID
echo ""

# Store credentials in keychain
echo "🔐 Storing credentials in Keychain..."
echo ""
echo "You'll be prompted for your App-Specific Password."
echo "This will be stored securely and you won't need to enter it again."
echo ""

xcrun notarytool store-credentials "qfot-notarization" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID"

if [ $? -eq 0 ]; then
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "✅ SUCCESS - Credentials stored in Keychain!"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Profile name: qfot-notarization"
    echo ""
    echo "🚀 You can now notarize with one command:"
    echo "   ./notarize_with_stored_credentials.sh"
    echo ""
else
    echo ""
    echo "❌ Failed to store credentials"
    echo ""
    echo "Make sure you're using an App-Specific Password, not your regular Apple ID password."
    exit 1
fi

