#!/usr/bin/env python3
"""Remove alpha channels from all app icons"""

from PIL import Image
import os
from pathlib import Path

print("🎨 REMOVING ALPHA CHANNELS FROM ALL APP ICONS")
print("=" * 50)
print()

apps = [
    "apps/PersonalHealthApp/iOS/PersonalHealth",
    "apps/ClinicianApp/iOS/FoTClinician",
    "apps/LegalApp/iOS/FoTLegal",
    "apps/EducationApp/iOS/FoTEducation",
    "apps/ParentApp/iOS/FoTParent"
]

for app_path in apps:
    icon_dir = Path(app_path) / "Assets.xcassets" / "AppIcon.appiconset"
    
    if not icon_dir.exists():
        print(f"⚠️  Skipping {app_path} - icon directory not found")
        continue
    
    print(f"📝 Processing {Path(app_path).name}...")
    
    for icon_file in icon_dir.glob("*.png"):
        try:
            # Open image
            img = Image.open(icon_file)
            
            # Check if has alpha
            if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
                # Convert to RGB (removes alpha)
                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                rgb_img.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                
                # Save without alpha
                rgb_img.save(icon_file, 'PNG')
                print(f"  ✅ Removed alpha from {icon_file.name}")
            else:
                print(f"  ✓  {icon_file.name} already has no alpha")
                
        except Exception as e:
            print(f"  ❌ Error processing {icon_file.name}: {e}")
    
    print()

print("=" * 50)
print("✅ ALL ICONS PROCESSED")
print("Icons now have no alpha channels and are ready for App Store")

