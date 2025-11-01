#!/bin/bash
set -e

echo "════════════════════════════════════════════════════════════"
echo "🚀 QFOT Wallet - Notarization & Packaging"
echo "════════════════════════════════════════════════════════════"
echo ""

# Configuration
APP_PATH="build/export/QFOT Wallet.app"
ZIP_PATH="build/export/QFOT_Wallet.zip"
DMG_PATH="QFOT_Wallet_v1.0.dmg"
TEAM_ID="WWQQB728U5"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at: $APP_PATH"
    echo ""
    echo "Run the build first:"
    echo "  cd \"/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet\""
    echo "  ./build_for_distribution.sh"
    exit 1
fi

echo "📦 Found app: $APP_PATH"
echo ""

# Get Apple ID
if [ -z "$APPLE_ID" ]; then
    echo "Enter your Apple ID (email):"
    read APPLE_ID
    echo ""
fi

# Get App-Specific Password
if [ -z "$APP_PASSWORD" ]; then
    echo "Enter your App-Specific Password:"
    echo "(Create one at: https://appleid.apple.com → Security → App-Specific Passwords)"
    read -s APP_PASSWORD
    echo ""
    echo ""
fi

# Step 1: Create ZIP for notarization
echo "1️⃣ Creating ZIP for notarization..."
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
echo "   ✅ Created: $ZIP_PATH"
echo ""

# Step 2: Submit for notarization
echo "2️⃣ Submitting to Apple for notarization..."
echo "   (This may take 5-10 minutes...)"
echo ""

xcrun notarytool submit "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --password "$APP_PASSWORD" \
  --team-id "$TEAM_ID" \
  --wait

if [ $? -eq 0 ]; then
    echo ""
    echo "   ✅ Notarization succeeded!"
    echo ""
else
    echo ""
    echo "   ❌ Notarization failed!"
    echo ""
    echo "Check logs with:"
    echo "   xcrun notarytool log <submission-id> --apple-id $APPLE_ID --password <password> --team-id $TEAM_ID"
    exit 1
fi

# Step 3: Staple the notarization ticket
echo "3️⃣ Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"
echo "   ✅ Stapled!"
echo ""

# Step 4: Verify notarization
echo "4️⃣ Verifying notarization..."
spctl -a -vv "$APP_PATH"
echo ""

# Step 5: Create DMG
echo "5️⃣ Creating distribution DMG..."
rm -f "$DMG_PATH"
hdiutil create -volname "QFOT Wallet" \
  -srcfolder "$APP_PATH" \
  -ov -format UDZO \
  "$DMG_PATH"
echo "   ✅ Created: $DMG_PATH"
echo ""

# Step 6: Notarize DMG
echo "6️⃣ Notarizing DMG..."
xcrun notarytool submit "$DMG_PATH" \
  --apple-id "$APPLE_ID" \
  --password "$APP_PASSWORD" \
  --team-id "$TEAM_ID" \
  --wait

echo ""
echo "7️⃣ Stapling DMG..."
xcrun stapler staple "$DMG_PATH"
echo ""

# Done!
echo "════════════════════════════════════════════════════════════"
echo "✅ SUCCESS - QFOT Wallet is ready for distribution!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📦 Distribution file: $DMG_PATH"
echo "   Size: $(du -h "$DMG_PATH" | cut -f1)"
echo ""
echo "🚀 Next steps:"
echo ""
echo "1. Test the DMG:"
echo "   open $DMG_PATH"
echo ""
echo "2. Upload to your server:"
echo "   scp $DMG_PATH user@safeaicoin.org:/var/www/downloads/"
echo ""
echo "3. Share download link:"
echo "   https://safeaicoin.org/download/$DMG_PATH"
echo ""
echo "════════════════════════════════════════════════════════════"

