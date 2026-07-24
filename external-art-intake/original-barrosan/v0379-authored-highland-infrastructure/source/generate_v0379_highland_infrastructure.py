from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Iterable

import numpy as np
import trimesh
from scipy.ndimage import gaussian_filter

SEED = 379
RNG = np.random.default_rng(SEED)

ROOT = Path(__file__).resolve().parents[1]
EXPORT_PATH = ROOT / "exports" / "barrosan_highland_infrastructure_v0379.glb"
MANIFEST_PATH = ROOT / "documentation" / "ASSET_MANIFEST.json"
PREVIEW_DIR = ROOT / "previews"


def smoothstep(edge0: float, edge1: float, x: np.ndarray | float) -> np.ndarray:
    t = np.clip((np.asarray(x) - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def river_center(z: np.ndarray | float) -> np.ndarray:
    z = np.asarray(z)
    return 3.2 * np.sin(z / 11.5) + 0.08 * z


def river_half_width(z: np.ndarray | float) -> np.ndarray:
    z = np.asarray(z)
    return 2.15 + 0.35 * np.sin(z / 8.0 + 0.7) + 0.18 * np.sin(z / 3.7)


def road_center(x: np.ndarray | float) -> np.ndarray:
    x = np.asarray(x)
    return 1.5 * np.sin(x / 11.0) - 0.018 * x


def road_half_width(x: np.ndarray | float) -> np.ndarray:
    x = np.asarray(x)
    return 1.7 + 0.25 * np.sin(x / 7.5 + 0.4)


def color_mix(a: np.ndarray, b: np.ndarray, t: np.ndarray) -> np.ndarray:
    return a * (1.0 - t[..., None]) + b * t[..., None]


def make_terrain(nx: int = 161, nz: int = 121) -> trimesh.Trimesh:
    xs = np.linspace(-44.0, 44.0, nx)
    zs = np.linspace(-33.0, 33.0, nz)
    X, Z = np.meshgrid(xs, zs)

    raw = RNG.normal(size=(nz, nx))
    noise = gaussian_filter(raw, sigma=8.0)
    noise = (noise - noise.min()) / (noise.max() - noise.min()) - 0.5

    micro_raw = RNG.normal(size=(nz, nx))
    micro = gaussian_filter(micro_raw, sigma=2.3)
    micro = (micro - micro.min()) / (micro.max() - micro.min()) - 0.5

    base = (
        0.55
        + 0.42 * np.sin((X + 7.0) / 17.0)
        + 0.28 * np.cos((Z - 3.0) / 13.0)
        + 0.48 * noise
        + 0.10 * micro
    )

    # Highland shelves and natural rises.
    base += 0.85 * np.exp(-((X + 23.0) ** 2 / 210.0 + (Z - 17.0) ** 2 / 150.0))
    base += 0.70 * np.exp(-((X - 25.0) ** 2 / 260.0 + (Z + 18.0) ** 2 / 180.0))
    base += 0.38 * np.exp(-((X - 7.0) ** 2 / 190.0 + (Z - 22.0) ** 2 / 130.0))

    rc = river_center(Z)
    rw = river_half_width(Z)
    dr = np.abs(X - rc)
    outer = rw + 4.8
    valley_t = 1.0 - smoothstep(rw, outer, dr)
    inner_t = 1.0 - smoothstep(0.0, rw, dr)
    Y = base - 1.45 * valley_t - 0.35 * inner_t

    # Road is shallowly worn into terrain, not a floating ribbon.
    rdc = road_center(X)
    road_w = road_half_width(X)
    d_road = np.abs(Z - rdc)
    road_core = 1.0 - smoothstep(road_w * 0.78, road_w, d_road)
    road_feather = 1.0 - smoothstep(road_w, road_w + 1.55, d_road)
    road_grade = 0.49 + 0.10 * np.sin(X / 16.0) + 0.03 * np.cos(X / 5.5)
    Y = Y * (1.0 - 0.72 * road_feather) + road_grade * (0.72 * road_feather)
    Y -= 0.07 * road_core

    # Stabilized bridge landings while retaining bank depth.
    near_crossing = np.exp(-((X / 6.6) ** 4 + ((Z - road_center(X)) / 3.3) ** 4))
    landing_target = 0.50 + 0.04 * np.sin(X / 5.0)
    bank_side = smoothstep(rw - 0.2, rw + 1.5, dr)
    landing_blend = near_crossing * bank_side
    Y = Y * (1.0 - landing_blend) + landing_target * landing_blend

    # Add gentle embedded wheel ruts in road core.
    for offset in (-0.62, 0.62):
        rut = np.exp(-((Z - (rdc + offset)) ** 2) / 0.035) * road_core
        Y -= 0.025 * rut

    vertices = np.column_stack([X.ravel(), Y.ravel(), Z.ravel()])
    faces = []
    for iz in range(nz - 1):
        row = iz * nx
        next_row = (iz + 1) * nx
        for ix in range(nx - 1):
            a, b = row + ix, row + ix + 1
            c, d = next_row + ix, next_row + ix + 1
            if (ix + iz) % 2:
                faces.extend([[a, c, b], [b, c, d]])
            else:
                faces.extend([[a, c, d], [a, d, b]])

    # Smooth natural vertex palette.
    grass_low = np.array([94, 117, 70], dtype=float)
    grass_high = np.array([137, 151, 91], dtype=float)
    grass_dry = np.array([154, 145, 88], dtype=float)
    wet = np.array([69, 82, 63], dtype=float)
    mud = np.array([92, 72, 48], dtype=float)
    dirt = np.array([126, 84, 49], dtype=float)
    dirt_light = np.array([161, 111, 63], dtype=float)
    rock = np.array([111, 109, 94], dtype=float)

    elevation_n = np.clip((Y - np.percentile(Y, 10)) / (np.percentile(Y, 90) - np.percentile(Y, 10)), 0, 1)
    colors = color_mix(grass_low, grass_high, elevation_n)
    dry_patch = np.clip(0.48 + 1.2 * noise + 0.20 * np.sin(X / 6.0), 0, 1)
    colors = color_mix(colors, grass_dry, 0.26 * dry_patch)

    wet_factor = np.clip((outer - dr) / 4.8, 0, 1) * (1.0 - inner_t * 0.55)
    colors = color_mix(colors, wet, 0.58 * wet_factor)
    bank_mud = np.clip((rw + 1.4 - dr) / 1.8, 0, 1) * (1.0 - inner_t)
    colors = color_mix(colors, mud, 0.64 * bank_mud)

    road_color_t = np.clip(road_feather * 0.92 + road_core * 0.25, 0, 1)
    road_base = color_mix(dirt_light, dirt, np.clip(0.48 + 0.55 * np.sin(X / 8.0), 0, 1))
    colors = color_mix(colors, road_base, road_color_t)

    # Granite flecks/outcrops on steeper, higher areas.
    gy, gx = np.gradient(Y)
    slope = np.sqrt(gx * gx + gy * gy)
    rock_factor = np.clip((slope - 0.10) / 0.25, 0, 1) * np.clip((noise + 0.28) * 1.7, 0, 1)
    colors = color_mix(colors, rock, 0.32 * rock_factor)

    shade = np.clip(0.96 + 0.12 * micro, 0.86, 1.08)
    colors *= shade[..., None]
    alpha = np.full((*colors.shape[:2], 1), 255.0)
    rgba = np.concatenate([np.clip(colors, 0, 255), alpha], axis=2).astype(np.uint8).reshape(-1, 4)

    mesh = trimesh.Trimesh(vertices=vertices, faces=np.asarray(faces), vertex_colors=rgba, process=False)
    mesh.metadata["name"] = "Terrain_Highland_Continuous"
    return mesh


def make_water(samples: int = 180) -> trimesh.Trimesh:
    zs = np.linspace(-36.0, 36.0, samples)
    centers = river_center(zs)
    widths = river_half_width(zs) * 0.98
    verts = []
    cols = []
    for i, (z, c, w) in enumerate(zip(zs, centers, widths)):
        y = -0.54 + 0.025 * math.sin(z / 3.2)
        for side in (-1.0, 1.0):
            verts.append([c + side * w, y, z])
            blue = np.array([50, 103, 105], dtype=float)
            blue += np.array([4, 7, 7]) * math.sin(i / 11.0)
            cols.append([*np.clip(blue, 0, 255).astype(np.uint8), 255])
    faces = []
    for i in range(samples - 1):
        a, b, c, d = 2 * i, 2 * i + 1, 2 * (i + 1), 2 * (i + 1) + 1
        faces.extend([[a, c, b], [b, c, d]])
    mesh = trimesh.Trimesh(vertices=np.asarray(verts), faces=np.asarray(faces), vertex_colors=np.asarray(cols), process=False)
    mesh.metadata["name"] = "Water_Recessed_River"
    return mesh


def box(name: str, extents: Iterable[float], center: Iterable[float], color: Iterable[int]) -> trimesh.Trimesh:
    mesh = trimesh.creation.box(extents=np.asarray(extents, dtype=float))
    mesh.apply_translation(np.asarray(center, dtype=float))
    mesh.visual.face_colors = np.tile(np.asarray([*color, 255], dtype=np.uint8), (len(mesh.faces), 1))
    mesh.metadata["name"] = name
    return mesh


def cylinder(name: str, radius: float, height: float, center: Iterable[float], color: Iterable[int], sections: int = 8) -> trimesh.Trimesh:
    mesh = trimesh.creation.cylinder(radius=radius, height=height, sections=sections)
    # trimesh cylinders are along Z; rotate to Y-up.
    mesh.apply_transform(trimesh.transformations.rotation_matrix(math.pi / 2, [1, 0, 0]))
    mesh.apply_translation(np.asarray(center, dtype=float))
    mesh.visual.face_colors = np.tile(np.asarray([*color, 255], dtype=np.uint8), (len(mesh.faces), 1))
    mesh.metadata["name"] = name
    return mesh


def create_bridge() -> list[trimesh.Trimesh]:
    pieces: list[trimesh.Trimesh] = []
    deck_y = 0.73
    bridge_length = 9.6
    bridge_width = 3.65
    wood_a = (127, 78, 40)
    wood_b = (151, 94, 47)
    wood_dark = (75, 48, 31)
    stone = (103, 102, 91)
    stone_dark = (78, 79, 72)

    # Granite abutments and under-deck beams.
    for side in (-1, 1):
        x = side * 5.25
        pieces.append(box(f"Bridge_Abutment_{side:+d}", (1.25, 1.35, 4.65), (x, 0.05, 0.0), stone))
        pieces.append(box(f"Bridge_Footing_{side:+d}", (1.55, 0.28, 5.0), (x, -0.62, 0.0), stone_dark))
    for z in (-1.28, 1.28):
        pieces.append(box(f"Bridge_Underbeam_{z:+.2f}", (bridge_length, 0.30, 0.28), (0.0, deck_y - 0.37, z), wood_dark))
    for x in (-2.5, 0.0, 2.5):
        pieces.append(box(f"Bridge_Crossbeam_{x:+.2f}", (0.28, 0.28, bridge_width + 0.4), (x, deck_y - 0.29, 0.0), wood_dark))

    # Individual planks with restrained variation.
    plank_count = 18
    plank_len = bridge_length / plank_count
    for i in range(plank_count):
        x = -bridge_length / 2 + plank_len * (i + 0.5)
        c = wood_a if i % 3 else wood_b
        pieces.append(box(f"Bridge_Deck_Plank_{i:02d}", (plank_len * 0.94, 0.18, bridge_width), (x, deck_y, 0.0), c))

    # Posts and two clean rail courses on each side.
    post_xs = np.linspace(-4.45, 4.45, 7)
    for side in (-1, 1):
        z = side * (bridge_width / 2 - 0.16)
        for i, x in enumerate(post_xs):
            pieces.append(cylinder(f"Bridge_Post_{side:+d}_{i:02d}", 0.095, 1.45, (x, deck_y + 0.72, z), wood_dark, sections=8))
        for h, suffix in ((0.62, "Low"), (1.18, "High")):
            pieces.append(box(f"Bridge_Rail_{side:+d}_{suffix}", (8.95, 0.12, 0.12), (0.0, deck_y + h, z), wood_dark))

    # Low edge course makes the crossing read as one continuous object.
    for side in (-1, 1):
        z = side * (bridge_width / 2 - 0.04)
        pieces.append(box(f"Bridge_EdgeCourse_{side:+d}", (bridge_length, 0.14, 0.15), (0.0, deck_y + 0.14, z), wood_dark))
    return pieces


def rock_mesh(name: str, center: tuple[float, float, float], scale: tuple[float, float, float], color: tuple[int, int, int]) -> trimesh.Trimesh:
    mesh = trimesh.creation.icosphere(subdivisions=1, radius=1.0)
    mesh.apply_scale(scale)
    mesh.apply_translation(center)
    mesh.visual.face_colors = np.tile(np.asarray([*color, 255], dtype=np.uint8), (len(mesh.faces), 1))
    mesh.metadata["name"] = name
    return mesh


def terrain_height_approx(x: float, z: float) -> float:
    # Approximation sufficient for dressing placement.
    base = 0.55 + 0.42 * math.sin((x + 7.0) / 17.0) + 0.28 * math.cos((z - 3.0) / 13.0)
    dr = abs(x - float(river_center(z)))
    rw = float(river_half_width(z))
    if dr < rw + 4.8:
        t = 1.0 - float(smoothstep(rw, rw + 4.8, dr))
        base -= 1.45 * t
    d_road = abs(z - float(road_center(x)))
    if d_road < float(road_half_width(x)) + 1.2:
        base = 0.49 + 0.10 * math.sin(x / 16.0)
    return base


def create_dressing() -> list[trimesh.Trimesh]:
    parts: list[trimesh.Trimesh] = []
    granite = [(116, 113, 98), (94, 96, 88), (137, 128, 105)]
    placements: list[tuple[float, float]] = []

    # Bank clusters and highland scatter, kept away from road core and bridge.
    for z in np.linspace(-29, 29, 16):
        c = float(river_center(z))
        w = float(river_half_width(z))
        for side in (-1, 1):
            if RNG.random() < 0.84:
                x = c + side * (w + RNG.uniform(1.0, 2.7))
                if abs(z - float(road_center(x))) < 3.0 or (abs(x) < 7 and abs(z) < 5):
                    continue
                placements.append((x, z))
    for _ in range(28):
        x = RNG.uniform(-39, 39)
        z = RNG.uniform(-29, 29)
        if abs(x - float(river_center(z))) < float(river_half_width(z)) + 4.0:
            continue
        if abs(z - float(road_center(x))) < float(road_half_width(x)) + 2.3:
            continue
        placements.append((x, z))

    for i, (x, z) in enumerate(placements):
        y = terrain_height_approx(x, z) + 0.22
        sx, sy, sz = RNG.uniform(0.35, 0.95), RNG.uniform(0.28, 0.75), RNG.uniform(0.35, 1.0)
        parts.append(rock_mesh(f"Rock_{i:03d}", (x, y, z), (sx, sy, sz), granite[i % len(granite)]))

    # Reeds and grasses concentrated near wet banks.
    reed_index = 0
    for z in np.linspace(-30, 30, 22):
        if RNG.random() < 0.25:
            continue
        c = float(river_center(z))
        w = float(river_half_width(z))
        side = -1 if RNG.random() < 0.5 else 1
        x = c + side * (w + RNG.uniform(0.3, 1.0))
        if abs(x) < 7 and abs(z) < 5:
            continue
        y = terrain_height_approx(x, z)
        for j in range(RNG.integers(3, 6)):
            dx = RNG.uniform(-0.22, 0.22)
            dz = RNG.uniform(-0.22, 0.22)
            h = RNG.uniform(0.45, 0.9)
            parts.append(box(f"Reed_{reed_index:03d}_{j}", (0.035, h, 0.035), (x + dx, y + h / 2, z + dz), (54, 76, 43)))
        reed_index += 1

    # Sparse highland shrubs with readable clumps.
    shrub_centers = [(-28, 19), (-24, -18), (27, 19), (31, -16), (-13, 26), (17, -25)]
    for i, (x, z) in enumerate(shrub_centers):
        y = terrain_height_approx(x, z)
        for j in range(5):
            angle = 2 * math.pi * j / 5 + RNG.uniform(-0.2, 0.2)
            r = RNG.uniform(0.2, 0.7)
            parts.append(rock_mesh(f"Shrub_{i}_{j}", (x + math.cos(angle) * r, y + 0.35, z + math.sin(angle) * r), (0.45, 0.45, 0.45), (75, 101, 55)))
    return parts


def create_scene() -> trimesh.Scene:
    scene = trimesh.Scene()
    scene.add_geometry(make_terrain(), node_name="Terrain_Highland_Continuous")
    scene.add_geometry(make_water(), node_name="Water_Recessed_River")
    for mesh in create_bridge():
        scene.add_geometry(mesh, node_name=mesh.metadata.get("name"))
    for mesh in create_dressing():
        scene.add_geometry(mesh, node_name=mesh.metadata.get("name"))
    scene.metadata["asset"] = {
        "name": "Ascendant Realms v0.379 Authored Highland Infrastructure",
        "units": "metres",
        "up_axis": "Y",
        "seed": SEED,
        "scope": ["terrain", "embedded-road", "recessed-river", "riverbanks", "bridge", "rocks", "reeds", "shrubs"],
    }
    return scene


def write_previews(scene: trimesh.Scene) -> None:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import Rectangle

    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    for old in PREVIEW_DIR.glob("*.png"):
        old.unlink()

    terrain = list(scene.geometry.values())[0]
    nx, nz = 161, 121
    verts = terrain.vertices.reshape(nz, nx, 3)
    colors = terrain.visual.vertex_colors[:, :3].reshape(nz, nx, 3) / 255.0
    xs = verts[0, :, 0]
    zs = verts[:, 0, 2]

    # 1. Top-down schematic using the exact terrain vertex colours.
    fig, ax = plt.subplots(figsize=(13.5, 8.5), dpi=150)
    ax.imshow(colors, origin="lower", extent=[xs.min(), xs.max(), zs.min(), zs.max()], interpolation="bilinear")
    zline = np.linspace(zs.min(), zs.max(), 500)
    c = river_center(zline)
    w = river_half_width(zline)
    ax.fill_betweenx(zline, c - w, c + w, color=(0.20, 0.42, 0.44), alpha=0.92)
    xline = np.linspace(xs.min(), xs.max(), 500)
    rc = road_center(xline)
    rw = road_half_width(xline)
    ax.fill_between(xline, rc - rw, rc + rw, color=(0.47, 0.28, 0.14), alpha=0.50)
    ax.add_patch(Rectangle((-4.8, -1.82), 9.6, 3.64, facecolor=(0.49, 0.29, 0.14), edgecolor=(0.22, 0.14, 0.09), linewidth=2.0))
    ax.add_patch(Rectangle((-5.85, -2.3), 1.25, 4.6, facecolor=(0.42, 0.42, 0.38), edgecolor="none"))
    ax.add_patch(Rectangle((4.6, -2.3), 1.25, 4.6, facecolor=(0.42, 0.42, 0.38), edgecolor="none"))
    ax.set_xlim(-38, 38)
    ax.set_ylim(-28, 28)
    ax.set_aspect("equal")
    ax.set_axis_off()
    ax.set_title("v0.379 exact authored layout — continuous terrain, embedded road, recessed river and bridge", fontsize=13, pad=12)
    fig.tight_layout()
    fig.savefig(PREVIEW_DIR / "01_SCHEMATIC_TOPDOWN.png", bbox_inches="tight", pad_inches=0.08)
    plt.close(fig)

    # 2. Exact terrain/river cross-section through the bridge crossing.
    iz = int(np.argmin(np.abs(zs - 0.0)))
    y_profile = verts[iz, :, 1]
    fig, ax = plt.subplots(figsize=(13.5, 5.8), dpi=150)
    ax.fill_between(xs, -2.3, y_profile, color=(0.40, 0.49, 0.29), alpha=0.95, label="authored terrain")
    water_left = float(river_center(0.0) - river_half_width(0.0))
    water_right = float(river_center(0.0) + river_half_width(0.0))
    ax.fill_between([water_left, water_right], -1.8, -0.54, color=(0.20, 0.42, 0.44), label="recessed water")
    ax.plot([-4.8, 4.8], [0.73, 0.73], linewidth=9, color=(0.49, 0.29, 0.14), solid_capstyle="butt", label="bridge deck")
    ax.add_patch(Rectangle((-5.85, -0.62), 1.25, 1.35, facecolor=(0.42, 0.42, 0.38)))
    ax.add_patch(Rectangle((4.6, -0.62), 1.25, 1.35, facecolor=(0.42, 0.42, 0.38)))
    ax.axhline(-0.54, color=(0.12, 0.28, 0.30), linewidth=1)
    ax.set_xlim(-13, 13)
    ax.set_ylim(-2.0, 2.1)
    ax.set_xlabel("metres across river")
    ax.set_ylabel("height (m)")
    ax.set_title("Exact bridge crossing profile — landform, recessed channel, water level and abutments")
    ax.grid(alpha=0.18)
    ax.legend(loc="upper right")
    fig.tight_layout()
    fig.savefig(PREVIEW_DIR / "02_HEIGHT_AND_BANK_PROFILE.png", bbox_inches="tight")
    plt.close(fig)

    # 3. Bridge assembly schematic, top and side views.
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(13.5, 8.0), dpi=150)
    # top
    ax1.add_patch(Rectangle((-4.8, -1.82), 9.6, 3.64, facecolor=(0.56, 0.34, 0.17), edgecolor=(0.22, 0.14, 0.09), linewidth=2))
    for i in range(1, 18):
        x = -4.8 + i * (9.6 / 18)
        ax1.plot([x, x], [-1.82, 1.82], color=(0.26, 0.16, 0.10), linewidth=0.8)
    for zrail in (-1.66, 1.66):
        ax1.plot([-4.45, 4.45], [zrail, zrail], color=(0.24, 0.14, 0.09), linewidth=4)
        ax1.scatter(np.linspace(-4.45, 4.45, 7), [zrail]*7, s=45, color=(0.22, 0.13, 0.08), zorder=3)
    ax1.add_patch(Rectangle((-5.85, -2.3), 1.25, 4.6, facecolor=(0.42, 0.42, 0.38)))
    ax1.add_patch(Rectangle((4.6, -2.3), 1.25, 4.6, facecolor=(0.42, 0.42, 0.38)))
    ax1.set_xlim(-7, 7); ax1.set_ylim(-3.4, 3.4); ax1.set_aspect("equal"); ax1.set_axis_off(); ax1.set_title("Top view — individual planks, restrained rails and granite abutments")
    # side
    ax2.add_patch(Rectangle((-4.8, 0.64), 9.6, 0.18, facecolor=(0.56, 0.34, 0.17), edgecolor=(0.22, 0.14, 0.09)))
    for x in np.linspace(-4.45, 4.45, 7):
        ax2.plot([x, x], [0.75, 2.15], color=(0.22, 0.13, 0.08), linewidth=4)
    ax2.plot([-4.45, 4.45], [1.35, 1.35], color=(0.22, 0.13, 0.08), linewidth=4)
    ax2.plot([-4.45, 4.45], [1.91, 1.91], color=(0.22, 0.13, 0.08), linewidth=4)
    ax2.add_patch(Rectangle((-5.85, -0.62), 1.25, 1.35, facecolor=(0.42, 0.42, 0.38)))
    ax2.add_patch(Rectangle((4.6, -0.62), 1.25, 1.35, facecolor=(0.42, 0.42, 0.38)))
    ax2.set_xlim(-7, 7); ax2.set_ylim(-1.0, 2.7); ax2.set_aspect("equal"); ax2.set_axis_off(); ax2.set_title("Side view — deck, under-beams, post rhythm and two rail courses")
    fig.suptitle("v0.379 bridge assembly schematic", fontsize=14)
    fig.tight_layout()
    fig.savefig(PREVIEW_DIR / "03_BRIDGE_ASSEMBLY_SCHEMATIC.png", bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    EXPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    scene = create_scene()
    EXPORT_PATH.write_bytes(scene.export(file_type="glb"))
    manifest = {
        "name": "barrosan_highland_infrastructure_v0379",
        "seed": SEED,
        "export": str(EXPORT_PATH.relative_to(ROOT)),
        "units": "metres",
        "up_axis": "Y",
        "geometry_count": len(scene.geometry),
        "scope": scene.metadata["asset"]["scope"],
        "design_intent": [
            "continuous non-checkerboard highland terrain",
            "road embedded by terrain shaping and vertex colour",
            "recessed curved river with dark wet-bank transition",
            "timber bridge with granite abutments, under-beams, planks, edge course and restrained rails",
            "clustered rocks, reeds and shrubs",
        ],
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    write_previews(scene)
    loaded = trimesh.load(EXPORT_PATH, force="scene")
    if not isinstance(loaded, trimesh.Scene) or len(loaded.geometry) < 10:
        raise RuntimeError("GLB round-trip validation failed")
    print(f"Wrote {EXPORT_PATH} ({EXPORT_PATH.stat().st_size:,} bytes), {len(scene.geometry)} geometries")


if __name__ == "__main__":
    main()
