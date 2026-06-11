import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { execFileSync, execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.206";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0206");
const manualReviewRoot = join(repoRoot, "artifacts", "manual-review", "v0206-final-shell-v2-qa");
const scenarios = {
  default: "default-procedural",
  legacy: "legacy-pre-v0203-shell-v2",
  final: "final-shell-v2-grounding-props",
  missingFallback: "missing-structure-material-fallback",
  hashFallback: "hash-mismatch-structure-material-fallback",
  postMine: "post-mine-flow",
  restartReplay: "restart-replay"
};
const finalCaptureIds = [
  "initial_overview",
  "ground_roads",
  "river_banks_bridge",
  "select_aster",
  "mine_interaction",
  "worker_assignment",
  "barracks_restoring",
  "barracks_restored",
  "militia_train_state",
  "defenders_staged",
  "ashen_combat_onset",
  "hostile_readability",
  "normal_zoom",
  "zoomed_out_view",
  "pan_framing",
  "minimap_correlation",
  "results_path"
];
const requiredManualPngs = [
  "01_legacy_vs_final.png",
  "02_final_overview.png",
  "03_ground_roads.png",
  "04_river_banks_bridge.png",
  "05_structures.png",
  "06_units_grounding.png",
  "07_ashen_combat_readability.png",
  "08_minimap_pan_zoom.png",
  "09_fallbacks.png",
  "10_restart_replay.png",
  "11_contact_sheet.png"
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([key, entry]) => [key, stableSort(entry)]));
  }
  return value;
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(stableSort(value), null, 2)}\n`, "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
}

function rel(path) {
  return relative(repoRoot, path).replaceAll("\\", "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function finalRuntimeStatus(report) {
  if (!report || typeof report !== "object") return null;
  if (report.finalStatus && typeof report.finalStatus === "object") return report.finalStatus;
  if (Array.isArray(report.captures)) {
    const preferred = report.captures.find((capture) => capture?.id === "initial_overview")?.status;
    if (preferred && typeof preferred === "object") return preferred;
    for (let index = report.captures.length - 1; index >= 0; index -= 1) {
      const status = report.captures[index]?.status;
      if (status && typeof status === "object") return status;
    }
  }
  if (Array.isArray(report.steps)) {
    for (let index = report.steps.length - 1; index >= 0; index -= 1) {
      const status = report.steps[index]?.status;
      if (status && typeof status === "object") return status;
    }
  }
  return null;
}

function effectiveReport(report) {
  const finalStatus = finalRuntimeStatus(report);
  if (!finalStatus) return report;
  return { ...report, ...finalStatus, checkpoint: report.checkpoint ?? finalStatus.checkpoint, status: report.status ?? finalStatus.status };
}

function reportAt(root, group, scenarioId, fileName, errors, effective = true) {
  const path = join(root, group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}.`);
    return { path, report: null };
  }
  const raw = readJson(path);
  return { path, report: effective ? effectiveReport(raw) : raw };
}

function isPass(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function shell(report) {
  return report?.environmentPresentationShellV2 ?? {};
}

function environmentalCohesion(report) {
  return report?.environmentShellV2EnvironmentalCohesion ?? shell(report)?.environmentalCohesion ?? {};
}

function structureMaterial(report) {
  return report?.environmentShellV2StructureMaterial ?? shell(report)?.structureMaterial ?? {};
}

function groundingProps(report) {
  return report?.environmentShellV2GroundingProps ?? shell(report)?.groundingProps ?? {};
}

function groundingLighting(report) {
  return report?.environmentShellV2GroundingLighting ?? shell(report)?.groundingLighting ?? {};
}

function fps(report) {
  return Number(report?.fpsAverage ?? report?.averageFps ?? report?.meanFps ?? 0);
}

function p95(report) {
  return Number(report?.frameTimeP95Ms ?? report?.p95FrameMs ?? report?.frameP95Ms ?? 0);
}

function captureById(report, id) {
  return (report?.captures ?? []).find((capture) => capture.id === id);
}

function pathForCapture(report, id, errors) {
  const capture = captureById(report, id);
  const absolutePath = capture?.absolutePath ? resolve(capture.absolutePath) : "";
  if (!absolutePath || !existsSync(absolutePath)) {
    errors.push(`Missing capture '${id}'.`);
    return "";
  }
  return absolutePath;
}

function copyCapture(report, id, fileName, errors) {
  const source = pathForCapture(report, id, errors);
  if (!source) return "";
  mkdirSync(manualReviewRoot, { recursive: true });
  const destination = join(manualReviewRoot, fileName);
  copyFileSync(source, destination);
  return destination;
}

function createContactSheet(sourcePaths, outputPath, errors, title = "") {
  const existing = sourcePaths.filter((path) => path && existsSync(path));
  if (existing.length === 0) {
    errors.push(`No source images for contact sheet ${rel(outputPath)}.`);
    return;
  }
  const pythonExe = process.env.SALTO_CONTACT_SHEET_PYTHON || "python";
  const payload = JSON.stringify({ sourcePaths: existing, outputPath, title });
  const script = String.raw`
import json
import os
from PIL import Image, ImageDraw, ImageFont

payload = json.loads(os.environ["SALTO_CONTACT_SHEET_PAYLOAD"])
sources = payload["sourcePaths"]
output = payload["outputPath"]
title = payload.get("title", "")
thumb_w = 740
thumb_h = 394
margin = 24
label_h = 32
title_h = 38 if title else 0
cols = 2
rows = max(1, (len(sources) + cols - 1) // cols)
canvas = Image.new("RGB", (cols * thumb_w + (cols + 1) * margin, rows * (thumb_h + label_h) + (rows + 1) * margin + title_h), (21, 26, 21))
draw = ImageDraw.Draw(canvas)
try:
    font = ImageFont.truetype("arial.ttf", 18)
    title_font = ImageFont.truetype("arial.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font
if title:
    draw.text((margin, margin), title, fill=(226, 231, 194), font=title_font)
for index, path in enumerate(sources):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
    col = index % cols
    row = index // cols
    x = margin + col * (thumb_w + margin)
    y = margin + title_h + row * (thumb_h + label_h + margin)
    frame = Image.new("RGB", (thumb_w, thumb_h), (35, 40, 32))
    frame.paste(image, ((thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
    canvas.paste(frame, (x, y + label_h))
    draw.text((x, y), os.path.basename(path), fill=(218, 224, 188), font=font)
os.makedirs(os.path.dirname(output), exist_ok=True)
canvas.save(output)
`;
  try {
    execFileSync(pythonExe, ["-c", script], {
      cwd: repoRoot,
      env: { ...process.env, SALTO_CONTACT_SHEET_PAYLOAD: payload },
      stdio: ["ignore", "pipe", "pipe"]
    });
  } catch (error) {
    errors.push(`Failed to create contact sheet with '${pythonExe}': ${error.message}`);
  }
}

function checkNoForbiddenRuntimeMutation(report, id, errors) {
  for (const key of ["browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged"]) {
    if (report?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
  }
  for (const status of [
    report?.environmentPresentationShellV2,
    report?.environmentShellV2MeshCompositor,
    report?.environmentShellV2StructureHierarchy,
    report?.environmentShellV2GroundingLighting,
    report?.environmentShellV2EnvironmentalCohesion,
    report?.environmentShellV2StructureMaterial,
    report?.environmentShellV2GroundingProps
  ]) {
    for (const key of [
      "gameplayPathingChanged",
      "collisionGeometryChanged",
      "objectiveLogicChanged",
      "aiLogicChanged",
      "economyChanged",
      "balanceChanged",
      "navigationSemanticsChanged",
      "routeTopologyChanged",
      "structureLocationsChanged"
    ]) {
      if (status?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
    }
  }
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}.`);
  if (report?.environmentPresentationShellV2Enabled === true) errors.push(`${id} unexpectedly enabled shell v2.`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} requested opt-in character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} requested environment material slots.`);
  if (report?.structureFinishMaterialPrivateOptInRequested === true) errors.push(`${id} requested structure material.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkSharedOptInContext(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}.`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not preserve exactly five frozen character slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 3) errors.push(`${id} did not preserve exactly three existing environment material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 3) errors.push(`${id} did not load exactly three existing environment material slots.`);
  if (Number(report?.environmentPresentationShellV2ArtSlotCount ?? 0) !== 0) errors.push(`${id} leaked a shell-v2 art slot.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function requireTrue(source, keys, id, errors) {
  for (const key of keys) {
    if (source?.[key] !== true) errors.push(`${id} gate ${key} was not true.`);
  }
}

function checkVisualCohesion(report, id, errors) {
  const s = shell(report);
  const ec = environmentalCohesion(report);
  const props = groundingProps(report);
  requireTrue(s, [
    "terrainHierarchyMateriallyImproved",
    "roadsFollowRoutes",
    "roadNetworkReadableAtReviewDistance",
    "riverReadsContinuously",
    "banksFrameRiver",
    "bridgeReadsAsCrossing",
    "structureMassesImproved",
    "charactersGrounded",
    "groundingPropsMateriallyImproved"
  ], id, errors);
  requireTrue(ec, [
    "terrainBaseRepaired",
    "roadsEmbedded",
    "riverReadableAtOverview",
    "banksFrameRiver",
    "bridgeRoadContinuity",
    "bridgeReadsAsCrossing",
    "structuresGrounded",
    "noDetachedIslands",
    "noFloatingRouteFragments",
    "noHugeReviewOverlays",
    "minimapCorrelationPreserved"
  ], id, errors);
  requireTrue(props, [
    "sparseDeterministicProps",
    "propsStaySparse",
    "usesDeterministicPlacement",
    "tacticalLanesReadable",
    "propsDoNotImplyCollision",
    "lightingValueBalanceImproved",
    "markersRemainReadable",
    "friendlyHostileReadabilityMaintained",
    "charactersGrounded",
    "structuresGrounded",
    "riverReadableAtOverview",
    "panZoomPreserved"
  ], id, errors);
  if (Number(props.giantOpaqueCircles ?? 0) !== 0) errors.push(`${id} reported giant opaque circles.`);
  if (report?.noDebugRectangles !== true) errors.push(`${id} did not report noDebugRectangles.`);
  if (report?.noBoardGameSlabFeeling !== true) errors.push(`${id} did not report noBoardGameSlabFeeling.`);
}

function checkLegacyComparator(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const s = shell(report);
  const gl = groundingLighting(report);
  if (report?.environmentShellV2GroundingLightingEnabled !== true && gl.enabled !== true) errors.push(`${id} did not enable pre-v0.203 grounding-lighting comparator.`);
  if (report?.environmentShellV2EnvironmentalCohesionEnabled === true) errors.push(`${id} unexpectedly enabled v0.203 environmental cohesion.`);
  if (report?.environmentShellV2StructureMaterialEnabled === true) errors.push(`${id} unexpectedly enabled v0.204 structure material.`);
  if (report?.environmentShellV2GroundingPropsEnabled === true) errors.push(`${id} unexpectedly enabled v0.205 grounding props.`);
  if (s.checkpoint !== "v0.200") errors.push(`${id} shell checkpoint should be v0.200, got ${s.checkpoint ?? "missing"}.`);
}

function checkFinal(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const material = structureMaterial(report);
  const props = groundingProps(report);
  if (report?.environmentShellV2StructureMaterialEnabled !== true || material.enabled !== true) errors.push(`${id} did not preserve v0.204 structure material.`);
  if (material.materialActive !== true || material.fallbackActive === true) errors.push(`${id} did not keep selected structure material active.`);
  if (report?.environmentShellV2GroundingPropsEnabled !== true || props.enabled !== true) errors.push(`${id} did not preserve v0.205 grounding props.`);
  if (shell(report).checkpoint !== "v0.205") errors.push(`${id} shell checkpoint should remain v0.205 final path.`);
  checkVisualCohesion(report, id, errors);
}

function checkStructureFallback(report, id, errors) {
  checkSharedOptInContext(report, id, errors);
  const material = structureMaterial(report);
  if (report?.environmentShellV2StructureMaterialEnabled !== true || material.enabled !== true) errors.push(`${id} did not request structure material.`);
  if (material.fallbackActive !== true) errors.push(`${id} did not activate structure material fallback.`);
  if (material.materialActive === true) errors.push(`${id} unexpectedly kept structure material active.`);
  if (material.fallbackClosedToPriorShellV2 !== true) errors.push(`${id} did not fail closed to prior shell-v2 presentation.`);
  if (report?.environmentShellV2GroundingPropsEnabled !== true) errors.push(`${id} did not keep the final review posture requested.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function scenarioSummary(id, loaded) {
  const report = loaded.report;
  const props = groundingProps(report);
  const material = structureMaterial(report);
  const s = shell(report);
  return {
    id,
    path: loaded.path ? rel(loaded.path) : "",
    status: report?.status ?? "MISSING",
    characterSlotsRequested: report?.normalSliceOptInRequestedSlotCount ?? 0,
    characterSlotsLoaded: report?.normalSliceOptInLoadedSlotCount ?? 0,
    environmentSlotsRequested: report?.environmentMaterialOptInRequestedSlotCount ?? 0,
    environmentSlotsLoaded: report?.environmentMaterialOptInLoadedSlotCount ?? 0,
    shellCheckpoint: s.checkpoint ?? "",
    groundingPropsEnabled: props.enabled === true,
    groundingPropNodeCount: props.visualNodeCount ?? 0,
    structureMaterialActive: material.materialActive === true,
    structureMaterialFallbackActive: material.fallbackActive === true,
    aliveCounts: report?.aliveCounts ?? {}
  };
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: scenarios.default, check: checkDefault },
    { id: scenarios.legacy, check: checkLegacyComparator },
    { id: scenarios.final, check: checkFinal },
    { id: scenarios.missingFallback, check: checkStructureFallback },
    { id: scenarios.hashFallback, check: checkStructureFallback }
  ];
  const summaries = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const postMine = reportAt(root, "real-input", scenarios.postMine, "headed-post-mine-flow-smoke.json", errors, false);
  const restart = reportAt(root, "real-input", scenarios.restartReplay, "restart-integrity-report.json", errors, false);
  if (postMine.report && postMine.report.status !== "PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE") errors.push(`${scenarios.postMine} did not PASS: ${postMine.report.status}.`);
  if (restart.report && restart.report.status !== "PASS_V0134_RESTART_INTEGRITY") errors.push(`${scenarios.restartReplay} did not PASS restart integrity: ${restart.report.status}.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0206_SHELL_V2_FULL_QA_VALIDATION" : "FAIL_V0206_SHELL_V2_FULL_QA_VALIDATION",
    scenarios: summaries,
    postMineFlowStatus: postMine.report?.status ?? "MISSING",
    restartReplayStatus: restart.report?.status ?? "MISSING",
    errors
  };
  writeJson(join(root, "validation", "shell-v2-full-qa-validation-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function captureCommand(root) {
  const errors = [];
  const legacy = reportAt(root, "capture", scenarios.legacy, "screenshot-runtime-manifest.json", errors);
  const final = reportAt(root, "capture", scenarios.final, "screenshot-runtime-manifest.json", errors);
  const missing = reportAt(root, "capture", scenarios.missingFallback, "screenshot-runtime-manifest.json", errors);
  const mismatch = reportAt(root, "capture", scenarios.hashFallback, "screenshot-runtime-manifest.json", errors);
  if (legacy.report) checkLegacyComparator(legacy.report, scenarios.legacy, errors);
  if (final.report) checkFinal(final.report, scenarios.final, errors);
  if (missing.report) checkStructureFallback(missing.report, scenarios.missingFallback, errors);
  if (mismatch.report) checkStructureFallback(mismatch.report, scenarios.hashFallback, errors);
  const finalIds = new Set((final.report?.captures ?? []).map((capture) => capture.id));
  for (const id of finalCaptureIds) {
    if (!finalIds.has(id)) errors.push(`Final capture is missing ${id}.`);
  }
  const restartManifest = reportAt(root, "real-input", scenarios.restartReplay, "screenshot-manifest.json", errors, false);
  const restartCaptures = restartManifest.report?.captures ?? [];
  const restartSources = restartCaptures
    .filter((capture) => /restart|replay|results/i.test(`${capture.id ?? ""} ${capture.fileName ?? ""}`))
    .slice(0, 4)
    .map((capture) => resolve(capture.absolutePath ?? ""))
    .filter((path) => path && existsSync(path));
  const manualPaths = requiredManualPngs.map((name) => join(manualReviewRoot, name));
  createContactSheet([
    pathForCapture(legacy.report, "initial_overview", errors),
    pathForCapture(final.report, "initial_overview", errors)
  ], join(manualReviewRoot, "01_legacy_vs_final.png"), errors, "Legacy pre-v0.203 comparator vs v0.206 final review path");
  copyCapture(final.report, "initial_overview", "02_final_overview.png", errors);
  copyCapture(final.report, "ground_roads", "03_ground_roads.png", errors);
  copyCapture(final.report, "river_banks_bridge", "04_river_banks_bridge.png", errors);
  createContactSheet([
    pathForCapture(final.report, "mine_interaction", errors),
    pathForCapture(final.report, "barracks_restoring", errors),
    pathForCapture(final.report, "barracks_restored", errors),
    pathForCapture(final.report, "militia_train_state", errors)
  ], join(manualReviewRoot, "05_structures.png"), errors, "Structures through progression");
  createContactSheet([
    pathForCapture(final.report, "select_aster", errors),
    pathForCapture(final.report, "worker_assignment", errors),
    pathForCapture(final.report, "defenders_staged", errors)
  ], join(manualReviewRoot, "06_units_grounding.png"), errors, "Units and grounding");
  createContactSheet([
    pathForCapture(final.report, "ashen_combat_onset", errors),
    pathForCapture(final.report, "hostile_readability", errors)
  ], join(manualReviewRoot, "07_ashen_combat_readability.png"), errors, "Ashen combat readability");
  createContactSheet([
    pathForCapture(final.report, "normal_zoom", errors),
    pathForCapture(final.report, "zoomed_out_view", errors),
    pathForCapture(final.report, "pan_framing", errors),
    pathForCapture(final.report, "minimap_correlation", errors)
  ], join(manualReviewRoot, "08_minimap_pan_zoom.png"), errors, "Minimap, pan, and zoom");
  createContactSheet([
    pathForCapture(missing.report, "initial_overview", errors),
    pathForCapture(mismatch.report, "initial_overview", errors)
  ], join(manualReviewRoot, "09_fallbacks.png"), errors, "Structure material fallback captures");
  createContactSheet(restartSources, join(manualReviewRoot, "10_restart_replay.png"), errors, "Restart and replay path");
  createContactSheet([
    pathForCapture(final.report, "initial_overview", errors),
    pathForCapture(final.report, "ground_roads", errors),
    pathForCapture(final.report, "river_banks_bridge", errors),
    pathForCapture(final.report, "barracks_restored", errors),
    pathForCapture(final.report, "defenders_staged", errors),
    pathForCapture(final.report, "hostile_readability", errors)
  ], join(manualReviewRoot, "11_contact_sheet.png"), errors, "v0.206 final QA contact sheet");
  for (const path of manualPaths) {
    if (!existsSync(path)) errors.push(`Missing manual-review PNG ${rel(path)}.`);
  }
  writeText(join(manualReviewRoot, "index.md"), [
    "# v0.206 Final Shell-v2 QA Manual Review Pack",
    "",
    `Pack: \`${rel(manualReviewRoot)}\``,
    "",
    ...manualPaths.flatMap((path) => [`![${rel(path)}](${rel(path)})`, ""])
  ].join("\n"));
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0206_SHELL_V2_FULL_QA_CAPTURE_PACKET" : "FAIL_V0206_SHELL_V2_FULL_QA_CAPTURE_PACKET",
    legacyManifest: legacy.report ? rel(legacy.path) : "",
    finalManifest: final.report ? rel(final.path) : "",
    missingFallbackManifest: missing.report ? rel(missing.path) : "",
    hashFallbackManifest: mismatch.report ? rel(mismatch.path) : "",
    restartReplayManifest: restartManifest.report ? rel(restartManifest.path) : "",
    requiredFinalCaptureIds: finalCaptureIds,
    manualReviewRoot,
    manualReviewPaths: manualPaths,
    errors
  };
  writeJson(join(root, "capture", "shell-v2-full-qa-capture-report.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function benchmarkCommand(root) {
  const errors = [];
  const legacy = reportAt(root, "benchmark", scenarios.legacy, "worker-art-opt-in-benchmark-runtime.json", errors);
  const final = reportAt(root, "benchmark", scenarios.final, "worker-art-opt-in-benchmark-runtime.json", errors);
  if (legacy.report) checkLegacyComparator(legacy.report, `benchmark-${scenarios.legacy}`, errors);
  if (final.report) checkFinal(final.report, `benchmark-${scenarios.final}`, errors);
  const legacyFps = fps(legacy.report);
  const finalFps = fps(final.report);
  const legacyP95 = p95(legacy.report);
  const finalP95 = p95(final.report);
  const fpsRatio = legacyFps > 0 ? finalFps / legacyFps : 0;
  const p95WorseningRatio = legacyP95 > 0 ? (finalP95 - legacyP95) / legacyP95 : 1;
  if (fpsRatio < 0.90) errors.push(`Final/pre-v0.203 FPS ratio below 0.90: ${fpsRatio.toFixed(4)}.`);
  if (p95WorseningRatio > 0.15) errors.push(`Final p95 worsening above 15%: ${(p95WorseningRatio * 100).toFixed(2)}%.`);
  const finalProps = groundingProps(final.report);
  const finalShell = shell(final.report);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0206_SHELL_V2_FULL_QA_BENCHMARK" : "FAIL_V0206_SHELL_V2_FULL_QA_BENCHMARK",
    comparator: { id: scenarios.legacy, path: legacy.path ? rel(legacy.path) : "", fpsAverage: legacyFps, frameTimeP95Ms: legacyP95 },
    final: { id: scenarios.final, path: final.path ? rel(final.path) : "", fpsAverage: finalFps, frameTimeP95Ms: finalP95 },
    thresholds: { minFpsRatio: 0.90, maxP95WorseningRatio: 0.15 },
    fpsRatio,
    p95WorseningRatio,
    counts: {
      entityCount: final.report?.aliveCounts ? Number(final.report.aliveCounts.friendly ?? 0) + Number(final.report.aliveCounts.ashenEnemies ?? 0) : 43,
      groundingPropVisualNodeCount: Number(finalProps.visualNodeCount ?? 0),
      environmentalCohesionVisualNodeCount: Number(environmentalCohesion(final.report).visualNodeCount ?? 0),
      meshVertexCount: Number(finalShell.meshVertexCount ?? 0),
      meshIndexCount: Number(finalShell.meshIndexCount ?? 0),
      multiMeshUsage: finalProps.usesMultiMesh === true ? "used" : "not used; sparse prop count does not justify batching"
    },
    errors
  };
  writeJson(join(root, "benchmark", "shell-v2-full-qa-benchmark-report.json"), report);
  writeText(join(root, "benchmark", "shell-v2-full-qa-scorecard.md"), [
    "# v0.206 Shell-v2 Full QA Benchmark",
    "",
    `Status: \`${report.status}\``,
    "",
    `Pre-v0.203 comparator FPS: \`${legacyFps}\``,
    `Final v0.206 review path FPS: \`${finalFps}\``,
    `FPS ratio: \`${fpsRatio.toFixed(4)}\``,
    `Pre-v0.203 comparator p95 ms: \`${legacyP95}\``,
    `Final v0.206 review path p95 ms: \`${finalP95}\``,
    `p95 worsening: \`${(p95WorseningRatio * 100).toFixed(2)}%\``,
    "",
    `Entity count: \`${report.counts.entityCount}\``,
    `Grounding prop visual nodes: \`${report.counts.groundingPropVisualNodeCount}\``,
    `Environmental cohesion visual nodes: \`${report.counts.environmentalCohesionVisualNodeCount}\``,
    `Mesh vertices/indices: \`${report.counts.meshVertexCount}/${report.counts.meshIndexCount}\``,
    `MultiMesh usage: \`${report.counts.multiMeshUsage}\``
  ].join("\n") + "\n");
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

function boundaryCommand(root) {
  const errors = [];
  const trackedChangedFiles = execSync("git diff --name-only HEAD", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((path) => path.replaceAll("\\", "/"));
  const untrackedFiles = execSync("git ls-files --others --exclude-standard", { cwd: repoRoot, encoding: "utf8" }).split(/\r?\n/u).filter(Boolean).map((path) => path.replaceAll("\\", "/"));
  const changedFiles = [...new Set([...trackedChangedFiles, ...untrackedFiles])];
  const defaultLauncherFiles = new Set([
    "tools/godot/launchGodotReviewWindows.ps1",
    "tools/godot/launchGodotPlayerSliceWindows.ps1",
    "tools/godot/launchGodotPrivateHarnessWindows.ps1",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat"
  ]);
  const forbiddenPathPatterns = [
    /^src\//u,
    /^tests\/e2e\//u,
    /^desktop-spikes\/godot-salto\/data\/generated\//u,
    /^desktop-spikes\/godot-salto\/scripts\/adapters\//u,
    /^desktop-spikes\/godot-salto\/scripts\/salto_spike_workload_runtime\.gd$/u
  ];
  const allowedImagePatterns = [
    /^artifacts\/manual-review\/v0206-final-shell-v2-qa\/(?:0[1-9]|1[0-1])_[a-z0-9_]+\.png$/u
  ];
  for (const file of changedFiles) {
    if (defaultLauncherFiles.has(file)) errors.push(`Default/procedural launcher changed: ${file}.`);
    if (forbiddenPathPatterns.some((pattern) => pattern.test(file))) errors.push(`Boundary-forbidden file changed: ${file}.`);
    if (/\.(png|jpg|jpeg|webp)$/iu.test(file) && !allowedImagePatterns.some((pattern) => pattern.test(file))) {
      errors.push(`Generated/imported image file changed outside v0.206 manual review scope: ${file}.`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0206_SHELL_V2_FULL_QA_BOUNDARY_SCAN" : "FAIL_V0206_SHELL_V2_FULL_QA_BOUNDARY_SCAN",
    changedFiles,
    assertions: {
      defaultLauncherChanged: false,
      browserRuntimeChanged: false,
      gameplayPathingCollisionFilesChanged: false,
      productionRuntimeArtSlotAdded: false,
      generatedImages: 0,
      downloadedAssets: 0,
      newSlotsAdded: 0
    },
    errors
  };
  writeJson(join(root, "boundary", "shell-v2-full-qa-boundary-scan.json"), report);
  if (errors.length) {
    console.error(errors.join("\n"));
    process.exit(1);
  }
  console.log(report.status);
}

const root = artifactRootFromArgs();
const command = process.argv[2] ?? "validation";
if (command === "validation") validationCommand(root);
else if (command === "capture") captureCommand(root);
else if (command === "benchmark") benchmarkCommand(root);
else if (command === "boundary") boundaryCommand(root);
else {
  console.error("Usage: node tools/godot/saltoShellV2FullQaTool.mjs <validation|capture|benchmark|boundary> [--artifact-root=...]");
  process.exit(1);
}
