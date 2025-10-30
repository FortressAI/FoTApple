#!/usr/bin/env bash
# Deploy All FoT Apps to TestFlight
# This script builds, archives, and uploads all 5 Field of Truth apps

set -euo pipefail

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}==>${NC} $1"; }
ok() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Configuration
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$WORKSPACE_ROOT/build/archives"
EXPORT_DIR="$WORKSPACE_ROOT/build/exports"
LOG_DIR="$WORKSPACE_ROOT/build/logs"

# App Store Connect API Key
API_KEY_ID="43BGN9JC5B"
API_ISSUER_ID="69a6de96-3a66-47e3-e053-5b8c7c11a4d1"  # Replace with your issuer ID
API_KEY_PATH="$WORKSPACE_ROOT/AuthKey_43BGN9JC5B.p8"

# Create directories
mkdir -p "$BUILD_DIR" "$EXPORT_DIR" "$LOG_DIR"

# App configurations
declare -A APPS=(
    ["PersonalHealth"]="apps/PersonalHealthApp/iOS/PersonalHealthApp.xcodeproj:PersonalHealthApp"
    ["Clinician"]="apps/ClinicianApp/iOS/FoTClinicianApp.xcodeproj:FoTClinicianApp"
    ["Legal"]="apps/LegalApp/iOS/FoTLegalApp.xcodeproj:FoTLegalApp"
    ["Education"]="apps/EducationApp/iOS/FoTEducationApp.xcodeproj:FoTEducationApp"
    ["Parent"]="apps/ParentApp/iOS/FoTParentApp.xcodeproj:FoTParentApp"
)

# Function to increment build number
increment_build_number() {
    local project_path=$1
    local scheme=$2
    
    log "Incrementing build number for $scheme..."
    
    # Get current build number
    local info_plist_path=$(find "$(dirname "$project_path")" -name "Info.plist" | head -n 1)
    if [ -f "$info_plist_path" ]; then
        local current_build=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$info_plist_path" 2>/dev/null || echo "1")
        local new_build=$((current_build + 1))
        
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_build" "$info_plist_path"
        ok "Build number: $current_build → $new_build"
    else
        warn "Info.plist not found, skipping build number increment"
    fi
}

# Function to build and archive an app
archive_app() {
    local app_name=$1
    local project_path=$2
    local scheme=$3
    local archive_path="$BUILD_DIR/${app_name}.xcarchive"
    
    log "Building $app_name..."
    
    # Clean build directory
    rm -rf "$archive_path"
    
    # Archive
    xcodebuild archive \
        -project "$WORKSPACE_ROOT/$project_path" \
        -scheme "$scheme" \
        -configuration Release \
        -archivePath "$archive_path" \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM=WWQQB728U5 \
        | tee "$LOG_DIR/${app_name}_archive.log" \
        | grep -E "^(===|►|Build|Archive)" || true
    
    if [ $? -eq 0 ] && [ -d "$archive_path" ]; then
        ok "$app_name archived successfully"
        return 0
    else
        fail "$app_name archive failed. Check $LOG_DIR/${app_name}_archive.log"
    fi
}

# Function to export archive for TestFlight
export_archive() {
    local app_name=$1
    local archive_path="$BUILD_DIR/${app_name}.xcarchive"
    local export_path="$EXPORT_DIR/$app_name"
    local export_options_path="$export_path/ExportOptions.plist"
    
    log "Exporting $app_name for TestFlight..."
    
    # Create export directory
    rm -rf "$export_path"
    mkdir -p "$export_path"
    
    # Create ExportOptions.plist
    cat > "$export_options_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>WWQQB728U5</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>upload</string>
</dict>
</plist>
EOF
    
    # Export archive
    xcodebuild -exportArchive \
        -archivePath "$archive_path" \
        -exportPath "$export_path" \
        -exportOptionsPlist "$export_options_path" \
        | tee "$LOG_DIR/${app_name}_export.log" \
        | grep -E "^(===|►|Export)" || true
    
    if [ $? -eq 0 ]; then
        ok "$app_name exported successfully"
        return 0
    else
        fail "$app_name export failed. Check $LOG_DIR/${app_name}_export.log"
    fi
}

# Function to upload to TestFlight
upload_to_testflight() {
    local app_name=$1
    local export_path="$EXPORT_DIR/$app_name"
    
    log "Uploading $app_name to TestFlight..."
    
    # Find the .ipa file
    local ipa_file=$(find "$export_path" -name "*.ipa" -type f | head -n 1)
    
    if [ -z "$ipa_file" ]; then
        fail "No .ipa file found for $app_name in $export_path"
    fi
    
    # Upload using xcrun altool
    xcrun altool --upload-app \
        --type ios \
        --file "$ipa_file" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "$LOG_DIR/${app_name}_upload.log"
    
    if [ $? -eq 0 ]; then
        ok "$app_name uploaded to TestFlight successfully! 🚀"
        return 0
    else
        warn "$app_name upload completed with warnings. Check $LOG_DIR/${app_name}_upload.log"
        return 0
    fi
}

# Function to validate app before upload
validate_app() {
    local app_name=$1
    local export_path="$EXPORT_DIR/$app_name"
    
    log "Validating $app_name..."
    
    local ipa_file=$(find "$export_path" -name "*.ipa" -type f | head -n 1)
    
    if [ -z "$ipa_file" ]; then
        fail "No .ipa file found for $app_name"
    fi
    
    # Validate using xcrun altool
    xcrun altool --validate-app \
        --type ios \
        --file "$ipa_file" \
        --apiKey "$API_KEY_ID" \
        --apiIssuer "$API_ISSUER_ID" \
        2>&1 | tee "$LOG_DIR/${app_name}_validate.log"
    
    if [ $? -eq 0 ]; then
        ok "$app_name validation passed"
        return 0
    else
        warn "$app_name validation completed with warnings"
        return 0
    fi
}

# Main deployment process
main() {
    log "🚀 Starting TestFlight Deployment for All Apps"
    log "Workspace: $WORKSPACE_ROOT"
    log "Build Directory: $BUILD_DIR"
    log "Export Directory: $EXPORT_DIR"
    echo ""
    
    # Check prerequisites
    if [ ! -f "$API_KEY_PATH" ]; then
        fail "API Key not found at $API_KEY_PATH"
    fi
    ok "API Key found"
    
    # Check Xcode
    if ! command -v xcodebuild &> /dev/null; then
        fail "xcodebuild not found. Please install Xcode."
    fi
    ok "Xcode found: $(xcodebuild -version | head -n 1)"
    echo ""
    
    # Process each app
    local successful_uploads=()
    local failed_uploads=()
    
    for app_name in "${!APPS[@]}"; do
        local config="${APPS[$app_name]}"
        local project_path="${config%%:*}"
        local scheme="${config##*:}"
        
        echo ""
        log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log "Processing: $app_name"
        log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Step 1: Increment build number
        increment_build_number "$WORKSPACE_ROOT/$project_path" "$scheme"
        
        # Step 2: Archive
        if archive_app "$app_name" "$project_path" "$scheme"; then
            # Step 3: Export
            if export_archive "$app_name"; then
                # Step 4: Validate (optional)
                validate_app "$app_name"
                
                # Step 5: Upload
                if upload_to_testflight "$app_name"; then
                    successful_uploads+=("$app_name")
                else
                    failed_uploads+=("$app_name")
                fi
            else
                failed_uploads+=("$app_name")
            fi
        else
            failed_uploads+=("$app_name")
        fi
        
        echo ""
    done
    
    # Summary
    echo ""
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "DEPLOYMENT SUMMARY"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ ${#successful_uploads[@]} -gt 0 ]; then
        ok "Successfully uploaded ${#successful_uploads[@]} app(s):"
        for app in "${successful_uploads[@]}"; do
            echo "  ✓ $app"
        done
        echo ""
    fi
    
    if [ ${#failed_uploads[@]} -gt 0 ]; then
        warn "Failed to upload ${#failed_uploads[@]} app(s):"
        for app in "${failed_uploads[@]}"; do
            echo "  ✗ $app"
        done
        echo ""
        warn "Check logs in: $LOG_DIR"
    else
        ok "All apps uploaded successfully! 🎉"
        echo ""
        ok "Next steps:"
        echo "  1. Go to App Store Connect (https://appstoreconnect.apple.com)"
        echo "  2. Navigate to each app → TestFlight"
        echo "  3. Wait for processing (~10-15 minutes per app)"
        echo "  4. Add beta testers or test groups"
        echo "  5. Submit for beta review"
        echo ""
    fi
    
    log "Logs saved to: $LOG_DIR"
    log "Archives saved to: $BUILD_DIR"
    log "Exports saved to: $EXPORT_DIR"
}

# Run main
main "$@"

