#!/bin/bash
#
# Rebuild ALL apps and upload to TestFlight automatically
# NO MANUAL STEPS REQUIRED
#

set -e

PROJECT_DIR="/Users/richardgillespie/Documents/FoTApple"
cd "$PROJECT_DIR"

# API Configuration
API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"
API_KEY_PATH="$PROJECT_DIR/AuthKey_43BGN9JC5B.p8"

echo "🚀 AUTOMATIC APP REBUILD AND UPLOAD"
echo "===================================="
echo ""
echo "Building and uploading ALL 5 apps to TestFlight..."
echo ""

# Apps to build
declare -a APPS=(
    "PersonalHealthApp:apps/PersonalHealthApp/iOS/PersonalHealth.xcodeproj:PersonalHealth"
    "FoTLegalApp:apps/LegalApp/iOS/FoTLegal.xcodeproj:Legal"
    "FoTClinicianApp:apps/ClinicianApp/iOS/FoTClinician.xcodeproj:Clinician"
    "FoTEducationApp:apps/EducationApp/iOS/FoTEducation.xcodeproj:Education"
    "FoTParentApp:apps/ParentApp/iOS/FoTParent.xcodeproj:Parent"
)

SUCCESS_COUNT=0
FAIL_COUNT=0

for APP_INFO in "${APPS[@]}"; do
    IFS=':' read -r APP_NAME PROJECT_PATH SCHEME <<< "$APP_INFO"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 Building: $APP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    ARCHIVE_PATH="$PROJECT_DIR/build/archives/${SCHEME}_iOS.xcarchive"
    EXPORT_PATH="$PROJECT_DIR/build/exports/${SCHEME}_iOS"
    
    # Clean previous builds
    rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
    mkdir -p "$(dirname "$ARCHIVE_PATH")" "$EXPORT_PATH"
    
    # Build archive
    echo "  Building archive..."
    if xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$APP_NAME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -sdk iphoneos \
        -destination "generic/platform=iOS" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        > "$PROJECT_DIR/build/logs/${SCHEME}_build.log" 2>&1; then
        
        echo "  ✅ Archive complete"
        
        # Export IPA
        echo "  Exporting IPA..."
        
        # Create export options
        cat > /tmp/ExportOptions_${SCHEME}.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>teamID</key>
    <string>T3Y6U38M9K</string>
    <key>provisioningProfiles</key>
    <dict/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
</dict>
</plist>
EOF
        
        if xcodebuild -exportArchive \
            -archivePath "$ARCHIVE_PATH" \
            -exportPath "$EXPORT_PATH" \
            -exportOptionsPlist /tmp/ExportOptions_${SCHEME}.plist \
            > "$PROJECT_DIR/build/logs/${SCHEME}_export.log" 2>&1; then
            
            echo "  ✅ Export complete"
            
            # Find the IPA
            IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -1)
            
            if [ -f "$IPA_FILE" ]; then
                echo "  Uploading to TestFlight..."
                
                # Upload to App Store Connect
                if xcrun altool --upload-app \
                    --type ios \
                    --file "$IPA_FILE" \
                    --apiKey "$API_KEY_ID" \
                    --apiIssuer "$API_ISSUER_ID" \
                    > "$PROJECT_DIR/build/logs/${SCHEME}_upload.log" 2>&1; then
                    
                    echo "  ✅ UPLOAD SUCCESSFUL: $APP_NAME"
                    ((SUCCESS_COUNT++))
                else
                    echo "  ❌ Upload failed: $APP_NAME"
                    echo "     Check: build/logs/${SCHEME}_upload.log"
                    ((FAIL_COUNT++))
                fi
            else
                echo "  ❌ No IPA found in export"
                ((FAIL_COUNT++))
            fi
        else
            echo "  ❌ Export failed"
            echo "     Check: build/logs/${SCHEME}_export.log"
            ((FAIL_COUNT++))
        fi
    else
        echo "  ❌ Build failed"
        echo "     Check: build/logs/${SCHEME}_build.log"
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 FINAL RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✅ Successful uploads: $SUCCESS_COUNT"
echo "  ❌ Failed uploads: $FAIL_COUNT"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "🎉 $SUCCESS_COUNT app(s) successfully uploaded to TestFlight!"
    echo ""
    echo "Next steps:"
    echo "  1. Go to App Store Connect"
    echo "  2. Wait ~15 minutes for processing"
    echo "  3. Submit for review"
fi

if [ $FAIL_COUNT -gt 0 ]; then
    echo "⚠️  $FAIL_COUNT app(s) failed - check logs in build/logs/"
fi

echo ""
echo "✅ AUTOMATIC DEPLOYMENT COMPLETE"

