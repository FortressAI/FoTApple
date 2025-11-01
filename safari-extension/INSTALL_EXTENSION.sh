#!/bin/bash

################################################################################
# QFOT Wallet Safari Extension - Installation Helper
################################################################################

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "🦊 QFOT WALLET SAFARI EXTENSION - INSTALLATION HELPER"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

# Check if Xcode is running
echo "🔍 Checking Xcode status..."
if ps aux | grep -v grep | grep -q "Xcode.app"; then
    echo "✅ Xcode is running"
else
    echo "⚠️  Xcode is not running"
    echo ""
    echo "Opening Xcode project..."
    open "/Users/richardgillespie/Documents/FoTApple/safari-extension/QFOTWallet-Safari/QFOT Wallet/QFOT Wallet.xcodeproj"
    sleep 3
    echo "✅ Xcode should be opening now..."
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "📋 STEP-BY-STEP INSTALLATION"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

echo "STEP 1: In Xcode (should be open now)"
echo "────────────────────────────────────────────────────────────────────────────────"
echo "  • Wait for Xcode to load the project (10-20 seconds)"
echo "  • Top left corner: Find the scheme dropdown"
echo "  • Click it and select: 'QFOT Wallet (macOS)'"
echo "  • Target should be: 'My Mac'"
echo "  • Press ⌘R (or click the Play ▶️ button)"
echo "  • You should see: 'Running QFOT Wallet' in the status bar"
echo "  • Keep Xcode running!"
echo ""

echo "STEP 2: In Safari"
echo "────────────────────────────────────────────────────────────────────────────────"
echo "  • Quit Safari completely: Press ⌘Q"
echo "  • Wait 2 seconds"
echo "  • Reopen Safari"
echo "  • Go to: Safari → Preferences (or press ⌘,)"
echo "  • Click the 'Extensions' tab"
echo "  • Look for 'QFOT Wallet' in the left sidebar"
echo "  • Check the box to enable it"
echo "  • Click 'Always Allow on Every Website'"
echo "  • Look for the ⚛️ icon in Safari toolbar!"
echo ""

echo "STEP 3: Test It"
echo "────────────────────────────────────────────────────────────────────────────────"
echo "  • Click the ⚛️ icon in Safari toolbar"
echo "  • You should see the wallet interface"
echo "  • Create a test wallet or import your creator wallet"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo "🔍 TROUBLESHOOTING"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

# Check if app is running
echo "Checking if QFOT Wallet app is running..."
if ps aux | grep -v grep | grep -q "QFOT Wallet"; then
    echo "✅ QFOT Wallet app is RUNNING"
else
    echo "❌ QFOT Wallet app is NOT RUNNING"
    echo "   → You need to run it from Xcode (⌘R)"
fi

# Check Safari
echo ""
echo "Checking Safari..."
if ps aux | grep -v grep | grep -q "Safari"; then
    echo "✅ Safari is running"
    echo "   → After running app from Xcode, quit Safari (⌘Q) and reopen"
else
    echo "⚠️  Safari is not running"
    echo "   → Start Safari after running the app from Xcode"
fi

# Check blockchain APIs
echo ""
echo "Checking blockchain APIs..."
if curl -s -f -m 2 "http://94.130.97.66:8000/api/status" > /dev/null 2>&1; then
    echo "✅ Blockchain API is RUNNING"
    echo "   → Extension will be able to fetch balances and submit transactions"
else
    echo "⚠️  Blockchain API not responding"
    echo "   → Wallet will work, but can't fetch balances from blockchain"
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "💡 KEY POINTS"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "  ✅ Safari extensions run LOCALLY (no deployment needed)"
echo "  ✅ Blockchain API runs on SERVERS (already deployed and running)"
echo "  ✅ Extension connects TO blockchain servers"
echo "  ✅ Wallet storage is LOCAL (secure, private)"
echo ""
echo "  ⚠️  Development extensions need parent app running"
echo "  ⚠️  Run from Xcode to keep app active"
echo "  ⚠️  Must restart Safari after starting app"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

# Check if everything is ready
ALL_READY=true

if ! ps aux | grep -v grep | grep -q "QFOT Wallet"; then
    ALL_READY=false
fi

if [ "$ALL_READY" = true ]; then
    echo "🎉 READY TO USE!"
    echo ""
    echo "   1. Quit Safari (⌘Q)"
    echo "   2. Reopen Safari"
    echo "   3. Safari → Preferences → Extensions"
    echo "   4. Enable 'QFOT Wallet'"
    echo "   5. Click ⚛️ icon in toolbar"
    echo ""
else
    echo "⏳ NOT QUITE READY"
    echo ""
    echo "   → Go to Xcode and press ⌘R to run the app"
    echo "   → Then run this script again to check status"
    echo ""
fi

echo "════════════════════════════════════════════════════════════════════════════════"

