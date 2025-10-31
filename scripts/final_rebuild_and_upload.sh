#!/bin/bash

set -e

echo "🚀 FINAL REBUILD & UPLOAD - ALL 5 APPS"
echo "All fixes applied:"
echo "  ✅ Icon configurations fixed (120x120)"
echo "  ✅ Alpha channels removed"
echo "  ✅ WatchKit Info.plist fixed"
echo "======================================="
echo ""

cd "$(dirname "$0")/.."
mkdir -p build/{logs,archives,exports}

# API credentials
API_KEY_ID="706IRVGBDV3B"
ISSUER_ID="69a6de95-fd71-47e3-e053-5b8c7c11a4d1"
TEAM_ID="WWQQB728U5"

# Function to rebuild and upload an app
rebuild_and_upload() {
    local APP_NAME=$1
    local PROJECT_PATH=$2
    local SCHEME=$3
    
    echo "🔨 Rebuilding $APP_NAME..."
    
    # Clean and archive
    xcodebuild clean archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -sdk iphoneos \
        -configuration Release \
        -archivePath "build/archives/${APP_NAME}_v13_final.xcarchive" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM=$TEAM_ID \
        > "build/logs/${APP_NAME}_final_rebuild.log" 2>&1 && \
    echo "✅ $APP_NAME archived" || { echo "❌ $APP_NAME archive failed"; tail -15 "build/logs/${APP_NAME}_final_rebuild.log"; return 1; }
    
    echo "📦 Exporting $APP_NAME..."
    
    # Create export options
    cat > "build/exports/${APP_NAME}_export_options.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

    # Export
    xcodebuild -exportArchive \
        -archivePath "build/archives/${APP_NAME}_v13_final.xcarchive" \
        -exportPath "build/exports/${APP_NAME}_v13_final" \
        -exportOptionsPlist "build/exports/${APP_NAME}_export_options.plist" \
        -allowProvisioningUpdates \
        > "build/logs/${APP_NAME}_final_export.log" 2>&1 && \
    echo "✅ $APP_NAME exported" || { echo "⚠️  $APP_NAME export issue"; tail -10 "build/logs/${APP_NAME}_final_export.log"; }
    
    # Find IPA
    IPA_FILE=$(find "build/exports/${APP_NAME}_v13_final" -name "*.ipa" 2>/dev/null | head -1)
    
    if [ -z "$IPA_FILE" ]; then
        echo "⚠️  No IPA found, skipping upload"
        return 1
    fi
    
    echo "📤 Uploading $APP_NAME to App Store Connect..."
    
    # Upload
    xcrun altool --upload-package "$IPA_FILE" \
        --type ios \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$ISSUER_ID" \
        2>&1 | tee "build/logs/${APP_NAME}_final_upload.log"
    
    if grep -q "No errors uploading" "build/logs/${APP_NAME}_final_upload.log" || grep -q "successfully uploaded" "build/logs/${APP_NAME}_final_upload.log"; then
        echo "✅ $APP_NAME UPLOADED SUCCESSFULLY!"
        return 0
    else
        echo "⚠️  $APP_NAME upload had issues, check log"
        return 1
    fi
}

# Process all 5 apps
echo "======================================="
echo "PROCESSING ALL 5 APPS"
echo "======================================="
echo ""

SUCCESS_COUNT=0
APPS_SUCCESS=()
APPS_FAILED=()

# PersonalHealth
if rebuild_and_upload "PersonalHealthApp" "apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj" "PersonalHealthApp"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    APPS_SUCCESS+=("PersonalHealthApp")
else
    APPS_FAILED+=("PersonalHealthApp")
fi
echo ""

# Clinician
if rebuild_and_upload "FoTClinicianApp" "apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj" "FoTClinicianApp"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    APPS_SUCCESS+=("FoTClinicianApp")
else
    APPS_FAILED+=("FoTClinicianApp")
fi
echo ""

# Legal
if rebuild_and_upload "FoTLegalApp" "apps/LegalApp/iOS/FoTLegalApp.xcodeproj" "FoTLegalApp"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    APPS_SUCCESS+=("FoTLegalApp")
else
    APPS_FAILED+=("FoTLegalApp")
fi
echo ""

# Education
if rebuild_and_upload "FoTEducationApp" "apps/EducationApp/iOS/FoTEducationApp.xcodeproj" "FoTEducationApp"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    APPS_SUCCESS+=("FoTEducationApp")
else
    APPS_FAILED+=("FoTEducationApp")
fi
echo ""

# Parent
if rebuild_and_upload "FoTParentApp" "apps/ParentApp/iOS/FoTParentApp.xcodeproj" "FoTParentApp"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    APPS_SUCCESS+=("FoTParentApp")
else
    APPS_FAILED+=("FoTParentApp")
fi
echo ""

# Final report
echo "======================================="
echo "🎯 FINAL RESULTS"
echo "======================================="
echo ""
echo "✅ Successfully uploaded: $SUCCESS_COUNT/5"
if [ ${#APPS_SUCCESS[@]} -gt 0 ]; then
    for app in "${APPS_SUCCESS[@]}"; do
        echo "  ✅ $app"
    done
fi
echo ""
if [ ${#APPS_FAILED[@]} -gt 0 ]; then
    echo "❌ Failed/Skipped: ${#APPS_FAILED[@]}/5"
    for app in "${APPS_FAILED[@]}"; do
        echo "  ❌ $app"
    done
    echo ""
fi

if [ $SUCCESS_COUNT -eq 5 ]; then
    echo "🎉🎉🎉 ALL 5 APPS UPLOADED TO APP STORE CONNECT! 🎉🎉🎉"
    echo ""
    echo "Apps will appear in TestFlight within 5-10 minutes"
    exit 0
else
    echo "⚠️  Some apps need attention. Check logs in build/logs/"
    exit 1
fi

