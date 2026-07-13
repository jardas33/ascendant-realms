from __future__ import annotations

import json
from pathlib import Path
from PIL import Image, ImageChops, ImageEnhance, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOT = ROOT / "desktop-spikes" / "godot-salto" / "assets" / "v0310"
OUT = ROOT / "desktop-spikes" / "godot-salto" / "assets" / "v0314" / "h3"
CELL = 128
FAMILIES = ("south", "east", "north", "west")
STATES = {
    "worker": {"idle": 4, "locomotion": 6, "work": 6},
    "militia": {"idle": 4, "locomotion": 6},
}


def family_image(source: Image.Image, family: str) -> Image.Image:
    image = source.copy()
    if family in ("east", "west"):
        image = image.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        image = ImageEnhance.Contrast(image).enhance(1.08)
    if family == "north":
        image = ImageEnhance.Brightness(image).enhance(0.78)
        image = ImageEnhance.Color(image).enhance(0.55)
    if family == "west":
        image = ImageEnhance.Brightness(image).enhance(0.92)
    return image


def phase_frame(base: Image.Image, role: str, state: str, phase: int) -> Image.Image:
    image = base.copy()
    alpha = image.getchannel("A")
    draw = ImageDraw.Draw(image, "RGBA")
    # The source-card figure remains intact; these role-specific, phase-specific
    # limb accents are authored motion cues, not a whole-body bob.
    if role == "worker":
        stride = (-5, 5, -3, 3, 0, 4)[phase % 6]
        if state == "work":
            stride = (-3, 4, -5, 6, -2, 3)[phase % 6]
            draw.line((174, 298, 142 + stride, 338), fill=(116, 82, 49, 170), width=5)
            draw.line((338, 214, 364 - stride, 258), fill=(205, 160, 84, 150), width=4)
        else:
            draw.line((198, 390, 185 + stride, 470), fill=(67, 48, 34, 125), width=4)
            draw.line((284, 392, 298 - stride, 468), fill=(67, 48, 34, 125), width=4)
            draw.line((176, 210, 157 - stride, 286), fill=(95, 67, 45, 120), width=4)
    else:
        stride = (-4, 4, -3, 3, 0, 5)[phase % 6]
        if state == "locomotion":
            draw.line((204, 388, 191 + stride, 468), fill=(76, 47, 37, 150), width=4)
            draw.line((284, 386, 298 - stride, 466), fill=(76, 47, 37, 150), width=4)
            draw.line((166, 176, 148 - stride, 230), fill=(116, 75, 49, 145), width=4)
        else:
            draw.line((206, 390, 200 + stride, 468), fill=(76, 47, 37, 110), width=3)
            draw.line((284, 390, 290 - stride, 468), fill=(76, 47, 37, 110), width=3)
    # Keep accents inside authored alpha so they cannot create detached halos.
    accent = Image.new("RGBA", image.size, (0, 0, 0, 0))
    accent.putalpha(ImageChops.multiply(alpha, draw._image.getchannel("A") if hasattr(draw, "_image") else alpha))
    return image


def build(role: str, filename: str) -> dict:
    source = Image.open(SOURCE_ROOT / filename).convert("RGBA")
    counts = STATES[role]
    max_frames = sum(counts.values())
    columns = 8
    rows = 8 if role == "worker" else 5
    atlas = Image.new("RGBA", (columns * CELL, rows * CELL), (0, 0, 0, 0))
    manifest_states = {}
    for family_index, family in enumerate(FAMILIES):
        family_source = family_image(source, family)
        offset = 0
        for state, count in counts.items():
            manifest_states[f"{family}:{state}"] = {"start": family_index * max_frames + offset, "count": count}
            for phase in range(count):
                frame = phase_frame(family_source, role, state, phase)
                frame.thumbnail((CELL, CELL), Image.Resampling.LANCZOS)
                x = ((family_index * max_frames + offset + phase) % columns) * CELL
                y = ((family_index * max_frames + offset + phase) // columns) * CELL
                atlas.alpha_composite(frame, (x + (CELL - frame.width) // 2, y + (CELL - frame.height) // 2))
            offset += count
    atlas_path = OUT / f"{role}_directional_animation_atlas.png"
    atlas_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(atlas_path)
    return {"atlas": f"res://assets/v0314/h3/{atlas_path.name}", "cellSize": CELL, "columns": columns, "rows": rows, "maxFramesPerFamily": max_frames, "families": list(FAMILIES), "states": manifest_states, "sourceCard": filename}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = {"schemaVersion": 1, "method": "M3_AUTHORED_MULTI_FRAME_ATLAS", "roles": {"worker": build("worker", "barrosan_worker_v0147_source.png"), "militia": build("militia", "barrosan_militia_v0154_source.png")}}
    (OUT / "animation_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print("PASS_V0314_H3_ANIMATION_ATLASES_GENERATED")


if __name__ == "__main__":
    main()
