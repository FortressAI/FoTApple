#!/bin/bash
###############################################################################
# Deploy Wallet-Based Validation System to QFOT Blockchain
###############################################################################

set -e

SERVER="94.130.97.66"
WEB_ROOT="/var/www/qfot"

echo "=" * 80
echo "🚀 DEPLOYING WALLET-BASED VALIDATION SYSTEM"
echo "="  * 80

# Copy new review.html interface
echo "📤 Deploying validation interface..."
scp /tmp/wallet_validation_review.html root@${SERVER}:${WEB_ROOT}/review.html

echo ""
echo "✅ DEPLOYMENT COMPLETE!"
echo ""
echo "🌐 Access your validation interface at:"
echo "   https://94.130.97.66/review.html"
echo ""
echo "🔐 Your Admin Wallet:"
echo "   Alias: @Domain-Packs.md"
echo "   Wallet ID: 2f42c99d9054916c"
echo "   Balance: 10,000 QFOT"
echo ""
echo "🎯 How to Use:"
echo "   1. Visit https://94.130.97.66/review.html"
echo "   2. Enter your alias: @Domain-Packs.md"
echo "   3. Click 'Connect'"
echo "   4. Start validating or refuting facts!"
echo ""
echo "💡 Anyone can participate:"
echo "   • Choose any alias"
echo "   • Connect wallet"
echo "   • Validate/refute facts"
echo "   • Earn rewards for correct validations"
echo ""

