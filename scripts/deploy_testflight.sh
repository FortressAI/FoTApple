#!/bin/bash
# TestFlight Deployment Script for Field of Truth Apps
# Requires: Xcode, Apple Developer Account with Team ID WWQQB728U5

set -e

TEAM_ID="WWQQB728U5"
ARCHIVE_PATH="./build/archives"
EXPORT_PATH="./build/exports"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Field of Truth - TestFlight Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Team ID: $TEAM_ID"
echo "Archive Path: $ARCHIVE_PATH"
echo ""

# Create directories
mkdir -p "$ARCHIVE_PATH"
mkdir -p "$EXPORT_PATH"

# App configurations: directory:project:scheme:bundle_id
declare -a APPS=(
    "PersonalHealthApp:PersonalHealthApp:PersonalHealthApp:com.fieldoftruth.personalhealth"
    "ClinicianApp:FoTClinicianApp:FoTClinicianApp:com.fieldoftruth.clinician"
    "ParentApp:FoTParentApp:FoTParentApp:com.fieldoftruth.parent"
    "EducationApp:FoTEducationApp:FoTEducationApp:com.fieldoftruth.education"
    "LegalApp:FoTLegalApp:FoTLegalApp:com.fieldoftruth.legal"
)

# Function to archive an app
archive_app() {
    local app_dir=$1
    local project=$2
    local scheme=$3
    local bundle_id=$4
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Archiving: $scheme"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "apps/$app_dir/iOS"
    
    # Clean build directory
    xcodebuild clean \
        -project "$project.xcodeproj" \
        -scheme "$scheme" \
        -configuration Release
    
    # Create archive
    xcodebuild archive \
        -project "$project.xcodeproj" \
        -scheme "$scheme" \
        -configuration Release \
        -archivePath "../../../$ARCHIVE_PATH/$scheme.xcarchive" \
        -destination "generic/platform=iOS" \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        PRODUCT_BUNDLE_IDENTIFIER="$bundle_id" \
        CODE_SIGN_STYLE=Automatic \
        CODE_SIGN_IDENTITY="Apple Development"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Archive created: $scheme.xcarchive${NC}"
    else
        echo -e "${RED}❌ Archive failed for $scheme${NC}"
        return 1
    fi
    
    cd ../../..
}

# Function to export for TestFlight
export_for_testflight() {
    local scheme=$1
    local bundle_id=$2
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📤 Exporting: $scheme"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Create ExportOptions.plist
    cat > "$EXPORT_PATH/ExportOptions_$scheme.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
    
    # Export archive
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH/$scheme.xcarchive" \
        -exportPath "$EXPORT_PATH/$scheme" \
        -exportOptionsPlist "$EXPORT_PATH/ExportOptions_$scheme.plist"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Exported: $scheme.ipa${NC}"
    else
        echo -e "${RED}❌ Export failed for $scheme${NC}"
        return 1
    fi
}

# Function to upload to TestFlight
upload_to_testflight() {
    local scheme=$1
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "☁️  Uploading: $scheme"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Find the .ipa file
    IPA_PATH="$EXPORT_PATH/$scheme/$scheme.ipa"
    
    if [ ! -f "$IPA_PATH" ]; then
        echo -e "${RED}❌ IPA not found: $IPA_PATH${NC}"
        return 1
    fi
    
    # Upload using altool or xcrun
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_PATH" \
        --apiKey "YOUR_API_KEY" \
        --apiIssuer "YOUR_API_ISSUER"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Uploaded: $scheme${NC}"
    else
        echo -e "${YELLOW}⚠️  Upload requires App Store Connect API key${NC}"
        echo -e "${YELLOW}   Alternatively, upload manually via Transporter app${NC}"
        echo -e "${YELLOW}   IPA location: $IPA_PATH${NC}"
    fi
}

# Main deployment loop
echo "Starting deployment process..."
echo ""

for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_dir project scheme bundle_id <<< "$app_config"
    
    # Archive
    if archive_app "$app_dir" "$project" "$scheme" "$bundle_id"; then
        # Export
        if export_for_testflight "$scheme" "$bundle_id"; then
            # Upload (optional - requires API key setup)
            # upload_to_testflight "$scheme"
            echo -e "${GREEN}✅ $scheme ready for TestFlight${NC}"
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "IPAs ready in: $EXPORT_PATH"
echo ""
echo "Next steps:"
echo "1. Upload IPAs to App Store Connect via Transporter"
echo "2. Configure TestFlight beta testing"
echo "3. Add beta testers"
echo ""

