#!/bin/bash
#
# Deploy ALL 5 apps - FIXED for manual signing
# Version 9 with unique icons
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# API Keys
API_KEY_PH="2D6WT653U4"
API_KEY_CLINICIAN="2D6WT653U4"
API_KEY_LEGAL="6BTQ4MH7DD"
API_KEY_EDUCATION="2D6WT653U4"
API_KEY_PARENT="2D6WT653U4"
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"

echo "🚀 DEPLOYING ALL 5 APPS - VERSION 9 (FIXED)"
echo ""
echo "Using AD-HOC signing for export (no account needed)"
echo ""

# Function to deploy one app
deploy_app() {
    local APP_NAME="$1"
    local PROJECT="$2"
    local SCHEME="$3"
    local API_KEY="$4"
    local ICON_DESC="$5"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$ICON_DESC $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Try archive with xcodebuild
    echo "   [1/3] Archiving (this may take 5-8 minutes)..."
    
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "build/archives/${APP_NAME}_v9_fixed.xcarchive" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Manual \
        CODE_SIGN_IDENTITY="Apple Distribution" \
        DEVELOPMENT_TEAM="84V9JRQRRN" \
        PROVISIONING_PROFILE_SPECIFIER="" \
        SKIP_INSTALL=NO \
        > "build/logs/${APP_NAME}_v9_fixed_archive.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ⚠️  Manual signing failed, trying automatic with device registration..."
        
        xcodebuild archive \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration Release \
            -archivePath "build/archives/${APP_NAME}_v9_fixed.xcarchive" \
            -sdk iphoneos \
            -destination "generic/platform=iOS" \
            CODE_SIGN_STYLE=Automatic \
            DEVELOPMENT_TEAM="84V9JRQRRN" \
            SKIP_INSTALL=NO \
            -allowProvisioningUpdates \
            -allowProvisioningDeviceRegistration \
            > "build/logs/${APP_NAME}_v9_fixed_archive.log" 2>&1
        
        if [ $? -ne 0 ]; then
            echo "   ❌ Archive failed"
            echo "   Error log:"
            tail -30 "build/logs/${APP_NAME}_v9_fixed_archive.log" | grep -A3 "error:"
            return 1
        fi
    fi
    
    echo "   ✅ Archived"
    
    # Export for App Store
    echo "   [2/3] Exporting..."
    
    cat > "/tmp/Export_${APP_NAME}_v9_fixed.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>84V9JRQRRN</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
</dict>
</plist>
EOF
    
    xcodebuild -exportArchive \
        -archivePath "build/archives/${APP_NAME}_v9_fixed.xcarchive" \
        -exportPath "build/exports_v9_fixed/${APP_NAME}" \
        -exportOptionsPlist "/tmp/Export_${APP_NAME}_v9_fixed.plist" \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_v9_fixed_export.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "   ❌ Export failed"
        tail -30 "build/logs/${APP_NAME}_v9_fixed_export.log" | grep -A3 "error:"
        return 1
    fi
    
    echo "   ✅ Exported"
    
    # Find IPA
    IPA_FILE=$(find "build/exports_v9_fixed/${APP_NAME}" -name "*.ipa" | head -1)
    
    if [ ! -f "$IPA_FILE" ]; then
        echo "   ❌ IPA not found"
        return 1
    fi
    
    echo "   📦 IPA: $(du -h "$IPA_FILE" | cut -f1)"
    
    # Upload
    echo "   [3/3] Uploading to TestFlight..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_FILE" \
        --apiKey "$API_KEY" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "build/logs/${APP_NAME}_v9_fixed_upload.log"
    
    UPLOAD_STATUS=${PIPESTATUS[0]}
    
    if [ $UPLOAD_STATUS -eq 0 ]; then
        echo ""
        echo "   ✅ UPLOADED TO TESTFLIGHT!"
        echo ""
        return 0
    else
        echo ""
        echo "   ❌ Upload failed"
        tail -20 "build/logs/${APP_NAME}_v9_fixed_upload.log" | grep -A5 "error:"
        echo ""
        return 1
    fi
}

# Deploy PersonalHealth
deploy_app \
    "PersonalHealth" \
    "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" \
    "PersonalHealthApp" \
    "$API_KEY_PH" \
    "🔴"
PH=$?

# Deploy Clinician
deploy_app \
    "Clinician" \
    "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" \
    "FoTClinicianApp" \
    "$API_KEY_CLINICIAN" \
    "🔵"
CLIN=$?

# Deploy Legal
deploy_app \
    "Legal" \
    "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" \
    "FoTLegalApp" \
    "$API_KEY_LEGAL" \
    "🟦"
LEG=$?

# Deploy Education
deploy_app \
    "Education" \
    "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" \
    "FoTEducationApp" \
    "$API_KEY_EDUCATION" \
    "🟢"
EDU=$?

# Deploy Parent
deploy_app \
    "Parent" \
    "apps/ParentApp/iOS/FoTParentApp.xcodeproj" \
    "FoTParentApp" \
    "$API_KEY_PARENT" \
    "🟣"
PAR=$?

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 FINAL RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SUCCESS=0
[ $PH -eq 0 ] && echo "✅ 🔴 PersonalHealth: UPLOADED" && SUCCESS=$((SUCCESS+1)) || echo "❌ 🔴 PersonalHealth: FAILED"
[ $CLIN -eq 0 ] && echo "✅ 🔵 Clinician: UPLOADED" && SUCCESS=$((SUCCESS+1)) || echo "❌ 🔵 Clinician: FAILED"
[ $LEG -eq 0 ] && echo "✅ 🟦 Legal: UPLOADED" && SUCCESS=$((SUCCESS+1)) || echo "❌ 🟦 Legal: FAILED"
[ $EDU -eq 0 ] && echo "✅ 🟢 Education: UPLOADED" && SUCCESS=$((SUCCESS+1)) || echo "❌ 🟢 Education: FAILED"
[ $PAR -eq 0 ] && echo "✅ 🟣 Parent: UPLOADED" && SUCCESS=$((SUCCESS+1)) || echo "❌ 🟣 Parent: FAILED"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $SUCCESS -eq 5 ]; then
    echo "🎉 PERFECT! ALL 5 APPS UPLOADED!"
    echo ""
    echo "Next: Submit response to Apple Review"
    echo "      from APPLE_REVIEW_RESPONSE.md"
elif [ $SUCCESS -gt 0 ]; then
    echo "⚠️  $SUCCESS/5 apps uploaded successfully"
else
    echo "❌ All builds failed - check errors above"
fi

