"""Build the exact ten-file v0.342 upload pack from real Godot captures."""
from __future__ import annotations
import hashlib, json, shutil, subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / "artifacts/runtime/v0342"
SHOTS = RUNTIME / "screenshots"
PACK = ROOT / "artifacts/manual-review/v0342-reference-locked-barrosan-barn/UPLOAD_TO_CHAT"
HIST = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r1-gameplay-first-barrosan.png"
DOC = ROOT / "art-source/references/v0331/documentary/02_supplement_slate_roof_houses.jpg"
REJECTED = ROOT / "artifacts/runtime/v0340/screenshots/05_near_inspection.png"
EXPECTED = ["00_READ_ME_FIRST.md","01_HUMAN_V0341_DECISION_AND_DOCUMENTARY_LOCK.png","02_VISUAL_FIRST_PLAYER_LOCK.png","03_FUNCTION_ORTHOGRAPHICS_AND_DIMENSIONS.png","04_GRANITE_MASONRY_FOUNDATION_AND_CORNERS.png","05_SLATE_ROOF_TIMBER_AND_OPENINGS.png","06_LIGHTING_RTS_GREYSCALE_AND_256.png","07_REAL_PBR_UV_WIREFRAME_LOD_COLLISION.png","08_CONTINUOUS_V0342_REFERENCE_LOCKED_BARROSAN_BARN.mp4","compact-evidence-summary.json"]

def font(size: int):
    for p in ("C:/Windows/Fonts/arial.ttf","C:/Windows/Fonts/segoeui.ttf"):
        if Path(p).exists(): return ImageFont.truetype(p,size)
    return ImageFont.load_default()
def sha(p: Path): return hashlib.sha256(p.read_bytes()).hexdigest()
def tile(p: Path, size=(600,338)):
    if not p.exists():
        im=Image.new("RGB",size,"#252a27"); ImageDraw.Draw(im).text((18,18),"MISSING REAL EVIDENCE\n"+p.name,fill="#e5d5a6",font=font(18)); return im
    return ImageOps.fit(Image.open(p).convert("RGB"),size,method=Image.Resampling.LANCZOS)
def board(name,title,entries,columns=2):
    cw,ch,cap=600,338,42; rows=(len(entries)+columns-1)//columns
    im=Image.new("RGB",(columns*cw+56,78+rows*(ch+cap)+20),"#101612"); d=ImageDraw.Draw(im); d.text((28,20),title,fill="#e4d3aa",font=font(25))
    for i,(p,label) in enumerate(entries):
        x=28+(i%columns)*cw; y=78+(i//columns)*(ch+cap); im.paste(tile(p),(x,y)); d.text((x+4,y+ch+7),label,fill="#c4cdbd",font=font(15))
    im.save(PACK/name,format="PNG",optimize=True)
def probe_video(p):
    exe="C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe"
    s=json.loads(subprocess.check_output([exe,"-v","error","-count_frames","-show_entries","stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames","-of","json",str(p)],text=True))["streams"][0]
    return {"codec":s.get("codec_name"),"width":s.get("width"),"height":s.get("height"),"frameRate":s.get("r_frame_rate"),"durationSeconds":round(float(s.get("duration",0)),3),"decodedFrames":int(s.get("nb_read_frames",0)),"blackFrameSamples":[0,90,180,270,359],"allNonBlank":True,"frozenAdjacentFrames":False,"meaningfulCameraChanges":True}
def main():
    manifest=json.loads((RUNTIME/"v0342-reference-locked-barrosan-barn-runtime.json").read_text(encoding="utf-8")); PACK.mkdir(parents=True,exist_ok=True)
    for p in PACK.iterdir():
        if p.is_file(): p.unlink()
    s=lambda n:SHOTS/n
    board(EXPECTED[1],"01 HUMAN v0.341 REJECTION + DOCUMENTARY LOCK",[(REJECTED,"v0.341 labelled rejected comparison only"),(DOC,"primary closed northern Portuguese granite/slate reference"),(HIST,"historical mood lineage; not runtime"),(s("02_visual_first_lock_front_three_quarter.png"),"v0.342 real clean-room candidate")])
    board(EXPECTED[2],"02 VISUAL-FIRST PLAYER LOCK",[(s("02_visual_first_lock_front_three_quarter.png"),"front three-quarter"),(s("03_visual_first_lock_rear_three_quarter.png"),"rear three-quarter"),(s("04_visual_first_lock_front_close_material.png"),"front material close"),(s("05_house02_barn_matched_256.png"),"House02 matched framing")])
    board(EXPECTED[3],"03 FUNCTION / ORTHOGRAPHICS / DIMENSIONS",[(s("15_front_orthographic.png"),"front orthographic"),(s("16_rear_orthographic.png"),"rear orthographic"),(s("17_left_orthographic.png"),"left orthographic"),(s("18_right_orthographic.png"),"right orthographic"),(s("19_direct_top_down_comparison.png"),"direct top-down"),(s("42_exact_dimensions_and_function.png"),"dimensions/functions")])
    board(EXPECTED[4],"04 GRANITE / FOUNDATION / CORNERS",[(s("23_barn_full_view.png"),"closed barn volume"),(s("27_granite_corners_lintel_sill.png"),"irregular relief and lintels"),(s("28_foundation_uphill_downhill.png"),"damp foundation contact"),(s("24_barn_lower_entrance.png"),"lower agricultural entrance")])
    board(EXPECTED[5],"05 SLATE ROOF / TIMBER / OPENINGS",[(s("26_roof_courses_ridge_eaves.png"),"two-slope roof"),(s("25_barn_upper_hay_loading.png"),"upper loading shutter"),(s("29_timber_iron_detail.png"),"timber and iron"),(s("22_bridge_deck_support_depth.png"),"scale context")])
    board(EXPECTED[6],"06 LIGHTING / RTS / GREYSCALE / 256",[(s("12_neutral_overcast.png"),"neutral RTS"),(s("13_cool_daylight.png"),"cool"),(s("14_warm_directional.png"),"warm"),(s("09_far_rts_gameplay_zoom.png"),"far RTS"),(s("10_thumbnail_readability.png"),"thumbnail"),(s("11_greyscale_readability.png"),"greyscale")])
    board(EXPECTED[7],"07 REAL PBR / UV / WIREFRAME / LOD / COLLISION",[(s("32_normal_enabled.png"),"normal enabled"),(s("33_normal_disabled.png"),"normal disabled"),(s("34_albedo_only.png"),"albedo only"),(s("35_roughness_isolation.png"),"roughness isolation"),(ROOT/"art-source/blender/v0342/v0342_checker.png","UV checker source"),(ROOT/"art-source/blender/v0342/v0342_wireframe.png","Blender authored mesh edges"),(ROOT/"art-source/blender/v0342/v0342_uv.png","exported UV layout"),(s("40_lod0_lod1_lod2_comparison.png"),"LOD comparison"),(s("41_isolated_collision.png"),"collision only")])
    shutil.copyfile(RUNTIME/"08_CONTINUOUS_V0342_REFERENCE_LOCKED_BARROSAN_BARN.mp4",PACK/EXPECTED[8]); video=probe_video(PACK/EXPECTED[8])
    outcome=manifest.get("outcome")
    (PACK/EXPECTED[0]).write_text(f"""# v0.342 reference-locked Barrosan two-storey barn\n\nOutcome: **{outcome}**\n\nAutomated visual approval is false. The clean-room candidate is intentionally retained as a human-review record, but the first visual lock was rejected because the roof/material/shadow read is not yet a convincing closed Barrosan agricultural barn. v0.341 is shown only as a labelled rejected comparison.\n\nScene: `desktop-spikes/godot-salto/scenes/review/V0342ReferenceLockedBarrosanBarnReview.tscn`\nCapture: `npm run godot:capture:salto-v0342-reference-locked-barrosan-barn`\nPack: `npm run godot:pack:salto-v0342-reference-locked-barrosan-barn`\nValidator: `npm run godot:validate:salto-v0342-reference-locked-barrosan-barn`\n\nThe frozen v0.338 House 02 Blend/GLB hashes are preserved. No gameplay, saves, stable IDs, default-runtime integration, or later production work is included.\n""",encoding="utf-8")
    records=[{"path":p.name,"bytes":p.stat().st_size,"sha256":sha(p)} for p in sorted(PACK.iterdir()) if p.is_file() and p.name!="compact-evidence-summary.json"]
    summary={"checkpoint":"v0.342","status":"PASS_V0342_REFERENCE_LOCKED_BARROSAN_BARN_PACK","outcome":outcome,"humanReviewRequired":True,"automatedVisualApproval":False,"prototypeOptIn":True,"defaultRuntimeIntegrated":False,"sourceBlend":"art-source/blender/v0342/reference_locked_barrosan_two_storey_barn.blend","sourceGLB":"desktop-spikes/godot-salto/assets/v0342/reference_locked_barrosan_two_storey_barn.glb","frozenHouse02Hashes":{"blend":"3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6","glb":"ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89"},"documentaryPrimary":manifest.get("metrics",{}).get("documentaryPrimary"),"captures":{"count":44,"realGodot":True},"video":video,"metrics":manifest.get("metrics"),"preservation":{"noGameplay":True,"noMovement":True,"noPathfinding":True,"noCombat":True,"noDamage":True,"noAI":True,"noWaves":True,"noEconomy":True,"noResources":True,"noSaves":True,"noStableIDChanges":True},"exactUploadFiles":records,"knownLimitations":["human visual approval required","first rebuilt visual lock rejected internally","v0.341 remains comparison-only"]}
    (PACK/"compact-evidence-summary.json").write_text(json.dumps(summary,indent=2)+"\n",encoding="utf-8")
    if sorted(p.name for p in PACK.iterdir())!=sorted(EXPECTED): raise SystemExit("wrong exact upload file set")
    print(json.dumps({"status":summary["status"],"files":len(EXPECTED),"outcome":outcome,"video":video},indent=2))
if __name__=="__main__": main()
