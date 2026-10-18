# Plan 354: a tileable grey leaf-clump texture (overlapping lit leaves with
# dark gaps) for the low-poly heather and moonbell clumps. Multiply by color.
import math, random, sys
from PIL import Image, ImageDraw, ImageFilter
N = 512
random.seed(354)
img = Image.new('L', (N, N), 62)
d = ImageDraw.Draw(img)
for i in range(1500):
    cx, cy = random.uniform(0, N), random.uniform(0, N)
    ln, wd = random.uniform(22, 40), random.uniform(9, 15)
    a = random.uniform(0, math.tau)
    lit = random.uniform(0.5, 0.92)
    # Each leaf: a pointed ellipse, lit on one side, with a darker midrib.
    pts = []
    for k in range(16):
        t = k / 16 * math.tau
        r = 1.0 - 0.35 * abs(math.cos(t)) ** 6
        x, y = math.cos(t) * ln * 0.5, math.sin(t) * wd * 0.5 * r
        pts.append((x, y))
    for ox in (-N, 0, N):
        for oy in (-N, 0, N):
            P = [(cx + ox + x * math.cos(a) - y * math.sin(a), cy + oy + x * math.sin(a) + y * math.cos(a)) for x, y in pts]
            if all(px < -50 or px > N + 50 for px, _ in P) or all(py < -50 or py > N + 50 for _, py in P):
                continue
            d.polygon(P, fill=int(255 * lit), outline=int(255 * lit * 0.55))
            d.line([(cx + ox - math.cos(a) * ln * 0.4, cy + oy - math.sin(a) * ln * 0.4), (cx + ox + math.cos(a) * ln * 0.4, cy + oy + math.sin(a) * ln * 0.4)], fill=int(255 * lit * 0.72), width=1)
img = img.filter(ImageFilter.GaussianBlur(0.6))
img.convert('RGB').save(sys.argv[1])
