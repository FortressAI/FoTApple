#!/usr/bin/env python3
"""
FoT Asset Generator - Adapted for local macOS Xcode project
Generates app icons, badges, and glass morphism assets for all three domains:
- Clinician (blue/cyan/teal)
- Education (green/mint/yellow)  
- Legal (indigo/purple/blue)

Outputs directly to each app's Assets.xcassets directory.
"""

import os, math, sys
from PIL import Image, ImageDraw, ImageFilter
try:
    import numpy as np
except ImportError:
    print("⚠️  Installing numpy for noise generation...")
    os.system(f"{sys.executable} -m pip install numpy pillow --quiet")
    import numpy as np

# Domain configurations
DOMAINS = {
    "clinician": {
        "colors": {
            "bg_dark": (8, 40, 80),
            "bg_primary": (20, 120, 220),
            "bg_light": (100, 200, 255),
            "glyph_accent": (120, 240, 255),
        },
        "glyph": "stethoscope",  # Concept: medical cross + stethoscope curves
        "app_path": "apps/ClinicianApp/iOS/FoTClinician/Assets.xcassets"
    },
    "education": {
        "colors": {
            "bg_dark": (10, 50, 20),
            "bg_primary": (50, 180, 100),
            "bg_light": (150, 230, 120),
            "glyph_accent": (200, 255, 100),
        },
        "glyph": "book",  # Concept: open book + learning path
        "app_path": "apps/EducationK18App/iOS/FoTEducation/Assets.xcassets"
    },
    "legal": {
        "colors": {
            "bg_dark": (20, 10, 50),
            "bg_primary": (80, 50, 180),
            "bg_light": (150, 120, 230),
            "glyph_accent": (180, 150, 255),
        },
        "glyph": "scales",  # Concept: balanced scales + gavel
        "app_path": "apps/LegalUSApp/iOS/FoTLegalUS/Assets.xcassets"
    }
}

MATERIALS = {
    "glass_blur": 30,
    "glass_opacity": 0.75,
    "glass_noise": 0.025,
    "card_blur": 28,
    "card_opacity": 0.72,
}

def vertical_gradient(size, top_color, mid_color, bottom_color):
    """Create a 3-stop vertical gradient."""
    w, h = size
    img = Image.new("RGB", (w, h), color=top_color)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / (h - 1) if h > 1 else 0
        if t < 0.5:
            u = t / 0.5
            r = int(top_color[0] + u * (mid_color[0] - top_color[0]))
            g = int(top_color[1] + u * (mid_color[1] - top_color[1]))
            b = int(top_color[2] + u * (mid_color[2] - top_color[2]))
        else:
            u = (t - 0.5) / 0.5
            r = int(mid_color[0] + u * (bottom_color[0] - mid_color[0]))
            g = int(mid_color[1] + u * (bottom_color[1] - mid_color[1]))
            b = int(mid_color[2] + u * (bottom_color[2] - mid_color[2]))
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return img

def add_glass_panel(img, bbox, blur_px, opacity, noise_level=0.02):
    """Add glass morphism panel with blur, opacity, and noise."""
    w, h = img.size
    x0, y0, x1, y1 = bbox
    
    # Extract and blur region
    x0_crop = max(int(x0 - blur_px), 0)
    y0_crop = max(int(y0 - blur_px), 0)
    x1_crop = min(int(x1 + blur_px), w)
    y1_crop = min(int(y1 + blur_px), h)
    
    region = img.crop((x0_crop, y0_crop, x1_crop, y1_crop))
    region = region.filter(ImageFilter.GaussianBlur(blur_px))
    
    # White tint overlay
    overlay = Image.new("RGBA", region.size, (255, 255, 255, int(255 * opacity * 0.6)))
    region = Image.alpha_composite(region.convert("RGBA"), overlay)
    
    # Film grain noise
    if noise_level > 0:
        arr = np.array(region).astype('int16')
        noise = np.random.normal(0, 255 * noise_level, arr.shape[:2] + (1,))
        arr[..., :3] = np.clip(arr[..., :3] + noise, 0, 255)
        region = Image.fromarray(arr.astype('uint8'), 'RGBA')
    
    # Rounded rectangle mask
    mask = Image.new("L", region.size, 0)
    mask_draw = ImageDraw.Draw(mask)
    rx = int(min(region.size) * 0.08)
    mask_draw.rounded_rectangle((0, 0, region.size[0]-1, region.size[1]-1), radius=rx, fill=255)
    
    img.paste(region, (x0_crop, y0_crop), mask)
    return img

def draw_domain_glyph(draw, center, scale, color, glyph_type):
    """Draw domain-specific glyph."""
    cx, cy = center
    s = scale
    line_width = max(2, int(s * 0.02))
    
    if glyph_type == "stethoscope":
        # Medical: concentric circles + cross
        draw.ellipse((cx - s, cy - s, cx + s, cy + s), outline=color, width=line_width)
        draw.ellipse((cx - s*0.6, cy - s*0.6, cx + s*0.6, cy + s*0.6), outline=color, width=line_width)
        draw.line((cx - s*0.7, cy, cx + s*0.7, cy), fill=color, width=line_width)
        draw.line((cx, cy - s*0.7, cx, cy + s*0.7), fill=color, width=line_width)
        
    elif glyph_type == "book":
        # Education: open book shape
        draw.rectangle((cx - s*0.7, cy - s*0.5, cx + s*0.7, cy + s*0.5), outline=color, width=line_width)
        draw.line((cx, cy - s*0.5, cx, cy + s*0.5), fill=color, width=line_width)
        # Pages
        for i in range(-2, 3):
            y = cy + i * s * 0.2
            draw.line((cx - s*0.5, y, cx - s*0.1, y), fill=color, width=line_width//2)
            draw.line((cx + s*0.1, y, cx + s*0.5, y), fill=color, width=line_width//2)
            
    elif glyph_type == "scales":
        # Legal: balanced scales
        draw.line((cx - s*0.8, cy, cx + s*0.8, cy), fill=color, width=line_width)
        draw.line((cx, cy - s*0.3, cx, cy + s*0.6), fill=color, width=line_width)
        # Left pan
        draw.rectangle((cx - s*0.8, cy - s*0.2, cx - s*0.4, cy), outline=color, width=line_width)
        # Right pan
        draw.rectangle((cx + s*0.4, cy - s*0.2, cx + s*0.8, cy), outline=color, width=line_width)

def create_app_icon(domain_config, size=1024):
    """Generate app icon with glass morphism."""
    colors = domain_config["colors"]
    bg = vertical_gradient((size, size), colors["bg_dark"], colors["bg_primary"], colors["bg_light"])
    img = bg.convert("RGBA")
    
    # Glass panel
    pad = int(size * 0.08)
    bbox = (pad, pad, size - pad, size - pad)
    img = add_glass_panel(img, bbox, MATERIALS["glass_blur"], MATERIALS["glass_opacity"], MATERIALS["glass_noise"])
    
    # Glyph
    draw = ImageDraw.Draw(img)
    draw_domain_glyph(draw, (size//2, size//2), int(size * 0.26), colors["glyph_accent"], domain_config["glyph"])
    
    return img

def setup_assets_catalog(app_path):
    """Create Assets.xcassets structure if it doesn't exist."""
    assets_path = app_path
    if not os.path.exists(assets_path):
        os.makedirs(assets_path)
        
    # Create AppIcon.appiconset
    icon_set_path = os.path.join(assets_path, "AppIcon.appiconset")
    os.makedirs(icon_set_path, exist_ok=True)
    
    # Create Contents.json for AppIcon
    contents = {
        "images": [
            {"size": "1024x1024", "idiom": "universal", "filename": "icon_1024.png", "scale": "1x"}
        ],
        "info": {"version": 1, "author": "xcode"}
    }
    
    import json
    with open(os.path.join(icon_set_path, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    
    return icon_set_path

def generate_domain_assets(domain_name, domain_config, project_root):
    """Generate all assets for a domain."""
    print(f"\n🎨 Generating assets for {domain_name.upper()}...")
    
    app_path = os.path.join(project_root, domain_config["app_path"])
    icon_set_path = setup_assets_catalog(app_path)
    
    # Generate app icon
    print(f"   → Creating app icon (1024x1024)...")
    icon = create_app_icon(domain_config, 1024)
    icon.save(os.path.join(icon_set_path, "icon_1024.png"))
    
    print(f"   ✅ Assets generated for {domain_name}")
    return True

def main():
    """Main entry point."""
    # Detect project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)  # Go up one level from scripts/
    
    print("🚀 FoT Asset Generator")
    print(f"📁 Project root: {project_root}")
    
    # Generate assets for each domain
    for domain_name, domain_config in DOMAINS.items():
        try:
            generate_domain_assets(domain_name, domain_config, project_root)
        except Exception as e:
            print(f"   ❌ Error generating {domain_name}: {e}")
    
    print("\n✨ Asset generation complete!")
    print("\nℹ️  To use these assets:")
    print("   1. Open Xcode")
    print("   2. Navigate to each app's Assets.xcassets")
    print("   3. The AppIcon.appiconset should contain icon_1024.png")
    print("   4. Build and run to see the custom icons!")

if __name__ == "__main__":
    main()

