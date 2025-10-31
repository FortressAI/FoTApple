#!/usr/bin/env python3 -u
"""
MEGA EXTRACTION AGENT - Extract ALL Knowledge from FoT Repository

This agent aggressively extracts facts from:
- All Swift App Intent files (9 files)
- All Wiki markdown files (60 files)
- All documentation files
- Code comments
- Feature descriptions
- Everything!

Target: Extract 5,000-10,000+ facts
"""

import sys
import requests
import json
import time
import hashlib
import re
from pathlib import Path
from datetime import datetime

# Unbuffer output
sys.stdout = open(sys.stdout.fileno(), 'w', buffering=1)

# Configuration
API_BASE = "http://94.130.97.66/api"
REPO_ROOT = Path("/Users/richardgillespie/Documents/FoTApple")
BATCH_DELAY = 0.2
STAKE_AMOUNT = 30.0

# Progress
submitted_facts = set()
total_submitted = 0
session_start = datetime.now()

def log(msg):
    elapsed = int((datetime.now() - session_start).total_seconds())
    print(f"[{datetime.now().strftime('%H:%M:%S')}] [{elapsed}s] {msg}", flush=True)

def submit_fact(content: str, domain: str, creator: str, stake: float = 30.0) -> bool:
    """Submit fact with deduplication"""
    global total_submitted
    
    content_hash = hashlib.sha256(content.encode()).hexdigest()
    if content_hash in submitted_facts:
        return False
    
    try:
        response = requests.post(
            f"{API_BASE}/facts/submit",
            json={"content": content, "domain": domain, "creator": creator, "stake": stake},
            timeout=10
        )
        
        if response.status_code == 200:
            total_submitted += 1
            submitted_facts.add(content_hash)
            if total_submitted % 50 == 0:
                log(f"✅ {total_submitted} facts submitted")
            time.sleep(BATCH_DELAY)
            return True
    except:
        pass
    return False

def extract_from_swift_file(file_path: Path) -> int:
    """Extract all facts from a Swift App Intent file"""
    count = 0
    
    try:
        content = file_path.read_text()
        
        # Determine domain
        filename = file_path.name.lower()
        if 'health' in filename or 'clinician' in filename:
            domain = "medical"
        elif 'legal' in filename:
            domain = "legal"
        elif 'education' in filename:
            domain = "education"
        else:
            domain = "general"
        
        # Extract struct definitions (App Intents)
        structs = re.findall(r'struct (\w+Intent)[^{]*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}', content, re.DOTALL)
        
        for struct_name, struct_body in structs:
            # Extract title
            title_match = re.search(r'title.*?=.*?"([^"]+)"', struct_body)
            if not title_match:
                continue
            
            title = title_match.group(1)
            
            # Extract description
            desc_match = re.search(r'description.*?=.*?"([^"]+)"', struct_body)
            description = desc_match.group(1) if desc_match else ""
            
            # Extract all parameters
            params = []
            param_matches = re.findall(r'@Parameter\([^)]+\)\s+var\s+(\w+):\s*([^\s\n=]+)', struct_body)
            for param_name, param_type in param_matches:
                params.append(f"{param_name} ({param_type})")
            
            # Build fact
            fact = f"App Intent: {struct_name} - {title}. {description}"
            if params:
                fact += f" Parameters: {', '.join(params)}."
            
            # Extract comments for additional context
            comments = re.findall(r'//\s*(.+)', struct_body)
            if comments:
                fact += f" Notes: {'; '.join(comments[:3])}."
            
            if submit_fact(fact, domain, f"FoT {domain.capitalize()} App Intent", 35.0):
                count += 1
        
        # Extract enum definitions
        enums = re.findall(r'enum\s+(\w+)[^{]*\{([^}]+)\}', content)
        for enum_name, enum_body in enums:
            cases = re.findall(r'case\s+(\w+)', enum_body)
            if cases:
                fact = f"Enumeration: {enum_name} with cases: {', '.join(cases)}"
                if submit_fact(fact, domain, f"FoT {domain.capitalize()} Domain", 25.0):
                    count += 1
        
        # Extract function definitions
        funcs = re.findall(r'func\s+(\w+)\([^)]*\)(?:\s*async)?(?:\s*throws)?(?:\s*->\s*([^{]+))?\s*\{', content)
        for func_name, return_type in funcs[:10]:  # Limit to avoid spam
            fact = f"Function: {func_name}"
            if return_type:
                fact += f" returns {return_type.strip()}"
            if submit_fact(fact, domain, f"FoT {domain.capitalize()} Implementation", 20.0):
                count += 1
        
    except Exception as e:
        log(f"❌ Error parsing {file_path.name}: {e}")
    
    return count

def extract_from_markdown_file(file_path: Path) -> int:
    """Extract facts from Wiki/docs markdown files"""
    count = 0
    
    try:
        content = file_path.read_text()
        
        # Determine domain
        filename = file_path.name.lower()
        text_lower = content.lower()[:500]
        
        if any(word in filename or word in text_lower for word in ['clinic', 'medical', 'health', 'patient']):
            domain = "medical"
        elif any(word in filename or word in text_lower for word in ['legal', 'law', 'court', 'constitutional']):
            domain = "legal"
        elif any(word in filename or word in text_lower for word in ['education', 'learning', 'student', 'teacher']):
            domain = "education"
        else:
            domain = "general"
        
        # Extract main sections with headers
        sections = re.findall(r'##\s+([^\n]+)\n+((?:(?!##).)+)', content, re.DOTALL)
        
        for section_title, section_content in sections:
            # Skip if too short
            if len(section_content.strip()) < 50:
                continue
            
            # Get first paragraph or key bullet points
            paragraphs = [p.strip() for p in section_content.split('\n\n') if len(p.strip()) > 40]
            if paragraphs:
                fact = f"{file_path.stem} - {section_title}: {paragraphs[0][:400]}"
                if submit_fact(fact, domain, f"FoT {file_path.stem} Documentation", 30.0):
                    count += 1
            
            # Extract bullet points
            bullets = re.findall(r'[-*]\s+([^\n]+)', section_content)
            for i, bullet in enumerate(bullets[:5]):  # Top 5 bullets
                if len(bullet.strip()) > 30:
                    fact = f"{file_path.stem} - {section_title}: {bullet.strip()}"
                    if submit_fact(fact, domain, f"FoT {file_path.stem} Documentation", 28.0):
                        count += 1
        
        # Extract bold statements (likely important)
        bold_statements = re.findall(r'\*\*([^*]+)\*\*', content)
        for statement in bold_statements[:10]:
            if len(statement.strip()) > 20 and not statement.isdigit():
                fact = f"{file_path.stem}: {statement.strip()}"
                if submit_fact(fact, domain, f"FoT {file_path.stem} Key Point", 25.0):
                    count += 1
        
        # Extract code blocks with descriptions
        code_blocks = re.findall(r'```(\w+)?\n([^`]+)```', content)
        for lang, code in code_blocks[:5]:
            if lang and len(code.strip()) > 20:
                # Get first few lines
                lines = [l.strip() for l in code.split('\n') if l.strip()][:3]
                fact = f"{file_path.stem} {lang} code example: {' '.join(lines)}"
                if submit_fact(fact, domain, f"FoT {file_path.stem} Code Example", 20.0):
                    count += 1
        
    except Exception as e:
        log(f"❌ Error parsing {file_path.name}: {e}")
    
    return count

def main():
    log("=" * 80)
    log("🚀 MEGA EXTRACTION AGENT STARTING")
    log("=" * 80)
    
    # Extract from Swift files
    log("\n📱 EXTRACTING FROM SWIFT APP INTENT FILES")
    log("-" * 80)
    
    swift_files = list((REPO_ROOT / "packages/FoTCore/AppIntents").rglob("*.swift"))
    log(f"Found {len(swift_files)} Swift files")
    
    for swift_file in swift_files:
        log(f"📄 Parsing {swift_file.name}...")
        count = extract_from_swift_file(swift_file)
        log(f"   ✅ Extracted {count} facts")
    
    # Extract from Wiki files
    log("\n📚 EXTRACTING FROM WIKI DOCUMENTATION")
    log("-" * 80)
    
    wiki_files = list((REPO_ROOT / "FoTApple.wiki").rglob("*.md"))
    log(f"Found {len(wiki_files)} Wiki files")
    
    for wiki_file in wiki_files:
        log(f"📄 Parsing {wiki_file.name}...")
        count = extract_from_markdown_file(wiki_file)
        log(f"   ✅ Extracted {count} facts")
    
    # Extract from docs folder
    log("\n📄 EXTRACTING FROM DOCS FOLDER")
    log("-" * 80)
    
    if (REPO_ROOT / "docs").exists():
        docs_files = list((REPO_ROOT / "docs").rglob("*.md"))
        log(f"Found {len(docs_files)} doc files")
        
        for doc_file in docs_files:
            log(f"📄 Parsing {doc_file.name}...")
            count = extract_from_markdown_file(doc_file)
            log(f"   ✅ Extracted {count} facts")
    
    # Final summary
    elapsed = (datetime.now() - session_start).total_seconds()
    log("\n" + "=" * 80)
    log("🎉 MEGA EXTRACTION COMPLETE!")
    log("=" * 80)
    log(f"✅ Total facts submitted: {total_submitted}")
    log(f"⏱️  Time: {int(elapsed/60)}min {int(elapsed%60)}sec")
    log(f"📈 Rate: {total_submitted/elapsed:.2f} facts/sec")
    log(f"\n💰 You now own {total_submitted} MORE facts earning 70% of fees!")
    log(f"🌐 View: http://94.130.97.66/review.html")
    log("=" * 80)

if __name__ == "__main__":
    main()

