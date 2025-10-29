#!/bin/bash
# Deploy all apps to TestFlight via CLI with API Key
# Supports iOS, macOS, and visionOS

set -e

TEAM_ID="WWQQB728U5"

# Check for API credentials
if [ -z "$API_KEY_ID" ] || [ -z "$API_ISSUER_ID" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  API Credentials Required"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Set these environment variables:"
    echo "  export API_KEY_ID=<your_key_id>"
    echo "  export API_ISSUER_ID=<your_issuer_id>"
    echo ""
    echo "And ensure key file exists:"
    echo "  ~/.appstoreconnect/private_keys/AuthKey_\$API_KEY_ID.p8"
    echo ""
    exit 1
fi

# Verify key file exists
KEY_FILE="$HOME/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8"
if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Key file not found: $KEY_FILE"
    echo "Download from App Store Connect and place it there"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Deploying All Apps to TestFlight"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Team ID: $TEAM_ID"
echo "API Key: $API_KEY_ID"
echo "Key File: ✅ Found"
echo ""

# App configurations: dir:scheme:bundle_id:platforms
declare -a APPS=(
    "PersonalHealthApp:PersonalHealthApp:com.fot.PersonalHealth:iOS"
    "ClinicianApp:FoTClinicianApp:com.fot.ClinicianApp:iOS"
    "ParentApp:FoTParentApp:com.fot.ParentApp:iOS,macOS"
    "EducationApp:FoTEducationApp:com.fot.EducationApp:iOS,macOS,visionOS"
    "LegalApp:FoTLegalApp:com.fot.LegalApp:iOS,macOS,visionOS"
)

SUCCESS=0
FAILED=0

for app_config in "${APPS[@]}"; do
    IFS=':' read -r dir scheme bundle_id platforms <<< "$app_config"
    
    # Split platforms
    IFS=',' read -ra PLATFORM_LIST <<< "$platforms"
    
    for platform in "${PLATFORM_LIST[@]}"; do
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 $scheme ($platform)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Set platform-specific variables
        case $platform in
            iOS)
                PLATFORM_DIR="iOS"
                DESTINATION="generic/platform=iOS"
                SDK="iphoneos"
                ;;
            macOS)
                PLATFORM_DIR="macOS"
                DESTINATION="generic/platform=macOS"
                SDK="macosx"
                ;;
            visionOS)
                PLATFORM_DIR="visionOS"
                DESTINATION="generic/platform=visionOS"
                SDK="xros"
                ;;
        esac
        
        PROJECT_PATH="apps/$dir/$PLATFORM_DIR"
        
        if [ ! -d "$PROJECT_PATH" ]; then
            echo "⚠️  Platform not available, skipping"
            continue
        fi
        
        cd "$PROJECT_PATH"
        
        # Archive
        echo "Archiving..."
        xcodebuild clean archive \
            -project "$scheme.xcodeproj" \
            -scheme "$scheme" \
            -configuration Release \
            -archivePath "../../../build/${scheme}_${platform}.xcarchive" \
            -destination "$DESTINATION" \
            -sdk "$SDK" \
            -allowProvisioningUpdates \
            DEVELOPMENT_TEAM="$TEAM_ID" \
            > /tmp/${scheme}_${platform}_archive.log 2>&1
        
        if [ $? -eq 0 ]; then
            echo "✅ Archive created"
            
            # Create ExportOptions with authentication
            cat > "../../../build/ExportOptions_${scheme}_${platform}.plist" <<EOF
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
            
            # Export and Upload
            echo "Exporting and uploading..."
            xcodebuild -exportArchive \
                -archivePath "../../../build/${scheme}_${platform}.xcarchive" \
                -exportPath "../../../build/export/${scheme}_${platform}" \
                -exportOptionsPlist "../../../build/ExportOptions_${scheme}_${platform}.plist" \
                -allowProvisioningUpdates \
                > /tmp/${scheme}_${platform}_export.log 2>&1
            
            if [ $? -eq 0 ]; then
                echo "✅ Uploaded to TestFlight"
                SUCCESS=$((SUCCESS + 1))
            else
                echo "❌ Export/Upload failed"
                echo "   Log: /tmp/${scheme}_${platform}_export.log"
                tail -20 /tmp/${scheme}_${platform}_export.log
                FAILED=$((FAILED + 1))
            fi
        else
            echo "❌ Archive failed"
            echo "   Log: /tmp/${scheme}_${platform}_archive.log"
            tail -20 /tmp/${scheme}_${platform}_archive.log
            FAILED=$((FAILED + 1))
        fi
        
        cd ../../..
    done
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Deployment Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Success: $SUCCESS"
echo "❌ Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 All apps deployed to TestFlight!"
else
    echo "⚠️  Some deployments failed - check logs in /tmp/"
fi

echo ""
echo "Check TestFlight:"
echo "  https://appstoreconnect.apple.com/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

