"""Generate deterministic, locally authored PBR texture inputs for v0.327."""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path("desktop-spikes/godot-salto/assets/v0327/textures")
SIZE = 1024


def noise_field(seed: int, base: tuple[int, int, int], spread: int) -> Image.Image:
    rng = random.Random(seed)
    image = Image.new("RGB", (SIZE, SIZE), base)
    pixels = image.load()
    for y in range(SIZE):
        for x in range(SIZE):
            smooth = math.sin(x * 0.018 + seed) * 0.42 + math.sin(y * 0.023 - seed) * 0.35
            fine = rng.randrange(-spread, spread + 1) if (x + y * 3) % 11 == 0 else 0
            pixels[x, y] = tuple(max(0, min(255, int(channel + smooth * spread + fine))) for channel in base)
    return image


def granite() -> Image.Image:
    image = noise_field(32, (112, 105, 94), 15)
    draw = ImageDraw.Draw(image)
    rng = random.Random(3301)
    for _ in range(950):
        x = rng.randrange(SIZE)
        y = rng.randrange(SIZE)
        radius = rng.randrange(1, 8)
        shade = rng.choice([(74, 70, 64), (145, 138, 122), (91, 86, 78)])
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=shade)
    for _ in range(70):
        x = rng.randrange(SIZE)
        y = rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(-40, 41), y + rng.randrange(8, 42)), fill=(62, 59, 55), width=2)
    return image


def foundation() -> Image.Image:
    image = noise_field(61, (69, 66, 59), 11)
    draw = ImageDraw.Draw(image)
    rng = random.Random(3302)
    for _ in range(380):
        x = rng.randrange(SIZE)
        y = rng.randrange(SIZE)
        draw.rectangle((x, y, x + rng.randrange(4, 20), y + rng.randrange(3, 12)), fill=rng.choice([(53, 51, 47), (87, 81, 70), (103, 95, 81)]))
    return image


def slate() -> Image.Image:
    image = noise_field(91, (46, 48, 46), 8)
    draw = ImageDraw.Draw(image)
    rng = random.Random(3303)
    for row in range(0, SIZE, 48):
        offset = 0 if (row // 48) % 2 == 0 else 28
        draw.line((0, row, SIZE, row + 3), fill=(25, 27, 27), width=4)
        for x in range(-offset, SIZE, 96):
            draw.line((x, row, x - 10, row + 48), fill=(72, 72, 67), width=2)
    for _ in range(160):
        x = rng.randrange(SIZE)
        y = rng.randrange(SIZE)
        draw.line((x, y, x + rng.randrange(8, 34), y + rng.randrange(-3, 4)), fill=(82, 81, 74), width=1)
    return image


def timber() -> Image.Image:
    image = noise_field(121, (92, 65, 43), 10)
    draw = ImageDraw.Draw(image)
    rng = random.Random(3304)
    for x in range(12, SIZE, 24):
        points = []
        for y in range(0, SIZE, 64):
            points.append((x + int(math.sin(y * 0.04 + x) * 7), y))
        draw.line(points, fill=rng.choice([(51, 39, 29), (124, 83, 51), (72, 49, 34)]), width=rng.choice([1, 2, 3]))
    return image


def limewash() -> Image.Image:
    image = noise_field(151, (171, 163, 143), 8)
    draw = ImageDraw.Draw(image)
    rng = random.Random(3305)
    for _ in range(190):
        x = rng.randrange(SIZE)
        y = rng.randrange(SIZE)
        w = rng.randrange(6, 80)
        h = rng.randrange(3, 20)
        draw.rectangle((x, y, x + w, y + h), fill=rng.choice([(145, 137, 120), (190, 181, 157), (122, 116, 103)]))
    return image


def iron() -> Image.Image:
    image = noise_field(181, (38, 40, 38), 6)
    draw = ImageDraw.Draw(image)
    rng = random.Random(3306)
    for _ in range(500):
        x = rng.randrange(SIZE)
        y = rng.randrange(SIZE)
        draw.point((x, y), fill=rng.choice([(19, 21, 21), (67, 66, 59), (93, 80, 58)]))
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
    print(f"PASS_V0327_TEXTURES_GENERATED {len(images)} {SIZE}x{SIZE}")


if __name__ == "__main__":
    main()
