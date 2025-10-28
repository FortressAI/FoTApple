#!/usr/bin/env python3
"""
Phase 1: Audit all AppEnums and their typeIdentifiers
Identifies duplicates and missing identifiers
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
print("PHASE 1: AUDIT REPORT")
print("=" * 80)
print()

# Count by status
total = len(all_enums)
with_id = sum(1 for e in all_enums if e['type_id'])
without_id = total - with_id

print(f"Total AppEnums: {total}")
print(f"With typeIdentifier: {with_id}")
print(f"Missing typeIdentifier: {without_id}")
print()

# Check for duplicates
type_id_map = defaultdict(list)
for enum in all_enums:
    if enum['type_id']:
        type_id_map[enum['type_id']].append(enum)

duplicates = {tid: enums for tid, enums in type_id_map.items() if len(enums) > 1}

if duplicates:
    print("=" * 80)
    print(f"DUPLICATE typeIdentifiers Found: {len(duplicates)}")
    print("=" * 80)
    for tid, enums in duplicates.items():
        print(f"\n'{tid}' used by {len(enums)} enums:")
        for e in enums:
            print(f"  - {e['file']}:{e['line']} → {e['intent']}.{e['enum']}")

if without_id > 0:
    print("\n" + "=" * 80)
    print(f"MISSING typeIdentifiers: {without_id}")
    print("=" * 80)
    missing = [e for e in all_enums if not e['type_id']]
    for e in missing:
        print(f"  - {e['file']}:{e['line']} → {e['intent']}.{e['enum']}")

print("\n" + "=" * 80)
print("RECOMMENDED FIX FORMAT")
print("=" * 80)
print("Use format: {domain}.{IntentName}.{EnumName}")
print("\nExamples:")
for e in all_enums[:3]:
    domain = e['file'].replace('AppIntents.swift', '').lower()
    recommended = f"{domain}.{e['intent']}.{e['enum']}"
    print(f"  {e['intent']}.{e['enum']} → '{recommended}'")

print("\n" + "=" * 80)
print("Ready for Phase 2: Fix Script")
print("=" * 80)

