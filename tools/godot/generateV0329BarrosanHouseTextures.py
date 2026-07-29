"""Generate v0.329's muted, macro-scale house materials locally and deterministically."""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path("desktop-spikes/godot-salto/assets/v0327/textures")
SIZE = 1024


def base(seed: int, color: tuple[int, int, int], spread: int) -> Image.Image:
    rng = random.Random(seed)
    image = Image.new("RGB", (SIZE, SIZE), color)
    pixels = image.load()
    for y in range(SIZE):
        for x in range(SIZE):
            broad = math.sin(x * 0.004 + seed) * 0.65 + math.sin(y * 0.006 - seed * 0.3) * 0.45
            local = rng.randrange(-spread, spread + 1) if (x * 13 + y * 17) % 71 == 0 else 0
            pixels[x, y] = tuple(max(0, min(255, int(channel + broad * spread + local))) for channel in color)
    return image


def granite() -> Image.Image:
    image = base(3291, (94, 91, 84), 6)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32911)
    for row in range(-1, SIZE // 150 + 2):
        y = row * 150 + rng.randrange(-20, 21)
        x = rng.randrange(-120, 40)
        while x < SIZE:
            width = rng.randrange(150, 280)
            height = rng.randrange(72, 124)
            shade = rng.choice([(82, 80, 75), (104, 100, 91), (112, 106, 95), (75, 74, 70)])
            polygon = [(x, y + rng.randrange(-10, 11)), (x + width, y + rng.randrange(-10, 11)), (x + width - 18, y + height), (x + 12, y + height + rng.randrange(-8, 9))]
            draw.polygon(polygon, fill=shade)
            draw.line((polygon[0], polygon[1]), fill=(57, 56, 53), width=2)
            draw.line((polygon[1], polygon[2]), fill=(67, 65, 60), width=2)
            x += width + rng.randrange(18, 42)
    for _ in range(90):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(18, 70), y + rng.randrange(-8, 12)), fill=rng.choice([(66, 63, 58), (129, 120, 103)]), width=1)
    return image


def foundation() -> Image.Image:
    image = base(3292, (50, 50, 47), 6)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32921)
    for row in range(-20, SIZE, 124):
        x = rng.randrange(-40, 30)
        while x < SIZE:
            width = rng.randrange(130, 240)
            height = rng.randrange(52, 92)
            draw.polygon([(x, row), (x + width, row + rng.randrange(-5, 6)), (x + width - 14, row + height), (x + 10, row + height + rng.randrange(-5, 6))], fill=rng.choice([(42, 43, 42), (62, 60, 55), (73, 68, 59)]))
            x += width + rng.randrange(16, 34)
    return image


def slate() -> Image.Image:
    image = base(3293, ( fifty := 56, 58, 57), 5)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32931)
    for row in range(0, SIZE + 80, 64):
        offset = 0 if (row // 64) % 2 == 0 else 42
        draw.line((0, row, SIZE, row + 2), fill=(34, 37, 36), width=3)
        for x in range(-offset, SIZE + 80, 124):
            draw.line((x, row + 2, x - 11, row + 64), fill=(81, 83, 78), width=2)
    for _ in range(70):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(10, 42), y + rng.randrange(-2, 3)), fill=(101, 98, 88), width=1)
    return image


def timber() -> Image.Image:
    image = base(3294, (83, 62, 44), 5)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32941)
    for x in range(8, SIZE, 42):
        points = [(x + int(math.sin(y * 0.028 + x) * 8), y) for y in range(0, SIZE, 56)]
        draw.line(points, fill=rng.choice([(46, 37, 30), (111, 77, 48), (70, 51, 37)]), width=rng.choice([1, 2]))
    return image


def muted_ground() -> Image.Image:
    image = base(3295, (91, 88, 70), 6)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32951)
    for _ in range(75):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        w, h = rng.randrange(26, 180), rng.randrange(8, 32)
        draw.ellipse((x, y, x + w, y + h), fill=rng.choice([(76, 78, 60), (108, 98, 73), (119, 104, 74), (67, 72, 57)]))
    return image


def warm_plaster() -> Image.Image:
    image = base(3297, (137, 126, 101), 4)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32971)
    for _ in range(42):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.ellipse((x, y, x + rng.randrange(80, 260), y + rng.randrange(40, 150)), fill=rng.choice([(146, 135, 110), (122, 113, 93), (159, 145, 116)]))
    return image


def iron() -> Image.Image:
    image = base(3296, (45, 45, 42), 4)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32961)
    for _ in range(140):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(5, 26), y + rng.randrange(-2, 3)), fill=rng.choice([(29, 30, 29), (81, 69, 53), (111, 79, 51)]), width=1)
    return image


def main() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    images = {
        "v0327_rough_local_granite.png": granite(),
        "v0327_dark_foundation_stone.png": foundation(),
        "v0327_weathered_slate.png": slate(),
        "v0327_aged_timber.png": timber(),
        "v0327_imperfect_limewash.png": muted_ground(),
        "v0329_muted_warm_plaster.png": warm_plaster(),
        "v0327_rough_iron.png": iron(),
    }
    for name, image in images.items():
        image.save(ROOT / name, format="PNG", optimize=True)
    print(f"PASS_V0329_TEXTURES_GENERATED {len(images)} {SIZE}x{SIZE}")


if __name__ == "__main__":
    main()
