#!/bin/bash

# ==============================================================================
# AUTOMATED MAC APP SCREENSHOT GENERATOR
# Takes screenshots automatically using AppleScript to control the apps
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCREENSHOTS_DIR="$PROJECT_ROOT/mac_screenshots_auto"
BUILD_DIR="$PROJECT_ROOT/build/mac_products"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# ==============================================================================
# APP DEFINITIONS
# ==============================================================================

declare -A APP_PATHS=(
    ["PersonalHealthMac"]="$BUILD_DIR/PersonalHealthMac/Build/Products/Release/PersonalHealthMac.app"
    ["FoTClinicianMac"]="$BUILD_DIR/FoTClinicianMac/Build/Products/Release/FoTClinicianMac.app"
    ["FoTLegalMac"]="$BUILD_DIR/FoTLegalMac/Build/Products/Release/FoTLegalMac.app"
)

declare -A APP_TITLES=(
    ["PersonalHealthMac"]="Personal Health Monitor for macOS"
    ["FoTClinicianMac"]="FoT Clinician for macOS"
    ["FoTLegalMac"]="FoT Legal for macOS"
)

# ==============================================================================
# SCREENSHOT FUNCTIONS
# ==============================================================================

setup_directories() {
    mkdir -p "$SCREENSHOTS_DIR"
    for app in "${!APP_PATHS[@]}"; do
        mkdir -p "$SCREENSHOTS_DIR/$app"
    done
    log_success "Directories created"
}

capture_window_screenshot() {
    local app_name=$1
    local screenshot_name=$2
    local output_path="$SCREENSHOTS_DIR/$app_name/$screenshot_name.png"
    
    # Get window ID using AppleScript
    local window_id=$(osascript << EOF
tell application "System Events"
    tell process "$app_name"
        try
            return id of window 1
        on error
            return ""
        end try
    end tell
end tell
EOF
)
    
    if [ -n "$window_id" ]; then
        screencapture -l"$window_id" -o "$output_path"
        log_success "  📸 Captured: $screenshot_name"
        return 0
    else
        log_warning "  ⚠️  Could not capture: $screenshot_name"
        return 1
    fi
}

automate_app_screenshots() {
    local app_name=$1
    local app_path="${APP_PATHS[$app_name]}"
    
    log_info "Processing $app_name..."
    
    # Check if app exists
    if [ ! -d "$app_path" ]; then
        log_warning "App not found: $app_path"
        log_info "Build the app first with: scripts/create_mac_screenshots_and_clips.sh"
        return 1
    fi
    
    # Launch app
    log_info "  🚀 Launching $app_name..."
    open "$app_path"
    sleep 5  # Wait for app to fully launch
    
    # Capture main window
    capture_window_screenshot "$app_name" "01_main_window"
    sleep 1
    
    # Try to interact with app using AppleScript
    case "$app_name" in
        "PersonalHealthMac")
            automate_health_app_screenshots "$app_name"
            ;;
        "FoTClinicianMac")
            automate_clinician_app_screenshots "$app_name"
            ;;
        "FoTLegalMac")
            automate_legal_app_screenshots "$app_name"
            ;;
    esac
    
    # Quit app
    log_info "  🛑 Quitting $app_name..."
    osascript -e "quit app \"$app_name\"" 2>/dev/null || pkill -f "$app_name" 2>/dev/null || true
    sleep 2
    
    log_success "Completed $app_name"
}

# ==============================================================================
# APP-SPECIFIC SCREENSHOT AUTOMATION
# ==============================================================================

automate_health_app_screenshots() {
    local app_name=$1
    
    log_info "  📸 Capturing Health app views..."
    
    # Click on different UI elements using AppleScript
    osascript << 'EOF' >/dev/null 2>&1 || true
tell application "System Events"
    tell process "PersonalHealthMac"
        try
            -- Try to click first button/tab if available
            click button 1 of window 1
            delay 1
        end try
    end tell
end tell
EOF
    
    sleep 1
    capture_window_screenshot "$app_name" "02_health_records"
    
    sleep 1
    capture_window_screenshot "$app_name" "03_health_vitals"
}

automate_clinician_app_screenshots() {
    local app_name=$1
    
    log_info "  📸 Capturing Clinician app views..."
    
    sleep 1
    capture_window_screenshot "$app_name" "02_patient_view"
    
    sleep 2
    capture_window_screenshot "$app_name" "03_clinical_tools"
}

automate_legal_app_screenshots() {
    local app_name=$1
    
    log_info "  📸 Capturing Legal app views..."
    
    sleep 1
    capture_window_screenshot "$app_name" "02_legal_documents"
    
    sleep 2
    capture_window_screenshot "$app_name" "03_legal_search"
}

# ==============================================================================
# APP STORE SCREENSHOT GENERATOR
# ==============================================================================

create_appstore_screenshots() {
    local app_name=$1
    local appstore_dir="$SCREENSHOTS_DIR/appstore/$app_name"
    
    mkdir -p "$appstore_dir"
    
    log_info "Creating App Store screenshots for $app_name..."
    
    # Required Mac App Store screenshot sizes:
    # - 1280 x 800 (Mac)
    # - 1440 x 900 (Mac)
    # - 2560 x 1600 (Mac Retina)
    # - 2880 x 1800 (Mac Retina)
    
    # Find all screenshots for this app
    local screenshots=("$SCREENSHOTS_DIR/$app_name"/*.png)
    
    if [ ${#screenshots[@]} -eq 0 ]; then
        log_warning "No screenshots found for $app_name"
        return 1
    fi
    
    # Use sips to resize screenshots to App Store requirements
    for screenshot in "${screenshots[@]}"; do
        if [ -f "$screenshot" ]; then
            local basename=$(basename "$screenshot" .png)
            
            # Create 2880x1800 version (primary)
            sips -z 1800 2880 "$screenshot" --out "$appstore_dir/${basename}_2880x1800.png" >/dev/null
            
            # Create 1440x900 version
            sips -z 900 1440 "$screenshot" --out "$appstore_dir/${basename}_1440x900.png" >/dev/null
            
            log_success "  ✅ Created App Store sizes for $basename"
        fi
    done
    
    log_success "App Store screenshots created for $app_name"
}

# ==============================================================================
# GENERATE HTML PREVIEW
# ==============================================================================

generate_html_preview() {
    local html_file="$SCREENSHOTS_DIR/preview.html"
    
    log_info "Generating HTML preview..."
    
    cat > "$html_file" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mac Products Screenshots</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 20px;
            color: #333;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        h1 {
            color: white;
            text-align: center;
            margin-bottom: 50px;
            font-size: 48px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .app-section {
            background: white;
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        
        .app-section h2 {
            color: #667eea;
            margin-bottom: 30px;
            font-size: 36px;
            border-bottom: 3px solid #667eea;
            padding-bottom: 15px;
        }
        
        .screenshots-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }
        
        .screenshot-card {
            background: #f8f9fa;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .screenshot-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }
        
        .screenshot-card img {
            width: 100%;
            height: auto;
            display: block;
            border-bottom: 3px solid #667eea;
        }
        
        .screenshot-card .caption {
            padding: 20px;
            font-size: 14px;
            color: #666;
            text-align: center;
            font-weight: 500;
        }
        
        .stats {
            background: rgba(255,255,255,0.9);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 40px;
            text-align: center;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .stat-item {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .stat-item .number {
            font-size: 48px;
            font-weight: bold;
            display: block;
        }
        
        .stat-item .label {
            font-size: 14px;
            opacity: 0.9;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 Mac Products Screenshots</h1>
        
        <div class="stats">
            <h2>📊 Screenshot Statistics</h2>
            <div class="stats-grid">
                <div class="stat-item">
                    <span class="number" id="total-apps">0</span>
                    <span class="label">Mac Apps</span>
                </div>
                <div class="stat-item">
                    <span class="number" id="total-screenshots">0</span>
                    <span class="label">Total Screenshots</span>
                </div>
                <div class="stat-item">
                    <span class="number" id="date">Today</span>
                    <span class="label">Generated</span>
                </div>
            </div>
        </div>
HTMLEOF

    # Add sections for each app
    for app in "${!APP_PATHS[@]}"; do
        cat >> "$html_file" << HTMLEOF
        
        <div class="app-section">
            <h2>${APP_TITLES[$app]}</h2>
            <div class="screenshots-grid">
HTMLEOF
        
        # Find screenshots for this app
        if [ -d "$SCREENSHOTS_DIR/$app" ]; then
            for screenshot in "$SCREENSHOTS_DIR/$app"/*.png; do
                if [ -f "$screenshot" ]; then
                    local rel_path="${screenshot#$SCREENSHOTS_DIR/}"
                    local basename=$(basename "$screenshot" .png)
                    local caption=$(echo "$basename" | sed 's/_/ /g' | sed 's/^[0-9]* //')
                    
                    cat >> "$html_file" << HTMLEOF
                <div class="screenshot-card">
                    <img src="$rel_path" alt="$caption">
                    <div class="caption">$caption</div>
                </div>
HTMLEOF
                fi
            done
        fi
        
        cat >> "$html_file" << 'HTMLEOF'
            </div>
        </div>
HTMLEOF
    done
    
    # Close HTML
    cat >> "$html_file" << 'HTMLEOF'
    </div>
    
    <script>
        // Update statistics
        document.getElementById('total-apps').textContent = document.querySelectorAll('.app-section').length;
        document.getElementById('total-screenshots').textContent = document.querySelectorAll('.screenshot-card').length;
        document.getElementById('date').textContent = new Date().toLocaleDateString();
    </script>
</body>
</html>
HTMLEOF
    
    log_success "HTML preview generated: $html_file"
    
    # Open in browser
    open "$html_file"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    clear
    
    cat << 'EOF'

╔══════════════════════════════════════════════════════════╗
║                                                          ║
║      AUTOMATED MAC APP SCREENSHOT GENERATOR              ║
║                                                          ║
║             Field of Truth - Mac Suite                   ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

EOF

    setup_directories
    
    # Process each app
    for app in "${!APP_PATHS[@]}"; do
        echo ""
        automate_app_screenshots "$app"
    done
    
    echo ""
    log_info "Creating App Store formatted screenshots..."
    
    # Create App Store screenshots
    for app in "${!APP_PATHS[@]}"; do
        create_appstore_screenshots "$app"
    done
    
    # Generate HTML preview
    echo ""
    generate_html_preview
    
    # Summary
    echo ""
    cat << EOF

╔══════════════════════════════════════════════════════════╗
║                                                          ║
║                  ✅ COMPLETE ✅                          ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

📁 Screenshots: $SCREENSHOTS_DIR
📱 App Store ready: $SCREENSHOTS_DIR/appstore/
🌐 HTML Preview: $SCREENSHOTS_DIR/preview.html

EOF

    log_success "All screenshots generated successfully!"
}

main "$@"

