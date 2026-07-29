"""Generate restrained, locally authored v0.328 house texture inputs."""

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
            broad = math.sin(x * 0.009 + seed) * 0.55 + math.sin(y * 0.013 - seed * 0.7) * 0.35
            local = rng.randrange(-spread, spread + 1) if (x * 7 + y * 11) % 37 == 0 else 0
            pixels[x, y] = tuple(max(0, min(255, int(channel + broad * spread + local))) for channel in color)
    return image


def granite() -> Image.Image:
    image = base(3281, (104, 99, 89), 10)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32811)
    # Large irregular families first, then restrained joint marks. This avoids
    # the v0.327 manufactured-speckle read at ordinary RTS distance.
    for row in range(-1, SIZE // 96 + 2):
        y = row * 96 + rng.randrange(-18, 19)
        x = rng.randrange(-80, 40)
        while x < SIZE:
            width = rng.randrange(82, 178)
            height = rng.randrange(46, 88)
            shade = rng.choice([(91, 87, 79), (116, 109, 96), (128, 119, 103), (82, 79, 73)])
            polygon = [(x, y + rng.randrange(-10, 10)), (x + width, y + rng.randrange(-8, 8)), (x + width - 12, y + height), (x + 8, y + height + rng.randrange(-8, 8))]
            draw.polygon(polygon, fill=shade)
            draw.line((polygon[0], polygon[1]), fill=(57, 55, 51), width=3)
            draw.line((polygon[1], polygon[2]), fill=(63, 60, 54), width=2)
            x += width + rng.randrange(10, 28)
    for _ in range(180):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(12, 55), y + rng.randrange(-8, 12)), fill=rng.choice([(69, 66, 60), (143, 134, 116)]), width=rng.choice([1, 2]))
    return image


def foundation() -> Image.Image:
    image = base(3282, (61, 59, 54), 8)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32821)
    for row in range(0, SIZE, 82):
        for x in range(rng.randrange(-30, 30), SIZE, rng.randrange(92, 142)):
            width, height = rng.randrange(80, 142), rng.randrange(42, 76)
            draw.polygon([(x, row), (x + width, row + rng.randrange(-5, 6)), (x + width - 12, row + height), (x + 8, row + height + rng.randrange(-5, 6))], fill=rng.choice([(48, 47, 44), (73, 69, 61), (86, 80, 69)]))
    return image


def slate() -> Image.Image:
    image = base(3283, (55, 58, 57), 6)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32831)
    for row in range(0, SIZE + 64, 54):
        offset = 0 if (row // 54) % 2 == 0 else 38
        draw.line((0, row, SIZE, row + 2), fill=(35, 38, 37), width=3)
        for x in range(-offset, SIZE + 80, 108):
            draw.line((x, row + 2, x - 9, row + 54), fill=(84, 85, 79), width=2)
    for _ in range(110):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(8, 32), y + rng.randrange(-2, 3)), fill=(100, 99, 90), width=1)
    return image


def timber() -> Image.Image:
    image = base(3284, (96, 70, 48), 7)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32841)
    for x in range(8, SIZE, 34):
        points = [(x + int(math.sin(y * 0.035 + x) * 9), y) for y in range(0, SIZE, 48)]
        draw.line(points, fill=rng.choice([(55, 42, 32), (127, 88, 55), (78, 54, 38)]), width=rng.choice([1, 2]))
    return image


def limewash() -> Image.Image:
    image = base(3285, (158, 153, 137), 5)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32851)
    for _ in range(120):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.rectangle((x, y, x + rng.randrange(10, 90), y + rng.randrange(3, 16)), fill=rng.choice([(139, 135, 123), (176, 170, 149), (116, 113, 103)]))
    return image


def iron() -> Image.Image:
    image = base(3286, (42, 44, 42), 4)
    draw = ImageDraw.Draw(image)
    rng = random.Random(32861)
    for _ in range(260):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(3, 18), y + rng.randrange(-2, 3)), fill=rng.choice([(26, 28, 27), (75, 70, 58), (104, 86, 61)]), width=1)
    return image


def main() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    images = {
        "v0327_rough_local_granite.png": granite(),
        "v0327_dark_foundation_stone.png": foundation(),
        "v0327_weathered_slate.png": slate(),
        "v0327_aged_timber.png": timber(),
        "v0327_imperfect_limewash.png": limewash(),
        "v0327_rough_iron.png": iron(),
    }
    for name, image in images.items():
        image.save(ROOT / name, format="PNG", optimize=True)
    print(f"PASS_V0328_TEXTURES_GENERATED {len(images)} {SIZE}x{SIZE}")


if __name__ == "__main__":
    main()
