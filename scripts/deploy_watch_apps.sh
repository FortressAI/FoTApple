#!/bin/bash
set -e

# ================================================================
# 🎯 WATCH APP DEPLOYMENT SCRIPT
# ================================================================
# Uses the new App Manager API key (A746Z2JSK2) to deploy Watch apps
# This key should have proper permissions for Watch app provisioning
# ================================================================

# Configuration
PROJECT_ROOT="/Users/richardgillespie/Documents/FoTApple"
API_KEY_PATH="$PROJECT_ROOT/private_keys/AuthKey_A746Z2JSK2.p8"
API_KEY_ID="A746Z2JSK2"
API_ISSUER_ID="d648c36b-f731-4c3e-bb88-32aad08f9f2d"
TEAM_ID="WWQQB728U5"
VERSION="9"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "================================================================"
echo "🎯 WATCH APP DEPLOYMENT - Using App Manager API Key"
echo "================================================================"
echo ""
echo "🔑 API Configuration:"
echo "   Key ID: $API_KEY_ID"
echo "   Key Path: $API_KEY_PATH"
echo "   Issuer ID: $API_ISSUER_ID"
echo "   Team ID: $TEAM_ID"
echo ""

# Verify API key exists
if [ ! -f "$API_KEY_PATH" ]; then
    echo "❌ ERROR: API key not found at $API_KEY_PATH"
    exit 1
fi

echo "✅ API key verified"
echo ""

# Watch apps to deploy (with their parent iOS apps)
declare -a WATCH_APPS=(
    "ClinicianApp|FoTClinicianApp|com.fot.ClinicianApp"
    "PersonalHealthApp|PersonalHealthApp|com.akashic.PersonalHealth"
    "LegalApp|FoTLegalApp|com.akashic.FoTLegal"
    "EducationApp|FoTEducationApp|com.akashic.FoTEducation"
    "ParentApp|FoTParentApp|com.akashic.FoTParent"
)

SUCCESS_COUNT=0
FAIL_COUNT=0

cd "$PROJECT_ROOT"

for APP_INFO in "${WATCH_APPS[@]}"; do
    IFS='|' read -r APP_DIR SCHEME BUNDLE_ID <<< "$APP_INFO"
    
    echo "================================================================"
    echo "📱 Processing: $SCHEME (Watch App)"
    echo "================================================================"
    
    PROJECT_PATH="apps/${APP_DIR}/iOS/${SCHEME}.xcodeproj"
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ Project not found: $PROJECT_PATH"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    # Archive path
    ARCHIVE_PATH="build/archives/${SCHEME}_Watch_v${VERSION}.xcarchive"
    
    echo "🔨 Building archive for $SCHEME..."
    echo "   Project: $PROJECT_PATH"
    echo "   Scheme: $SCHEME"
    echo ""
    
    # Build with Manual code signing to handle Watch app provisioning
    if xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Manual \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        -allowProvisioningUpdates \
        2>&1 | tee "build/logs/${SCHEME}_watch_archive.log"; then
        
        echo "✅ Archive created successfully"
        echo ""
        
        # Export IPA
        echo "📦 Exporting IPA..."
        
        # Create export options plist
        EXPORT_OPTIONS="build/${SCHEME}_WatchExportOptions.plist"
        cat > "$EXPORT_OPTIONS" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
</dict>
</plist>
EOF
        
        IPA_PATH="build/ipas/${SCHEME}_Watch_v${VERSION}.ipa"
        mkdir -p build/ipas
        
        if xcodebuild -exportArchive \
            -archivePath "$ARCHIVE_PATH" \
            -exportPath "build/ipas" \
            -exportOptionsPlist "$EXPORT_OPTIONS" \
            -allowProvisioningUpdates \
            2>&1 | tee "build/logs/${SCHEME}_watch_export.log"; then
            
            echo "✅ IPA exported successfully"
            echo ""
            
            # Upload to App Store Connect
            echo "🚀 Uploading to App Store Connect..."
            
            if xcrun altool --upload-app \
                --type ios \
                --file "$IPA_PATH" \
                --apiKey "$API_KEY_ID" \
                --apiIssuer "$API_ISSUER_ID" \
                2>&1 | tee "build/logs/${SCHEME}_watch_upload.log"; then
                
                echo -e "${GREEN}✅ $SCHEME Watch App UPLOADED SUCCESSFULLY${NC}"
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                echo -e "${RED}❌ $SCHEME Watch App UPLOAD FAILED${NC}"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        else
            echo -e "${RED}❌ $SCHEME Watch App EXPORT FAILED${NC}"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo -e "${RED}❌ $SCHEME Watch App ARCHIVE FAILED${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    echo ""
done

echo "================================================================"
echo "🎯 WATCH APP DEPLOYMENT COMPLETE"
echo "================================================================"
echo ""
echo "✅ Successful: $SUCCESS_COUNT"
echo "❌ Failed: $FAIL_COUNT"
echo ""

if [ $SUCCESS_COUNT -eq 5 ]; then
    echo -e "${GREEN}🎉 ALL WATCH APPS DEPLOYED SUCCESSFULLY!${NC}"
    exit 0
elif [ $SUCCESS_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  PARTIAL SUCCESS - Some Watch apps deployed${NC}"
    exit 1
else
    echo -e "${RED}❌ ALL WATCH APPS FAILED TO DEPLOY${NC}"
    exit 1
fi

