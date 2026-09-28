from PIL import Image, ImageDraw
import math

size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

corner = 220

# Create gradient background (deep purple to magenta-pink)
bg = Image.new('RGBA', (size, size))
bg_draw = ImageDraw.Draw(bg)
for y in range(size):
    t = y / size
    r = int(107 + (236 - 107) * t)
    g = int(70 + (72 - 70) * t)
    b = int(193 + (153 - 193) * t)
    bg_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

# Mask for rounded corners
mask = Image.new('L', (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.rounded_rectangle((0, 0, size, size), radius=corner, fill=255)
img.paste(bg, (0, 0), mask)

cx, cy = size // 2, size // 2 - 10
white = (255, 255, 255, 255)
star = (255, 220, 120, 255)

# Hanger hook - simple curved hook
hook_points = []
for i in range(31):
    angle = math.pi * 0.85 - i * (math.pi * 0.7 / 30)
    hx = cx + 36 * math.cos(angle)
    hy = cy - 210 + 60 * math.sin(angle)
    hook_points.append((hx, hy))
for a, b in zip(hook_points[:-1], hook_points[1:]):
    draw.line([a, b], fill=white, width=26)

# Filled hanger body (triangle with rounded base)
left = (cx - 260, cy + 130)
right = (cx + 260, cy + 130)
top = (cx, cy - 60)
# Outline first to form shape
draw.line([left, top, right], fill=white, width=32, joint='curve')
# Fill triangular body
body_polygon = [left, top, right, (cx, cy + 230)]
draw.polygon(body_polygon, fill=(255, 255, 255, 255))
# Redraw outline for crisp edges
draw.line([left, top, right], fill=white, width=32, joint='curve')
# Bottom bar
draw.line([(cx - 270, cy + 130), (cx + 270, cy + 130)], fill=white, width=36)

# Sparkle / AI accents
def draw_sparkle(draw, x, y, r, fill):
    points = []
    for i in range(8):
        angle = math.pi / 2 + i * math.pi / 4
        dist = r if i % 2 == 0 else r * 0.45
        points.append((x + dist * math.cos(angle), y + dist * math.sin(angle)))
    draw.polygon(points, fill=fill)

draw_sparkle(draw, cx + 200, cy - 140, 65, star)
draw_sparkle(draw, cx - 190, cy + 20, 42, (255, 255, 255, 230))

# Small AI/orbit dots
draw.ellipse([cx + 250, cy + 50, cx + 285, cy + 85], fill=(255, 255, 255, 210))
draw.ellipse([cx - 270, cy - 90, cx - 240, cy - 60], fill=(255, 255, 255, 190))

img.save('assets/images/icon.png')
print('Icon saved to assets/images/icon.png')
