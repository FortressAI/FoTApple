#!/bin/bash
################################################################################
# FULLY AUTOMATED TESTFLIGHT DEPLOYMENT SCRIPT
# No human interaction required after initial setup
################################################################################

set -e
set -o pipefail

################################################################################
# CONFIGURATION
################################################################################

TEAM_ID="WWQQB728U5"

# API Credentials - Set these via environment variables or hardcode
API_KEY_ID="${APP_STORE_API_KEY_ID:-YOUR_KEY_ID}"
API_ISSUER_ID="${APP_STORE_API_ISSUER_ID:-YOUR_ISSUER_ID}"

# Validate API credentials are set
if [[ "$API_KEY_ID" == "YOUR_KEY_ID" ]] || [[ "$API_ISSUER_ID" == "YOUR_ISSUER_ID" ]]; then
    echo "❌ ERROR: API credentials not configured!"
    echo ""
    echo "Set environment variables:"
    echo "  export APP_STORE_API_KEY_ID='your_key_id'"
    echo "  export APP_STORE_API_ISSUER_ID='your_issuer_id'"
    echo ""
    echo "Or edit this script to hardcode them."
    exit 1
fi

# Verify .p8 key file exists
P8_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8"
if [ ! -f "$P8_KEY_PATH" ]; then
    echo "❌ ERROR: API key file not found!"
    echo "Expected location: $P8_KEY_PATH"
    echo ""
    echo "Download your .p8 file from App Store Connect and run:"
    echo "  mkdir -p ~/.appstoreconnect/private_keys/"
    echo "  mv /path/to/AuthKey_${API_KEY_ID}.p8 ~/.appstoreconnect/private_keys/"
    exit 1
fi

# Build settings
BUILD_DIR="build"
LOG_DIR="$BUILD_DIR/logs"
EXPORT_DIR="$BUILD_DIR/export"
ARCHIVE_DIR="$BUILD_DIR/archives"

# Retry settings
MAX_UPLOAD_RETRIES=3
RETRY_DELAY=10

# App configurations
declare -a APPS=(
    "PersonalHealthApp:PersonalHealthApp:com.fot.PersonalHealth"
    "ClinicianApp:FoTClinicianApp:com.fot.ClinicianApp"
    "ParentApp:FoTParentApp:com.fot.ParentApp"
    "EducationApp:FoTEducationApp:com.fot.EducationApp"
    "LegalApp:FoTLegalApp:com.fot.LegalApp"
)

################################################################################
# SETUP
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 AUTOMATED TESTFLIGHT DEPLOYMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Team ID: $TEAM_ID"
echo "API Key: $API_KEY_ID"
echo "Apps to deploy: ${#APPS[@]}"
echo ""

# Create directories
mkdir -p "$LOG_DIR" "$EXPORT_DIR" "$ARCHIVE_DIR"

# Deployment tracking
SUCCESS=0
FAILED=0
declare -a FAILED_APPS=()
declare -a SUCCESS_APPS=()

START_TIME=$(date +%s)

################################################################################
# HELPER FUNCTIONS
################################################################################

# Auto-increment build number
auto_increment_build() {
    local plist_path="$1"
    
    if [ -f "$plist_path" ]; then
        # Get current build number
        current_build=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$plist_path" 2>/dev/null || echo "1")
        
        # Increment
        new_build=$((current_build + 1))
        
        # Update plist
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_build" "$plist_path"
        
        echo "  Build number: $current_build → $new_build"
        return 0
    else
        echo "  ⚠️  Could not find Info.plist at: $plist_path"
        return 1
    fi
}

# Retry function with exponential backoff
retry_command() {
    local max_attempts=$1
    shift
    local command=("$@")
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if "${command[@]}"; then
            return 0
        else
            if [ $attempt -lt $max_attempts ]; then
                local wait_time=$((RETRY_DELAY * attempt))
                echo "  ⚠️  Attempt $attempt failed. Retrying in ${wait_time}s..."
                sleep $wait_time
                ((attempt++))
            else
                echo "  ❌ All $max_attempts attempts failed"
                return 1
            fi
        fi
    done
}

################################################################################
# MAIN DEPLOYMENT LOOP
################################################################################

for app_config in "${APPS[@]}"; do
    IFS=':' read -r dir scheme bundle_id <<< "$app_config"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Deploying: $scheme"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Bundle ID: $bundle_id"
    echo "Directory: apps/$dir/iOS"
    echo ""
    
    APP_START=$(date +%s)
    
    # Navigate to app directory
    if [ ! -d "apps/$dir/iOS" ]; then
        echo "❌ Directory not found: apps/$dir/iOS"
        FAILED=$((FAILED + 1))
        FAILED_APPS+=("$scheme (directory not found)")
        continue
    fi
    
    cd "apps/$dir/iOS"
    
    # Find Info.plist and auto-increment build number
    echo "▶ Incrementing build number..."
    INFO_PLIST="$scheme/Info.plist"
    if [ -f "$INFO_PLIST" ]; then
        auto_increment_build "$INFO_PLIST"
    else
        echo "  ⚠️  Info.plist not found, skipping build increment"
    fi
    
    # Clean any previous builds
    echo ""
    echo "▶ Cleaning previous builds..."
    xcodebuild clean \
        -project "$scheme.xcodeproj" \
        -scheme "$scheme" \
        -configuration Release \
        > /dev/null 2>&1 || true
    
    # Archive
    echo ""
    echo "▶ Creating archive..."
    ARCHIVE_PATH="../../../$ARCHIVE_DIR/$scheme.xcarchive"
    
    if xcodebuild archive \
        -project "$scheme.xcodeproj" \
        -scheme "$scheme" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -destination "generic/platform=iOS" \
        -allowProvisioningUpdates \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        > "../../../$LOG_DIR/${scheme}_archive.log" 2>&1; then
        
        echo "  ✅ Archive created successfully"
        
        # Create ExportOptions.plist
        echo ""
        echo "▶ Creating export options..."
        
        EXPORT_OPTIONS="../../../$BUILD_DIR/ExportOptions_${scheme}.plist"
        
        cat > "$EXPORT_OPTIONS" <<EOF
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
    
    <key>compileBitcode</key>
    <false/>
    
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
    
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
        
        echo "  ✅ Export options configured"
        
        # Export and Upload with retry
        echo ""
        echo "▶ Exporting and uploading to TestFlight..."
        echo "  (This may take several minutes...)"
        
        if retry_command $MAX_UPLOAD_RETRIES \
            xcodebuild -exportArchive \
                -archivePath "$ARCHIVE_PATH" \
                -exportPath "../../../$EXPORT_DIR/$scheme" \
                -exportOptionsPlist "$EXPORT_OPTIONS" \
                -allowProvisioningUpdates \
                > "../../../$LOG_DIR/${scheme}_export.log" 2>&1; then
            
            APP_END=$(date +%s)
            APP_DURATION=$((APP_END - APP_START))
            
            echo "  ✅ Successfully uploaded to TestFlight!"
            echo "  ⏱️  Time taken: ${APP_DURATION}s"
            SUCCESS=$((SUCCESS + 1))
            SUCCESS_APPS+=("$scheme")
        else
            echo "  ❌ Export/Upload failed after $MAX_UPLOAD_RETRIES attempts"
            echo "  📋 Check log: $LOG_DIR/${scheme}_export.log"
            FAILED=$((FAILED + 1))
            FAILED_APPS+=("$scheme (upload failed)")
        fi
    else
        echo "  ❌ Archive creation failed"
        echo "  📋 Check log: $LOG_DIR/${scheme}_archive.log"
        FAILED=$((FAILED + 1))
        FAILED_APPS+=("$scheme (archive failed)")
    fi
    
    cd ../../..
done

################################################################################
# FINAL REPORT
################################################################################

END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_DURATION / 60))
SECONDS=$((TOTAL_DURATION % 60))

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 DEPLOYMENT SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Completed: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Total time: ${MINUTES}m ${SECONDS}s"
echo ""
echo "Results:"
echo "  ✅ Successful: $SUCCESS"
echo "  ❌ Failed: $FAILED"
echo ""

if [ ${#SUCCESS_APPS[@]} -gt 0 ]; then
    echo "✅ Successfully deployed:"
    for app in "${SUCCESS_APPS[@]}"; do
        echo "   • $app"
    done
    echo ""
fi

if [ ${#FAILED_APPS[@]} -gt 0 ]; then
    echo "❌ Failed deployments:"
    for app in "${FAILED_APPS[@]}"; do
        echo "   • $app"
    done
    echo ""
    echo "📋 Check logs in: $LOG_DIR/"
    echo ""
fi

if [ $SUCCESS -eq 5 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 SUCCESS! All 5 apps deployed to TestFlight!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Next steps:"
    echo "  1. Check build processing:"
    echo "     https://appstoreconnect.apple.com/apps"
    echo ""
    echo "  2. Builds typically process in 5-15 minutes"
    echo ""
    echo "  3. Once processed, add to test groups:"
    echo "     App Store Connect → TestFlight → Select App → Testing"
    echo ""
    exit 0
elif [ $SUCCESS -gt 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  PARTIAL SUCCESS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Review failed deployments and retry if needed."
    echo ""
    exit 1
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ ALL DEPLOYMENTS FAILED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Common issues:"
    echo "  • Check API credentials are correct"
    echo "  • Verify .p8 key file exists at: $P8_KEY_PATH"
    echo "  • Ensure all apps are registered in App Store Connect"
    echo "  • Check network connectivity"
    echo "  • Review logs in: $LOG_DIR/"
    echo ""
    exit 1
fi
