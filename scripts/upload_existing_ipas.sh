#!/bin/bash
#
# Upload existing IPAs directly to TestFlight
# Uses IPAs that were already successfully exported
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# API credentials
API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="d648c36b-f731-4c3e-bb88-32aad08f9f2d"

echo "🚀 UPLOADING EXISTING IPAs TO TESTFLIGHT"
echo ""

# Check if PersonalHealth IPA exists
if [ -f "build/ipas_for_upload/PersonalHealthApp.ipa" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 PersonalHealth iOS (RED icon)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   IPA: build/ipas_for_upload/PersonalHealthApp.ipa"
    echo "   Size: $(du -h build/ipas_for_upload/PersonalHealthApp.ipa | cut -f1)"
    echo ""
    echo "   Uploading to TestFlight..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "build/ipas_for_upload/PersonalHealthApp.ipa" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee build/logs/PersonalHealth_upload.log
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo ""
        echo "   ✅ PERSONAL HEALTH UPLOADED TO TESTFLIGHT!"
        echo ""
    else
        echo ""
        echo "   ⚠️  Upload failed - check build/logs/PersonalHealth_upload.log"
        echo ""
    fi
else
    echo "⚠️  PersonalHealth IPA not found"
fi

# Check for Legal IPA in temp folders
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Legal iOS (NAVY/GOLD icon)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LEGAL_IPA=$(find /var/folders -name "FoTLegalApp.ipa" -mmin -300 2>/dev/null | head -1)

if [ -n "$LEGAL_IPA" ] && [ -f "$LEGAL_IPA" ]; then
    echo "   IPA: $LEGAL_IPA"
    echo "   Size: $(du -h "$LEGAL_IPA" | cut -f1)"
    echo ""
    echo "   Uploading to TestFlight..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "$LEGAL_IPA" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee build/logs/Legal_upload.log
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo ""
        echo "   ✅ LEGAL UPLOADED TO TESTFLIGHT!"
        echo ""
    else
        echo ""
        echo "   ⚠️  Upload failed - check build/logs/Legal_upload.log"
        echo ""
    fi
else
    echo "   ⚠️  Legal IPA not found in temp folders"
    echo "   Will re-export from archive..."
    
    # Re-export Legal archive if IPA not found
    if [ -d "build/archives/Legal_iOS.xcarchive" ]; then
        echo "   Exporting Legal archive..."
        
        # Simple export without signing validation
        xcodebuild -exportArchive \
            -archivePath "build/archives/Legal_iOS.xcarchive" \
            -exportPath "build/exports_simple/Legal" \
            -exportOptionsPlist /dev/stdin \
            <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
        
        LEGAL_IPA_NEW=$(find build/exports_simple/Legal -name "*.ipa" 2>/dev/null | head -1)
        
        if [ -f "$LEGAL_IPA_NEW" ]; then
            echo "   Re-export successful!"
            echo "   Uploading..."
            
            xcrun altool --upload-app \
                --type ios \
                --file "$LEGAL_IPA_NEW" \
                --apiKey "$API_KEY_ID" \
                --apiIssuer "$API_ISSUER_ID" \
                2>&1 | tee build/logs/Legal_upload.log
            
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                echo ""
                echo "   ✅ LEGAL UPLOADED TO TESTFLIGHT!"
                echo ""
            fi
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ UPLOAD COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next: Check App Store Connect in 15 minutes"
echo "      https://appstoreconnect.apple.com"

