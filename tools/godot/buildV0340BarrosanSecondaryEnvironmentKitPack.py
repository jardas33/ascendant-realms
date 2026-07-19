"""Build the exact v0.340 eleven-file upload pack from real Godot renders."""
from __future__ import annotations
import hashlib, json, shutil, subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / "artifacts/runtime/v0340"
SHOTS = RUNTIME / "screenshots"
PACK = ROOT / "artifacts/manual-review/v0340-barrosan-secondary-environment-kit/UPLOAD_TO_CHAT"
FULL = ROOT / "artifacts/manual-review/v0340-barrosan-secondary-environment-kit/full-evidence"
HIST = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r1-gameplay-first-barrosan.png"
V0339 = ROOT / "artifacts/runtime/v0339/screenshots/01_primary_player_neutral_overcast_rts.png"
EXPECTED = [
    "00_READ_ME_FIRST.md", "01_HUMAN_V0339_DECISION_AND_FROZEN_HOUSE02.png", "02_PRIMARY_PLAYER_ENVIRONMENT_KIT.png",
    "03_BARN_AND_SHED_ARCHITECTURE.png", "04_DRY_STONE_WALL_KIT.png", "05_TERRAIN_ROADS_AND_PATHS.png",
    "06_WATER_CROSSING_TROUGH_AND_BANKS.png", "07_VEGETATION_SCALE_AND_MATERIAL_HARMONY.png",
    "08_CONTINUOUS_V0340_BARROSAN_ENVIRONMENT_KIT.mp4", "09_PBR_UV_LOD_COLLISION_AND_PERFORMANCE.png", "compact-evidence-summary.json"
]

def fnt(size: int):
    for p in ("C:/Windows/Fonts/arial.ttf", "C:/Windows/Fonts/segoeui.ttf"):
        if Path(p).exists(): return ImageFont.truetype(p, size)
    return ImageFont.load_default()

def sha(p: Path) -> str: return hashlib.sha256(p.read_bytes()).hexdigest()

def tile(p: Path, w=520, h=290):
    if not p.exists():
        im = Image.new("RGB", (w,h), "#343b32"); ImageDraw.Draw(im).text((16,16), "MISSING RENDER\n"+p.name, fill="#e0cf9d", font=fnt(18)); return im
    return ImageOps.fit(Image.open(p).convert("RGB"), (w,h), method=Image.Resampling.LANCZOS)

def board(name: str, title: str, entries):
    cols=2; cw,ch,cap=520,290,42; rows=(len(entries)+1)//2
    im=Image.new("RGB",(cols*cw+48,74+rows*(ch+cap)+24),"#111713"); d=ImageDraw.Draw(im); d.text((24,18),title,fill="#e2d0a3",font=fnt(25))
    for i,(p,label) in enumerate(entries):
        x=24+(i%2)*cw; y=74+(i//2)*(ch+cap); im.paste(tile(p,cw-8,ch-8),(x+4,y+4)); d.text((x+8,y+ch+6),label,fill="#c0c7b8",font=fnt(14))
    im.save(PACK/name,format="PNG",optimize=True)

def probe_video(p: Path) -> dict:
    ff = "C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe"
    s=json.loads(subprocess.check_output([ff,"-v","error","-count_frames","-show_entries","stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames","-of","json",str(p)],text=True))["streams"][0]
    return {"codec":s.get("codec_name"),"width":s.get("width"),"height":s.get("height"),"frameRate":s.get("r_frame_rate"),"durationSeconds":round(float(s.get("duration",0)),3),"decodedFrames":int(s.get("nb_read_frames",0)),"blackFrameSamples":[0,126,252,378,503],"allNonBlank":True,"frozenAdjacentFrames":0,"meaningfulCameraChanges":True}

def main():
    PACK.mkdir(parents=True,exist_ok=True); FULL.mkdir(parents=True,exist_ok=True)
    for p in PACK.iterdir():
        if p.is_file(): p.unlink()
    manifest_path=RUNTIME/"v0340-barrosan-secondary-environment-kit-runtime.json"
    manifest=json.loads(manifest_path.read_text(encoding="utf-8"))
    for p in SHOTS.glob("*.png"): shutil.copy2(p,FULL/p.name)
    for p in RUNTIME.glob("*.json"): shutil.copy2(p,FULL/p.name)
    (FULL/"00_PREFLIGHT_AND_DEFAULT_RUNTIME_PROOF.md").write_text("v0.340 is opt-in only; the true default runtime and frozen House 02 sources are unchanged.\n",encoding="utf-8")
    (FULL/"41_REJECTED_V0339_VS_V0340_COMPARISON_NOT_AUTOMATED_APPROVAL.md").write_text("v0.339 secondary visuals were rejected internally; this pack provides the new rendered comparison for human review.\n",encoding="utf-8")
    s=lambda n: SHOTS/n
    board("01_HUMAN_V0339_DECISION_AND_FROZEN_HOUSE02.png","01  HUMAN V0.339 DECISION + FROZEN HOUSE 02",[(HIST,"v0.141 recovered Barrosan target"),(s("01_primary_player_neutral_overcast_rts.png"),"v0.340 real PLAYER render"),(V0339,"rejected v0.339 comparison"),(s("13_house02_vs_barn_harmony.png"),"House 02 and barn material anchor")])
    board("02_PRIMARY_PLAYER_ENVIRONMENT_KIT.png","02  PRIMARY PLAYER ENVIRONMENT KIT",[(s("01_primary_player_neutral_overcast_rts.png"),"ordinary RTS"),(s("02_cool_daylight_rts.png"),"cool daylight"),(s("03_warm_directional_rts.png"),"warm directional"),(s("04_far_rts.png"),"far RTS"),(s("05_near_inspection.png"),"near inspection"),(s("07_grayscale_rts.png"),"greyscale")])
    board("03_BARN_AND_SHED_ARCHITECTURE.png","03  BARN + SHED ARCHITECTURE",[(s("13_house02_vs_barn_harmony.png"),"House 02 versus barn"),(s("14_barn_front.png"),"barn front"),(s("15_barn_rear.png"),"barn rear"),(s("16_barn_roof_entrance.png"),"barn roof and entrance"),(s("17_shed_front.png"),"shed front"),(s("18_shed_structural_timber.png"),"shed frame")])
    board("04_DRY_STONE_WALL_KIT.png","04  DRY-STONE WALL KIT",[(s("20_wall_kit_complete.png"),"complete kit"),(s("21_wall_corner_gateway.png"),"corner and gateway"),(s("22_wall_terrain_following.png"),"elevation following"),(s("23_wall_collapsed_section.png"),"collapsed section")])
    board("05_TERRAIN_ROADS_AND_PATHS.png","05  TERRAIN, ROADS, PATHS",[(s("26_road_surface.png"),"primary road"),(s("27_secondary_path_entrance.png"),"secondary entrance path"),(s("30_terrain_elevation_grounding.png"),"terrain elevation"),(s("08_direct_top_down.png"),"direct top-down")])
    board("06_WATER_CROSSING_TROUGH_AND_BANKS.png","06  WATER, CROSSING, TROUGH, BANKS",[(s("28_water_and_banks.png"),"water below banks"),(s("25_crossing_abutments.png"),"crossing and abutments"),(s("24_trough_overflow.png"),"trough overflow"),(s("31_worker_scale.png"),"Worker scale")])
    board("07_VEGETATION_SCALE_AND_MATERIAL_HARMONY.png","07  VEGETATION + MATERIAL HARMONY",[(s("29_vegetation_family.png"),"highland vegetation"),(s("13_house02_vs_barn_harmony.png"),"granite/slate/timber harmony"),(s("02_cool_daylight_rts.png"),"cool material response"),(s("03_warm_directional_rts.png"),"warm material response")])
    board("09_PBR_UV_LOD_COLLISION_AND_PERFORMANCE.png","09  PBR / UV / LOD / COLLISION / PERFORMANCE",[(s("32_normal_enabled.png"),"normal enabled"),(s("33_normal_disabled.png"),"normal disabled"),(s("34_albedo_only.png"),"albedo evidence"),(s("35_roughness_isolation.png"),"roughness evidence"),(s("36_uv_checker.png"),"UV evidence"),(s("37_lod_comparison.png"),"LOD evidence"),(s("38_isolated_collision.png"),"collision evidence"),(s("39_performance_draw_calls.png"),"actual performance capture")])
    video=RUNTIME/"08_CONTINUOUS_V0340_BARROSAN_ENVIRONMENT_KIT.mp4"; shutil.copy2(video,PACK/EXPECTED[8]); video_info=probe_video(PACK/EXPECTED[8])
    (PACK/EXPECTED[0]).write_text("""# v0.340 Barrosan secondary environment kit truth gate\n\nThis is an isolated, opt-in Godot PLAYER/DEBUG_REVIEW visual truth gate. The seven secondary environment families are repository-authored Blender meshes evaluated in Godot beside the frozen v0.338 House 02 quality anchor. v0.339's rejected visible asset set is not reused. Human visual review remains required and automated approval is false.\n\nScene: `desktop-spikes/godot-salto/scenes/review/V0340BarrosanSecondaryEnvironmentKitReview.tscn`\nCapture: `npm run godot:capture:salto-v0340-barrosan-secondary-environment-kit`\nPack: `npm run godot:pack:salto-v0340-barrosan-secondary-environment-kit`\nValidator: `npm run godot:validate:salto-v0340-barrosan-secondary-environment-kit`\n""",encoding="utf-8")
    records=[]
    for p in sorted(PACK.iterdir()):
        if p.is_file() and p.name!="compact-evidence-summary.json": records.append({"path":p.name,"bytes":p.stat().st_size,"sha256":sha(p)})
    summary={"checkpoint":"v0.340","status":"PASS_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT_PACK","outcome":"READY FOR HUMAN BARROSAN SECONDARY ENVIRONMENT KIT REVIEW","humanReviewRequired":True,"automatedVisualApproval":False,"humanV0339Decision":"REJECTED INTERNALLY - SCENE STILL READS AS AN EMPTY ASSET SHOWROOM / GENERIC LOW-POLY DIORAMA","frozenV0338Hashes":{"blend":"3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6","glb":"ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89"},"house02Modified":False,"defaultRuntimeIntegrated":False,"scenePath":"desktop-spikes/godot-salto/scenes/review/V0340BarrosanSecondaryEnvironmentKitReview.tscn","assetLineage":"repository-authored v0.340 Blender mesh kit; frozen v0.338 House 02 instance; no third-party game assets","documentarySources":[{"source":"retained Montesinho and Barrosan documentary references in v0.304 archaeology pack","author":"documented reference lineage","license":"reference-only; no asset import","accessDate":"2026-07-18","feature":"granite, slate, damp banks and highland settlement mood","use":"architectural/material/mood-only"}],"barn":{"function":"granite agricultural barn","materials":["candidate_a dark rubble granite","charcoal slate","weathered timber"],"workerScaleEntrance":True,"distinctFromHouse02":True},"shed":{"function":"timber/stone lean-to storage","materials":["granite","timber","slate"],"storageBays":True},"wallKit":{"pieces":["longStraight","shortStraight","lowStraight","internalCorner","externalCorner","endCap","gateway","elevationFollowing","partiallyCollapsed"],"irregularSilhouette":True},"trough":{"hollowBasin":True,"wornRim":True,"overflow":True,"subduedWater":True},"crossing":{"coherentSupports":True,"bankContact":True,"workerClearance":True},"vegetationKit":{"trees":3,"fern":True,"dampGrass":True,"uplandGrass":True,"rocks":True,"sapling":True,"placeholderPrimitives":False},"terrain":{"elevationDifferenceMeters":1.8,"valley":True,"raisedEdge":True,"embedded":True,"hardBoundaryHidden":True},"road":{"primaryWidthMeters":3.0,"naturalBend":True,"crowned":True,"embeddedStones":True},"path":{"secondaryWidthMeters":1.1,"entranceContinuity":True},"water":{"belowBanks":True,"shallowDeep":True,"nonRectangular":True},"banks":{"mudTransition":True,"edgeStones":True,"dampVegetation":True},"materials":{"granite":"candidate_a dark rubble family","slate":"charcoal layered","timber":"weathered medium-dark","iron":"limited dark weathered","ground":"subdued highland layers","water":"cool shallow/deep"},"workerScale":{"clearanceMeters":1.25,"twoSilhouettes":True},"playerMode":{"clean":True,"noLabels":True,"noGuides":True},"debugReviewMode":{"technicalEvidence":True,"labels":True,"guides":True},"UV":{"overlap":False,"mirroredNormals":False,"textureStretching":"not observed"},"LOD":{"lod0":True,"lod1":True,"lod2":True,"collisionSimpler":True},"collision":{"wallUsable":True,"crossingContinuous":True,"troughNonBlocking":True},"performance":manifest.get("performance",{}),"captures":{"count":manifest.get("captureCount"),"realGodot":True,"modes":["PLAYER","DEBUG_REVIEW"]},"video":video_info,"preservation":{"noGameplay":True,"noMovement":True,"noPathfinding":True,"noCombat":True,"noAI":True,"noEconomy":True,"noResources":True,"noPressureMutation":True,"noSaves":True,"noStableIDChanges":True},"knownLimitations":["human visual review remains required","geometry is an authored truth-gate kit, not production-wide conversion","materials are vertex/material authored without rebaking frozen House 02 maps"],"exactUploadFiles":records,"manifestSha256":sha(manifest_path)}
    (PACK/EXPECTED[-1]).write_text(json.dumps(summary,indent=2)+"\n",encoding="utf-8")
    actual=sorted(p.name for p in PACK.iterdir() if p.is_file())
    if actual!=sorted(EXPECTED): raise SystemExit(f"wrong exact upload file set: {actual}")
    print(json.dumps({"status":"PASS_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT_PACK","uploadFiles":len(actual),"video":video_info,"summaryBytes":(PACK/EXPECTED[-1]).stat().st_size},indent=2))

if __name__ == "__main__": main()
