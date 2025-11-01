#!/bin/bash
set -e

# ================================================================
# 🎨 REBUILD & DEPLOY ALL APPS WITH NEW ICONS
# ================================================================
# Increments version, rebuilds, and uploads all 5 apps with new icons
# ================================================================

PROJECT_ROOT="/Users/richardgillespie/Documents/FoTApple"
API_KEY_PATH="$PROJECT_ROOT/private_keys/AuthKey_A746Z2JSK2.p8"
API_KEY_ID="A746Z2JSK2"
API_ISSUER_ID="d648c36b-f731-4c3e-bb88-32aad08f9f2d"
TEAM_ID="WWQQB728U5"

# New version number (increment from current)
NEW_VERSION="14"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$PROJECT_ROOT"

echo "================================================================"
echo "🎨 REBUILDING ALL APPS WITH NEW ICONS"
echo "================================================================"
echo ""
echo "🔢 New Version: $NEW_VERSION"
echo "🔑 API Key: $API_KEY_ID"
echo ""

# Create build directories
mkdir -p build/{archives,ipas,logs}

# Function to update bundle version
update_version() {
    local plist_path=$1
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_VERSION" "$plist_path" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $NEW_VERSION" "$plist_path"
    echo "   ✅ Version updated to $NEW_VERSION"
}

# Function to build, export, and upload an app
deploy_app() {
    local APP_DIR=$1
    local SCHEME=$2
    local APP_NAME=$3
    
    echo ""
    echo "================================================================"
    echo "📱 $APP_NAME"
    echo "================================================================"
    
    PROJECT_PATH="apps/${APP_DIR}/iOS/${SCHEME}.xcodeproj"
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ Project not found: $PROJECT_PATH"
        return 1
    fi
    
    # Determine Info.plist path
    case "$APP_DIR" in
        "PersonalHealthApp")
            PLIST_PATH="apps/${APP_DIR}/iOS/PersonalHealth/Info.plist"
            ;;
        "ClinicianApp")
            PLIST_PATH="apps/${APP_DIR}/iOS/FoTClinician/Info.plist"
            ;;
        "LegalApp")
            PLIST_PATH="apps/${APP_DIR}/iOS/FoTLegal/Info.plist"
            ;;
        "EducationApp")
            PLIST_PATH="apps/${APP_DIR}/iOS/FoTEducation/Info.plist"
            ;;
        "ParentApp")
            PLIST_PATH="apps/${APP_DIR}/iOS/FoTParent/Info.plist"
            ;;
    esac
    
    # Update version
    echo "🔢 Updating version..."
    update_version "$PLIST_PATH"
    
    # Clean build
    echo "🧹 Cleaning..."
    xcodebuild clean \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration Release \
        > "build/logs/${SCHEME}_clean.log" 2>&1
    
    # Archive
    echo "🔨 Building archive..."
    ARCHIVE_PATH="build/archives/${SCHEME}_v${NEW_VERSION}.xcarchive"
    
    if xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        -allowProvisioningUpdates \
        2>&1 | tee "build/logs/${SCHEME}_archive.log"; then
        
        echo -e "${GREEN}✅ Archive created${NC}"
    else
        echo -e "${RED}❌ Archive failed${NC}"
        return 1
    fi
    
    # Export
    echo "📦 Exporting IPA..."
    
    # Create export options
    EXPORT_OPTIONS="build/${SCHEME}_ExportOptions.plist"
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
    
    IPA_DIR="build/ipas/${SCHEME}_v${NEW_VERSION}"
    mkdir -p "$IPA_DIR"
    
    if xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$IPA_DIR" \
        -exportOptionsPlist "$EXPORT_OPTIONS" \
        -allowProvisioningUpdates \
        2>&1 | tee "build/logs/${SCHEME}_export.log"; then
        
        echo -e "${GREEN}✅ IPA exported${NC}"
    else
        echo -e "${RED}❌ Export failed${NC}"
        return 1
    fi
    
    # Find the IPA file
    IPA_FILE=$(find "$IPA_DIR" -name "*.ipa" | head -1)
    
    if [ -z "$IPA_FILE" ]; then
        echo -e "${RED}❌ IPA file not found${NC}"
        return 1
    fi
    
    # Upload
    echo "🚀 Uploading to App Store Connect..."
    
    if xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "build/logs/${SCHEME}_upload_v${NEW_VERSION}.log"; then
        
        echo -e "${GREEN}✅ $APP_NAME UPLOADED SUCCESSFULLY${NC}"
        return 0
    else
        echo -e "${RED}❌ $APP_NAME UPLOAD FAILED${NC}"
        return 1
    fi
}

# Deploy all apps
SUCCESS=0
FAILED=0

deploy_app "PersonalHealthApp" "PersonalHealthApp" "PersonalHealth" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
deploy_app "LegalApp" "FoTLegalApp" "Legal" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
deploy_app "EducationApp" "FoTEducationApp" "Education" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
deploy_app "ParentApp" "FoTParentApp" "Parent" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))
deploy_app "ClinicianApp" "FoTClinicianApp" "Clinician" && SUCCESS=$((SUCCESS+1)) || FAILED=$((FAILED+1))

echo ""
echo "================================================================"
echo "🎯 DEPLOYMENT COMPLETE"
echo "================================================================"
echo ""
echo "✅ Successful: $SUCCESS/5"
echo "❌ Failed: $FAILED/5"
echo ""

if [ $SUCCESS -eq 5 ]; then
    echo -e "${GREEN}🎉 ALL APPS DEPLOYED WITH NEW ICONS!${NC}"
    echo ""
    echo "📱 All apps now have version $NEW_VERSION with new icons"
    echo "🔗 Check App Store Connect: https://appstoreconnect.apple.com"
    exit 0
elif [ $SUCCESS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  PARTIAL SUCCESS${NC}"
    exit 1
else
    echo -e "${RED}❌ ALL DEPLOYMENTS FAILED${NC}"
    exit 1
fi

