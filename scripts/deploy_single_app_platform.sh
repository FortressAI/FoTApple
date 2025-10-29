#!/bin/bash
################################################################################
# SINGLE APP/PLATFORM TESTFLIGHT DEPLOYMENT
# Deploy one app for one specific platform to TestFlight
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
API_KEY_ID="${APP_STORE_API_KEY_ID:-43BGN9JC5B}"
API_ISSUER_ID="${APP_STORE_API_ISSUER_ID:-69a6de92-4ce0-47e3-e053-5b8c7c11a4d1}"

################################################################################
# ARGUMENT PARSING
################################################################################

if [ $# -lt 2 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Deploy Single App/Platform to TestFlight"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Usage: $0 <app_name> <platform>"
    echo ""
    echo "Available apps:"
    echo "  • PersonalHealthApp"
    echo "  • ClinicianApp"
    echo "  • ParentApp"
    echo "  • EducationApp"
    echo "  • LegalApp"
    echo ""
    echo "Available platforms:"
    echo "  • iOS"
    echo "  • macOS"
    echo "  • watchOS"
    echo "  • visionOS"
    echo ""
    echo "Examples:"
    echo "  $0 PersonalHealthApp iOS"
    echo "  $0 ClinicianApp macOS"
    echo "  $0 ClinicianApp watchOS"
    echo ""
    exit 1
fi

APP_NAME=$1
PLATFORM=$2

# Validate platform
if ! validate_platform "$PLATFORM"; then
    echo "❌ Invalid platform: $PLATFORM"
    echo "Valid platforms: iOS, macOS, watchOS, visionOS"
    exit 1
fi

# Get app configuration
APP_DIR=$(get_app_directory "$APP_NAME")
SCHEME=$(get_app_scheme "$APP_NAME" "$PLATFORM")
BUNDLE_ID=$(get_app_bundle_id "$APP_NAME" "$PLATFORM")
PLATFORM_DIR=$(get_platform_dir "$PLATFORM")
SDK=$(get_platform_sdk "$PLATFORM")
DESTINATION=$(get_platform_destination "$PLATFORM")

# Validate configuration
if [ -z "$APP_DIR" ] || [ -z "$SCHEME" ] || [ -z "$BUNDLE_ID" ]; then
    echo "❌ ERROR: Could not find configuration for $APP_NAME/$PLATFORM"
    echo ""
    echo "Check that:"
    echo "  1. App name is correct"
    echo "  2. Platform is supported for this app"
    echo "  3. Platform matrix is properly configured"
    exit 1
fi

# Check platform support
if ! check_platform_support "$APP_DIR" "$PLATFORM"; then
    echo "❌ ERROR: Platform $PLATFORM is not available for $APP_NAME"
    echo "   Directory not found: apps/$APP_DIR/$PLATFORM_DIR"
    exit 1
fi

# Validate API credentials
if [[ "$API_KEY_ID" == "YOUR_KEY_ID" ]] || [[ "$API_ISSUER_ID" == "YOUR_ISSUER_ID" ]]; then
    echo "❌ ERROR: API credentials not configured!"
    echo ""
    echo "Set environment variables:"
    echo "  export APP_STORE_API_KEY_ID='your_key_id'"
    echo "  export APP_STORE_API_ISSUER_ID='your_issuer_id'"
    exit 1
fi

# Verify .p8 key file
P8_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${API_KEY_ID}.p8"
if [ ! -f "$P8_KEY_PATH" ]; then
    echo "❌ ERROR: API key file not found at: $P8_KEY_PATH"
    exit 1
fi

################################################################################
# SETUP
################################################################################

BUILD_DIR="build"
LOG_DIR="$BUILD_DIR/logs"
EXPORT_DIR="$BUILD_DIR/export"
ARCHIVE_DIR="$BUILD_DIR/archives"

mkdir -p "$LOG_DIR" "$EXPORT_DIR" "$ARCHIVE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Deploying: $APP_NAME ($PLATFORM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Scheme: $SCHEME"
echo "Bundle ID: $BUNDLE_ID"
echo "Directory: apps/$APP_DIR/$PLATFORM_DIR"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

START_TIME=$(date +%s)

################################################################################
# DEPLOYMENT
################################################################################

cd "apps/$APP_DIR/$PLATFORM_DIR"

# Auto-increment build
echo "▶ Incrementing build number..."
INFO_PLIST="$SCHEME/Info.plist"
if [ ! -f "$INFO_PLIST" ]; then
    # Try alternative locations - look in scheme subdirectory
    INFO_PLIST=$(find . -name "Info.plist" -path "*/$SCHEME/*" | head -1)
    if [ -z "$INFO_PLIST" ]; then
        # Try finding any Info.plist in current directory structure
        INFO_PLIST=$(find . -maxdepth 3 -name "Info.plist" -not -path "*/.build/*" -not -path "*/DerivedData/*" | head -1)
    fi
fi

if [ -f "$INFO_PLIST" ]; then
    CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST" 2>/dev/null || echo "1")
    NEW_BUILD=$((CURRENT_BUILD + 1))
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$INFO_PLIST"
    echo "  Build: $CURRENT_BUILD → $NEW_BUILD"
else
    echo "  ⚠️  Info.plist not found"
fi

# Clean
echo ""
echo "▶ Cleaning..."
PROJECT_FILE=""
if [ -f "$SCHEME.xcodeproj/project.pbxproj" ]; then
    PROJECT_FILE="$SCHEME.xcodeproj"
elif [ -f "$SCHEME.xcworkspace/contents.xcworkspacedata" ]; then
    PROJECT_FILE="$SCHEME.xcworkspace"
else
    echo "❌ Project file not found for $SCHEME"
    exit 1
fi

if [[ "$PROJECT_FILE" == *.xcworkspace ]]; then
    xcodebuild clean -workspace "$PROJECT_FILE" -scheme "$SCHEME" -configuration Release > /dev/null 2>&1 || true
else
    xcodebuild clean -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration Release > /dev/null 2>&1 || true
fi

# Archive
echo ""
echo "▶ Creating archive..."
ARCHIVE_PATH="../../../$ARCHIVE_DIR/${SCHEME}_${PLATFORM}.xcarchive"

ARCHIVE_CMD=()
if [[ "$PROJECT_FILE" == *.xcworkspace ]]; then
    ARCHIVE_CMD=(xcodebuild archive -workspace "$PROJECT_FILE")
else
    ARCHIVE_CMD=(xcodebuild archive -project "$PROJECT_FILE")
fi

ARCHIVE_CMD+=(
    -scheme "$SCHEME"
    -configuration Release
    -archivePath "$ARCHIVE_PATH"
    -destination "$DESTINATION"
    -sdk "$SDK"
    -allowProvisioningUpdates
    DEVELOPMENT_TEAM="$TEAM_ID"
)

if "${ARCHIVE_CMD[@]}" > "../../../$LOG_DIR/${SCHEME}_${PLATFORM}_archive.log" 2>&1; then
    
    echo "  ✅ Archive created"
    
    # Create ExportOptions
    echo ""
    echo "▶ Configuring export..."
    
    EXPORT_OPTIONS="../../../$BUILD_DIR/ExportOptions_${SCHEME}_${PLATFORM}.plist"
    
    create_export_options_plist "$EXPORT_OPTIONS" "$PLATFORM" "$TEAM_ID" "$API_ISSUER_ID" "$API_KEY_ID"
    
    # Export and Upload
    echo ""
    if [ "$PLATFORM" = "watchOS" ]; then
        echo "▶ Exporting IPA (watchOS requires separate upload)..."
    else
        echo "▶ Uploading to TestFlight..."
        echo "  (This may take several minutes...)"
    fi
    
    if xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "../../../$EXPORT_DIR/${SCHEME}_${PLATFORM}" \
        -exportOptionsPlist "$EXPORT_OPTIONS" \
        -allowProvisioningUpdates \
        > "../../../$LOG_DIR/${SCHEME}_${PLATFORM}_export.log" 2>&1; then
        
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        MINUTES=$((DURATION / 60))
        SECONDS=$((DURATION % 60))
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ SUCCESS!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "App: $APP_NAME"
        echo "Platform: $PLATFORM"
        echo "Time: ${MINUTES}m ${SECONDS}s"
        echo "Completed: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "Next steps:"
        echo "  1. Build will process in 5-15 minutes"
        echo "  2. Check: https://appstoreconnect.apple.com/apps"
        echo "  3. Add to test groups in TestFlight tab"
        echo ""
        exit 0
    else
        echo ""
        echo "❌ Upload failed"
        echo "Check log: $LOG_DIR/${SCHEME}_${PLATFORM}_export.log"
        exit 1
    fi
else
    echo ""
    echo "❌ Archive failed"
    echo "Check log: $LOG_DIR/${SCHEME}_${PLATFORM}_archive.log"
    exit 1
fi

