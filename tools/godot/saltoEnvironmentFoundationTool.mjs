import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.173";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0173");
const requiredCaptureIds = [
  "battle_default_full_battlefield",
  "road_network",
  "river_banks",
  "bridge_crossing",
  "mine_uncaptured",
  "mine_converted",
  "barracks_restoration",
  "barracks_restored",
  "command_hall",
  "site_markers",
  "five_slot_coexistence",
  "combat_posture",
  "minimap",
  "pan_camera",
  "zoom_camera",
  "camera_min_zoom",
  "camera_max_zoom"
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

function checkCommonFiveSlot(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five existing opt-in slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five existing opt-in slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth player-facing art slot.`);
  if (Number(report?.environmentFoundationArtSlotCount ?? 0) !== 0) errors.push(`${id} reported an environment art slot.`);
  if (report?.terrainMaterialSourceImported === true || report?.terrainMaterialRuntimeSlotAdded === true) errors.push(`${id} imported or integrated a terrain material.`);
  if (report?.browserRuntimeChanged === true || report?.saveWritesAllowed === true || report?.stableIdsChanged === true) {
    errors.push(`${id} reported browser/save/stable-ID boundary mutation.`);
  }
}

function checkEnvironmentPosture(report, expectedEnabled, id, errors) {
  const review = report?.environmentFoundationReview ?? {};
  if (report?.environmentFoundationReviewEnabled !== expectedEnabled || review.enabled !== expectedEnabled) {
    errors.push(`${id} environment foundation enabled flag mismatch.`);
  }
  if (expectedEnabled) {
    if (review.runtimeArtSlotAdded !== false || review.aiImageGenerated !== false || review.terrainTextureImported !== false) {
      errors.push(`${id} environment foundation boundary flags are not clean.`);
    }
    const layers = Array.isArray(review.appliedLayers) ? review.appliedLayers : [];
    ["terrain value hierarchy", "main road shoulders and edge ticks", "river bank contrast and water reads", "bridge deck silhouette"].forEach((layer) => {
      if (!layers.includes(layer)) errors.push(`${id} missing environment layer evidence: ${layer}`);
    });
  }
}

function validationCommand(root) {
  const errors = [];
  const scenarios = [
    { id: "default-procedural", expectedEnvironment: false, expectedSlots: 0 },
    { id: "m5-five-slot-baseline", expectedEnvironment: false, expectedSlots: 5 },
    { id: "e1-environment-foundation", expectedEnvironment: true, expectedSlots: 5 }
  ].map((scenario) => {
    const loaded = reportAt(root, "validation", scenario.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) {
      if (scenario.expectedSlots === 0) {
        if (!isPass(loaded.report)) errors.push(`${scenario.id} did not PASS: ${loaded.report.status}`);
        if (Number(loaded.report.normalSliceOptInRequestedSlotCount ?? 0) !== 0 || Number(loaded.report.normalSliceOptInLoadedSlotCount ?? 0) !== 0) {
          errors.push(`${scenario.id} should remain zero-slot procedural.`);
        }
      } else {
        checkCommonFiveSlot(loaded.report, scenario.id, errors);
      }
      checkEnvironmentPosture(loaded.report, scenario.expectedEnvironment, scenario.id, errors);
    }
    return {
      id: scenario.id,
      expectedEnvironment: scenario.expectedEnvironment,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      requestedSlotCount: loaded.report?.normalSliceOptInRequestedSlotCount ?? 0,
      loadedSlotCount: loaded.report?.normalSliceOptInLoadedSlotCount ?? 0,
      environmentFoundationReviewEnabled: loaded.report?.environmentFoundationReviewEnabled ?? false
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0173_ENVIRONMENT_FOUNDATION_VALIDATION" : "FAIL_V0173_ENVIRONMENT_FOUNDATION_VALIDATION",
    scenarios,
    errors
  };
  writeJson(join(root, "validation", "environment-foundation-validation-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function captureCommand(root) {
  const errors = [];
  const scenarios = ["m5-five-slot-baseline", "e1-environment-foundation"].map((id) => {
    const loaded = reportAt(root, "capture", id, "screenshot-runtime-manifest.json", errors);
    const captures = Array.isArray(loaded.report?.captures) ? loaded.report.captures : [];
    if (loaded.report) {
      checkCommonFiveSlot(loaded.report, id, errors);
      checkEnvironmentPosture(loaded.report, id === "e1-environment-foundation", id, errors);
      if (captures.length < Number(loaded.report.requiredCaptureCount ?? requiredCaptureIds.length)) errors.push(`${id} did not emit all required screenshots.`);
      const ids = new Set(captures.map((capture) => capture.id));
      for (const captureId of requiredCaptureIds) {
        if (!ids.has(captureId)) errors.push(`${id} missing required capture id: ${captureId}`);
      }
    }
    return {
      id,
      path: rel(loaded.path),
      status: loaded.report?.status ?? "MISSING",
      captureCount: loaded.report?.captureCount ?? 0,
      screenshotRoot: loaded.report?.screenshotRoot ? rel(resolve(loaded.report.screenshotRoot)) : "",
      captures: captures.map((capture) => ({
        id: capture.id,
        fileName: capture.fileName,
        label: capture.label,
        absolutePath: capture.absolutePath
      }))
    };
  });
  const status = errors.length === 0 ? "PASS_V0173_ENVIRONMENT_FOUNDATION_CAPTURE" : "FAIL_V0173_ENVIRONMENT_FOUNDATION_CAPTURE";
  const report = { schemaVersion: 1, checkpoint, status, requiredCaptureIds, scenarios, contactSheet: "capture/v0173-environment-foundation-contact-sheet.svg", errors };
  writeJson(join(root, "capture", "environment-foundation-capture-report.json"), report);
  writeText(join(root, "capture", "v0173-environment-foundation-contact-sheet.svg"), contactSheetSvg(scenarios));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function contactSheetSvg(scenarios) {
  const rows = [];
  const preferred = ["battle_default_full_battlefield", "road_network", "river_banks", "bridge_crossing", "barracks_restoration", "barracks_restored", "five_slot_coexistence", "combat_posture", "minimap", "camera_max_zoom"];
  let y = 32;
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
  return [
    `<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="${Math.max(420, y + 24)}" viewBox="0 0 1600 ${Math.max(420, y + 24)}">`,
    '<rect width="100%" height="100%" fill="#11170f"/>',
    '<text x="24" y="24" font-family="Arial" font-size="18" fill="#f3e7b8">v0.173 Salto Environment Foundation Before/After Contact Sheet</text>',
    ...rows,
    "</svg>",
    ""
  ].join("\n");
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", "m5-five-slot-baseline", "worker-art-opt-in-benchmark-runtime.json", errors);
  const environment = reportAt(root, "benchmark", "e1-environment-foundation", "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) {
    checkCommonFiveSlot(baseline.report, "m5-five-slot-baseline", errors);
    checkEnvironmentPosture(baseline.report, false, "m5-five-slot-baseline", errors);
  }
  if (environment.report) {
    checkCommonFiveSlot(environment.report, "e1-environment-foundation", errors);
    checkEnvironmentPosture(environment.report, true, "e1-environment-foundation", errors);
  }
  const baselineFps = Number(baseline.report?.fpsAverage ?? 0);
  const environmentFps = Number(environment.report?.fpsAverage ?? 0);
  const baselineP95 = Number(baseline.report?.frameTimeP95Ms ?? 0);
  const environmentP95 = Number(environment.report?.frameTimeP95Ms ?? 0);
  const fpsRatio = baselineFps > 0 ? environmentFps / baselineFps : 0;
  const p95Worsening = baselineP95 > 0 ? (environmentP95 - baselineP95) / baselineP95 : 1;
  if (fpsRatio < 0.90) errors.push(`FPS ratio ${fpsRatio.toFixed(4)} is below 0.90.`);
  if (p95Worsening > 0.15) errors.push(`p95 worsening ${(p95Worsening * 100).toFixed(2)}% exceeds 15%.`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0173_ENVIRONMENT_FOUNDATION_BENCHMARK" : "FAIL_V0173_ENVIRONMENT_FOUNDATION_BENCHMARK",
    baseline: {
      id: "m5-five-slot-baseline",
      fpsAverage: baselineFps,
      frameTimeP95Ms: baselineP95,
      path: rel(baseline.path)
    },
    environmentFoundation: {
      id: "e1-environment-foundation",
      fpsAverage: environmentFps,
      frameTimeP95Ms: environmentP95,
      path: rel(environment.path)
    },
    thresholds: {
      minimumFpsRatio: 0.90,
      maximumP95WorseningRatio: 0.15
    },
    result: {
      fpsRatio: Number(fpsRatio.toFixed(4)),
      p95WorseningRatio: Number(p95Worsening.toFixed(4)),
      p95WorseningPercent: Number((p95Worsening * 100).toFixed(2))
    },
    errors
  };
  writeJson(join(root, "benchmark", "environment-foundation-benchmark-scorecard.json"), report);
  writeText(join(root, "benchmark", "environment-foundation-benchmark-scorecard.md"), benchmarkMarkdown(report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkMarkdown(report) {
  return [
    "# v0.173 Environment Foundation Benchmark Scorecard",
    "",
    `Status: \`${report.status}\``,
    "",
    `M5 FPS: \`${report.baseline.fpsAverage}\``,
    `E1 FPS: \`${report.environmentFoundation.fpsAverage}\``,
    `FPS ratio: \`${report.result.fpsRatio}\``,
    `M5 p95 ms: \`${report.baseline.frameTimeP95Ms}\``,
    `E1 p95 ms: \`${report.environmentFoundation.frameTimeP95Ms}\``,
    `p95 worsening: \`${report.result.p95WorseningPercent}%\``,
    "",
    "Thresholds: FPS ratio >= 0.90; p95 worsening <= 15%.",
    ""
  ].join("\n");
}

function boundaryCommand(root) {
  const errors = [];
  const defaultLaunchers = [
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat",
    "GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat"
  ];
  for (const path of defaultLaunchers) {
    const text = readFileSync(join(repoRoot, path), "utf8");
    if (text.includes("--salto-environment-foundation-review")) errors.push(`${path} unexpectedly enables environment foundation review.`);
  }
  const reviewBat = readFileSync(join(repoRoot, "GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat"), "utf8");
  const launchScript = readFileSync(join(repoRoot, "tools", "godot", "launchGodotSaltoEnvironmentFoundationWindows.ps1"), "utf8");
  if (!reviewBat.includes("reviewGodotSaltoEnvironmentFoundationWindows.ps1")) errors.push("Required v0.173 review batch does not call its review script.");
  ["--salto-environment-foundation-review", "--salto-five-slot-review-framing", "--ashen-art-opt-in"].forEach((text) => {
    if (!launchScript.includes(text)) errors.push(`Environment launcher missing ${text}.`);
  });
  const status = execSync("git status --short --untracked-files=all", { cwd: repoRoot, encoding: "utf8" }).trim();
  const imageChanges = status.split(/\r?\n/u).filter((line) => /\.(png|jpe?g|webp|avif)\b/iu.test(line));
  if (imageChanges.length > 0) errors.push(`Tracked/untracked image changes are not allowed for v0.173: ${imageChanges.join(", ")}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0173_ENVIRONMENT_FOUNDATION_BOUNDARY" : "FAIL_V0173_ENVIRONMENT_FOUNDATION_BOUNDARY",
    defaultLauncherProcedural: true,
    priorLaunchersPreserved: true,
    browserRuntimeChanged: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    aiImagesGenerated: 0,
    runtimeArtSlotsAdded: 0,
    terrainMaterialImported: false,
    statusSnapshot: status,
    errors
  };
  writeJson(join(root, "boundary", "environment-foundation-boundary-report.json"), report);
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
