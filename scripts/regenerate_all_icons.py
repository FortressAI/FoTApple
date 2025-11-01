#!/usr/bin/env python3
"""
🎨 iOS App Icon Generator
Resizes source images to all required iOS icon sizes
"""

import os
import json
from PIL import Image
from pathlib import Path

# Icon configurations
APPS = {
    "Clinician": {
        "source": "/Users/richardgillespie/Downloads/Gemini_Generated_Image_78ii6678ii6678ii (3).png",
        "asset_path": "apps/ClinicianApp/iOS/FoTClinician/Assets.xcassets/AppIcon.appiconset"
    },
    "PersonalHealth": {
        "source": "/Users/richardgillespie/Downloads/Gemini_Generated_Image_m3z9iam3z9iam3z9 (4).png",
        "asset_path": "apps/PersonalHealthApp/iOS/PersonalHealth/Assets.xcassets/AppIcon.appiconset"
    },
    "Legal": {
        "source": "/Users/richardgillespie/Downloads/Gemini_Generated_Image_rsq08jrsq08jrsq0 (1).png",
        "asset_path": "apps/LegalApp/iOS/FoTLegal/Assets.xcassets/AppIcon.appiconset"
    },
    "Parent": {
        "source": "/Users/richardgillespie/Downloads/Gemini_Generated_Image_78ii6678ii6678ii (1).png",
        "asset_path": "apps/ParentApp/iOS/FoTParent/Assets.xcassets/AppIcon.appiconset"
    },
    "Education": {
        "source": "/Users/richardgillespie/Downloads/Gemini_Generated_Image_78ii6678ii6678ii.png",
        "asset_path": "apps/EducationApp/iOS/FoTEducation/Assets.xcassets/AppIcon.appiconset"
    }
}

# Required icon sizes for iOS
ICON_SIZES = [
    {"size": 40, "scale": 2, "idiom": "iphone", "filename": "icon_40x40@2x.png"},
    {"size": 60, "scale": 2, "idiom": "iphone", "filename": "icon_60x60@2x.png"},
    {"size": 60, "scale": 3, "idiom": "iphone", "filename": "icon_60x60@3x.png"},
    {"size": 20, "scale": 2, "idiom": "iphone", "filename": "icon_20x20@2x.png"},
    {"size": 20, "scale": 3, "idiom": "iphone", "filename": "icon_20x20@3x.png"},
    {"size": 29, "scale": 2, "idiom": "iphone", "filename": "icon_29x29@2x.png"},
    {"size": 29, "scale": 3, "idiom": "iphone", "filename": "icon_29x29@3x.png"},
    {"size": 40, "scale": 2, "idiom": "ipad", "filename": "icon_40x40@2x_ipad.png"},
    {"size": 76, "scale": 2, "idiom": "ipad", "filename": "icon_76x76@2x.png"},
    {"size": 83.5, "scale": 2, "idiom": "ipad", "filename": "icon_83.5x83.5@2x.png"},
    {"size": 1024, "scale": 1, "idiom": "ios-marketing", "filename": "icon_1024x1024.png"},
]

def remove_alpha_channel(image):
    """Remove alpha channel and use white background"""
    if image.mode in ('RGBA', 'LA'):
        background = Image.new('RGB', image.size, (255, 255, 255))
        if image.mode == 'RGBA':
            background.paste(image, mask=image.split()[3])
        else:
            background.paste(image, mask=image.split()[1])
        return background
    elif image.mode != 'RGB':
        return image.convert('RGB')
    return image

def generate_icons(app_name, source_path, asset_path):
    """Generate all icon sizes for an app"""
    print(f"\n🎨 Processing {app_name}...")
    print(f"   Source: {source_path}")
    print(f"   Destination: {asset_path}")
    
    # Load source image
    try:
        img = Image.open(source_path)
        img = remove_alpha_channel(img)
        print(f"   ✅ Loaded {img.size[0]}x{img.size[1]} image")
    except Exception as e:
        print(f"   ❌ Error loading image: {e}")
        return False
    
    # Create asset directory if it doesn't exist
    os.makedirs(asset_path, exist_ok=True)
    
    # Generate each icon size
    generated_files = []
    for icon_spec in ICON_SIZES:
        target_size = int(icon_spec["size"] * icon_spec["scale"])
        filename = icon_spec["filename"]
        output_path = os.path.join(asset_path, filename)
        
        try:
            # Resize with high-quality antialiasing
            resized = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
            resized.save(output_path, "PNG", optimize=True)
            generated_files.append({
                "size": f"{icon_spec['size']}x{icon_spec['size']}",
                "scale": f"{icon_spec['scale']}x",
                "idiom": icon_spec["idiom"],
                "filename": filename
            })
            print(f"   ✅ {filename} ({target_size}x{target_size})")
        except Exception as e:
            print(f"   ❌ Error generating {filename}: {e}")
            return False
    
    # Create Contents.json
    contents = {
        "images": [
            {
                "size": item["size"],
                "idiom": item["idiom"],
                "filename": item["filename"],
                "scale": item["scale"]
            }
            for item in generated_files
        ],
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }
    
    contents_path = os.path.join(asset_path, "Contents.json")
    try:
        with open(contents_path, 'w') as f:
            json.dump(contents, f, indent=2)
        print(f"   ✅ Contents.json created")
    except Exception as e:
        print(f"   ❌ Error creating Contents.json: {e}")
        return False
    
    print(f"   ✅ {app_name} icons complete!")
    return True

def main():
    """Main execution"""
    print("=" * 70)
    print("🎨 iOS APP ICON GENERATOR")
    print("=" * 70)
    
    # Change to project root
    project_root = "/Users/richardgillespie/Documents/FoTApple"
    os.chdir(project_root)
    print(f"\n📁 Working directory: {project_root}")
    
    success_count = 0
    fail_count = 0
    
    # Generate icons for each app
    for app_name, config in APPS.items():
        if generate_icons(app_name, config["source"], config["asset_path"]):
            success_count += 1
        else:
            fail_count += 1
    
    print("\n" + "=" * 70)
    print("🎯 ICON GENERATION COMPLETE")
    print("=" * 70)
    print(f"✅ Success: {success_count}/5 apps")
    print(f"❌ Failed: {fail_count}/5 apps")
    print("")
    
    if success_count == 5:
        print("🎉 ALL ICONS GENERATED SUCCESSFULLY!")
        return 0
    else:
        print("⚠️  Some icons failed to generate")
        return 1

if __name__ == "__main__":
    exit(main())

