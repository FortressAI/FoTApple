#!/bin/bash
###############################################################################
# SIMPLE DEPLOYMENT - Just copy this file to your server
###############################################################################

echo "🚀 Deploying Wallet Validation Interface..."
echo ""

# The HTML file to deploy
HTML_FILE="/tmp/wallet_validation_review.html"

# Option 1: Direct SCP (if you have SSH key)
echo "📤 Option 1: Direct Copy"
echo "scp $HTML_FILE root@94.130.97.66:/var/www/qfot/review.html"
echo ""

# Option 2: Using password (will prompt)
echo "📤 Option 2: With Password Prompt"
echo "scp -o PreferredAuthentications=password $HTML_FILE root@94.130.97.66:/var/www/qfot/review.html"
echo ""

# Option 3: Show file content to copy manually
echo "📋 Option 3: Manual Copy"
echo "If SCP doesn't work, copy the file content from:"
echo "$HTML_FILE"
echo ""

# Try automatic deployment
echo "🔄 Attempting automatic deployment..."
echo ""

scp -o ConnectTimeout=5 -o PreferredAuthentications=password $HTML_FILE root@94.130.97.66:/var/www/qfot/review.html 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ DEPLOYMENT SUCCESSFUL!"
    echo "🌐 Visit: https://94.130.97.66/review.html"
    echo "🔐 Login with: @Domain-Packs.md"
else
    echo ""
    echo "⚠️  Automatic deployment failed"
    echo "📋 Manual steps:"
    echo "   1. Open your server terminal"
    echo "   2. Create file: nano /var/www/qfot/review.html"
    echo "   3. Copy content from: $HTML_FILE"
    echo "   4. Save and reload nginx: systemctl reload nginx"
fi
