#!/bin/bash
#
# Upload IPAs to TestFlight using API credentials
# Using the API key and issuer from your App Store Connect account
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# API credentials - from your App Store Connect
API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="d648c36b-f731-4c3e-bb88-32aad08f9f2d"  # This is what we have

echo "🚀 UPLOADING TO TESTFLIGHT WITH API CREDENTIALS"
echo ""
echo "API Key: $API_KEY_ID"
echo "Issuer: $API_ISSUER_ID"
echo ""

# Function to upload an IPA
upload_ipa() {
    local IPA_PATH="$1"
    local APP_NAME="$2"
    
    if [ ! -f "$IPA_PATH" ]; then
        echo "⚠️  IPA not found: $IPA_PATH"
        return 1
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   File: $(basename $IPA_PATH)"
    echo "   Size: $(du -h "$IPA_PATH" | cut -f1)"
    echo ""
    echo "   Uploading to Apple..."
    
    # Try upload with detailed error output
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_PATH" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        --verbose \
        2>&1 | tee "build/logs/${APP_NAME}_upload_verbose.log"
    
    local UPLOAD_STATUS=${PIPESTATUS[0]}
    
    if [ $UPLOAD_STATUS -eq 0 ]; then
        echo ""
        echo "   ✅ UPLOADED TO TESTFLIGHT!"
        echo ""
        return 0
    else
        echo ""
        echo "   ❌ UPLOAD FAILED"
        echo ""
        echo "Error details in: build/logs/${APP_NAME}_upload_verbose.log"
        echo ""
        
        # Show last 20 lines of error
        echo "Last error lines:"
        tail -20 "build/logs/${APP_NAME}_upload_verbose.log"
        echo ""
        return 1
    fi
}

# Upload PersonalHealth
upload_ipa \
    "build/ipas_for_upload/PersonalHealthApp.ipa" \
    "PersonalHealth"

# Upload Legal
upload_ipa \
    "build/exports_simple/Legal/FoTLegalApp.ipa" \
    "Legal"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ UPLOAD ATTEMPTS COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If uploads failed with authentication error:"
echo "  The API Issuer ID may be wrong."
echo "  Check: https://appstoreconnect.apple.com"
echo "         Users and Access → Keys → Copy Issuer ID"
echo ""
echo "Or use Transporter app (no API needed):"
echo "  1. Open Transporter"
echo "  2. Drag IPAs"
echo "  3. Click Deliver"

