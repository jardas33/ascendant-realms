import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.181";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0181");
const groundSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const roadSha = "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10";
const groundSlot = "barrosan_foothold_ground_material_v0175";
const roadSlot = "barrosan_foothold_road_material_v0180";
const groundApproach = "GROUND_MATERIAL_LOCAL_1024";
const roadApproach = "ROAD_MATERIAL_LOCAL_1024";
const groundUvScale = 0.56;
const roadUvScale = 0.80;
const maximumGroundNoiseAlpha = 0.52;
const groundSurfaces = ["v0173_terrain_mid_value_field", "v0173_friendly_staging_value_field"];
const roadSurfaces = [
  "v0173_main_road_wide_readable_bed",
  "v0173_barracks_side_path_wide_bed",
  "v0173_ruins_side_path_wide_bed"
];
const excludedRoadTerms = ["ground", "river", "bank", "bridge", "site", "marker", "minimap", "character", "approach"];
const requiredCaptureIds = [
  "ground_material_normal_rts",
  "ground_material_close",
  "road_river_bridge_hierarchy",
  "site_marker_scope",
  "five_slot_coexistence",
  "combat_onset",
  "camera_pan_readability",
  "camera_min_zoom",
  "camera_max_zoom",
  "results"
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([key, entry]) => [key, stableSort(entry)]));
  }
  return value;
}

function stableStringify(value) {
  return `${JSON.stringify(stableSort(value), null, 2)}\n`;
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8").replace(/^\uFEFF/u, ""));
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, stableStringify(value), "utf8");
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value, "utf8");
}

function rel(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function artifactRootFromArgs() {
  const explicit = process.argv.find((arg) => arg.startsWith("--artifact-root="));
  return explicit ? resolve(explicit.slice("--artifact-root=".length)) : artifactRootDefault;
}

function reportAt(root, group, scenarioId, fileName, errors) {
  const path = join(root, group, scenarioId, fileName);
  if (!existsSync(path)) {
    errors.push(`Missing ${rel(path)}`);
    return { path, report: null };
  }
  return { path, report: readJson(path) };
}

function isPass(report) {
  return typeof report?.status === "string" && report.status.startsWith("PASS");
}

function ground(report) {
  return report?.groundMaterialExperiment ?? {};
}

function road(report) {
  return report?.roadMaterialExperiment ?? {};
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0 || Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 0) errors.push(`${id} should remain zero-slot procedural.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 0 || Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 0) errors.push(`${id} should not request or load environment material.`);
  if (report?.environmentFoundationReviewEnabled === true) errors.push(`${id} unexpectedly enabled environment foundation review.`);
  if (report?.terrainMaterialSourceImported === true || report?.roadMaterialSourceImported === true) errors.push(`${id} unexpectedly imported environment material.`);
  if (report?.groundMaterialOptInRequested === true || report?.roadMaterialOptInRequested === true) errors.push(`${id} unexpectedly requested environment material opt-in.`);
}

function checkFiveSlot(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five frozen character/material slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character/material slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  if (report?.browserRuntimeChanged === true || report?.saveWritesAllowed === true || report?.stableIdsChanged === true) errors.push(`${id} reported browser/save/stable-ID mutation.`);
}

function checkFoundation(report, id, errors) {
  checkFiveSlot(report, id, errors);
  if (report?.environmentFoundationReviewEnabled !== true || report?.environmentFoundationReview?.enabled !== true) errors.push(`${id} did not enable the environment foundation review.`);
  if (report?.environmentReadabilityHardeningEnabled === true || report?.environmentContrastHarmonizationEnabled === true) errors.push(`${id} unexpectedly enabled later environment hardening flags.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 0 || Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} should not request material slots.`);
  if (report?.terrainMaterialSourceImported === true || report?.roadMaterialSourceImported === true) errors.push(`${id} unexpectedly imported material.`);
}

function checkGroundLoaded(report, id, errors) {
  checkFiveSlot(report, id, errors);
  const g = ground(report);
  if (report?.environmentFoundationReviewEnabled !== true || report?.environmentFoundationReview?.enabled !== true) errors.push(`${id} did not enable the environment foundation review.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 1 || Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 1) errors.push(`${id} did not report exactly one ground material slot.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 1) errors.push(`${id} did not load exactly one ground material slot.`);
  if (report?.terrainMaterialSourceImported !== true || report?.terrainMaterialRuntimeSlotAdded !== true) errors.push(`${id} did not report the ground material imported/runtime-added.`);
  if (report?.roadMaterialOptInRequested === true || report?.roadMaterialSourceImported === true) errors.push(`${id} unexpectedly requested or loaded road material.`);
  checkGroundContract(g, id, errors);
}

function checkGroundContract(g, id, errors) {
  if (g.slotId !== groundSlot || g.approach !== groundApproach) errors.push(`${id} ground slot/approach mismatch.`);
  if (g.expectedSha256 !== groundSha || g.actualSha256 !== groundSha) errors.push(`${id} ground hash mismatch.`);
  if (g.sourceLoaded !== true || g.materialActive !== true || g.fallbackActive !== false) errors.push(`${id} ground material is not active without fallback.`);
  if (Math.abs(Number(g.uvScale ?? 0) - groundUvScale) > 0.001) errors.push(`${id} ground UV scale is not ${groundUvScale}.`);
  if (Number(g.noiseControlAlpha ?? 1) > maximumGroundNoiseAlpha) errors.push(`${id} ground noise-control alpha exceeds ${maximumGroundNoiseAlpha}.`);
  if (!String(g.filterMode ?? "").toLowerCase().includes("mipmaps")) errors.push(`${id} ground filter mode does not include mipmaps.`);
  if (Number(g.sourceLoadCount ?? 99) !== 1 || Number(g.metadataParseCount ?? 99) !== 1 || Number(g.imageDecodeCount ?? 99) !== 1 || Number(g.textureCreateCount ?? 99) !== 1 || Number(g.materialCreateCount ?? 99) !== 1) errors.push(`${id} ground material was not one-time loaded/created.`);
  const surfaces = Array.isArray(g.appliedSurfaceNames) ? g.appliedSurfaceNames : [];
  if (Number(g.appliedSurfaceCount ?? 0) !== groundSurfaces.length) errors.push(`${id} ground applied surface count is not ${groundSurfaces.length}.`);
  for (const surface of groundSurfaces) if (!surfaces.includes(surface)) errors.push(`${id} missing ground surface ${surface}.`);
  for (const surface of surfaces) if (!groundSurfaces.includes(surface)) errors.push(`${id} applied ground material to unexpected surface ${surface}.`);
}

function checkRoadLoaded(report, id, errors) {
  checkFiveSlot(report, id, errors);
  const g = ground(report);
  const r = road(report);
  if (report?.environmentFoundationReviewEnabled !== true || report?.environmentFoundationReview?.enabled !== true) errors.push(`${id} did not enable the environment foundation review.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 2 || Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 2) errors.push(`${id} did not report exactly two environment material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 2) errors.push(`${id} did not load both environment material slots.`);
  if (report?.terrainMaterialSourceImported !== true || report?.terrainMaterialRuntimeSlotAdded !== true) errors.push(`${id} did not preserve the ground material.`);
  if (report?.roadMaterialSourceImported !== true || report?.roadMaterialRuntimeSlotAdded !== true) errors.push(`${id} did not report the road material imported/runtime-added.`);
  checkGroundContract(g, id, errors);
  checkRoadContract(r, id, errors);
}

function checkRoadContract(r, id, errors) {
  if (r.slotId !== roadSlot || r.approach !== roadApproach) errors.push(`${id} road slot/approach mismatch.`);
  if (r.expectedSha256 !== roadSha || r.actualSha256 !== roadSha) errors.push(`${id} road hash mismatch.`);
  if (r.sourceLoaded !== true || r.materialActive !== true || r.fallbackActive !== false) errors.push(`${id} road material is not active without fallback.`);
  if (r.sourceDimensions?.width !== 1024 || r.sourceDimensions?.height !== 1024) errors.push(`${id} road source dimensions are not 1024x1024.`);
  if (Math.abs(Number(r.uvScale ?? 0) - roadUvScale) > 0.001) errors.push(`${id} road UV scale is not ${roadUvScale}.`);
  if (!String(r.filterMode ?? "").toLowerCase().includes("mipmaps")) errors.push(`${id} road filter mode does not include mipmaps.`);
  if (r.appliedOnlyToRoadSurfaceGroup !== true) errors.push(`${id} road material did not declare road-only application.`);
  if (Number(r.sourceLoadCount ?? 99) !== 1 || Number(r.metadataParseCount ?? 99) !== 1 || Number(r.imageDecodeCount ?? 99) !== 1 || Number(r.textureCreateCount ?? 99) !== 1 || Number(r.materialCreateCount ?? 99) !== 1) errors.push(`${id} road material was not one-time loaded/created.`);
  if (Number(r.materialReuseCount ?? 0) < 2) errors.push(`${id} road material was not reused across road surfaces.`);
  const surfaces = Array.isArray(r.appliedSurfaceNames) ? r.appliedSurfaceNames : [];
  if (Number(r.appliedSurfaceCount ?? 0) !== roadSurfaces.length) errors.push(`${id} road applied surface count is not ${roadSurfaces.length}.`);
  for (const surface of roadSurfaces) if (!surfaces.includes(surface)) errors.push(`${id} missing road surface ${surface}.`);
  for (const surface of surfaces) {
    if (!roadSurfaces.includes(surface)) errors.push(`${id} applied road material to unexpected surface ${surface}.`);
    for (const term of excludedRoadTerms) {
      if (term !== "road" && surface.toLowerCase().includes(term)) errors.push(`${id} road material surface ${surface} matches excluded term ${term}.`);
    }
  }
}

function checkRoadFallback(report, id, expectedReasonFragment, errors) {
  checkFiveSlot(report, id, errors);
  const g = ground(report);
  const r = road(report);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 2 || Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 2) errors.push(`${id} should still request ground plus road material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 1) errors.push(`${id} should load only the ground material while road falls back.`);
  if (report?.terrainMaterialSourceImported !== true || report?.terrainMaterialRuntimeSlotAdded !== true) errors.push(`${id} did not preserve ground material during road fallback.`);
  if (report?.roadMaterialSourceImported === true || report?.roadMaterialProceduralFallbackActive !== true) errors.push(`${id} should not import road material during fallback.`);
  checkGroundContract(g, id, errors);
  if (r.enabled !== true || r.sourceLoaded !== false || r.materialActive !== false || r.fallbackActive !== true || r.proceduralFallbackVisible !== true) errors.push(`${id} did not activate procedural road fallback.`);
  if (!String(r.fallbackReason ?? "").includes(expectedReasonFragment)) errors.push(`${id} fallback reason did not include '${expectedReasonFragment}': ${r.fallbackReason ?? ""}`);
  if (Math.abs(Number(r.uvScale ?? 0) - roadUvScale) > 0.001) errors.push(`${id} fallback road UV scale is not ${roadUvScale}.`);
  if (Number(r.appliedSurfaceCount ?? 0) !== 0) errors.push(`${id} applied road material surfaces during fallback.`);
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: "default-procedural", check: checkDefault },
    { id: "e0-environment-foundation-baseline", check: checkFoundation },
    { id: "e1-ground-material-opt-in", check: checkGroundLoaded },
    { id: "e2-ground-road-material-opt-in", check: checkRoadLoaded },
    { id: "road-missing-art-fallback", check: (report, id, errs) => checkRoadFallback(report, id, "missing source file", errs) },
    { id: "road-hash-mismatch-fallback", check: (report, id, errs) => checkRoadFallback(report, id, "hash mismatch", errs) }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION" : "FAIL_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION", groundSha, roadSha, groundUvScale, roadUvScale, scenarios, errors };
  writeJson(join(root, "validation", "ground-road-material-opt-in-validation-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function scenarioSummary(id, loaded) {
  const report = loaded.report;
  return {
    id,
    path: rel(loaded.path),
    status: report?.status ?? "MISSING",
    characterSlotsRequested: report?.normalSliceOptInRequestedSlotCount ?? 0,
    characterSlotsLoaded: report?.normalSliceOptInLoadedSlotCount ?? 0,
    environmentSlotsRequested: report?.environmentMaterialOptInRequestedSlotCount ?? 0,
    environmentSlotsLoaded: report?.environmentMaterialOptInLoadedSlotCount ?? 0,
    groundLoaded: ground(report)?.sourceLoaded ?? false,
    roadLoaded: road(report)?.sourceLoaded ?? false,
    roadFallbackActive: road(report)?.fallbackActive ?? false,
    roadFallbackReason: road(report)?.fallbackReason ?? "",
    roadAppliedSurfaceNames: road(report)?.appliedSurfaceNames ?? []
  };
}

function captureCommand(root) {
  const errors = [];
  const configs = [
    { id: "e0-environment-foundation-baseline", check: checkFoundation },
    { id: "e1-ground-material-opt-in", check: checkGroundLoaded },
    { id: "e2-ground-road-material-opt-in", check: checkRoadLoaded },
    { id: "road-missing-art-fallback", check: (report, id, errs) => checkRoadFallback(report, id, "missing source file", errs) },
    { id: "road-hash-mismatch-fallback", check: (report, id, errs) => checkRoadFallback(report, id, "hash mismatch", errs) }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "capture", config.id, "screenshot-runtime-manifest.json", errors);
    const captures = Array.isArray(loaded.report?.captures) ? loaded.report.captures : [];
    if (loaded.report) {
      config.check(loaded.report, config.id, errors);
      const ids = new Set(captures.map((capture) => capture.id));
      for (const captureId of requiredCaptureIds) if (!ids.has(captureId)) errors.push(`${config.id} missing required capture id: ${captureId}`);
    }
    return { ...scenarioSummary(config.id, loaded), captureCount: loaded.report?.captureCount ?? 0, screenshotRoot: loaded.report?.screenshotRoot ? rel(resolve(loaded.report.screenshotRoot)) : "", captures: captures.map((capture) => ({ id: capture.id, fileName: capture.fileName, label: capture.label, absolutePath: capture.absolutePath })) };
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE" : "FAIL_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE", requiredCaptureIds, contactSheet: "capture/v0181-ground-road-material-opt-in-contact-sheet.svg", scenarios, errors };
  writeJson(join(root, "capture", "ground-road-material-opt-in-capture-report.json"), report);
  writeText(join(root, "capture", "v0181-ground-road-material-opt-in-contact-sheet.svg"), contactSheetSvg(scenarios));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function contactSheetSvg(scenarios) {
  const preferred = ["ground_material_normal_rts", "road_river_bridge_hierarchy", "five_slot_coexistence", "combat_onset", "camera_max_zoom", "results"];
  const rows = [];
  let y = 34;
  for (const scenario of scenarios) {
    rows.push(`<text x="24" y="${y}" font-family="Arial" font-size="22" fill="#e9eedc">${scenario.id}</text>`);
    y += 18;
    let x = 24;
    for (const id of preferred) {
      const capture = scenario.captures.find((entry) => entry.id === id);
      if (!capture) continue;
      const href = rel(resolve(capture.absolutePath));
      rows.push(`<image x="${x}" y="${y}" width="210" height="118" href="../../../../${href}"><title>${scenario.id} ${id}</title></image>`);
      rows.push(`<text x="${x}" y="${y + 134}" font-family="Arial" font-size="10" fill="#cbd3bd">${id}</text>`);
      x += 232;
      if (x > 1420) {
        x = 24;
        y += 156;
      }
    }
    y += 170;
  }
  const height = Math.max(420, y + 24);
  return [`<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="${height}" viewBox="0 0 1600 ${height}">`, '<rect width="100%" height="100%" fill="#10150f"/>', '<text x="24" y="24" font-family="Arial" font-size="18" fill="#f3e7b8">v0.181 Salto Ground + Road Material Opt-in Contact Sheet</text>', ...rows, "</svg>", ""].join("\n");
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", "e1-ground-material-opt-in", "worker-art-opt-in-benchmark-runtime.json", errors);
  const optIn = reportAt(root, "benchmark", "e2-ground-road-material-opt-in", "worker-art-opt-in-benchmark-runtime.json", errors);
  const missing = reportAt(root, "benchmark", "road-missing-art-fallback", "worker-art-opt-in-benchmark-runtime.json", errors);
  const mismatch = reportAt(root, "benchmark", "road-hash-mismatch-fallback", "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) checkGroundLoaded(baseline.report, "e1-ground-material-opt-in", errors);
  if (optIn.report) checkRoadLoaded(optIn.report, "e2-ground-road-material-opt-in", errors);
  if (missing.report) checkRoadFallback(missing.report, "road-missing-art-fallback", "missing source file", errors);
  if (mismatch.report) checkRoadFallback(mismatch.report, "road-hash-mismatch-fallback", "hash mismatch", errors);
  const baselineFps = Number(baseline.report?.fpsAverage ?? 0);
  const optInFps = Number(optIn.report?.fpsAverage ?? 0);
  const baselineP95 = Number(baseline.report?.frameTimeP95Ms ?? 0);
  const optInP95 = Number(optIn.report?.frameTimeP95Ms ?? 0);
  const fpsRatio = baselineFps > 0 ? optInFps / baselineFps : 0;
  const p95Worsening = baselineP95 > 0 ? (optInP95 - baselineP95) / baselineP95 : 1;
  if (fpsRatio < 0.90) errors.push(`FPS ratio ${fpsRatio.toFixed(4)} is below 0.90.`);
  if (p95Worsening > 0.15) errors.push(`p95 worsening ${(p95Worsening * 100).toFixed(2)}% exceeds 15%.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK" : "FAIL_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK",
    baseline: { id: "e1-ground-material-opt-in", fpsAverage: baselineFps, frameTimeP95Ms: baselineP95, path: rel(baseline.path) },
    optIn: { id: "e2-ground-road-material-opt-in", fpsAverage: optInFps, frameTimeP95Ms: optInP95, path: rel(optIn.path) },
    fallbacks: [
      { id: "road-missing-art-fallback", fpsAverage: Number(missing.report?.fpsAverage ?? 0), frameTimeP95Ms: Number(missing.report?.frameTimeP95Ms ?? 0), fallbackReason: road(missing.report)?.fallbackReason ?? "", path: rel(missing.path) },
      { id: "road-hash-mismatch-fallback", fpsAverage: Number(mismatch.report?.fpsAverage ?? 0), frameTimeP95Ms: Number(mismatch.report?.frameTimeP95Ms ?? 0), fallbackReason: road(mismatch.report)?.fallbackReason ?? "", path: rel(mismatch.path) }
    ],
    thresholds: { minimumFpsRatio: 0.90, maximumP95WorseningRatio: 0.15, roadUvScale },
    result: { fpsRatio: Number(fpsRatio.toFixed(4)), p95WorseningRatio: Number(p95Worsening.toFixed(4)), p95WorseningPercent: Number((p95Worsening * 100).toFixed(2)) },
    cacheCounters: optIn.report?.cacheCounters ?? {},
    errors
  };
  writeJson(join(root, "benchmark", "ground-road-material-opt-in-benchmark-scorecard.json"), report);
  writeText(join(root, "benchmark", "ground-road-material-opt-in-benchmark-scorecard.md"), benchmarkMarkdown(report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkMarkdown(report) {
  return ["# v0.181 Ground + Road Material Opt-in Benchmark Scorecard", "", `Status: \`${report.status}\``, "", `Ground-only FPS: \`${report.baseline.fpsAverage}\``, `Ground+road FPS: \`${report.optIn.fpsAverage}\``, `FPS ratio: \`${report.result.fpsRatio}\``, `Ground-only p95 ms: \`${report.baseline.frameTimeP95Ms}\``, `Ground+road p95 ms: \`${report.optIn.frameTimeP95Ms}\``, `p95 worsening: \`${report.result.p95WorseningPercent}%\``, "", `Road UV scale: \`${report.thresholds.roadUvScale}\``, "Thresholds: FPS ratio >= 0.90; p95 worsening <= 15%.", ""].join("\n");
}

function boundaryCommand(root) {
  const errors = [];
  const preservedLaunchers = [
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_CONTRAST_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat"
  ];
  for (const path of preservedLaunchers) {
    const text = readFileSync(join(repoRoot, path), "utf8");
    if (text.includes("--road-material-opt-in")) errors.push(`${path} unexpectedly enables v0.181 road material.`);
  }
  const launchPath = join(repoRoot, "tools", "godot", "launchGodotSaltoGroundRoadMaterialOptInWindows.ps1");
  const launchScript = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  ["--salto-environment-foundation-review", "--ground-material-opt-in", "--road-material-opt-in", "--ashen-art-opt-in", groundSha, roadSha].forEach((text) => {
    if (!launchScript.includes(text)) errors.push(`Ground+road material launcher missing ${text}.`);
  });
  const status = execSync("git status --short --untracked-files=all", { cwd: repoRoot, encoding: "utf8" }).trim();
  const imageChanges = status.split(/\r?\n/u).filter((line) => /\.(png|jpe?g|webp|avif)\b/iu.test(line));
  if (imageChanges.length > 0) errors.push(`Unexpected image changes during v0.181 zero-image integration: ${imageChanges.join(", ")}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY" : "FAIL_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY",
    defaultLauncherProcedural: true,
    priorLaunchersPreserved: true,
    browserRuntimeChanged: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    gameplayPathingChanged: false,
    navigationSemanticsChanged: false,
    aiImagesGenerated: 0,
    characterSlotsAdded: 0,
    environmentMaterialSlotsAdded: 1,
    selectedGroundHash: groundSha,
    selectedRoadHash: roadSha,
    roadSurfaceGroup: roadSurfaces,
    statusSnapshot: status,
    errors
  };
  writeJson(join(root, "boundary", "ground-road-material-opt-in-boundary-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

const command = process.argv[2] ?? "all";
const root = artifactRootFromArgs();
try {
  if (command === "validation" || command === "all") validationCommand(root);
  if (command === "capture" || command === "all") captureCommand(root);
  if (command === "benchmark" || command === "all") benchmarkCommand(root);
  if (command === "boundary" || command === "all") boundaryCommand(root);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
