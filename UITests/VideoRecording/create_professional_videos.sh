#!/usr/bin/env bash
# Create Professional Marketing Videos for Field of Truth
# High-quality MP4 videos with branding, animations, and professional narration

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/FoTMarketingVideos"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }

# Setup directories
mkdir -p "$OUTPUT_DIR"/{raw,audio,final,assets}

# Create professional video with narration
create_professional_video() {
    local audio_file=$1
    local title=$2
    local subtitle=$3
    local platform=$4
    local output_file=$5
    
    log_info "Creating: $title"
    
    # Get audio duration
    local duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null)
    
    if [ -z "$duration" ]; then
        log_warning "Could not get audio duration, using 180s"
        duration=180
    fi
    
    # Create professional gradient background with platform-specific colors
    local color1="0x667eea"
    local color2="0x764ba2"
    
    case $platform in
        iOS)     color1="0x007AFF"; color2="0x5856D6" ;;
        watchOS) color1="0xFF3B30"; color2="0xFF9500" ;;
        macOS)   color1="0x5856D6"; color2="0x00C7BE" ;;
    esac
    
    # Create video with gradient, title, subtitle, and fade effects
    ffmpeg -f lavfi -i "color=c=${color1}:s=1920x1080:d=${duration}" \
        -f lavfi -i "color=c=${color2}:s=1920x1080:d=${duration}" \
        -i "$audio_file" \
        -filter_complex "\
            [0:v][1:v]blend=all_mode=overlay:all_opacity=0.5[bg]; \
            [bg]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='${title}':\
                fontcolor=white:\
                fontsize=80:\
                x=(w-text_w)/2:\
                y=(h-text_h)/2-150:\
                shadowcolor=black:\
                shadowx=3:\
                shadowy=3:\
                alpha='if(lt(t,1),t,if(lt(t,${duration}-2),1,(${duration}-t)/2))'[title]; \
            [title]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='${subtitle}':\
                fontcolor=white:\
                fontsize=48:\
                x=(w-text_w)/2:\
                y=(h-text_h)/2-50:\
                alpha='if(lt(t,1.5),(t-0.5)*2,if(lt(t,${duration}-2),1,(${duration}-t)/2))'[subtitle]; \
            [subtitle]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='${platform}':\
                fontcolor=white:\
                fontsize=36:\
                x=(w-text_w)/2:\
                y=(h-text_h)/2+50:\
                box=1:\
                boxcolor=black@0.5:\
                boxborderw=10:\
                alpha='if(lt(t,2),(t-1),if(lt(t,${duration}-2),1,(${duration}-t)/2))'[platform]; \
            [platform]drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:\
                text='foundation-of-truth.com':\
                fontcolor=white@0.7:\
                fontsize=28:\
                x=(w-text_w)/2:\
                y=h-100:\
                alpha='if(lt(t,3),(t-2),if(lt(t,${duration}-2),1,(${duration}-t)/2))'[final]" \
        -map "[final]" -map 2:a \
        -c:v libx264 -preset slow -crf 18 -profile:v high -pix_fmt yuv420p \
        -c:a aac -b:a 192k -ar 44100 \
        -movflags +faststart \
        -t "$duration" \
        -y "$output_file" 2>&1 | grep -E "(frame=|time=|size=)" || true
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | awk '{print $1}')
        log_success "Created: $(basename $output_file) ($size, ${duration}s)"
        return 0
    else
        log_warning "Failed to create: $(basename $output_file)"
        return 1
    fi
}

# Create all videos
create_all_videos() {
    log_header "Creating Professional Marketing Videos"
    
    local total=9
    local count=0
    
    # iOS Videos
    create_professional_video \
        "$OUTPUT_DIR/audio/Clinician_iOS.aiff" \
        "FoT Clinician" \
        "Clinical Decision Support That Proves Its Work" \
        "iOS" \
        "$OUTPUT_DIR/final/Clinician_iOS.mp4" && ((count++))
    
    create_professional_video \
        "$OUTPUT_DIR/audio/LegalUS_iOS.aiff" \
        "FoT Legal US" \
        "Legal Practice Management With Proof" \
        "iOS" \
        "$OUTPUT_DIR/final/LegalUS_iOS.mp4" && ((count++))
    
    create_professional_video \
        "$OUTPUT_DIR/audio/EducationK18_iOS.aiff" \
        "FoT Education K-18" \
        "Virtue-Guided Learning For Every Student" \
        "iOS" \
        "$OUTPUT_DIR/final/EducationK18_iOS.mp4" && ((count++))
    
    # watchOS Videos
    create_professional_video \
        "$OUTPUT_DIR/audio/Clinician_watchOS.aiff" \
        "FoT Clinician" \
        "Critical Clinical Data On Your Wrist" \
        "watchOS" \
        "$OUTPUT_DIR/final/Clinician_watchOS.mp4" && ((count++))
    
    create_professional_video \
        "$OUTPUT_DIR/audio/LegalUS_watchOS.aiff" \
        "FoT Legal US" \
        "Legal Alerts At Your Fingertips" \
        "watchOS" \
        "$OUTPUT_DIR/final/LegalUS_watchOS.mp4" && ((count++))
    
    create_professional_video \
        "$OUTPUT_DIR/audio/EducationK18_watchOS.aiff" \
        "FoT Education" \
        "Learning Companion For Young Minds" \
        "watchOS" \
        "$OUTPUT_DIR/final/EducationK18_watchOS.mp4" && ((count++))
    
    # macOS Videos
    create_professional_video \
        "$OUTPUT_DIR/audio/Clinician_macOS.aiff" \
        "FoT Clinician" \
        "Comprehensive Clinical Workspace" \
        "macOS" \
        "$OUTPUT_DIR/final/Clinician_macOS.mp4" && ((count++))
    
    create_professional_video \
        "$OUTPUT_DIR/audio/LegalUS_macOS.aiff" \
        "FoT Legal US" \
        "Complete Legal Practice Suite" \
        "macOS" \
        "$OUTPUT_DIR/final/LegalUS_macOS.mp4" && ((count++))
    
    create_professional_video \
        "$OUTPUT_DIR/audio/EducationK18_macOS.aiff" \
        "FoT Education" \
        "Complete Adaptive Learning Environment" \
        "macOS" \
        "$OUTPUT_DIR/final/EducationK18_macOS.mp4" && ((count++))
    
    echo ""
    log_success "Created $count/$total videos"
}

# Generate professional video index
generate_index() {
    log_header "Generating Video Gallery"
    
    cat > "$OUTPUT_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Field of Truth - Professional Marketing Videos</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #fff;
            padding: 40px 20px;
        }
        .container { max-width: 1600px; margin: 0 auto; }
        
        header {
            text-align: center;
            margin-bottom: 60px;
            animation: fadeInDown 1s ease;
        }
        h1 {
            font-size: 4rem;
            font-weight: 800;
            margin-bottom: 20px;
            text-shadow: 4px 4px 8px rgba(0,0,0,0.3);
            letter-spacing: -2px;
        }
        .tagline {
            font-size: 1.5rem;
            opacity: 0.95;
            font-weight: 300;
            letter-spacing: 0.5px;
        }
        
        .stats {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin: 40px 0;
            flex-wrap: wrap;
        }
        .stat {
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(10px);
            padding: 20px 40px;
            border-radius: 15px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .stat-number {
            font-size: 3rem;
            font-weight: 700;
            display: block;
        }
        .stat-label {
            font-size: 1rem;
            opacity: 0.9;
        }
        
        .domain-section {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(15px);
            border-radius: 25px;
            padding: 40px;
            margin-bottom: 40px;
            border: 1px solid rgba(255,255,255,0.2);
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
            animation: fadeInUp 1s ease;
        }
        .domain-section h2 {
            font-size: 2.5rem;
            margin-bottom: 15px;
            border-bottom: 3px solid rgba(255,255,255,0.3);
            padding-bottom: 15px;
            font-weight: 700;
        }
        .domain-description {
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 30px;
        }
        
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }
        
        .video-card {
            background: rgba(0,0,0,0.3);
            border-radius: 20px;
            padding: 25px;
            border: 2px solid rgba(255,255,255,0.2);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .video-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, rgba(255,255,255,0.05) 0%, transparent 100%);
            opacity: 0;
            transition: opacity 0.4s;
        }
        .video-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.4);
            border-color: rgba(255,255,255,0.4);
        }
        .video-card:hover::before {
            opacity: 1;
        }
        
        .video-card h3 {
            font-size: 1.8rem;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .platform-badge {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 700;
            margin-bottom: 20px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .ios { background: linear-gradient(135deg, #007AFF 0%, #5856D6 100%); }
        .watchos { background: linear-gradient(135deg, #FF3B30 0%, #FF9500 100%); }
        .macos { background: linear-gradient(135deg, #5856D6 0%, #00C7BE 100%); }
        
        .video-card video {
            width: 100%;
            border-radius: 12px;
            margin-bottom: 20px;
            background: #000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
        }
        
        .video-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
        }
        
        .duration {
            font-size: 1rem;
            opacity: 0.8;
        }
        
        .download-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.2);
            padding: 12px 24px;
            border-radius: 10px;
            text-decoration: none;
            color: #fff;
            font-weight: 700;
            transition: all 0.3s;
            border: 2px solid transparent;
        }
        .download-btn:hover {
            background: rgba(255,255,255,0.3);
            border-color: rgba(255,255,255,0.5);
            transform: scale(1.05);
        }
        
        .cta-section {
            text-align: center;
            margin-top: 80px;
            padding: 60px 40px;
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(15px);
            border-radius: 25px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .cta-section h2 {
            font-size: 3rem;
            margin-bottom: 20px;
            font-weight: 700;
        }
        .cta-section p {
            font-size: 1.3rem;
            margin-bottom: 30px;
            opacity: 0.95;
        }
        .cta-btn {
            display: inline-block;
            background: #fff;
            color: #667eea;
            padding: 20px 50px;
            border-radius: 15px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.3rem;
            transition: all 0.3s;
            box-shadow: 0 8px 20px rgba(0,0,0,0.3);
        }
        .cta-btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.4);
        }
        
        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @media (max-width: 768px) {
            h1 { font-size: 2.5rem; }
            .tagline { font-size: 1.2rem; }
            .video-grid { grid-template-columns: 1fr; }
            .stats { flex-direction: column; gap: 20px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🎬 Field of Truth</h1>
            <p class="tagline">Professional Marketing Videos</p>
            <div class="stats">
                <div class="stat">
                    <span class="stat-number">9</span>
                    <span class="stat-label">Professional Videos</span>
                </div>
                <div class="stat">
                    <span class="stat-number">3</span>
                    <span class="stat-label">Commercial Domains</span>
                </div>
                <div class="stat">
                    <span class="stat-number">3</span>
                    <span class="stat-label">Apple Platforms</span>
                </div>
            </div>
        </header>
        
        <div class="domain-section">
            <h2>🏥 Clinician - Clinical Decision Support</h2>
            <p class="domain-description">Clinical decision support that cryptographically proves every action, ensuring patient safety and regulatory compliance.</p>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iPhone & iPad</h3>
                    <span class="platform-badge ios">iOS</span>
                    <video controls preload="metadata">
                        <source src="final/Clinician_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/Clinician_iOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>Apple Watch</h3>
                    <span class="platform-badge watchos">watchOS</span>
                    <video controls preload="metadata">
                        <source src="final/Clinician_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/Clinician_watchOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>Mac</h3>
                    <span class="platform-badge macos">macOS</span>
                    <video controls preload="metadata">
                        <source src="final/Clinician_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/Clinician_macOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="domain-section">
            <h2>⚖️ Legal US - Legal Practice Management</h2>
            <p class="domain-description">Complete legal practice management with automated deadline calculation and cryptographic proof of every action.</p>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iPhone & iPad</h3>
                    <span class="platform-badge ios">iOS</span>
                    <video controls preload="metadata">
                        <source src="final/LegalUS_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/LegalUS_iOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>Apple Watch</h3>
                    <span class="platform-badge watchos">watchOS</span>
                    <video controls preload="metadata">
                        <source src="final/LegalUS_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/LegalUS_watchOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>Mac</h3>
                    <span class="platform-badge macos">macOS</span>
                    <video controls preload="metadata">
                        <source src="final/LegalUS_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/LegalUS_macOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="domain-section">
            <h2>🎓 Education K-18 - Adaptive Learning</h2>
            <p class="domain-description">Virtue-guided adaptive learning powered by Socratic dialogue, Wittgenstein language games, and Aristotelian ethics.</p>
            <div class="video-grid">
                <div class="video-card">
                    <h3>iPhone & iPad</h3>
                    <span class="platform-badge ios">iOS</span>
                    <video controls preload="metadata">
                        <source src="final/EducationK18_iOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/EducationK18_iOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>Apple Watch</h3>
                    <span class="platform-badge watchos">watchOS</span>
                    <video controls preload="metadata">
                        <source src="final/EducationK18_watchOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/EducationK18_watchOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
                <div class="video-card">
                    <h3>Mac</h3>
                    <span class="platform-badge macos">macOS</span>
                    <video controls preload="metadata">
                        <source src="final/EducationK18_macOS.mp4" type="video/mp4">
                    </video>
                    <div class="video-info">
                        <span class="duration">Professional Narration</span>
                        <a href="final/EducationK18_macOS.mp4" download class="download-btn">
                            ⬇ Download MP4
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="cta-section">
            <h2>Ready to Experience Field of Truth?</h2>
            <p>Join the revolution in verifiable, trustworthy AI</p>
            <a href="https://foundation-of-truth.com" class="cta-btn">Learn More →</a>
        </div>
    </div>
</body>
</html>
EOF
    
    log_success "Video gallery created: $OUTPUT_DIR/index.html"
}

# Main execution
main() {
    log_header "🎬 Professional Marketing Video Production"
    log_info "Creating high-quality MP4 videos with professional narration"
    
    create_all_videos
    generate_index
    
    log_header "✅ Production Complete!"
    log_success "All videos created in: $OUTPUT_DIR/final/"
    log_info "View gallery: open $OUTPUT_DIR/index.html"
    
    echo ""
    log_info "📊 Final Videos:"
    ls -lh "$OUTPUT_DIR/final"/*.mp4 2>/dev/null | awk '{print "   " $9 " - " $5}' || true
    
    echo ""
    log_info "🚀 Next Steps:"
    echo "   1. Open gallery: open $OUTPUT_DIR/index.html"
    echo "   2. Review videos for quality"
    echo "   3. Upload to YouTube/Vimeo"
    echo "   4. Share with investors/customers"
}

main "$@"

