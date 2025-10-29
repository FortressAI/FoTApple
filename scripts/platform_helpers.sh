#!/bin/bash
# Platform-specific helper functions for TestFlight deployment

################################################################################
# Get platform-specific configuration
################################################################################

get_platform_sdk() {
    local platform=$1
    case $platform in
        iOS)
            echo "iphoneos"
            ;;
        macOS)
            echo "macosx"
            ;;
        watchOS)
            echo "watchos"
            ;;
        visionOS)
            echo "xros"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_platform_destination() {
    local platform=$1
    case $platform in
        iOS)
            echo "generic/platform=iOS"
            ;;
        macOS)
            echo "generic/platform=macOS"
            ;;
        watchOS)
            echo "generic/platform=watchOS"
            ;;
        visionOS)
            echo "generic/platform=visionOS"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_platform_dir() {
    local platform=$1
    case $platform in
        iOS)
            echo "iOS"
            ;;
        macOS)
            echo "macOS"
            ;;
        watchOS)
            echo "watchOS"
            ;;
        visionOS)
            echo "visionOS"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_export_method() {
    local platform=$1
    # watchOS uses app-store, others use app-store-connect
    if [ "$platform" = "watchOS" ]; then
        echo "app-store"
    else
        echo "app-store-connect"
    fi
}

validate_platform() {
    local platform=$1
    case $platform in
        iOS|macOS|watchOS|visionOS)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

check_platform_support() {
    local app_dir=$1
    local platform=$2
    local platform_dir=$(get_platform_dir "$platform")
    
    if [ -z "$platform_dir" ]; then
        return 1
    fi
    
    if [ -d "apps/$app_dir/$platform_dir" ]; then
        return 0
    else
        return 1
    fi
}

################################################################################
# Load platform matrix from JSON
################################################################################

load_platform_matrix() {
    local matrix_file="scripts/app_platform_matrix.json"
    
    if [ ! -f "$matrix_file" ]; then
        echo "Error: Platform matrix file not found: $matrix_file" >&2
        return 1
    fi
    
    # Check if jq is available
    if command -v jq &> /dev/null; then
        echo "$matrix_file"
        return 0
    else
        # Fallback: JSON parsing would need to be done differently
        echo "Warning: jq not found. Platform matrix loading may be limited." >&2
        echo "$matrix_file"
        return 0
    fi
}

get_app_scheme() {
    local app_name=$1
    local platform=$2
    local matrix_file=$(load_platform_matrix)
    
    if command -v jq &> /dev/null; then
        jq -r ".[\"$app_name\"].schemes.\"$platform\"" "$matrix_file" 2>/dev/null
    else
        # Simple grep-based fallback (less reliable)
        grep -A 20 "\"$app_name\"" "$matrix_file" | grep -A 5 "\"$platform\"" | grep -o "\"[^\"]*\":\s*\"[^\"]*\"" | head -1 | cut -d'"' -f4
    fi
}

get_app_bundle_id() {
    local app_name=$1
    local platform=$2
    local matrix_file=$(load_platform_matrix)
    
    if command -v jq &> /dev/null; then
        jq -r ".[\"$app_name\"].bundleIds.\"$platform\"" "$matrix_file" 2>/dev/null
    else
        # Simple grep-based fallback (less reliable)
        grep -A 20 "\"$app_name\"" "$matrix_file" | grep -A 5 "bundleIds" | grep -A 5 "\"$platform\"" | grep -o "\"[^\"]*\":\s*\"[^\"]*\"" | head -1 | cut -d'"' -f4
    fi
}

get_app_platforms() {
    local app_name=$1
    local matrix_file=$(load_platform_matrix)
    
    if command -v jq &> /dev/null; then
        jq -r ".[\"$app_name\"].platforms[]" "$matrix_file" 2>/dev/null
    else
        # Simple grep-based fallback
        grep -A 30 "\"$app_name\"" "$matrix_file" | grep "platforms" | grep -o '"[^"]*"' | tr -d '"' | grep -E "^(iOS|macOS|watchOS|visionOS)$"
    fi
}

get_app_directory() {
    local app_name=$1
    local matrix_file=$(load_platform_matrix)
    
    if command -v jq &> /dev/null; then
        jq -r ".[\"$app_name\"].directory" "$matrix_file" 2>/dev/null
    else
        # Fallback assumes directory matches app name
        echo "$app_name"
    fi
}

################################################################################
# Platform-specific archive and export helpers
################################################################################

create_export_options_plist() {
    local output_file=$1
    local platform=$2
    local team_id=$3
    local api_issuer_id=$4
    local api_key_id=$5
    
    local method=$(get_export_method "$platform")
    
    # watchOS doesn't support "destination: upload" - must export IPA and upload separately
    if [ "$platform" = "watchOS" ]; then
        cat > "$output_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$method</string>
    
    <key>teamID</key>
    <string>$team_id</string>
    
    <key>signingStyle</key>
    <string>automatic</string>
    
    <key>uploadSymbols</key>
    <true/>
    
    <key>compileBitcode</key>
    <false/>
    
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
</dict>
</plist>
EOF
    else
        cat > "$output_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$method</string>
    
    <key>destination</key>
    <string>upload</string>
    
    <key>teamID</key>
    <string>$team_id</string>
    
    <key>signingStyle</key>
    <string>automatic</string>
    
    <key>uploadSymbols</key>
    <true/>
    
    <key>compileBitcode</key>
    <false/>
    
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
    
    <key>authentication</key>
    <dict>
        <key>apiIssuer</key>
        <string>$api_issuer_id</string>
        <key>apiKey</key>
        <string>$api_key_id</string>
    </dict>
</dict>
</plist>
EOF
    fi
}

