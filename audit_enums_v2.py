#!/usr/bin/env python3
"""
Phase 1 Enhanced: Check for duplicate enum NAMES that need unique typeIdentifiers
"""

import re
from pathlib import Path
from collections import defaultdict

def extract_enums_from_file(file_path):
    """Extract all AppEnums with their parent Intent and current typeIdentifier."""
    content = Path(file_path).read_text()
    lines = content.split('\n')
    
    enums = []
    current_intent = None
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Track current Intent struct
        intent_match = re.search(r'struct\s+(\w+Intent):\s+AppIntent', line)
        if intent_match:
            current_intent = intent_match.group(1)
        
        # Find AppEnum definitions
        enum_match = re.search(r'enum\s+(\w+)\s*:.*AppEnum', line)
        if enum_match and current_intent:
            enum_name = enum_match.group(1)
            
            # Look ahead for typeIdentifier
            type_id = None
            for j in range(i+1, min(i+30, len(lines))):
                id_match = re.search(r'static let typeIdentifier\s*=\s*"([^"]+)"', lines[j])
                if id_match:
                    type_id = id_match.group(1)
                    break
                # Stop at next enum or struct
                if re.search(r'(enum|struct|public func perform)', lines[j]):
                    break
            
            enums.append({
                'file': Path(file_path).name,
                'intent': current_intent,
                'enum': enum_name,
                'type_id': type_id,
                'line': i + 1
            })
        
        i += 1
    
    return enums

# Process all intent files
intent_files = [
    'packages/FoTCore/AppIntents/HealthAppIntents.swift',
    'packages/FoTCore/AppIntents/ClinicianAppIntents.swift',
    'packages/FoTCore/AppIntents/ParentAppIntents.swift',
    'packages/FoTCore/AppIntents/EducationAppIntents.swift',
    'packages/FoTCore/AppIntents/LegalAppIntents.swift',
]

all_enums = []
for file_path in intent_files:
    enums = extract_enums_from_file(file_path)
    all_enums.extend(enums)

print("=" * 80)
print("PHASE 1 ENHANCED: DUPLICATE ENUM NAME ANALYSIS")
print("=" * 80)
print()

# Group by enum name
enum_name_map = defaultdict(list)
for enum in all_enums:
    enum_name_map[enum['enum']].append(enum)

# Find duplicate enum names
duplicates = {name: enums for name, enums in enum_name_map.items() if len(enums) > 1}

print(f"Total unique enum names: {len(enum_name_map)}")
print(f"Enum names used multiple times: {len(duplicates)}")
print()

if duplicates:
    print("=" * 80)
    print("DUPLICATE ENUM NAMES (These MUST have unique typeIdentifiers)")
    print("=" * 80)
    for enum_name, instances in sorted(duplicates.items()):
        print(f"\n'{enum_name}' appears {len(instances)} times:")
        for e in instances:
            domain = e['file'].replace('AppIntents.swift', '').lower()
            recommended = f"{domain}.{e['intent']}.{enum_name}"
            status = "✓" if e['type_id'] and e['intent'] in e['type_id'] else "✗"
            print(f"  {status} {e['file']}:{e['line']}")
            print(f"     Intent: {e['intent']}")
            print(f"     Current: {e['type_id']}")
            print(f"     Should be: '{recommended}'")

print("\n" + "=" * 80)
print("ACTION REQUIRED")
print("=" * 80)
print("Each duplicate enum name MUST have a typeIdentifier that includes the Intent name")
print("Format: {domain}.{IntentName}.{EnumName}")
print("\nThis ensures global uniqueness across all intents.")

