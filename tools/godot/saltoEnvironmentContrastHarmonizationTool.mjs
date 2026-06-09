import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.179";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0179");
const selectedSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const selectedSlot = "barrosan_foothold_ground_material_v0175";
const hardenedUvScale = 0.56;
const requiredCaptureIds = [
  "tactical_overview",
  "road_intersections",
  "river_banks",
  "bridge_crossing",
  "site_marker_hierarchy",
  "mine_barracks_approach",
  "hostile_approach_lane",
  "five_slot_combat_posture",
  "camera_pan_readability",
  "camera_min_zoom",
  "camera_max_zoom",
  "minimap_correlation",
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

function contrast(report) {
  return report?.environmentContrastHarmonization ?? {};
}

function checkFiveSlot(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five frozen character/material slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character/material slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported an extra character slot.`);
  if (report?.browserRuntimeChanged === true || report?.saveWritesAllowed === true || report?.stableIdsChanged === true) errors.push(`${id} reported browser/save/stable-ID mutation.`);
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0 || Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 0) errors.push(`${id} should remain zero-slot procedural.`);
  if (report?.environmentFoundationReviewEnabled === true || report?.environmentContrastHarmonizationEnabled === true) errors.push(`${id} unexpectedly enabled an environment review posture.`);
  if (report?.groundMaterialOptInRequested === true || ground(report).enabled === true) errors.push(`${id} unexpectedly requested ground material.`);
}

function checkGroundLoaded(report, id, errors) {
  checkFiveSlot(report, id, errors);
  const g = ground(report);
  if (report?.environmentFoundationReviewEnabled !== true || report?.environmentFoundationReview?.enabled !== true) errors.push(`${id} did not enable environment foundation.`);
  if (report?.environmentReadabilityHardeningEnabled === true) errors.push(`${id} unexpectedly enabled v0.174 readability hardening.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 1 || Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 1) errors.push(`${id} did not report exactly one existing ground-material environment slot.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 1) errors.push(`${id} did not load the selected ground material.`);
  if (report?.terrainMaterialSourceImported !== true || report?.terrainMaterialRuntimeSlotAdded !== true) errors.push(`${id} did not report terrain material imported and runtime-added under opt-in.`);
  if (g.slotId !== selectedSlot || g.expectedSha256 !== selectedSha || g.actualSha256 !== selectedSha) errors.push(`${id} ground material identity/hash mismatch.`);
  if (g.sourceLoaded !== true || g.materialActive !== true || g.fallbackActive !== false) errors.push(`${id} ground material is not active.`);
  if (Math.abs(Number(g.uvScale ?? 0) - hardenedUvScale) > 0.001) errors.push(`${id} ground UV scale is not ${hardenedUvScale}.`);
}

function checkPriorGround(report, id, errors) {
  checkGroundLoaded(report, id, errors);
  if (report?.environmentContrastHarmonizationEnabled === true || contrast(report).enabled === true) errors.push(`${id} unexpectedly enabled v0.179 contrast harmonization.`);
}

function checkContrastLoaded(report, id, errors) {
  checkGroundLoaded(report, id, errors);
  const c = contrast(report);
  if (report?.environmentContrastHarmonizationEnabled !== true || c.enabled !== true) errors.push(`${id} did not enable v0.179 contrast harmonization.`);
  if (c.checkpoint !== checkpoint || c.reviewOnly !== true) errors.push(`${id} contrast status did not report v0.179 review-only posture.`);
  if (c.runtimeArtSlotAdded !== false || c.aiImageGenerated !== false || c.newTextureImported !== false || c.terrainTextureImportedByHarmonization !== false) errors.push(`${id} contrast status reported a forbidden new art/texture addition.`);
  if (c.gameplayPathingChanged !== false || c.navigationSemanticsChanged !== false || c.saveWritesAllowed !== false || c.stableIdsChanged !== false) errors.push(`${id} contrast status reported gameplay/navigation/save/stable-ID mutation.`);
  if (c.materiallyImprovesTacticalReadability !== true) errors.push(`${id} did not report tactical readability improvement.`);
  if (c.minimapCorrelationMarkersRendered !== true) errors.push(`${id} did not render minimap correlation markers.`);
}

function checkContrastFallback(report, id, expectedReasonFragment, errors) {
  checkFiveSlot(report, id, errors);
  const g = ground(report);
  const c = contrast(report);
  if (report?.environmentFoundationReviewEnabled !== true || report?.environmentContrastHarmonizationEnabled !== true || c.enabled !== true) errors.push(`${id} did not keep foundation plus contrast active while falling back.`);
  if (report?.environmentReadabilityHardeningEnabled === true) errors.push(`${id} unexpectedly enabled v0.174 readability hardening.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 1 || Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 1) errors.push(`${id} should still request the existing single ground-material slot.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 0 || report?.terrainMaterialSourceImported === true) errors.push(`${id} should not import the material in fallback.`);
  if (g.enabled !== true || g.sourceLoaded !== false || g.materialActive !== false || g.fallbackActive !== true || g.proceduralFallbackVisible !== true) errors.push(`${id} did not activate procedural ground fallback.`);
  if (!String(g.fallbackReason ?? "").includes(expectedReasonFragment)) errors.push(`${id} fallback reason did not include '${expectedReasonFragment}'.`);
  if (c.runtimeArtSlotAdded !== false || c.aiImageGenerated !== false || c.newTextureImported !== false) errors.push(`${id} contrast fallback reported a forbidden art addition.`);
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: "default-procedural", check: checkDefault },
    { id: "e1-prior-ground-material-opt-in", check: checkPriorGround },
    { id: "e2-environment-contrast-harmonized", check: checkContrastLoaded },
    { id: "ground-missing-art-contrast-fallback", check: (report, id, errs) => checkContrastFallback(report, id, "missing source file", errs) },
    { id: "ground-hash-mismatch-contrast-fallback", check: (report, id, errs) => checkContrastFallback(report, id, "hash mismatch", errs) }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return { id: config.id, path: rel(loaded.path), status: loaded.report?.status ?? "MISSING", contrastEnabled: contrast(loaded.report).enabled ?? false, groundLoaded: ground(loaded.report).sourceLoaded ?? false, groundFallbackActive: ground(loaded.report).fallbackActive ?? false };
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_VALIDATION" : "FAIL_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_VALIDATION", selectedSha, selectedSlot, scenarios, errors };
  writeJson(join(root, "validation", "environment-contrast-harmonization-validation-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function captureCommand(root) {
  const errors = [];
  const configs = [
    { id: "e1-prior-ground-material-opt-in", check: checkPriorGround },
    { id: "e2-environment-contrast-harmonized", check: checkContrastLoaded },
    { id: "ground-missing-art-contrast-fallback", check: (report, id, errs) => checkContrastFallback(report, id, "missing source file", errs) },
    { id: "ground-hash-mismatch-contrast-fallback", check: (report, id, errs) => checkContrastFallback(report, id, "hash mismatch", errs) }
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
    return { id: config.id, path: rel(loaded.path), status: loaded.report?.status ?? "MISSING", captureCount: loaded.report?.captureCount ?? 0, captures: captures.map((capture) => ({ id: capture.id, fileName: capture.fileName, label: capture.label, absolutePath: capture.absolutePath })) };
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_CAPTURE" : "FAIL_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_CAPTURE", requiredCaptureIds, scenarios, contactSheet: "capture/v0179-environment-contrast-harmonization-contact-sheet.svg", errors };
  writeJson(join(root, "capture", "environment-contrast-harmonization-capture-report.json"), report);
  writeText(join(root, "capture", "v0179-environment-contrast-harmonization-contact-sheet.svg"), contactSheetSvg(scenarios));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function contactSheetSvg(scenarios) {
  const preferred = ["tactical_overview", "road_intersections", "river_banks", "bridge_crossing", "site_marker_hierarchy", "five_slot_combat_posture", "camera_max_zoom", "minimap_correlation"];
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
      rows.push(`<image x="${x}" y="${y}" width="184" height="104" href="../../../../${href}"><title>${scenario.id} ${id}</title></image>`);
      rows.push(`<text x="${x}" y="${y + 120}" font-family="Arial" font-size="10" fill="#cbd3bd">${id}</text>`);
      x += 204;
      if (x > 1480) {
        x = 24;
        y += 142;
      }
    }
    y += 154;
  }
  const height = Math.max(420, y + 24);
  return [`<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="${height}" viewBox="0 0 1600 ${height}">`, '<rect width="100%" height="100%" fill="#10150f"/>', '<text x="24" y="24" font-family="Arial" font-size="18" fill="#f3e7b8">v0.179 Environment Contrast Harmonization Contact Sheet</text>', ...rows, "</svg>", ""].join("\n");
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", "e1-prior-ground-material-opt-in", "worker-art-opt-in-benchmark-runtime.json", errors);
  const optIn = reportAt(root, "benchmark", "e2-environment-contrast-harmonized", "worker-art-opt-in-benchmark-runtime.json", errors);
  const missing = reportAt(root, "benchmark", "ground-missing-art-contrast-fallback", "worker-art-opt-in-benchmark-runtime.json", errors);
  const mismatch = reportAt(root, "benchmark", "ground-hash-mismatch-contrast-fallback", "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) checkPriorGround(baseline.report, "e1-prior-ground-material-opt-in", errors);
  if (optIn.report) checkContrastLoaded(optIn.report, "e2-environment-contrast-harmonized", errors);
  if (missing.report) checkContrastFallback(missing.report, "ground-missing-art-contrast-fallback", "missing source file", errors);
  if (mismatch.report) checkContrastFallback(mismatch.report, "ground-hash-mismatch-contrast-fallback", "hash mismatch", errors);
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
    status: errors.length === 0 ? "PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_BENCHMARK" : "FAIL_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_BENCHMARK",
    baseline: { id: "e1-prior-ground-material-opt-in", fpsAverage: baselineFps, frameTimeP95Ms: baselineP95, path: rel(baseline.path) },
    optIn: { id: "e2-environment-contrast-harmonized", fpsAverage: optInFps, frameTimeP95Ms: optInP95, path: rel(optIn.path) },
    fallbacks: [
      { id: "ground-missing-art-contrast-fallback", fpsAverage: Number(missing.report?.fpsAverage ?? 0), frameTimeP95Ms: Number(missing.report?.frameTimeP95Ms ?? 0), fallbackReason: ground(missing.report)?.fallbackReason ?? "", path: rel(missing.path) },
      { id: "ground-hash-mismatch-contrast-fallback", fpsAverage: Number(mismatch.report?.fpsAverage ?? 0), frameTimeP95Ms: Number(mismatch.report?.frameTimeP95Ms ?? 0), fallbackReason: ground(mismatch.report)?.fallbackReason ?? "", path: rel(mismatch.path) }
    ],
    thresholds: { minimumFpsRatio: 0.90, maximumP95WorseningRatio: 0.15 },
    result: { fpsRatio: Number(fpsRatio.toFixed(4)), p95WorseningRatio: Number(p95Worsening.toFixed(4)), p95WorseningPercent: Number((p95Worsening * 100).toFixed(2)) },
    errors
  };
  writeJson(join(root, "benchmark", "environment-contrast-harmonization-benchmark-scorecard.json"), report);
  writeText(join(root, "benchmark", "environment-contrast-harmonization-benchmark-scorecard.md"), benchmarkMarkdown(report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkMarkdown(report) {
  return ["# v0.179 Environment Contrast Harmonization Benchmark", "", `Status: \`${report.status}\``, "", `E1 FPS: \`${report.baseline.fpsAverage}\``, `E2 FPS: \`${report.optIn.fpsAverage}\``, `FPS ratio: \`${report.result.fpsRatio}\``, `E1 p95 ms: \`${report.baseline.frameTimeP95Ms}\``, `E2 p95 ms: \`${report.optIn.frameTimeP95Ms}\``, `p95 worsening: \`${report.result.p95WorseningPercent}%\``, "", "Thresholds: FPS ratio >= 0.90; p95 worsening <= 15%.", ""].join("\n");
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
    "GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat"
  ];
  for (const path of preservedLaunchers) {
    const text = readFileSync(join(repoRoot, path), "utf8");
    if (text.includes("--salto-environment-contrast-harmonization")) errors.push(`${path} unexpectedly enables v0.179 contrast harmonization.`);
  }
  const launchPath = join(repoRoot, "tools", "godot", "launchGodotSaltoEnvironmentContrastWindows.ps1");
  const launchScript = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  ["--salto-environment-foundation-review", "--salto-environment-contrast-harmonization", "--ground-material-opt-in", "--ashen-art-opt-in", selectedSha].forEach((text) => {
    if (!launchScript.includes(text)) errors.push(`Environment contrast launcher missing ${text}.`);
  });
  if (launchScript.includes("--salto-environment-readability-hardening")) errors.push("Environment contrast launcher should not enable v0.174 readability hardening.");
  const status = execSync("git status --short --untracked-files=all", { cwd: repoRoot, encoding: "utf8" }).trim();
  const imageChanges = status.split(/\r?\n/u).filter((line) => /\.(png|jpe?g|webp|avif)\b/iu.test(line) && !line.includes("v0179"));
  if (imageChanges.length > 0) errors.push(`Unexpected non-v0.179 image changes: ${imageChanges.join(", ")}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_BOUNDARY" : "FAIL_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_BOUNDARY",
    defaultLauncherProcedural: true,
    priorLaunchersPreserved: true,
    browserRuntimeChanged: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    gameplayPathingChanged: false,
    navigationSemanticsChanged: false,
    aiImagesGenerated: 0,
    runtimeCharacterSlotsAdded: 0,
    newEnvironmentMaterialSlotsAddedByHarmonization: 0,
    selectedGroundMaterialHash: selectedSha,
    statusSnapshot: status,
    errors
  };
  writeJson(join(root, "boundary", "environment-contrast-harmonization-boundary-report.json"), report);
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
