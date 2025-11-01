#!/bin/bash

# QFOT Wallet Safari Extension Build Script

echo "=" * 80
echo "🦊 Building QFOT Wallet Safari Extension"
echo "=" * 80
echo ""

# Check prerequisites
if ! command -v xcrun &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found"
    echo "   Install with: xcode-select --install"
    exit 1
fi

# Convert Web Extension to Safari Extension
echo "📦 Converting Web Extension to Safari Extension..."
echo ""

xcrun safari-web-extension-converter QFOTWallet \
  --project-location ./QFOTWallet-Safari \
  --app-name "QFOT Wallet" \
  --bundle-identifier "com.fotapple.qfot.wallet" \
  --swift \
  --copy-resources

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Safari Extension created successfully!"
    echo ""
    echo "📂 Project location: ./QFOTWallet-Safari/"
    echo ""
    echo "Next steps:"
    echo "  1. open QFOTWallet-Safari/QFOT\ Wallet.xcodeproj"
    echo "  2. Select your development team"
    echo "  3. Build and run (⌘R)"
    echo "  4. Enable extension in Safari → Preferences → Extensions"
    echo ""
    echo "🚀 Ready to manage QFOT tokens!"
else
    echo ""
    echo "❌ Failed to create Safari Extension"
    echo "   Check error messages above"
    exit 1
fi

