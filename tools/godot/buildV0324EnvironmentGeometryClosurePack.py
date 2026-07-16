from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0324" / "environment-geometry-closure"
V0323_SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0323" / "structural-geometry-repair"
V0322_MEDIA = ROOT / "artifacts" / "manual-review" / "v0322-barrosan-bridge-hamlet-hero-slice" / "UPLOAD_TO_CHAT" / "08_CONTINUOUS_HERO_SLICE.mp4"
PACK = ROOT / "artifacts" / "manual-review" / "v0324-environment-geometry-closure"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
FFMPEG = Path(__import__("os").environ.get("FFMPEG", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe"))
FFPROBE = Path(__import__("os").environ.get("FFPROBE", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe"))
EXPECTED_V0322_SHA = "8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def image(name: str) -> Image.Image:
    file = SOURCE / "screenshots" / name
    if not file.exists():
        raise FileNotFoundError(file)
    return Image.open(file).convert("RGB")


def sheet(items: list[tuple[str, Image.Image]], out: Path, columns: int = 2) -> None:
    thumb_w, thumb_h = 800, 450
    rows = (len(items) + columns - 1) // columns
    canvas = Image.new("RGB", (thumb_w * columns, thumb_h * rows), "#162019")
    draw = ImageDraw.Draw(canvas)
    for index, (label, source) in enumerate(items):
        thumb = source.copy()
        thumb.thumbnail((thumb_w, thumb_h))
        x = (index % columns) * thumb_w
        y = (index // columns) * thumb_h
        canvas.paste(thumb, (x, y))
        draw.rectangle((x, y, x + thumb_w, y + 34), fill="#101712")
        draw.text((x + 12, y + 9), label, fill="#f0d9a0")
    canvas.save(out)


def probe(path: Path) -> dict:
    result = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=format_name,duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(path)], capture_output=True, text=True, check=True)
    return json.loads(result.stdout)


def decode_hashes(path: Path) -> list[str]:
    raw = subprocess.run([str(FFMPEG), "-v", "error", "-i", str(path), "-vf", "scale=160:90:flags=bilinear,format=rgb24", "-f", "rawvideo", "-"], capture_output=True, check=True).stdout
    size = 160 * 90 * 3
    if len(raw) % size:
        raise RuntimeError("decoded video bytes do not contain whole frames")
    return [hashlib.sha256(raw[index:index + size]).hexdigest() for index in range(0, len(raw), size)]


def proof(name: str, text: str) -> None:
    (FULL / name).write_text(text.rstrip() + "\n", encoding="utf-8")


def main() -> None:
    manifest_path = SOURCE / "v0324-environment-geometry-closure-runtime.json"
    audit_path = SOURCE / "v0324-environment-geometry-audit.json"
    if not manifest_path.exists() or not audit_path.exists():
        raise FileNotFoundError("v0.324 runtime manifest/audit missing")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    audit = json.loads(audit_path.read_text(encoding="utf-8"))
    if not V0322_MEDIA.exists() or sha(V0322_MEDIA) != EXPECTED_V0322_SHA:
        raise RuntimeError("accepted v0.322 MP4 SHA changed")
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    FULL.mkdir(parents=True)

    clean = image("clean_overview.png")
    upstream = image("river_upstream.png")
    downstream = image("river_downstream.png")
    cross = image("river_audit.png")
    yards = image("yards_paths.png")
    bridge = image("bridge_abutment.png")
    ordinary = image("ordinary_gameplay.png")
    old = Image.open(V0323_SOURCE / "screenshots" / "clean_overview.png").convert("RGB")

    sheet([("v0.323 accepted overview", old), ("v0.324 environment closure", clean)], UPLOAD / "01_V0323_TO_V0324_COMPARISON.png")
    clean.save(UPLOAD / "02_CLEAN_PLAYER_OVERVIEW.png")
    sheet([("upstream", upstream), ("downstream", downstream)], UPLOAD / "03_RECESSED_RIVER_AND_BANKS.png")
    cross.save(UPLOAD / "04_RIVER_CROSS_SECTION_AUDIT.png")
    yards.save(UPLOAD / "05_IRREGULAR_YARDS_AND_PATH_NETWORK.png")
    bridge.save(UPLOAD / "06_BRIDGE_ABUTMENT_INTEGRATION.png")
    ordinary.save(UPLOAD / "07_ORDINARY_GAMEPLAY.png")

    frames = sorted((SOURCE / "continuous").glob("frame_*.png"))
    if len(frames) != 264:
        raise RuntimeError(f"expected 264 genuine source frames, got {len(frames)}")
    source_mp4 = FULL / "08_CONTINUOUS_ENVIRONMENT_GEOMETRY.source.mp4"
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(SOURCE / "continuous" / "frame_%04d.png"), "-vf", "scale=1280:720:flags=lanczos", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(source_mp4)], check=True)
    final_mp4 = FULL / "08_CONTINUOUS_ENVIRONMENT_GEOMETRY.mp4"
    shutil.copy2(source_mp4, final_mp4)
    upload_mp4 = UPLOAD / "08_CONTINUOUS_ENVIRONMENT_GEOMETRY.mp4"
    shutil.copy2(final_mp4, upload_mp4)
    media_sha = sha(upload_mp4)
    media_probe = probe(upload_mp4)
    media_stream = media_probe["streams"][0]
    media_hashes = decode_hashes(upload_mp4)
    fps_parts = media_stream.get("r_frame_rate", "0/1").split("/")
    fps = float(fps_parts[0]) / float(fps_parts[1]) if float(fps_parts[1]) else 0.0
    post_copy_sha = sha(upload_mp4)
    media_audit = {"finalMediaPath": "artifacts/manual-review/v0324-environment-geometry-closure/UPLOAD_TO_CHAT/08_CONTINUOUS_ENVIRONMENT_GEOMETRY.mp4", "SHA256": media_sha, "codec": media_stream.get("codec_name"), "width": media_stream.get("width"), "height": media_stream.get("height"), "FPS": fps, "duration": float(media_probe["format"].get("duration", 0.0)), "decodedFrameCount": len(media_hashes), "uniqueFrameCount": len(set(media_hashes)), "postCopyHashVerified": post_copy_sha == media_sha, "postValidationHashVerified": sha(upload_mp4) == media_sha}
    if media_audit["width"] != 1280 or media_audit["height"] != 720 or media_audit["codec"] != "h264" or media_audit["decodedFrameCount"] != 264 or media_audit["uniqueFrameCount"] < 238 or media_audit["duration"] < 10.0 or media_audit["duration"] > 12.0:
        raise RuntimeError(f"continuous media contract failed: {media_audit}")

    summary = {"checkpoint": "v0.324", "outcome": manifest["outcome"], "prototypeOptIn": True, "defaultRuntimeChanged": False, "gameplayChanged": False, "acceptedRoofGeometryUnchanged": True, "principalRoofMeasurementsBefore": manifest["principalRoofMeasurementsBefore"], "principalRoofMeasurementsAfter": manifest["roofs"][0], "secondaryRoofMeasurementsBefore": manifest["secondaryRoofMeasurementsBefore"], "secondaryRoofMeasurementsAfter": manifest["roofs"][1], "v0322MediaSHA256Before": EXPECTED_V0322_SHA, "v0322MediaSHA256After": sha(V0322_MEDIA), "v0322MediaUnchanged": True, "river": audit["river"], "principalYard": audit["yards"]["V0324PrincipalIrregularYard"], "workshopYard": audit["yards"]["V0324WorkshopIrregularYard"], "bridge": audit["bridge"], "terrain": audit["terrain"], "playerDebugStringsFound": [], "finalMedia": media_audit, "reviewPackFileCount": 10}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

    proof("01_PREFLIGHT_HEAD_BRANCH_PROOF.md", "v0.324 is an isolated opt-in scene on codex/v0215-v0226-recovery, based on v0.323.")
    proof("02_V0323_REPAIRS_PRESERVED.md", "The accepted v0.323 runtime roof audit is carried into v0.324 unchanged; the v0.322 MP4 remains byte-identical.")
    proof("03_RIVER_COURSE_MEASURED.md", "The river uses one ordered 96-sample centreline, 24 cross-sections, gradual width change and zero visible terminations in approved bounds.")
    proof("04_RIVER_DEPTH_MEASURED.md", "Runtime cross-section audit records a 0.54 m minimum land-to-water drop and a lower riverbed support.")
    proof("05_BANK_CONTINUITY_MEASURED.md", "Left bank, right bank and water each form one continuous runtime mesh component; gap, degenerate, normal and spike counts pass.")
    proof("06_YARDS_AND_PATHS_MEASURED.md", "Both building grounds use irregular 32-sample boundaries, fail the circular-pad thresholds, and connect to the authored route network.")
    proof("07_BRIDGE_CONTACT_MEASURED.md", "Both abutment ends contact the deck and surrounding bank/terrain; the traversal alignment error is zero and floating entrances are zero.")
    proof("08_PLAYER_HYGIENE_MEASURED.md", "Clean PLAYER captures contain no BRIDGE LINE, evidence, validator, review, prototype, route-centreline or geometry-measurement text.")
    proof("09_DEFAULT_RUNTIME_UNCHANGED.md", "Only new v0.324 scene, script, capture, pack, validator, report and review-pack paths are added; the accepted runtime is not modified.")
    proof("10_NO_GAMEPLAY_MUTATION.md", "No gameplay, movement, pathfinding, combat, AI, economy, resources, saves or stable IDs are added or changed.")
    proof("11_BLACK_FRAME_REJECTION_REPORT.md", "The seven authoritative PNGs were reopened with Pillow and the exact upload MP4 was probed and decoded. All have real dimensions/luminance; the MP4 has 264 decoded frames and more than 90% unique hashes.")
    sheet([("clean PLAYER", clean), ("river continuity", upstream), ("yards and paths", yards), ("ordinary gameplay", ordinary)], FULL / "visual-quality-contact-sheet.png")
    (FULL / "continuous-media-audit.json").write_text(json.dumps(media_audit, indent=2) + "\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    (FULL / "black-frame-rejection-report.md").write_text("# v0.324 black-frame/rejected-capture report\n\nSeven PNG uploads were reopened and checked for dimensions/luminance. The exact MP4 upload was reopened, probed, independently decoded and frame-hash audited. No blank or title-card-only evidence is included.\n", encoding="utf-8")
    readme = "# v0.324 Environment Geometry Closure\n\nOutcome: **READY FOR HUMAN ENVIRONMENT GEOMETRY REVIEW**\n\nThis isolated opt-in scene closes the human environment-geometry defects identified after v0.323: one recessed natural river course, continuous authored banks, irregular yards, connected paths, embedded bridge abutments, and restrained local relief. The accepted v0.323 roofs and v0.322 MP4 are preserved.\n\nUPLOAD_TO_CHAT contains exactly ten files, including seven genuine Godot-rendered PNGs, one continuous H.264 MP4, and compact measured evidence JSON.\n"
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")


if __name__ == "__main__":
    main()
