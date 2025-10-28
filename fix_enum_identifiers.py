#!/usr/bin/env python3
"""
Fix all AppEnum duplicate identifiers by adding unique typeIdentifier to each enum.
"""

import re
from pathlib import Path

def add_type_identifier_to_enum(file_path):
    """Add typeIdentifier to all AppEnums in a file."""
    content = Path(file_path).read_text()
    lines = content.split('\n')
    
    new_lines = []
    i = 0
    enum_counter = {}
    
    while i < len(lines):
        line = lines[i]
        
        # Check if this line defines an AppEnum
        if re.search(r'enum\s+(\w+).*:.*AppEnum', line):
            enum_name = re.search(r'enum\s+(\w+)', line).group(1)
            
            # Count how many times we've seen this enum name
            enum_counter[enum_name] = enum_counter.get(enum_name, 0) + 1
            instance = enum_counter[enum_name]
            
            # Create unique identifier
            file_name = Path(file_path).stem.replace('AppIntents', '')
            type_id = f"{file_name.lower()}.{enum_name}.{instance}"
            
            new_lines.append(line)
            i += 1
            
            # Skip opening brace and find where to insert typeIdentifier
            inserted = False
            while i < len(lines) and not inserted:
                current = lines[i]
                
                # If we hit static var typeDisplayRepresentation, insert before it
                if 'static var typeDisplayRepresentation' in current or \
                   'static var caseDisplayRepresentations' in current or \
                   'static let typeIdentifier' in current:
                    # Check if typeIdentifier already exists
                    if 'static let typeIdentifier' not in current:
                        new_lines.append(f'        static let typeIdentifier = "{type_id}"')
                        new_lines.append('')
                    inserted = True
                    new_lines.append(current)
                    i += 1
                    break
                
                new_lines.append(current)
                i += 1
        else:
            new_lines.append(line)
            i += 1
    
    return '\n'.join(new_lines)

# Process all intent files
intent_files = [
    'packages/FoTCore/AppIntents/HealthAppIntents.swift',
    'packages/FoTCore/AppIntents/ClinicianAppIntents.swift',
    'packages/FoTCore/AppIntents/ParentAppIntents.swift',
    'packages/FoTCore/AppIntents/EducationAppIntents.swift',
    'packages/FoTCore/AppIntents/LegalAppIntents.swift',
]

for file_path in intent_files:
    print(f"Processing {file_path}...")
    try:
        new_content = add_type_identifier_to_enum(file_path)
        Path(file_path).write_text(new_content)
        print(f"  ✅ Fixed")
    except Exception as e:
        print(f"  ❌ Error: {e}")

print("\n✅ All enum identifiers added!")

