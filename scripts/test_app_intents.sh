#!/bin/bash
################################################################################
# Test App Intents for All Apps
# Verifies App Intents are properly registered and Siri can discover them
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing App Intents for All Apps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if macOS apps have AppShortcutsProvider
check_app_intents() {
    local app_name=$1
    local app_path=$2
    local shortcuts_file=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 Testing: $app_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if shortcuts file exists
    if [ -f "$app_path/$shortcuts_file" ]; then
        echo "  ✅ Shortcuts file found: $shortcuts_file"
        
        # Check if it has AppShortcutsProvider
        if grep -q "AppShortcutsProvider" "$app_path/$shortcuts_file"; then
            echo "  ✅ AppShortcutsProvider found"
        else
            echo "  ❌ AppShortcutsProvider NOT found in $shortcuts_file"
            return 1
        fi
        
        # Count app shortcuts
        shortcut_count=$(grep -c "AppShortcut(" "$app_path/$shortcuts_file" || echo "0")
        echo "  ✅ Found $shortcut_count app shortcut(s)"
    else
        echo "  ❌ Shortcuts file NOT found: $app_path/$shortcuts_file"
        return 1
    fi
    
    # Check Info.plist for NSAppIntentsPackages
    info_plist=$(find "$app_path" -name "Info.plist" -not -path "*/.*" | head -1)
    if [ -f "$info_plist" ]; then
        if grep -q "NSAppIntentsPackages" "$info_plist"; then
            echo "  ✅ Info.plist contains NSAppIntentsPackages"
        else
            echo "  ❌ Info.plist missing NSAppIntentsPackages"
            return 1
        fi
    else
        echo "  ⚠️  Info.plist not found"
    fi
    
    # Check project.yml for FoTAppIntents dependency
    project_yml=$(find "$app_path" -name "project.yml" -not -path "*/.*" | head -1)
    if [ -f "$project_yml" ]; then
        if grep -q "FoTAppIntents" "$project_yml"; then
            echo "  ✅ project.yml includes FoTAppIntents dependency"
        else
            echo "  ❌ project.yml missing FoTAppIntents dependency"
            return 1
        fi
    fi
    
    echo "  ✅ $app_name App Intents configuration complete"
    echo ""
    return 0
}

# Test all macOS apps
echo "📱 macOS Apps:"
echo ""

check_app_intents \
    "PersonalHealthMac" \
    "$PROJECT_ROOT/apps/PersonalHealthApp/macOS/PersonalHealthMac" \
    "HealthAppShortcuts.swift"

check_app_intents \
    "FoTClinicianMac" \
    "$PROJECT_ROOT/apps/ClinicianApp/macOS/FoTClinicianMac" \
    "ClinicianAppShortcuts.swift"

# Test iOS apps
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 iOS Apps:"
echo ""

check_app_intents \
    "PersonalHealthApp" \
    "$PROJECT_ROOT/apps/PersonalHealthApp/iOS/PersonalHealth" \
    "HealthAppShortcuts.swift"

check_app_intents \
    "FoTClinicianApp" \
    "$PROJECT_ROOT/apps/ClinicianApp/iOS/FoTClinician" \
    "ClinicianAppShortcuts.swift"

check_app_intents \
    "FoTParentApp" \
    "$PROJECT_ROOT/apps/ParentApp/iOS/FoTParent" \
    "ParentAppShortcuts.swift"

check_app_intents \
    "FoTEducationApp" \
    "$PROJECT_ROOT/apps/EducationApp/iOS/FoTEducation" \
    "EducationAppShortcuts.swift"

check_app_intents \
    "FoTLegalApp" \
    "$PROJECT_ROOT/apps/LegalApp/iOS/FoTLegal" \
    "LegalAppShortcuts.swift"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ App Intents Testing Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next Steps:"
echo "1. Build apps with xcodegen"
echo "2. Install on device/simulator"
echo "3. Test Siri: 'Hey Siri, what can I do in [App Name]?'"
echo "4. Test voice commands: 'Hey Siri, record health check-in in My Health'"
echo ""

