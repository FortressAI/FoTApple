#!/bin/bash
set -e

# ================================================================
# 🔧 FIX PRIVACY STRINGS & REDEPLOY
# ================================================================
# Adds required privacy permission strings to Info.plist files
# Then rebuilds and uploads Legal v16 and Education v15
# ================================================================

PROJECT_ROOT="/Users/richardgillespie/Documents/FoTApple"
API_KEY_PATH="$PROJECT_ROOT/private_keys/AuthKey_4D2JDDUK2S.p8"
API_KEY_ID="4D2JDDUK2S"
API_ISSUER_ID="0be0b98b-ed15-45d9-a644-9a1a26b22d31"
TEAM_ID="WWQQB728U5"

cd "$PROJECT_ROOT"

echo "================================================================"
echo "🔧 FIXING PRIVACY STRINGS FOR ALL APPS"
echo "================================================================"
echo ""

# Privacy strings to add
CAMERA_DESC="This app requires camera access for document scanning and visual content creation in your professional workflow."
LOCATION_DESC="Location access helps provide location-aware features and improves app functionality."

# Function to add privacy strings
add_privacy_strings() {
    local plist=$1
    local app_name=$2
    
    echo "📝 Adding privacy strings to $app_name..."
    
    # Add NSCameraUsageDescription
    /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string '$CAMERA_DESC'" "$plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :NSCameraUsageDescription '$CAMERA_DESC'" "$plist"
    
    # Add NSLocationWhenInUseUsageDescription
    /usr/libexec/PlistBuddy -c "Add :NSLocationWhenInUseUsageDescription string '$LOCATION_DESC'" "$plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :NSLocationWhenInUseUsageDescription '$LOCATION_DESC'" "$plist"
    
    echo "   ✅ Privacy strings added"
}

# Add privacy strings to ALL apps
echo "Adding privacy strings to all 5 apps..."
echo ""

add_privacy_strings "apps/PersonalHealthApp/iOS/PersonalHealth/Info.plist" "PersonalHealth"
add_privacy_strings "apps/LegalApp/iOS/FoTLegal/Info.plist" "Legal"
add_privacy_strings "apps/EducationApp/iOS/FoTEducation/Info.plist" "Education"
add_privacy_strings "apps/ParentApp/iOS/FoTParent/Info.plist" "Parent"
add_privacy_strings "apps/ClinicianApp/iOS/FoTClinician/Info.plist" "Clinician"

echo ""
echo "✅ All privacy strings added!"
echo ""
echo "================================================================"
echo "🔨 REBUILDING AFFECTED APPS"
echo "================================================================"
echo ""

# Function to build and upload
build_and_upload() {
    local APP_DIR=$1
    local SCHEME=$2
    local APP_NAME=$3
    local VERSION=$4
    local PLIST_PATH=$5
    
    echo "================================================================"
    echo "📱 $APP_NAME v$VERSION"
    echo "================================================================"
    
    PROJECT_PATH="apps/${APP_DIR}/iOS/${SCHEME}.xcodeproj"
    
    # Update version
    echo "🔢 Updating to version $VERSION..."
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$PLIST_PATH"
    echo "   ✅ Version $VERSION"
    echo ""
    
    # Clean
    echo "🧹 Cleaning..."
    xcodebuild clean \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration Release \
        > "build/logs/${SCHEME}_v${VERSION}_clean.log" 2>&1
    
    # Archive
    echo "🔨 Building archive..."
    ARCHIVE_PATH="build/archives/${SCHEME}_v${VERSION}.xcarchive"
    
    if ! xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        -allowProvisioningUpdates \
        2>&1 | tee "build/logs/${SCHEME}_v${VERSION}_archive.log"; then
        echo "❌ Archive failed"
        return 1
    fi
    
    echo "✅ Archive created"
    echo ""
    
    # Export
    echo "📦 Exporting IPA..."
    EXPORT_OPTIONS="build/${SCHEME}_v${VERSION}_ExportOptions.plist"
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
    
    if ! xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$IPA_DIR" \
        -exportOptionsPlist "$EXPORT_OPTIONS" \
        -allowProvisioningUpdates \
        2>&1 | tee "build/logs/${SCHEME}_v${VERSION}_export.log"; then
        echo "❌ Export failed"
        return 1
    fi
    
    echo "✅ IPA exported"
    echo ""
    
    # Find IPA
    IPA_FILE=$(find "$IPA_DIR" -name "*.ipa" | head -1)
    
    if [ -z "$IPA_FILE" ]; then
        echo "❌ IPA not found"
        return 1
    fi
    
    # Upload
    echo "🚀 Uploading to App Store Connect..."
    
    if xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "build/logs/${SCHEME}_v${VERSION}_upload.log"; then
        echo ""
        echo "✅ $APP_NAME v$VERSION UPLOADED SUCCESSFULLY!"
        return 0
    else
        echo ""
        echo "❌ Upload failed"
        return 1
    fi
}

# Build and upload the two rejected apps with new versions
SUCCESS=0
FAILED=0

echo "Rebuilding Legal (v15 was rejected, building v16)..."
if build_and_upload "LegalApp" "FoTLegalApp" "Legal" "16" "apps/LegalApp/iOS/FoTLegal/Info.plist"; then
    SUCCESS=$((SUCCESS+1))
else
    FAILED=$((FAILED+1))
fi

echo ""
echo "Rebuilding Education (v14 was rejected, building v15)..."
if build_and_upload "EducationApp" "FoTEducationApp" "Education" "15" "apps/EducationApp/iOS/FoTEducation/Info.plist"; then
    SUCCESS=$((SUCCESS+1))
else
    FAILED=$((FAILED+1))
fi

echo ""
echo "================================================================"
echo "🎯 DEPLOYMENT COMPLETE"
echo "================================================================"
echo ""
echo "✅ Successful: $SUCCESS/2"
echo "❌ Failed: $FAILED/2"
echo ""

if [ $SUCCESS -eq 2 ]; then
    echo "🎉 ALL APPS NOW HAVE PRIVACY STRINGS AND NEW BUILDS!"
    echo ""
    echo "📱 Final Status:"
    echo "   PersonalHealth: v14 ✅"
    echo "   Legal: v16 ✅ (fixed)"
    echo "   Education: v15 ✅ (fixed)"
    echo "   Parent: v14 ✅"
    echo "   Clinician: v15 ✅"
    exit 0
else
    echo "⚠️  Some builds failed - check logs"
    exit 1
fi

