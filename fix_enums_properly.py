#!/usr/bin/env python3
"""
Phase 2: Fix all duplicate enum typeIdentifiers
Uses format: {domain}.{IntentName}.{EnumName} for guaranteed uniqueness
"""

import re
from pathlib import Path

def fix_enums_in_file(file_path):
    """Fix all enum typeIdentifiers in a file to include Intent name."""
    content = Path(file_path).read_text()
    lines = content.split('\n')
    
    domain = Path(file_path).stem.replace('AppIntents', '').lower()
    
    new_lines = []
    current_intent = None
    current_enum = None
    i = 0
    fixes_made = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Track current Intent struct
        intent_match = re.search(r'struct\s+(\w+Intent):\s+AppIntent', line)
        if intent_match:
            current_intent = intent_match.group(1)
            current_enum = None
        
        # Track current enum
        enum_match = re.search(r'enum\s+(\w+)\s*:.*AppEnum', line)
        if enum_match and current_intent:
            current_enum = enum_match.group(1)
        
        # Fix typeIdentifier if we're in an enum
        if current_enum and current_intent:
            type_id_match = re.match(r'(\s*)static let typeIdentifier\s*=\s*"([^"]+)"', line)
            if type_id_match:
                indent = type_id_match.group(1)
                old_id = type_id_match.group(2)
                new_id = f"{domain}.{current_intent}.{current_enum}"
                
                if old_id != new_id:
                    line = f'{indent}static let typeIdentifier = "{new_id}"'
                    fixes_made += 1
                    print(f"  Fixed: {current_intent}.{current_enum}")
                    print(f"    Old: {old_id}")
                    print(f"    New: {new_id}")
        
        new_lines.append(line)
        i += 1
    
    return '\n'.join(new_lines), fixes_made

# Fix all intent files
intent_files = [
    'packages/FoTCore/AppIntents/HealthAppIntents.swift',
    'packages/FoTCore/AppIntents/ClinicianAppIntents.swift',
    'packages/FoTCore/AppIntents/ParentAppIntents.swift',
    'packages/FoTCore/AppIntents/EducationAppIntents.swift',
    'packages/FoTCore/AppIntents/LegalAppIntents.swift',
]

print("=" * 80)
print("PHASE 2: FIXING ENUM typeIdentifiers")
print("=" * 80)
print()

total_fixes = 0
for file_path in intent_files:
    print(f"Processing {Path(file_path).name}...")
    new_content, fixes = fix_enums_in_file(file_path)
    
    if fixes > 0:
        Path(file_path).write_text(new_content)
        print(f"  ✓ Applied {fixes} fixes")
        total_fixes += fixes
    else:
        print(f"  ✓ No changes needed")
    print()

print("=" * 80)
print(f"PHASE 2 COMPLETE: {total_fixes} typeIdentifiers fixed")
print("=" * 80)
print("\nAll enums now have unique typeIdentifiers in format:")
print("{domain}.{IntentName}.{EnumName}")
print("\nReady for Phase 3: Validation and Testing")

