#!/bin/bash

# sync_extensions_with_apps.sh
# Automated sync script to keep browser extensions aligned with Mac/iOS apps

set -e

echo "════════════════════════════════════════════════════════════"
echo "🔄 EXTENSION <=> APP SYNC SYSTEM"
echo "════════════════════════════════════════════════════════════"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directories
SAFARI_DIR="safari-extension"
APPS_DIR="apps"
PACKAGES_DIR="packages"

# Function to extract version from manifest
get_extension_version() {
    local manifest=$1
    if [ -f "$manifest" ]; then
        grep -o '"version": "[^"]*"' "$manifest" | cut -d'"' -f4
    else
        echo "N/A"
    fi
}

# Function to extract version from app
get_app_version() {
    local info_plist=$1
    if [ -f "$info_plist" ]; then
        /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$info_plist" 2>/dev/null || echo "N/A"
    else
        echo "N/A"
    fi
}

# Function to check feature parity
check_feature_parity() {
    echo "Checking feature parity..."
    echo ""
    
    # Check Clinician
    clinician_app_version=$(get_app_version "apps/ClinicianApp/iOS/FoTClinician/Info.plist")
    clinician_ext_version=$(get_extension_version "safari-extension/FoTSuite-Chrome/manifest.json")
    
    if [ "$clinician_app_version" != "$clinician_ext_version" ]; then
        echo -e "${YELLOW}⚠️  Version mismatch: Clinician${NC}"
        echo "   App: $clinician_app_version | Extension: $clinician_ext_version"
    else
        echo -e "${GREEN}✅ Clinician: v$clinician_app_version (synced)${NC}"
    fi
    
    # Check Legal
    legal_app_version=$(get_app_version "apps/LegalApp/iOS/FoTLegal/Info.plist")
    
    if [ "$legal_app_version" != "$clinician_ext_version" ]; then
        echo -e "${YELLOW}⚠️  Version mismatch: Legal${NC}"
        echo "   App: $legal_app_version | Extension: $clinician_ext_version"
    else
        echo -e "${GREEN}✅ Legal: v$legal_app_version (synced)${NC}"
    fi
    
    # Check Education
    education_app_version=$(get_app_version "apps/EducationApp/iOS/FoTEducation/Info.plist")
    
    if [ "$education_app_version" != "$clinician_ext_version" ]; then
        echo -e "${YELLOW}⚠️  Version mismatch: Education${NC}"
        echo "   App: $education_app_version | Extension: $clinician_ext_version"
    else
        echo -e "${GREEN}✅ Education: v$education_app_version (synced)${NC}"
    fi
    
    # Check Personal Health
    health_app_version=$(get_app_version "apps/PersonalHealthApp/iOS/PersonalHealth/Info.plist")
    
    if [ "$health_app_version" != "$clinician_ext_version" ]; then
        echo -e "${YELLOW}⚠️  Version mismatch: Personal Health${NC}"
        echo "   App: $health_app_version | Extension: $clinician_ext_version"
    else
        echo -e "${GREEN}✅ Personal Health: v$health_app_version (synced)${NC}"
    fi
    
    echo ""
}

# Function to check native messaging hosts
check_native_messaging() {
    echo "Checking native messaging hosts..."
    echo ""
    
    # Safari hosts
    safari_hosts_dir="$HOME/Library/Application Support/Safari/NativeMessagingHosts"
    if [ -d "$safari_hosts_dir" ]; then
        host_count=$(ls -1 "$safari_hosts_dir"/*.json 2>/dev/null | wc -l | xargs)
        if [ "$host_count" = "4" ]; then
            echo -e "${GREEN}✅ Safari: 4 native messaging hosts installed${NC}"
        else
            echo -e "${YELLOW}⚠️  Safari: Found $host_count hosts, expected 4${NC}"
        fi
    else
        echo -e "${RED}❌ Safari: No native messaging hosts found${NC}"
    fi
    
    # Chrome hosts
    chrome_hosts_dir="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
    if [ -d "$chrome_hosts_dir" ]; then
        host_count=$(ls -1 "$chrome_hosts_dir"/*.json 2>/dev/null | wc -l | xargs)
        if [ "$host_count" -gt "0" ]; then
            echo -e "${GREEN}✅ Chrome: $host_count native messaging hosts installed${NC}"
        else
            echo -e "${YELLOW}⚠️  Chrome: No hosts found${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Chrome: Native messaging directory not found${NC}"
    fi
    
    # Firefox hosts
    firefox_hosts_dir="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
    if [ -d "$firefox_hosts_dir" ]; then
        host_count=$(ls -1 "$firefox_hosts_dir"/*.json 2>/dev/null | wc -l | xargs)
        if [ "$host_count" -gt "0" ]; then
            echo -e "${GREEN}✅ Firefox: $host_count native messaging hosts installed${NC}"
        else
            echo -e "${YELLOW}⚠️  Firefox: No hosts found${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Firefox: Native messaging directory not found${NC}"
    fi
    
    echo ""
}

# Function to check AppIntents sync
check_app_intents() {
    echo "Checking App Intents availability..."
    echo ""
    
    # Count App Intent files
    clinician_intents=$(find apps/ClinicianApp -name "*Intent.swift" 2>/dev/null | wc -l | xargs)
    legal_intents=$(find apps/LegalApp -name "*Intent.swift" 2>/dev/null | wc -l | xargs)
    education_intents=$(find apps/EducationApp -name "*Intent.swift" 2>/dev/null | wc -l | xargs)
    health_intents=$(find apps/PersonalHealthApp -name "*Intent.swift" 2>/dev/null | wc -l | xargs)
    
    echo -e "${GREEN}✅ Clinician: $clinician_intents App Intents${NC}"
    echo -e "${GREEN}✅ Legal: $legal_intents App Intents${NC}"
    echo -e "${GREEN}✅ Education: $education_intents App Intents${NC}"
    echo -e "${GREEN}✅ Personal Health: $health_intents App Intents${NC}"
    
    total_intents=$((clinician_intents + legal_intents + education_intents + health_intents))
    echo ""
    echo "Total App Intents: $total_intents"
    echo ""
}

# Function to verify QFOT integration
check_qfot_integration() {
    echo "Checking QFOT blockchain integration..."
    echo ""
    
    # Check if QFOT Wallet extensions exist
    qfot_chrome="safari-extension/QFOTWallet_Chrome_v1.0.zip"
    qfot_firefox="safari-extension/QFOTWallet_Firefox_v1.0.zip"
    qfot_edge="safari-extension/QFOTWallet_Edge_v1.0.zip"
    
    if [ -f "$qfot_chrome" ]; then
        echo -e "${GREEN}✅ QFOT Wallet Chrome: Ready${NC}"
    else
        echo -e "${RED}❌ QFOT Wallet Chrome: Not found${NC}"
    fi
    
    if [ -f "$qfot_firefox" ]; then
        echo -e "${GREEN}✅ QFOT Wallet Firefox: Ready${NC}"
    else
        echo -e "${RED}❌ QFOT Wallet Firefox: Not found${NC}"
    fi
    
    if [ -f "$qfot_edge" ]; then
        echo -e "${GREEN}✅ QFOT Wallet Edge: Ready${NC}"
    else
        echo -e "${RED}❌ QFOT Wallet Edge: Not found${NC}"
    fi
    
    echo ""
}

# Function to check data mode consistency
check_data_mode() {
    echo "Checking Training/Live mode implementation..."
    echo ""
    
    # Check if AppConfig has DataMode
    if grep -q "enum DataMode" packages/FoTCore/Sources/AppConfig.swift 2>/dev/null; then
        echo -e "${GREEN}✅ DataMode enum: Implemented in AppConfig${NC}"
    else
        echo -e "${RED}❌ DataMode enum: NOT found in AppConfig${NC}"
    fi
    
    # Check if apps are using DataMode
    clinician_uses_mode=$(grep -r "dataMode" apps/ClinicianApp 2>/dev/null | wc -l | xargs)
    legal_uses_mode=$(grep -r "dataMode" apps/LegalApp 2>/dev/null | wc -l | xargs)
    education_uses_mode=$(grep -r "dataMode" apps/EducationApp 2>/dev/null | wc -l | xargs)
    health_uses_mode=$(grep -r "dataMode" apps/PersonalHealthApp 2>/dev/null | wc -l | xargs)
    
    echo "Apps using DataMode:"
    echo "  Clinician: $clinician_uses_mode references"
    echo "  Legal: $legal_uses_mode references"
    echo "  Education: $education_uses_mode references"
    echo "  Personal Health: $health_uses_mode references"
    
    echo ""
}

# Function to generate sync report
generate_report() {
    echo "════════════════════════════════════════════════════════════"
    echo "📊 SYNC REPORT SUMMARY"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Report generated: $(date)"
    echo ""
    echo "✅ = Synced and working"
    echo "⚠️  = Needs attention"
    echo "❌ = Missing or broken"
    echo ""
    echo "Next recommended sync: When any app or extension is updated"
    echo ""
    echo "To update extensions after app changes:"
    echo "  1. Update FEATURE_PARITY_MATRIX.md"
    echo "  2. Modify extension content scripts"
    echo "  3. Test native messaging"
    echo "  4. Bump version in manifest.json"
    echo "  5. Re-package for all browsers"
    echo "  6. Submit to stores"
    echo ""
}

# Main execution
main() {
    check_feature_parity
    check_native_messaging
    check_app_intents
    check_qfot_integration
    check_data_mode
    generate_report
}

# Run main
main

