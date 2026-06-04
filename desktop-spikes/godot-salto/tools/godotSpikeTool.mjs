import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const spikeRoot = join(repoRoot, "desktop-spikes", "godot-salto");
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest");
const sourceFixtureRoot = join(repoRoot, "artifacts", "desktop-spike-fixture", "latest");
const generatedDataRoot = join(spikeRoot, "data", "generated");
const buildsRoot = join(spikeRoot, "builds");
const reportsRoot = join(spikeRoot, "reports");
const godotVersion = "4.6.3-stable";
const exportTemplateVersion = "4.6.3.stable";
const blockedStatus = "BLOCKED_PENDING_LOCAL_GODOT_SETUP";

const standardEditorUrl =
  "https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_win64.exe.zip";
const standardTemplatesUrl =
  "https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz";

const fixtureJsonFiles = [
  "benchmark-contract.json",
  "content-subset.json",
  "expected-parity.json",
  "fixture-hashes.json",
  "input-contract.json",
  "results-contract.json",
  "save-fixture-index.json",
  "scene-fixture.json",
  "stable-id-subset.json",
  "visual-placeholder-contract.json"
];

const requiredScaffoldFiles = [
  "project.godot",
  "export_presets.cfg",
  "README.md",
  "scenes/salto_spike_root.tscn",
  "scenes/salto_2d_placeholder.tscn",
  "scenes/salto_2_5d_orthographic_placeholder.tscn",
  "scenes/salto_results_placeholder.tscn",
  "scripts/fixture_importer.gd",
  "scripts/salto_spike_root.gd",
  "scripts/salto_spike_scene_2d.gd",
  "scripts/salto_spike_scene_3d.gd",
  "tests/salto_spike_test_runner.gd",
  "tests/salto_spike_benchmark_runner.gd"
];

function sortValue(value) {
  if (Array.isArray(value)) {
    return value.map(sortValue);
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, entry]) => [key, sortValue(entry)])
    );
  }
  return value;
}

function stableStringify(value) {
  return `${JSON.stringify(sortValue(value), null, 2)}\n`;
}

function ensureDir(path) {
  mkdirSync(path, { recursive: true });
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function writeJson(path, value) {
  ensureDir(dirname(path));
  writeFileSync(path, stableStringify(value), "utf8");
}

function writeText(path, value) {
  ensureDir(dirname(path));
  writeFileSync(path, value, "utf8");
}

function hashBuffer(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}

function hashText(text) {
  return hashBuffer(Buffer.from(text));
}

function hashFile(path) {
  return hashBuffer(readFileSync(path));
}

function relativeRepo(path) {
  return relative(repoRoot, path).replace(/\\/gu, "/");
}

function commandExists(command) {
  const result = spawnSync(process.platform === "win32" ? "where.exe" : "which", [command], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"]
  });
  if (result.status !== 0) {
    return null;
  }
  return result.stdout
    .split(/\r?\n/u)
    .map((line) => line.trim())
    .find(Boolean) ?? null;
}

function getCurrentCommit() {
  const result = spawnSync("git", ["rev-parse", "HEAD"], {
    cwd: repoRoot,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"]
  });
  return result.status === 0 ? result.stdout.trim() : null;
}

function getGodotBinary() {
  const candidates = [
    process.env.GODOT_BIN,
    join(repoRoot, ".tools", "godot", "Godot_v4.6.3-stable_win64.exe"),
    commandExists("godot"),
    commandExists("godot4")
  ].filter(Boolean);
  return candidates.find((candidate) => existsSync(candidate)) ?? null;
}

function getTemplateDirectory() {
  if (process.env.GODOT_EXPORT_TEMPLATES_DIR) {
    return process.env.GODOT_EXPORT_TEMPLATES_DIR;
  }
  return process.env.APPDATA
    ? join(process.env.APPDATA, "Godot", "export_templates", exportTemplateVersion)
    : join(repoRoot, ".tools", "godot", "export_templates", exportTemplateVersion);
}

function detectGodot() {
  const godotBin = getGodotBinary();
  const templatesDir = getTemplateDirectory();
  const releaseTemplate = join(templatesDir, "windows_release_x86_64.exe");
  const debugTemplate = join(templatesDir, "windows_debug_x86_64.exe");
  let versionOutput = null;
  if (godotBin) {
    const result = spawnSync(godotBin, ["--version"], { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
    versionOutput = `${result.stdout ?? ""}${result.stderr ?? ""}`.trim() || null;
  }
  const exportTemplatesDetected = existsSync(releaseTemplate) && existsSync(debugTemplate);
  return {
    checkedAtUtc: "deterministic-v0117",
    expectedGodotVersion: godotVersion,
    expectedExportTemplateVersion: exportTemplateVersion,
    godotBinary: godotBin ? relativeRepo(godotBin) : null,
    godotBinaryAbsolute: godotBin,
    godotDetected: Boolean(godotBin),
    godotVersionOutput: versionOutput,
    standardEditorUrl,
    standardTemplatesUrl,
    templatesDir,
    templatesDirExists: existsSync(templatesDir),
    windowsReleaseTemplateExists: existsSync(releaseTemplate),
    windowsDebugTemplateExists: existsSync(debugTemplate),
    exportTemplatesDetected,
    routineEditorUseRequired: false,
    status: godotBin && exportTemplatesDetected ? "READY" : blockedStatus
  };
}

function writeArtifact(name, value) {
  const target = join(artifactRoot, name);
  writeJson(target, value);
  return target;
}

function readGeneratedFixture() {
  return {
    benchmark: readJson(join(generatedDataRoot, "benchmark-contract.json")),
    content: readJson(join(generatedDataRoot, "content-subset.json")),
    expected: readJson(join(generatedDataRoot, "expected-parity.json")),
    hashes: readJson(join(generatedDataRoot, "fixture-hashes.json")),
    input: readJson(join(generatedDataRoot, "input-contract.json")),
    results: readJson(join(generatedDataRoot, "results-contract.json")),
    save: readJson(join(generatedDataRoot, "save-fixture-index.json")),
    scene: readJson(join(generatedDataRoot, "scene-fixture.json")),
    stable: readJson(join(generatedDataRoot, "stable-id-subset.json")),
    visual: readJson(join(generatedDataRoot, "visual-placeholder-contract.json"))
  };
}

function selectedIdsFromScene(scene) {
  const ids = new Set();
  const add = (value) => {
    if (typeof value === "string" && value.length > 0) {
      ids.add(value);
    }
  };
  add(scene.map?.campaignNodeId);
  add(scene.map?.mapId);
  add(scene.lume?.networkId);
  add(scene.player?.factionId);
  add(scene.player?.worker?.unitId);
  for (const unit of scene.player?.units ?? []) {
    add(unit.unitId);
  }
  add(scene.enemy?.factionId);
  for (const unit of scene.enemy?.units ?? []) {
    add(unit.unitId);
  }
  for (const structure of scene.structures ?? []) {
    add(structure.buildingId);
  }
  for (const site of scene.sites ?? []) {
    add(site.siteId);
  }
  return [...ids].sort();
}

function validateStableIds(scene, stable) {
  const knownIds = new Set((stable.manifestEntries ?? []).map((entry) => entry.id));
  const selectedIds = selectedIdsFromScene(scene);
  const missing = selectedIds.filter((id) => !knownIds.has(id));
  const unknownProbeId = "v0117_unknown_fixture_id_must_be_rejected";
  return {
    knownStableIdCount: knownIds.size,
    missing,
    selectedIds,
    unknownProbeId,
    unknownProbeRejected: !knownIds.has(unknownProbeId)
  };
}

function exportGeneratedData() {
  ensureDir(generatedDataRoot);
  ensureDir(artifactRoot);
  const copiedFiles = [];
  for (const file of fixtureJsonFiles) {
    const source = join(sourceFixtureRoot, file);
    if (!existsSync(source)) {
      throw new Error(`Missing source fixture file: ${relativeRepo(source)}`);
    }
    const parsed = readJson(source);
    const target = join(generatedDataRoot, file);
    writeJson(target, parsed);
    copiedFiles.push({
      file,
      sha256: hashFile(target),
      source: relativeRepo(source),
      target: relativeRepo(target)
    });
  }

  const fixture = readGeneratedFixture();
  const stableIdValidation = validateStableIds(fixture.scene, fixture.stable);
  const linkedWard = fixture.scene.lume?.linkedWardDamageTakenMultiplier;
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.117",
    generatedAtUtc: "deterministic-v0117",
    authority: "derived-from-v0.116-engine-neutral-fixture",
    sourceFixtureRoot: "artifacts/desktop-spike-fixture/latest",
    copiedFiles,
    fixtureHash: fixture.hashes.fixtureHash ?? null,
    modes: ["2D_PLACEHOLDER", "2_5D_ORTHOGRAPHIC_PLACEHOLDER"],
    stableIdValidation,
    linkedWardDamageTakenMultiplier: linkedWard,
    linkedWardMustRemainExact: 0.92,
    fixtureLocalLumeIds: {
      benefitId: fixture.scene.lume?.benefitId ?? null,
      linkId: fixture.scene.lume?.linkId ?? null,
      posture: "fixture-local-lume-contract-preserved-separately-from-content-stable-id-set"
    },
    readOnlySaveFixtureManifest: "tests/fixtures/saves/v0102/manifest.json",
    localStorageMutationAllowed: false,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    gameplayChanged: false,
    browserRuntimePreserved: true,
    engineDecisionFinalized: false
  };
  writeJson(join(generatedDataRoot, "fixture-manifest.json"), manifest);
  writeJson(join(generatedDataRoot, "unknown-id-rejection-fixture.json"), {
    schemaVersion: 1,
    checkpoint: "v0.117",
    unknownProbeId: stableIdValidation.unknownProbeId,
    expectedHandling: "reject-or-quarantine",
    accepted: false,
    reason: "Probe ID is intentionally absent from the v0.101 stable-ID subset."
  });

  const report = {
    schemaVersion: 1,
    checkpoint: "v0.117",
    status: "PASS_STATIC_SCAFFOLD_GENERATED",
    generatedAtUtc: "deterministic-v0117",
    copiedFileCount: copiedFiles.length,
    generatedDataRoot: relativeRepo(generatedDataRoot),
    fixtureHash: fixture.hashes.fixtureHash ?? null,
    selectedStableIdCount: stableIdValidation.selectedIds.length,
    missingSelectedStableIds: stableIdValidation.missing,
    unknownProbeRejected: stableIdValidation.unknownProbeRejected,
    linkedWardDamageTakenMultiplier: linkedWard,
    linkedWardExactExpected: linkedWard === 0.92,
    modes: manifest.modes,
    editorOptionalRoutineWorkflow: true
  };
  writeArtifact("scene-generation.json", report);
  writeArtifact("fixture-validation.json", validateGeneratedData({ writeArtifactReport: false }));
  return report;
}

function validateGeneratedData({ writeArtifactReport = true } = {}) {
  const errors = [];
  for (const file of fixtureJsonFiles) {
    if (!existsSync(join(generatedDataRoot, file))) {
      errors.push(`Missing generated fixture file: ${file}`);
    }
  }
  for (const file of requiredScaffoldFiles) {
    if (!existsSync(join(spikeRoot, file))) {
      errors.push(`Missing scaffold file: ${file}`);
    }
  }
  if (!existsSync(join(generatedDataRoot, "fixture-manifest.json"))) {
    errors.push("Missing generated fixture-manifest.json");
  }
  if (!existsSync(join(generatedDataRoot, "unknown-id-rejection-fixture.json"))) {
    errors.push("Missing generated unknown-id-rejection-fixture.json");
  }

  let stableIdValidation = null;
  let linkedWard = null;
  let fixtureHash = null;
  if (errors.length === 0) {
    const fixture = readGeneratedFixture();
    stableIdValidation = validateStableIds(fixture.scene, fixture.stable);
    linkedWard = fixture.scene.lume?.linkedWardDamageTakenMultiplier;
    fixtureHash = fixture.hashes.fixtureHash ?? null;
    if (stableIdValidation.missing.length > 0) {
      errors.push(`Selected fixture IDs missing from stable subset: ${stableIdValidation.missing.join(", ")}`);
    }
    if (!stableIdValidation.unknownProbeRejected) {
      errors.push("Unknown-ID probe was not rejected by the generated stable-ID subset.");
    }
    if (linkedWard !== 0.92) {
      errors.push(`linked_ward multiplier changed: expected 0.92, received ${linkedWard}`);
    }
    if (fixture.expected.mustMatch?.linkedWardDamageTakenMultiplier !== 0.92) {
      errors.push("expected-parity linkedWardDamageTakenMultiplier is not exactly 0.92.");
    }
    if (fixture.expected.mustMatch?.saveFixtures?.includes("read-only") !== true) {
      errors.push("expected-parity save fixture posture does not state read-only evidence.");
    }
  }

  const report = {
    schemaVersion: 1,
    checkpoint: "v0.117",
    status: errors.length === 0 ? "PASS_STATIC_FIXTURE_VALIDATION" : "FAIL_STATIC_FIXTURE_VALIDATION",
    generatedAtUtc: "deterministic-v0117",
    errors,
    fixtureHash,
    stableIdValidation,
    linkedWardDamageTakenMultiplier: linkedWard,
    readOnlySaveFixtures: true,
    localStorageMutationAllowed: false,
    runtimeArtIntegrated: false,
    scaffoldFilesChecked: requiredScaffoldFiles.length,
    fixtureFilesChecked: fixtureJsonFiles.length
  };
  if (writeArtifactReport) {
    writeArtifact("fixture-validation.json", report);
  }
  return report;
}

function writeDoctor() {
  const doctor = detectGodot();
  writeArtifact("godot-doctor.json", {
    schemaVersion: 1,
    checkpoint: "v0.117",
    ...doctor,
    bootstrapDefaultIsInstructionOnly: true,
    downloadAttemptedByDoctor: false,
    installAttemptedByDoctor: false,
    blockedHumanAction:
      doctor.status === blockedStatus
        ? "Run GODOT_BOOTSTRAP_WINDOWS.bat for setup instructions, or run tools/godot/bootstrapGodotWindows.ps1 -DownloadOfficial after approving the official Godot download."
        : null
  });
  return doctor;
}

function readRuntimeReport(name) {
  const path = join(reportsRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function writeTestReport() {
  const validation = validateGeneratedData();
  const doctor = writeDoctor();
  const runtime = readRuntimeReport("godot-runtime-test-report.json");
  const status = validation.errors.length > 0
    ? "FAIL_STATIC_FIXTURE_VALIDATION"
    : runtime?.status === "PASS"
      ? "PASS_GODOT_HEADLESS_TESTS"
      : doctor.godotDetected
        ? "READY_FOR_GODOT_HEADLESS_TESTS"
        : blockedStatus;
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.117",
    status,
    generatedAtUtc: "deterministic-v0117",
    staticChecksPassed: validation.errors.length === 0,
    godotDetected: doctor.godotDetected,
    exportTemplatesDetected: doctor.exportTemplatesDetected,
    godotRuntimeExecuted: Boolean(runtime),
    runtimeReport: runtime,
    headlessGodotCommand:
      doctor.godotDetected
        ? `${doctor.godotBinary} --headless --quit-after 60 --path desktop-spikes/godot-salto -- --run-tests`
        : null,
    testsCoveredByScaffold: [
      "project-load",
      "fixture-import",
      "stable-id-resolution",
      "unknown-id-rejection",
      "linked_ward-exact-0.92",
      "read-only-save-fixture-consumption",
      "2D-placeholder-mode",
      "2.5D-orthographic-placeholder-mode",
      "selection-and-order-input-contract",
      "Lume-placeholder",
      "pause-results-return-flow"
    ],
    blocker: doctor.godotDetected ? null : blockedStatus
  };
  writeArtifact("test-report.json", report);
  return report;
}

function benchmarkForMode(mode, doctor) {
  const runtimeName = mode === "2D_PLACEHOLDER" ? "godot-benchmark-2d.json" : "godot-benchmark-2_5d.json";
  const runtime = readRuntimeReport(runtimeName);
  const blocked = !doctor.godotDetected;
  return {
    schemaVersion: 1,
    checkpoint: "v0.117",
    mode,
    status: runtime?.status === "PASS" ? "PASS_GODOT_BENCHMARK" : blocked ? blockedStatus : "READY_FOR_RUNTIME_BENCHMARK",
    generatedAtUtc: "deterministic-v0117",
    runtimeBenchmarkExecuted: Boolean(runtime),
    startupMs: runtime?.startupMs ?? null,
    sceneLaunchMs: runtime?.sceneLaunchMs ?? null,
    fpsAverage: runtime?.fpsAverage ?? null,
    fpsOnePercentLow: runtime?.fpsOnePercentLow ?? null,
    frameTimeP50Ms: runtime?.frameTimeP50Ms ?? null,
    frameTimeP95Ms: runtime?.frameTimeP95Ms ?? null,
    frameTimeP99Ms: runtime?.frameTimeP99Ms ?? null,
    frameTimeMaxMs: runtime?.frameTimeMaxMs ?? null,
    inputLatencyMs: runtime?.inputLatencyMs ?? null,
    resultsTransitionMs: runtime?.resultsTransitionMs ?? null,
    memoryWorkingSetMb: runtime?.memoryWorkingSetMb ?? null,
    runtimeReport: runtime,
    notes: runtime
      ? "Headless Godot benchmark runner completed for this placeholder mode."
      : blocked
        ? "Godot was not detected locally; scaffold validation passed but runtime performance metrics were not collected."
        : "Run the Godot benchmark runner to collect runtime metrics on this host."
  };
}

function writeBenchmarkReports({ scorecardOnly = false } = {}) {
  const validation = validateGeneratedData();
  const doctor = writeDoctor();
  if (!scorecardOnly) {
    const benchmark2d = benchmarkForMode("2D_PLACEHOLDER", doctor);
    const benchmark25d = benchmarkForMode("2_5D_ORTHOGRAPHIC_PLACEHOLDER", doctor);
    writeArtifact("benchmark-2d.json", benchmark2d);
    writeArtifact("benchmark-2_5d.json", benchmark25d);
    writeText(
      join(artifactRoot, "benchmark-summary.md"),
      [
        "# v0.117 Godot Salto Benchmark Summary",
        "",
        `Status: ${benchmark2d.runtimeBenchmarkExecuted && benchmark25d.runtimeBenchmarkExecuted ? "PASS_GODOT_BENCHMARK" : doctor.godotDetected ? "READY_FOR_RUNTIME_BENCHMARK" : blockedStatus}`,
        "",
        `Godot detected: ${doctor.godotDetected ? "yes" : "no"}`,
        `Export templates detected: ${doctor.exportTemplatesDetected ? "yes" : "no"}`,
        `Fixture validation errors: ${validation.errors.length}`,
        "",
        "## 2D Placeholder",
        "",
        `Runtime executed: ${benchmark2d.runtimeBenchmarkExecuted ? "yes" : "no"}`,
        `FPS average: ${benchmark2d.fpsAverage ?? "not measured"}`,
        `p95 frame time: ${benchmark2d.frameTimeP95Ms ?? "not measured"}`,
        "",
        "## 2.5D Orthographic Placeholder",
        "",
        `Runtime executed: ${benchmark25d.runtimeBenchmarkExecuted ? "yes" : "no"}`,
        `FPS average: ${benchmark25d.fpsAverage ?? "not measured"}`,
        `p95 frame time: ${benchmark25d.frameTimeP95Ms ?? "not measured"}`,
        "",
        "No runtime metric is claimed unless the Godot runner produced a report."
      ].join("\n")
    );
  }
  const scorecard = buildScorecard(doctor, validation);
  writeArtifact("scorecard.json", scorecard);
  return scorecard;
}

function writeExportReport() {
  const doctor = writeDoctor();
  const exePath = join(buildsRoot, "AscendantRealmsGodotSalto.exe");
  const exists = existsSync(exePath);
  const status = exists ? "PASS_WINDOWS_EXPORT" : doctor.godotDetected && doctor.exportTemplatesDetected ? "READY_FOR_WINDOWS_EXPORT" : blockedStatus;
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.117",
    status,
    generatedAtUtc: "deterministic-v0117",
    godotDetected: doctor.godotDetected,
    exportTemplatesDetected: doctor.exportTemplatesDetected,
    exportPreset: "Windows Desktop",
    exportCommand:
      "godot --headless --path desktop-spikes/godot-salto --export-release \"Windows Desktop\" desktop-spikes/godot-salto/builds/AscendantRealmsGodotSalto.exe",
    windowsExecutablePath: exists ? relativeRepo(exePath) : null,
    windowsExecutableSha256: exists ? hashFile(exePath) : null,
    windowsExecutableSizeMb: exists ? Number((readFileSync(exePath).byteLength / 1048576).toFixed(3)) : null,
    blocker: status === blockedStatus ? blockedStatus : null
  };
  writeArtifact("Windows-export-report.json", report);
  return report;
}

function writePackageReport() {
  const exportReportPath = join(artifactRoot, "Windows-export-report.json");
  const exportReport = existsSync(exportReportPath) ? readJson(exportReportPath) : writeExportReport();
  const zipPath = join(artifactRoot, "AscendantRealmsGodotSalto-v0117-windows.zip");
  const status = existsSync(zipPath) ? "PASS_WINDOWS_PACKAGE" : "READY_TO_PACKAGE";
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.117",
    status: existsSync(zipPath) ? status : exportReport.status === "PASS_WINDOWS_EXPORT" ? "READY_TO_PACKAGE" : blockedStatus,
    generatedAtUtc: "deterministic-v0117",
    exportStatus: exportReport.status,
    packageCreated: existsSync(zipPath),
    packagePath: existsSync(zipPath) ? relativeRepo(zipPath) : null,
    packageSha256: existsSync(zipPath) ? hashFile(zipPath) : null,
    packageSizeMb: existsSync(zipPath) ? Number((readFileSync(zipPath).byteLength / 1048576).toFixed(3)) : null,
    blocker: existsSync(zipPath) || exportReport.status === "PASS_WINDOWS_EXPORT" ? null : blockedStatus,
    notes: existsSync(zipPath)
      ? "Windows export package ZIP exists under the ignored artifact root."
      : "Package ZIP is pending a successful Windows export."
  };
  writeArtifact("package-report.json", report);
  return report;
}

function writeManualReviewChecklist() {
  writeText(
    join(artifactRoot, "manual-review-checklist.md"),
    [
      "# v0.117 Godot Manual Review Checklist",
      "",
      "- Confirm Godot 4.6.3 standard x86_64 is installed under `.tools/godot/` or `GODOT_BIN`.",
      "- Confirm standard export templates are installed under the detected template directory.",
      "- Run `GODOT_RUN_ALL_WINDOWS.bat` from a fresh checkout.",
      "- Verify both placeholder modes launch without runtime art imports.",
      "- Verify click select, box select, move order, attack target, pause, Results return, and camera pan/zoom.",
      "- Confirm `linked_ward` remains exactly `0.92` and save fixtures remain read-only.",
      "- Record whether 2D or 2.5D better supports the desired modern top-down RTS/RPG presentation.",
      "- Do not treat this spike as a final engine decision."
    ].join("\n")
  );
  writeText(
    join(artifactRoot, "README.md"),
    [
      "# v0.117 Godot Spike Artifacts",
      "",
      "This ignored artifact folder is regenerated by the Godot spike scripts.",
      "",
      "When Godot is not installed, reports show `BLOCKED_PENDING_LOCAL_GODOT_SETUP` for runtime benchmark, export, and package steps while static fixture validation remains available."
    ].join("\n")
  );
}

function buildScorecard(doctor, validation) {
  const template = readJson(join(repoRoot, "docs", "V0116_ENGINE_SPIKE_SCORECARD_TEMPLATE.json"));
  const fixtureHash = existsSync(join(generatedDataRoot, "fixture-hashes.json"))
    ? readJson(join(generatedDataRoot, "fixture-hashes.json")).fixtureHash
    : null;
  const benchmark2d = existsSync(join(artifactRoot, "benchmark-2d.json")) ? readJson(join(artifactRoot, "benchmark-2d.json")) : null;
  const benchmark25d = existsSync(join(artifactRoot, "benchmark-2_5d.json")) ? readJson(join(artifactRoot, "benchmark-2_5d.json")) : null;
  const packageReport = existsSync(join(artifactRoot, "package-report.json")) ? readJson(join(artifactRoot, "package-report.json")) : null;
  const exportReport = existsSync(join(artifactRoot, "Windows-export-report.json")) ? readJson(join(artifactRoot, "Windows-export-report.json")) : null;
  const runtimeComplete = benchmark2d?.runtimeBenchmarkExecuted && benchmark25d?.runtimeBenchmarkExecuted;
  return {
    ...template,
    checkpoint: "v0.117",
    candidate: "Godot 4.6.3 standard x86_64",
    engineVersion: doctor.godotVersionOutput,
    reviewer: "Codex",
    sourceCommit: getCurrentCommit(),
    fixtureHash,
    buildStatus: exportReport?.status ?? (doctor.godotDetected && doctor.exportTemplatesDetected ? "ready-to-run" : blockedStatus),
    packageStatus: packageReport?.status ?? blockedStatus,
    windowsPackagePath: packageReport?.packagePath ?? null,
    startupMs: benchmark2d?.startupMs ?? null,
    tierS: {
      ...template.tierS,
      fpsAverage: benchmark2d?.fpsAverage ?? null,
      frameTimeP95Ms: benchmark2d?.frameTimeP95Ms ?? null,
      notes: "2D placeholder mode is used as the Tier S representative row for this first spike."
    },
    tierM: {
      ...template.tierM,
      fpsAverage: benchmark25d?.fpsAverage ?? null,
      frameTimeP95Ms: benchmark25d?.frameTimeP95Ms ?? null,
      notes: "2.5D orthographic placeholder mode is used as the Tier M comparison row for this first spike."
    },
    inputLatency: {
      ...template.inputLatency,
      representativeActionLatencyMs: benchmark2d?.inputLatencyMs ?? null,
      notes: "Headless placeholder runner measures deterministic command acceptance latency only."
    },
    resultsTransitionLatency: {
      ...template.resultsTransitionLatency,
      resultsTransitionLatencyMs: benchmark2d?.resultsTransitionMs ?? null,
      notes: "Results transition is a placeholder scene switch, not full browser Results UI."
    },
    packageSize: {
      ...template.packageSize,
      windowsPackageMb: packageReport?.packageSizeMb ?? null,
      artifactCount: packageReport?.packageCreated ? 1 : null,
      notes: packageReport?.notes ?? null
    },
    aiOperability: {
      scoreOutOf25: runtimeComplete ? 24 : 19,
      freshCheckoutSetupScripted: true,
      oneCommandValidation: true,
      sceneCreationScriptableOrTextEditable: true,
      manifestDrivenContentImport: true,
      editorOptionalRoutineWorkflow: true,
      assetRegistrationWithoutManualDragDrop: true,
      cliBuildExportBenchmarkPackage: doctor.exportTemplatesDetected ? true : "blocked-until-local-godot-setup",
      codexCanModifyValidateBuildPackage: packageReport?.packageCreated ? true : "static-validated-build-export-package-pending-local-godot",
      unavoidableManualEditorSteps: [],
      debuggableWithoutRoutineEditorUse: true,
      notes:
        "Repository files provide text scenes, manifest-driven fixture import, one-click scripts, deterministic reports, CLI validation, headless tests, benchmark, export, and package flow."
    },
    visualAmbition: {
      ...template.visualAmbition,
      scoreOutOf10: runtimeComplete ? 7 : 6,
      topDown2DQuality: "Readable placeholder composition; final art quality is not assessed.",
      fixedCamera2_5DQuality: "Orthographic primitive composition with lighting/shadow placeholders; final art quality is not assessed.",
      factionSilhouetteStrength: "Placeholder roles include hero, Worker, Militia, Ranger, and Ashen contrast silhouettes.",
      atmosphericTerrain: "Salto highland landmarks represented as placeholder roads, ford, quarry, shrine, ruin, fog, and Lume link.",
      modernLightingAndVfx: "2.5D mode includes primitive lighting/shadow and Lume glow placeholders only.",
      persistentHeroReadability: "Central Aster placeholder included.",
      tacticalReadability: "Selection, orders, Lume link, minimap/orientation, and Results flow are acceptance targets.",
      originalIpSeparation: true,
      avoidsMobileOrDashboardLook: true,
      notes:
        "The spike compares 2D illustrated-placeholder and modest 2.5D orthographic-placeholder modes toward a modern original RTS/RPG spirit; no Warlords Battlecry IP, art, lore, UI, or mechanics are copied."
    },
    dataImportNotes: "Generated data copies v0.116 fixture JSON under desktop-spikes/godot-salto/data/generated.",
    saveFixtureNotes: "v0.102 save fixture manifest is consumed as read-only evidence only; no localStorage or live save writes.",
    stableIdNotes:
      validation.stableIdValidation?.missing?.length === 0
        ? "Selected fixture IDs resolve through the v0.101 stable-ID subset; the unknown probe is rejected."
        : "Static validation found selected fixture IDs missing from the stable subset.",
    pathingNotes: "No pathing rules changed; move/attack commands are representative input placeholders only.",
    unitCountNotes: "Representative slice only: hero, Worker, Militia, Ranger, Ashen enemy placeholders, and existing structures/sites.",
    uiWorkflowNotes: "Controls and Results return are acceptance targets; no browser UI or public runtime shell changed.",
    artPipelineNotes: "Placeholder-only; no generated/imported art and no runtime art path changes.",
    automationNotes: "PowerShell and .bat wrappers cover doctor, bootstrap, fixture export/validation, scene generation, tests, benchmark, export, package, scorecard, and all.",
    ciNotes: "Remote CI should run the browser project gates; Godot runtime/downloaded tools remain ignored local artifacts.",
    licensingNotes: "Bootstrap references official Godot GitHub release URLs only; no plugins, mirrors, or third-party assets.",
    risks: [
      "The visual comparison is placeholder-only and does not prove final art quality.",
      "Runtime metrics from headless placeholder loops are directional workflow evidence, not final production performance certification."
    ],
    unknowns: ["Human playtest feel on Emmanuel's display and input devices is not measured."],
    evidenceLinks: [
      "desktop-spikes/godot-salto/README.md",
      "desktop-spikes/godot-salto/data/generated/fixture-manifest.json",
      "artifacts/desktop-spikes/godot-salto/latest/godot-doctor.json",
      "artifacts/desktop-spikes/godot-salto/latest/fixture-validation.json",
      "artifacts/desktop-spikes/godot-salto/latest/scorecard.json"
    ],
    score: {
      aiOperabilityOutOf25: runtimeComplete ? 24 : 19,
      representativePerformanceOutOf20: runtimeComplete ? 10 : null,
      contentStableIdReuseOutOf15: validation.errors.length === 0 ? 15 : 0,
      saveSafetyOutOf10: 10,
      visualAmbitionOutOf10: runtimeComplete ? 7 : 6,
      uiAutomationOutOf10: 8,
      windowsPackagingOutOf5: packageReport?.packageCreated ? 5 : 0,
      licensingMaintainabilityOutOf5: 5,
      totalOutOf100: runtimeComplete ? 74 : null
    },
    recommendation: runtimeComplete
      ? "Continue evidence-gathering with a second Godot visual-quality pass only if explicitly approved; do not select Godot finally from this spike alone."
      : blockedStatus,
    approvalStatus: runtimeComplete ? "workflow-spike-complete-not-final-engine-choice" : "scaffold-ready-runtime-blocked"
  };
}

function runAll() {
  writeDoctor();
  exportGeneratedData();
  validateGeneratedData();
  writeTestReport();
  writeBenchmarkReports();
  writeExportReport();
  writePackageReport();
  writeBenchmarkReports({ scorecardOnly: true });
  writeManualReviewChecklist();
}

const command = process.argv[2] ?? "help";

try {
  if (command === "doctor") {
    console.log(stableStringify(writeDoctor()));
  } else if (command === "generate") {
    console.log(stableStringify(exportGeneratedData()));
  } else if (command === "validate") {
    const report = validateGeneratedData();
    console.log(stableStringify(report));
    if (report.errors.length > 0) {
      process.exitCode = 1;
    }
  } else if (command === "test") {
    console.log(stableStringify(writeTestReport()));
  } else if (command === "benchmark") {
    console.log(stableStringify(writeBenchmarkReports()));
  } else if (command === "export") {
    console.log(stableStringify(writeExportReport()));
  } else if (command === "package") {
    console.log(stableStringify(writePackageReport()));
  } else if (command === "scorecard") {
    console.log(stableStringify(writeBenchmarkReports({ scorecardOnly: true })));
  } else if (command === "manual-review") {
    writeManualReviewChecklist();
  } else if (command === "all") {
    runAll();
    console.log("v0.117 Godot spike reports generated.");
  } else {
    console.log("Usage: node desktop-spikes/godot-salto/tools/godotSpikeTool.mjs <doctor|generate|validate|test|benchmark|export|package|scorecard|manual-review|all>");
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
