#!/bin/bash
set -e

# ================================================================
# 🏥 BUILD & UPLOAD CLINICIAN v15 WITH NEW ICONS
# ================================================================

PROJECT_ROOT="/Users/richardgillespie/Documents/FoTApple"
API_KEY_PATH="$PROJECT_ROOT/private_keys/AuthKey_4D2JDDUK2S.p8"
API_KEY_ID="4D2JDDUK2S"
API_ISSUER_ID="0be0b98b-ed15-45d9-a644-9a1a26b22d31"
TEAM_ID="WWQQB728U5"
VERSION="15"

PROJECT_PATH="apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj"
SCHEME="FoTClinicianApp"
PLIST_PATH="apps/ClinicianApp/iOS/FoTClinician/Info.plist"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$PROJECT_ROOT"

echo "================================================================"
echo "🏥 BUILDING CLINICIAN v15 WITH NEW ICONS"
echo "================================================================"
echo ""

# Update version
echo "🔢 Updating version to $VERSION..."
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$PLIST_PATH" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $VERSION" "$PLIST_PATH"
echo "   ✅ Version updated to $VERSION"
echo ""

# Clean
echo "🧹 Cleaning..."
xcodebuild clean \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration Release \
    > "build/logs/clinician_v15_clean.log" 2>&1
echo "   ✅ Clean complete"
echo ""

# Archive
echo "🔨 Building archive..."
ARCHIVE_PATH="build/archives/${SCHEME}_v${VERSION}.xcarchive"

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
    2>&1 | tee "build/logs/clinician_v15_archive.log"; then
    
    echo ""
    echo -e "${GREEN}✅ Archive created successfully${NC}"
else
    echo ""
    echo -e "${RED}❌ Archive failed${NC}"
    exit 1
fi

echo ""
echo "📦 Exporting IPA..."

# Create export options
EXPORT_OPTIONS="build/clinician_v15_ExportOptions.plist"
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

IPA_DIR="build/ipas/${SCHEME}_v${VERSION}"
mkdir -p "$IPA_DIR"

if xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$IPA_DIR" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -allowProvisioningUpdates \
    2>&1 | tee "build/logs/clinician_v15_export.log"; then
    
    echo ""
    echo -e "${GREEN}✅ IPA exported successfully${NC}"
else
    echo ""
    echo -e "${RED}❌ Export failed${NC}"
    exit 1
fi

# Find IPA
IPA_FILE=$(find "$IPA_DIR" -name "*.ipa" | head -1)

if [ -z "$IPA_FILE" ]; then
    echo -e "${RED}❌ IPA file not found${NC}"
    exit 1
fi

echo ""
echo "🚀 Uploading to App Store Connect..."
echo "   File: $(basename "$IPA_FILE")"
echo "   Size: $(du -h "$IPA_FILE" | cut -f1)"
echo ""

if xcrun altool --upload-app \
    --type ios \
    --file "$IPA_FILE" \
    --apiKey "$API_KEY_ID" \
    --apiIssuer "$API_ISSUER_ID" \
    2>&1 | tee "build/logs/clinician_v15_upload.log"; then
    
    echo ""
    echo -e "${GREEN}================================================================${NC}"
    echo -e "${GREEN}🎉 CLINICIAN v15 UPLOADED SUCCESSFULLY!${NC}"
    echo -e "${GREEN}================================================================${NC}"
    echo ""
    echo "✅ All 5 apps now have new icons in App Store Connect"
    echo "🔗 Check: https://appstoreconnect.apple.com"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Upload failed${NC}"
    exit 1
fi

