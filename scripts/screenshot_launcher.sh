#!/bin/bash

# ==============================================================================
# MAC PRODUCTS SCREENSHOT LAUNCHER
# Simple menu to launch screenshot and marketing tools
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

cat << 'EOF'

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           MAC PRODUCTS SCREENSHOT GENERATOR                  ║
║                                                              ║
║              Field of Truth - Mac Applications               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

echo ""
echo -e "${CYAN}📸 Choose your screenshot generation method:${NC}"
echo ""
echo -e "${GREEN}1)${NC} ${YELLOW}Quick Automated Screenshots${NC}"
echo "   - Fast and efficient"
echo "   - Automatically captures main views"
echo "   - Creates App Store ready versions"
echo "   - ⏱️  ~10-15 minutes"
echo ""

echo -e "${GREEN}2)${NC} ${YELLOW}Interactive Screenshots & Clips${NC}"
echo "   - Full control over what's captured"
echo "   - 5 custom screenshots per app"
echo "   - Records 30-second demo videos"
echo "   - ⏱️  ~30-45 minutes"
echo ""

echo -e "${GREEN}3)${NC} ${YELLOW}Marketing Materials Setup${NC}"
echo "   - Creates complete directory structure"
echo "   - Generates templates and guides"
echo "   - Provides App Store requirements"
echo "   - ⏱️  ~2 minutes (setup only)"
echo ""

echo -e "${GREEN}4)${NC} ${YELLOW}View Documentation${NC}"
echo "   - Complete screenshot guide"
echo "   - App Store requirements"
echo "   - Tips and best practices"
echo ""

echo -e "${GREEN}5)${NC} ${YELLOW}Exit${NC}"
echo ""

read -p "$(echo -e ${CYAN}Enter your choice [1-5]:${NC} )" choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}🚀 Launching Automated Screenshot Generator...${NC}"
        sleep 1
        "$SCRIPT_DIR/auto_screenshot_mac_apps.sh"
        ;;
    2)
        echo ""
        echo -e "${BLUE}🚀 Launching Interactive Screenshot & Clip Generator...${NC}"
        sleep 1
        "$SCRIPT_DIR/create_mac_screenshots_and_clips.sh"
        ;;
    3)
        echo ""
        echo -e "${BLUE}🚀 Creating Marketing Materials Structure...${NC}"
        sleep 1
        "$SCRIPT_DIR/create_appstore_marketing.sh"
        ;;
    4)
        echo ""
        echo -e "${BLUE}📚 Opening Documentation...${NC}"
        sleep 1
        
        # Open the guide in default markdown viewer
        if [ -f "$(dirname "$SCRIPT_DIR")/MAC_PRODUCTS_SCREENSHOT_GUIDE.md" ]; then
            open "$(dirname "$SCRIPT_DIR")/MAC_PRODUCTS_SCREENSHOT_GUIDE.md"
            
            echo ""
            echo -e "${GREEN}✅ Documentation opened${NC}"
            echo ""
            echo "Press Enter to continue..."
            read
        else
            echo -e "${RED}❌ Documentation file not found${NC}"
        fi
        ;;
    5)
        echo ""
        echo -e "${GREEN}👋 Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo ""
        echo -e "${RED}❌ Invalid choice. Please run again and select 1-5.${NC}"
        exit 1
        ;;
esac

echo ""
echo ""
echo -e "${GREEN}✅ Process complete!${NC}"
echo ""
echo -e "${CYAN}What would you like to do next?${NC}"
echo ""
echo "1) Run another tool"
echo "2) View generated files"
echo "3) Exit"
echo ""

read -p "$(echo -e ${CYAN}Enter your choice [1-3]:${NC} )" next_choice

case $next_choice in
    1)
        exec "$0"  # Restart this script
        ;;
    2)
        # Open Finder to the screenshots directory
        if [ -d "$(dirname "$SCRIPT_DIR")/mac_screenshots_auto" ]; then
            open "$(dirname "$SCRIPT_DIR")/mac_screenshots_auto"
        elif [ -d "$(dirname "$SCRIPT_DIR")/mac_screenshots" ]; then
            open "$(dirname "$SCRIPT_DIR")/mac_screenshots"
        elif [ -d "$(dirname "$SCRIPT_DIR")/appstore_marketing" ]; then
            open "$(dirname "$SCRIPT_DIR")/appstore_marketing"
        fi
        ;;
    3)
        echo ""
        echo -e "${GREEN}👋 Goodbye!${NC}"
        exit 0
        ;;
esac

