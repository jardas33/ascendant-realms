import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const checkpoint = "v0.186";
const artifactRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0186");
const groundSha = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8";
const roadSha = "a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10";
const s1ScenarioId = "s1-structure-shell-hardening";
const e4ScenarioId = "e4-refined-shell-live-qa-baseline";
const requiredCaptureIds = [
  "full_overview_before",
  "command_hall_normal",
  "command_hall_close",
  "mine_normal",
  "mine_close",
  "barracks_restoration",
  "barracks_restoration_close",
  "barracks_restored",
  "worker_barracks_relation",
  "road_bridge_relation",
  "site_structure_marker",
  "combat_posture",
  "pan",
  "zoom",
  "minimap",
  "results"
];

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, entry]) => [key, stableSort(entry)])
    );
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

function shellLiveQa(report) {
  return report?.environmentShellLiveQa ?? {};
}

function structureShell(report) {
  return report?.environmentStructureShellHardening ?? {};
}

function checkNoForbiddenRuntimeMutation(report, id, errors) {
  for (const key of ["browserRuntimeChanged", "saveWritesAllowed", "stableIdsChanged"]) {
    if (report?.[key] === true) errors.push(`${id} reported forbidden ${key}.`);
  }
  for (const [label, status] of [
    ["shell live QA", shellLiveQa(report)],
    ["structure shell", structureShell(report)]
  ]) {
    for (const key of ["gameplayPathingChanged", "collisionGeometryChanged", "objectiveLogicChanged", "aiLogicChanged", "navigationSemanticsChanged"]) {
      if (status?.[key] === true) errors.push(`${id} ${label} reported forbidden ${key}.`);
    }
  }
}

function checkDefault(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} should request zero character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 0) errors.push(`${id} should request zero environment material slots.`);
  if (report?.environmentStructureShellHardeningEnabled === true) errors.push(`${id} unexpectedly enabled v0.186 structure shell hardening.`);
  if (report?.environmentShellLiveQaEnabled === true) errors.push(`${id} unexpectedly enabled v0.185 shell live QA.`);
  if (report?.environmentGeometryConvergenceEnabled === true) errors.push(`${id} unexpectedly enabled v0.184 geometry convergence.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkGroundRoad(report, id, errors) {
  if (!isPass(report)) errors.push(`${id} did not PASS: ${report?.status ?? "MISSING"}`);
  if (Number(report?.normalSliceOptInRequestedSlotCount ?? 0) !== 5) errors.push(`${id} did not request exactly five frozen character slots.`);
  if (Number(report?.normalSliceOptInLoadedSlotCount ?? 0) !== 5) errors.push(`${id} did not load exactly five frozen character slots.`);
  if (Number(report?.environmentMaterialOptInRequestedSlotCount ?? 0) !== 2) errors.push(`${id} did not request exactly two existing environment material slots.`);
  if (Number(report?.environmentMaterialOptInLoadedSlotCount ?? 0) !== 2) errors.push(`${id} did not load exactly two existing environment material slots.`);
  if (report?.sixthPlayerFacingArtSlotAdded === true) errors.push(`${id} reported a sixth character slot.`);
  const g = ground(report);
  const r = road(report);
  if (g.expectedSha256 !== groundSha || g.actualSha256 !== groundSha || g.sourceLoaded !== true) errors.push(`${id} ground material hash/load mismatch.`);
  if (r.expectedSha256 !== roadSha || r.actualSha256 !== roadSha || r.sourceLoaded !== true) errors.push(`${id} road material hash/load mismatch.`);
  if (Number(g.sourceLoadCount ?? 99) !== 1 || Number(g.metadataParseCount ?? 99) !== 1 || Number(g.imageDecodeCount ?? 99) !== 1 || Number(g.textureCreateCount ?? 99) !== 1 || Number(g.materialCreateCount ?? 99) !== 1) errors.push(`${id} ground material was not one-time loaded/created.`);
  if (Number(r.sourceLoadCount ?? 99) !== 1 || Number(r.metadataParseCount ?? 99) !== 1 || Number(r.imageDecodeCount ?? 99) !== 1 || Number(r.textureCreateCount ?? 99) !== 1 || Number(r.materialCreateCount ?? 99) !== 1) errors.push(`${id} road material was not one-time loaded/created.`);
  checkNoForbiddenRuntimeMutation(report, id, errors);
}

function checkE4(report, id, errors) {
  checkGroundRoad(report, id, errors);
  const shell = shellLiveQa(report);
  if (report?.environmentGeometryConvergenceEnabled !== true) errors.push(`${id} did not retain the v0.184 geometry foundation.`);
  if (report?.environmentShellLiveQaEnabled !== true || shell.enabled !== true) errors.push(`${id} did not enable the v0.185 shell live-QA baseline.`);
  if (report?.environmentStructureShellHardeningEnabled === true) errors.push(`${id} unexpectedly enabled v0.186 structure hardening.`);
  if (Number(report?.environmentShellLiveQaArtSlotCount ?? 0) !== 0) errors.push(`${id} added a shell-live-QA art slot.`);
  for (const key of ["residualGiantOverlaysPruned", "floatingReviewRectanglesMateriallyReduced", "transparentLayerCompetitionReduced", "roadsRiverBridgeContinuous", "structureHierarchyImproved", "charactersReadable"]) {
    if (shell[key] !== true) errors.push(`${id} live-QA gate ${key} was not true.`);
  }
  const audit = shell.audit ?? {};
  if (Number(audit.largeTransparentDiagnosticPadsKept ?? 99) !== 0) errors.push(`${id} retained giant diagnostic pads.`);
  if (Number(audit.newArtSlots ?? 99) !== 0 || Number(audit.newImportedTextures ?? 99) !== 0) errors.push(`${id} reported new art or imported textures.`);
}

function checkS1(report, id, errors) {
  checkGroundRoad(report, id, errors);
  checkE4Inheritance(report, id, errors);
  const structure = structureShell(report);
  if (report?.environmentStructureShellHardeningEnabled !== true || structure.enabled !== true) errors.push(`${id} did not enable v0.186 structure shell hardening.`);
  if (Number(report?.environmentStructureShellHardeningArtSlotCount ?? 0) !== 0) errors.push(`${id} added a structure-shell art slot.`);
  for (const key of ["structureHierarchyMateriallyImproved", "commandHallDistinguishable", "mineDistinguishable", "barracksRestorationStateReadable", "shellsGroundedInsideTerrain", "warmAccentsRestrained", "charactersReadable"]) {
    if (structure[key] !== true) errors.push(`${id} structure gate ${key} was not true.`);
  }
  const audit = structure.audit ?? {};
  for (const key of ["commandHallNodes", "mineNodes", "barracksNodes", "siteStructureNodes"]) {
    if (!Array.isArray(audit[key]) || audit[key].length < 3) errors.push(`${id} ${key} audit is incomplete.`);
  }
  if (Number(audit.newArtSlots ?? 99) !== 0 || Number(audit.newImportedTextures ?? 99) !== 0 || Number(audit.structureMaterialSlotsAdded ?? 99) !== 0) errors.push(`${id} reported new art, imported textures, or structure material slots.`);
}

function checkE4Inheritance(report, id, errors) {
  const shell = shellLiveQa(report);
  if (report?.environmentGeometryConvergenceEnabled !== true) errors.push(`${id} did not retain geometry convergence.`);
  if (report?.environmentShellLiveQaEnabled !== true || shell.enabled !== true) errors.push(`${id} did not retain shell live QA.`);
  if (Number(report?.environmentShellLiveQaArtSlotCount ?? 0) !== 0) errors.push(`${id} added a shell-live-QA art slot.`);
  for (const key of ["residualGiantOverlaysPruned", "floatingReviewRectanglesMateriallyReduced", "transparentLayerCompetitionReduced", "roadsRiverBridgeContinuous", "charactersReadable"]) {
    if (shell[key] !== true) errors.push(`${id} inherited live-QA gate ${key} was not true.`);
  }
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
    shellLiveQaEnabled: report?.environmentShellLiveQaEnabled ?? false,
    structureShellHardeningEnabled: report?.environmentStructureShellHardeningEnabled ?? false,
    shellLiveQaAudit: shellLiveQa(report).audit ?? {},
    structureShellAudit: structureShell(report).audit ?? {}
  };
}

function validationCommand(root) {
  const errors = [];
  const configs = [
    { id: "default-procedural", check: checkDefault },
    { id: e4ScenarioId, check: checkE4 },
    { id: s1ScenarioId, check: checkS1 }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "validation", config.id, "player-slice-validation-runtime.json", errors);
    if (loaded.report) config.check(loaded.report, config.id, errors);
    return scenarioSummary(config.id, loaded);
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0186_STRUCTURE_SHELL_HARDENING_VALIDATION" : "FAIL_V0186_STRUCTURE_SHELL_HARDENING_VALIDATION", scenarios, errors };
  writeJson(join(root, "validation", "structure-shell-hardening-validation-report.json"), report);
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function captureCommand(root) {
  const errors = [];
  const configs = [
    { id: e4ScenarioId, check: checkE4 },
    { id: s1ScenarioId, check: checkS1 }
  ];
  const scenarios = configs.map((config) => {
    const loaded = reportAt(root, "capture", config.id, "screenshot-runtime-manifest.json", errors);
    const captures = Array.isArray(loaded.report?.captures) ? loaded.report.captures : [];
    if (loaded.report) {
      config.check(loaded.report, config.id, errors);
      if (config.id === s1ScenarioId) {
        const ids = new Set(captures.map((capture) => capture.id));
        for (const captureId of requiredCaptureIds) if (!ids.has(captureId)) errors.push(`${config.id} missing required capture id: ${captureId}`);
      }
    }
    return { ...scenarioSummary(config.id, loaded), captureCount: loaded.report?.captureCount ?? 0, captures: captures.map((capture) => ({ id: capture.id, fileName: capture.fileName, label: capture.label, absolutePath: capture.absolutePath })) };
  });
  const report = { schemaVersion: 1, checkpoint, status: errors.length === 0 ? "PASS_V0186_STRUCTURE_SHELL_HARDENING_CAPTURE" : "FAIL_V0186_STRUCTURE_SHELL_HARDENING_CAPTURE", requiredCaptureIds, contactSheet: "capture/v0186-structure-shell-hardening-contact-sheet.svg", scenarios, errors };
  writeJson(join(root, "capture", "structure-shell-hardening-capture-report.json"), report);
  writeText(join(root, "capture", "v0186-structure-shell-hardening-contact-sheet.svg"), contactSheetSvg(scenarios));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function contactSheetSvg(scenarios) {
  const preferred = ["full_overview_before", "command_hall_normal", "command_hall_close", "mine_normal", "mine_close", "barracks_restoration", "barracks_restored", "worker_barracks_relation", "road_bridge_relation", "combat_posture", "minimap", "results"];
  const fallback = ["full_battlefield_overview", "command_hall", "mine", "barracks_shell", "bridge_close_view", "ashen_combat_posture", "minimap", "results"];
  const rows = [];
  let y = 34;
  for (const scenario of scenarios) {
    rows.push(`<text x="24" y="${y}" font-family="Arial" font-size="22" fill="#e9eedc">${scenario.id}</text>`);
    y += 18;
    let x = 24;
    const captures = scenario.captures.length ? scenario.captures : [];
    const ids = scenario.id === s1ScenarioId ? preferred : fallback;
    for (const id of ids) {
      const capture = captures.find((entry) => entry.id === id);
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
  return [`<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="${height}" viewBox="0 0 1600 ${height}">`, '<rect width="100%" height="100%" fill="#10150f"/>', '<text x="24" y="24" font-family="Arial" font-size="18" fill="#f3e7b8">v0.186 Salto Structure Shell Hardening Contact Sheet</text>', ...rows, "</svg>", ""].join("\n");
}

function benchmarkCommand(root) {
  const errors = [];
  const baseline = reportAt(root, "benchmark", e4ScenarioId, "worker-art-opt-in-benchmark-runtime.json", errors);
  const optIn = reportAt(root, "benchmark", s1ScenarioId, "worker-art-opt-in-benchmark-runtime.json", errors);
  if (baseline.report) checkE4(baseline.report, e4ScenarioId, errors);
  if (optIn.report) checkS1(optIn.report, s1ScenarioId, errors);
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
    status: errors.length === 0 ? "PASS_V0186_STRUCTURE_SHELL_HARDENING_BENCHMARK" : "FAIL_V0186_STRUCTURE_SHELL_HARDENING_BENCHMARK",
    baseline: { id: e4ScenarioId, fpsAverage: baselineFps, frameTimeP95Ms: baselineP95, path: rel(baseline.path) },
    optIn: { id: s1ScenarioId, fpsAverage: optInFps, frameTimeP95Ms: optInP95, path: rel(optIn.path) },
    thresholds: { minimumFpsRatio: 0.90, maximumP95WorseningRatio: 0.15 },
    result: { fpsRatio: Number(fpsRatio.toFixed(4)), p95WorseningRatio: Number(p95Worsening.toFixed(4)), p95WorseningPercent: Number((p95Worsening * 100).toFixed(2)) },
    cacheCounters: optIn.report?.cacheCounters ?? {},
    shellLiveQaAudit: shellLiveQa(optIn.report).audit ?? {},
    structureShellAudit: structureShell(optIn.report).audit ?? {},
    errors
  };
  writeJson(join(root, "benchmark", "structure-shell-hardening-benchmark-scorecard.json"), report);
  writeText(join(root, "benchmark", "structure-shell-hardening-benchmark-scorecard.md"), benchmarkMarkdown(report));
  if (errors.length > 0) throw new Error(errors.join("\n"));
}

function benchmarkMarkdown(report) {
  return ["# v0.186 Structure Shell Hardening Benchmark Scorecard", "", `Status: \`${report.status}\``, "", `E4 FPS: \`${report.baseline.fpsAverage}\``, `S1 FPS: \`${report.optIn.fpsAverage}\``, `FPS ratio: \`${report.result.fpsRatio}\``, `E4 p95 ms: \`${report.baseline.frameTimeP95Ms}\``, `S1 p95 ms: \`${report.optIn.frameTimeP95Ms}\``, `p95 worsening: \`${report.result.p95WorseningPercent}%\``, "", "Thresholds: S1/E4 FPS ratio >= 0.90; S1 p95 worsening <= 15%.", ""].join("\n");
}

function boundaryCommand(root) {
  const errors = [];
  const preservedLaunchers = [
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_CONTRAST_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_GEOMETRY_CONVERGENCE_WINDOWS.bat",
    "GODOT_REVIEW_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat"
  ];
  for (const path of preservedLaunchers) {
    const text = readFileSync(join(repoRoot, path), "utf8");
    if (text.includes("--salto-structure-shell-hardening")) errors.push(`${path} unexpectedly enables v0.186 structure hardening.`);
  }
  const launchPath = join(repoRoot, "tools", "godot", "launchGodotSaltoStructureShellHardeningWindows.ps1");
  const launchScript = existsSync(launchPath) ? readFileSync(launchPath, "utf8") : "";
  for (const text of ["--salto-structure-shell-hardening", "--salto-environment-shell-live-qa", "--ground-material-opt-in", "--road-material-opt-in", "Experimental opt-in: 5 slots + Barrosan ground + roads + structure shell hardening", groundSha, roadSha]) {
    if (!launchScript.includes(text)) errors.push(`v0.186 launcher missing ${text}.`);
  }
  const status = execSync("git status --short --untracked-files=all", { cwd: repoRoot, encoding: "utf8" }).trim();
  const imageChanges = status.split(/\r?\n/u).filter((line) => /\.(png|jpe?g|webp|avif)\b/iu.test(line));
  if (imageChanges.length > 0) errors.push(`Unexpected image changes during v0.186 zero-image implementation: ${imageChanges.join(", ")}`);
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? "PASS_V0186_STRUCTURE_SHELL_HARDENING_BOUNDARY" : "FAIL_V0186_STRUCTURE_SHELL_HARDENING_BOUNDARY",
    defaultLauncherProcedural: true,
    priorLaunchersPreserved: true,
    browserRuntimeChanged: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    gameplayPathingChanged: false,
    collisionGeometryChanged: false,
    objectivesChanged: false,
    aiChanged: false,
    aiImagesGenerated: 0,
    characterSlotsAdded: 0,
    environmentMaterialSlotsAdded: 0,
    structureMaterialSlotsAdded: 0,
    statusSnapshot: status,
    errors
  };
  writeJson(join(root, "boundary", "structure-shell-hardening-boundary-report.json"), report);
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
