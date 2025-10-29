#!/bin/bash
# Deploy all 5 apps to TestFlight via CLI
# Run after apps are created in App Store Connect

set -e

TEAM_ID="WWQQB728U5"
API_KEY_ID="YOUR_KEY_ID"           # e.g., A1B2C3D4E5
API_ISSUER_ID="YOUR_ISSUER_ID"     # UUID from App Store Connect

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Deploying All 5 Apps to TestFlight"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# App configurations
declare -a APPS=(
    "PersonalHealthApp:PersonalHealthApp:com.fot.PersonalHealth"
    "ClinicianApp:FoTClinicianApp:com.fot.ClinicianApp"
    "ParentApp:FoTParentApp:com.fot.ParentApp"
    "EducationApp:FoTEducationApp:com.fot.EducationApp"
    "LegalApp:FoTLegalApp:com.fot.LegalApp"
)

SUCCESS=0
FAILED=0

for app_config in "${APPS[@]}"; do
    IFS=':' read -r dir scheme bundle_id <<< "$app_config"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 $scheme"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "apps/$dir/iOS"
    
    # Archive
    echo "Archiving..."
    xcodebuild clean archive \
        -project "$scheme.xcodeproj" \
        -scheme "$scheme" \
        -configuration Release \
        -archivePath "../../../build/$scheme.xcarchive" \
        -destination "generic/platform=iOS" \
        -allowProvisioningUpdates \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        > /tmp/${scheme}_archive.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ Archive created"
        
        # Create ExportOptions with authentication
        echo "Creating export options..."
        
        cat > "../../../build/ExportOptions_${scheme}.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    
    <key>destination</key>
    <string>upload</string>
    
    <key>teamID</key>
    <string>$TEAM_ID</string>
    
    <key>signingStyle</key>
    <string>automatic</string>
    
    <key>uploadSymbols</key>
    <true/>
    
    <key>authentication</key>
    <dict>
        <key>apiIssuer</key>
        <string>$API_ISSUER_ID</string>
        <key>apiKey</key>
        <string>$API_KEY_ID</string>
    </dict>
</dict>
</plist>
EOF
        
        # Export and Upload (automatic with destination:upload)
        echo "Exporting and uploading..."
        xcodebuild -exportArchive \
            -archivePath "../../../build/$scheme.xcarchive" \
            -exportPath "../../../build/export/$scheme" \
            -exportOptionsPlist "../../../build/ExportOptions_${scheme}.plist" \
            -allowProvisioningUpdates \
            > /tmp/${scheme}_export.log 2>&1
        
        if [ $? -eq 0 ]; then
            echo "✅ Uploaded to TestFlight"
            SUCCESS=$((SUCCESS + 1))
        else
            echo "❌ Export/Upload failed (see /tmp/${scheme}_export.log)"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "❌ Archive failed (see /tmp/${scheme}_archive.log)"
        FAILED=$((FAILED + 1))
    fi
    
    cd ../../..
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Deployment Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Success: $SUCCESS"
echo "❌ Failed: $FAILED"
echo ""

if [ $SUCCESS -eq 5 ]; then
    echo "🎉 All 5 apps deployed to TestFlight!"
    echo ""
    echo "Check status:"
    echo "  https://appstoreconnect.apple.com/"
elif [ $SUCCESS -gt 0 ]; then
    echo "⚠️  $SUCCESS apps deployed, $FAILED failed"
    echo "Check logs in /tmp/"
else
    echo "❌ All deployments failed"
    echo "Check logs in /tmp/"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"