import os
from PIL import Image

SOURCE_IMAGE = r"C:\Users\USER\.gemini\antigravity-ide\brain\07024a09-c104-4e01-a69c-6e870913da11\spendly_app_icon_1790849731237.jpg"
PROJECT_ROOT = os.path.abspath(r"d:\Flutter Task")

def generate_icons():
    if not os.path.exists(SOURCE_IMAGE):
        print(f"Error: Source image not found at {SOURCE_IMAGE}")
        return

    img = Image.open(SOURCE_IMAGE).convert("RGBA")
    print(f"Loaded source image {img.size}")

    # 1. Save master icon to assets/icon/app_icon.png
    assets_dir = os.path.join(PROJECT_ROOT, "assets", "icon")
    os.makedirs(assets_dir, exist_ok=True)
    master_path = os.path.join(assets_dir, "app_icon.png")
    img.save(master_path, format="PNG")
    print(f"Saved master icon to {master_path}")

    # 2. Android Mipmap densities
    android_res = os.path.join(PROJECT_ROOT, "android", "app", "src", "main", "res")
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, size in android_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        out_path = os.path.join(folder_path, "ic_launcher.png")
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(out_path, format="PNG")
        print(f"Generated Android {folder}/ic_launcher.png ({size}x{size})")

    # 3. Web icons
    web_dir = os.path.join(PROJECT_ROOT, "web")
    if os.path.exists(web_dir):
        # favicon
        fav_path = os.path.join(web_dir, "favicon.png")
        img.resize((32, 32), Image.Resampling.LANCZOS).save(fav_path, format="PNG")
        print("Generated web/favicon.png (32x32)")

        # icons folder
        web_icons_dir = os.path.join(web_dir, "icons")
        if os.path.exists(web_icons_dir):
            img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-192.png"), format="PNG")
            img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-512.png"), format="PNG")
            img.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-maskable-192.png"), format="PNG")
            img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, "Icon-maskable-512.png"), format="PNG")
            print("Generated web/icons (192, 512, maskable)")

    # 4. Windows Desktop icon (.ico)
    windows_res = os.path.join(PROJECT_ROOT, "windows", "runner", "resources")
    if os.path.exists(windows_res):
        ico_path = os.path.join(windows_res, "app_icon.ico")
        img.save(ico_path, format="ICO", sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
        print("Generated windows/runner/resources/app_icon.ico")

    print("\nAll app icons successfully generated and deployed!")

if __name__ == "__main__":
    generate_icons()
