#!/usr/bin/env python3 -u
"""
SIMPLE MEGA EXTRACTOR - Reliably extract ALL knowledge from FoT repo
"""

import sys
import requests
import json
import time
import hashlib
import re
from pathlib import Path
from datetime import datetime

sys.stdout = open(sys.stdout.fileno(), 'w', buffering=1)

API_BASE = "http://94.130.97.66/api"
REPO_ROOT = Path("/Users/richardgillespie/Documents/FoTApple")
DELAY = 0.15
total_submitted = 0
start_time = datetime.now()

def submit(content, domain, creator):
    """Submit fact - show all attempts"""
    global total_submitted
    
    try:
        resp = requests.post(
            f"{API_BASE}/facts/submit",
            json={"content": content[:500], "domain": domain, "creator": creator, "stake": 30.0},
            timeout=5
        )
        
        if resp.status_code == 200:
            total_submitted += 1
            if total_submitted % 25 == 0:
                print(f"✅ {total_submitted} facts submitted", flush=True)
            time.sleep(DELAY)
            return True
        else:
            print(f"⚠️  API returned {resp.status_code}: {resp.text[:100]}", flush=True)
            return False
    except Exception as e:
        print(f"❌ Error: {str(e)[:100]}", flush=True)
        return False

print("="*80)
print("🚀 SIMPLE MEGA EXTRACTOR STARTING")
print("="*80)

# ==============================================================================
# EXTRACT FROM SWIFT FILES
# ==============================================================================
print("\n📱 SWIFT APP INTENTS")
print("-"*80)

swift_files = [
    ("packages/FoTCore/AppIntents/LegalIntents.swift", "legal"),
    ("packages/FoTCore/AppIntents/ClinicianIntents.swift", "medical"),
    ("packages/FoTCore/AppIntents/HealthGuidanceIntents.swift", "medical"),
    ("packages/FoTCore/AppIntents/EducationIntents.swift", "education"),
    ("packages/FoTCore/AppIntents/EducationHelperIntents.swift", "education"),
]

for file_rel, domain in swift_files:
    file_path = REPO_ROOT / file_rel
    if not file_path.exists():
        continue
    
    print(f"\n📄 {file_path.name}:")
    content = file_path.read_text()
    
    # Extract Intent structs with titles and descriptions
    structs = re.findall(r'public struct (\w+Intent):', content)
    titles = re.findall(r'title.*?=.*?"([^"]+)"', content)
    descs = re.findall(r'IntentDescription\("([^"]+)"\)', content)
    
    print(f"   Found {len(structs)} intents, {len(titles)} titles, {len(descs)} descriptions")
    
    # Submit each Intent as a fact
    for i, (struct, title, desc) in enumerate(zip(structs, titles, descs)):
        fact = f"App Intent '{struct}': {title}. {desc}"
        submit(fact, domain, f"FoT {domain.capitalize()} App")
    
    # Extract enums
    enums = re.findall(r'enum\s+(\w+)[^{]*\{([^}]+)\}', content)
    for enum_name, enum_body in enums:
        cases = re.findall(r'case\s+(\w+)', enum_body)
        if len(cases) >= 2:
            fact = f"Enumeration '{enum_name}' defines: {', '.join(cases[:10])}"
            submit(fact, domain, f"FoT {domain.capitalize()} Types")

print(f"\n   📊 Subtotal: {total_submitted} facts from Swift files\n")

# ==============================================================================
# EXTRACT FROM WIKI FILES
# ==============================================================================
print("📚 WIKI DOCUMENTATION")
print("-"*80)

wiki_files = list((REPO_ROOT / "FoTApple.wiki").glob("*.md"))
print(f"Found {len(wiki_files)} Wiki files\n")

for wiki_file in wiki_files:
    if wiki_file.stat().st_size < 500:  # Skip tiny files
        continue
    
    content = wiki_file.read_text()
    
    # Determine domain
    text_lower = content.lower()[:300]
    if any(w in text_lower for w in ['clinic', 'medical', 'health', 'patient', 'doctor']):
        domain = "medical"
    elif any(w in text_lower for w in ['legal', 'law', 'court', 'evidence']):
        domain = "legal"
    elif any(w in text_lower for w in ['education', 'learning', 'student', 'teacher']):
        domain = "education"
    else:
        domain = "general"
    
    # Extract ## Headers with content
    sections = re.findall(r'##\s+([^\n]+)\n+((?:(?!##).)+)', content, re.DOTALL)
    
    for header, body in sections:
        # Get first meaningful paragraph
        paragraphs = [p.strip() for p in body.split('\n\n') if len(p.strip()) > 50]
        if paragraphs:
            fact = f"{wiki_file.stem} - {header}: {paragraphs[0][:350]}"
            submit(fact, domain, f"FoT {wiki_file.stem} Wiki")
        
        # Extract bullet points
        bullets = re.findall(r'^[-*]\s+(.+)$', body, re.MULTILINE)
        for bullet in bullets[:3]:
            if len(bullet.strip()) > 30:
                fact = f"{wiki_file.stem} - {header}: {bullet.strip()}"
                submit(fact, domain, f"FoT {wiki_file.stem} Wiki")
    
    if total_submitted % 100 == 0 and total_submitted > 0:
        print(f"\n   📊 Progress: {total_submitted} facts...")

# ==============================================================================
# SUMMARY
# ==============================================================================
elapsed = int((datetime.now() - start_time).total_seconds())
print("\n" + "="*80)
print("🎉 EXTRACTION COMPLETE!")
print("="*80)
print(f"✅ Total submitted: {total_submitted}")
print(f"⏱️  Time: {elapsed//60}m {elapsed%60}s")
print(f"📈 Rate: {total_submitted/max(elapsed,1):.1f} facts/sec")
print(f"\n💰 You now own {total_submitted} MORE facts!")
print(f"🌐 View: http://94.130.97.66/review.html")
print("="*80)

