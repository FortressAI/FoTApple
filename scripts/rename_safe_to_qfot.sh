#!/bin/bash
# rename_safe_to_qfot.sh
# Rename SAFE token to QFOT (Quantum Field of Truth) throughout codebase
# This script systematically replaces all references

set -e

echo "🔄 Renaming SAFE → QFOT (Quantum Field of Truth)"
echo "================================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counter
FILES_MODIFIED=0

# Function to rename in file
rename_in_file() {
    local file=$1
    
    if [ -f "$file" ]; then
        # Skip binary files and certain directories
        if [[ "$file" == *".git"* ]] || [[ "$file" == *"build/"* ]] || [[ "$file" == *".xcodeproj"* ]]; then
            return
        fi
        
        # Check if file contains SAFE references
        if grep -q "SAFE\|SafeAI" "$file" 2>/dev/null; then
            echo -e "${BLUE}📝 Modifying: $file${NC}"
            
            # Perform replacements (macOS compatible)
            sed -i '' 's/SAFE token/QFOT token/g' "$file"
            sed -i '' 's/SAFE Token/QFOT Token/g' "$file"
            sed -i '' 's/SafeAICoin/QFOT/g' "$file"
            sed -i '' 's/SafeAI/QFOT/g' "$file"
            sed -i '' 's/SAFE/QFOT/g' "$file"
            sed -i '' 's/safeaicoin/qfot/g' "$file"
            sed -i '' 's/safeai/qfot/g' "$file"
            
            # Special cases
            sed -i '' 's/QFOT Harbor/Safe Harbor/g' "$file" # HIPAA Safe Harbor
            sed -i '' 's/QFOT Mode/Safe Mode/g' "$file" # Safe mode (technical term)
            sed -i '' 's/thread-QFOT/thread-safe/g' "$file" # Thread-safe
            sed -i '' 's/type-QFOT/type-safe/g' "$file" # Type-safe
            
            ((FILES_MODIFIED++))
        fi
    fi
}

# Directories to process
echo "📁 Scanning directories..."
DIRS=(
    "Sources/SafeAICoinBridge"
    "packages/FoTUI"
    "packages/FoTCore"
    "blockchain"
    "scripts"
    "docs"
    "."
)

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "   Scanning $dir..."
        
        # Process Swift files
        find "$dir" -name "*.swift" -type f | while read file; do
            rename_in_file "$file"
        done
        
        # Process Markdown files
        find "$dir" -name "*.md" -type f | while read file; do
            rename_in_file "$file"
        done
        
        # Process shell scripts
        find "$dir" -name "*.sh" -type f | while read file; do
            rename_in_file "$file"
        done
        
        # Process Rust files
        find "$dir" -name "*.rs" -type f | while read file; do
            rename_in_file "$file"
        done
        
        # Process JSON files
        find "$dir" -name "*.json" -type f | while read file; do
            rename_in_file "$file"
        done
    fi
done

# Rename directories
echo ""
echo "📂 Renaming directories..."

if [ -d "Sources/SafeAICoinBridge" ]; then
    echo -e "${BLUE}   Sources/SafeAICoinBridge → Sources/QFOTBridge${NC}"
    mv "Sources/SafeAICoinBridge" "Sources/QFOTBridge"
fi

# Rename specific files
echo ""
echo "📄 Renaming specific files..."

FILES_TO_RENAME=(
    "Sources/QFOTBridge/SafeAICoinClient.swift:Sources/QFOTBridge/QFOTClient.swift"
    "Sources/QFOTBridge/SafeAICoinConfig.swift:Sources/QFOTBridge/QFOTConfig.swift"
    "Sources/QFOTBridge/SafeAICoinWallet.swift:Sources/QFOTBridge/QFOTWallet.swift"
    "Sources/QFOTBridge/SafeAICoinOptIn.swift:Sources/QFOTBridge/QFOTOptIn.swift"
    "packages/FoTCore/SafeAICoinIntegration.swift:packages/FoTCore/QFOTIntegration.swift"
    "packages/FoTUI/SafeAICoinWalletView.swift:packages/FoTUI/QFOTWalletView.swift"
    "packages/FoTUI/SettingsViews/SafeAICoinSettingsView.swift:packages/FoTUI/SettingsViews/QFOTSettingsView.swift"
    "blockchain/SAFEAICOIN_ARCHITECTURE.md:blockchain/QFOT_ARCHITECTURE.md"
    "blockchain/SAFEAICOIN_QUICKSTART.md:blockchain/QFOT_QUICKSTART.md"
    "docs/SAFEAICOIN_APP_INTEGRATION.md:docs/QFOT_APP_INTEGRATION.md"
    "docs/SAFEAICOIN_LEGAL_COMPLIANCE.md:docs/QFOT_LEGAL_COMPLIANCE.md"
    "docs/SAFEAICOIN_LEGAL_APP_INTEGRATION.md:docs/QFOT_LEGAL_APP_INTEGRATION.md"
    "SAFEAICOIN_INTEGRATION_COMPLETE.md:QFOT_INTEGRATION_COMPLETE.md"
    "SAFEAICOIN_FINAL_SUMMARY.md:QFOT_FINAL_SUMMARY.md"
    "SAFEAICOIN_TOKEN_VALUE_DISCLAIMER.md:QFOT_TOKEN_VALUE_DISCLAIMER.md"
    "scripts/deploy_safeaicoin_hetzner.sh:scripts/deploy_qfot_hetzner.sh"
    "scripts/check_safeaicoin_network.sh:scripts/check_qfot_network.sh"
    "scripts/destroy_safeaicoin_network.sh:scripts/destroy_qfot_network.sh"
    "blockchain/deploy_safeaicoin_substrate.sh:blockchain/deploy_qfot_substrate.sh"
)

for rename_pair in "${FILES_TO_RENAME[@]}"; do
    OLD_FILE="${rename_pair%%:*}"
    NEW_FILE="${rename_pair##*:}"
    
    if [ -f "$OLD_FILE" ]; then
        echo -e "${BLUE}   $OLD_FILE → $NEW_FILE${NC}"
        mv "$OLD_FILE" "$NEW_FILE"
    fi
done

# Update Package.swift
echo ""
echo "📦 Updating Package.swift..."
if [ -f "Package.swift" ]; then
    sed -i '' 's/SafeAICoinBridge/QFOTBridge/g' "Package.swift"
    sed -i '' 's/"SafeAICoinBridge"/"QFOTBridge"/g' "Package.swift"
    echo -e "${GREEN}   ✅ Updated Package.swift${NC}"
fi

echo ""
echo "================================================="
echo -e "${GREEN}✅ Renaming complete!${NC}"
echo ""
echo "📊 Summary:"
echo "   Files modified: $FILES_MODIFIED"
echo "   Token name: SAFE → QFOT"
echo "   Module name: SafeAICoinBridge → QFOTBridge"
echo ""
echo "🔧 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Build project: swift build"
echo "   3. Run tests: swift test"
echo "   4. Update documentation"
echo ""
echo "⚠️  Note: You may need to clean build folders:"
echo "   rm -rf .build"
echo "   rm -rf DerivedData"
echo ""

