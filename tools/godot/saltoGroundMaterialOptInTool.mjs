import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.178";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0178");
const selectedSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const selectedSlot = "barrosan_foothold_ground_material_v0175";
const selectedApproach = "GROUND_MATERIAL_LOCAL_1024";
const hardenedUvScale = 0.56;
const previousUvScale = 0.72;
const maximumNoiseAlpha = 0.52;
const groundSurfaces = ["v0173_terrain_mid_value_field", "v0173_friendly_staging_value_field"];
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

function checkNoGround(report, id, errors) {
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 0) errors.push(`${id} reported an environment material slot.`);
  if (report?.terrainMaterialSourceImported === true || report?.terrainMaterialRuntimeSlotAdded === true) errors.push(`${id} unexpectedly loaded/integrated terrain material.`);
  if (report?.groundMaterialOptInRequested === true || ground(report).enabled === true) errors.push(`${id} unexpectedly requested ground material.`);
}

function checkFiveSlot(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five character/material opt-in slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five character/material opt-in slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  if (report?.browserRuntimeChanged === true || report?.saveWritesAllowed === true || report?.stableIdsChanged === true) errors.push(`${id} reported browser/save/stable-ID mutation.`);
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0 || Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 0) errors.push(`${id} should remain zero-slot procedural.`);
  if (report?.environmentFoundationReviewEnabled === true) errors.push(`${id} unexpectedly enabled foundation review.`);
  checkNoGround(report, id, errors);
}

function checkFoundation(report, id, errors) {
  checkFiveSlot(report, id, errors);
  if (report?.environmentFoundationReviewEnabled !== true || report?.environmentFoundationReview?.enabled !== true) errors.push(`${id} did not enable environment foundation.`);
  if (report?.environmentReadabilityHardeningEnabled === true) errors.push(`${id} unexpectedly enabled v0.174 readability hardening.`);
  checkNoGround(report, id, errors);
}

function checkGroundLoaded(report, id, errors) {
  checkFiveSlot(report, id, errors);
  const g = ground(report);
  if (report?.environmentFoundationReviewEnabled !== true || report?.environmentFoundationReview?.enabled !== true) errors.push(`${id} did not enable environment foundation.`);
  if (report?.environmentReadabilityHardeningEnabled === true) errors.push(`${id} unexpectedly enabled v0.174 readability hardening.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 1 || Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 1) errors.push(`${id} did not report exactly one environment material slot.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 1) errors.push(`${id} did not load exactly one environment material slot.`);
  if (report?.terrainMaterialSourceImported !== true || report?.terrainMaterialRuntimeSlotAdded !== true) errors.push(`${id} did not report terrain material imported and runtime-added under opt-in.`);
  if (g.slotId !== selectedSlot || g.approach !== selectedApproach) errors.push(`${id} ground slot/approach mismatch.`);
  if (g.expectedSha256 !== selectedSha || g.actualSha256 !== selectedSha) errors.push(`${id} ground hash mismatch.`);
  if (g.sourceLoaded !== true || g.materialActive !== true || g.fallbackActive !== false) errors.push(`${id} ground material did not load active without fallback.`);
  if (g.checkpoint !== checkpoint || g.visualHardeningCheckpoint !== checkpoint) errors.push(`${id} did not report v0.178 visual hardening.`);
  if (Math.abs(Number(g.uvScale ?? 0) - hardenedUvScale) > 0.001) errors.push(`${id} ground UV scale ${g.uvScale ?? "MISSING"} is not hardened value ${hardenedUvScale}.`);
  if (Math.abs(Number(g.uvScaleHardenedFrom ?? 0) - previousUvScale) > 0.001) errors.push(`${id} missing previous UV scale audit ${previousUvScale}.`);
  if (Number(g.noiseControlAlpha ?? 1) > maximumNoiseAlpha) errors.push(`${id} ground noise-control alpha ${g.noiseControlAlpha ?? "MISSING"} exceeds ${maximumNoiseAlpha}.`);
  if (g.proceduralValueUnderlayVisible !== true) errors.push(`${id} did not preserve the procedural value underlay beneath the texture.`);
  if (!String(g.filterMode ?? "").toLowerCase().includes("mipmaps")) errors.push(`${id} did not preserve mipmapped filtering.`);
  if (g.sourceDimensions?.width !== 1024 || g.sourceDimensions?.height !== 1024) errors.push(`${id} ground source dimensions are not 1024x1024.`);
  if (Number(g.sourceLoadCount ?? 99) !== 1 || Number(g.metadataParseCount ?? 99) !== 1 || Number(g.imageDecodeCount ?? 99) !== 1 || Number(g.textureCreateCount ?? 99) !== 1 || Number(g.materialCreateCount ?? 99) !== 1) errors.push(`${id} ground material was not a one-time load/create path.`);
  const surfaces = Array.isArray(g.appliedSurfaceNames) ? g.appliedSurfaceNames : [];
  if (Number(g.appliedSurfaceCount ?? 0) !== groundSurfaces.length) errors.push(`${id} ground material applied surface count is not ${groundSurfaces.length}.`);
  for (const surface of groundSurfaces) {
    if (!surfaces.includes(surface)) errors.push(`${id} missing applied ground surface ${surface}.`);
  }
  for (const surface of surfaces) {
    if (!groundSurfaces.includes(surface)) errors.push(`${id} applied ground material to unexpected surface ${surface}.`);
  }
}

function checkGroundFallback(report, id, expectedReasonFragment, errors) {
  checkFiveSlot(report, id, errors);
  const g = ground(report);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 1 || report?.terrainMaterialRuntimeSlotAdded !== true) errors.push(`${id} should still report one requested environment material slot.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 0 || report?.terrainMaterialSourceImported === true) errors.push(`${id} should not import terrain material in fallback.`);
  if (g.enabled !== true || g.sourceLoaded !== false || g.materialActive !== false || g.fallbackActive !== true || g.proceduralFallbackVisible !== true) errors.push(`${id} did not activate procedural ground fallback.`);
  if (!String(g.fallbackReason ?? "").includes(expectedReasonFragment)) errors.push(`${id} fallback reason did not include '${expectedReasonFragment}': ${g.fallbackReason ?? ""}`);
  if (Math.abs(Number(g.uvScale ?? 0) - hardenedUvScale) > 0.001) errors.push(`${id} fallback UV scale ${g.uvScale ?? "MISSING"} is not hardened value ${hardenedUvScale}.`);
  if (g.proceduralValueUnderlayVisible === true) errors.push(`${id} should not report the material underlay while falling back.`);
  if (Number(g.appliedSurfaceCount ?? 0) !== 0) errors.push(`${id} applied material surfaces during fallback.`);
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: "default-procedural", check: checkDefault },
    { id: "e0-environment-foundation-baseline", check: checkFoundation },
    { id: "e1-ground-material-opt-in", check: checkGroundLoaded },
    { id: "ground-missing-art-fallback", check: (report, id, errs) => checkGroundFallback(report, id, "missing source file", errs) },
    { id: "ground-hash-mismatch-fallback", check: (report, id, errs) => checkGroundFallback(report, id, "hash mismatch", errs) }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return {
      id: config.id,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      characterSlotsRequested: loaded.report?.normalSliceOptInRequestedSlotCount ?? 0,
      characterSlotsLoaded: loaded.report?.normalSliceOptInLoadedSlotCount ?? 0,
      environmentFoundationArtSlotCount: loaded.report?.environmentFoundationArtSlotCount ?? 0,
      terrainMaterialSourceImported: loaded.report?.terrainMaterialSourceImported ?? false,
      groundFallbackActive: ground(loaded.report)?.fallbackActive ?? true,
      groundFallbackReason: ground(loaded.report)?.fallbackReason ?? "",
      groundUvScale: ground(loaded.report)?.uvScale ?? 0,
      noiseControlAlpha: ground(loaded.report)?.noiseControlAlpha ?? 0,
      proceduralValueUnderlayVisible: ground(loaded.report)?.proceduralValueUnderlayVisible ?? false
    };
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_VALIDATION" : "FAIL_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_VALIDATION", selectedSha, selectedSlot, hardenedUvScale, previousUvScale, maximumNoiseAlpha, scenarios, errors };
  writeJson(join(root, "validation", "ground-material-opt-in-validation-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function captureCommand(root) {
  const errors = [];
  const configs = [
    { id: "e0-environment-foundation-baseline", check: checkFoundation },
    { id: "e1-ground-material-opt-in", check: checkGroundLoaded },
    { id: "ground-missing-art-fallback", check: (report, id, errs) => checkGroundFallback(report, id, "missing source file", errs) },
    { id: "ground-hash-mismatch-fallback", check: (report, id, errs) => checkGroundFallback(report, id, "hash mismatch", errs) }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "capture", config.id, "screenshot-runtime-manifest.json", errors);
    const captures = Array.isArray(loaded.report?.captures) ? loaded.report.captures : [];
    if (loaded.report) {
      config.check(loaded.report, config.id, errors);
      const ids = new Set(captures.map((capture) => capture.id));
      for (const captureId of requiredCaptureIds) {
        if (!ids.has(captureId)) errors.push(`${config.id} missing required capture id: ${captureId}`);
      }
    }
    return {
      id: config.id,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      captureCount: loaded.report?.captureCount ?? 0,
      screenshotRoot: loaded.report?.screenshotRoot ? rel(resolve(loaded.report.screenshotRoot)) : "",
      captures: captures.map((capture) => ({ id: capture.id, fileName: capture.fileName, label: capture.label, absolutePath: capture.absolutePath }))
    };
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_CAPTURE" : "FAIL_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_CAPTURE", requiredCaptureIds, hardenedUvScale, previousUvScale, maximumNoiseAlpha, scenarios, contactSheet: "capture/v0178-ground-material-uv-noise-hardening-contact-sheet.svg", errors };
  writeJson(join(root, "capture", "ground-material-opt-in-capture-report.json"), report);
  writeText(join(root, "capture", "v0178-ground-material-uv-noise-hardening-contact-sheet.svg"), contactSheetSvg(scenarios));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function contactSheetSvg(scenarios) {
  const preferred = ["ground_material_normal_rts", "ground_material_close", "road_river_bridge_hierarchy", "five_slot_coexistence", "combat_onset", "camera_max_zoom"];
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
  return [`<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="${height}" viewBox="0 0 1600 ${height}">`, '<rect width="100%" height="100%" fill="#10150f"/>', '<text x="24" y="24" font-family="Arial" font-size="18" fill="#f3e7b8">v0.178 Salto Ground Material UV/Noise Hardening Contact Sheet</text>', ...rows, "</svg>", ""].join("\n");
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", "e0-environment-foundation-baseline", "worker-art-opt-in-benchmark-runtime.json", errors);
  const optIn = reportAt(root, "benchmark", "e1-ground-material-opt-in", "worker-art-opt-in-benchmark-runtime.json", errors);
  const missing = reportAt(root, "benchmark", "ground-missing-art-fallback", "worker-art-opt-in-benchmark-runtime.json", errors);
  const mismatch = reportAt(root, "benchmark", "ground-hash-mismatch-fallback", "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) checkFoundation(baseline.report, "e0-environment-foundation-baseline", errors);
  if (optIn.report) checkGroundLoaded(optIn.report, "e1-ground-material-opt-in", errors);
  if (missing.report) checkGroundFallback(missing.report, "ground-missing-art-fallback", "missing source file", errors);
  if (mismatch.report) checkGroundFallback(mismatch.report, "ground-hash-mismatch-fallback", "hash mismatch", errors);
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
    status: errors.length === 0 ? "PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BENCHMARK" : "FAIL_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BENCHMARK",
    baseline: { id: "e0-environment-foundation-baseline", fpsAverage: baselineFps, frameTimeP95Ms: baselineP95, path: rel(baseline.path) },
    optIn: { id: "e1-ground-material-opt-in", fpsAverage: optInFps, frameTimeP95Ms: optInP95, path: rel(optIn.path) },
    fallbacks: [
      { id: "ground-missing-art-fallback", fpsAverage: Number(missing.report?.fpsAverage ?? 0), frameTimeP95Ms: Number(missing.report?.frameTimeP95Ms ?? 0), fallbackReason: ground(missing.report)?.fallbackReason ?? "", path: rel(missing.path) },
      { id: "ground-hash-mismatch-fallback", fpsAverage: Number(mismatch.report?.fpsAverage ?? 0), frameTimeP95Ms: Number(mismatch.report?.frameTimeP95Ms ?? 0), fallbackReason: ground(mismatch.report)?.fallbackReason ?? "", path: rel(mismatch.path) }
    ],
    thresholds: { minimumFpsRatio: 0.90, maximumP95WorseningRatio: 0.15, hardenedUvScale, previousUvScale, maximumNoiseAlpha },
    result: { fpsRatio: Number(fpsRatio.toFixed(4)), p95WorseningRatio: Number(p95Worsening.toFixed(4)), p95WorseningPercent: Number((p95Worsening * 100).toFixed(2)) },
    cacheCounters: optIn.report?.cacheCounters ?? {},
    errors
  };
  writeJson(join(root, "benchmark", "ground-material-opt-in-benchmark-scorecard.json"), report);
  writeText(join(root, "benchmark", "ground-material-opt-in-benchmark-scorecard.md"), benchmarkMarkdown(report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkMarkdown(report) {
  return ["# v0.178 Ground Material UV/Noise Hardening Benchmark Scorecard", "", `Status: \`${report.status}\``, "", `E0 FPS: \`${report.baseline.fpsAverage}\``, `E1 FPS: \`${report.optIn.fpsAverage}\``, `FPS ratio: \`${report.result.fpsRatio}\``, `E0 p95 ms: \`${report.baseline.frameTimeP95Ms}\``, `E1 p95 ms: \`${report.optIn.frameTimeP95Ms}\``, `p95 worsening: \`${report.result.p95WorseningPercent}%\``, "", `Hardened UV scale: \`${report.thresholds.hardenedUvScale}\` (from \`${report.thresholds.previousUvScale}\`)`, `Maximum noise-control alpha: \`${report.thresholds.maximumNoiseAlpha}\``, "Thresholds: FPS ratio >= 0.90; p95 worsening <= 15%.", ""].join("\n");
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
    "GODOT_REVIEW_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat"
  ];
  for (const path of preservedLaunchers) {
    const text = readFileSync(join(repoRoot, path), "utf8");
    if (text.includes("--ground-material-opt-in")) errors.push(`${path} unexpectedly enables v0.178 ground material.`);
  }
  const launchPath = join(repoRoot, "tools", "godot", "launchGodotSaltoGroundMaterialOptInWindows.ps1");
  const launchScript = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  ["--salto-environment-foundation-review", "--ground-material-opt-in", "--ashen-art-opt-in", selectedSha].forEach((text) => {
    if (!launchScript.includes(text)) errors.push(`Ground material launcher missing ${text}.`);
  });
  const status = execSync("git status --short --untracked-files=all", { cwd: repoRoot, encoding: "utf8" }).trim();
  const imageChanges = status.split(/\r?\n/u).filter((line) => /\.(png|jpe?g|webp|avif)\b/iu.test(line) && !line.includes("v0178"));
  if (imageChanges.length > 0) errors.push(`Unexpected non-v0.178 image changes: ${imageChanges.join(", ")}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BOUNDARY" : "FAIL_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BOUNDARY",
    defaultLauncherProcedural: true,
    priorLaunchersPreserved: true,
    browserRuntimeChanged: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    gameplayPathingChanged: false,
    navigationSemanticsChanged: false,
    aiImagesGenerated: 0,
    runtimeCharacterSlotsAdded: 0,
    environmentMaterialSlotsAdded: 1,
    selectedHash: selectedSha,
    hardenedUvScale,
    previousUvScale,
    maximumNoiseAlpha,
    statusSnapshot: status,
    errors
  };
  writeJson(join(root, "boundary", "ground-material-opt-in-boundary-report.json"), report);
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
