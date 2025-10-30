#!/bin/bash
# Remove commented AppShortcutsProvider blocks from all *Intents.swift files

cd /Users/richardgillespie/Documents/FoTApple

for file in packages/FoTCore/AppIntents/*Intents.swift; do
    echo "Cleaning: $(basename $file)"
    
    # Find the line number where "// MARK: - App Shortcuts Provider" starts
    LINE=$(grep -n "// MARK: - App Shortcuts Provider" "$file" | cut -d: -f1)
    
    if [ ! -z "$LINE" ]; then
        # Delete from that line to the end of the file
        sed -i '' "${LINE},\$d" "$file"
        echo "✅ Removed commented block from $(basename $file)"
    fi
done

echo ""
echo "✅ All commented AppShortcutsProvider blocks removed"

