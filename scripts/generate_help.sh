#!/bin/bash

#
# Generate Apple Help from FoT Wiki
# Converts markdown wiki to Apple Help Bundle for macOS and iOS
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "🍎 FoT Apple Help Generator"
echo "======================================"
echo ""

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required but not installed"
    exit 1
fi

# Install dependencies if needed
echo "📦 Checking dependencies..."
if ! python3 -c "import markdown" 2>/dev/null; then
    echo "Installing markdown library..."
    pip3 install -r scripts/help_requirements.txt
fi

# Run converter
echo ""
echo "🔄 Converting wiki to Apple Help format..."
python3 scripts/convert_wiki_to_apple_help.py

# Verify output
if [ -d "AppleHelp/FoTHelp.help" ] && [ -d "AppleHelp/iOS" ]; then
    echo ""
    echo "✅ SUCCESS! Apple Help generated successfully"
    echo ""
    echo "📁 Output locations:"
    echo "   macOS: AppleHelp/FoTHelp.help/"
    echo "   iOS:   AppleHelp/iOS/"
    echo ""
    echo "📚 Next steps:"
    echo "   1. Add FoTHelp.help to your macOS app in Xcode"
    echo "   2. Add iOS help resources to your iOS app"
    echo "   3. See docs/APPLE_HELP_INTEGRATION.md for details"
    echo ""
else
    echo ""
    echo "❌ ERROR: Help generation failed"
    exit 1
fi

