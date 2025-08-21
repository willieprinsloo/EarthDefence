#!/usr/bin/env python3

from PIL import Image, ImageDraw
import os

def create_launch_background(width, height):
    """Create a space-themed background"""
    img = Image.new('RGB', (width, height), color=(5, 5, 20))
    draw = ImageDraw.Draw(img)
    
    # Add some stars
    import random
    for _ in range(100):
        x = random.randint(0, width)
        y = random.randint(0, height)
        brightness = random.randint(100, 255)
        draw.point((x, y), fill=(brightness, brightness, brightness))
    
    return img

def create_launch_logo(size):
    """Create a hexagonal station core logo"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw a hexagon
    center_x = size // 2
    center_y = size // 2
    radius = size // 3
    
    # Calculate hexagon points
    import math
    points = []
    for i in range(6):
        angle = math.pi / 3 * i - math.pi / 6
        x = center_x + radius * math.cos(angle)
        y = center_y + radius * math.sin(angle)
        points.append((x, y))
    
    # Draw filled hexagon with cyan color
    draw.polygon(points, fill=(0, 204, 255, 200), outline=(0, 255, 255, 255))
    
    # Draw inner hexagon
    inner_radius = radius // 2
    inner_points = []
    for i in range(6):
        angle = math.pi / 3 * i - math.pi / 6
        x = center_x + inner_radius * math.cos(angle)
        y = center_y + inner_radius * math.sin(angle)
        inner_points.append((x, y))
    
    draw.polygon(inner_points, fill=(0, 255, 255, 255))
    
    return img

# Create directories if they don't exist
base_path = "/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets"
os.makedirs(f"{base_path}/LaunchBackground.imageset", exist_ok=True)
os.makedirs(f"{base_path}/LaunchLogo.imageset", exist_ok=True)

# Generate background images
bg_sizes = [
    (320, 568, "launch-bg@1x.png"),
    (750, 1334, "launch-bg@2x.png"),
    (1242, 2208, "launch-bg@3x.png")
]

for width, height, filename in bg_sizes:
    img = create_launch_background(width, height)
    img.save(f"{base_path}/LaunchBackground.imageset/{filename}")
    print(f"Created {filename}")

# Generate logo images
logo_sizes = [
    (200, "launch-logo@1x.png"),
    (400, "launch-logo@2x.png"),
    (600, "launch-logo@3x.png")
]

for size, filename in logo_sizes:
    img = create_launch_logo(size)
    img.save(f"{base_path}/LaunchLogo.imageset/{filename}")
    print(f"Created {filename}")

print("All launch images created successfully!")