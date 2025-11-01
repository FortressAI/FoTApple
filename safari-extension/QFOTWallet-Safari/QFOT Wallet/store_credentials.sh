#!/bin/bash
set -e

echo "════════════════════════════════════════════════════════════"
echo "🔐 Store Apple Credentials for Notarization"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Apple ID: richard_gillespie@yahoo.com"
echo "Team ID: WWQQB728U5"
echo ""
echo "────────────────────────────────────────────────────────────"
echo "⚠️  IMPORTANT: Use APP-SPECIFIC PASSWORD"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "NOT your regular Yahoo password!"
echo "You need to generate one at: https://appleid.apple.com"
echo ""
echo "If you haven't generated it yet:"
echo "  1. Go to: https://appleid.apple.com"
echo "  2. Sign in with your REGULAR password"
echo "  3. Click 'Security'"
echo "  4. Find 'App-Specific Passwords'"
echo "  5. Click 'Generate an app-specific password'"
echo "  6. Name it: 'QFOT Notarization'"
echo "  7. Copy the password (looks like: xxxx-xxxx-xxxx-xxxx)"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Press ENTER when you have your App-Specific Password ready..."
read

echo ""
echo "Storing credentials in Keychain..."
echo ""
echo "When prompted:"
echo "  • Apple ID: richard_gillespie@yahoo.com"
echo "  • Team ID: WWQQB728U5 (already filled)"
echo "  • Password: PASTE YOUR APP-SPECIFIC PASSWORD"
echo ""

xcrun notarytool store-credentials "qfot-notarization" \
  --apple-id "richard_gillespie@yahoo.com" \
  --team-id "WWQQB728U5"

if [ $? -eq 0 ]; then
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "✅ SUCCESS!"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Credentials stored in Keychain as: qfot-notarization"
    echo ""
    echo "Now you can notarize:"
    echo "  ./notarize_with_stored_credentials.sh"
    echo ""
else
    echo ""
    echo "❌ FAILED"
    echo ""
    echo "Common issues:"
    echo "  • Used regular password instead of App-Specific Password"
    echo "  • Typo in App-Specific Password"
    echo "  • App-Specific Password not generated yet"
    echo ""
    echo "Try again after generating App-Specific Password"
fi

