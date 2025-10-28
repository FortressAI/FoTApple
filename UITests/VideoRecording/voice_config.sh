#!/usr/bin/env bash
# Voice Configuration and Detection
# Automatically selects best available TTS voice per language

# Get available voices
get_available_voices() {
    say -v "?" 2>/dev/null || echo ""
}

# Select best voice for language with fallbacks
select_voice() {
    local language=$1
    local available_voices=$(get_available_voices)
    
    case $language in
        en|en_US)
            for voice in Samantha Alex Victoria; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        en_GB)
            for voice in Daniel Kate Serena; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        en_AU)
            for voice in Karen; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        es|es_ES)
            for voice in Monica Jorge; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        es_MX)
            for voice in Paulina Diego; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        fr|fr_FR)
            for voice in Thomas Amelie; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        fr_CA)
            for voice in Amelie Chantal; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        de|de_DE)
            for voice in Anna Markus Petra; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        it|it_IT)
            for voice in Alice Luca; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        pt_BR)
            for voice in Luciana Felipe; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        pt_PT)
            for voice in Joana; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        ja|ja_JP)
            for voice in Kyoko Otoya; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        ko|ko_KR)
            for voice in Yuna; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        zh_CN)
            for voice in Ting-Ting; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        zh_TW)
            for voice in Mei-Jia; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
        zh_HK)
            for voice in Sin-Ji; do
                if echo "$available_voices" | grep -q "$voice"; then
                    echo "$voice"
                    return 0
                fi
            done
            ;;
    esac
    
    # Fallback to system default
    echo "Alex"
}

# Test voice
test_voice() {
    local voice=$1
    local text=${2:-"This is a test."}
    
    say -v "$voice" "$text" 2>/dev/null
    return $?
}

# Show all available voices
list_all_voices() {
    echo "Available TTS voices on this system:"
    echo ""
    say -v "?" | while read line; do
        echo "  $line"
    done
}

# Main command interface
case "${1:-}" in
    list)
        list_all_voices
        ;;
    select)
        select_voice "${2:-en_US}"
        ;;
    test)
        voice=$(select_voice "${2:-en_US}")
        test_voice "$voice" "${3:-This is a test in this language}"
        ;;
    *)
        echo "Usage: $0 {list|select|test} [language] [text]"
        echo ""
        echo "Commands:"
        echo "  list              Show all installed voices"
        echo "  select <lang>     Select best voice for language"
        echo "  test <lang> [txt] Test voice with sample text"
        echo ""
        echo "Languages: en_US, en_GB, es_ES, es_MX, fr_FR, de_DE, etc."
        ;;
esac

