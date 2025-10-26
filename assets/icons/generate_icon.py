#!/usr/bin/env python3
"""
Generate app icon for Bible Meditation Notes app
Design: Modern cross with notebook elements
"""

from PIL import Image, ImageDraw

# Create 1024x1024 image
size = 1024
img = Image.new('RGB', (size, size), color='#1A237E')
draw = ImageDraw.Draw(img)

# Define colors
background_color = '#1A237E'  # Deep indigo blue
cross_color = '#FFC107'  # Golden amber
line_color = '#FFFFFF'  # White
bookmark_color = '#64B5F6'  # Light blue

# Draw notebook lines at bottom (subtle, with transparency)
line_overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
line_draw = ImageDraw.Draw(line_overlay)

line_y_positions = [650, 700, 750]
line_width = 3
for y in line_y_positions:
    line_draw.line([(200, y), (824, y)], fill=(255, 255, 255, 51), width=line_width)  # 20% opacity

# Convert main image to RGBA for blending
img = img.convert('RGBA')
img = Image.alpha_composite(img, line_overlay)

# Back to RGB for drawing cross
img = img.convert('RGB')
draw = ImageDraw.Draw(img)

# Draw cross with rounded corners (using rectangles)
# Vertical bar
vertical_x = 452
vertical_y = 250
vertical_w = 120
vertical_h = 500
draw.rounded_rectangle(
    [(vertical_x, vertical_y), (vertical_x + vertical_w, vertical_y + vertical_h)],
    radius=20,
    fill=cross_color
)

# Horizontal bar
horizontal_x = 312
horizontal_y = 390
horizontal_w = 400
horizontal_h = 120
draw.rounded_rectangle(
    [(horizontal_x, horizontal_y), (horizontal_x + horizontal_w, horizontal_y + horizontal_h)],
    radius=20,
    fill=cross_color
)

# Draw small bookmark accent (triangle) at top right
bookmark_overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
bookmark_draw = ImageDraw.Draw(bookmark_overlay)
bookmark_points = [(900, 100), (900, 250), (850, 200)]
bookmark_draw.polygon(bookmark_points, fill=(100, 181, 246, 153))  # 60% opacity

# Composite bookmark
img = img.convert('RGBA')
img = Image.alpha_composite(img, bookmark_overlay)

# Convert back to RGB and save
img = img.convert('RGB')
img.save('icon.png', 'PNG', quality=100, optimize=True)

print('✓ icon.png created successfully (1024x1024)')
print('  Design: Golden cross on deep blue background')
print('  Elements: Notebook lines + bookmark accent')
