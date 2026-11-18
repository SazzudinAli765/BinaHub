"""
Generate Cyberpunk Neon Butterfly Icons for BinaHub Android App
Generates high-res PNGs and adaptive vectors for all Android mipmap buckets.
"""
import os
import math
from PIL import Image, ImageDraw, ImageFilter

BASE_RES = r"D:\Projects\BinaHub\android\app\src\main\res"

def create_butterfly_image(size=512):
    # Create high-res canvas
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = size / 2, size / 2
    s = size / 512.0
    
    # 1. Dark Carbon Hexagonal / Rounded background
    # Background plate: Deep void dark with subtle cyan/violet border
    pad = int(16 * s)
    corner = int(96 * s)
    draw.rounded_rectangle(
        [pad, pad, size - pad, size - pad],
        radius=corner,
        fill=(7, 10, 14, 255),
        outline=(0, 240, 255, 180),
        width=int(6 * s)
    )
    
    # Inner subtle glow ring
    inner_pad = int(24 * s)
    inner_corner = int(88 * s)
    draw.rounded_rectangle(
        [inner_pad, inner_pad, size - inner_pad, size - inner_pad],
        radius=inner_corner,
        fill=None,
        outline=(189, 0, 255, 90),
        width=int(2 * s)
    )

    # 2. Butterfly Wings Geometry
    # We will draw left wing and mirror to right wing for perfect symmetry
    
    # Upper Wing Polygon (Left)
    upper_wing_left = [
        (cx - 8 * s, cy - 20 * s),
        (cx - 70 * s, cy - 130 * s),
        (cx - 150 * s, cy - 180 * s),
        (cx - 210 * s, cy - 150 * s),
        (cx - 220 * s, cy - 70 * s),
        (cx - 170 * s, cy + 20 * s),
        (cx - 90 * s, cy + 10 * s),
        (cx - 12 * s, cy + 5 * s)
    ]
    
    # Lower Wing Polygon (Left)
    lower_wing_left = [
        (cx - 10 * s, cy + 25 * s),
        (cx - 80 * s, cy + 30 * s),
        (cx - 160 * s, cy + 70 * s),
        (cx - 170 * s, cy + 140 * s),
        (cx - 120 * s, cy + 190 * s),
        (cx - 60 * s, cy + 170 * s),
        (cx - 30 * s, cy + 90 * s),
        (cx - 8 * s, cy + 50 * s)
    ]
    
    # Inner Upper Accent Polygon (Left)
    inner_upper_left = [
        (cx - 25 * s, cy - 25 * s),
        (cx - 80 * s, cy - 100 * s),
        (cx - 145 * s, cy - 135 * s),
        (cx - 170 * s, cy - 80 * s),
        (cx - 120 * s, cy - 10 * s),
        (cx - 28 * s, cy + 0 * s)
    ]
    
    # Inner Lower Accent Polygon (Left)
    inner_lower_left = [
        (cx - 25 * s, cy + 40 * s),
        (cx - 75 * s, cy + 55 * s),
        (cx - 125 * s, cy + 105 * s),
        (cx - 120 * s, cy + 145 * s),
        (cx - 70 * s, cy + 135 * s),
        (cx - 25 * s, cy + 65 * s)
    ]

    def mirror_poly(poly):
        return [(2 * cx - x, y) for (x, y) in poly]

    # Draw Outer Wings with Glowing Cyan & Violet gradients/layers
    upper_wing_right = mirror_poly(upper_wing_left)
    lower_wing_right = mirror_poly(lower_wing_left)
    inner_upper_right = mirror_poly(inner_upper_left)
    inner_lower_right = mirror_poly(inner_lower_left)

    # Glow effect behind wings
    glow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow_layer)
    gdraw.polygon(upper_wing_left, fill=(0, 240, 255, 120))
    gdraw.polygon(upper_wing_right, fill=(0, 240, 255, 120))
    gdraw.polygon(lower_wing_left, fill=(189, 0, 255, 120))
    gdraw.polygon(lower_wing_right, fill=(189, 0, 255, 120))
    glow_blurred = glow_layer.filter(ImageFilter.GaussianBlur(radius=int(14 * s)))
    img = Image.alpha_composite(img, glow_blurred)
    draw = ImageDraw.Draw(img)

    # Solid Upper Wings - Electric Cyan
    draw.polygon(upper_wing_left, fill=(0, 229, 255, 230), outline=(255, 255, 255, 220), width=int(3 * s))
    draw.polygon(upper_wing_right, fill=(0, 229, 255, 230), outline=(255, 255, 255, 220), width=int(3 * s))

    # Solid Lower Wings - Electric Magenta / Violet
    draw.polygon(lower_wing_left, fill=(189, 0, 255, 220), outline=(255, 255, 255, 200), width=int(3 * s))
    draw.polygon(lower_wing_right, fill=(189, 0, 255, 220), outline=(255, 255, 255, 200), width=int(3 * s))

    # Inner Wing Accents - Glowing Core Patterns
    draw.polygon(inner_upper_left, fill=(10, 16, 26, 220), outline=(255, 255, 255, 180), width=int(2 * s))
    draw.polygon(inner_upper_right, fill=(10, 16, 26, 220), outline=(255, 255, 255, 180), width=int(2 * s))
    
    draw.polygon(inner_lower_left, fill=(10, 16, 26, 220), outline=(0, 240, 255, 200), width=int(2 * s))
    draw.polygon(inner_lower_right, fill=(10, 16, 26, 220), outline=(0, 240, 255, 200), width=int(2 * s))

    # Cyber Circuit Lines across wings
    # Upper left circuit veins
    draw.line([(cx - 30 * s, cy - 25 * s), (cx - 100 * s, cy - 80 * s), (cx - 180 * s, cy - 120 * s)], fill=(0, 240, 255, 255), width=int(3 * s))
    draw.line([(cx + 30 * s, cy - 25 * s), (cx + 100 * s, cy - 80 * s), (cx + 180 * s, cy - 120 * s)], fill=(0, 240, 255, 255), width=int(3 * s))
    
    draw.line([(cx - 30 * s, cy + 40 * s), (cx - 110 * s, cy + 100 * s), (cx - 130 * s, cy + 150 * s)], fill=(255, 176, 32, 255), width=int(3 * s))
    draw.line([(cx + 30 * s, cy + 40 * s), (cx + 110 * s, cy + 100 * s), (cx + 130 * s, cy + 150 * s)], fill=(255, 176, 32, 255), width=int(3 * s))

    # Butterfly Antennae with Neon Nodes
    # Left antenna
    draw.arc([cx - 90 * s, cy - 190 * s, cx + 10 * s, cy - 50 * s], start=180, end=290, fill=(0, 240, 255, 255), width=int(4 * s))
    draw.ellipse([cx - 86 * s, cy - 170 * s, cx - 74 * s, cy - 158 * s], fill=(255, 255, 255, 255), outline=(0, 240, 255, 255), width=int(2 * s))
    
    # Right antenna
    draw.arc([cx - 10 * s, cy - 190 * s, cx + 90 * s, cy - 50 * s], start=250, end=360, fill=(0, 240, 255, 255), width=int(4 * s))
    draw.ellipse([cx + 74 * s, cy - 170 * s, cx + 86 * s, cy - 158 * s], fill=(255, 255, 255, 255), outline=(0, 240, 255, 255), width=int(2 * s))

    # Central Cybernetic Body
    # Head
    draw.ellipse([cx - 14 * s, cy - 65 * s, cx + 14 * s, cy - 37 * s], fill=(255, 255, 255, 255), outline=(0, 240, 255, 255), width=int(2 * s))
    # Eyes
    draw.ellipse([cx - 10 * s, cy - 56 * s, cx - 4 * s, cy - 48 * s], fill=(0, 240, 255, 255))
    draw.ellipse([cx + 4 * s, cy - 56 * s, cx + 10 * s, cy - 48 * s], fill=(0, 240, 255, 255))

    # Thorax & Abdomen
    body_poly = [
        (cx - 12 * s, cy - 35 * s),
        (cx + 12 * s, cy - 35 * s),
        (cx + 16 * s, cy + 15 * s),
        (cx + 8 * s, cy + 110 * s),
        (cx, cy + 145 * s),
        (cx - 8 * s, cy + 110 * s),
        (cx - 16 * s, cy + 15 * s)
    ]
    draw.polygon(body_poly, fill=(15, 23, 42, 255), outline=(0, 240, 255, 255), width=int(3 * s))

    # Glowing segments along abdomen
    for seg_y in [-15, 15, 45, 75, 105]:
        draw.line([(cx - 10 * s, cy + seg_y * s), (cx + 10 * s, cy + seg_y * s)], fill=(0, 240, 255, 230), width=int(3 * s))
    
    # Core Energy Reactor at center
    draw.ellipse([cx - 8 * s, cy - 5 * s, cx + 8 * s, cy + 11 * s], fill=(255, 255, 255, 255), outline=(189, 0, 255, 255), width=int(2 * s))

    return img

def export_all_icons():
    master_icon = create_butterfly_image(512)
    
    # Save master high-res preview
    master_path = os.path.join(r"D:\Projects\BinaHub", "butterfly_icon_512.png")
    master_icon.save(master_path, "PNG")
    print(f"[Master Icon] Saved to {master_path}")

    # Standard Mipmap densities
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, dim in densities.items():
        folder_path = os.path.join(BASE_RES, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # 1. Standard square/rounded icon
        resized = master_icon.resize((dim, dim), Image.Resampling.LANCZOS)
        out_square = os.path.join(folder_path, "ic_launcher.png")
        resized.save(out_square, "PNG")

        # 2. Round icon (masked circle)
        mask = Image.new("L", (dim, dim), 0)
        mdraw = ImageDraw.Draw(mask)
        mdraw.ellipse((1, 1, dim - 1, dim - 1), fill=255)
        
        round_img = Image.new("RGBA", (dim, dim), (0, 0, 0, 0))
        round_img.paste(resized, (0, 0), mask=mask)
        out_round = os.path.join(folder_path, "ic_launcher_round.png")
        round_img.save(out_round, "PNG")

        print(f"[{folder}] Exported {dim}x{dim} ic_launcher.png and ic_launcher_round.png")

    # Also create a pure vector foreground for adaptive icon
    print("[Adaptive Vector] Writing ic_launcher_foreground.xml and ic_launcher_background.xml...")
    
    bg_xml = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#070A0E"
        android:pathData="M0,0h108v108h-108z" />
    <path
        android:fillColor="#0E1624"
        android:pathData="M14,14 L94,14 L94,94 L14,94 Z" />
    <path
        android:strokeColor="#1F2E47"
        android:strokeWidth="1"
        android:pathData="M24,24 L84,24 L84,84 L24,84 Z" />
</vector>
"""
    with open(os.path.join(BASE_RES, "drawable", "ic_launcher_background.xml"), "w", encoding="utf-8") as f:
        f.write(bg_xml)

    fg_xml = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <!-- Glow Backdrop -->
    <path
        android:fillColor="#3300F0FF"
        android:pathData="M54,34 C44,18 20,24 22,46 C24,62 46,68 54,80 C62,68 84,62 86,46 C88,24 64,18 54,34 Z" />
    <!-- Upper Left Wing -->
    <path
        android:fillColor="#00E5FF"
        android:strokeColor="#FFFFFF"
        android:strokeWidth="1.2"
        android:pathData="M53,48 C44,28 22,30 24,52 C26,64 45,68 53,74 Z" />
    <!-- Upper Right Wing -->
    <path
        android:fillColor="#00E5FF"
        android:strokeColor="#FFFFFF"
        android:strokeWidth="1.2"
        android:pathData="M55,48 C64,28 86,30 84,52 C82,64 63,68 55,74 Z" />
    <!-- Lower Left Wing -->
    <path
        android:fillColor="#BD00FF"
        android:strokeColor="#FFFFFF"
        android:strokeWidth="1.2"
        android:pathData="M53,62 C42,65 30,76 34,88 C38,94 48,90 53,82 Z" />
    <!-- Lower Right Wing -->
    <path
        android:fillColor="#BD00FF"
        android:strokeColor="#FFFFFF"
        android:strokeWidth="1.2"
        android:pathData="M55,62 C66,65 78,76 74,88 C70,94 60,90 55,82 Z" />
    <!-- Cyber Antennae -->
    <path
        android:strokeColor="#00F0FF"
        android:strokeWidth="1.5"
        android:pathData="M52,44 C48,34 40,32 38,34" />
    <path
        android:strokeColor="#00F0FF"
        android:strokeWidth="1.5"
        android:pathData="M56,44 C60,34 68,32 70,34" />
    <!-- Antenna Nodes -->
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M38,34 m-1.5,0 a1.5,1.5 0 1,0 3,0 a1.5,1.5 0 1,0 -3,0" />
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M70,34 m-1.5,0 a1.5,1.5 0 1,0 3,0 a1.5,1.5 0 1,0 -3,0" />
    <!-- Central Cybernetic Body -->
    <path
        android:fillColor="#0A0E17"
        android:strokeColor="#00F0FF"
        android:strokeWidth="1.5"
        android:pathData="M52,43 C52,41 56,41 56,43 L57,60 L54,82 L51,60 Z" />
    <!-- Core Reactor Dot -->
    <path
        android:fillColor="#00F0FF"
        android:pathData="M54,54 m-2,0 a2,2 0 1,0 4,0 a2,2 0 1,0 -4,0" />
</vector>
"""
    with open(os.path.join(BASE_RES, "drawable", "ic_launcher_foreground.xml"), "w", encoding="utf-8") as f:
        f.write(fg_xml)

    # Adaptive icon linking
    adaptive_xml = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
"""
    os.makedirs(os.path.join(BASE_RES, "mipmap-anydpi-v26"), exist_ok=True)
    with open(os.path.join(BASE_RES, "mipmap-anydpi-v26", "ic_launcher.xml"), "w", encoding="utf-8") as f:
        f.write(adaptive_xml)
    with open(os.path.join(BASE_RES, "mipmap-anydpi-v26", "ic_launcher_round.xml"), "w", encoding="utf-8") as f:
        f.write(adaptive_xml)

    print("[Success] All butterfly icons generated successfully across vectors and all mipmap densities!")

if __name__ == "__main__":
    export_all_icons()
