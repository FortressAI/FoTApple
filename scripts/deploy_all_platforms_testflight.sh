#!/bin/bash
################################################################################
# MULTI-PLATFORM TESTFLIGHT DEPLOYMENT SCRIPT
# Deploys all 5 apps across all available platforms (iOS, macOS, watchOS, visionOS)
# No human interaction required after initial setup
################################################################################

set -e
set -o pipefail

# Source platform helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/platform_helpers.sh"

################################################################################
# CONFIGURATION
################################################################################

TEAM_ID="WWQQB728U5"

# API Credentials - Set these via environment variables or hardcode
API_KEY_ID="${APP_STORE_API_KEY_ID:-43BGN9JC5B}"
API_ISSUER_ID="${APP_STORE_API_ISSUER_ID:-69a6de92-4ce0-47e3-e053-5b8c7c11a4d1}"

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

# App list from platform matrix
declare -a APP_NAMES=(
    "PersonalHealthApp"
    "ClinicianApp"
    "ParentApp"
    "EducationApp"
    "LegalApp"
)

################################################################################
# SETUP
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 MULTI-PLATFORM TESTFLIGHT DEPLOYMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Team ID: $TEAM_ID"
echo "API Key: $API_KEY_ID"
echo "Apps: ${#APP_NAMES[@]}"
echo ""

# Create directories
mkdir -p "$LOG_DIR" "$EXPORT_DIR" "$ARCHIVE_DIR"

# Deployment tracking
SUCCESS=0
FAILED=0
declare -a FAILED_DEPLOYMENTS=()
declare -a SUCCESS_DEPLOYMENTS=()

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

for app_name in "${APP_NAMES[@]}"; do
    # Get app directory from matrix
    app_dir=$(get_app_directory "$app_name")
    
    if [ -z "$app_dir" ]; then
        echo "⚠️  Skipping $app_name: directory not found in matrix"
        continue
    fi
    
    # Get platforms for this app
    platforms=$(get_app_platforms "$app_name")
    
    if [ -z "$platforms" ]; then
        echo "⚠️  Skipping $app_name: no platforms configured"
        continue
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 App: $app_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Deploy for each platform
    while IFS= read -r platform; do
        [ -z "$platform" ] && continue
        
        # Validate platform
        if ! validate_platform "$platform"; then
            echo "⚠️  Invalid platform: $platform, skipping"
            continue
        fi
        
        # Check if platform is supported
        if ! check_platform_support "$app_dir" "$platform"; then
            echo "⚠️  Platform $platform not available for $app_name, skipping"
            continue
        fi
        
        # Get platform-specific configuration
        scheme=$(get_app_scheme "$app_name" "$platform")
        bundle_id=$(get_app_bundle_id "$app_name" "$platform")
        platform_dir=$(get_platform_dir "$platform")
        sdk=$(get_platform_sdk "$platform")
        destination=$(get_platform_destination "$platform")
        
        if [ -z "$scheme" ] || [ -z "$bundle_id" ]; then
            echo "⚠️  Missing configuration for $app_name/$platform, skipping"
            continue
        fi
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📱 Platform: $platform"
        echo "   Scheme: $scheme"
        echo "   Bundle ID: $bundle_id"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        DEPLOYMENT_START=$(date +%s)
        
        # Navigate to platform directory
        project_path="apps/$app_dir/$platform_dir"
        
        if [ ! -d "$project_path" ]; then
            echo "❌ Directory not found: $project_path"
            FAILED=$((FAILED + 1))
            FAILED_DEPLOYMENTS+=("$app_name/$platform (directory not found)")
            continue
        fi
        
        cd "$project_path"
        
        # Find Info.plist and auto-increment build number
        echo "▶ Incrementing build number..."
        INFO_PLIST="$scheme/Info.plist"
        if [ ! -f "$INFO_PLIST" ]; then
            # Try alternative locations - look in scheme subdirectory
            INFO_PLIST=$(find . -name "Info.plist" -path "*/$scheme/*" | head -1)
            if [ -z "$INFO_PLIST" ]; then
                # Try finding any Info.plist in current directory structure
                INFO_PLIST=$(find . -maxdepth 3 -name "Info.plist" -not -path "*/.build/*" -not -path "*/DerivedData/*" | head -1)
            fi
        fi
        
        if [ -f "$INFO_PLIST" ]; then
            auto_increment_build "$INFO_PLIST"
        else
            echo "  ⚠️  Info.plist not found, skipping build increment"
        fi
        
        # Find project file
        PROJECT_FILE=""
        if [ -f "$scheme.xcodeproj/project.pbxproj" ]; then
            PROJECT_FILE="$scheme.xcodeproj"
        elif [ -f "$scheme.xcworkspace/contents.xcworkspacedata" ]; then
            # Workspace requires different handling
            echo "  ⚠️  Workspace detected: $scheme.xcworkspace"
            PROJECT_FILE="$scheme.xcworkspace"
        else
            echo "❌ Project file not found for $scheme"
            FAILED=$((FAILED + 1))
            FAILED_DEPLOYMENTS+=("$app_name/$platform (project not found)")
            cd ../../..
            continue
        fi
        
        # Clean any previous builds
        echo ""
        echo "▶ Cleaning previous builds..."
        if [[ "$PROJECT_FILE" == *.xcworkspace ]]; then
            xcodebuild clean \
                -workspace "$PROJECT_FILE" \
                -scheme "$scheme" \
                -configuration Release \
                > /dev/null 2>&1 || true
        else
            xcodebuild clean \
                -project "$PROJECT_FILE" \
                -scheme "$scheme" \
                -configuration Release \
                > /dev/null 2>&1 || true
        fi
        
        # Archive
        echo ""
        echo "▶ Creating archive..."
        ARCHIVE_PATH="../../../$ARCHIVE_DIR/${scheme}_${platform}.xcarchive"
        
        ARCHIVE_CMD=()
        if [[ "$PROJECT_FILE" == *.xcworkspace ]]; then
            ARCHIVE_CMD=(xcodebuild archive -workspace "$PROJECT_FILE")
        else
            ARCHIVE_CMD=(xcodebuild archive -project "$PROJECT_FILE")
        fi
        
        ARCHIVE_CMD+=(
            -scheme "$scheme"
            -configuration Release
            -archivePath "$ARCHIVE_PATH"
            -destination "$destination"
            -sdk "$sdk"
            -allowProvisioningUpdates
            DEVELOPMENT_TEAM="$TEAM_ID"
        )
        
        if "${ARCHIVE_CMD[@]}" > "../../../$LOG_DIR/${scheme}_${platform}_archive.log" 2>&1; then
            
            echo "  ✅ Archive created successfully"
            
            # Create ExportOptions.plist
            echo ""
            echo "▶ Creating export options..."
            
            EXPORT_OPTIONS="../../../$BUILD_DIR/ExportOptions_${scheme}_${platform}.plist"
            
            create_export_options_plist "$EXPORT_OPTIONS" "$platform" "$TEAM_ID" "$API_ISSUER_ID" "$API_KEY_ID"
            
            echo "  ✅ Export options configured"
            
            # Export and Upload with retry
            echo ""
            echo "▶ Exporting and uploading to TestFlight..."
            echo "  (This may take several minutes...)"
            
            if retry_command $MAX_UPLOAD_RETRIES \
                xcodebuild -exportArchive \
                    -archivePath "$ARCHIVE_PATH" \
                    -exportPath "../../../$EXPORT_DIR/${scheme}_${platform}" \
                    -exportOptionsPlist "$EXPORT_OPTIONS" \
                    -allowProvisioningUpdates \
                    > "../../../$LOG_DIR/${scheme}_${platform}_export.log" 2>&1; then
                
                DEPLOYMENT_END=$(date +%s)
                DEPLOYMENT_DURATION=$((DEPLOYMENT_END - DEPLOYMENT_START))
                
                echo "  ✅ Successfully uploaded to TestFlight!"
                echo "  ⏱️  Time taken: ${DEPLOYMENT_DURATION}s"
                SUCCESS=$((SUCCESS + 1))
                SUCCESS_DEPLOYMENTS+=("$app_name/$platform")
            else
                echo "  ❌ Export/Upload failed after $MAX_UPLOAD_RETRIES attempts"
                echo "  📋 Check log: $LOG_DIR/${scheme}_${platform}_export.log"
                FAILED=$((FAILED + 1))
                FAILED_DEPLOYMENTS+=("$app_name/$platform (upload failed)")
            fi
        else
            echo "  ❌ Archive creation failed"
            echo "  📋 Check log: $LOG_DIR/${scheme}_${platform}_archive.log"
            FAILED=$((FAILED + 1))
            FAILED_DEPLOYMENTS+=("$app_name/$platform (archive failed)")
        fi
        
        cd ../../..
        
    done <<< "$platforms"
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

if [ ${#SUCCESS_DEPLOYMENTS[@]} -gt 0 ]; then
    echo "✅ Successfully deployed:"
    for deployment in "${SUCCESS_DEPLOYMENTS[@]}"; do
        echo "   • $deployment"
    done
    echo ""
fi

if [ ${#FAILED_DEPLOYMENTS[@]} -gt 0 ]; then
    echo "❌ Failed deployments:"
    for deployment in "${FAILED_DEPLOYMENTS[@]}"; do
        echo "   • $deployment"
    done
    echo ""
    echo "📋 Check logs in: $LOG_DIR/"
    echo ""
fi

TOTAL_EXPECTED=$((${#APP_NAMES[@]} * 4))  # Rough estimate, actual depends on available platforms
if [ $SUCCESS -gt 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 Deployment completed!"
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
    if [ $FAILED -gt 0 ]; then
        echo "  ⚠️  Some deployments failed - review logs and retry"
    fi
    exit 0
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

