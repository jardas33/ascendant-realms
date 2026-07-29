from __future__ import annotations

import random
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "desktop-spikes" / "godot-salto" / "assets" / "v0326" / "textures"
SIZE = 512


def noise_color(base: tuple[int, int, int], seed: int, amplitude: int = 14) -> Image.Image:
    rng = random.Random(seed)
    image = Image.new("RGB", (SIZE, SIZE))
    pixels = image.load()
    for y in range(SIZE):
        for x in range(SIZE):
            wave = int(5 * (1 + __import__("math").sin(x * 0.07 + y * 0.021)))
            pixels[x, y] = tuple(max(0, min(255, c + rng.randint(-amplitude, amplitude) + wave)) for c in base)
    return image


def save_grass() -> None:
    image = noise_color((82, 103, 58), 32601, 11)
    draw = ImageDraw.Draw(image, "RGBA")
    rng = random.Random(32602)
    for _ in range(2600):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randint(-2, 2), y - rng.randint(2, 8)), fill=(35, 57, 30, 80), width=1)
    image.save(OUT / "v0326_grass_breakup.png")


def save_earth() -> None:
    image = noise_color((112, 77, 48), 32603, 15)
    draw = ImageDraw.Draw(image, "RGBA")
    rng = random.Random(32604)
    for _ in range(480):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        draw.line((x, y, x + rng.randint(5, 28), y + rng.randint(-3, 3)), fill=(58, 39, 28, 75), width=rng.choice((1, 1, 2)))
    image.save(OUT / "v0326_earth_path.png")


def save_stone() -> None:
    image = noise_color((105, 108, 99), 32605, 16)
    draw = ImageDraw.Draw(image, "RGBA")
    rng = random.Random(32606)
    for _ in range(100):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        radius = rng.randint(8, 30)
        draw.polygon([(x - radius, y), (x - radius // 2, y - radius // 2), (x + radius, y - radius // 3), (x + radius // 2, y + radius // 2)], fill=(57, 62, 59, 80))
        draw.line((x - radius // 2, y, x + radius // 2, y - radius // 3), fill=(211, 205, 181, 55), width=2)
    image.save(OUT / "v0326_stone_granite.png")


def save_timber() -> None:
    image = noise_color((93, 55, 33), 32607, 13)
    draw = ImageDraw.Draw(image, "RGBA")
    rng = random.Random(32608)
    for y in range(0, SIZE, 54):
        draw.line((0, y, SIZE, y + rng.randint(-4, 4)), fill=(43, 28, 23, 150), width=4)
        for _ in range(8):
            x = rng.randrange(SIZE)
            y0 = y + rng.randint(8, 28)
            draw.ellipse((x, y0, x + rng.randint(10, 24), y0 + rng.randint(8, 18)), outline=(184, 117, 61, 80), width=2)
    image.save(OUT / "v0326_weathered_timber.png")


def save_roof() -> None:
    image = noise_color((62, 58, 55), 32609, 10)
    draw = ImageDraw.Draw(image, "RGBA")
    for y in range(-24, SIZE + 40, 34):
        offset = 22 if (y // 34) % 2 else 0
        for x in range(-40 + offset, SIZE + 40, 48):
            draw.polygon([(x, y), (x + 43, y), (x + 35, y + 24), (x + 7, y + 24)], fill=(39, 41, 40, 125), outline=(150, 143, 124, 70))
    image.save(OUT / "v0326_weathered_slate.png")


def save_water() -> None:
    image = noise_color((35, 83, 86), 32611, 9)
    draw = ImageDraw.Draw(image, "RGBA")
    for y in range(20, SIZE, 38):
        draw.arc((-80, y - 12, SIZE + 80, y + 22), 5, 175, fill=(153, 190, 169, 62), width=3)
        draw.arc((40, y + 5, SIZE + 120, y + 35), 190, 350, fill=(16, 49, 59, 90), width=2)
    image.save(OUT / "v0326_recessed_water.png")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    save_grass()
    save_earth()
    save_stone()
    save_timber()
    save_roof()
    save_water()
    print(f"PASS_V0326_TEXTURES_GENERATED {OUT}")


if __name__ == "__main__":
    main()
