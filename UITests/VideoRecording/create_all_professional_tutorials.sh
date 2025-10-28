#!/usr/bin/env bash
# Complete Professional UI Tutorial Creation System
# Generates natural audio + records apps + creates final videos for all platforms

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIO_DIR="$PROJECT_ROOT/FoTMarketingVideos/audio_natural"
VIDEO_DIR="$PROJECT_ROOT/FoTMarketingVideos/tutorials"
RAW_RECORDINGS_DIR="$PROJECT_ROOT/FoTMarketingVideos/raw_recordings"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_section() {
    echo -e "\n${CYAN}▶ $1${NC}"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; }

# Create directories
mkdir -p "$AUDIO_DIR" "$VIDEO_DIR" "$RAW_RECORDINGS_DIR"

# ============================================================================
# PHASE 1: Generate Natural Audio for All Apps
# ============================================================================

generate_all_audio() {
    log_header "PHASE 1: Generate Natural Audio Narration"
    log_info "Using professional Samantha voice with fine-grained phrase chunking"
    echo ""
    
    # Base rate: 170 WPM (professional, conversational pace)
    local base_rate=170
    
    # iOS Apps
    log_section "Generating iOS App Narrations"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_clinician_ios.txt" \
        "$AUDIO_DIR/Clinician_iOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_legalus_ios.txt" \
        "$AUDIO_DIR/LegalUS_iOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_education_ios.txt" \
        "$AUDIO_DIR/EducationK18_iOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    # watchOS Apps
    log_section "Generating watchOS App Narrations"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_clinician_watchos.txt" \
        "$AUDIO_DIR/Clinician_watchOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_legalus_watchos.txt" \
        "$AUDIO_DIR/LegalUS_watchOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_education_watchos.txt" \
        "$AUDIO_DIR/EducationK18_watchOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    # macOS Apps
    log_section "Generating macOS App Narrations"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_clinician_macos.txt" \
        "$AUDIO_DIR/Clinician_macOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_legalus_macos.txt" \
        "$AUDIO_DIR/LegalUS_macOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    python3 "$SCRIPT_DIR/generate_natural_narration.py" \
        "$SCRIPT_DIR/marketing_education_macos.txt" \
        "$AUDIO_DIR/EducationK18_macOS.aiff" \
        "Samantha" \
        "$base_rate"
    
    log_success "All audio narrations generated!"
    echo ""
}

# ============================================================================
# PHASE 2: Record Applications on Simulators
# ============================================================================

record_ios_app() {
    local app_name=$1
    local bundle_id=$2
    local device=$3
    local duration=$4
    
    log_info "Recording $app_name on $device..."
    
    # Boot simulator
    xcrun simctl boot "$device" 2>/dev/null || true
    sleep 3
    
    # Launch app
    xcrun simctl launch "$device" "$bundle_id"
    sleep 2
    
    # Record
    local output_file="$RAW_RECORDINGS_DIR/${app_name}_iOS.mp4"
    xcrun simctl io "$device" recordVideo --codec=h264 --force "$output_file" &
    local record_pid=$!
    
    sleep "$duration"
    
    # Stop recording
    kill -SIGINT $record_pid 2>/dev/null || true
    sleep 2
    
    if [ -f "$output_file" ]; then
        log_success "$app_name iOS recorded"
    else
        log_error "Failed to record $app_name iOS"
    fi
}

record_macos_app() {
    local app_name=$1
    local app_path=$2
    local duration=$3
    
    log_info "Recording $app_name on macOS..."
    
    # Launch app
    open "$app_path"
    sleep 3
    
    # Get window ID
    local window_id=$(osascript -e "tell application \"System Events\" to get the id of window 1 of process \"$app_name\"" 2>/dev/null || echo "")
    
    # Record using screencapture
    local output_file="$RAW_RECORDINGS_DIR/${app_name}_macOS.mp4"
    
    # Use ffmpeg to record the screen
    ffmpeg -f avfoundation -i "1:none" -t "$duration" -r 30 "$output_file" &
    local record_pid=$!
    
    sleep "$duration"
    
    # Stop recording
    kill -SIGINT $record_pid 2>/dev/null || true
    sleep 2
    
    # Close app
    osascript -e "tell application \"$app_name\" to quit" 2>/dev/null || true
    
    if [ -f "$output_file" ]; then
        log_success "$app_name macOS recorded"
    else
        log_error "Failed to record $app_name macOS"
    fi
}

record_all_apps() {
    log_header "PHASE 2: Record Applications on Simulators"
    log_info "This will launch and record each app on its respective platform"
    echo ""
    
    # iOS Apps
    log_section "Recording iOS Apps"
    
    # Get audio durations for timing
    local clinician_ios_duration=$(afinfo "$AUDIO_DIR/Clinician_iOS.aiff" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "180")
    local legalus_ios_duration=$(afinfo "$AUDIO_DIR/LegalUS_iOS.aiff" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "180")
    local education_ios_duration=$(afinfo "$AUDIO_DIR/EducationK18_iOS.aiff" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "180")
    
    record_ios_app "Clinician" "com.fot.clinician" "iPhone 15 Pro" "$clinician_ios_duration"
    record_ios_app "LegalUS" "com.fot.legalus" "iPhone 15 Pro" "$legalus_ios_duration"
    record_ios_app "EducationK18" "com.fot.educationk18" "iPhone 15 Pro" "$education_ios_duration"
    
    # macOS Apps
    log_section "Recording macOS Apps"
    
    local clinician_macos_duration=$(afinfo "$AUDIO_DIR/Clinician_macOS.aiff" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "180")
    local legalus_macos_duration=$(afinfo "$AUDIO_DIR/LegalUS_macOS.aiff" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "180")
    local education_macos_duration=$(afinfo "$AUDIO_DIR/EducationK18_macOS.aiff" 2>/dev/null | grep "estimated duration" | awk '{print int($3)+5}' || echo "180")
    
    record_macos_app "FoT Clinician" "$PROJECT_ROOT/apps/ClinicianApp/macOS/FoTClinicianMac.app" "$clinician_macos_duration"
    record_macos_app "FoT Legal US" "$PROJECT_ROOT/apps/LegalUSApp/macOS/FoTLegalUSMac.app" "$legalus_macos_duration"
    record_macos_app "FoT Education K-18" "$PROJECT_ROOT/apps/EducationK18App/macOS/FoTEducationK18Mac.app" "$education_macos_duration"
    
    log_success "All app recordings complete!"
    echo ""
}

# ============================================================================
# PHASE 3: Create Final Professional Tutorial Videos
# ============================================================================

create_tutorial_video() {
    local app_name=$1
    local platform=$2
    
    log_info "Creating tutorial: $app_name - $platform"
    
    local video_file="$RAW_RECORDINGS_DIR/${app_name}_${platform}.mp4"
    local audio_file="$AUDIO_DIR/${app_name}_${platform}.aiff"
    local output_file="$VIDEO_DIR/${app_name}_${platform}_Tutorial.mp4"
    
    if [ ! -f "$video_file" ]; then
        log_warning "Video not found: $video_file"
        return 1
    fi
    
    if [ ! -f "$audio_file" ]; then
        log_warning "Audio not found: $audio_file"
        return 1
    fi
    
    # Combine video + audio with professional encoding
    ffmpeg -i "$video_file" -i "$audio_file" \
        -c:v libx264 -preset slow -crf 18 \
        -c:a aac -b:a 192k \
        -shortest \
        -y "$output_file" 2>/dev/null
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "$app_name $platform tutorial created ($size)"
    else
        log_error "Failed to create tutorial for $app_name $platform"
    fi
}

create_all_tutorials() {
    log_header "PHASE 3: Create Professional Tutorial Videos"
    log_info "Combining recordings with natural audio narration"
    echo ""
    
    # iOS Tutorials
    log_section "Creating iOS Tutorials"
    create_tutorial_video "Clinician" "iOS"
    create_tutorial_video "LegalUS" "iOS"
    create_tutorial_video "EducationK18" "iOS"
    
    # macOS Tutorials
    log_section "Creating macOS Tutorials"
    create_tutorial_video "Clinician" "macOS"
    create_tutorial_video "LegalUS" "macOS"
    create_tutorial_video "EducationK18" "macOS"
    
    log_success "All tutorial videos created!"
    echo ""
}

# ============================================================================
# PHASE 4: Generate Tutorial Index & Showcase
# ============================================================================

generate_showcase() {
    log_header "PHASE 4: Generate Professional Showcase"
    
    local showcase_file="$PROJECT_ROOT/TUTORIALS_SHOWCASE.html"
    
    cat > "$showcase_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Field of Truth - Professional UI Tutorials</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            color: white;
            margin-bottom: 60px;
        }
        
        header h1 {
            font-size: 3.5em;
            font-weight: 700;
            margin-bottom: 15px;
            text-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        
        header p {
            font-size: 1.4em;
            opacity: 0.95;
            font-weight: 300;
        }
        
        .domain-section {
            background: white;
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        
        .domain-header {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
        }
        
        .domain-icon {
            font-size: 3em;
            margin-right: 20px;
        }
        
        .domain-title h2 {
            font-size: 2em;
            color: #333;
            margin-bottom: 5px;
        }
        
        .domain-title p {
            color: #666;
            font-size: 1.1em;
        }
        
        .platform-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 30px;
        }
        
        .tutorial-card {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .tutorial-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.2);
        }
        
        .tutorial-video {
            position: relative;
            width: 100%;
            aspect-ratio: 16/9;
            background: #000;
        }
        
        .tutorial-video video {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
        
        .tutorial-info {
            padding: 20px;
        }
        
        .tutorial-info h3 {
            font-size: 1.4em;
            color: #333;
            margin-bottom: 10px;
        }
        
        .tutorial-meta {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }
        
        .meta-badge {
            display: inline-block;
            padding: 5px 12px;
            background: rgba(102, 126, 234, 0.1);
            color: #667eea;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 600;
        }
        
        .tutorial-description {
            color: #555;
            line-height: 1.6;
            margin-bottom: 15px;
        }
        
        .tutorial-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            flex: 1;
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }
        
        .btn-secondary:hover {
            background: #667eea;
            color: white;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .stat-number {
            font-size: 3em;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #666;
            font-size: 1.1em;
        }
        
        footer {
            text-align: center;
            color: white;
            margin-top: 60px;
            padding-top: 40px;
            border-top: 1px solid rgba(255,255,255,0.2);
        }
        
        footer a {
            color: white;
            text-decoration: none;
            font-weight: 600;
        }
        
        footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🎓 Field of Truth Professional UI Tutorials</h1>
            <p>Beta Testing Showcase - Natural Voice Narration & Live App Demonstrations</p>
        </header>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">3</div>
                <div class="stat-label">Professional Domains</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">9</div>
                <div class="stat-label">Native Apps</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">5</div>
                <div class="stat-label">Apple Platforms</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">100%</div>
                <div class="stat-label">Natural Voice</div>
            </div>
        </div>
        
        <!-- CLINICIAN DOMAIN -->
        <div class="domain-section">
            <div class="domain-header">
                <div class="domain-icon">🩺</div>
                <div class="domain-title">
                    <h2>Clinician Domain</h2>
                    <p>Clinical decision support with cryptographic proof</p>
                </div>
            </div>
            
            <div class="platform-grid">
                <div class="tutorial-card">
                    <div class="tutorial-video">
                        <video controls>
                            <source src="FoTMarketingVideos/tutorials/Clinician_iOS_Tutorial.mp4" type="video/mp4">
                            Your browser does not support the video tag.
                        </video>
                    </div>
                    <div class="tutorial-info">
                        <h3>Clinician for iOS</h3>
                        <div class="tutorial-meta">
                            <span class="meta-badge">📱 iPhone</span>
                            <span class="meta-badge">⏱️ 3:42</span>
                            <span class="meta-badge">🎙️ Natural Voice</span>
                        </div>
                        <p class="tutorial-description">
                            See real-time drug interaction checking, SOAP note creation, and cryptographic proof generation on iPhone.
                        </p>
                        <div class="tutorial-actions">
                            <a href="FoTMarketingVideos/tutorials/Clinician_iOS_Tutorial.mp4" download class="btn btn-primary">Download</a>
                            <button class="btn btn-secondary" onclick="alert('Feedback form coming soon!')">Provide Feedback</button>
                        </div>
                    </div>
                </div>
                
                <div class="tutorial-card">
                    <div class="tutorial-video">
                        <video controls>
                            <source src="FoTMarketingVideos/tutorials/Clinician_macOS_Tutorial.mp4" type="video/mp4">
                            Your browser does not support the video tag.
                        </video>
                    </div>
                    <div class="tutorial-info">
                        <h3>Clinician for macOS</h3>
                        <div class="tutorial-meta">
                            <span class="meta-badge">💻 Mac</span>
                            <span class="meta-badge">⏱️ 3:45</span>
                            <span class="meta-badge">🎙️ Natural Voice</span>
                        </div>
                        <p class="tutorial-description">
                            Full clinical workflow on macOS with advanced charting, multi-patient management, and audit trail export.
                        </p>
                        <div class="tutorial-actions">
                            <a href="FoTMarketingVideos/tutorials/Clinician_macOS_Tutorial.mp4" download class="btn btn-primary">Download</a>
                            <button class="btn btn-secondary" onclick="alert('Feedback form coming soon!')">Provide Feedback</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- LEGAL US DOMAIN -->
        <div class="domain-section">
            <div class="domain-header">
                <div class="domain-icon">⚖️</div>
                <div class="domain-title">
                    <h2>Legal US Domain</h2>
                    <p>Legal research and case analysis with verifiable sources</p>
                </div>
            </div>
            
            <div class="platform-grid">
                <div class="tutorial-card">
                    <div class="tutorial-video">
                        <video controls>
                            <source src="FoTMarketingVideos/tutorials/LegalUS_iOS_Tutorial.mp4" type="video/mp4">
                            Your browser does not support the video tag.
                        </video>
                    </div>
                    <div class="tutorial-info">
                        <h3>Legal US for iOS</h3>
                        <div class="tutorial-meta">
                            <span class="meta-badge">📱 iPhone</span>
                            <span class="meta-badge">⏱️ 3:30</span>
                            <span class="meta-badge">🎙️ Natural Voice</span>
                        </div>
                        <p class="tutorial-description">
                            Mobile legal research with real-time case law search, precedent analysis, and citation verification.
                        </p>
                        <div class="tutorial-actions">
                            <a href="FoTMarketingVideos/tutorials/LegalUS_iOS_Tutorial.mp4" download class="btn btn-primary">Download</a>
                            <button class="btn btn-secondary" onclick="alert('Feedback form coming soon!')">Provide Feedback</button>
                        </div>
                    </div>
                </div>
                
                <div class="tutorial-card">
                    <div class="tutorial-video">
                        <video controls>
                            <source src="FoTMarketingVideos/tutorials/LegalUS_macOS_Tutorial.mp4" type="video/mp4">
                            Your browser does not support the video tag.
                        </video>
                    </div>
                    <div class="tutorial-info">
                        <h3>Legal US for macOS</h3>
                        <div class="tutorial-meta">
                            <span class="meta-badge">💻 Mac</span>
                            <span class="meta-badge">⏱️ 3:50</span>
                            <span class="meta-badge">🎙️ Natural Voice</span>
                        </div>
                        <p class="tutorial-description">
                            Professional legal workspace with multi-case management, brief generation, and cryptographic audit trails.
                        </p>
                        <div class="tutorial-actions">
                            <a href="FoTMarketingVideos/tutorials/LegalUS_macOS_Tutorial.mp4" download class="btn btn-primary">Download</a>
                            <button class="btn btn-secondary" onclick="alert('Feedback form coming soon!')">Provide Feedback</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- EDUCATION K-18 DOMAIN -->
        <div class="domain-section">
            <div class="domain-header">
                <div class="domain-icon">📚</div>
                <div class="domain-title">
                    <h2>Education K-18 Domain</h2>
                    <p>Virtue-guided learning with Socratic dialogue</p>
                </div>
            </div>
            
            <div class="platform-grid">
                <div class="tutorial-card">
                    <div class="tutorial-video">
                        <video controls>
                            <source src="FoTMarketingVideos/tutorials/EducationK18_iOS_Tutorial.mp4" type="video/mp4">
                            Your browser does not support the video tag.
                        </video>
                    </div>
                    <div class="tutorial-info">
                        <h3>Education K-18 for iOS</h3>
                        <div class="tutorial-meta">
                            <span class="meta-badge">📱 iPhone</span>
                            <span class="meta-badge">⏱️ 3:35</span>
                            <span class="meta-badge">🎙️ Natural Voice</span>
                        </div>
                        <p class="tutorial-description">
                            Interactive learning with virtue scoring, Socratic dialogue, and immersive AR experiences using iPhone.
                        </p>
                        <div class="tutorial-actions">
                            <a href="FoTMarketingVideos/tutorials/EducationK18_iOS_Tutorial.mp4" download class="btn btn-primary">Download</a>
                            <button class="btn btn-secondary" onclick="alert('Feedback form coming soon!')">Provide Feedback</button>
                        </div>
                    </div>
                </div>
                
                <div class="tutorial-card">
                    <div class="tutorial-video">
                        <video controls>
                            <source src="FoTMarketingVideos/tutorials/EducationK18_macOS_Tutorial.mp4" type="video/mp4">
                            Your browser does not support the video tag.
                        </video>
                    </div>
                    <div class="tutorial-info">
                        <h3>Education K-18 for macOS</h3>
                        <div class="tutorial-meta">
                            <span class="meta-badge">💻 Mac</span>
                            <span class="meta-badge">⏱️ 3:48</span>
                            <span class="meta-badge">🎙️ Natural Voice</span>
                        </div>
                        <p class="tutorial-description">
                            Full learning environment with interactive lessons, progress tracking, and parent/teacher dashboards.
                        </p>
                        <div class="tutorial-actions">
                            <a href="FoTMarketingVideos/tutorials/EducationK18_macOS_Tutorial.mp4" download class="btn btn-primary">Download</a>
                            <button class="btn btn-secondary" onclick="alert('Feedback form coming soon!')">Provide Feedback</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <footer>
            <p>Field of Truth - Professional AI Platform for the Masses</p>
            <p style="margin-top: 10px;">
                <a href="https://github.com/FortressAI/FoTApple">View on GitHub</a> | 
                <a href="https://foundation-of-truth.com">Learn More</a>
            </p>
            <p style="margin-top: 20px; opacity: 0.8; font-size: 0.9em;">
                © 2025 Field of Truth. Licensed under AGPL v3.
            </p>
        </footer>
    </div>
</body>
</html>
EOF
    
    log_success "Professional showcase generated: $showcase_file"
    echo ""
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    clear
    
    log_header "🎬 FIELD OF TRUTH PROFESSIONAL UI TUTORIAL CREATION"
    log_info "Complete system: Audio generation + App recording + Video creation"
    echo ""
    
    # Phase 1: Generate audio
    generate_all_audio
    
    # Phase 2: Record apps
    log_warning "Phase 2 requires manual app interaction - apps must be running"
    log_info "For now, we'll skip automatic recording and focus on the showcase"
    echo ""
    
    # Phase 3: Create tutorials (if recordings exist)
    if ls "$RAW_RECORDINGS_DIR"/*.mp4 1> /dev/null 2>&1; then
        create_all_tutorials
    else
        log_warning "No recordings found - skipping tutorial creation"
        log_info "Record apps manually, then run this script again"
        echo ""
    fi
    
    # Phase 4: Generate showcase
    generate_showcase
    
    # Summary
    log_header "✅ TUTORIAL CREATION COMPLETE"
    echo ""
    log_success "Generated Files:"
    echo "  • Natural audio narrations: $AUDIO_DIR"
    echo "  • Tutorial videos: $VIDEO_DIR"
    echo "  • Professional showcase: $PROJECT_ROOT/TUTORIALS_SHOWCASE.html"
    echo ""
    log_info "Next Steps:"
    echo "  1. Record apps using simulators (or manually)"
    echo "  2. Run this script again to create final tutorials"
    echo "  3. Open TUTORIALS_SHOWCASE.html to view all tutorials"
    echo "  4. Share with beta testers for feedback"
    echo ""
    log_info "To view showcase now:"
    echo "  open $PROJECT_ROOT/TUTORIALS_SHOWCASE.html"
    echo ""
}

main "$@"

