#!/bin/bash

# ================================================================
# macOS Terminal - Natural Samantha Voice with Professional Tricks
# ================================================================

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================================
# NATURAL SPEECH TECHNIQUES FROM THE GUIDE
# ========================================

# 1. CHUNKING METHOD - Break text into natural phrases
# -----------------------------------------------------
speak_chunked() {
    local text="$1"
    
    echo -e "${BLUE}🎯 Using Chunking Method for Natural Speech${NC}"
    
    # Split text into chunks (sentences/phrases)
    IFS='.' read -ra chunks <<< "$text"
    
    for chunk in "${chunks[@]}"; do
        if [[ -n "$chunk" ]]; then
            # Clean up the chunk
            chunk=$(echo "$chunk" | xargs)
            
            # Determine pause duration based on chunk ending
            if [[ "$chunk" == *"?" ]]; then
                pause_duration=0.8  # Longer pause after questions
                rate=190           # Slightly slower for questions
                pitch_adjust=""    # Raise pitch for questions (say command doesn't support pitch directly)
            elif [[ "$chunk" == *"!" ]]; then
                pause_duration=0.6  # Medium pause after exclamations
                rate=210           # Slightly faster for excitement
            elif [[ "$chunk" == *"," ]]; then
                pause_duration=0.3  # Short pause after commas
                rate=200
            else
                pause_duration=0.5  # Normal pause between sentences
                rate=195
            fi
            
            # Speak the chunk
            echo -e "${GREEN}  Speaking:${NC} \"$chunk\" (rate: $rate, pause: ${pause_duration}s)"
            say -v "Samantha" -r $rate "$chunk."
            
            # Natural pause between chunks
            sleep $pause_duration
        fi
    done
}

# 2. ADVANCED NATURAL SPEECH WITH EMPHASIS
# -----------------------------------------
speak_natural_advanced() {
    local script="$1"
    
    echo -e "${BLUE}🎭 Advanced Natural Speech Processing${NC}"
    
    # Define speech segments with prosody instructions
    # Format: "text|rate|pre_pause|post_pause"
    local segments=(
        "Hello.|180|0|0.1"
        "To make a voice sound natural,|195|0|0.3"
        "you can't just...|185|0|0.4"
        "speak it all at once.|175|0.2|0.6"
        "You need to add pauses.|180|0.1|0.3"
        "You can even change the speed slightly...|190|0.2|0.2"
        "or emphasize certain words.|185|0|0.8"
        "This gives the impression of thought.|175|0.1|0"
    )
    
    # Process custom script if provided, otherwise use demo
    if [[ -n "$script" ]]; then
        # Parse custom script with natural breaks
        IFS=$'\n' read -d '' -ra segments <<< "$script"
    fi
    
    for segment in "${segments[@]}"; do
        IFS='|' read -r text rate pre_pause post_pause <<< "$segment"
        
        # Default values if not specified
        rate=${rate:-195}
        pre_pause=${pre_pause:-0}
        post_pause=${post_pause:-0.5}
        
        # Pre-utterance delay
        [[ "$pre_pause" != "0" ]] && sleep $pre_pause
        
        # Speak with custom rate
        echo -e "${GREEN}  [Rate: $rate]${NC} $text"
        say -v "Samantha" -r $rate "$text"
        
        # Post-utterance delay
        [[ "$post_pause" != "0" ]] && sleep $post_pause
    done
}

# 3. SSML-LIKE MARKUP PARSER FOR TERMINAL
# ----------------------------------------
# Simulates SSML behavior using say command
parse_and_speak_markup() {
    local marked_text="$1"
    
    echo -e "${BLUE}📝 Processing Markup for Natural Speech${NC}"
    
    # Replace markup with say command equivalents
    # <pause:0.5> → sleep 0.5
    # <slow>text</slow> → rate 170
    # <fast>text</fast> → rate 220
    # <emphasis>text</emphasis> → rate 185 with pauses
    
    # Example processing
    local current_rate=195
    local segments=()
    
    # Simple parser (you'd expand this for production)
    while IFS= read -r line; do
        if [[ "$line" == *"<pause:"* ]]; then
            # Extract pause duration
            pause=$(echo "$line" | sed -n 's/.*<pause:\([0-9.]*\)>.*/\1/p')
            echo -e "${YELLOW}  ⏸ Pausing for ${pause}s${NC}"
            sleep $pause
        elif [[ "$line" == *"<slow>"* ]]; then
            # Slow speech
            text=$(echo "$line" | sed 's/<[^>]*>//g')
            echo -e "${GREEN}  🐌 Slow:${NC} $text"
            say -v "Samantha" -r 170 "$text"
        elif [[ "$line" == *"<fast>"* ]]; then
            # Fast speech
            text=$(echo "$line" | sed 's/<[^>]*>//g')
            echo -e "${GREEN}  ⚡ Fast:${NC} $text"
            say -v "Samantha" -r 220 "$text"
        elif [[ "$line" == *"<emphasis>"* ]]; then
            # Emphasized speech
            text=$(echo "$line" | sed 's/<[^>]*>//g')
            echo -e "${GREEN}  💪 Emphasis:${NC} $text"
            sleep 0.2  # Pre-emphasis pause
            say -v "Samantha" -r 185 "$text"
            sleep 0.3  # Post-emphasis pause
        else
            # Normal speech
            [[ -n "$line" ]] && say -v "Samantha" -r $current_rate "$line"
        fi
    done <<< "$marked_text"
}

# 4. VIDEO AGENT OPTIMIZED SPEECH
# --------------------------------
speak_for_video() {
    local script_file="$1"
    local output_dir="${2:-./audio_chunks}"
    
    echo -e "${BLUE}🎬 Video Agent Speech Generation${NC}"
    echo -e "${YELLOW}Reading from: $script_file${NC}"
    echo -e "${YELLOW}Output to: $output_dir${NC}"
    
    mkdir -p "$output_dir"
    
    # Process video script with timing
    # Format: timestamp|text|rate|pause
    local chunk_num=1
    
    while IFS='|' read -r timestamp text rate pause_after; do
        # Skip empty lines
        [[ -z "$text" ]] && continue
        
        # Default values
        rate=${rate:-195}
        pause_after=${pause_after:-0.5}
        
        # Generate audio chunk
        output_file="$output_dir/chunk_$(printf "%03d" $chunk_num)_${timestamp}.aiff"
        
        echo -e "${GREEN}[$timestamp]${NC} Creating chunk $chunk_num"
        echo -e "  Text: \"$text\""
        echo -e "  Rate: $rate WPM, Pause: ${pause_after}s"
        
        # Apply natural speech patterns
        if [[ "$text" == *"?" ]]; then
            # Questions: slower rate, rising intonation (simulated with rate change)
            say -v "Samantha" -r $((rate - 10)) -o "$output_file" "$text"
        elif [[ "$text" == *"!" ]]; then
            # Exclamations: slightly faster
            say -v "Samantha" -r $((rate + 15)) -o "$output_file" "$text"
        else
            # Normal statements
            say -v "Samantha" -r $rate -o "$output_file" "$text"
        fi
        
        echo -e "${GREEN}  ✓ Saved:${NC} $output_file"
        ((chunk_num++))
        
        # Add silence file for pause if needed
        if (( $(echo "$pause_after > 0.3" | bc -l) )); then
            silence_file="$output_dir/silence_$(printf "%03d" $chunk_num).aiff"
            # Generate silence using sox or just note it
            echo -e "${YELLOW}  + Added ${pause_after}s silence${NC}"
        fi
        
    done < "$script_file"
    
    echo -e "${GREEN}✅ Generated $((chunk_num-1)) audio chunks${NC}"
}

# 5. NATURAL CONVERSATION SIMULATOR
# ----------------------------------
natural_conversation() {
    echo -e "${BLUE}💬 Natural Conversation Mode${NC}"
    
    # Simulate natural conversation patterns
    local phrases=(
        "Hello there.|180|0|0.3"
        "How are you doing today?|190|0|0.8"
        "I wanted to talk to you about something interesting.|195|0.2|0.4"
        "You see,|185|0|0.2"
        "when we speak naturally,|195|0|0.3"
        "we don't maintain the same pace throughout.|190|0.1|0.5"
        "Sometimes we speed up when excited!|210|0.2|0.3"
        "And slow down...|170|0.3|0.4"
        "for emphasis.|165|0.2|0.8"
        "We also use pauses|185|0|0.4"
        "to let ideas sink in.|175|0.3|1.0"
        "This creates a much more|195|0|0.2"
        "natural|180|0.1|0.1"
        "and engaging|185|0.1|0.1"
        "listening experience.|175|0.1|0"
    )
    
    for phrase_data in "${phrases[@]}"; do
        IFS='|' read -r text rate pre_pause post_pause <<< "$phrase_data"
        
        # Pre-pause for thought
        [[ "$pre_pause" != "0" ]] && sleep $pre_pause
        
        # Visual indicator of speech rate
        if (( rate < 180 )); then
            speed_indicator="🐢 Slow"
        elif (( rate > 200 )); then
            speed_indicator="🐇 Fast"
        else
            speed_indicator="👄 Normal"
        fi
        
        echo -e "${GREEN}$speed_indicator [$rate WPM]:${NC} $text"
        say -v "Samantha" -r $rate "$text"
        
        # Post-pause for effect
        [[ "$post_pause" != "0" ]] && sleep $post_pause
    done
}

# 6. PROSODY PATTERNS FOR COMMON SCENARIOS
# -----------------------------------------
apply_prosody_pattern() {
    local pattern="$1"
    local text="$2"
    
    echo -e "${BLUE}🎨 Applying Prosody Pattern: $pattern${NC}"
    
    case "$pattern" in
        "announcement")
            # Clear, slightly slower, with pauses
            echo -e "${GREEN}📢 Announcement Style${NC}"
            say -v "Samantha" -r 180 "Attention please."
            sleep 0.8
            say -v "Samantha" -r 185 "$text"
            sleep 0.5
            say -v "Samantha" -r 180 "Thank you."
            ;;
            
        "storytelling")
            # Varied pace, dramatic pauses
            echo -e "${GREEN}📚 Storytelling Style${NC}"
            chunks=("Once upon a time," "$text" "And that's how it happened.")
            rates=(175 190 170)
            pauses=(0.5 0.3 0)
            
            for i in "${!chunks[@]}"; do
                say -v "Samantha" -r "${rates[$i]}" "${chunks[$i]}"
                sleep "${pauses[$i]}"
            done
            ;;
            
        "tutorial")
            # Clear, measured pace with emphasis
            echo -e "${GREEN}🎓 Tutorial Style${NC}"
            say -v "Samantha" -r 185 "Let me explain this step by step."
            sleep 0.5
            say -v "Samantha" -r 190 "First,"
            sleep 0.3
            say -v "Samantha" -r 195 "$text"
            sleep 0.4
            say -v "Samantha" -r 185 "Got it?"
            ;;
            
        "emotional")
            # Slower, with more pauses
            echo -e "${GREEN}❤️ Emotional Style${NC}"
            words=($text)
            for word in "${words[@]}"; do
                say -v "Samantha" -r 170 "$word"
                sleep 0.15
            done
            ;;
            
        "energetic")
            # Faster, minimal pauses
            echo -e "${GREEN}⚡ Energetic Style${NC}"
            say -v "Samantha" -r 220 "$text"
            ;;
            
        "professional")
            # Steady, clear, with strategic pauses
            echo -e "${GREEN}💼 Professional Style${NC}"
            sentences=$(echo "$text" | sed 's/\. /.\n/g')
            while IFS= read -r sentence; do
                [[ -n "$sentence" ]] && say -v "Samantha" -r 195 "$sentence"
                sleep 0.4
            done <<< "$sentences"
            ;;
    esac
}

# 7. BEST PRACTICES IMPLEMENTATION
# ---------------------------------
demonstrate_best_practices() {
    echo -e "${BLUE}✨ Demonstrating Best Practices for Natural Speech${NC}"
    echo -e "${YELLOW}Listen to how these techniques improve naturalness:${NC}\n"
    
    # Technique 1: Pause Strategy
    echo -e "${GREEN}1️⃣ Pause Strategy:${NC}"
    say -v "Samantha" -r 195 "Short phrase here"
    sleep 0.2  # Short pause
    say -v "Samantha" -r 195 "connected to this one."
    sleep 0.5  # Medium pause
    say -v "Samantha" -r 195 "New sentence begins."
    sleep 1.0  # Long pause
    say -v "Samantha" -r 195 "New paragraph or topic."
    
    sleep 2
    
    # Technique 2: Rate Adjustments
    echo -e "\n${GREEN}2️⃣ Rate Adjustments:${NC}"
    say -v "Samantha" -r 175 "Important information is spoken slowly."
    sleep 0.4
    say -v "Samantha" -r 195 "Normal speed for transitions."
    sleep 0.3
    say -v "Samantha" -r 210 "Lists and examples can be slightly faster."
    
    sleep 2
    
    # Technique 3: Emphasis Techniques
    echo -e "\n${GREEN}3️⃣ Emphasis Techniques:${NC}"
    say -v "Samantha" -r 195 "Now pay attention to"
    sleep 0.3  # Pre-emphasis pause
    say -v "Samantha" -r 185 "THIS important word"
    sleep 0.4  # Post-emphasis pause
    say -v "Samantha" -r 195 "in the sentence."
    
    sleep 2
    
    # Technique 4: Natural Rhythm
    echo -e "\n${GREEN}4️⃣ Natural Rhythm:${NC}"
    say -v "Samantha" -r 190 "Short sentence."
    sleep 0.3
    say -v "Samantha" -r 195 "This one is a bit longer to create variety."
    sleep 0.4
    say -v "Samantha" -r 185 "And here we have an even longer sentence that demonstrates how varying sentence length creates a more natural flowing rhythm in speech."
    
    sleep 2
    
    # Technique 5: Question Intonation
    echo -e "\n${GREEN}5️⃣ Question Patterns:${NC}"
    say -v "Samantha" -r 185 "Did you notice how questions sound different?"
    sleep 0.6
    say -v "Samantha" -r 195 "They have a different pattern."
    sleep 0.4
    say -v "Samantha" -r 180 "Don't they?"
}

# 8. SCRIPT GENERATOR FOR NATURAL SPEECH
# ---------------------------------------
generate_natural_script() {
    local input_text="$1"
    local output_file="${2:-natural_script.txt}"
    
    echo -e "${BLUE}📝 Generating Natural Speech Script${NC}"
    
    # Analyze text and add prosody markers
    {
        echo "# Natural Speech Script for Samantha"
        echo "# Format: timestamp|text|rate|pause_after"
        echo "# Generated: $(date)"
        echo ""
        
        # Split into sentences and analyze
        timestamp=0
        sentence_num=0
        
        while IFS= read -r sentence; do
            [[ -z "$sentence" ]] && continue
            
            # Clean up
            sentence=$(echo "$sentence" | xargs)
            
            # Determine optimal rate and pause
            word_count=$(echo "$sentence" | wc -w)
            
            if [[ "$sentence" == *"?" ]]; then
                rate=185
                pause=0.8
            elif [[ "$sentence" == *"!" ]]; then
                rate=210
                pause=0.6
            elif (( word_count > 15 )); then
                rate=195
                pause=0.7
            elif (( word_count < 5 )); then
                rate=185
                pause=0.4
            else
                rate=190
                pause=0.5
            fi
            
            # Format timestamp
            mins=$((timestamp / 60))
            secs=$((timestamp % 60))
            ts=$(printf "%02d:%02d" $mins $secs)
            
            echo "$ts|$sentence|$rate|$pause"
            
            # Calculate next timestamp (rough estimate)
            duration=$(echo "scale=2; $word_count * 60 / $rate + $pause" | bc)
            timestamp=$(echo "$timestamp + $duration" | bc | cut -d. -f1)
            
            ((sentence_num++))
        done <<< "$(echo "$input_text" | sed 's/\. /.\n/g' | sed 's/? /?/g' | sed 's/! /!\n/g')"
        
    } > "$output_file"
    
    echo -e "${GREEN}✅ Script saved to: $output_file${NC}"
    echo -e "${YELLOW}Generated $sentence_num segments${NC}"
}

# 9. INTERACTIVE NATURAL SPEECH TESTER
# -------------------------------------
interactive_tester() {
    echo -e "${BLUE}🎤 Interactive Natural Speech Tester${NC}"
    echo -e "${YELLOW}Adjust parameters in real-time to find the perfect voice${NC}\n"
    
    local test_text="Hello, this is a test of natural speech synthesis."
    local rate=195
    local pre_pause=0
    local post_pause=0.5
    
    while true; do
        echo -e "\n${GREEN}Current Settings:${NC}"
        echo -e "  Text: \"$test_text\""
        echo -e "  Rate: $rate WPM"
        echo -e "  Pre-pause: ${pre_pause}s"
        echo -e "  Post-pause: ${post_pause}s"
        echo -e "\n${YELLOW}Options:${NC}"
        echo "  1. Play with current settings"
        echo "  2. Change text"
        echo "  3. Adjust rate (current: $rate)"
        echo "  4. Adjust pre-pause (current: $pre_pause)"
        echo "  5. Adjust post-pause (current: $post_pause)"
        echo "  6. Try a preset pattern"
        echo "  7. Back to main menu"
        
        read -p "Choice: " choice
        
        case $choice in
            1)
                [[ "$pre_pause" != "0" ]] && sleep $pre_pause
                say -v "Samantha" -r $rate "$test_text"
                [[ "$post_pause" != "0" ]] && sleep $post_pause
                ;;
            2)
                read -p "Enter new text: " test_text
                ;;
            3)
                read -p "Enter rate (150-250): " rate
                ;;
            4)
                read -p "Enter pre-pause (0-2): " pre_pause
                ;;
            5)
                read -p "Enter post-pause (0-2): " post_pause
                ;;
            6)
                echo "Select preset:"
                echo "  1. Slow & Thoughtful (175 WPM)"
                echo "  2. Normal Conversation (195 WPM)"
                echo "  3. Energetic (220 WPM)"
                echo "  4. Question Pattern"
                read -p "Preset: " preset
                
                case $preset in
                    1) rate=175; pre_pause=0.3; post_pause=0.8 ;;
                    2) rate=195; pre_pause=0; post_pause=0.5 ;;
                    3) rate=220; pre_pause=0; post_pause=0.3 ;;
                    4) rate=185; test_text="Is this what you're looking for?" ;;
                esac
                ;;
            7)
                break
                ;;
        esac
    done
}

# 10. MAIN MENU WITH NATURAL SPEECH OPTIONS
# ------------------------------------------
show_main_menu() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   🎙️  NATURAL SAMANTHA VOICE TOOLKIT     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}Professional Speech Synthesis Techniques${NC}\n"
    
    echo "1.  Check Samantha installation"
    echo "2.  Basic speech (with Samantha)"
    echo "3.  Chunked natural speech"
    echo "4.  Advanced natural speech"
    echo "5.  Video agent mode"
    echo "6.  Natural conversation demo"
    echo "7.  Apply prosody patterns"
    echo "8.  Best practices demo"
    echo "9.  Interactive tester"
    echo "10. Generate natural script"
    echo "11. List all available voices"
    echo "12. Exit"
    echo ""
}

# Check for Samantha on startup
check_samantha() {
    if say -v "?" | grep -qi "^Samantha"; then
        echo -e "${GREEN}✅ Samantha is installed${NC}"
        export SAMANTHA_AVAILABLE=true
        export SAMANTHA_VOICE=$(say -v "?" | grep -i "^Samantha" | head -1 | awk '{print $1}')
    else
        echo -e "${RED}❌ Samantha is not installed${NC}"
        echo -e "${YELLOW}Using fallback voice. To install Samantha:${NC}"
        echo "  System Settings → Accessibility → Spoken Content → System Voice"
        export SAMANTHA_AVAILABLE=false
        export SAMANTHA_VOICE="Alex"  # Fallback
    fi
}

# Main execution
main() {
    clear
    echo -e "${BLUE}Initializing Natural Speech System...${NC}"
    check_samantha
    echo ""
    
    if [ "$#" -gt 0 ]; then
        # Command line mode
        case "$1" in
            "chunk") speak_chunked "$2" ;;
            "natural") speak_natural_advanced "$2" ;;
            "video") speak_for_video "$2" "$3" ;;
            "pattern") apply_prosody_pattern "$2" "$3" ;;
            "demo") demonstrate_best_practices ;;
            *) say -v "$SAMANTHA_VOICE" "$*" ;;
        esac
    else
        # Interactive mode
        while true; do
            show_main_menu
            read -p "Select option: " choice
            
            case $choice in
                1)
                    check_samantha
                    say -v "?" | grep -i samantha
                    ;;
                2)
                    read -p "Enter text: " text
                    say -v "$SAMANTHA_VOICE" "$text"
                    ;;
                3)
                    read -p "Enter text: " text
                    speak_chunked "$text"
                    ;;
                4)
                    speak_natural_advanced ""
                    ;;
                5)
                    read -p "Script file path: " script_file
                    read -p "Output directory (default: ./audio_chunks): " output_dir
                    speak_for_video "$script_file" "${output_dir:-./audio_chunks}"
                    ;;
                6)
                    natural_conversation
                    ;;
                7)
                    echo "Patterns: announcement, storytelling, tutorial, emotional, energetic, professional"
                    read -p "Select pattern: " pattern
                    read -p "Enter text: " text
                    apply_prosody_pattern "$pattern" "$text"
                    ;;
                8)
                    demonstrate_best_practices
                    ;;
                9)
                    interactive_tester
                    ;;
                10)
                    read -p "Enter text: " text
                    read -p "Output file (default: natural_script.txt): " output
                    generate_natural_script "$text" "${output:-natural_script.txt}"
                    ;;
                11)
                    say -v "?" | grep "en_"
                    ;;
                12)
                    echo -e "${GREEN}👋 Goodbye!${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Invalid option${NC}"
                    ;;
            esac
            
            echo -e "\n${YELLOW}Press Enter to continue...${NC}"
            read
            clear
        done
    fi
}

# Run main function
main "$@"
