#!/bin/bash
################################################################################
# TESTFLIGHT DEPLOYMENT DIAGNOSTIC TOOL
# Checks your setup and identifies common issues
################################################################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 TestFlight Deployment Diagnostic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ISSUES_FOUND=0
WARNINGS_FOUND=0

################################################################################
# CHECK 1: Xcode & Command Line Tools
################################################################################

echo "▶ Checking Xcode..."
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n1)
    echo "  ✅ $XCODE_VERSION"
else
    echo "  ❌ Xcode command line tools not found"
    echo "     Run: xcode-select --install"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

################################################################################
# CHECK 2: API Credentials
################################################################################

echo ""
echo "▶ Checking API credentials..."

API_KEY_ID="${APP_STORE_API_KEY_ID}"
API_ISSUER_ID="${APP_STORE_API_ISSUER_ID}"

if [ -z "$API_KEY_ID" ]; then
    echo "  ❌ APP_STORE_API_KEY_ID not set"
    echo "     Run: export APP_STORE_API_KEY_ID='your_key_id'"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo "  ✅ API_KEY_ID: $API_KEY_ID"
fi

if [ -z "$API_ISSUER_ID" ]; then
    echo "  ❌ APP_STORE_API_ISSUER_ID not set"
    echo "     Run: export APP_STORE_API_ISSUER_ID='your_issuer_id'"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo "  ✅ API_ISSUER_ID: ${API_ISSUER_ID:0:8}..."
fi

################################################################################
# CHECK 3: .p8 Key File
################################################################################

echo ""
echo "▶ Checking .p8 key file..."

KEY_DIR="$HOME/.appstoreconnect/private_keys"

if [ -d "$KEY_DIR" ]; then
    echo "  ✅ Key directory exists: $KEY_DIR"
    
    if [ -n "$API_KEY_ID" ]; then
        P8_FILE="$KEY_DIR/AuthKey_${API_KEY_ID}.p8"
        
        if [ -f "$P8_FILE" ]; then
            echo "  ✅ Key file found: AuthKey_${API_KEY_ID}.p8"
            
            # Check file permissions
            PERMS=$(stat -f "%A" "$P8_FILE" 2>/dev/null || stat -c "%a" "$P8_FILE" 2>/dev/null)
            if [ "$PERMS" = "600" ] || [ "$PERMS" = "400" ]; then
                echo "  ✅ File permissions secure: $PERMS"
            else
                echo "  ⚠️  File permissions not secure: $PERMS"
                echo "     Run: chmod 600 $P8_FILE"
                WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
            fi
        else
            echo "  ❌ Key file not found: AuthKey_${API_KEY_ID}.p8"
            echo "     Expected location: $P8_FILE"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        # List available keys
        KEY_COUNT=$(find "$KEY_DIR" -name "AuthKey_*.p8" 2>/dev/null | wc -l)
        if [ $KEY_COUNT -gt 0 ]; then
            echo "  ℹ️  Found $KEY_COUNT .p8 key file(s):"
            find "$KEY_DIR" -name "AuthKey_*.p8" -exec basename {} \;
        else
            echo "  ❌ No .p8 key files found in $KEY_DIR"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi
else
    echo "  ❌ Key directory not found: $KEY_DIR"
    echo "     Run: mkdir -p $KEY_DIR"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

################################################################################
# CHECK 4: Directory Structure
################################################################################

echo ""
echo "▶ Checking app directories..."

declare -a APPS=(
    "PersonalHealthApp:PersonalHealthApp"
    "ClinicianApp:FoTClinicianApp"
    "ParentApp:FoTParentApp"
    "EducationApp:FoTEducationApp"
    "LegalApp:FoTLegalApp"
)

ALL_APPS_FOUND=true

for app_config in "${APPS[@]}"; do
    IFS=':' read -r dir scheme <<< "$app_config"
    APP_PATH="apps/$dir/iOS"
    
    if [ -d "$APP_PATH" ]; then
        # Check for .xcodeproj
        if [ -d "$APP_PATH/$scheme.xcodeproj" ]; then
            echo "  ✅ $scheme"
        else
            echo "  ❌ $scheme - project file not found"
            echo "     Expected: $APP_PATH/$scheme.xcodeproj"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
            ALL_APPS_FOUND=false
        fi
    else
        echo "  ❌ $scheme - directory not found"
        echo "     Expected: $APP_PATH"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        ALL_APPS_FOUND=false
    fi
done

################################################################################
# CHECK 5: Multi-Platform Configuration
################################################################################

echo ""
echo "▶ Checking multi-platform configuration..."

# Source platform helpers if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/platform_helpers.sh" ]; then
    source "$SCRIPT_DIR/platform_helpers.sh"
    echo "  ✅ platform_helpers.sh found"
    
    # Check platform matrix
    if [ -f "$SCRIPT_DIR/app_platform_matrix.json" ]; then
        echo "  ✅ app_platform_matrix.json found"
        
        # Check if jq is available for JSON parsing
        if command -v jq &> /dev/null; then
            echo "  ✅ jq available for JSON parsing"
            
            # Validate JSON structure
            if jq empty "$SCRIPT_DIR/app_platform_matrix.json" 2>/dev/null; then
                echo "  ✅ Platform matrix JSON is valid"
                
                # List apps and platforms
                APP_COUNT=$(jq 'length' "$SCRIPT_DIR/app_platform_matrix.json" 2>/dev/null)
                echo "  ℹ️  Configured apps: $APP_COUNT"
                
                # Check each app's platform support
                declare -a APP_NAMES=("PersonalHealthApp" "ClinicianApp" "ParentApp" "EducationApp" "LegalApp")
                for app_name in "${APP_NAMES[@]}"; do
                    platforms=$(jq -r ".[\"$app_name\"].platforms[]?" "$SCRIPT_DIR/app_platform_matrix.json" 2>/dev/null)
                    if [ -n "$platforms" ]; then
                        platform_list=$(echo "$platforms" | tr '\n' ', ' | sed 's/,$//')
                        echo "     • $app_name: $platform_list"
                        
                        # Verify directories exist
                        app_dir=$(jq -r ".[\"$app_name\"].directory" "$SCRIPT_DIR/app_platform_matrix.json" 2>/dev/null)
                        for platform in $platforms; do
                            platform_dir=$(get_platform_dir "$platform" 2>/dev/null)
                            if [ -n "$platform_dir" ] && [ -d "apps/$app_dir/$platform_dir" ]; then
                                echo "       ✓ $platform directory exists"
                            else
                                echo "       ⚠️  $platform directory missing"
                                WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
                            fi
                        done
                    fi
                done
            else
                echo "  ❌ Platform matrix JSON is invalid"
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        else
            echo "  ⚠️  jq not found - cannot fully validate platform matrix"
            echo "     Install with: brew install jq"
            WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
        fi
    else
        echo "  ❌ app_platform_matrix.json not found"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo "  ⚠️  platform_helpers.sh not found"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

################################################################################
# CHECK 6: Deployment Scripts
################################################################################

echo ""
echo "▶ Checking deployment scripts..."

# Check scripts in scripts/ directory
if [ -f "scripts/deploy_to_testflight.sh" ]; then
    echo "  ✅ scripts/deploy_to_testflight.sh exists (iOS only)"
    
    if [ -x "scripts/deploy_to_testflight.sh" ]; then
        echo "  ✅ Script is executable"
    else
        echo "  ⚠️  Script is not executable"
        echo "     Run: chmod +x scripts/deploy_to_testflight.sh"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
else
    echo "  ℹ️  scripts/deploy_to_testflight.sh not found (optional - iOS only)"
fi

if [ -f "scripts/deploy_single_app.sh" ]; then
    echo "  ✅ scripts/deploy_single_app.sh exists (iOS only)"
    
    if [ -x "scripts/deploy_single_app.sh" ]; then
        echo "  ✅ Script is executable"
    else
        echo "  ⚠️  Script is not executable"
        echo "     Run: chmod +x scripts/deploy_single_app.sh"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
else
    echo "  ℹ️  scripts/deploy_single_app.sh not found (optional - iOS only)"
fi

# Check for multi-platform deployment script
if [ -f "scripts/deploy_all_platforms_testflight.sh" ]; then
    echo "  ✅ deploy_all_platforms_testflight.sh exists"
    
    if [ -x "scripts/deploy_all_platforms_testflight.sh" ]; then
        echo "  ✅ Script is executable"
    else
        echo "  ⚠️  Script is not executable"
        echo "     Run: chmod +x scripts/deploy_all_platforms_testflight.sh"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
else
    echo "  ⚠️  deploy_all_platforms_testflight.sh not found"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

################################################################################
# CHECK 7: Network Connectivity
################################################################################

echo ""
echo "▶ Checking network connectivity..."

if ping -c 1 apple.com &> /dev/null; then
    echo "  ✅ Internet connection working"
else
    echo "  ⚠️  Cannot reach apple.com"
    echo "     Check your internet connection"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

################################################################################
# CHECK 8: Build Directory
################################################################################

echo ""
echo "▶ Checking build artifacts..."

if [ -d "build" ]; then
    echo "  ℹ️  Build directory exists"
    
    # Check sizes
    if [ -d "build/archives" ]; then
        ARCHIVE_COUNT=$(find build/archives -name "*.xcarchive" 2>/dev/null | wc -l)
        echo "     Archives: $ARCHIVE_COUNT"
    fi
    
    if [ -d "build/export" ]; then
        IPA_COUNT=$(find build/export -name "*.ipa" 2>/dev/null | wc -l)
        echo "     IPAs: $IPA_COUNT"
    fi
    
    if [ -d "build/logs" ]; then
        LOG_COUNT=$(find build/logs -name "*.log" 2>/dev/null | wc -l)
        echo "     Log files: $LOG_COUNT"
    fi
else
    echo "  ℹ️  Build directory doesn't exist yet (will be created on first run)"
fi

################################################################################
# CHECK 9: Recent Logs (if any)
################################################################################

if [ -d "build/logs" ]; then
    echo ""
    echo "▶ Checking recent logs..."
    
    RECENT_LOGS=$(find build/logs -name "*.log" -mtime -1 2>/dev/null)
    
    if [ -n "$RECENT_LOGS" ]; then
        echo "  ℹ️  Recent logs from last 24 hours:"
        echo "$RECENT_LOGS" | while read -r log; do
            SIZE=$(du -h "$log" | cut -f1)
            echo "     $(basename $log) ($SIZE)"
        done
    else
        echo "  ℹ️  No recent logs found"
    fi
fi

################################################################################
# FINAL REPORT
################################################################################

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Diagnostic Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    echo "✅ All checks passed! System is ready for deployment."
    echo ""
    echo "Run: ./scripts/deploy_all_platforms_testflight.sh"
    echo ""
    exit 0
elif [ $ISSUES_FOUND -eq 0 ]; then
    echo "⚠️  Minor issues found: $WARNINGS_FOUND"
    echo ""
    echo "System should work, but review warnings above."
    echo ""
    exit 0
else
    echo "❌ Critical issues found: $ISSUES_FOUND"
    if [ $WARNINGS_FOUND -gt 0 ]; then
        echo "⚠️  Additional warnings: $WARNINGS_FOUND"
    fi
    echo ""
    echo "Fix the issues above before deploying."
    echo ""
    echo "Need help? See SETUP_GUIDE.md or QUICK_START.md"
    echo ""
    exit 1
fi
