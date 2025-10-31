#!/usr/bin/env python3
"""
Generate Professional Domain-Specific Icons
Cohesive design with Personal vs Professional archetypes
"""

from PIL import Image, ImageDraw, ImageFont
import os
import json

PROJECT_DIR = "/Users/richardgillespie/Documents/FoTApple"

# Icon configuration
ICONS = [
    {
        "name": "PersonalHealth",
        "dir": "apps/PersonalHealthApp/iOS/PersonalHealth/Assets.xcassets/AppIcon.appiconset",
        "base_color": (230, 57, 70),      # Red
        "accent_color": (255, 107, 107),  # Pink
        "symbol": "♥",
        "type": "PERSONAL",
        "emoji": "🔴"
    },
    {
        "name": "Clinician",
        "dir": "apps/ClinicianApp/iOS/FoTClinician/Assets.xcassets/AppIcon.appiconset",
        "base_color": (0, 119, 182),      # Medical Blue
        "accent_color": (0, 180, 216),    # Cyan
        "symbol": "⚕",
        "type": "PROFESSIONAL",
        "emoji": "🔵"
    },
    {
        "name": "Legal",
        "dir": "apps/LegalApp/iOS/FoTLegal/Assets.xcassets/AppIcon.appiconset",
        "base_color": (27, 54, 93),       # Navy
        "accent_color": (218, 165, 32),   # Gold
        "symbol": "⚖",
        "type": "PROFESSIONAL",
        "emoji": "🟦"
    },
    {
        "name": "Education",
        "dir": "apps/EducationApp/iOS/FoTEducation/Assets.xcassets/AppIcon.appiconset",
        "base_color": (42, 157, 143),     # Teal
        "accent_color": (82, 183, 136),   # Green
        "symbol": "📚",
        "type": "PROFESSIONAL",
        "emoji": "🟢"
    },
    {
        "name": "Parent",
        "dir": "apps/ParentApp/iOS/FoTParent/Assets.xcassets/AppIcon.appiconset",
        "base_color": (114, 9, 183),      # Deep Purple
        "accent_color": (177, 133, 219),  # Light Purple
        "symbol": "👪",
        "type": "PERSONAL",
        "emoji": "🟣"
    }
]

SIZES = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]

def interpolate_color(color1, color2, t):
    """Interpolate between two RGB colors"""
    return tuple(int(c1 + (c2 - c1) * t) for c1, c2 in zip(color1, color2))

def create_gradient(size, base_color, accent_color):
    """Create diagonal gradient background"""
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)
    
    # Diagonal gradient (top-left to bottom-right)
    for y in range(size):
        for x in range(size):
            # Calculate position along diagonal (0 to 1)
            t = (x + y) / (2 * size)
            color = interpolate_color(base_color, accent_color, t)
            draw.point((x, y), fill=color)
    
    return img

def add_rounded_corners(img, radius):
    """Add rounded corners to image"""
    size = img.size[0]
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (size-1, size-1)], radius=radius, fill=255)
    
    result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    result.paste(img, (0, 0))
    result.putalpha(mask)
    return result

def create_icon(config, size):
    """Create a single icon"""
    # Create gradient background
    img = create_gradient(size, config['base_color'], config['accent_color'])
    
    # Convert to RGBA for transparency support
    img = img.convert('RGBA')
    
    # Add rounded corners for PERSONAL apps
    if config['type'] == 'PERSONAL':
        radius = size // 8
        img = add_rounded_corners(img, radius)
    
    # Add symbol
    draw = ImageDraw.Draw(img)
    
    # Try to load a font, fallback to default
    try:
        # Use system font
        font_size = size // 2
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size // 2)
        except:
            font = ImageFont.load_default()
    
    # Draw symbol in center
    symbol = config['symbol']
    bbox = draw.textbbox((0, 0), symbol, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((size - text_width) // 2, (size - text_height) // 2 - size // 20)
    
    # Draw with white color
    draw.text(position, symbol, fill=(255, 255, 255, 255), font=font)
    
    # Add 'P' badge for PERSONAL apps
    if config['type'] == 'PERSONAL':
        badge_size = size // 4
        badge_x = size - badge_size - size // 12
        badge_y = size - badge_size - size // 12
        
        # Draw badge circle with accent color
        draw.ellipse(
            [(badge_x, badge_y), (badge_x + badge_size, badge_y + badge_size)],
            fill=config['accent_color']
        )
        
        # Draw 'P' text
        try:
            badge_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", badge_size // 2)
        except:
            badge_font = ImageFont.load_default()
        
        p_bbox = draw.textbbox((0, 0), 'P', font=badge_font)
        p_width = p_bbox[2] - p_bbox[0]
        p_height = p_bbox[3] - p_bbox[1]
        p_x = badge_x + (badge_size - p_width) // 2
        p_y = badge_y + (badge_size - p_height) // 2
        
        draw.text((p_x, p_y), 'P', fill=(255, 255, 255, 255), font=badge_font)
    
    # Add corner accent for PROFESSIONAL apps
    elif config['type'] == 'PROFESSIONAL':
        corner_width = size // 3
        corner_height = size // 3
        overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        overlay_draw = ImageDraw.Draw(overlay)
        overlay_draw.rectangle(
            [(size - corner_width, 0), (size, corner_height)],
            fill=(255, 255, 255, 50)
        )
        img = Image.alpha_composite(img, overlay)
    
    return img

def create_contents_json():
    """Create Contents.json for app icon"""
    return {
        "images": [
            {"filename": "icon_20x20.png", "idiom": "iphone", "scale": "2x", "size": "20x20"},
            {"filename": "icon_20x20.png", "idiom": "iphone", "scale": "3x", "size": "20x20"},
            {"filename": "icon_29x29.png", "idiom": "iphone", "scale": "2x", "size": "29x29"},
            {"filename": "icon_29x29.png", "idiom": "iphone", "scale": "3x", "size": "29x29"},
            {"filename": "icon_40x40.png", "idiom": "iphone", "scale": "2x", "size": "40x40"},
            {"filename": "icon_40x40.png", "idiom": "iphone", "scale": "3x", "size": "40x40"},
            {"filename": "icon_60x60.png", "idiom": "iphone", "scale": "2x", "size": "60x60"},
            {"filename": "icon_60x60.png", "idiom": "iphone", "scale": "3x", "size": "60x60"},
            {"filename": "icon_20x20.png", "idiom": "ipad", "scale": "1x", "size": "20x20"},
            {"filename": "icon_40x40.png", "idiom": "ipad", "scale": "2x", "size": "20x20"},
            {"filename": "icon_29x29.png", "idiom": "ipad", "scale": "1x", "size": "29x29"},
            {"filename": "icon_58x58.png", "idiom": "ipad", "scale": "2x", "size": "29x29"},
            {"filename": "icon_40x40.png", "idiom": "ipad", "scale": "1x", "size": "40x40"},
            {"filename": "icon_80x80.png", "idiom": "ipad", "scale": "2x", "size": "40x40"},
            {"filename": "icon_76x76.png", "idiom": "ipad", "scale": "1x", "size": "76x76"},
            {"filename": "icon_152x152.png", "idiom": "ipad", "scale": "2x", "size": "76x76"},
            {"filename": "icon_167x167.png", "idiom": "ipad", "scale": "2x", "size": "83.5x83.5"},
            {"filename": "icon_1024x1024.png", "idiom": "ios-marketing", "scale": "1x", "size": "1024x1024"}
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

def main():
    print("🎨 GENERATING PROFESSIONAL DOMAIN ICONS")
    print()
    print("Design Strategy:")
    print("  📱 PERSONAL Apps: Rounded, warm colors, 'P' badge")
    print("  👔 PROFESSIONAL Apps: Sharp, authoritative symbols")
    print()
    
    os.chdir(PROJECT_DIR)
    
    for config in ICONS:
        print("━" * 40)
        print(f"{config['emoji']} {config['name']}")
        print("━" * 40)
        print(f"   Type: {config['type']}")
        print(f"   Symbol: {config['symbol']}")
        print()
        
        icon_dir = os.path.join(PROJECT_DIR, config['dir'])
        os.makedirs(icon_dir, exist_ok=True)
        
        # Remove old icons
        for file in os.listdir(icon_dir):
            if file.startswith('icon_') and file.endswith('.png'):
                os.remove(os.path.join(icon_dir, file))
        
        # Generate all sizes
        for size in SIZES:
            print(f"   Creating {size}x{size}...")
            img = create_icon(config, size)
            
            # Convert to RGB if saving as PNG without alpha
            if img.mode == 'RGBA':
                # Keep RGBA for transparency
                img.save(os.path.join(icon_dir, f"icon_{size}x{size}.png"), "PNG")
            else:
                img.save(os.path.join(icon_dir, f"icon_{size}x{size}.png"), "PNG")
        
        # Create Contents.json
        with open(os.path.join(icon_dir, "Contents.json"), "w") as f:
            json.dump(create_contents_json(), f, indent=2)
        
        print("   ✅ Complete")
        print()
    
    print("━" * 40)
    print("✅ ALL PROFESSIONAL DOMAIN ICONS GENERATED!")
    print("━" * 40)
    print()
    print("Icon Summary:")
    print("  👤 PERSONAL:")
    print("     • PersonalHealth: Red gradient, heart ♥, 'P' badge")
    print("     • Parent: Purple gradient, family 👪, 'P' badge")
    print()
    print("  👔 PROFESSIONAL:")
    print("     • Clinician: Medical blue, caduceus ⚕")
    print("     • Legal: Navy-Gold, scales ⚖")
    print("     • Education: Green, books 📚")
    print()

if __name__ == "__main__":
    main()

