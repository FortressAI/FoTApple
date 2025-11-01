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
KEYCHAIN_PROFILE="qfot-notarization"

# Check if credentials are stored
echo "🔐 Checking for stored credentials..."
xcrun notarytool history --keychain-profile "$KEYCHAIN_PROFILE" &>/dev/null

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ No stored credentials found!"
    echo ""
    echo "Run this first to store your credentials:"
    echo "   ./setup_notarization.sh"
    echo ""
    exit 1
fi

echo "   ✅ Found stored credentials: $KEYCHAIN_PROFILE"
echo ""

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at: $APP_PATH"
    echo ""
    echo "The app needs to be built first."
    exit 1
fi

echo "📦 Found app: $APP_PATH"
echo ""

# Step 1: Create ZIP for notarization
echo "1️⃣ Creating ZIP for notarization..."
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
echo "   ✅ Created: $ZIP_PATH"
echo ""

# Step 2: Submit for notarization (using stored credentials)
echo "2️⃣ Submitting to Apple for notarization..."
echo "   (This may take 5-10 minutes...)"
echo ""

xcrun notarytool submit "$ZIP_PATH" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

if [ $? -eq 0 ]; then
    echo ""
    echo "   ✅ Notarization succeeded!"
    echo ""
else
    echo ""
    echo "   ❌ Notarization failed!"
    echo ""
    echo "View recent submissions:"
    echo "   xcrun notarytool history --keychain-profile $KEYCHAIN_PROFILE"
    exit 1
fi

# Step 3: Staple the notarization ticket
echo "3️⃣ Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"
echo "   ✅ Stapled!"
echo ""

# Step 4: Verify notarization
echo "4️⃣ Verifying notarization..."
spctl -a -vv "$APP_PATH" 2>&1 | grep -E "accepted|origin"
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
ZIP_DMG="${DMG_PATH}.zip"
ditto -c -k --keepParent "$DMG_PATH" "$ZIP_DMG"

xcrun notarytool submit "$ZIP_DMG" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

rm -f "$ZIP_DMG"
echo ""

echo "7️⃣ Stapling DMG..."
xcrun stapler staple "$DMG_PATH"
echo ""

# Get file sizes
APP_SIZE=$(du -h "$APP_PATH" | cut -f1)
DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)

# Done!
echo "════════════════════════════════════════════════════════════"
echo "✅ SUCCESS - QFOT Wallet is ready for distribution!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📦 Distribution files:"
echo "   App:  $APP_PATH ($APP_SIZE)"
echo "   DMG:  $DMG_PATH ($DMG_SIZE)"
echo ""
echo "🔐 Verification:"
codesign -dvv "$APP_PATH" 2>&1 | grep "Authority"
echo ""
echo "🚀 Next steps:"
echo ""
echo "1. Test the DMG:"
echo "   open $DMG_PATH"
echo ""
echo "2. Upload to your server:"
echo "   scp $DMG_PATH root@94.130.97.66:/var/www/downloads/"
echo "   scp $DMG_PATH root@46.224.42.20:/var/www/downloads/"
echo ""
echo "3. Share download link:"
echo "   https://safeaicoin.org/download/$DMG_PATH"
echo ""
echo "════════════════════════════════════════════════════════════"

