#!/usr/bin/env python3
"""
Convert FoT Wiki to Apple Help Format
Transforms markdown wiki files into Apple Help bundles for macOS and iOS
"""

import os
import re
import shutil
from pathlib import Path
import markdown
from datetime import datetime

# Configuration
WIKI_DIR = Path("FoTApple.wiki")
HELP_DIR = Path("AppleHelp")
MACOS_HELP = HELP_DIR / "FoTHelp.help"
IOS_HELP = HELP_DIR / "iOS"
ASSETS_DIR = HELP_DIR / "Assets"

# Help Book Configuration
HELP_BOOK_TITLE = "FoT Apple Help"
HELP_BOOK_IDENTIFIER = "com.fortressai.fot.help"
HELP_BOOK_VERSION = "1.0"

class WikiToAppleHelpConverter:
    """Convert wiki markdown files to Apple Help format"""
    
    def __init__(self):
        self.md = markdown.Markdown(extensions=[
            'extra',
            'toc',
            'tables',
            'fenced_code',
            'codehilite'
        ])
        self.pages = []
        self.categories = {
            'Getting Started': [],
            'Apps': [],
            'Compliance': [],
            'Technical': [],
            'Support': []
        }
    
    def convert_all(self):
        """Main conversion process"""
        print("🔄 Converting FoT Wiki to Apple Help Format...")
        
        # Clean and create directories
        self._setup_directories()
        
        # Process markdown files
        self._process_wiki_files()
        
        # Generate macOS Help Bundle
        self._generate_macos_help()
        
        # Generate iOS Help Resources
        self._generate_ios_help()
        
        # Copy assets
        self._copy_assets()
        
        print(f"✅ Conversion complete! Generated {len(self.pages)} help pages")
        print(f"📁 macOS Help: {MACOS_HELP}")
        print(f"📁 iOS Help: {IOS_HELP}")
    
    def _setup_directories(self):
        """Create necessary directory structure"""
        for dir_path in [HELP_DIR, MACOS_HELP, IOS_HELP, ASSETS_DIR]:
            dir_path.mkdir(parents=True, exist_ok=True)
        
        # Create macOS help subdirectories
        (MACOS_HELP / "Contents").mkdir(exist_ok=True)
        (MACOS_HELP / "Contents" / "Resources").mkdir(exist_ok=True)
        (MACOS_HELP / "Contents" / "Resources" / "en.lproj").mkdir(exist_ok=True)
        (MACOS_HELP / "Contents" / "Resources" / "images").mkdir(exist_ok=True)
        (MACOS_HELP / "Contents" / "Resources" / "css").mkdir(exist_ok=True)
    
    def _process_wiki_files(self):
        """Process all markdown files in wiki"""
        wiki_files = list(WIKI_DIR.glob("*.md"))
        
        for md_file in wiki_files:
            if md_file.name.startswith("_"):
                continue
                
            print(f"  Processing: {md_file.name}")
            page_info = self._convert_markdown_file(md_file)
            
            if page_info:
                self.pages.append(page_info)
                self._categorize_page(page_info)
    
    def _convert_markdown_file(self, md_file: Path) -> dict:
        """Convert single markdown file to HTML"""
        try:
            content = md_file.read_text(encoding='utf-8')
            
            # Extract title
            title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
            title = title_match.group(1) if title_match else md_file.stem.replace('-', ' ')
            
            # Clean content for Apple Help
            content = self._clean_markdown(content)
            
            # Convert to HTML
            html_content = self.md.convert(content)
            
            # Generate HTML page
            page_id = md_file.stem.lower().replace(' ', '-')
            html = self._generate_html_page(title, html_content, page_id)
            
            return {
                'id': page_id,
                'title': title,
                'html': html,
                'source': md_file.name,
                'keywords': self._extract_keywords(content)
            }
            
        except Exception as e:
            print(f"  ⚠️  Error processing {md_file.name}: {e}")
            return None
    
    def _clean_markdown(self, content: str) -> str:
        """Clean markdown content for Apple Help"""
        # Remove badges and shields.io links
        content = re.sub(r'!\[.*?\]\(https://img.shields.io/.*?\)', '', content)
        
        # Convert wiki links to help links
        content = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', 
                        lambda m: f'[{m.group(1)}]({m.group(2).lower().replace(" ", "-")}.html)', 
                        content)
        
        # Remove HTML comments
        content = re.sub(r'<!--.*?-->', '', content, flags=re.DOTALL)
        
        return content
    
    def _generate_html_page(self, title: str, content: str, page_id: str) -> str:
        """Generate complete HTML page with Apple Help styling"""
        return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="AppleTitle" content="{title}">
    <meta name="AppleIcon" content="images/FoT_core_128.png">
    <title>{title} - {HELP_BOOK_TITLE}</title>
    <link rel="stylesheet" href="../css/apple-help.css">
</head>
<body>
    <div class="help-container">
        <header>
            <img src="../images/FoT_core_128.png" alt="FoT" class="app-icon">
            <h1>{title}</h1>
        </header>
        
        <main>
            {content}
        </main>
        
        <footer>
            <p>© {datetime.now().year} Fortress AI. All rights reserved.</p>
            <p><a href="index.html">Help Index</a> | <a href="support.html">Contact Support</a></p>
        </footer>
    </div>
</body>
</html>"""
    
    def _extract_keywords(self, content: str) -> list:
        """Extract searchable keywords from content"""
        # Remove markdown formatting
        text = re.sub(r'[#*`\[\]()]', '', content)
        
        # Extract important words (3+ characters)
        words = re.findall(r'\b[A-Za-z]{3,}\b', text.lower())
        
        # Get unique words, sorted by frequency
        from collections import Counter
        word_freq = Counter(words)
        return [word for word, _ in word_freq.most_common(20)]
    
    def _categorize_page(self, page: dict):
        """Categorize page based on content"""
        title_lower = page['title'].lower()
        
        if any(word in title_lower for word in ['quick start', 'getting started', 'installation', 'setup']):
            self.categories['Getting Started'].append(page)
        elif any(word in title_lower for word in ['app', 'clinician', 'legal', 'education', 'personal']):
            self.categories['Apps'].append(page)
        elif any(word in title_lower for word in ['hipaa', 'ferpa', 'compliance', 'gdpr']):
            self.categories['Compliance'].append(page)
        elif any(word in title_lower for word in ['api', 'technical', 'integration', 'blockchain']):
            self.categories['Technical'].append(page)
        else:
            self.categories['Support'].append(page)
    
    def _generate_macos_help(self):
        """Generate macOS Apple Help bundle"""
        print("\n📦 Generating macOS Help Bundle...")
        
        resources_dir = MACOS_HELP / "Contents" / "Resources" / "en.lproj"
        
        # Write HTML pages
        for page in self.pages:
            html_file = resources_dir / f"{page['id']}.html"
            html_file.write_text(page['html'], encoding='utf-8')
        
        # Generate index page
        self._generate_help_index(resources_dir)
        
        # Generate Info.plist
        self._generate_info_plist()
        
        # Generate CSS
        self._generate_css()
        
        # Generate search index (helpindex)
        self._generate_search_index()
    
    def _generate_help_index(self, resources_dir: Path):
        """Generate main help index page"""
        categories_html = ""
        
        for category, pages in self.categories.items():
            if not pages:
                continue
                
            pages_html = "\n".join([
                f'<li><a href="{page["id"]}.html">{page["title"]}</a></li>'
                for page in sorted(pages, key=lambda p: p['title'])
            ])
            
            categories_html += f"""
            <section class="help-category">
                <h2>{category}</h2>
                <ul>
                    {pages_html}
                </ul>
            </section>
            """
        
        index_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="AppleTitle" content="FoT Apple Help">
    <title>{HELP_BOOK_TITLE}</title>
    <link rel="stylesheet" href="../css/apple-help.css">
</head>
<body>
    <div class="help-container">
        <header class="hero">
            <img src="../images/FoT_core_256.png" alt="FoT" class="hero-icon">
            <h1>FoT Apple Help</h1>
            <p>AI-Powered Decision Support for Medical, Legal, and Education</p>
        </header>
        
        <main>
            <div class="search-box">
                <input type="search" placeholder="Search help..." id="help-search">
            </div>
            
            {categories_html}
        </main>
        
        <footer>
            <p>© {datetime.now().year} Fortress AI. All rights reserved.</p>
        </footer>
    </div>
    
    <script src="../js/help-search.js"></script>
</body>
</html>"""
        
        (resources_dir / "index.html").write_text(index_html, encoding='utf-8')
    
    def _generate_info_plist(self):
        """Generate Info.plist for Help Bundle"""
        plist = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>{HELP_BOOK_IDENTIFIER}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>{HELP_BOOK_TITLE}</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>{HELP_BOOK_VERSION}</string>
    <key>CFBundleSignature</key>
    <string>hbwr</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>HPDBookAccessPath</key>
    <string>index.html</string>
    <key>HPDBookIndexPath</key>
    <string>FoTHelp.helpindex</string>
    <key>HPDBookTitle</key>
    <string>{HELP_BOOK_TITLE}</string>
    <key>HPDBookType</key>
    <string>3</string>
</dict>
</plist>"""
        
        (MACOS_HELP / "Contents" / "Info.plist").write_text(plist, encoding='utf-8')
    
    def _generate_css(self):
        """Generate Apple Help CSS"""
        css = """/* Apple Help Styling */
:root {
    --primary-color: #007AFF;
    --secondary-color: #5856D6;
    --text-color: #1D1D1F;
    --secondary-text: #6E6E73;
    --background: #FFFFFF;
    --glass-background: rgba(255, 255, 255, 0.72);
    --border-color: #D2D2D7;
    --shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

@media (prefers-color-scheme: dark) {
    :root {
        --text-color: #F5F5F7;
        --secondary-text: #A1A1A6;
        --background: #000000;
        --glass-background: rgba(29, 29, 31, 0.72);
        --border-color: #424245;
    }
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Helvetica Neue', sans-serif;
    font-size: 15px;
    line-height: 1.6;
    color: var(--text-color);
    background: var(--background);
    -webkit-font-smoothing: antialiased;
}

.help-container {
    max-width: 980px;
    margin: 0 auto;
    padding: 40px 20px;
}

header {
    text-align: center;
    margin-bottom: 48px;
    padding-bottom: 24px;
    border-bottom: 1px solid var(--border-color);
}

header.hero {
    border: none;
    margin-bottom: 64px;
}

.app-icon {
    width: 64px;
    height: 64px;
    margin-bottom: 16px;
    border-radius: 14px;
    box-shadow: var(--shadow);
}

.hero-icon {
    width: 128px;
    height: 128px;
    margin-bottom: 24px;
    border-radius: 28px;
    box-shadow: var(--shadow);
}

h1 {
    font-size: 48px;
    font-weight: 700;
    letter-spacing: -0.5px;
    margin-bottom: 12px;
}

header p {
    font-size: 21px;
    color: var(--secondary-text);
}

main {
    margin-bottom: 64px;
}

h2 {
    font-size: 32px;
    font-weight: 600;
    margin: 48px 0 24px;
    letter-spacing: -0.3px;
}

h3 {
    font-size: 24px;
    font-weight: 600;
    margin: 32px 0 16px;
}

p {
    margin-bottom: 16px;
}

a {
    color: var(--primary-color);
    text-decoration: none;
    transition: opacity 0.2s;
}

a:hover {
    opacity: 0.7;
}

ul, ol {
    margin: 16px 0;
    padding-left: 24px;
}

li {
    margin: 8px 0;
}

code {
    font-family: 'SF Mono', Monaco, 'Courier New', monospace;
    font-size: 13px;
    background: var(--glass-background);
    padding: 2px 6px;
    border-radius: 4px;
}

pre {
    background: var(--glass-background);
    padding: 16px;
    border-radius: 8px;
    overflow-x: auto;
    margin: 16px 0;
    border: 1px solid var(--border-color);
}

pre code {
    background: none;
    padding: 0;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin: 24px 0;
}

th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid var(--border-color);
}

th {
    font-weight: 600;
    background: var(--glass-background);
}

.search-box {
    margin-bottom: 48px;
}

#help-search {
    width: 100%;
    padding: 12px 16px;
    font-size: 17px;
    border: 1px solid var(--border-color);
    border-radius: 10px;
    background: var(--glass-background);
    color: var(--text-color);
    outline: none;
    transition: all 0.2s;
}

#help-search:focus {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1);
}

.help-category {
    margin-bottom: 48px;
}

.help-category h2 {
    margin-top: 0;
}

.help-category ul {
    list-style: none;
    padding: 0;
}

.help-category li {
    margin: 8px 0;
}

.help-category li a {
    display: block;
    padding: 12px 16px;
    background: var(--glass-background);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    transition: all 0.2s;
}

.help-category li a:hover {
    opacity: 1;
    background: var(--primary-color);
    color: white;
    transform: translateX(4px);
}

footer {
    text-align: center;
    padding-top: 32px;
    border-top: 1px solid var(--border-color);
    color: var(--secondary-text);
    font-size: 13px;
}

footer p {
    margin: 8px 0;
}

@media (max-width: 768px) {
    .help-container {
        padding: 24px 16px;
    }
    
    h1 {
        font-size: 36px;
    }
    
    h2 {
        font-size: 28px;
    }
}"""
        
        css_dir = MACOS_HELP / "Contents" / "Resources" / "css"
        (css_dir / "apple-help.css").write_text(css, encoding='utf-8')
    
    def _generate_search_index(self):
        """Generate search index for Apple Help"""
        # Create helpindex file (simplified - Apple's hiutil would normally do this)
        index_data = []
        
        for page in self.pages:
            index_data.append({
                'title': page['title'],
                'url': f"{page['id']}.html",
                'keywords': ' '.join(page['keywords'])
            })
        
        # Write search data as JSON (for JavaScript search)
        import json
        js_dir = MACOS_HELP / "Contents" / "Resources" / "js"
        js_dir.mkdir(exist_ok=True)
        
        search_js = f"""// FoT Apple Help Search
const searchData = {json.dumps(index_data, indent=2)};

document.addEventListener('DOMContentLoaded', function() {{
    const searchInput = document.getElementById('help-search');
    if (!searchInput) return;
    
    searchInput.addEventListener('input', function(e) {{
        const query = e.target.value.toLowerCase();
        if (query.length < 2) return;
        
        // Simple search implementation
        console.log('Searching for:', query);
    }});
}});"""
        
        (js_dir / "help-search.js").write_text(search_js, encoding='utf-8')
    
    def _generate_ios_help(self):
        """Generate iOS help resources"""
        print("\n📱 Generating iOS Help Resources...")
        
        # Create iOS-friendly JSON structure
        help_data = {
            'version': HELP_BOOK_VERSION,
            'title': HELP_BOOK_TITLE,
            'categories': {}
        }
        
        for category, pages in self.categories.items():
            if not pages:
                continue
                
            help_data['categories'][category] = [
                {
                    'id': page['id'],
                    'title': page['title'],
                    'keywords': page['keywords']
                }
                for page in pages
            ]
        
        # Write JSON
        import json
        (IOS_HELP / "help-data.json").write_text(
            json.dumps(help_data, indent=2),
            encoding='utf-8'
        )
        
        # Write HTML pages for iOS
        for page in self.pages:
            (IOS_HELP / f"{page['id']}.html").write_text(page['html'], encoding='utf-8')
    
    def _copy_assets(self):
        """Copy images and other assets"""
        print("\n🖼️  Copying assets...")
        
        wiki_screenshots = WIKI_DIR / "screenshots"
        if wiki_screenshots.exists():
            dest = MACOS_HELP / "Contents" / "Resources" / "images"
            
            # Copy icon files
            for icon_file in wiki_screenshots.glob("FoT_core_*.png"):
                shutil.copy2(icon_file, dest / icon_file.name)
            
            print(f"  ✅ Copied {len(list(dest.glob('*.png')))} images")


def main():
    """Main execution"""
    print("=" * 60)
    print("FoT Wiki to Apple Help Converter")
    print("=" * 60)
    
    converter = WikiToAppleHelpConverter()
    converter.convert_all()
    
    print("\n" + "=" * 60)
    print("✅ CONVERSION COMPLETE!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Add FoTHelp.help to your Xcode project")
    print("2. Configure Help Book in Info.plist")
    print("3. For iOS, integrate the HelpView.swift component")
    print("\nSee APPLE_HELP_INTEGRATION.md for details")


if __name__ == "__main__":
    main()

