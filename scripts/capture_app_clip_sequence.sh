#!/bin/bash

# ==============================================================================
# APP CLIP SEQUENCE SCREENSHOT GENERATOR
# Captures multiple screenshots for creating demo clips
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCREENSHOTS_DIR="$PROJECT_ROOT/mac_screenshots_auto"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

cat << 'EOF'

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        APP CLIP SEQUENCE SCREENSHOT GENERATOR                ║
║                                                              ║
║     Capture Multiple Screenshots for Demo Videos            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

echo -e "${CYAN}📸 This tool helps you capture screenshot sequences for app clips${NC}"
echo ""
echo "How it works:"
echo "  1. Open the app"
echo "  2. Take screenshots at key moments"
echo "  3. You click through the app between screenshots"
echo "  4. Create 8-10 screenshots showing the app's journey"
echo ""

# ==============================================================================
# PersonalHealthMac Sequence
# ==============================================================================

capture_personalhealth_sequence() {
    local app_name="PersonalHealthMac"
    local output_dir="$SCREENSHOTS_DIR/$app_name/clip_sequence"
    
    mkdir -p "$output_dir"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📱 PersonalHealthMac - Health Monitor${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${GREEN}Suggested screenshot sequence for Health app:${NC}"
    echo "  01. Launch screen / Main dashboard"
    echo "  02. Health records list"
    echo "  03. Adding new health entry"
    echo "  04. Recording vital signs"
    echo "  05. Health timeline view"
    echo "  06. Trends and analytics"
    echo "  07. Settings or profile"
    echo "  08. Completed entry confirmation"
    echo ""
    
    echo -e "${CYAN}Let's capture the sequence!${NC}"
    echo ""
    
    # Screenshot 1
    echo -e "${YELLOW}📸 Screenshot 1: Launch/Dashboard${NC}"
    echo "   Make sure the app shows the main screen"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/01_dashboard.png" 2>/dev/null || screencapture -o "$output_dir/01_dashboard.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 2
    echo -e "${YELLOW}📸 Screenshot 2: Health Records${NC}"
    echo "   Click to show health records or history"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/02_records_list.png" 2>/dev/null || screencapture -o "$output_dir/02_records_list.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 3
    echo -e "${YELLOW}📸 Screenshot 3: New Entry${NC}"
    echo "   Click 'Add' or 'New Entry' button"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/03_new_entry.png" 2>/dev/null || screencapture -o "$output_dir/03_new_entry.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 4
    echo -e "${YELLOW}📸 Screenshot 4: Recording Vitals${NC}"
    echo "   Show the form being filled out"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/04_recording_vitals.png" 2>/dev/null || screencapture -o "$output_dir/04_recording_vitals.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 5
    echo -e "${YELLOW}📸 Screenshot 5: Timeline View${NC}"
    echo "   Navigate to timeline or history view"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/05_timeline.png" 2>/dev/null || screencapture -o "$output_dir/05_timeline.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 6
    echo -e "${YELLOW}📸 Screenshot 6: Analytics/Trends${NC}"
    echo "   Show charts or analytics if available"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/06_analytics.png" 2>/dev/null || screencapture -o "$output_dir/06_analytics.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 7
    echo -e "${YELLOW}📸 Screenshot 7: Detail View${NC}"
    echo "   Click on a specific health record to show details"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/07_detail_view.png" 2>/dev/null || screencapture -o "$output_dir/07_detail_view.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 8
    echo -e "${YELLOW}📸 Screenshot 8: Success/Confirmation${NC}"
    echo "   Show completion or success message"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/08_success.png" 2>/dev/null || screencapture -o "$output_dir/08_success.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    
    echo -e "${GREEN}✅ PersonalHealthMac sequence complete!${NC}"
    echo -e "   Location: $output_dir"
    echo ""
}

# ==============================================================================
# FoTClinicianMac Sequence
# ==============================================================================

capture_clinician_sequence() {
    local app_name="FoTClinicianMac"
    local output_dir="$SCREENSHOTS_DIR/$app_name/clip_sequence"
    
    mkdir -p "$output_dir"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}👨‍⚕️ FoTClinicianMac - Clinical Tools${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${GREEN}Suggested screenshot sequence for Clinician app:${NC}"
    echo "  01. Launch screen / Main dashboard"
    echo "  02. Patient list"
    echo "  03. Patient record view"
    echo "  04. Clinical assessment tools"
    echo "  05. Drug interaction checker"
    echo "  06. Documentation/notes"
    echo "  07. Reports or analytics"
    echo "  08. Completed workflow"
    echo ""
    
    echo -e "${CYAN}Let's capture the sequence!${NC}"
    echo ""
    
    # Screenshot 1
    echo -e "${YELLOW}📸 Screenshot 1: Launch/Dashboard${NC}"
    echo "   Make sure the app shows the main screen"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/01_dashboard.png" 2>/dev/null || screencapture -o "$output_dir/01_dashboard.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 2
    echo -e "${YELLOW}📸 Screenshot 2: Patient List${NC}"
    echo "   Show the patient list or schedule"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/02_patient_list.png" 2>/dev/null || screencapture -o "$output_dir/02_patient_list.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 3
    echo -e "${YELLOW}📸 Screenshot 3: Patient Record${NC}"
    echo "   Click on a patient to view their record"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/03_patient_record.png" 2>/dev/null || screencapture -o "$output_dir/03_patient_record.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 4
    echo -e "${YELLOW}📸 Screenshot 4: Assessment Tools${NC}"
    echo "   Show clinical assessment or diagnostic tools"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/04_assessment.png" 2>/dev/null || screencapture -o "$output_dir/04_assessment.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 5
    echo -e "${YELLOW}📸 Screenshot 5: Clinical Feature${NC}"
    echo "   Show a key clinical feature (drug checker, guidelines, etc.)"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/05_clinical_feature.png" 2>/dev/null || screencapture -o "$output_dir/05_clinical_feature.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 6
    echo -e "${YELLOW}📸 Screenshot 6: Documentation${NC}"
    echo "   Show notes or documentation interface"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/06_documentation.png" 2>/dev/null || screencapture -o "$output_dir/06_documentation.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 7
    echo -e "${YELLOW}📸 Screenshot 7: Reports/Analytics${NC}"
    echo "   Show reports or clinical analytics"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/07_reports.png" 2>/dev/null || screencapture -o "$output_dir/07_reports.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    sleep 1
    
    # Screenshot 8
    echo -e "${YELLOW}📸 Screenshot 8: Workflow Complete${NC}"
    echo "   Show completion or success state"
    read -p "   Press ENTER when ready to capture..."
    screencapture -W "$output_dir/08_complete.png" 2>/dev/null || screencapture -o "$output_dir/08_complete.png"
    echo -e "${GREEN}   ✅ Captured!${NC}"
    echo ""
    
    echo -e "${GREEN}✅ FoTClinicianMac sequence complete!${NC}"
    echo -e "   Location: $output_dir"
    echo ""
}

# ==============================================================================
# Main Menu
# ==============================================================================

main() {
    echo -e "${CYAN}Which app would you like to capture?${NC}"
    echo ""
    echo "  1) PersonalHealthMac (Health Monitor)"
    echo "  2) FoTClinicianMac (Clinical Tools)"
    echo "  3) Both apps"
    echo "  4) Exit"
    echo ""
    
    read -p "$(echo -e ${CYAN}Enter your choice [1-4]:${NC} )" choice
    echo ""
    
    case $choice in
        1)
            echo -e "${GREEN}Opening PersonalHealthMac...${NC}"
            open /Users/richardgillespie/Documents/FoTApple/build/mac_products/PersonalHealthMac/Build/Products/Release/PersonalHealthMac.app
            sleep 5
            capture_personalhealth_sequence
            ;;
        2)
            echo -e "${GREEN}Opening FoTClinicianMac...${NC}"
            open /Users/richardgillespie/Documents/FoTApple/build/mac_products/FoTClinicianMac/Build/Products/Release/FoTClinicianMac.app
            sleep 5
            capture_clinician_sequence
            ;;
        3)
            echo -e "${GREEN}Opening PersonalHealthMac first...${NC}"
            open /Users/richardgillespie/Documents/FoTApple/build/mac_products/PersonalHealthMac/Build/Products/Release/PersonalHealthMac.app
            sleep 5
            capture_personalhealth_sequence
            
            echo ""
            echo -e "${BLUE}Now switching to FoTClinicianMac...${NC}"
            pkill -f PersonalHealthMac 2>/dev/null
            sleep 2
            
            open /Users/richardgillespie/Documents/FoTApple/build/mac_products/FoTClinicianMac/Build/Products/Release/FoTClinicianMac.app
            sleep 5
            capture_clinician_sequence
            ;;
        4)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
    
    # Generate summary
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ SEQUENCE CAPTURE COMPLETE!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "📁 Screenshots saved to:"
    echo "   $SCREENSHOTS_DIR/*/clip_sequence/"
    echo ""
    echo "🎬 Next steps to create app clips:"
    echo "   1. Review the screenshots"
    echo "   2. Import into video editing software"
    echo "   3. Add transitions (0.5-1 second each)"
    echo "   4. Add background music (optional)"
    echo "   5. Export as 15-30 second clips"
    echo ""
    echo "💡 Recommended tools:"
    echo "   - iMovie (Free, built-in)"
    echo "   - Final Cut Pro (Professional)"
    echo "   - Keynote (Simple slideshow-style)"
    echo ""
    
    # Count screenshots
    local total_screenshots=$(find "$SCREENSHOTS_DIR" -name "*.png" -type f | wc -l | xargs)
    echo -e "${CYAN}Total screenshots captured: $total_screenshots${NC}"
    echo ""
    
    # Open the directory
    read -p "$(echo -e ${YELLOW}Open screenshots folder? [Y/n]:${NC} )" open_choice
    if [[ $open_choice =~ ^[Yy]$ ]] || [[ -z $open_choice ]]; then
        open "$SCREENSHOTS_DIR"
    fi
}

main "$@"

