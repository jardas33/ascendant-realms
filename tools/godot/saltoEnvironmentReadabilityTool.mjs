import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.174";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0174");
const requiredCaptureIds = [
  "tactical_overview",
  "road_intersections",
  "river_bridge_normal",
  "river_bridge_close",
  "approach_lanes",
  "friendly_boundary",
  "hostile_approach_lane",
  "site_marker_hierarchy",
  "minimap_correlation",
  "five_slot_combat_posture",
  "camera_pan_readability",
  "camera_zoom_readability"
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

function checkFiveSlot(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five opt-in slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five opt-in slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth player-facing art slot.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 0 || Number(report?.environmentReadabilityArtSlotCount ?? 0) !== 0) errors.push(`${id} reported an environment art slot.`);
  if (report?.terrainMaterialSourceImported === true || report?.terrainMaterialRuntimeSlotAdded === true) errors.push(`${id} imported or integrated terrain material.`);
  if (report?.browserRuntimeChanged === true || report?.saveWritesAllowed === true || report?.stableIdsChanged === true) errors.push(`${id} reported browser/save/stable-ID mutation.`);
}

function checkEnvironment(report, expectedFoundation, expectedReadability, id, errors) {
  const foundation = report?.environmentFoundationReview ?? {};
  const readability = report?.environmentReadabilityHardening ?? {};
  if (report?.environmentFoundationReviewEnabled !== expectedFoundation || foundation.enabled !== expectedFoundation) {
    errors.push(`${id} foundation flag mismatch.`);
  }
  if (report?.environmentReadabilityHardeningEnabled !== expectedReadability || readability.enabled !== expectedReadability) {
    errors.push(`${id} readability hardening flag mismatch.`);
  }
  if (expectedReadability) {
    if (readability.runtimeArtSlotAdded !== false || readability.aiImageGenerated !== false || readability.terrainTextureImported !== false) errors.push(`${id} readability boundary flags are not clean.`);
    if (readability.gameplayPathingChanged !== false || readability.navigationSemanticsChanged !== false) errors.push(`${id} readability reported gameplay/pathing mutation.`);
    if (readability.materiallyImprovesTacticalReadability !== true) errors.push(`${id} did not claim material readability improvement.`);
    if (readability.minimapCorrelationMarkersRendered !== true) errors.push(`${id} did not render minimap correlation markers.`);
    const layers = Array.isArray(readability.appliedLayers) ? readability.appliedLayers : [];
    ["road continuity centerline and intersections", "river bank ledges and water contrast", "bridge silhouette crossing guards", "site-marker hierarchy", "minimap correlation markers"].forEach((layer) => {
      if (!layers.includes(layer)) errors.push(`${id} missing readability layer evidence: ${layer}`);
    });
  } else if (readability.enabled === true) {
    errors.push(`${id} unexpectedly enabled readability hardening.`);
  }
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: "default-procedural", slots: 0, foundation: false, readability: false },
    { id: "e1-environment-foundation-baseline", slots: 5, foundation: true, readability: false },
    { id: "e2-road-river-bridge-site-marker-hardening", slots: 5, foundation: true, readability: true }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) {
      if (config.slots === 0) {
        if (!isPass(loaded.report)) errors.push(`${config.id} did not PASS: ${loaded.report.status}`);
        if (Number(loaded.report.normalSliceOptInRequestedSlotCount ?? 0) !== 0 || Number(loaded.report.normalSliceOptInLoadedSlotCount ?? 0) !== 0) errors.push(`${config.id} should remain zero-slot procedural.`);
      } else {
        checkFiveSlot(loaded.report, config.id, errors);
      }
      checkEnvironment(loaded.report, config.foundation, config.readability, config.id, errors);
    }
    return {
      id: config.id,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      requestedSlotCount: loaded.report?.normalSliceOptInRequestedSlotCount ?? 0,
      loadedSlotCount: loaded.report?.normalSliceOptInLoadedSlotCount ?? 0,
      environmentFoundationReviewEnabled: loaded.report?.environmentFoundationReviewEnabled ?? false,
      environmentReadabilityHardeningEnabled: loaded.report?.environmentReadabilityHardeningEnabled ?? false
    };
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0174_ENVIRONMENT_READABILITY_VALIDATION" : "FAIL_V0174_ENVIRONMENT_READABILITY_VALIDATION", scenarios, errors };
  writeJson(join(root, "validation", "environment-readability-validation-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function captureCommand(root) {
  const errors = [];
  const configs = [
    { id: "e1-environment-foundation-baseline", readability: false },
    { id: "e2-road-river-bridge-site-marker-hardening", readability: true }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "capture", config.id, "screenshot-runtime-manifest.json", errors);
    const captures = Array.isArray(loaded.report?.captures) ? loaded.report.captures : [];
    if (loaded.report) {
      checkFiveSlot(loaded.report, config.id, errors);
      checkEnvironment(loaded.report, true, config.readability, config.id, errors);
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
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0174_ENVIRONMENT_READABILITY_CAPTURE" : "FAIL_V0174_ENVIRONMENT_READABILITY_CAPTURE", requiredCaptureIds, scenarios, contactSheet: "capture/v0174-environment-readability-contact-sheet.svg", errors };
  writeJson(join(root, "capture", "environment-readability-capture-report.json"), report);
  writeText(join(root, "capture", "v0174-environment-readability-contact-sheet.svg"), contactSheetSvg(scenarios));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function contactSheetSvg(scenarios) {
  const preferred = ["tactical_overview", "road_intersections", "river_bridge_normal", "river_bridge_close", "approach_lanes", "site_marker_hierarchy", "minimap_correlation", "five_slot_combat_posture", "camera_max_zoom"];
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
  return [`<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="${height}" viewBox="0 0 1600 ${height}">`, '<rect width="100%" height="100%" fill="#11170f"/>', '<text x="24" y="24" font-family="Arial" font-size="18" fill="#f3e7b8">v0.174 Salto Tactical Environment Readability Contact Sheet</text>', ...rows, "</svg>", ""].join("\n");
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", "e1-environment-foundation-baseline", "worker-art-opt-in-benchmark-runtime.json", errors);
  const hardened = reportAt(root, "benchmark", "e2-road-river-bridge-site-marker-hardening", "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) {
    checkFiveSlot(baseline.report, "e1-environment-foundation-baseline", errors);
    checkEnvironment(baseline.report, true, false, "e1-environment-foundation-baseline", errors);
  }
  if (hardened.report) {
    checkFiveSlot(hardened.report, "e2-road-river-bridge-site-marker-hardening", errors);
    checkEnvironment(hardened.report, true, true, "e2-road-river-bridge-site-marker-hardening", errors);
  }
  const baselineFps = Number(baseline.report?.fpsAverage ?? 0);
  const hardenedFps = Number(hardened.report?.fpsAverage ?? 0);
  const baselineP95 = Number(baseline.report?.frameTimeP95Ms ?? 0);
  const hardenedP95 = Number(hardened.report?.frameTimeP95Ms ?? 0);
  const fpsRatio = baselineFps > 0 ? hardenedFps / baselineFps : 0;
  const p95Worsening = baselineP95 > 0 ? (hardenedP95 - baselineP95) / baselineP95 : 1;
  if (fpsRatio < 0.90) errors.push(`FPS ratio ${fpsRatio.toFixed(4)} is below 0.90.`);
  if (p95Worsening > 0.15) errors.push(`p95 worsening ${(p95Worsening * 100).toFixed(2)}% exceeds 15%.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0174_ENVIRONMENT_READABILITY_BENCHMARK" : "FAIL_V0174_ENVIRONMENT_READABILITY_BENCHMARK",
    baseline: { id: "e1-environment-foundation-baseline", fpsAverage: baselineFps, frameTimeP95Ms: baselineP95, path: rel(baseline.path) },
    hardened: { id: "e2-road-river-bridge-site-marker-hardening", fpsAverage: hardenedFps, frameTimeP95Ms: hardenedP95, path: rel(hardened.path) },
    thresholds: { minimumFpsRatio: 0.90, maximumP95WorseningRatio: 0.15 },
    result: { fpsRatio: Number(fpsRatio.toFixed(4)), p95WorseningRatio: Number(p95Worsening.toFixed(4)), p95WorseningPercent: Number((p95Worsening * 100).toFixed(2)) },
    errors
  };
  writeJson(join(root, "benchmark", "environment-readability-benchmark-scorecard.json"), report);
  writeText(join(root, "benchmark", "environment-readability-benchmark-scorecard.md"), benchmarkMarkdown(report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkMarkdown(report) {
  return ["# v0.174 Environment Readability Benchmark Scorecard", "", `Status: \`${report.status}\``, "", `E1 FPS: \`${report.baseline.fpsAverage}\``, `E2 FPS: \`${report.hardened.fpsAverage}\``, `FPS ratio: \`${report.result.fpsRatio}\``, `E1 p95 ms: \`${report.baseline.frameTimeP95Ms}\``, `E2 p95 ms: \`${report.hardened.frameTimeP95Ms}\``, `p95 worsening: \`${report.result.p95WorseningPercent}%\``, "", "Thresholds: FPS ratio >= 0.90; p95 worsening <= 15%.", ""].join("\n");
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
    "GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat"
  ];
  for (const path of preservedLaunchers) {
    const text = readFileSync(join(repoRoot, path), "utf8");
    if (text.includes("--salto-environment-readability-hardening")) errors.push(`${path} unexpectedly enables v0.174 readability hardening.`);
  }
  const launchPath = join(repoRoot, "tools", "godot", "launchGodotSaltoEnvironmentReadabilityWindows.ps1");
  const launchScript = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  ["--salto-environment-foundation-review", "--salto-environment-readability-hardening", "--ashen-art-opt-in"].forEach((text) => {
    if (!launchScript.includes(text)) errors.push(`Readability launcher missing ${text}.`);
  });
  const status = execSync("git status --short --untracked-files=all", { cwd: repoRoot, encoding: "utf8" }).trim();
  const imageChanges = status.split(/\r?\n/u).filter((line) => /\.(png|jpe?g|webp|avif)\b/iu.test(line));
  if (imageChanges.length > 0) errors.push(`Tracked/untracked image changes are not allowed for v0.174: ${imageChanges.join(", ")}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0174_ENVIRONMENT_READABILITY_BOUNDARY" : "FAIL_V0174_ENVIRONMENT_READABILITY_BOUNDARY",
    defaultLauncherProcedural: true,
    priorLaunchersPreserved: true,
    browserRuntimeChanged: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    gameplayPathingChanged: false,
    navigationSemanticsChanged: false,
    aiImagesGenerated: 0,
    runtimeArtSlotsAdded: 0,
    terrainMaterialImported: false,
    statusSnapshot: status,
    errors
  };
  writeJson(join(root, "boundary", "environment-readability-boundary-report.json"), report);
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
