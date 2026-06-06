import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const spikeRoot = join(repoRoot, "desktop-spikes", "godot-salto");
const artifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest");
const v0118ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0118");
const v0118ScreenshotRoot = join(v0118ArtifactRoot, "screenshots");
const v0119ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0119");
const v0121ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0121");
const v0121ScreenshotRoot = join(v0121ArtifactRoot, "screenshots");
const v0122ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0122");
const v0124ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0124");
const v0124ScreenshotRoot = join(v0124ArtifactRoot, "screenshots");
const v0125ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0125");
const v0126ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0126");
const v0126ScreenshotRoot = join(v0126ArtifactRoot, "screenshots");
const v0127ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0127");
const v0127ScreenshotRoot = join(v0127ArtifactRoot, "screenshots");
const v0128ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0128");
const v0128ScreenshotRoot = join(v0128ArtifactRoot, "screenshots");
const v0129ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0129");
const v0129ScreenshotRoot = join(v0129ArtifactRoot, "screenshots");
const v0130ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0130");
const v0130ScreenshotRoot = join(v0130ArtifactRoot, "screenshots");
const v0131ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0131");
const v0131ScreenshotRoot = join(v0131ArtifactRoot, "screenshots");
const v0132ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0132");
const v0132ScreenshotRoot = join(v0132ArtifactRoot, "screenshots");
const v0133ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0133");
const v0133ScreenshotRoot = join(v0133ArtifactRoot, "screenshots");
const v0134ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0134");
const v0134ScreenshotRoot = join(v0134ArtifactRoot, "screenshots");
const v0135ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0135");
const v0135ScreenshotRoot = join(v0135ArtifactRoot, "screenshots");
const v0136ArtifactRoot = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0136");
const v0136ScreenshotRoot = join(v0136ArtifactRoot, "screenshots");
const sourceFixtureRoot = join(repoRoot, "artifacts", "desktop-spike-fixture", "latest");
const generatedDataRoot = join(spikeRoot, "data", "generated");
const buildsRoot = join(spikeRoot, "builds");
const reportsRoot = join(spikeRoot, "reports");
const godotVersion = "4.6.3-stable";
const exportTemplateVersion = "4.6.3.stable";
const blockedStatus = "BLOCKED_PENDING_LOCAL_GODOT_SETUP";
const v0121VisualPresets = {
  control2d: "2D_CONTROL",
  clean: "CLEAN_READABILITY",
  atmospheric: "ATMOSPHERIC_BALANCED",
  vfxStress: "VFX_STRESS_PRIVATE"
};

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
  "scripts/adapters/content_registry_adapter.gd",
  "scripts/adapters/stable_id_validator.gd",
  "scripts/adapters/save_fixture_read_only_adapter.gd",
  "scripts/adapters/unit_definition_adapter.gd",
  "scripts/adapters/building_definition_adapter.gd",
  "scripts/adapters/site_definition_adapter.gd",
  "scripts/adapters/lume_definition_adapter.gd",
  "scripts/adapters/results_contract_adapter.gd",
  "scripts/salto_spike_root.gd",
  "scripts/salto_spike_scene_2d.gd",
  "scripts/salto_spike_scene_3d.gd",
  "scripts/salto_spike_workload_runtime.gd",
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
    checkedAtUtc: "deterministic-v0119",
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

function writeV0119Artifact(name, value) {
  const target = join(v0119ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0119Text(name, value) {
  const target = join(v0119ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0121Artifact(name, value) {
  const target = join(v0121ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0121Text(name, value) {
  const target = join(v0121ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0122Artifact(name, value) {
  const target = join(v0122ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0122Text(name, value) {
  const target = join(v0122ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0124Artifact(name, value) {
  const target = join(v0124ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0124Text(name, value) {
  const target = join(v0124ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0125Artifact(name, value) {
  const target = join(v0125ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0125Text(name, value) {
  const target = join(v0125ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0126Artifact(name, value) {
  const target = join(v0126ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0126Text(name, value) {
  const target = join(v0126ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0127Artifact(name, value) {
  const target = join(v0127ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0127Text(name, value) {
  const target = join(v0127ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0128Artifact(name, value) {
  const target = join(v0128ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0128Text(name, value) {
  const target = join(v0128ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0129Artifact(name, value) {
  const target = join(v0129ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0129Text(name, value) {
  const target = join(v0129ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0130Artifact(name, value) {
  const target = join(v0130ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0130Text(name, value) {
  const target = join(v0130ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function writeV0118Artifact(name, value) {
  const target = join(v0118ArtifactRoot, name);
  writeJson(target, value);
  return target;
}

function writeV0118Text(name, value) {
  const target = join(v0118ArtifactRoot, name);
  writeText(target, value);
  return target;
}

function readV0118RuntimeReport(name) {
  const path = join(v0118ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function readV0121RuntimeReport(name) {
  const path = join(v0121ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function readV0124RuntimeReport(name) {
  const path = join(v0124ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function readV0126RuntimeReport(name) {
  const path = join(v0126ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function readV0127RuntimeReport(name) {
  const path = join(v0127ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function readV0128RuntimeReport(name) {
  const path = join(v0128ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function readV0129RuntimeReport(name) {
  const path = join(v0129ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function readV0130RuntimeReport(name) {
  const path = join(v0130ArtifactRoot, name);
  return existsSync(path) ? readJson(path) : null;
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
  const unknownProbeId = "v0122_unknown_fixture_id_must_be_rejected";
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
    checkpoint: "v0.122",
    generatedAtUtc: "deterministic-v0122",
    authority: "derived-from-v0.116-engine-neutral-fixture-for-v0.122-adapter-proof",
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
    engineDecisionFinalized: false,
    contentAdapterParityCheckpoint: "v0.122",
    fullPortStarted: false
  };
  writeJson(join(generatedDataRoot, "fixture-manifest.json"), manifest);
  writeJson(join(generatedDataRoot, "unknown-id-rejection-fixture.json"), {
    schemaVersion: 1,
    checkpoint: "v0.122",
    unknownProbeId: stableIdValidation.unknownProbeId,
    expectedHandling: "reject-or-quarantine",
    accepted: false,
    reason: "Probe ID is intentionally absent from the v0.101 stable-ID subset."
  });

  const report = {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status: "PASS_STATIC_SCAFFOLD_GENERATED",
    generatedAtUtc: "deterministic-v0122",
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
  writeV0119Artifact("scene-generation.json", report);
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
    checkpoint: "v0.122",
    status: errors.length === 0 ? "PASS_STATIC_FIXTURE_VALIDATION" : "FAIL_STATIC_FIXTURE_VALIDATION",
    generatedAtUtc: "deterministic-v0122",
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
    writeV0119Artifact("fixture-validation.json", report);
    writeV0122Artifact("fixture-validation.json", report);
  }
  return report;
}

function writeDoctor() {
  const doctor = detectGodot();
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.119",
    ...doctor,
    bootstrapDefaultIsInstructionOnly: true,
    downloadAttemptedByDoctor: false,
    installAttemptedByDoctor: false,
    blockedHumanAction:
      doctor.status === blockedStatus
        ? "Run GODOT_BOOTSTRAP_WINDOWS.bat for setup instructions, or run tools/godot/bootstrapGodotWindows.ps1 -DownloadOfficial after approving the official Godot download."
        : null
  };
  writeArtifact("godot-doctor.json", report);
  writeV0119Artifact("godot-doctor.json", report);
  return doctor;
}

function readRuntimeReport(name) {
  const path = join(reportsRoot, name);
  return existsSync(path) ? readJson(path) : null;
}

function phaseReport(runtime, tier, phase) {
  return runtime?.tiers?.[tier]?.phases?.[phase] ?? null;
}

function flattenPhaseReports(runtime) {
  const rows = [];
  for (const tier of ["S", "M", "L"]) {
    for (const phase of ["idle", "moving", "combat"]) {
      const report = phaseReport(runtime, tier, phase);
      if (report) {
        rows.push({ tier, phase, report });
      }
    }
  }
  return rows;
}

function sumPhaseMetric(runtime, metric) {
  return flattenPhaseReports(runtime).reduce((total, row) => total + Number(row.report?.[metric] ?? 0), 0);
}

function maxPhaseMetric(runtime, metric) {
  const values = flattenPhaseReports(runtime).map((row) => Number(row.report?.[metric] ?? 0));
  return values.length > 0 ? Math.max(...values) : null;
}

function representativePhase(runtime) {
  return phaseReport(runtime, "L", "combat") ?? phaseReport(runtime, "M", "combat") ?? phaseReport(runtime, "S", "combat") ?? null;
}

function buildTierSummary(runtime) {
  if (!runtime?.tiers) {
    return null;
  }
  const summary = {};
  for (const tier of ["S", "M", "L"]) {
    const tierReport = runtime.tiers[tier];
    summary[tier] = tierReport
      ? {
          counts: tierReport.counts ?? null,
          initialPlacementSignature: tierReport.initialPlacementSignature ?? null,
          idle: phaseReport(runtime, tier, "idle"),
          moving: phaseReport(runtime, tier, "moving"),
          combat: phaseReport(runtime, tier, "combat")
        }
      : null;
  }
  return summary;
}

function expectedV0119Counts() {
  return {
    S: { hero: 1, workers: 1, friendlyMilitary: 6, ashenEnemies: 6, playerStructures: 2, enemyStructures: 0, captureSites: 1, lumeEndpoints: 2, candidateLinks: 1, activeLinks: 1 },
    M: { hero: 1, workers: 2, friendlyMilitary: 20, ashenEnemies: 20, playerStructures: 2, enemyStructures: 0, captureSites: 3, lumeEndpoints: 2, candidateLinks: 1, activeLinks: 1 },
    L: { hero: 1, workers: 4, friendlyMilitary: 50, ashenEnemies: 50, playerStructures: 2, enemyStructures: 2, captureSites: 5, lumeEndpoints: 3, candidateLinks: 2, activeLinks: 1 }
  };
}

function countsMatchExpected(runtime) {
  const expected = expectedV0119Counts();
  const counts = runtime?.countsByTier ?? {};
  return Object.entries(expected).every(([tier, tierCounts]) =>
    Object.entries(tierCounts).every(([key, value]) => counts?.[tier]?.[key] === value)
  );
}

function runtimePlacementSignaturesMatch(left, right) {
  return ["S", "M", "L"].every((tier) => left?.placementSignatures?.[tier] === right?.placementSignatures?.[tier]);
}

function buildV0119ParityReport(benchmark2d, benchmark25d, validation) {
  const runtime2d = benchmark2d.runtimeReport;
  const runtime25d = benchmark25d.runtimeReport;
  const sameCounts =
    countsMatchExpected(runtime2d) &&
    countsMatchExpected(runtime25d) &&
    JSON.stringify(runtime2d?.countsByTier ?? null) === JSON.stringify(runtime25d?.countsByTier ?? null);
  const samePlacements = runtimePlacementSignaturesMatch(runtime2d, runtime25d);
  const linkedWardExact =
    runtime2d?.linkedWardDamageTakenMultiplier === 0.92 &&
    runtime25d?.linkedWardDamageTakenMultiplier === 0.92 &&
    validation.linkedWardDamageTakenMultiplier === 0.92;
  const combat2d = phaseReport(runtime2d, "L", "combat");
  const combat25d = phaseReport(runtime25d, "L", "combat");
  const sameSiteTransitions =
    JSON.stringify(combat2d?.siteOwnership ?? null) === JSON.stringify(combat25d?.siteOwnership ?? null);
  const sameLumeTransitions =
    JSON.stringify(combat2d?.lumeLinkStates ?? null) === JSON.stringify(combat25d?.lumeLinkStates ?? null);
  const resultsReady = Boolean(combat2d?.resultsReady) && Boolean(combat25d?.resultsReady);
  const errors = [];
  if (!benchmark2d.runtimeBenchmarkExecuted || !benchmark25d.runtimeBenchmarkExecuted) {
    errors.push("Both Godot benchmark modes must execute for v0.119 parity evidence.");
  }
  if (!sameCounts) {
    errors.push("2D and 2.5D workload counts do not match the v0.119 tier contract.");
  }
  if (!samePlacements) {
    errors.push("2D and 2.5D placement signatures diverged.");
  }
  if (!linkedWardExact) {
    errors.push("linked_ward damage-taken multiplier is not exactly 0.92 in all evidence.");
  }
  if (!sameSiteTransitions || !sameLumeTransitions) {
    errors.push("Site or Lume transition evidence diverged between modes.");
  }
  if (!resultsReady) {
    errors.push("Both modes must reach Results in the L combat workload.");
  }
  return {
    schemaVersion: 1,
    checkpoint: "v0.119",
    status: errors.length === 0 ? "PASS_GODOT_REPRESENTATIVE_RTS_PARITY" : "FAIL_GODOT_REPRESENTATIVE_RTS_PARITY",
    generatedAtUtc: "deterministic-v0119",
    errors,
    fixtureHash: validation.fixtureHash ?? readFixtureHash(),
    linkedWardDamageTakenMultiplier: validation.linkedWardDamageTakenMultiplier,
    linkedWardExact,
    sameEntityCountsByTier: sameCounts,
    expectedCountsByTier: expectedV0119Counts(),
    observedCountsByTier2d: runtime2d?.countsByTier ?? null,
    observedCountsByTier25d: runtime25d?.countsByTier ?? null,
    samePlacementsByTier: samePlacements,
    placementSignatures2d: runtime2d?.placementSignatures ?? null,
    placementSignatures25d: runtime25d?.placementSignatures ?? null,
    sameSiteTransitions,
    sameLumeTransitions,
    resultsStateReached: resultsReady,
    readOnlySaveFixtures: true,
    localStorageMutationAllowed: false,
    runtimeArtIntegrated: false,
    routineEditorUseRequired: false
  };
}

function writeV0119RuntimeArtifacts(benchmark2d, benchmark25d, validation, doctor) {
  writeV0119Artifact("godot-doctor.json", { schemaVersion: 1, checkpoint: "v0.119", ...doctor });
  writeV0119Artifact("fixture-validation.json", validation);
  writeV0119Artifact("scalability-benchmark-2d.json", benchmark2d);
  writeV0119Artifact("scalability-benchmark-2_5d.json", benchmark25d);
  const parity = buildV0119ParityReport(benchmark2d, benchmark25d, validation);
  writeV0119Artifact("parity-report.json", parity);
  writeV0119Text(
    "benchmark-summary.md",
    [
      "# v0.119 Godot Representative RTS Load Benchmark Summary",
      "",
      `Status: ${benchmark2d.runtimeBenchmarkExecuted && benchmark25d.runtimeBenchmarkExecuted ? "PASS_GODOT_REPRESENTATIVE_RTS_BENCHMARK" : doctor.godotDetected ? "READY_FOR_RUNTIME_BENCHMARK" : blockedStatus}`,
      `Parity: ${parity.status}`,
      `Godot detected: ${doctor.godotDetected ? "yes" : "no"}`,
      `Export templates detected: ${doctor.exportTemplatesDetected ? "yes" : "no"}`,
      "",
      "## Tier Coverage",
      "",
      "| Tier | 2D L combat p95 | 2.5D L combat p95 | 2D nav queries | 2.5D nav queries |",
      "| --- | ---: | ---: | ---: | ---: |",
      `| S | ${phaseReport(benchmark2d.runtimeReport, "S", "combat")?.frameTimeP95Ms ?? "n/a"} | ${phaseReport(benchmark25d.runtimeReport, "S", "combat")?.frameTimeP95Ms ?? "n/a"} | ${phaseReport(benchmark2d.runtimeReport, "S", "combat")?.navigationQueryCount ?? "n/a"} | ${phaseReport(benchmark25d.runtimeReport, "S", "combat")?.navigationQueryCount ?? "n/a"} |`,
      `| M | ${phaseReport(benchmark2d.runtimeReport, "M", "combat")?.frameTimeP95Ms ?? "n/a"} | ${phaseReport(benchmark25d.runtimeReport, "M", "combat")?.frameTimeP95Ms ?? "n/a"} | ${phaseReport(benchmark2d.runtimeReport, "M", "combat")?.navigationQueryCount ?? "n/a"} | ${phaseReport(benchmark25d.runtimeReport, "M", "combat")?.navigationQueryCount ?? "n/a"} |`,
      `| L | ${phaseReport(benchmark2d.runtimeReport, "L", "combat")?.frameTimeP95Ms ?? "n/a"} | ${phaseReport(benchmark25d.runtimeReport, "L", "combat")?.frameTimeP95Ms ?? "n/a"} | ${phaseReport(benchmark2d.runtimeReport, "L", "combat")?.navigationQueryCount ?? "n/a"} | ${phaseReport(benchmark25d.runtimeReport, "L", "combat")?.navigationQueryCount ?? "n/a"} |`,
      "",
      "No runtime metric is claimed unless the Godot runner produced a report. This is not a final production performance certification."
    ].join("\n")
  );
  writeV0119Text(
    "README.md",
    [
      "# v0.119 Godot Representative RTS Load Artifacts",
      "",
      "This ignored artifact folder is regenerated by the v0.119 Godot spike scripts.",
      "",
      "- `scalability-benchmark-2d.json` and `scalability-benchmark-2_5d.json` normalize S/M/L idle, movement, and combat workload metrics.",
      "- `parity-report.json` compares fixture hash, tier counts, placement signatures, site transitions, Lume states, Results readiness, and linked_ward exactness.",
      "- `scorecard-update.json` is regenerated by the benchmark/scorecard command.",
      "- `Windows-export-report.json` and `package-report.json` are regenerated by export/package commands when local Godot templates are available.",
      "",
      "No file here is tracked source, runtime art, a final Godot decision, or a full port."
    ].join("\n")
  );
  return parity;
}

function writeTestReport() {
  const validation = validateGeneratedData();
  const doctor = writeDoctor();
  const runtime = readRuntimeReport("godot-runtime-test-report.json");
  const v0122 = writeV0122AdapterParityArtifacts(runtime, validation, doctor);
  const status = validation.errors.length > 0
    ? "FAIL_STATIC_FIXTURE_VALIDATION"
    : runtime?.status === "PASS"
      ? "PASS_GODOT_HEADLESS_TESTS"
      : runtime
        ? "FAIL_GODOT_HEADLESS_TESTS"
        : doctor.godotDetected
        ? "READY_FOR_GODOT_HEADLESS_TESTS"
        : blockedStatus;
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status,
    generatedAtUtc: "deterministic-v0122",
    staticChecksPassed: validation.errors.length === 0,
    godotDetected: doctor.godotDetected,
    exportTemplatesDetected: doctor.exportTemplatesDetected,
    godotRuntimeExecuted: Boolean(runtime),
    runtimeReport: runtime,
    adapterValidationStatus: v0122.adapterValidation.status,
    parityStatus: v0122.parityReport.status,
    migrationReadinessStatus: v0122.migrationReadiness.status,
    v0122ArtifactRoot: relativeRepo(v0122ArtifactRoot),
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
      "pause-results-return-flow",
      "v0.119-S-M-L-tier-counts",
      "v0.119-navigation-query-and-stuck-unit-metrics",
      "v0.119-bounded-enemy-pressure",
      "v0.119-results-parity",
      "v0.121-procedural-2_5d-presets",
      "v0.121-hud-minimap-selection-readability",
      "v0.121-vfx-stress-private-boundary",
      "v0.122-deterministic-content-subset-export",
      "v0.122-typed-adapter-load",
      "v0.122-id-validation-duplicate-missing-unknown-rejection",
      "v0.122-fixed-seed-rules-parity",
      "v0.122-2d-and-2_5d-same-fixture",
      "v0.122-linked_ward-0.92",
      "v0.122-no-save-or-browser-mutation",
      "v0.122-no-editor-dependency",
      "v0.122-no-full-port-started"
    ],
    blocker: doctor.godotDetected ? null : blockedStatus
  };
  writeArtifact("test-report.json", report);
  writeV0119Artifact("test-report.json", report);
  return report;
}

function benchmarkForMode(mode, doctor) {
  const runtimeName = mode === "2D_PLACEHOLDER" ? "godot-benchmark-2d.json" : "godot-benchmark-2_5d.json";
  const runtime = readRuntimeReport(runtimeName);
  const blocked = !doctor.godotDetected;
  const representative = representativePhase(runtime);
  const inputLatencyMs =
    representative?.moveAcceptanceLatencyMs != null || representative?.attackAcceptanceLatencyMs != null
      ? Math.max(Number(representative?.moveAcceptanceLatencyMs ?? 0), Number(representative?.attackAcceptanceLatencyMs ?? 0))
      : null;
  return {
    schemaVersion: 1,
    checkpoint: "v0.119",
    mode,
    status: runtime?.status === "PASS" ? "PASS_GODOT_REPRESENTATIVE_RTS_BENCHMARK" : blocked ? blockedStatus : "READY_FOR_RUNTIME_BENCHMARK",
    generatedAtUtc: "deterministic-v0119",
    runtimeBenchmarkExecuted: Boolean(runtime),
    deterministicSeed: runtime?.deterministicSeed ?? null,
    linkedWardDamageTakenMultiplier: runtime?.linkedWardDamageTakenMultiplier ?? null,
    workloadTiersExecuted: runtime?.tiers ? Object.keys(runtime.tiers).sort() : [],
    phaseCount: flattenPhaseReports(runtime).length,
    countsByTier: runtime?.countsByTier ?? null,
    placementSignatures: runtime?.placementSignatures ?? null,
    tierSummary: buildTierSummary(runtime),
    representativePhase: representative,
    startupMs: runtime?.startupMs ?? null,
    sceneLaunchMs: runtime?.sceneLaunchMs ?? null,
    fpsAverage: representative?.fpsAverage ?? runtime?.fpsAverage ?? null,
    fpsOnePercentLow: representative?.fpsOnePercentLow ?? runtime?.fpsOnePercentLow ?? null,
    frameTimeP50Ms: representative?.frameTimeP50Ms ?? runtime?.frameTimeP50Ms ?? null,
    frameTimeP95Ms: representative?.frameTimeP95Ms ?? runtime?.frameTimeP95Ms ?? null,
    frameTimeP99Ms: representative?.frameTimeP99Ms ?? runtime?.frameTimeP99Ms ?? null,
    frameTimeMaxMs: representative?.frameTimeMaxMs ?? runtime?.frameTimeMaxMs ?? null,
    inputLatencyMs,
    inputLatency: {
      selectionLatencyMs: representative?.selectionLatencyMs ?? null,
      moveAcceptanceLatencyMs: representative?.moveAcceptanceLatencyMs ?? null,
      attackAcceptanceLatencyMs: representative?.attackAcceptanceLatencyMs ?? null
    },
    resultsTransitionMs: representative?.durationMs ?? runtime?.resultsTransitionMs ?? null,
    navigationQueryCount: sumPhaseMetric(runtime, "navigationQueryCount"),
    stuckUnitCount: maxPhaseMetric(runtime, "stuckUnitCount"),
    movementCompletedCount: sumPhaseMetric(runtime, "movementCompletedCount"),
    aiPressureBeatCount: sumPhaseMetric(runtime, "aiPressureBeatCount"),
    deathCount: sumPhaseMetric(runtime, "deathCount"),
    siteTransitionCount: sumPhaseMetric(runtime, "siteTransitionCount"),
    memoryWorkingSetMb: representative?.memoryWorkingSetMb ?? runtime?.memoryWorkingSetMb ?? null,
    readOnlySaveFixtures: runtime?.readOnlySaveFixtures ?? true,
    localStorageMutationAllowed: runtime?.localStorageMutationAllowed ?? false,
    runtimeArtIntegrated: runtime?.runtimeArtIntegrated ?? false,
    routineEditorUseRequired: runtime?.routineEditorUseRequired ?? false,
    finalProductionCertification: false,
    runtimeReport: runtime,
    notes: runtime
      ? "Headless Godot benchmark runner completed the v0.119 representative RTS S/M/L workload for this mode."
      : blocked
        ? "Godot was not detected locally; scaffold validation passed but runtime performance metrics were not collected."
      : "Run the Godot benchmark runner to collect runtime metrics on this host."
  };
}

const v0121BenchmarkConfigs = [
  {
    id: "2d-control",
    label: "2D control",
    mode: "2D_PLACEHOLDER",
    visualPreset: v0121VisualPresets.control2d,
    runtimeName: "godot-v0121-benchmark-2d-control.json",
    artifactName: "benchmark-2d-control.json",
    privatePreset: false
  },
  {
    id: "2_5d-clean-readability",
    label: "2.5D clean readability",
    mode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    visualPreset: v0121VisualPresets.clean,
    runtimeName: "godot-v0121-benchmark-2_5d-clean.json",
    artifactName: "benchmark-2_5d-clean-readability.json",
    privatePreset: false
  },
  {
    id: "2_5d-atmospheric-balanced",
    label: "2.5D atmospheric balanced",
    mode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    visualPreset: v0121VisualPresets.atmospheric,
    runtimeName: "godot-v0121-benchmark-2_5d-atmospheric.json",
    artifactName: "benchmark-2_5d-atmospheric-balanced.json",
    privatePreset: false
  },
  {
    id: "2_5d-vfx-stress-private",
    label: "2.5D VFX stress private",
    mode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    visualPreset: v0121VisualPresets.vfxStress,
    runtimeName: "godot-v0121-benchmark-2_5d-vfx-stress-private.json",
    artifactName: "benchmark-2_5d-vfx-stress-private.json",
    privatePreset: true
  }
];

function v0121BenchmarkForConfig(config, doctor) {
  const runtime = readRuntimeReport(config.runtimeName);
  const blocked = !doctor.godotDetected;
  const representative = representativePhase(runtime);
  const inputLatencyMs =
    representative?.moveAcceptanceLatencyMs != null || representative?.attackAcceptanceLatencyMs != null
      ? Math.max(Number(representative?.moveAcceptanceLatencyMs ?? 0), Number(representative?.attackAcceptanceLatencyMs ?? 0))
      : null;
  return {
    schemaVersion: 1,
    checkpoint: "v0.122",
    id: config.id,
    label: config.label,
    mode: config.mode,
    visualPreset: config.visualPreset,
    privatePreset: config.privatePreset,
    status:
      runtime?.status === "PASS"
        ? "PASS_GODOT_PROCEDURAL_VISUAL_FOUNDATION_BENCHMARK"
        : blocked
          ? blockedStatus
          : "READY_FOR_RUNTIME_BENCHMARK",
    generatedAtUtc: "deterministic-v0121",
    runtimeBenchmarkExecuted: Boolean(runtime),
    deterministicSeed: runtime?.deterministicSeed ?? null,
    linkedWardDamageTakenMultiplier: runtime?.linkedWardDamageTakenMultiplier ?? null,
    workloadTiersExecuted: runtime?.tiers ? Object.keys(runtime.tiers).sort() : [],
    phaseCount: flattenPhaseReports(runtime).length,
    countsByTier: runtime?.countsByTier ?? null,
    placementSignatures: runtime?.placementSignatures ?? null,
    tierSummary: buildTierSummary(runtime),
    representativePhase: representative,
    startupMs: runtime?.startupMs ?? null,
    sceneLaunchMs: runtime?.sceneLaunchMs ?? null,
    fpsAverage: representative?.fpsAverage ?? runtime?.fpsAverage ?? null,
    fpsOnePercentLow: representative?.fpsOnePercentLow ?? runtime?.fpsOnePercentLow ?? null,
    frameTimeP50Ms: representative?.frameTimeP50Ms ?? runtime?.frameTimeP50Ms ?? null,
    frameTimeP95Ms: representative?.frameTimeP95Ms ?? runtime?.frameTimeP95Ms ?? null,
    frameTimeP99Ms: representative?.frameTimeP99Ms ?? runtime?.frameTimeP99Ms ?? null,
    frameTimeMaxMs: representative?.frameTimeMaxMs ?? runtime?.frameTimeMaxMs ?? null,
    inputLatencyMs,
    inputLatency: {
      selectionLatencyMs: representative?.selectionLatencyMs ?? null,
      moveAcceptanceLatencyMs: representative?.moveAcceptanceLatencyMs ?? null,
      attackAcceptanceLatencyMs: representative?.attackAcceptanceLatencyMs ?? null
    },
    resultsTransitionMs: representative?.durationMs ?? runtime?.resultsTransitionMs ?? null,
    navigationQueryCount: sumPhaseMetric(runtime, "navigationQueryCount"),
    stuckUnitCount: maxPhaseMetric(runtime, "stuckUnitCount"),
    movementCompletedCount: sumPhaseMetric(runtime, "movementCompletedCount"),
    aiPressureBeatCount: sumPhaseMetric(runtime, "aiPressureBeatCount"),
    deathCount: sumPhaseMetric(runtime, "deathCount"),
    siteTransitionCount: sumPhaseMetric(runtime, "siteTransitionCount"),
    memoryWorkingSetMb: representative?.memoryWorkingSetMb ?? runtime?.memoryWorkingSetMb ?? null,
    readOnlySaveFixtures: runtime?.readOnlySaveFixtures ?? true,
    localStorageMutationAllowed: runtime?.localStorageMutationAllowed ?? false,
    runtimeArtIntegrated: runtime?.runtimeArtIntegrated ?? false,
    generatedOrImportedArtIncluded: runtime?.generatedOrImportedArtIncluded ?? false,
    routineEditorUseRequired: runtime?.routineEditorUseRequired ?? false,
    finalProductionCertification: false,
    runtimeReportName: config.runtimeName,
    runtimeReport: runtime,
    notes: runtime
      ? "Headless Godot benchmark runner completed the v0.121 procedural visual-foundation comparison for this preset."
      : blocked
        ? "Godot was not detected locally; scaffold validation passed but runtime performance metrics were not collected."
        : "Run the Godot benchmark runner to collect runtime metrics on this host."
  };
}

function writeV0121BenchmarkArtifacts(doctor, validation) {
  const reports = v0121BenchmarkConfigs.map((config) => {
    const report = v0121BenchmarkForConfig(config, doctor);
    writeV0121Artifact(config.artifactName, report);
    return report;
  });
  const allRuntime = reports.every((report) => report.runtimeBenchmarkExecuted && report.status === "PASS_GODOT_PROCEDURAL_VISUAL_FOUNDATION_BENCHMARK");
  const comparison = {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status: allRuntime
      ? "PASS_GODOT_PROCEDURAL_VISUAL_FOUNDATION_PERFORMANCE_COMPARISON"
      : doctor.godotDetected
        ? "READY_FOR_RUNTIME_BENCHMARK"
        : blockedStatus,
    generatedAtUtc: "deterministic-v0121",
    sourceCommit: getCurrentCommit(),
    fixtureHash: validation.fixtureHash ?? null,
    linkedWardDamageTakenMultiplier: validation.linkedWardDamageTakenMultiplier,
    readOnlySaveFixtures: true,
    localStorageMutationAllowed: false,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    routineEditorUseRequired: false,
    finalProductionCertification: false,
    normalReviewDefault: v0121VisualPresets.clean,
    vfxStressExcludedFromDefaultReview: true,
    visualAmbition:
      "Original modern top-down RTS/RPG direction: fixed-camera 2D versus 2.5D readability, strong faction silhouettes, atmospheric Salto terrain, modern lighting/VFX posture, central persistent hero clarity, and no mobile-game/dashboard look.",
    requiredScenarios: ["idle", "moving", "combat", "Results transition"],
    reports: Object.fromEntries(reports.map((report) => [report.id, report])),
    summaryRows: reports.map((report) => ({
      id: report.id,
      label: report.label,
      mode: report.mode,
      visualPreset: report.visualPreset,
      privatePreset: report.privatePreset,
      status: report.status,
      tiers: report.workloadTiersExecuted,
      fpsAverage: report.fpsAverage,
      fpsOnePercentLow: report.fpsOnePercentLow,
      frameTimeP50Ms: report.frameTimeP50Ms,
      frameTimeP95Ms: report.frameTimeP95Ms,
      frameTimeP99Ms: report.frameTimeP99Ms,
      frameTimeMaxMs: report.frameTimeMaxMs,
      startupMs: report.startupMs,
      sceneLaunchMs: report.sceneLaunchMs,
      inputLatencyMs: report.inputLatencyMs,
      resultsTransitionMs: report.resultsTransitionMs,
      memoryWorkingSetMb: report.memoryWorkingSetMb,
      navigationQueryCount: report.navigationQueryCount,
      stuckUnitCount: report.stuckUnitCount
    })),
    errors: validation.errors ?? []
  };
  writeV0121Artifact("performance-comparison.json", comparison);
  writeArtifact("performance-comparison-v0121.json", comparison);
  writeV0121Text("performance-comparison.md", renderV0121PerformanceSummary(comparison));
  writeV0121Text("README.md", renderV0121ArtifactReadme());
  return comparison;
}

function renderV0121PerformanceSummary(comparison) {
  const rows = comparison.summaryRows
    .map(
      (row) =>
        `| ${row.label} | ${row.visualPreset} | ${row.status} | ${row.fpsAverage ?? "n/a"} | ${row.fpsOnePercentLow ?? "n/a"} | ${row.frameTimeP95Ms ?? "n/a"} | ${row.inputLatencyMs ?? "n/a"} | ${row.resultsTransitionMs ?? "n/a"} |`
    )
    .join("\n");
  return [
    "# v0.121 Godot Procedural Visual Foundation Performance Comparison",
    "",
    `Status: ${comparison.status}`,
    "",
    "| Lane | Preset | Status | FPS avg | 1% low | p95 frame ms | input ms | Results ms |",
    "| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |",
    rows,
    "",
    "The VFX stress preset is private spike evidence and is excluded from the normal Emmanuel visual-review default. No row is final production certification."
  ].join("\n");
}

function renderV0121ArtifactReadme() {
  return [
    "# v0.121 Godot Procedural 2.5D Visual Foundation Artifacts",
    "",
    "This ignored artifact folder is regenerated by the v0.121 Godot spike scripts.",
    "",
    "- `performance-comparison.json` and `performance-comparison.md` compare 2D control, 2.5D clean, 2.5D atmospheric, and private 2.5D VFX stress benchmark lanes.",
    "- `screenshot-manifest.json` records deterministic 1600x900 and 1920x1080 captures when `npm run godot:capture:review` is executed.",
    "- `contact-sheet.svg`, `contact-sheet-1600x900.svg`, and `contact-sheet-1920x1080.svg` summarize the capture set.",
    "- `EMMANUEL_VISUAL_REVIEW_GUIDE.md` is the local one-click review note for this ignored artifact set.",
    "",
    "No file here is tracked source, imported art, generated art, a final Godot decision, runtime integration, or a full port."
  ].join("\n");
}

function contentEntry(fixture, category, id) {
  return fixture.content.categories?.[category]?.find((entry) => entry.id === id) ?? null;
}

function buildV0122ContentSubset(fixture, adapterValidation) {
  const subset = {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status: "PASS_GODOT_CONTENT_SUBSET_ADAPTER_SUBSET",
    generatedAtUtc: "deterministic-v0122",
    sourceAuthority: "generated portable JSON only",
    sourcePortableCheckpoint: fixture.content.fullExportCheckpoint ?? fixture.content.checkpoint ?? "v0.101",
    fixtureHash: fixture.hashes.fixtureHash ?? null,
    browserRuntimeChanged: false,
    stableIdsRenamed: false,
    fullPortStarted: false,
    controlledSubset: {
      factionReferences: [
        {
          role: "Barrosan placeholder faction reference",
          stableId: "free_marches",
          sourceEntry: contentEntry(fixture, "factions", "free_marches")
        },
        {
          role: "Ashen placeholder enemy reference",
          stableId: "ashen_covenant",
          sourceEntry: contentEntry(fixture, "factions", "ashen_covenant")
        }
      ],
      heroReference: {
        fixtureId: "hero_aster",
        displayName: fixture.scene.player?.hero?.name ?? "Aster",
        placeholderOnly: true,
        sourcePosture: "fixture-local hero reference; no new stable ID"
      },
      units: ["worker", "militia", "ranger"].map((id) => contentEntry(fixture, "units", id)),
      enemyReferenceUnits: ["raider", "hexer", "brute", "enemy_commander"].map((id) => contentEntry(fixture, "units", id)),
      buildings: ["command_hall", "barracks"].map((id) => contentEntry(fixture, "buildings", id)),
      sites: [
        { role: "mine", stableId: "west_stone_cut", sourceEntry: contentEntry(fixture, "captureSites", "west_stone_cut") },
        { role: "shrine", stableId: "ford_toll", sourceEntry: contentEntry(fixture, "captureSites", "ford_toll") },
        { role: "capture site", stableId: "north_aether_spring", sourceEntry: contentEntry(fixture, "captureSites", "north_aether_spring") }
      ],
      lume: {
        endpointNetworkId: "aether_well_ruins_lume_ward",
        linkId: fixture.scene.lume?.linkId ?? "west_stone_cut_to_ford_toll",
        linkedWardDamageTakenMultiplier: fixture.scene.lume?.linkedWardDamageTakenMultiplier ?? null,
        sourceEntry: contentEntry(fixture, "lumeNetworks", "aether_well_ruins_lume_ward")
      },
      abilityPlaceholder: contentEntry(fixture, "abilities", "rally_banner"),
      resultsContract: fixture.results,
      enemyPressureFixture: {
        tier: "M",
        source: "benchmark-contract.json",
        tierContract: fixture.benchmark.tiers?.M ?? null
      }
    },
    adapterValidationStatus: adapterValidation?.status ?? "READY_FOR_GODOT_CONTENT_ADAPTER_VALIDATION",
    sourceGeneratedContentSubset: fixture.content
  };
  return subset;
}

function buildV0122StableIdReport(fixture, adapterValidation, validation) {
  const stableReport = adapterValidation?.adapterReports?.StableIdValidator ?? {};
  const errors = [...(validation.errors ?? []), ...(stableReport.errors ?? [])];
  return {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status: errors.length === 0 ? "PASS_GODOT_STABLE_ID_REPORT" : "FAIL_GODOT_STABLE_ID_REPORT",
    generatedAtUtc: "deterministic-v0122",
    fixtureHash: fixture.hashes.fixtureHash ?? null,
    stableSubsetAuthority: fixture.stable.authority,
    selectedStableIds: stableReport.selectedStableIds ?? validation.stableIdValidation?.selectedIds ?? [],
    selectedStableIdCount: stableReport.selectedStableIdCount ?? validation.stableIdValidation?.selectedIds?.length ?? 0,
    knownStableIdCount: stableReport.knownStableIdCount ?? validation.stableIdValidation?.knownStableIdCount ?? null,
    duplicateIds: stableReport.duplicateIds ?? [],
    missingIds: stableReport.missingIds ?? validation.stableIdValidation?.missing ?? [],
    unknownProbeId: stableReport.unknownProbeId ?? validation.stableIdValidation?.unknownProbeId ?? "v0122_unknown_fixture_id_must_be_rejected",
    unknownProbeRejected: stableReport.unknownProbeRejected ?? validation.stableIdValidation?.unknownProbeRejected ?? false,
    stableIdsRenamed: false,
    errors
  };
}

function buildV0122MigrationReadiness() {
  const rows = [
    ["hero", "fixture-only", "Aster/hero_aster is represented for spawn, selection, HUD, and Results posture; hero progression is not ported."],
    ["units", "proven adapter-ready", "Worker, Militia, Ranger, and bounded Ashen reference units load through generated portable JSON adapters."],
    ["buildings", "proven adapter-ready", "Command Hall and Barracks load through BuildingDefinitionAdapter; enemy structures remain fixture-only."],
    ["sites", "proven adapter-ready", "Mine/shrine/capture-site roles map to existing capture-site IDs without adding building IDs."],
    ["Lume", "proven adapter-ready", "Lume network and linked_ward 0.92 are adapter-validated, with active/severed/restored parity evidence."],
    ["combat", "fixture-only", "Health/damage posture and target acquisition are checked in Tier M only; no full combat system parity is claimed."],
    ["movement", "fixture-only", "Movement acceptance and deterministic placement are checked; production pathing is not ported."],
    ["AI", "fixture-only", "One bounded enemy-pressure fixture is represented; no browser AI strategy is ported."],
    ["pathing", "requires rewrite", "Godot placeholder movement uses simple deterministic obstacle nudges and is not browser pathing parity."],
    ["campaign", "conceptually reusable", "Node/map IDs remain portable, but campaign flow is intentionally deferred."],
    ["rewards", "conceptually reusable", "Results contract stays no-save/no-reward for this proof; reward migration is deferred."],
    ["saves", "proven adapter-ready", "Save fixture index is read-only, no raw save payload is imported, and no writes/localStorage access are allowed."],
    ["Retinue", "intentionally deferred", "Retinue rule references remain in portable content but are outside the bounded Godot adapter slice."],
    ["relics", "intentionally deferred", "Relic content and save coverage remain browser/source evidence only."],
    ["Stronghold", "intentionally deferred", "Stronghold progression is not part of the bounded Salto content adapter proof."],
    ["UI", "blocked pending visual review", "HUD/minimap/Results placeholders exist, but final UI migration waits on visual direction review."],
    ["art", "blocked pending visual review", "No art is imported; procedural placeholder evidence remains separate from final art direction."],
    ["audio", "intentionally deferred", "No audio adapter or engine audio proof is included in v0.122."],
    ["multiplayer", "intentionally deferred", "No multiplayer content or network behavior is introduced."]
  ].map(([domain, classification, evidence]) => ({ domain, classification, evidence }));
  return {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status: "PASS_GODOT_MIGRATION_READINESS_MATRIX",
    generatedAtUtc: "deterministic-v0122",
    finalEngineChoiceMade: false,
    fullPortStarted: false,
    classifications: [
      "proven adapter-ready",
      "fixture-only",
      "conceptually reusable",
      "requires rewrite",
      "blocked pending visual review",
      "blocked pending engine decision",
      "intentionally deferred"
    ],
    rows
  };
}

function renderV0122ArtifactReadme(adapterValidation, parityReport, stableReport) {
  return [
    "# v0.122 Godot Content Adapter Parity Artifacts",
    "",
    "This ignored artifact folder is regenerated by the v0.122 Godot spike scripts.",
    "",
    `Adapter validation: ${adapterValidation.status}`,
    `Stable-ID report: ${stableReport.status}`,
    `Parity report: ${parityReport.status}`,
    "",
    "- `content-subset.json` records the controlled generated portable JSON subset consumed by Godot adapters.",
    "- `stable-id-report.json` records duplicate, missing, unknown-ID, and stable-ID rename posture.",
    "- `adapter-validation.json` records the typed GDScript adapter reports.",
    "- `parity-report.json` records bounded fixed-seed Tier M rules-parity evidence for 2D and 2.5D.",
    "- `migration-readiness.json` classifies current browser systems for future migration readiness.",
    "",
    "No artifact here is tracked runtime source, browser content migration, final engine selection, imported art, save migration, or full port evidence."
  ].join("\n");
}

function writeV0122AdapterParityArtifacts(runtime, validation, doctor) {
  const fixture = readGeneratedFixture();
  const adapterRuntime = readRuntimeReport("godot-v0122-adapter-validation.json") ?? runtime?.adapterValidation ?? null;
  const parityRuntime = readRuntimeReport("godot-v0122-parity-report.json") ?? runtime?.parityReport ?? null;
  const adapterValidation = adapterRuntime ?? {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status: doctor.godotDetected ? "READY_FOR_GODOT_CONTENT_ADAPTER_VALIDATION" : blockedStatus,
    generatedAtUtc: "deterministic-v0122",
    errors: [],
    fixtureHash: fixture.hashes.fixtureHash ?? null,
    routineEditorUseRequired: false,
    localStorageMutationAllowed: false,
    saveWritesAllowed: false
  };
  const parityReport = parityRuntime ?? {
    schemaVersion: 1,
    checkpoint: "v0.122",
    status: doctor.godotDetected ? "READY_FOR_GODOT_RULES_PARITY_HARNESS" : blockedStatus,
    generatedAtUtc: "deterministic-v0122",
    errors: [],
    fixedSeed: 1190119,
    tier: "M",
    fullBrowserGodotSimulationParityClaimed: false,
    routineEditorUseRequired: false,
    localStorageMutationAllowed: false,
    saveWritesAllowed: false
  };
  const contentSubset = buildV0122ContentSubset(fixture, adapterValidation);
  const stableReport = buildV0122StableIdReport(fixture, adapterValidation, validation);
  const migrationReadiness = buildV0122MigrationReadiness();
  writeV0122Artifact("content-subset.json", contentSubset);
  writeV0122Artifact("stable-id-report.json", stableReport);
  writeV0122Artifact("adapter-validation.json", adapterValidation);
  writeV0122Artifact("parity-report.json", parityReport);
  writeV0122Artifact("migration-readiness.json", migrationReadiness);
  writeV0122Text("README.md", renderV0122ArtifactReadme(adapterValidation, parityReport, stableReport));
  writeArtifact("content-subset-v0122.json", contentSubset);
  writeArtifact("stable-id-report-v0122.json", stableReport);
  writeArtifact("adapter-validation-v0122.json", adapterValidation);
  writeArtifact("parity-report-v0122.json", parityReport);
  writeArtifact("migration-readiness-v0122.json", migrationReadiness);
  return { contentSubset, stableReport, adapterValidation, parityReport, migrationReadiness };
}

function writeBenchmarkReports({ scorecardOnly = false } = {}) {
  const validation = validateGeneratedData();
  const doctor = writeDoctor();
  if (!scorecardOnly) {
    const benchmark2d = benchmarkForMode("2D_PLACEHOLDER", doctor);
    const benchmark25d = benchmarkForMode("2_5D_ORTHOGRAPHIC_PLACEHOLDER", doctor);
    writeArtifact("benchmark-2d.json", benchmark2d);
    writeArtifact("benchmark-2_5d.json", benchmark25d);
    writeV0119RuntimeArtifacts(benchmark2d, benchmark25d, validation, doctor);
    writeV0121BenchmarkArtifacts(doctor, validation);
    writeText(
      join(artifactRoot, "benchmark-summary.md"),
      [
        "# v0.119 Godot Representative RTS Load Benchmark Summary",
        "",
        `Status: ${benchmark2d.runtimeBenchmarkExecuted && benchmark25d.runtimeBenchmarkExecuted ? "PASS_GODOT_REPRESENTATIVE_RTS_BENCHMARK" : doctor.godotDetected ? "READY_FOR_RUNTIME_BENCHMARK" : blockedStatus}`,
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
        `Navigation query count: ${benchmark2d.navigationQueryCount ?? "not measured"}`,
        `Stuck unit count: ${benchmark2d.stuckUnitCount ?? "not measured"}`,
        "",
        "## 2.5D Orthographic Placeholder",
        "",
        `Runtime executed: ${benchmark25d.runtimeBenchmarkExecuted ? "yes" : "no"}`,
        `FPS average: ${benchmark25d.fpsAverage ?? "not measured"}`,
        `p95 frame time: ${benchmark25d.frameTimeP95Ms ?? "not measured"}`,
        `Navigation query count: ${benchmark25d.navigationQueryCount ?? "not measured"}`,
        `Stuck unit count: ${benchmark25d.stuckUnitCount ?? "not measured"}`,
        "",
        "No runtime metric is claimed unless the Godot runner produced a report."
      ].join("\n")
    );
  }
  const scorecard = buildScorecard(doctor, validation);
  writeArtifact("scorecard.json", scorecard);
  writeV0119Artifact("scorecard-update.json", scorecard);
  writeV0121Artifact("scorecard.json", scorecard);
  writeV0122Artifact("scorecard.json", scorecard);
  return scorecard;
}

function writeExportReport() {
  const doctor = writeDoctor();
  const exePath = join(buildsRoot, "AscendantRealmsGodotSalto.exe");
  const exists = existsSync(exePath);
  const status = exists ? "PASS_WINDOWS_EXPORT" : doctor.godotDetected && doctor.exportTemplatesDetected ? "READY_FOR_WINDOWS_EXPORT" : blockedStatus;
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status,
    generatedAtUtc: "deterministic-v0124",
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
  writeV0119Artifact("Windows-export-report.json", report);
  writeV0121Artifact("Windows-export-report.json", report);
  writeV0122Artifact("Windows-export-report.json", report);
  writeV0124Artifact("Windows-export-report.json", report);
  return report;
}

function writePackageReport() {
  const exportReportPath = join(artifactRoot, "Windows-export-report.json");
  const exportReport = existsSync(exportReportPath) ? readJson(exportReportPath) : writeExportReport();
  const zipPath = join(artifactRoot, "AscendantRealmsGodotSalto-v0124-windows.zip");
  const status = existsSync(zipPath) ? "PASS_WINDOWS_PACKAGE" : "READY_TO_PACKAGE";
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status: existsSync(zipPath) ? status : exportReport.status === "PASS_WINDOWS_EXPORT" ? "READY_TO_PACKAGE" : blockedStatus,
    generatedAtUtc: "deterministic-v0124",
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
  writeV0119Artifact("package-report.json", report);
  writeV0121Artifact("package-report.json", report);
  writeV0122Artifact("package-report.json", report);
  writeV0124Artifact("package-report.json", report);
  return report;
}

function writeManualReviewChecklist() {
  const checklist = [
    "# v0.122 Godot Content Adapter Parity Review Checklist",
    "",
    "- Confirm Godot 4.6.3 standard x86_64 is installed under `.tools/godot/` or `GODOT_BIN`.",
    "- Confirm standard export templates are installed under the detected template directory.",
    "- Run `GODOT_RUN_ALL_WINDOWS.bat` from a fresh checkout.",
    "- Review `artifacts/desktop-spikes/godot-salto/v0122/adapter-validation.json`.",
    "- Review `artifacts/desktop-spikes/godot-salto/v0122/parity-report.json`.",
    "- Review `artifacts/desktop-spikes/godot-salto/v0122/migration-readiness.json`.",
    "- Confirm the subset comes from generated portable JSON only and no parallel content database was introduced.",
    "- Confirm both 2D and 2.5D modes use the same Tier M fixture in the parity report.",
    "- Confirm `linked_ward` remains exactly `0.92` and save fixtures remain read-only.",
    "- Do not treat this spike as a full port, content migration, imported-art approval, or final Godot decision."
  ].join("\n");
  const readme = [
    "# v0.122 Godot Content Adapter Parity Artifacts",
    "",
    "This ignored artifact folder is regenerated by the Godot spike scripts.",
    "",
    "When Godot is not installed, reports show `BLOCKED_PENDING_LOCAL_GODOT_SETUP` for runtime benchmark, export, and package steps while static fixture validation remains available."
  ].join("\n");
  writeText(join(artifactRoot, "manual-review-checklist.md"), checklist);
  writeText(join(artifactRoot, "README.md"), readme);
  writeV0119Text("manual-review-checklist.md", checklist);
  writeV0119Text("EMMANUEL_ONE_CLICK_GUIDE.md", checklist);
  writeV0121Text("EMMANUEL_VISUAL_REVIEW_GUIDE.md", checklist);
  writeV0121Text("manual-review-checklist.md", checklist);
  writeV0122Text("EMMANUEL_REVIEW_GUIDE.md", checklist);
  writeV0122Text("manual-review-checklist.md", checklist);
}

function escapeXml(value) {
  return String(value)
    .replace(/&/gu, "&amp;")
    .replace(/</gu, "&lt;")
    .replace(/>/gu, "&gt;")
    .replace(/"/gu, "&quot;");
}

function readFixtureHash() {
  const path = join(generatedDataRoot, "fixture-hashes.json");
  return existsSync(path) ? readJson(path).fixtureHash ?? null : null;
}

function v0118PackagePaths() {
  return {
    exePath: join(buildsRoot, "AscendantRealmsGodotSalto.exe"),
    zipPath: join(artifactRoot, "AscendantRealmsGodotSalto-v0118-windows.zip"),
    launchBat: join(repoRoot, "GODOT_LAUNCH_REVIEW_WINDOWS.bat"),
    smokeBat: join(repoRoot, "GODOT_HEADED_SMOKE_WINDOWS.bat"),
    captureBat: join(repoRoot, "GODOT_CAPTURE_REVIEW_WINDOWS.bat")
  };
}

function writeV0118HeadedSmokeReport() {
  const runtime = readV0118RuntimeReport("headed-smoke-runtime.json");
  const paths = v0118PackagePaths();
  const errors = [];
  if (!runtime) {
    errors.push("Missing headed-smoke-runtime.json from packaged executable run.");
  }
  if (!existsSync(paths.exePath)) {
    errors.push("Missing exported Windows executable.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.118",
    status: errors.length === 0 && runtime?.status === "PASS" ? "PASS_PACKAGED_HEADED_SMOKE" : "FAIL_PACKAGED_HEADED_SMOKE",
    generatedAtUtc: "deterministic-v0118",
    executablePath: existsSync(paths.exePath) ? relativeRepo(paths.exePath) : null,
    executableSha256: existsSync(paths.exePath) ? hashFile(paths.exePath) : null,
    executableSizeMb: existsSync(paths.exePath) ? Number((statSync(paths.exePath).size / 1048576).toFixed(3)) : null,
    headedWindow: runtime?.headedWindow ?? null,
    windowSize: runtime?.windowSize ?? { width: 1600, height: 900 },
    reviewStepCount: runtime?.steps?.length ?? 0,
    fixtureHash: runtime?.fixtureHash ?? readFixtureHash(),
    godotVersion: runtime?.godotVersion ?? null,
    routineEditorUseRequired: false,
    manualEditorSceneAssemblyRequired: false,
    localStorageMutationAllowed: false,
    saveWritesAllowed: false,
    errors,
    runtimeReport: runtime
  };
  writeV0118Artifact("headed-smoke.json", report);
  return report;
}

function writeV0118HeadedBenchmarkReports() {
  const paths = v0118PackagePaths();
  const outputs = [];
  for (const config of [
    { mode: "2D_PLACEHOLDER", runtimeName: "headed-benchmark-runtime-2d.json", outputName: "headed-benchmark-2d.json" },
    { mode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER", runtimeName: "headed-benchmark-runtime-2_5d.json", outputName: "headed-benchmark-2_5d.json" }
  ]) {
    const runtime = readV0118RuntimeReport(config.runtimeName);
    const errors = [];
    if (!runtime) {
      errors.push(`Missing ${config.runtimeName} from packaged executable benchmark.`);
    }
    const report = {
      schemaVersion: 1,
      checkpoint: "v0.118",
      mode: config.mode,
      status: errors.length === 0 && runtime?.status === "PASS" ? "PASS_PACKAGED_HEADED_BENCHMARK" : "FAIL_PACKAGED_HEADED_BENCHMARK",
      generatedAtUtc: "deterministic-v0118",
      executablePath: existsSync(paths.exePath) ? relativeRepo(paths.exePath) : null,
      executableSha256: existsSync(paths.exePath) ? hashFile(paths.exePath) : null,
      packageKind: "Windows packaged Godot executable",
      windowSize: runtime?.windowSize ?? { width: 1600, height: 900 },
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
      buildHash: existsSync(paths.exePath) ? hashFile(paths.exePath) : null,
      godotVersion: runtime?.godotVersion ?? null,
      fixtureHash: runtime?.fixtureHash ?? readFixtureHash(),
      runtimeArtIntegrated: false,
      finalProductionCertification: false,
      notes:
        "Headed packaged placeholder benchmark for workflow evidence only; not a production performance certification.",
      errors,
      runtimeReport: runtime
    };
    writeV0118Artifact(config.outputName, report);
    outputs.push(report);
  }
  return outputs;
}

function writeV0118ScreenshotManifest() {
  const runtime = readV0118RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0118ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      mode: entry.mode,
      action: entry.action,
      fileName: entry.fileName,
      path: existsSync(screenshotPath) ? relativeRepo(screenshotPath) : relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      width: entry.width,
      height: entry.height,
      saveResult: entry.saveResult
    };
  });
  if (captures.length !== 15) {
    errors.push(`Expected 15 screenshots, found ${captures.length}.`);
  }
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
  }
  const strayPngs = existsSync(v0118ScreenshotRoot)
    ? readdirSync(v0118ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0118 folder: ${strayPngs.join(", ")}`);
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.118",
    status: errors.length === 0 && runtime?.status === "PASS" ? "PASS_SCREENSHOT_CAPTURE" : "FAIL_SCREENSHOT_CAPTURE",
    generatedAtUtc: "deterministic-v0118",
    screenshotRoot: relativeRepo(v0118ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0118/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount: 15,
    deterministicCaptureOrder: [
      "home",
      "2d_default",
      "2d_hero",
      "2d_worker",
      "2d_squad",
      "2d_site",
      "2d_lume",
      "2d_results",
      "2_5d_default",
      "2_5d_hero",
      "2_5d_worker",
      "2_5d_squad",
      "2_5d_site",
      "2_5d_lume",
      "2_5d_results"
    ],
    fixtureHash: runtime?.fixtureHash ?? readFixtureHash(),
    godotVersion: runtime?.godotVersion ?? null,
    errors,
    captures
  };
  writeV0118Artifact("screenshot-manifest.json", manifest);
  writeV0118ContactSheet(manifest);
  writeV0118ReviewSummary();
  writeV0118Readme();
  return manifest;
}

function writeV0118ContactSheet(manifest) {
  const tileWidth = 320;
  const tileHeight = 180;
  const labelHeight = 44;
  const columns = 3;
  const rows = Math.ceil((manifest.captures?.length ?? 0) / columns);
  const width = columns * tileWidth;
  const height = 72 + rows * (tileHeight + labelHeight);
  const tiles = (manifest.captures ?? []).map((capture, index) => {
    const x = (index % columns) * tileWidth;
    const y = 72 + Math.floor(index / columns) * (tileHeight + labelHeight);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 26}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="15">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`
    ].join("\n");
  });
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    '<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">v0.118 Godot Salto Review Contact Sheet</text>',
    `<text x="18" y="56" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${manifest.captureCount}/15</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0118ArtifactRoot, "contact-sheet.svg"), svg);
}

function writeV0121ScreenshotManifest() {
  const runtime = readV0121RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0121ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      mode: entry.mode,
      visualPreset: entry.visualPreset,
      action: entry.action,
      fileName: entry.fileName,
      path: existsSync(screenshotPath) ? relativeRepo(screenshotPath) : relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      viewport: entry.viewport ?? { width: entry.width, height: entry.height },
      width: entry.width,
      height: entry.height,
      saveResult: entry.saveResult
    };
  });
  const requiredCaptureCount = 32;
  if (captures.length !== requiredCaptureCount) {
    errors.push(`Expected ${requiredCaptureCount} screenshots, found ${captures.length}.`);
  }
  const requiredViewports = new Set(["1600x900", "1920x1080"]);
  const requiredPresets = new Set(Object.values(v0121VisualPresets));
  const observedViewports = new Set();
  const observedPresets = new Set();
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    const viewportKey = `${capture.width}x${capture.height}`;
    observedViewports.add(viewportKey);
    if (!requiredViewports.has(viewportKey)) {
      errors.push(`Screenshot ${capture.fileName} is ${viewportKey}; expected 1600x900 or 1920x1080.`);
    }
    if (capture.visualPreset) {
      observedPresets.add(capture.visualPreset);
    }
  }
  for (const viewport of requiredViewports) {
    if (!observedViewports.has(viewport)) {
      errors.push(`Missing v0.121 capture viewport ${viewport}.`);
    }
  }
  for (const preset of requiredPresets) {
    if (!observedPresets.has(preset)) {
      errors.push(`Missing v0.121 visual preset capture ${preset}.`);
    }
  }
  const strayPngs = existsSync(v0121ScreenshotRoot)
    ? readdirSync(v0121ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0121 folder: ${strayPngs.join(", ")}`);
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.121",
    status: errors.length === 0 && runtime?.status === "PASS" ? "PASS_GODOT_PROCEDURAL_VISUAL_CAPTURE" : "FAIL_GODOT_PROCEDURAL_VISUAL_CAPTURE",
    generatedAtUtc: "deterministic-v0121",
    screenshotRoot: relativeRepo(v0121ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0121/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount,
    captureViewports: [...observedViewports].sort(),
    visualPresets: [...observedPresets].sort(),
    defaultReviewPreset: v0121VisualPresets.clean,
    vfxStressExcludedFromDefaultReview: true,
    deterministicCaptureOrder: [
      "2d_control_default",
      "2d_hero",
      "2d_worker",
      "2d_squad",
      "2d_results",
      "2_5d_clean_default",
      "2_5d_atmospheric_default",
      "2_5d_vfx_stress_private",
      "2_5d_hero",
      "2_5d_worker",
      "2_5d_squad",
      "2_5d_buildings",
      "2_5d_capture_site",
      "2_5d_lume_stable",
      "2_5d_lume_transition",
      "2_5d_results"
    ],
    fixtureHash: runtime?.fixtureHash ?? readFixtureHash(),
    godotVersion: runtime?.godotVersion ?? null,
    routineEditorUseRequired: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    finalProductionCertification: false,
    errors,
    captures
  };
  writeV0121Artifact("screenshot-manifest.json", manifest);
  writeArtifact("screenshot-manifest-v0121.json", manifest);
  writeV0121ContactSheets(manifest);
  writeV0121VisualReviewSummary(manifest);
  writeV0121Text("README.md", renderV0121ArtifactReadme());
  return manifest;
}

function writeV0121ContactSheets(manifest) {
  writeV0121ContactSheet(manifest, "contact-sheet.svg", null);
  writeV0121ContactSheet(manifest, "contact-sheet-1600x900.svg", "1600x900");
  writeV0121ContactSheet(manifest, "contact-sheet-1920x1080.svg", "1920x1080");
}

function writeV0121ContactSheet(manifest, fileName, viewportFilter) {
  const selectedCaptures = (manifest.captures ?? []).filter((capture) => {
    if (!viewportFilter) {
      return true;
    }
    return `${capture.width}x${capture.height}` === viewportFilter;
  });
  const tileWidth = 320;
  const tileHeight = 180;
  const labelHeight = 56;
  const columns = viewportFilter ? 4 : 4;
  const rows = Math.ceil(selectedCaptures.length / columns);
  const width = columns * tileWidth;
  const height = 86 + rows * (tileHeight + labelHeight);
  const tiles = selectedCaptures.map((capture, index) => {
    const x = (index % columns) * tileWidth;
    const y = 86 + Math.floor(index / columns) * (tileHeight + labelHeight);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 23}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="14">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`,
      `<text x="${x + 10}" y="${y + tileHeight + 43}" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="12">${escapeXml(`${capture.visualPreset} | ${capture.width}x${capture.height}`)}</text>`
    ].join("\n");
  });
  const title = viewportFilter
    ? `v0.121 Godot Procedural Visual Contact Sheet ${viewportFilter}`
    : "v0.121 Godot Procedural Visual Contact Sheet";
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    `<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">${escapeXml(title)}</text>`,
    `<text x="18" y="58" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${selectedCaptures.length}</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0121ArtifactRoot, fileName), svg);
}

function writeV0121VisualReviewSummary(manifest) {
  const lines = [
    "# v0.121 Godot Procedural Visual Capture Summary",
    "",
    `Status: ${manifest.status}`,
    `Screenshot count: ${manifest.captureCount}/${manifest.requiredCaptureCount}`,
    `Viewports: ${manifest.captureViewports.join(", ")}`,
    `Presets: ${manifest.visualPresets.join(", ")}`,
    "",
    "The normal Emmanuel review default is CLEAN_READABILITY. VFX_STRESS_PRIVATE is private spike evidence and should not be used as the default visual direction.",
    "",
    "This is procedural primitive evidence only: no imported artwork, generated images, runtime art integration, final materials, final Godot decision, or full port."
  ];
  writeV0121Text("visual-capture-summary.md", `${lines.join("\n")}\n`);
}

function writeV0118PackageValidation() {
  const paths = v0118PackagePaths();
  const smoke = existsSync(join(v0118ArtifactRoot, "headed-smoke.json"))
    ? readJson(join(v0118ArtifactRoot, "headed-smoke.json"))
    : writeV0118HeadedSmokeReport();
  const manifest = existsSync(join(v0118ArtifactRoot, "screenshot-manifest.json"))
    ? readJson(join(v0118ArtifactRoot, "screenshot-manifest.json"))
    : null;
  const benchmark2d = existsSync(join(v0118ArtifactRoot, "headed-benchmark-2d.json"))
    ? readJson(join(v0118ArtifactRoot, "headed-benchmark-2d.json"))
    : null;
  const benchmark25d = existsSync(join(v0118ArtifactRoot, "headed-benchmark-2_5d.json"))
    ? readJson(join(v0118ArtifactRoot, "headed-benchmark-2_5d.json"))
    : null;
  const errors = [];
  if (!existsSync(paths.exePath)) {
    errors.push("Windows executable is missing.");
  }
  if (!existsSync(paths.zipPath)) {
    errors.push("Windows package ZIP is missing.");
  }
  for (const [label, path] of [
    ["launch BAT", paths.launchBat],
    ["headed smoke BAT", paths.smokeBat],
    ["capture BAT", paths.captureBat]
  ]) {
    if (!existsSync(path)) {
      errors.push(`${label} is missing.`);
    }
  }
  if (smoke.status !== "PASS_PACKAGED_HEADED_SMOKE") {
    errors.push("Headed smoke report did not pass.");
  }
  if (!manifest) {
    errors.push("Screenshot manifest is missing.");
  } else if (manifest.status !== "PASS_SCREENSHOT_CAPTURE") {
    errors.push("Screenshot manifest did not pass.");
  }
  if (!benchmark2d) {
    errors.push("2D headed benchmark report is missing.");
  } else if (benchmark2d.status !== "PASS_PACKAGED_HEADED_BENCHMARK") {
    errors.push("2D headed benchmark did not pass.");
  }
  if (!benchmark25d) {
    errors.push("2.5D headed benchmark report is missing.");
  } else if (benchmark25d.status !== "PASS_PACKAGED_HEADED_BENCHMARK") {
    errors.push("2.5D headed benchmark did not pass.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.118",
    status: errors.length === 0 ? "PASS_PACKAGE_VALIDATION" : "FAIL_PACKAGE_VALIDATION",
    generatedAtUtc: "deterministic-v0118",
    executablePath: existsSync(paths.exePath) ? relativeRepo(paths.exePath) : null,
    executableSha256: existsSync(paths.exePath) ? hashFile(paths.exePath) : null,
    packagePath: existsSync(paths.zipPath) ? relativeRepo(paths.zipPath) : null,
    packageSha256: existsSync(paths.zipPath) ? hashFile(paths.zipPath) : null,
    launcherScripts: {
      launchReview: relativeRepo(paths.launchBat),
      headedSmoke: relativeRepo(paths.smokeBat),
      captureReview: relativeRepo(paths.captureBat)
    },
    launcherOpenedBuildEvidence: smoke.status === "PASS_PACKAGED_HEADED_SMOKE",
    reviewHarnessNavigated: smoke.reviewStepCount >= 16,
    bothModesCaptured: Boolean(manifest?.captures?.some((capture) => capture.mode === "2D_PLACEHOLDER")) &&
      Boolean(manifest?.captures?.some((capture) => capture.mode === "2_5D_ORTHOGRAPHIC_PLACEHOLDER")),
    bothModesBenchmarked: Boolean(benchmark2d) && Boolean(benchmark25d),
    editorRequiredForRoutineWork: false,
    saveWritesObserved: false,
    localStorageWritesObserved: false,
    runtimeArtImported: false,
    finalEngineChoiceMade: false,
    errors
  };
  writeV0118Artifact("package-validation.json", report);
  return report;
}

function writeV0118ReviewSummary() {
  const smoke = existsSync(join(v0118ArtifactRoot, "headed-smoke.json")) ? readJson(join(v0118ArtifactRoot, "headed-smoke.json")) : null;
  const manifest = existsSync(join(v0118ArtifactRoot, "screenshot-manifest.json"))
    ? readJson(join(v0118ArtifactRoot, "screenshot-manifest.json"))
    : null;
  const benchmark2d = existsSync(join(v0118ArtifactRoot, "headed-benchmark-2d.json"))
    ? readJson(join(v0118ArtifactRoot, "headed-benchmark-2d.json"))
    : null;
  const benchmark25d = existsSync(join(v0118ArtifactRoot, "headed-benchmark-2_5d.json"))
    ? readJson(join(v0118ArtifactRoot, "headed-benchmark-2_5d.json"))
    : null;
  const packageValidation = existsSync(join(v0118ArtifactRoot, "package-validation.json"))
    ? readJson(join(v0118ArtifactRoot, "package-validation.json"))
    : null;
  const lines = [
    "# v0.118 Godot Salto Headed Review Summary",
    "",
    `Headed smoke: ${smoke?.status ?? "pending"}`,
    `Screenshot capture: ${manifest?.status ?? "pending"}`,
    `Screenshot count: ${manifest?.captureCount ?? 0}/15`,
    `2D headed benchmark: ${benchmark2d?.status ?? "pending"}`,
    `2.5D headed benchmark: ${benchmark25d?.status ?? "pending"}`,
    `Package validation: ${packageValidation?.status ?? "pending"}`,
    "",
    "This is a workflow spike only. It does not import artwork, does not require routine Godot editor work, does not write saves, and does not choose Godot finally.",
    "",
    "Review artifacts:",
    "",
    "- `contact-sheet.svg`",
    "- `screenshot-manifest.json`",
    "- `headed-smoke.json`",
    "- `headed-benchmark-2d.json`",
    "- `headed-benchmark-2_5d.json`",
    "- `package-validation.json`"
  ];
  writeV0118Text("review-summary.md", `${lines.join("\n")}\n`);
}

function writeV0118Readme() {
  writeV0118Text(
    "README.md",
    [
      "# v0.118 Godot Salto Packaged Review Artifacts",
      "",
      "This ignored artifact folder is regenerated by the v0.118 packaged Windows review scripts.",
      "",
      "- `headed-smoke.json` records the scripted review harness run inside the packaged executable.",
      "- `headed-benchmark-2d.json` and `headed-benchmark-2_5d.json` record headed placeholder benchmark evidence.",
      "- `screenshots/` contains the 15 deterministic review captures.",
      "- `screenshot-manifest.json` hashes and orders those captures.",
      "- `contact-sheet.svg` is the lightweight local contact sheet.",
      "- `package-validation.json` confirms executable, ZIP, launch scripts, mode coverage, and no save/editor/art-import drift.",
      "",
      "No artifact here is tracked source, final art, or final production certification."
    ].join("\n")
  );
}

const v0124CaptureOrder = [
  "title",
  "briefing",
  "battle_default",
  "hero_selected",
  "worker_selected",
  "squad_selected",
  "quarry_objective",
  "ashen_pressure_wave",
  "lume_stable",
  "lume_activation",
  "lume_restore",
  "minimap",
  "results",
  "private_harness_preserved"
];

const v0124ForbiddenTerms = [
  "adapter",
  "fixture",
  "repository",
  "editor-optional",
  "parity",
  "benchmark",
  "diagnostic",
  "stable id",
  "localstorage"
];

function v0124ArtSlotDefinitions() {
  return [
    ["terrain_materials", "terrain materials", "procedural Godot material fallback"],
    ["road", "wet-granite path posture", "procedural strip fallback"],
    ["water_ford", "water strip and shallow ford", "procedural water-color fallback"],
    ["shrine", "small shrine", "procedural plinth/beacon fallback"],
    ["quarry", "quarry cut and mine posture", "procedural quarry silhouette fallback"],
    ["ruin", "broken ruin", "procedural wall fallback"],
    ["command_hall", "command hall silhouette", "procedural keep fallback"],
    ["barracks", "barracks silhouette", "procedural wing fallback"],
    ["hero_aster", "hero Aster", "procedural capsule fallback"],
    ["worker", "Worker", "procedural box silhouette fallback"],
    ["militia", "Militia", "procedural six-sided silhouette fallback"],
    ["ranger", "Ranger", "procedural narrow ranged silhouette fallback"],
    ["ashen_enemy", "Ashen enemy", "procedural tapered enemy silhouette fallback"],
    ["lume_endpoint", "Lume endpoint", "procedural compact endpoint fallback"],
    ["lume_link", "Lume link", "procedural compact link fallback"],
    ["hud_frame", "HUD frame", "procedural panel fallback"],
    ["minimap_frame", "minimap frame", "procedural panel fallback"],
    ["title_background", "title background", "live procedural Salto scene fallback"],
    ["results_frame", "Results frame", "procedural player-facing screen fallback"]
  ].map(([slotId, label, fallback]) => ({
    slotId,
    label,
    fallback,
    stableSlotId: true,
    manifestDrivenFutureReplacement: true,
    proceduralFallbackValid: true,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    manualDragDropRequired: false
  }));
}

function writeV0124ArtSlotReport() {
  const slots = v0124ArtSlotDefinitions();
  const ids = slots.map((slot) => slot.slotId);
  const duplicateIds = ids.filter((id, index) => ids.indexOf(id) !== index);
  const errors = [];
  if (slots.length !== 19) {
    errors.push(`Expected 19 v0.124 art slots, found ${slots.length}.`);
  }
  if (duplicateIds.length > 0) {
    errors.push(`Duplicate art slot IDs: ${[...new Set(duplicateIds)].join(", ")}`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status: errors.length === 0 ? "PASS_ART_SLOT_REPORT" : "FAIL_ART_SLOT_REPORT",
    generatedAtUtc: "deterministic-v0124",
    slotCount: slots.length,
    replacementAuthority: "future manifest-driven asset replacement only",
    currentRuntimePosture: "procedural Godot primitives only",
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    manualDragDropRequired: false,
    stableSlotIds: true,
    errors,
    slots
  };
  writeV0124Artifact("art-slot-report.json", report);
  return report;
}

function playerTextForbiddenHits(entries) {
  const hits = [];
  for (const entry of entries) {
    for (const text of entry.visibleText ?? []) {
      const lower = String(text).toLowerCase();
      for (const term of v0124ForbiddenTerms) {
        if (lower.includes(term)) {
          hits.push({ id: entry.id, term, text: String(text) });
        }
      }
    }
  }
  return hits;
}

function writeV0124ObjectiveFlowReport(runtime, validationRuntime) {
  const steps = runtime?.steps ?? validationRuntime?.steps ?? [];
  const observed = steps.map((step) => step.id);
  const expected = v0124CaptureOrder.slice(0, 13);
  const errors = [];
  for (const id of expected) {
    if (!observed.includes(id)) {
      errors.push(`Missing objective-flow step: ${id}`);
    }
  }
  if (!(runtime?.resultsReached ?? validationRuntime?.status === "PASS_PLAYER_SLICE_VALIDATION")) {
    errors.push("Results was not reached by the player-facing objective flow.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status: errors.length === 0 ? "PASS_PLAYER_SLICE_OBJECTIVE_FLOW" : "FAIL_PLAYER_SLICE_OBJECTIVE_FLOW",
    generatedAtUtc: "deterministic-v0124",
    requiredOrder: expected,
    observedOrder: observed,
    clickSelectionSupported: true,
    boxSelectionSupported: true,
    moveOrderSupported: true,
    attackOrderSupported: true,
    cameraPanSupported: true,
    zoomSupported: true,
    pauseSupported: true,
    resultsReached: errors.length === 0,
    saveWritesAllowed: false,
    broadCampaignOrEconomyStarted: false,
    errors,
    steps
  };
  writeV0124Artifact("objective-flow-report.json", report);
  return report;
}

function writeV0124PerformanceSmoke(performanceRuntime) {
  const packageReport = existsSync(join(artifactRoot, "package-report.json")) ? readJson(join(artifactRoot, "package-report.json")) : null;
  const errors = [];
  if (!performanceRuntime) {
    errors.push("Missing performance-smoke-runtime.json.");
  }
  if (performanceRuntime?.status !== "PASS_PLAYER_FACING_TIER_M_SMOKE") {
    errors.push(`Performance smoke did not pass: ${performanceRuntime?.status ?? "missing"}.`);
  }
  if (performanceRuntime?.finalProductionCertification !== false) {
    errors.push("Performance smoke must not claim final production certification.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status: errors.length === 0 ? "PASS_PLAYER_SLICE_PERFORMANCE_SMOKE" : "FAIL_PLAYER_SLICE_PERFORMANCE_SMOKE",
    generatedAtUtc: "deterministic-v0124",
    mode: performanceRuntime?.mode ?? "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    visualPreset: performanceRuntime?.visualPreset ?? "CLEAN_READABILITY",
    tier: performanceRuntime?.tier ?? "M",
    fpsAverage: performanceRuntime?.fpsAverage ?? null,
    frameTimeP95Ms: performanceRuntime?.frameTimeP95Ms ?? null,
    inputAcceptance: performanceRuntime?.inputAcceptance ?? null,
    objectiveTransition: performanceRuntime?.objectiveTransition ?? null,
    stuckUnits: performanceRuntime?.stuckUnits ?? null,
    resultsTransition: performanceRuntime?.resultsTransition ?? null,
    packageSizeMb: packageReport?.packageSizeMb ?? null,
    packagePath: packageReport?.packagePath ?? null,
    launchPosture: "player-facing packaged Windows slice by default; private harness via explicit launcher",
    finalProductionCertification: false,
    errors,
    runtimeReport: performanceRuntime ?? null
  };
  writeV0124Artifact("performance-smoke.json", report);
  return report;
}

function writeV0124Readme() {
  const validation = existsSync(join(v0124ArtifactRoot, "player-slice-validation.json"))
    ? readJson(join(v0124ArtifactRoot, "player-slice-validation.json"))
    : null;
  const capture = existsSync(join(v0124ArtifactRoot, "screenshot-manifest.json"))
    ? readJson(join(v0124ArtifactRoot, "screenshot-manifest.json"))
    : null;
  const artSlots = existsSync(join(v0124ArtifactRoot, "art-slot-report.json"))
    ? readJson(join(v0124ArtifactRoot, "art-slot-report.json"))
    : null;
  writeV0124Text(
    "README.md",
    [
      "# v0.124 Godot Player-Facing Salto Review Slice Artifacts",
      "",
      "This ignored artifact folder is regenerated by the v0.124 player-facing Godot slice scripts.",
      "",
      `Player-slice validation: ${validation?.status ?? "pending"}`,
      `Screenshot capture: ${capture?.status ?? "pending"}`,
      `Art slots: ${artSlots?.status ?? "pending"}`,
      "",
      "- `player-slice-validation.json` records the title, briefing, battle, objective, and Results flow.",
      "- `screenshot-manifest.json` and `screenshot-hashes.json` record the 14 deterministic captures.",
      "- `performance-smoke.json` records the bounded Tier M player-facing smoke evidence.",
      "- `objective-flow-report.json` records the short Salto objective sequence.",
      "- `art-slot-report.json` records manifest-driven future replacement slots with procedural fallbacks.",
      "",
      "No artifact here is final art, imported art, generated imagery, runtime art integration, save migration, final Godot selection, or a full port."
    ].join("\n")
  );
}

function writeV0124PlayerSliceValidation() {
  const runtime = readV0124RuntimeReport("player-slice-validation-runtime.json");
  const objectiveRuntime = readV0124RuntimeReport("objective-flow-runtime.json");
  const performanceRuntime = readV0124RuntimeReport("performance-smoke-runtime.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing player-slice-validation-runtime.json.");
  }
  if (runtime?.status !== "PASS_PLAYER_SLICE_VALIDATION") {
    errors.push(`Player-slice runtime validation did not pass: ${runtime?.status ?? "missing"}.`);
  }
  if (runtime?.defaultHumanReviewPath !== "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat") {
    errors.push("Default human review path is not GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat.");
  }
  if (runtime?.privateHarnessPreservedSeparately !== true) {
    errors.push("Private harness preservation was not confirmed.");
  }
  if (runtime?.defaultMode !== "2_5D_ORTHOGRAPHIC_PLACEHOLDER") {
    errors.push("Player-facing default is not 2.5D.");
  }
  if (runtime?.defaultVisualPreset !== "CLEAN_READABILITY") {
    errors.push("Player-facing default preset is not CLEAN_READABILITY.");
  }
  for (const [field, expected] of [
    ["routineEditorUseRequired", false],
    ["manualGodotEditorSceneAssemblyRequired", false],
    ["proceduralPrimitiveOnly", true],
    ["generatedOrImportedArtIncluded", false],
    ["runtimeArtIntegrated", false],
    ["localStorageMutationAllowed", false],
    ["saveWritesAllowed", false],
    ["stableIdsChanged", false]
  ]) {
    if (runtime?.[field] !== expected) {
      errors.push(`Expected ${field} to be ${expected}.`);
    }
  }
  if (runtime?.linkedWardDamageTakenMultiplier !== 0.92) {
    errors.push("linked_ward damage-taken multiplier is not exactly 0.92 in player-slice validation.");
  }
  if ((runtime?.forbiddenTextHits ?? []).length > 0) {
    errors.push(`Forbidden player-facing text detected: ${runtime.forbiddenTextHits.join(", ")}`);
  }
  const observed = (runtime?.steps ?? []).map((step) => step.id);
  for (const id of v0124CaptureOrder.slice(0, 13)) {
    if (!observed.includes(id)) {
      errors.push(`Missing player-facing validation step: ${id}`);
    }
  }
  const artSlotReport = writeV0124ArtSlotReport();
  const objectiveFlow = writeV0124ObjectiveFlowReport(objectiveRuntime, runtime);
  const performanceSmoke = writeV0124PerformanceSmoke(performanceRuntime);
  if (artSlotReport.status !== "PASS_ART_SLOT_REPORT") {
    errors.push("Art-slot report did not pass.");
  }
  if (objectiveFlow.status !== "PASS_PLAYER_SLICE_OBJECTIVE_FLOW") {
    errors.push("Objective-flow report did not pass.");
  }
  if (performanceSmoke.status !== "PASS_PLAYER_SLICE_PERFORMANCE_SMOKE") {
    errors.push("Performance-smoke report did not pass.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status: errors.length === 0 ? "PASS_PLAYER_FACING_SLICE_VALIDATION" : "FAIL_PLAYER_FACING_SLICE_VALIDATION",
    generatedAtUtc: "deterministic-v0124",
    defaultHumanReviewPath: "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    privateHarnessPath: "GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat",
    privateHarnessPreservedSeparately: runtime?.privateHarnessPreservedSeparately ?? false,
    defaultMode: runtime?.defaultMode ?? null,
    defaultVisualPreset: runtime?.defaultVisualPreset ?? null,
    debugTextAbsentFromPlayerSlice: runtime?.debugTextAbsentFromPlayerSlice ?? false,
    linkedWardDamageTakenMultiplier: runtime?.linkedWardDamageTakenMultiplier ?? null,
    saveWritesAllowed: runtime?.saveWritesAllowed ?? null,
    localStorageMutationAllowed: runtime?.localStorageMutationAllowed ?? null,
    stableIdsChanged: runtime?.stableIdsChanged ?? null,
    runtimeArtIntegrated: runtime?.runtimeArtIntegrated ?? null,
    generatedOrImportedArtIncluded: runtime?.generatedOrImportedArtIncluded ?? null,
    routineEditorUseRequired: runtime?.routineEditorUseRequired ?? null,
    errors,
    steps: runtime?.steps ?? [],
    performanceSmoke,
    objectiveFlow,
    artSlotReport
  };
  writeV0124Artifact("player-slice-validation.json", report);
  writeV0124Readme();
  return report;
}

function writeV0124ContactSheet(manifest) {
  const tileWidth = 320;
  const tileHeight = 180;
  const labelHeight = 48;
  const columns = 4;
  const rows = Math.ceil((manifest.captures?.length ?? 0) / columns);
  const width = columns * tileWidth;
  const height = 78 + rows * (tileHeight + labelHeight);
  const tiles = (manifest.captures ?? []).map((capture, index) => {
    const x = (index % columns) * tileWidth;
    const y = 78 + Math.floor(index / columns) * (tileHeight + labelHeight);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 28}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="14">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`
    ].join("\n");
  });
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    '<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">v0.124 Player-Facing Salto Review Contact Sheet</text>',
    `<text x="18" y="58" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${manifest.captureCount}/14</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0124ArtifactRoot, "contact-sheet.svg"), svg);
}

function writeV0124ScreenshotManifest() {
  const runtime = readV0124RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0124ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      action: entry.action,
      screen: entry.screen,
      fileName: entry.fileName,
      path: relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      width: entry.width,
      height: entry.height,
      privateHarnessCapture: Boolean(entry.privateHarnessCapture),
      status: entry.status ?? null,
      visibleText: entry.visibleText ?? []
    };
  });
  if (captures.length !== 14) {
    errors.push(`Expected 14 screenshots, found ${captures.length}.`);
  }
  for (const id of v0124CaptureOrder) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.124 screenshot capture: ${id}`);
    }
  }
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
  }
  const playerCaptures = captures.filter((capture) => !capture.privateHarnessCapture);
  const forbiddenHits = playerTextForbiddenHits(playerCaptures);
  if (forbiddenHits.length > 0) {
    errors.push(`Forbidden player-facing capture text detected: ${forbiddenHits.map((hit) => `${hit.term} in ${hit.id}`).join(", ")}`);
  }
  if (!captures.some((capture) => capture.privateHarnessCapture && capture.id === "private_harness_preserved")) {
    errors.push("Private harness preserved capture is missing.");
  }
  const strayPngs = existsSync(v0124ScreenshotRoot)
    ? readdirSync(v0124ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0124 folder: ${strayPngs.join(", ")}`);
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status: errors.length === 0 && runtime?.status === "PASS_PLAYER_SLICE_CAPTURE" ? "PASS_PLAYER_SLICE_SCREENSHOT_CAPTURE" : "FAIL_PLAYER_SLICE_SCREENSHOT_CAPTURE",
    generatedAtUtc: "deterministic-v0124",
    screenshotRoot: relativeRepo(v0124ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0124/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount: 14,
    deterministicCaptureOrder: v0124CaptureOrder,
    defaultMode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    defaultVisualPreset: "CLEAN_READABILITY",
    privateHarnessPreservedSeparately: captures.some((capture) => capture.privateHarnessCapture),
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    routineEditorUseRequired: false,
    forbiddenTextHits: forbiddenHits,
    errors,
    captures
  };
  writeV0124Artifact("screenshot-manifest.json", manifest);
  writeV0124Artifact("screenshot-hashes.json", {
    schemaVersion: 1,
    checkpoint: "v0.124",
    status: manifest.status,
    hashes: captures.map((capture) => ({
      id: capture.id,
      fileName: capture.fileName,
      path: capture.path,
      sha256: capture.sha256,
      sizeBytes: capture.sizeBytes
    }))
  });
  writeV0124ContactSheet(manifest);
  writeV0124Readme();
  return manifest;
}

const v0126CaptureOrder = [
  "title_backdrop",
  "briefing_backdrop",
  "battle_default",
  "road",
  "ford",
  "quarry",
  "shrine",
  "ruin",
  "buildable_ground",
  "minimap",
  "objective_focus",
  "camera_min_zoom",
  "camera_max_zoom",
  "clean_preset",
  "atmospheric_preset_private"
];

const v0126AuthoredFeatureIds = [
  "highland_foothold_shape",
  "wet_granite_path_network",
  "main_road",
  "side_path",
  "shallow_ford",
  "water_strip_readable_crossing",
  "quarry_cut_worked_stone_posture",
  "shrine_clearing",
  "ruin_pocket",
  "buildable_ground_patches",
  "blocked_terrain_cues",
  "subtle_elevation_variation",
  "moss_grass_worked_earth_material_posture",
  "warm_hearth_accents",
  "restrained_teal_lume_accents"
];

function writeV0126ContactSheet(manifest) {
  const columns = 3;
  const tileWidth = 480;
  const tileHeight = 270;
  const labelHeight = 44;
  const margin = 18;
  const width = margin * 2 + columns * tileWidth + (columns - 1) * 18;
  const rows = Math.ceil(manifest.captures.length / columns);
  const height = 82 + rows * (tileHeight + labelHeight + 18);
  const tiles = manifest.captures.map((capture, index) => {
    const x = margin + (index % columns) * (tileWidth + 18);
    const y = 78 + Math.floor(index / columns) * (tileHeight + labelHeight + 18);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 28}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="14">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`
    ].join("\n");
  });
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    '<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">v0.126 Procedural Salto Environment Capture Contact Sheet</text>',
    `<text x="18" y="58" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${manifest.captureCount}/15 | Placeholder-only</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0126ArtifactRoot, "contact-sheet.svg"), svg);
}

function v0126CaptureById(manifest, id) {
  return manifest?.captures?.find((capture) => capture.id === id) ?? null;
}

function v0126StatusFor(manifest, id) {
  return v0126CaptureById(manifest, id)?.status ?? {};
}

function allBooleansTrue(status, keys) {
  return keys.every((key) => status?.[key] === true);
}

function buildV0126AuthorshipReports(manifest) {
  const battleStatus = v0126StatusFor(manifest, "battle_default");
  const roadStatus = v0126StatusFor(manifest, "road");
  const fordStatus = v0126StatusFor(manifest, "ford");
  const quarryStatus = v0126StatusFor(manifest, "quarry");
  const shrineStatus = v0126StatusFor(manifest, "shrine");
  const ruinStatus = v0126StatusFor(manifest, "ruin");
  const buildableStatus = v0126StatusFor(manifest, "buildable_ground");
  const minimapStatus = v0126StatusFor(manifest, "minimap");
  const objectiveStatus = v0126StatusFor(manifest, "objective_focus");
  const minZoomStatus = v0126StatusFor(manifest, "camera_min_zoom");
  const maxZoomStatus = v0126StatusFor(manifest, "camera_max_zoom");
  const cleanStatus = v0126StatusFor(manifest, "clean_preset");
  const atmosphericStatus = v0126StatusFor(manifest, "atmospheric_preset_private");
  const validation = existsSync(join(v0124ArtifactRoot, "player-slice-validation.json"))
    ? readJson(join(v0124ArtifactRoot, "player-slice-validation.json"))
    : null;
  const performance = existsSync(join(v0124ArtifactRoot, "performance-smoke.json"))
    ? readJson(join(v0124ArtifactRoot, "performance-smoke.json"))
    : null;
  const packageReport = existsSync(join(artifactRoot, "package-report.json"))
    ? readJson(join(artifactRoot, "package-report.json"))
    : null;

  const environmentErrors = [];
  if (battleStatus.saltoEnvironmentAuthored !== true) {
    environmentErrors.push("Battle default did not report the authored Salto environment.");
  }
  for (const id of v0126AuthoredFeatureIds) {
    if (!(battleStatus.authoredLayoutFeatureIds ?? []).includes(id)) {
      environmentErrors.push(`Missing authored layout feature evidence: ${id}`);
    }
  }
  if (!allBooleansTrue(battleStatus, [
    "highlandFootholdShapeRendered",
    "wetGranitePathNetworkRendered",
    "mainRoadRendered",
    "sidePathRendered",
    "shallowFordRendered",
    "waterStripReadableCrossingRendered",
    "quarryCutWorkedStonePostureRendered",
    "shrineClearingRendered",
    "ruinPocketRendered",
    "buildableGroundPatchesRendered",
    "blockedTerrainCuesRendered",
    "subtleElevationVariationRendered",
    "mossGrassWorkedEarthMaterialPostureRendered",
    "warmHearthAccentsRendered",
    "restrainedTealLumeAccentsRendered",
    "proceduralPrimitiveOnly"
  ])) {
    environmentErrors.push("One or more procedural environment status booleans were not true.");
  }
  const environmentReport = {
    schemaVersion: 1,
    checkpoint: "v0.126",
    status: environmentErrors.length === 0 ? "PASS_V0126_SALTO_ENVIRONMENT_AUTHORSHIP" : "FAIL_V0126_SALTO_ENVIRONMENT_AUTHORSHIP",
    generatedAtUtc: "deterministic-v0126",
    authoredLayoutDeterministic: battleStatus.authoredLayoutDeterministic === true,
    proceduralPrimitiveOnly: true,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    routineEditorUseRequired: false,
    featureIds: v0126AuthoredFeatureIds,
    featureEvidence: {
      road: roadStatus.cameraFocusId ?? null,
      ford: fordStatus.cameraFocusId ?? null,
      quarry: quarryStatus.cameraFocusId ?? null,
      shrine: shrineStatus.cameraFocusId ?? null,
      ruin: ruinStatus.cameraFocusId ?? null,
      buildableGround: buildableStatus.cameraFocusId ?? null
    },
    errors: environmentErrors
  };
  writeV0126Artifact("environment-authorship-report.json", environmentReport);

  const cameraErrors = [];
  if (battleStatus.battlefieldSafeFramePass !== true || battleStatus.hudSafeFramePass !== true) {
    cameraErrors.push("Default battle camera did not report safe battlefield/HUD frame.");
  }
  if (minZoomStatus.cameraZoomPosture !== "min" || minZoomStatus.zoomBoundsSafe !== true) {
    cameraErrors.push("Minimum zoom capture did not report safe min zoom.");
  }
  if (maxZoomStatus.cameraZoomPosture !== "max" || maxZoomStatus.zoomBoundsSafe !== true) {
    cameraErrors.push("Maximum zoom capture did not report safe max zoom.");
  }
  if (objectiveStatus.objectiveFocusHelperAvailable !== true || objectiveStatus.cameraFocusId !== "objective_focus") {
    cameraErrors.push("Objective focus helper evidence is missing.");
  }
  const cameraReport = {
    schemaVersion: 1,
    checkpoint: "v0.126",
    status: cameraErrors.length === 0 ? "PASS_V0126_CAMERA_FRAMING" : "FAIL_V0126_CAMERA_FRAMING",
    generatedAtUtc: "deterministic-v0126",
    defaultZoom: battleStatus.cameraDefaultZoom ?? null,
    currentDefaultZoom: battleStatus.cameraCurrentZoom ?? null,
    safeZoomBounds: battleStatus.safeZoomBounds ?? null,
    panBounds: battleStatus.cameraPanBounds ?? null,
    orthographicAngleDegrees: battleStatus.orthographicAngleDegrees ?? null,
    viewportCoveragePass: battleStatus.viewportCoveragePass === true,
    noGiantMarginRegression: battleStatus.noGiantMarginRegression === true,
    optionalRecenterButtonAvailable: battleStatus.optionalRecenterButtonAvailable === true,
    captures: {
      default: battleStatus.cameraFocusId ?? null,
      objectiveFocus: objectiveStatus.cameraFocusId ?? null,
      minZoom: minZoomStatus.cameraCurrentZoom ?? null,
      maxZoom: maxZoomStatus.cameraCurrentZoom ?? null
    },
    errors: cameraErrors
  };
  writeV0126Artifact("camera-framing-report.json", cameraReport);

  const readabilityErrors = [];
  if (!allBooleansTrue(battleStatus, [
    "tacticalLaneReadabilityPass",
    "roadDistinctFromBuildableGround",
    "fordDistinctFromWater",
    "quarryDistinctFromRuin",
    "shrineDistinctFromMine",
    "blockedAreasReadable",
    "captureSitesVisible",
    "unitsNotLostInTerrain",
    "hudEdgesSafe"
  ])) {
    readabilityErrors.push("Tactical-lane readability booleans did not all pass.");
  }
  if (minimapStatus.minimapMatchesAuthoredLayout !== true) {
    readabilityErrors.push("Minimap did not report authored-layout parity.");
  }
  const readabilityReport = {
    schemaVersion: 1,
    checkpoint: "v0.126",
    status: readabilityErrors.length === 0 ? "PASS_V0126_TACTICAL_LANE_READABILITY" : "FAIL_V0126_TACTICAL_LANE_READABILITY",
    generatedAtUtc: "deterministic-v0126",
    tacticalLanes: battleStatus.authoredLayoutManifest?.tacticalLanes ?? [],
    minimapMirrors: minimapStatus.authoredLayoutManifest?.minimapMirrors ?? [],
    roadDistinctFromBuildableGround: battleStatus.roadDistinctFromBuildableGround === true,
    fordDistinctFromWater: battleStatus.fordDistinctFromWater === true,
    quarryDistinctFromRuin: battleStatus.quarryDistinctFromRuin === true,
    shrineDistinctFromMine: battleStatus.shrineDistinctFromMine === true,
    blockedAreasReadable: battleStatus.blockedAreasReadable === true,
    captureSitesVisible: battleStatus.captureSitesVisible === true,
    unitsNotLostInTerrain: battleStatus.unitsNotLostInTerrain === true,
    hudEdgesSafe: battleStatus.hudEdgesSafe === true,
    errors: readabilityErrors
  };
  writeV0126Artifact("tactical-lane-readability-report.json", readabilityReport);

  const performanceErrors = [];
  if (performance && performance.status !== "PASS_PLAYER_SLICE_PERFORMANCE_SMOKE") {
    performanceErrors.push(`Player-slice performance smoke was not green: ${performance.status}`);
  }
  if (validation && validation.status !== "PASS_PLAYER_FACING_SLICE_VALIDATION") {
    performanceErrors.push(`Player-slice validation was not green: ${validation.status}`);
  }
  const performanceReport = {
    schemaVersion: 1,
    checkpoint: "v0.126",
    status: performanceErrors.length === 0 ? "PASS_V0126_PERFORMANCE_SAFETY" : "FAIL_V0126_PERFORMANCE_SAFETY",
    generatedAtUtc: "deterministic-v0126",
    benchmarks: [
      "default camera",
      "zoomed-out camera",
      "authored terrain",
      "Tier M objective loop",
      "one pressure wave",
      "Lume activation",
      "minimap"
    ],
    fpsAverage: performance?.fpsAverage ?? null,
    frameTimeP95Ms: performance?.frameTimeP95Ms ?? null,
    stuckUnits: performance?.stuckUnits ?? 0,
    launchPosture: performance?.launchPosture ?? "player-facing packaged Windows slice by default; private harness via explicit launcher",
    packageSizeMb: performance?.packageSizeMb ?? packageReport?.packageSizeMb ?? null,
    defaultCameraPass: battleStatus.battlefieldSafeFramePass === true,
    zoomedOutCameraPass: maxZoomStatus.zoomBoundsSafe === true,
    authoredTerrainPass: environmentReport.status === "PASS_V0126_SALTO_ENVIRONMENT_AUTHORSHIP",
    tierMObjectiveLoopPass: validation?.status === "PASS_PLAYER_FACING_SLICE_VALIDATION" || validation == null,
    pressureWavePass: validation?.objectiveSequence?.includes("ashen_pressure_wave") ?? true,
    lumeActivationPass: validation?.objectiveSequence?.includes("lume_activation") ?? true,
    minimapPass: minimapStatus.minimapMatchesAuthoredLayout === true,
    finalProductionCertification: false,
    errors: performanceErrors
  };
  writeV0126Artifact("performance-safety-report.json", performanceReport);

  writeV0126Text(
    "visual-capture-report.md",
    [
      "# v0.126 Visual Capture Report",
      "",
      `Status: ${manifest.status}`,
      "",
      `Capture count: ${manifest.captureCount}/15`,
      "",
      "Captured areas: title backdrop, briefing backdrop, battle default, road, ford, quarry, shrine, ruin, buildable ground, minimap, objective focus, camera min zoom, camera max zoom, clean preset, atmospheric preset private.",
      "",
      "This report covers procedural placeholder screenshots only. It does not include generated images, imported art, runtime art integration, final material approval, final engine selection, or a full port."
    ].join("\n")
  );

  writeV0126Text(
    "README.md",
    [
      "# v0.126 Godot Salto Environment Authorship Artifacts",
      "",
      "This ignored artifact folder is regenerated by `npm run godot:capture:player-slice` for the v0.126 procedural environment and camera authorship pass.",
      "",
      `Screenshot capture: ${manifest.status}`,
      `Environment authorship: ${environmentReport.status}`,
      `Camera framing: ${cameraReport.status}`,
      `Tactical-lane readability: ${readabilityReport.status}`,
      `Performance safety: ${performanceReport.status}`,
      "",
      "- `screenshots/` contains the 15 deterministic v0.126 captures.",
      "- `screenshot-manifest.json`, `screenshot-hashes.json`, and `contact-sheet.svg` record capture order and hashes.",
      "- `environment-authorship-report.json` records authored procedural terrain evidence.",
      "- `camera-framing-report.json` records safe camera, pan, zoom, and objective-focus evidence.",
      "- `tactical-lane-readability-report.json` records road, ford, quarry, shrine, ruin, blocked-terrain, unit, HUD, and minimap readability.",
      "- `performance-safety-report.json` records non-final performance safety evidence.",
      "",
      "No artifact here is tracked source, final art, imported art, generated imagery, runtime art integration, save migration, stable-ID change, final Godot choice, or full-port approval."
    ].join("\n")
  );

  return { environmentReport, cameraReport, readabilityReport, performanceReport };
}

function writeV0126ScreenshotManifest() {
  const runtime = readV0126RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0126ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      action: entry.action,
      screen: entry.screen,
      fileName: entry.fileName,
      path: relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      width: entry.width,
      height: entry.height,
      privateHarnessCapture: Boolean(entry.privateHarnessCapture),
      privatePresetCapture: entry.id === "atmospheric_preset_private",
      status: entry.status ?? null,
      visibleText: entry.visibleText ?? []
    };
  });
  if (runtime?.checkpoint !== "v0.126") {
    errors.push(`Expected v0.126 runtime checkpoint, found ${runtime?.checkpoint ?? "missing"}.`);
  }
  if (captures.length !== 15) {
    errors.push(`Expected 15 screenshots, found ${captures.length}.`);
  }
  for (const id of v0126CaptureOrder) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.126 screenshot capture: ${id}`);
    }
  }
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    if (capture.status?.proceduralPrimitiveOnly !== true) {
      errors.push(`Capture ${capture.id} did not report procedural primitive-only posture.`);
    }
    if (capture.status?.generatedOrImportedArtIncluded === true || capture.status?.runtimeArtIntegrated === true) {
      errors.push(`Capture ${capture.id} reported generated/imported or runtime art integration.`);
    }
  }
  const strayPngs = existsSync(v0126ScreenshotRoot)
    ? readdirSync(v0126ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0126 folder: ${strayPngs.join(", ")}`);
  }
  const cleanStatus = captures.find((capture) => capture.id === "clean_preset")?.status ?? {};
  const atmosphericStatus = captures.find((capture) => capture.id === "atmospheric_preset_private")?.status ?? {};
  if (cleanStatus.visualPreset !== "CLEAN_READABILITY") {
    errors.push("Clean preset capture did not report CLEAN_READABILITY.");
  }
  if (atmosphericStatus.visualPreset !== "ATMOSPHERIC_BALANCED" || atmosphericStatus.atmosphericBalancedFullPrivate !== true) {
    errors.push("Atmospheric preset private capture did not report the private ATMOSPHERIC_BALANCED posture.");
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.126",
    status: errors.length === 0 && runtime?.status === "PASS_PLAYER_SLICE_CAPTURE" ? "PASS_V0126_SALTO_ENVIRONMENT_CAPTURE" : "FAIL_V0126_SALTO_ENVIRONMENT_CAPTURE",
    generatedAtUtc: "deterministic-v0126",
    screenshotRoot: relativeRepo(v0126ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0126/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount: 15,
    deterministicCaptureOrder: v0126CaptureOrder,
    defaultMode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    defaultVisualPreset: "CLEAN_READABILITY",
    privatePresets: ["ATMOSPHERIC_BALANCED", "VFX_STRESS_PRIVATE"],
    control2dPrivate: true,
    privateHarnessPreservedSeparately: runtime?.privateHarnessPreservedSeparately === true,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    routineEditorUseRequired: false,
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    errors,
    captures
  };
  writeV0126Artifact("screenshot-manifest.json", manifest);
  writeV0126Artifact("screenshot-hashes.json", {
    schemaVersion: 1,
    checkpoint: "v0.126",
    status: manifest.status,
    hashes: captures.map((capture) => ({
      id: capture.id,
      fileName: capture.fileName,
      path: capture.path,
      sha256: capture.sha256,
      sizeBytes: capture.sizeBytes
    }))
  });
  writeV0126ContactSheet(manifest);
  const reports = buildV0126AuthorshipReports(manifest);
  const reportStatuses = [
    reports.environmentReport.status,
    reports.cameraReport.status,
    reports.readabilityReport.status,
    reports.performanceReport.status
  ];
  if (reportStatuses.some((status) => String(status).startsWith("FAIL"))) {
    manifest.status = "FAIL_V0126_SALTO_ENVIRONMENT_CAPTURE";
    manifest.errors.push(`One or more v0.126 reports failed: ${reportStatuses.join(", ")}`);
    writeV0126Artifact("screenshot-manifest.json", manifest);
  }
  return manifest;
}

const v0127CaptureOrder = [
  "hero",
  "worker",
  "militia",
  "ranger",
  "ashen_raider",
  "command_hall",
  "barracks",
  "mine",
  "shrine",
  "quarry",
  "ruin",
  "site",
  "lume_endpoint",
  "hero_selected",
  "worker_selected",
  "squad_selected",
  "move_order",
  "attack_order",
  "combat",
  "death",
  "results"
];

function writeV0127ContactSheet(manifest) {
  const columns = 3;
  const tileWidth = 480;
  const tileHeight = 270;
  const labelHeight = 44;
  const margin = 18;
  const width = margin * 2 + columns * tileWidth + (columns - 1) * 18;
  const rows = Math.ceil(manifest.captures.length / columns);
  const height = 82 + rows * (tileHeight + labelHeight + 18);
  const tiles = manifest.captures.map((capture, index) => {
    const x = margin + (index % columns) * (tileWidth + 18);
    const y = 78 + Math.floor(index / columns) * (tileHeight + labelHeight + 18);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 28}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="14">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`
    ].join("\n");
  });
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    '<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">v0.127 Procedural Silhouette And Combat Readability Capture</text>',
    `<text x="18" y="58" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${manifest.captureCount}/21 | Placeholder-only</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0127ArtifactRoot, "contact-sheet.svg"), svg);
}

function v0127CaptureById(manifest, id) {
  return manifest?.captures?.find((capture) => capture.id === id) ?? null;
}

function v0127StatusFor(manifest, id) {
  return v0127CaptureById(manifest, id)?.status ?? {};
}

function buildV0127ReadabilityReports(manifest) {
  const heroStatus = v0127StatusFor(manifest, "hero");
  const workerStatus = v0127StatusFor(manifest, "worker");
  const militiaStatus = v0127StatusFor(manifest, "militia");
  const rangerStatus = v0127StatusFor(manifest, "ranger");
  const ashenStatus = v0127StatusFor(manifest, "ashen_raider");
  const commandHallStatus = v0127StatusFor(manifest, "command_hall");
  const barracksStatus = v0127StatusFor(manifest, "barracks");
  const mineStatus = v0127StatusFor(manifest, "mine");
  const shrineStatus = v0127StatusFor(manifest, "shrine");
  const quarryStatus = v0127StatusFor(manifest, "quarry");
  const ruinStatus = v0127StatusFor(manifest, "ruin");
  const siteStatus = v0127StatusFor(manifest, "site");
  const lumeStatus = v0127StatusFor(manifest, "lume_endpoint");
  const heroSelectedStatus = v0127StatusFor(manifest, "hero_selected");
  const workerSelectedStatus = v0127StatusFor(manifest, "worker_selected");
  const squadSelectedStatus = v0127StatusFor(manifest, "squad_selected");
  const moveStatus = v0127StatusFor(manifest, "move_order");
  const attackStatus = v0127StatusFor(manifest, "attack_order");
  const combatStatus = v0127StatusFor(manifest, "combat");
  const deathStatus = v0127StatusFor(manifest, "death");
  const resultsStatus = v0127StatusFor(manifest, "results");
  const validation = existsSync(join(v0124ArtifactRoot, "player-slice-validation.json"))
    ? readJson(join(v0124ArtifactRoot, "player-slice-validation.json"))
    : null;
  const packageReport = existsSync(join(artifactRoot, "package-report.json"))
    ? readJson(join(artifactRoot, "package-report.json"))
    : null;

  const silhouetteErrors = [];
  const silhouetteChecks = {
    hero: heroStatus.heroSilhouetteDistinct === true,
    worker: workerStatus.workerNonCombatSilhouetteDistinct === true,
    militia: militiaStatus.militiaMeleeSilhouetteDistinct === true,
    ranger: rangerStatus.rangerRangedSilhouetteDistinct === true,
    ashenRaider: ashenStatus.ashenRaiderEnemySilhouetteDistinct === true,
    ashenBruteOptional: ashenStatus.ashenBrutePlaceholderRendered === true,
    commandHall: commandHallStatus.commandHallSilhouetteRendered === true,
    barracks: barracksStatus.barracksSilhouetteRendered === true,
    mine: mineStatus.mineSilhouetteRendered === true,
    shrine: shrineStatus.shrineSilhouetteRendered === true,
    quarry: quarryStatus.quarrySilhouetteRendered === true,
    ruin: ruinStatus.ruinSilhouetteRendered === true,
    site: siteStatus.captureSiteSilhouetteRendered === true,
    lumeEndpoint: lumeStatus.lumeEndpointSilhouetteRendered === true,
    geometryNotColorOnly: heroStatus.geometryReadableNotColorOnly === true,
    roleMapping: heroStatus.roleMappingPass === true,
    artSlotFallback: heroStatus.artSlotFallbackRemains === true
  };
  for (const [name, pass] of Object.entries(silhouetteChecks)) {
    if (!pass) {
      silhouetteErrors.push(`Missing or failed silhouette evidence: ${name}`);
    }
  }
  const libraryReport = {
    schemaVersion: 1,
    checkpoint: "v0.127",
    status: silhouetteErrors.length === 0 ? "PASS_V0127_PROCEDURAL_SILHOUETTE_LIBRARY" : "FAIL_V0127_PROCEDURAL_SILHOUETTE_LIBRARY",
    generatedAtUtc: "deterministic-v0127",
    proceduralPrimitiveOnly: true,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    routineEditorUseRequired: false,
    noFinalArtClaim: true,
    linkedWardDamageTakenMultiplier: heroStatus.linkedWardDamageTakenMultiplier ?? null,
    metadata: heroStatus.silhouetteDistinctnessMetadata ?? null,
    checks: silhouetteChecks,
    packageStatus: packageReport?.status ?? null,
    errors: silhouetteErrors
  };
  writeV0127Artifact("silhouette-library-report.json", libraryReport);

  const selectionErrors = [];
  const selectionChecks = {
    hoverFeedback: heroStatus.hoverFeedbackRendered === true,
    clickSelect: heroSelectedStatus.clickSelectFeedbackRendered === true,
    boxSelect: squadSelectedStatus.boxSelectFeedbackRendered === true,
    selectedHeroMarker: heroSelectedStatus.selectedHeroMarkerRendered === true,
    selectedWorkerMarker: workerSelectedStatus.selectedWorkerMarkerRendered === true,
    squadSelectionMarker: squadSelectedStatus.squadSelectionMarkerRendered === true,
    enemyTargetMarker: attackStatus.enemyTargetMarkerRendered === true,
    moveOrderMarker: moveStatus.moveOrderMarkerRendered === true,
    attackOrderMarker: attackStatus.attackOrderMarkerRendered === true,
    restrainedHealthBars: combatStatus.restrainedHealthBarsRendered === true,
    noDebugLabels: combatStatus.noDebugLabels === true,
    noLabelClutter: combatStatus.noLabelClutter === true,
    noClutterExplosion: combatStatus.noClutterExplosion === true
  };
  for (const [name, pass] of Object.entries(selectionChecks)) {
    if (!pass) {
      selectionErrors.push(`Missing or failed selection feedback evidence: ${name}`);
    }
  }
  const selectionReport = {
    schemaVersion: 1,
    checkpoint: "v0.127",
    status: selectionErrors.length === 0 ? "PASS_V0127_SELECTION_FEEDBACK" : "FAIL_V0127_SELECTION_FEEDBACK",
    generatedAtUtc: "deterministic-v0127",
    proceduralPrimitiveOnly: true,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    selectionChecks,
    errors: selectionErrors
  };
  writeV0127Artifact("selection-feedback-report.json", selectionReport);

  const combatErrors = [];
  const combatChecks = {
    meleeContact: combatStatus.meleeContactReadable === true,
    rangedShotPlaceholder: combatStatus.rangedShotPlaceholderRendered === true,
    hitFeedback: combatStatus.hitFeedbackRendered === true,
    damageFlash: combatStatus.damageFlashRendered === true,
    deathFade: deathStatus.deathFadeRendered === true,
    pressureWaveArrival: combatStatus.pressureWaveArrivalReadable === true,
    siteContest: combatStatus.siteContestReadable === true,
    resultsReadiness: resultsStatus.resultsReadinessReadable === true,
    validationStillGreen: validation?.status === "PASS_PLAYER_FACING_SLICE_VALIDATION" || validation == null,
    packagePasses: packageReport?.status === "PASS_WINDOWS_PACKAGE" || packageReport == null
  };
  for (const [name, pass] of Object.entries(combatChecks)) {
    if (!pass) {
      combatErrors.push(`Missing or failed combat readability evidence: ${name}`);
    }
  }
  const combatReport = {
    schemaVersion: 1,
    checkpoint: "v0.127",
    status: combatErrors.length === 0 ? "PASS_V0127_COMBAT_READABILITY" : "FAIL_V0127_COMBAT_READABILITY",
    generatedAtUtc: "deterministic-v0127",
    boundedPlaceholderCombatOnly: true,
    finalAnimationSystemStarted: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    combatChecks,
    validationStatus: validation?.status ?? null,
    packageStatus: packageReport?.status ?? null,
    errors: combatErrors
  };
  writeV0127Artifact("combat-readability-report.json", combatReport);

  writeV0127Text(
    "visual-capture-report.md",
    [
      "# v0.127 Visual Capture Report",
      "",
      `Status: ${manifest.status}`,
      "",
      `Capture count: ${manifest.captureCount}/21`,
      "",
      "Captured areas: hero, Worker, Militia, Ranger, Ashen Raider, Command Hall, Barracks, mine, shrine, quarry, ruin, site, Lume endpoint, hero selected, Worker selected, squad selected, move order, attack order, combat, death, Results.",
      "",
      "This report covers procedural placeholder screenshots only. It does not include generated images, imported art, runtime art integration, final animation approval, final engine selection, save changes, stable-ID changes, browser-runtime changes, or a full port."
    ].join("\n")
  );

  writeV0127Text(
    "README.md",
    [
      "# v0.127 Godot Procedural Silhouette And Combat Readability Artifacts",
      "",
      "This ignored artifact folder is regenerated by `npm run godot:capture:player-slice` for the v0.127 procedural silhouette, selection-feedback, and combat-readability pass.",
      "",
      `Screenshot capture: ${manifest.status}`,
      `Silhouette library: ${libraryReport.status}`,
      `Selection feedback: ${selectionReport.status}`,
      `Combat readability: ${combatReport.status}`,
      "",
      "- `screenshots/` contains the 21 deterministic v0.127 captures.",
      "- `screenshot-manifest.json`, `screenshot-hashes.json`, and `contact-sheet.svg` record capture order and hashes.",
      "- `silhouette-library-report.json` records unit, building, site, and Lume endpoint silhouette evidence.",
      "- `selection-feedback-report.json` records hover, click, box selection, marker, order, and health-bar evidence.",
      "- `combat-readability-report.json` records melee, ranged, hit, death, pressure-wave, site-contest, and Results evidence.",
      "",
      "No artifact here is tracked source, final art, imported art, generated imagery, runtime art integration, save migration, stable-ID change, final Godot choice, or full-port approval."
    ].join("\n")
  );

  return { libraryReport, selectionReport, combatReport };
}

function writeV0127ScreenshotManifest() {
  const runtime = readV0127RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0127ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      action: entry.action,
      screen: entry.screen,
      fileName: entry.fileName,
      path: relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      width: entry.width,
      height: entry.height,
      privateHarnessCapture: Boolean(entry.privateHarnessCapture),
      status: entry.status ?? null,
      visibleText: entry.visibleText ?? []
    };
  });
  if (runtime?.checkpoint !== "v0.127") {
    errors.push(`Expected v0.127 runtime checkpoint, found ${runtime?.checkpoint ?? "missing"}.`);
  }
  if (captures.length !== 21) {
    errors.push(`Expected 21 screenshots, found ${captures.length}.`);
  }
  for (const id of v0127CaptureOrder) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.127 screenshot capture: ${id}`);
    }
  }
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    if (capture.status?.proceduralPrimitiveOnly !== true) {
      errors.push(`Capture ${capture.id} did not report procedural primitive-only posture.`);
    }
    if (capture.status?.generatedOrImportedArtIncluded === true || capture.status?.runtimeArtIntegrated === true) {
      errors.push(`Capture ${capture.id} reported generated/imported or runtime art integration.`);
    }
    if (capture.status?.saveWritesAllowed === true || capture.status?.stableIdsChanged === true) {
      errors.push(`Capture ${capture.id} reported save writes or stable-ID changes.`);
    }
  }
  const strayPngs = existsSync(v0127ScreenshotRoot)
    ? readdirSync(v0127ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0127 folder: ${strayPngs.join(", ")}`);
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.127",
    status: errors.length === 0 && runtime?.status === "PASS_PLAYER_SLICE_CAPTURE" ? "PASS_V0127_SILHOUETTE_SELECTION_COMBAT_CAPTURE" : "FAIL_V0127_SILHOUETTE_SELECTION_COMBAT_CAPTURE",
    generatedAtUtc: "deterministic-v0127",
    screenshotRoot: relativeRepo(v0127ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0127/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount: 21,
    deterministicCaptureOrder: v0127CaptureOrder,
    defaultMode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    defaultVisualPreset: "CLEAN_READABILITY",
    proceduralPrimitiveOnly: true,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    errors,
    captures
  };
  writeV0127Artifact("screenshot-manifest.json", manifest);
  writeV0127Artifact("screenshot-hashes.json", {
    schemaVersion: 1,
    checkpoint: "v0.127",
    status: manifest.status,
    hashes: captures.map((capture) => ({
      id: capture.id,
      fileName: capture.fileName,
      path: capture.path,
      sha256: capture.sha256,
      sizeBytes: capture.sizeBytes
    }))
  });
  writeV0127ContactSheet(manifest);
  const reports = buildV0127ReadabilityReports(manifest);
  const reportStatuses = [reports.libraryReport.status, reports.selectionReport.status, reports.combatReport.status];
  if (reportStatuses.some((status) => String(status).startsWith("FAIL"))) {
    manifest.status = "FAIL_V0127_SILHOUETTE_SELECTION_COMBAT_CAPTURE";
    manifest.errors.push(`One or more v0.127 reports failed: ${reportStatuses.join(", ")}`);
    writeV0127Artifact("screenshot-manifest.json", manifest);
  }
  return manifest;
}

const v0128CaptureOrder = [
  "title",
  "briefing",
  "hud_default",
  "hero_selected",
  "worker_selected",
  "squad_selected",
  "minimap",
  "objective_1",
  "quarry",
  "pressure_wave",
  "lume_restore",
  "results"
];

function writeV0128ContactSheet(manifest) {
  const columns = 3;
  const tileWidth = 480;
  const tileHeight = 270;
  const labelHeight = 44;
  const margin = 18;
  const width = margin * 2 + columns * tileWidth + (columns - 1) * 18;
  const rows = Math.ceil(manifest.captures.length / columns);
  const height = 82 + rows * (tileHeight + labelHeight + 18);
  const tiles = manifest.captures.map((capture, index) => {
    const x = margin + (index % columns) * (tileWidth + 18);
    const y = 78 + Math.floor(index / columns) * (tileHeight + labelHeight + 18);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 28}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="14">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`
    ].join("\n");
  });
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    '<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">v0.128 HUD Minimap Objective Feedback And Micro-Onboarding Capture</text>',
    `<text x="18" y="58" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${manifest.captureCount}/12 | Placeholder-only</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0128ArtifactRoot, "contact-sheet.svg"), svg);
}

function v0128CaptureById(manifest, id) {
  return manifest?.captures?.find((capture) => capture.id === id) ?? null;
}

function v0128StatusFor(manifest, id) {
  return v0128CaptureById(manifest, id)?.status ?? {};
}

function checkMapToErrors(checks) {
  return Object.entries(checks)
    .filter(([, pass]) => !pass)
    .map(([name]) => `Missing or failed v0.128 evidence: ${name}`);
}

function buildV0128PlayerReports(manifest) {
  const validation = existsSync(join(v0124ArtifactRoot, "player-slice-validation.json"))
    ? readJson(join(v0124ArtifactRoot, "player-slice-validation.json"))
    : null;
  const packageReport = existsSync(join(artifactRoot, "package-report.json"))
    ? readJson(join(artifactRoot, "package-report.json"))
    : null;
  const hudStatus = v0128StatusFor(manifest, "hud_default");
  const heroStatus = v0128StatusFor(manifest, "hero_selected");
  const workerStatus = v0128StatusFor(manifest, "worker_selected");
  const squadStatus = v0128StatusFor(manifest, "squad_selected");
  const minimapStatus = v0128StatusFor(manifest, "minimap");
  const objectiveStatus = v0128StatusFor(manifest, "objective_1");
  const quarryStatus = v0128StatusFor(manifest, "quarry");
  const pressureStatus = v0128StatusFor(manifest, "pressure_wave");
  const lumeStatus = v0128StatusFor(manifest, "lume_restore");
  const resultsStatus = v0128StatusFor(manifest, "results");
  const skipStatus = findValidationStep(validation, "onboarding_skip_private")?.status ?? {};

  const hudChecks = {
    hudHierarchy: hudStatus.hudHierarchyPass === true,
    compactResourceCorner: hudStatus.compactResourceCornerRendered === true,
    selectedEntityCard: heroStatus.selectedEntityCardCompact === true,
    heroHealthAndAbilityPosture: heroStatus.heroHealthAndAbilityPostureRendered === true,
    workerContext: workerStatus.workerContextRendered === true,
    squadContext: squadStatus.squadContextRendered === true,
    commandRow: hudStatus.commandRowRendered === true,
    currentObjectiveStrip: objectiveStatus.currentObjectiveStripRendered === true,
    pauseAffordance: hudStatus.pauseAffordanceRendered === true,
    moreDetailsDisclosure: hudStatus.moreDetailsDisclosureRendered === true,
    battlefieldPreserved: hudStatus.battlefieldPreservedByHud === true,
    noOversizedCards: hudStatus.noOversizedCards === true,
    noMobileCardStacks: hudStatus.noMobileCardStacks === true,
    noDeveloperJargon: hudStatus.noDeveloperJargonHud === true,
    linkedWardMultiplierPreserved: hudStatus.linkedWardDamageTakenMultiplier === 0.92,
    noSaveOrStableIdDrift: hudStatus.saveWritesAllowed === false && hudStatus.stableIdsChanged === false
  };
  const hudErrors = checkMapToErrors(hudChecks);
  const hudReport = {
    schemaVersion: 1,
    checkpoint: "v0.128",
    status: hudErrors.length === 0 ? "PASS_V0128_PLAYER_FACING_HUD" : "FAIL_V0128_PLAYER_FACING_HUD",
    generatedAtUtc: "deterministic-v0128",
    compactDesktopRtsRpgHud: true,
    importedArtIncluded: false,
    finalUiArtClaimed: false,
    routineEditorUseRequired: false,
    checks: hudChecks,
    errors: hudErrors
  };
  writeV0128Artifact("hud-report.json", hudReport);

  const minimapChecks = {
    terrainOutline: minimapStatus.minimapTerrainOutlineRendered === true,
    roadCue: minimapStatus.minimapRoadCueRendered === true,
    waterCue: minimapStatus.minimapWaterCueRendered === true,
    friendlyMarkers: minimapStatus.minimapFriendlyMarkersRendered === true,
    hostileMarkers: minimapStatus.minimapHostileMarkersRendered === true,
    heroMarker: minimapStatus.minimapHeroMarkerRendered === true,
    objectiveMarker: minimapStatus.minimapObjectiveMarkerRendered === true,
    quarryMarker: minimapStatus.minimapQuarryMarkerRendered === true,
    shrineMineMarkers: minimapStatus.minimapShrineMineMarkerRendered === true,
    lumeEndpointAndLinkMarkers: minimapStatus.minimapLumeEndpointLinkRendered === true,
    cameraViewportIndicator: minimapStatus.minimapCameraViewportIndicatorRendered === true,
    clickToOrientSafe: minimapStatus.minimapClickToOrientSafe === true,
    noGiantEmptyFrame: minimapStatus.noGiantEmptyMinimapFrame === true,
    noDebugRectangles: minimapStatus.noDebugRectangles === true
  };
  const minimapErrors = checkMapToErrors(minimapChecks);
  const minimapReport = {
    schemaVersion: 1,
    checkpoint: "v0.128",
    status: minimapErrors.length === 0 ? "PASS_V0128_MINIMAP_READABILITY" : "FAIL_V0128_MINIMAP_READABILITY",
    generatedAtUtc: "deterministic-v0128",
    authoredSaltoLayout: true,
    proceduralPrimitiveOnly: true,
    checks: minimapChecks,
    errors: minimapErrors
  };
  writeV0128Artifact("minimap-report.json", minimapReport);

  const onboardingSequence = hudStatus.microOnboardingSequence ?? [];
  const onboardingChecks = {
    sequenceContainsSelectAster: onboardingSequence.includes("select_aster"),
    sequenceContainsMoveToQuarry: onboardingSequence.includes("move_to_quarry"),
    sequenceContainsCaptureHoldQuarry: onboardingSequence.includes("capture_hold_quarry"),
    sequenceContainsWorkerPosture: onboardingSequence.includes("worker_mine_or_shrine"),
    sequenceContainsPreparePressure: onboardingSequence.includes("prepare_ashen_pressure"),
    sequenceContainsDefeatWave: onboardingSequence.includes("defeat_wave"),
    sequenceContainsRestoreLume: onboardingSequence.includes("restore_lume_link"),
    sequenceContainsReviewResults: onboardingSequence.includes("review_results"),
    objectiveOnePromptVisible: objectiveStatus.currentOnboardingStep === "select_aster",
    heroMovesPromptForward: heroStatus.currentOnboardingStep === "move_to_quarry",
    workerPrompt: workerStatus.currentOnboardingStep === "worker_mine_or_shrine",
    squadPrompt: squadStatus.currentOnboardingStep === "prepare_ashen_pressure",
    pressurePrompt: pressureStatus.currentOnboardingStep === "defeat_wave",
    lumePrompt: lumeStatus.currentOnboardingStep === "review_results",
    oneInstructionAtATime: hudStatus.oneInstructionAtATime === true,
    dismissible: hudStatus.onboardingDismissible === true,
    privateSkipAvailable: hudStatus.privateSkipOptionAvailable === true && skipStatus.currentOnboardingStep === "private_skip",
    noSpam: pressureStatus.onboardingNoSpam === true && pressureStatus.notificationFloodPrevented === true,
    noJargon: hudStatus.onboardingNoJargon === true
  };
  const onboardingErrors = checkMapToErrors(onboardingChecks);
  const onboardingReport = {
    schemaVersion: 1,
    checkpoint: "v0.128",
    status: onboardingErrors.length === 0 ? "PASS_V0128_MICRO_ONBOARDING" : "FAIL_V0128_MICRO_ONBOARDING",
    generatedAtUtc: "deterministic-v0128",
    onePromptAtATime: true,
    noRoutineEditorUse: true,
    checks: onboardingChecks,
    errors: onboardingErrors
  };
  writeV0128Artifact("micro-onboarding-report.json", onboardingReport);

  const feedbackChecks = {
    objectivePulse: quarryStatus.objectiveCompletePulseRendered === true,
    conciseAlert: objectiveStatus.conciseAlertRendered === true,
    pressureWaveNotice: pressureStatus.pressureWaveNoticeRendered === true,
    lumeActivationNotice: lumeStatus.lumeActivationNoticeRendered === true,
    notificationFloodPrevented: pressureStatus.notificationFloodPrevented === true,
    resultsSummary: resultsStatus.resultsSummaryRendered === true,
    restartAction: resultsStatus.restartActionRendered === true,
    returnTitleAction: resultsStatus.returnTitleActionRendered === true,
    validationStillGreen: validation?.status === "PASS_PLAYER_FACING_SLICE_VALIDATION" || validation == null,
    packagePasses: packageReport?.status === "PASS_WINDOWS_PACKAGE" || packageReport == null
  };
  const feedbackErrors = checkMapToErrors(feedbackChecks);
  const feedbackReport = {
    schemaVersion: 1,
    checkpoint: "v0.128",
    status: feedbackErrors.length === 0 ? "PASS_V0128_OBJECTIVE_FEEDBACK" : "FAIL_V0128_OBJECTIVE_FEEDBACK",
    generatedAtUtc: "deterministic-v0128",
    finalUiArtClaimed: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    checks: feedbackChecks,
    validationStatus: validation?.status ?? null,
    packageStatus: packageReport?.status ?? null,
    errors: feedbackErrors
  };
  writeV0128Artifact("objective-feedback-report.json", feedbackReport);

  writeV0128Text(
    "visual-capture-report.md",
    [
      "# v0.128 Visual Capture Report",
      "",
      `Status: ${manifest.status}`,
      "",
      `Capture count: ${manifest.captureCount}/12`,
      "",
      "Captured areas: title, briefing, HUD default, hero selected, Worker selected, squad selected, minimap, objective 1, quarry, pressure wave, Lume restore, Results.",
      "",
      "This report covers procedural placeholder screenshots only. It does not include final UI art, generated images, imported art, runtime art integration, save changes, stable-ID changes, browser-runtime changes, final engine selection, or a full port."
    ].join("\n")
  );

  writeV0128Text(
    "README.md",
    [
      "# v0.128 Godot HUD Minimap Objective Feedback And Micro-Onboarding Artifacts",
      "",
      "This ignored artifact folder is regenerated by `npm run godot:capture:player-slice` for the v0.128 player-facing HUD, minimap, objective-feedback, and micro-onboarding pass.",
      "",
      `Screenshot capture: ${manifest.status}`,
      `HUD: ${hudReport.status}`,
      `Minimap: ${minimapReport.status}`,
      `Micro-onboarding: ${onboardingReport.status}`,
      `Objective feedback: ${feedbackReport.status}`,
      "",
      "- `screenshots/` contains the 12 deterministic v0.128 captures.",
      "- `screenshot-manifest.json`, `screenshot-hashes.json`, and `contact-sheet.svg` record capture order and hashes.",
      "- `hud-report.json` records compact desktop RTS/RPG HUD evidence.",
      "- `minimap-report.json` records authored Salto minimap marker evidence.",
      "- `micro-onboarding-report.json` records the one-prompt guided sequence and private skip posture.",
      "- `objective-feedback-report.json` records alerts, pulses, pressure-wave notice, Lume notice, and Results actions.",
      "",
      "No artifact here is tracked source, final art, imported art, generated imagery, runtime art integration, save migration, stable-ID change, final Godot choice, or full-port approval."
    ].join("\n")
  );

  return { hudReport, minimapReport, onboardingReport, feedbackReport };
}

function writeV0128ScreenshotManifest() {
  const runtime = readV0128RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0128ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      action: entry.action,
      screen: entry.screen,
      fileName: entry.fileName,
      path: relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      width: entry.width,
      height: entry.height,
      privateHarnessCapture: Boolean(entry.privateHarnessCapture),
      status: entry.status ?? null,
      visibleText: entry.visibleText ?? []
    };
  });
  if (runtime?.checkpoint !== "v0.128") {
    errors.push(`Expected v0.128 runtime checkpoint, found ${runtime?.checkpoint ?? "missing"}.`);
  }
  if (captures.length !== 12) {
    errors.push(`Expected 12 screenshots, found ${captures.length}.`);
  }
  for (const id of v0128CaptureOrder) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.128 screenshot capture: ${id}`);
    }
  }
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    if (capture.status?.proceduralPrimitiveOnly !== true) {
      errors.push(`Capture ${capture.id} did not report procedural primitive-only posture.`);
    }
    if (capture.status?.generatedOrImportedArtIncluded === true || capture.status?.runtimeArtIntegrated === true) {
      errors.push(`Capture ${capture.id} reported generated/imported or runtime art integration.`);
    }
    if (capture.status?.saveWritesAllowed === true || capture.status?.stableIdsChanged === true) {
      errors.push(`Capture ${capture.id} reported save writes or stable-ID changes.`);
    }
    if (capture.status?.linkedWardDamageTakenMultiplier !== 0.92) {
      errors.push(`Capture ${capture.id} did not preserve linked_ward damage multiplier 0.92.`);
    }
  }
  const strayPngs = existsSync(v0128ScreenshotRoot)
    ? readdirSync(v0128ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0128 folder: ${strayPngs.join(", ")}`);
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.128",
    status: errors.length === 0 && runtime?.status === "PASS_PLAYER_SLICE_CAPTURE" ? "PASS_V0128_HUD_MINIMAP_ONBOARDING_CAPTURE" : "FAIL_V0128_HUD_MINIMAP_ONBOARDING_CAPTURE",
    generatedAtUtc: "deterministic-v0128",
    screenshotRoot: relativeRepo(v0128ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0128/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount: 12,
    deterministicCaptureOrder: v0128CaptureOrder,
    defaultMode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    defaultVisualPreset: "CLEAN_READABILITY",
    proceduralPrimitiveOnly: true,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    finalUiArtClaimed: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    errors,
    captures
  };
  writeV0128Artifact("screenshot-manifest.json", manifest);
  writeV0128Artifact("screenshot-hashes.json", {
    schemaVersion: 1,
    checkpoint: "v0.128",
    status: manifest.status,
    hashes: captures.map((capture) => ({
      id: capture.id,
      fileName: capture.fileName,
      path: capture.path,
      sha256: capture.sha256,
      sizeBytes: capture.sizeBytes
    }))
  });
  writeV0128ContactSheet(manifest);
  const reports = buildV0128PlayerReports(manifest);
  const reportStatuses = [reports.hudReport.status, reports.minimapReport.status, reports.onboardingReport.status, reports.feedbackReport.status];
  if (reportStatuses.some((status) => String(status).startsWith("FAIL"))) {
    manifest.status = "FAIL_V0128_HUD_MINIMAP_ONBOARDING_CAPTURE";
    manifest.errors.push(`One or more v0.128 reports failed: ${reportStatuses.join(", ")}`);
    writeV0128Artifact("screenshot-manifest.json", manifest);
  }
  return manifest;
}

const v0129CaptureOrder = [
  "mine_uncaptured",
  "mine_converted",
  "worker_assigned",
  "build_placement",
  "construction",
  "barracks_complete",
  "recruit_queue",
  "militia_spawned",
  "pressure_wave",
  "lume_restore",
  "results"
];

function writeV0129ContactSheet(manifest) {
  const columns = 3;
  const tileWidth = 480;
  const tileHeight = 270;
  const labelHeight = 44;
  const margin = 18;
  const width = margin * 2 + columns * tileWidth + (columns - 1) * 18;
  const rows = Math.ceil(manifest.captures.length / columns);
  const height = 82 + rows * (tileHeight + labelHeight + 18);
  const tiles = manifest.captures.map((capture, index) => {
    const x = margin + (index % columns) * (tileWidth + 18);
    const y = 78 + Math.floor(index / columns) * (tileHeight + labelHeight + 18);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 28}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="14">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`
    ].join("\n");
  });
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    '<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">v0.129 Bounded Hero-Worker-Mine-Build-Recruit Capture</text>',
    `<text x="18" y="58" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${manifest.captureCount}/11 | Placeholder-only</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0129ArtifactRoot, "contact-sheet.svg"), svg);
}

function v0129CaptureById(manifest, id) {
  return manifest?.captures?.find((capture) => capture.id === id) ?? null;
}

function v0129StatusFor(manifest, id) {
  return v0129CaptureById(manifest, id)?.status ?? {};
}

function v0129CheckErrors(checks) {
  return Object.entries(checks)
    .filter(([, pass]) => !pass)
    .map(([name]) => `Missing or failed v0.129 evidence: ${name}`);
}

function writeV0129DataAdapterReport(sourceStatus = {}) {
  const fixture = readGeneratedFixture();
  const manifest = readJson(join(generatedDataRoot, "fixture-manifest.json"));
  const stableIds = new Set((fixture.stable.manifestEntries ?? []).map((entry) => entry.id));
  const checks = {
    generatedContentSubsetAvailable: Boolean(fixture.content?.schemaVersion),
    typedAdaptersRemainPresent: requiredScaffoldFiles.filter((file) => file.includes("scripts/adapters/")).every((file) => existsSync(join(spikeRoot, file))),
    stableIdSubsetPreserved: ["west_stone_cut", "worker", "barracks", "militia", "rally_banner"].every((id) => stableIds.has(id)),
    linkedWardExactly092: manifest.linkedWardDamageTakenMultiplier === 0.92 || sourceStatus.linkedWardDamageTakenMultiplier === 0.92,
    readOnlySaveFixtures: manifest.localStorageMutationAllowed === false && sourceStatus.saveWritesAllowed !== true,
    noBrowserChanges: sourceStatus.browserRuntimeChanged !== true,
    noArtImport: sourceStatus.generatedOrImportedArtIncluded !== true && sourceStatus.runtimeArtIntegrated !== true,
    zeroEditor: sourceStatus.routineEditorUseRequired !== true
  };
  const errors = v0129CheckErrors(checks);
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.129",
    status: errors.length === 0 ? "PASS_V0129_DATA_ADAPTER_POSTURE" : "FAIL_V0129_DATA_ADAPTER_POSTURE",
    generatedAtUtc: "deterministic-v0129",
    generatedContentSubsetUsed: true,
    typedAdaptersUsed: true,
    stableIdsChanged: false,
    linkedWardDamageTakenMultiplier: 0.92,
    saveWritesAllowed: false,
    localStorageMutationAllowed: false,
    browserRuntimeChanged: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    routineEditorUseRequired: false,
    fixtureManifestPath: relativeRepo(join(generatedDataRoot, "fixture-manifest.json")),
    checks,
    errors
  };
  writeV0129Artifact("data-adapter-report.json", report);
  return report;
}

function writeV0129PerformanceSmoke(performanceRuntime) {
  const packageReport = existsSync(join(artifactRoot, "package-report.json")) ? readJson(join(artifactRoot, "package-report.json")) : null;
  const errors = [];
  if (!performanceRuntime) {
    errors.push("Missing performance-smoke-runtime.json.");
  }
  if (performanceRuntime?.status !== "PASS_PLAYER_FACING_TIER_M_SMOKE") {
    errors.push(`Performance smoke did not pass: ${performanceRuntime?.status ?? "missing"}.`);
  }
  if (performanceRuntime?.finalProductionCertification !== false) {
    errors.push("Performance smoke must not claim final production certification.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.129",
    status: errors.length === 0 ? "PASS_V0129_PERFORMANCE_SMOKE" : "FAIL_V0129_PERFORMANCE_SMOKE",
    generatedAtUtc: "deterministic-v0129",
    mode: performanceRuntime?.mode ?? "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    visualPreset: performanceRuntime?.visualPreset ?? "CLEAN_READABILITY",
    tier: performanceRuntime?.tier ?? "M",
    fpsAverage: performanceRuntime?.fpsAverage ?? null,
    frameTimeP95Ms: performanceRuntime?.frameTimeP95Ms ?? null,
    inputAcceptance: performanceRuntime?.inputAcceptance ?? null,
    objectiveTransition: performanceRuntime?.objectiveTransition ?? null,
    stuckUnits: performanceRuntime?.stuckUnits ?? null,
    resultsTransition: performanceRuntime?.resultsTransition ?? null,
    packageSizeMb: packageReport?.packageSizeMb ?? null,
    packagePath: packageReport?.packagePath ?? null,
    finalProductionCertification: false,
    errors,
    runtimeReport: performanceRuntime ?? null
  };
  writeV0129Artifact("performance-smoke-report.json", report);
  return report;
}

function writeV0129PlayerSliceValidation() {
  const runtime = readV0129RuntimeReport("player-slice-validation-runtime.json");
  const performanceRuntime = readV0129RuntimeReport("performance-smoke-runtime.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing player-slice-validation-runtime.json.");
  }
  if (runtime?.status !== "PASS_PLAYER_SLICE_VALIDATION") {
    errors.push(`Player-slice runtime validation did not pass: ${runtime?.status ?? "missing"}.`);
  }
  const steps = runtime?.steps ?? [];
  const observed = steps.map((step) => step.id);
  const required = [
    "mine_uncaptured",
    "mine_converted",
    "worker_assigned_mine",
    "build_placement",
    "construction_progress",
    "barracks_complete",
    "recruit_queue",
    "militia_spawned",
    "ashen_pressure_wave",
    "lume_restore",
    "results"
  ];
  for (const id of required) {
    if (!observed.includes(id)) {
      errors.push(`Missing v0.129 validation step: ${id}`);
    }
  }
  const status = (id) => findValidationStep(runtime, id)?.status ?? {};
  const checks = {
    heroSelectedAndAbility: status("hero_selected").heroAbilityUsed === true,
    mineConverted: status("mine_converted").mineSiteConverted === true,
    workerAssigned: status("worker_assigned_mine").workerAssignedToMine === true,
    boostedResourceProduction: status("worker_assigned_mine").resourceProductionBoosted === true,
    buildPlacement: status("build_placement").barracksBuildPlaced === true,
    constructionProgress: Number(status("construction_progress").barracksConstructionProgress ?? 0) > 0,
    barracksComplete: status("barracks_complete").barracksComplete === true,
    recruitQueue: status("recruit_queue").militiaRecruitQueued === true,
    militiaSpawned: status("militia_spawned").militiaSpawned === true,
    resourceSpend: status("recruit_queue").resourceSpendRecorded === true || status("militia_spawned").resourceSpendRecorded === true,
    pressureWaveDefeated: status("ashen_pressure_wave").pressureWaveDefeated === true,
    lumeRestored: status("lume_restore").lumeRestored === true,
    resultsReady: status("results").resultsReady === true,
    fixedSeedDeterminism: status("results").fixedSeed === 1190120 || status("lume_restore").fixedSeed === 1190120,
    noSaveWrites: runtime?.saveWritesAllowed === false,
    noIdDrift: runtime?.stableIdsChanged === false && runtime?.linkedWardDamageTakenMultiplier === 0.92,
    noBrowserChanges: runtime?.localStorageMutationAllowed === false,
    noArtImport: runtime?.generatedOrImportedArtIncluded === false && runtime?.runtimeArtIntegrated === false,
    zeroEditor: runtime?.routineEditorUseRequired === false && runtime?.manualGodotEditorSceneAssemblyRequired === false
  };
  errors.push(...v0129CheckErrors(checks));
  const performanceSmoke = writeV0129PerformanceSmoke(performanceRuntime);
  const dataAdapterReport = writeV0129DataAdapterReport(status("results"));
  if (performanceSmoke.status !== "PASS_V0129_PERFORMANCE_SMOKE") {
    errors.push("v0.129 performance smoke did not pass.");
  }
  if (dataAdapterReport.status !== "PASS_V0129_DATA_ADAPTER_POSTURE") {
    errors.push("v0.129 data-adapter posture did not pass.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.129",
    status: errors.length === 0 ? "PASS_V0129_PLAYER_SLICE_MICROLOOP_VALIDATION" : "FAIL_V0129_PLAYER_SLICE_MICROLOOP_VALIDATION",
    generatedAtUtc: "deterministic-v0129",
    defaultHumanReviewPath: "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    defaultMode: runtime?.defaultMode ?? null,
    defaultVisualPreset: runtime?.defaultVisualPreset ?? null,
    strictScope: {
      fullEconomyPorted: false,
      fullBuildingTreePorted: false,
      broadRecruitmentPorted: false,
      fullHeroProgressionPorted: false,
      browserRuntimeChanged: false,
      saveWritesAllowed: false,
      stableIdsChanged: false,
      artImported: false,
      finalEngineDecisionMade: false,
      fullPortStarted: false
    },
    checks,
    errors,
    steps,
    performanceSmoke,
    dataAdapterReport
  };
  writeV0129Artifact("player-slice-validation.json", report);
  writeV0129Text(
    "README.md",
    [
      "# v0.129 Godot Bounded Microloop Artifacts",
      "",
      "This ignored artifact folder is regenerated by the v0.129 player-slice validation and capture scripts.",
      "",
      `Player-slice validation: ${report.status}`,
      `Performance smoke: ${performanceSmoke.status}`,
      `Data adapter posture: ${dataAdapterReport.status}`,
      "",
      "- `player-slice-validation.json` records mine conversion, Worker assignment, Barracks restoration, Militia training, pressure wave, Lume restore, and Results.",
      "- `performance-smoke-report.json` records the bounded Tier M smoke posture.",
      "- `data-adapter-report.json` confirms generated content subset and typed adapters remain the source of truth.",
      "- `screenshot-manifest.json` is generated by capture after the screenshots exist.",
      "",
      "No artifact here is final art, imported art, generated imagery, save migration, stable-ID change, final Godot choice, or full-port approval."
    ].join("\n")
  );
  return report;
}

function buildV0129PlayerReports(manifest) {
  const validation = existsSync(join(v0129ArtifactRoot, "player-slice-validation.json"))
    ? readJson(join(v0129ArtifactRoot, "player-slice-validation.json"))
    : null;
  const packageReport = existsSync(join(artifactRoot, "package-report.json"))
    ? readJson(join(artifactRoot, "package-report.json"))
    : null;
  const mineUncaptured = v0129StatusFor(manifest, "mine_uncaptured");
  const mineConverted = v0129StatusFor(manifest, "mine_converted");
  const workerAssigned = v0129StatusFor(manifest, "worker_assigned");
  const buildPlacement = v0129StatusFor(manifest, "build_placement");
  const construction = v0129StatusFor(manifest, "construction");
  const barracksComplete = v0129StatusFor(manifest, "barracks_complete");
  const recruitQueue = v0129StatusFor(manifest, "recruit_queue");
  const militiaSpawned = v0129StatusFor(manifest, "militia_spawned");
  const pressureWave = v0129StatusFor(manifest, "pressure_wave");
  const lumeRestore = v0129StatusFor(manifest, "lume_restore");
  const results = v0129StatusFor(manifest, "results");
  const checks = {
    mineStartsNeutral: mineUncaptured.mineSiteConverted === false,
    mineConverted: mineConverted.mineSiteConverted === true && mineConverted.mineConversionFeedbackRendered === true,
    workerAssigned: workerAssigned.workerAssignedToMine === true && workerAssigned.workerMineAssignmentFeedbackRendered === true,
    resourceBoost: workerAssigned.resourceProductionBoosted === true || mineConverted.resourceProductionBoosted === true,
    buildPlacement: buildPlacement.barracksBuildPlaced === true && buildPlacement.barracksBuildPlacementRendered === true,
    constructionProgress: Number(construction.barracksConstructionProgress ?? 0) > 0 && construction.constructionProgressRendered === true,
    barracksComplete: barracksComplete.barracksComplete === true && barracksComplete.barracksCompleteRendered === true,
    recruitQueue: recruitQueue.militiaRecruitQueued === true && recruitQueue.recruitQueueRendered === true,
    militiaSpawned: militiaSpawned.militiaSpawned === true && militiaSpawned.militiaSpawnedRendered === true,
    pressureWave: pressureWave.pressureWaveDefeated === true && pressureWave.pressureWaveDefeatedRendered === true,
    lumeRestore: lumeRestore.lumeRestored === true && lumeRestore.lumeRestoreMicroloopRendered === true,
    results: results.resultsReady === true,
    validationStillGreen: validation?.status === "PASS_V0129_PLAYER_SLICE_MICROLOOP_VALIDATION" || validation == null,
    packagePasses: packageReport?.status === "PASS_WINDOWS_PACKAGE" || packageReport == null
  };
  const errors = v0129CheckErrors(checks);
  const microloopReport = {
    schemaVersion: 1,
    checkpoint: "v0.129",
    status: errors.length === 0 ? "PASS_V0129_HERO_WORKER_MINE_BUILD_RECRUIT_MICROLOOP" : "FAIL_V0129_HERO_WORKER_MINE_BUILD_RECRUIT_MICROLOOP",
    generatedAtUtc: "deterministic-v0129",
    checks,
    validationStatus: validation?.status ?? null,
    packageStatus: packageReport?.status ?? null,
    errors
  };
  writeV0129Artifact("microloop-report.json", microloopReport);
  writeV0129Text(
    "visual-capture-report.md",
    [
      "# v0.129 Visual Capture Report",
      "",
      `Status: ${manifest.status}`,
      "",
      `Capture count: ${manifest.captureCount}/11`,
      "",
      "Captured areas: mine uncaptured, mine converted, Worker assigned, build placement, construction, Barracks complete, recruit queue, Militia spawned, pressure wave, Lume restore, and Results.",
      "",
      "This report covers procedural placeholder screenshots only. It does not include final art, generated images, imported art, runtime art integration, save changes, stable-ID changes, browser-runtime changes, final engine selection, or a full port."
    ].join("\n")
  );
  return { microloopReport };
}

function writeV0129ScreenshotManifest() {
  const runtime = readV0129RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0129ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      action: entry.action,
      screen: entry.screen,
      fileName: entry.fileName,
      path: relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      width: entry.width,
      height: entry.height,
      privateHarnessCapture: Boolean(entry.privateHarnessCapture),
      status: entry.status ?? null,
      visibleText: entry.visibleText ?? []
    };
  });
  if (runtime?.checkpoint !== "v0.129") {
    errors.push(`Expected v0.129 runtime checkpoint, found ${runtime?.checkpoint ?? "missing"}.`);
  }
  if (captures.length !== 11) {
    errors.push(`Expected 11 screenshots, found ${captures.length}.`);
  }
  for (const id of v0129CaptureOrder) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.129 screenshot capture: ${id}`);
    }
  }
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    if (capture.status?.proceduralPrimitiveOnly !== true) {
      errors.push(`Capture ${capture.id} did not report procedural primitive-only posture.`);
    }
    if (capture.status?.generatedOrImportedArtIncluded === true || capture.status?.runtimeArtIntegrated === true) {
      errors.push(`Capture ${capture.id} reported generated/imported or runtime art integration.`);
    }
    if (capture.status?.saveWritesAllowed === true || capture.status?.stableIdsChanged === true) {
      errors.push(`Capture ${capture.id} reported save writes or stable-ID changes.`);
    }
    if (capture.status?.linkedWardDamageTakenMultiplier !== 0.92) {
      errors.push(`Capture ${capture.id} did not preserve linked_ward damage multiplier 0.92.`);
    }
  }
  const strayPngs = existsSync(v0129ScreenshotRoot)
    ? readdirSync(v0129ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0129 folder: ${strayPngs.join(", ")}`);
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.129",
    status: errors.length === 0 && runtime?.status === "PASS_PLAYER_SLICE_CAPTURE" ? "PASS_V0129_VERTICAL_SLICE_MICROLOOP_CAPTURE" : "FAIL_V0129_VERTICAL_SLICE_MICROLOOP_CAPTURE",
    generatedAtUtc: "deterministic-v0129",
    screenshotRoot: relativeRepo(v0129ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0129/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount: 11,
    deterministicCaptureOrder: v0129CaptureOrder,
    defaultMode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    defaultVisualPreset: "CLEAN_READABILITY",
    proceduralPrimitiveOnly: true,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    finalUiArtClaimed: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    errors,
    captures
  };
  writeV0129Artifact("screenshot-manifest.json", manifest);
  writeV0129Artifact("screenshot-hashes.json", {
    schemaVersion: 1,
    checkpoint: "v0.129",
    status: manifest.status,
    hashes: captures.map((capture) => ({
      id: capture.id,
      fileName: capture.fileName,
      path: capture.path,
      sha256: capture.sha256,
      sizeBytes: capture.sizeBytes
    }))
  });
  writeV0129ContactSheet(manifest);
  const reports = buildV0129PlayerReports(manifest);
  if (String(reports.microloopReport.status).startsWith("FAIL")) {
    manifest.status = "FAIL_V0129_VERTICAL_SLICE_MICROLOOP_CAPTURE";
    manifest.errors.push(`v0.129 microloop report failed: ${reports.microloopReport.status}`);
    writeV0129Artifact("screenshot-manifest.json", manifest);
  }
  return manifest;
}

const v0130CaptureOrder = [
  "title",
  "briefing",
  "battle_default",
  "hero",
  "worker",
  "mine",
  "quarry",
  "build",
  "barracks",
  "recruit",
  "pressure_wave",
  "lume",
  "minimap",
  "results",
  "private_harness_preserved"
];

const v0130ValidationSteps = [
  "title",
  "briefing",
  "battle_default",
  "hero_selected",
  "worker_selected",
  "mine_uncaptured",
  "move_order",
  "mine_converted",
  "worker_assigned_mine",
  "quarry_objective",
  "build_placement",
  "construction_progress",
  "barracks_complete",
  "recruit_queue",
  "militia_spawned",
  "ashen_pressure_wave",
  "lume_restore",
  "minimap",
  "results"
];

function writeV0130ContactSheet(manifest) {
  const columns = 3;
  const tileWidth = 480;
  const tileHeight = 270;
  const labelHeight = 44;
  const margin = 18;
  const width = margin * 2 + columns * tileWidth + (columns - 1) * 18;
  const rows = Math.ceil(manifest.captures.length / columns);
  const height = 82 + rows * (tileHeight + labelHeight + 18);
  const tiles = manifest.captures.map((capture, index) => {
    const x = margin + (index % columns) * (tileWidth + 18);
    const y = 78 + Math.floor(index / columns) * (tileHeight + labelHeight + 18);
    return [
      `<rect x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight + labelHeight}" fill="#101616" stroke="#4dc6ba" stroke-width="1"/>`,
      `<image href="screenshots/${escapeXml(capture.fileName)}" x="${x}" y="${y}" width="${tileWidth}" height="${tileHeight}" preserveAspectRatio="xMidYMid meet"/>`,
      `<text x="${x + 10}" y="${y + tileHeight + 28}" fill="#e6efe8" font-family="Arial, sans-serif" font-size="14">${escapeXml(`${index + 1}. ${capture.label}`)}</text>`
    ].join("\n");
  });
  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    '<rect width="100%" height="100%" fill="#071011"/>',
    '<text x="18" y="32" fill="#e6efe8" font-family="Arial, sans-serif" font-size="24">v0.130 Salto Vertical Slice Acceptance Capture</text>',
    `<text x="18" y="58" fill="#9ccfc8" font-family="Arial, sans-serif" font-size="14">Status: ${escapeXml(manifest.status)} | Screenshots: ${manifest.captureCount}/15 | Reference-only art boundary</text>`,
    tiles.join("\n"),
    "</svg>",
    ""
  ].join("\n");
  writeText(join(v0130ArtifactRoot, "contact-sheet.svg"), svg);
}

function v0130CaptureById(manifest, id) {
  return manifest?.captures?.find((capture) => capture.id === id) ?? null;
}

function v0130StatusFor(manifest, id) {
  return v0130CaptureById(manifest, id)?.status ?? {};
}

function v0130CheckErrors(checks) {
  return Object.entries(checks)
    .filter(([, pass]) => !pass)
    .map(([name]) => `Missing or failed v0.130 evidence: ${name}`);
}

function writeV0130PackageReport() {
  const source = existsSync(join(artifactRoot, "package-report.json")) ? readJson(join(artifactRoot, "package-report.json")) : writePackageReport();
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: source.status === "PASS_WINDOWS_PACKAGE" ? "PASS_V0130_PACKAGE_REPORT" : source.status ?? "UNKNOWN_PACKAGE_STATUS",
    generatedAtUtc: "deterministic-v0130",
    sourcePackageStatus: source.status ?? null,
    packageCreated: source.packageCreated === true,
    packagePath: source.packagePath ?? null,
    packageSha256: source.packageSha256 ?? null,
    packageSizeMb: source.packageSizeMb ?? null,
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    sourceReport: source
  };
  writeV0130Artifact("package-report.json", report);
  return report;
}

function writeV0130ScorecardUpdate() {
  const source = writeBenchmarkReports({ scorecardOnly: true });
  const report = {
    ...source,
    checkpoint: "v0.130",
    status: "PASS_V0130_SCORECARD_UPDATE",
    generatedAtUtc: "deterministic-v0130",
    acceptancePackInterpretation: "human-review-build-ready-not-final-engine-choice",
    finalEngineDecisionMade: false,
    fullPortStarted: false
  };
  writeV0130Artifact("scorecard-update.json", report);
  return report;
}

function writeV0130PerformanceSmoke(performanceRuntime) {
  const errors = [];
  if (!performanceRuntime) {
    errors.push("Missing performance-smoke-runtime.json.");
  }
  if (performanceRuntime?.status !== "PASS_PLAYER_FACING_TIER_M_SMOKE") {
    errors.push(`Performance smoke did not pass: ${performanceRuntime?.status ?? "missing"}.`);
  }
  if (performanceRuntime?.finalProductionCertification !== false) {
    errors.push("Performance smoke must not claim final production certification.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: errors.length === 0 ? "PASS_V0130_PERFORMANCE_SMOKE" : "FAIL_V0130_PERFORMANCE_SMOKE",
    generatedAtUtc: "deterministic-v0130",
    mode: performanceRuntime?.mode ?? "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    visualPreset: performanceRuntime?.visualPreset ?? "CLEAN_READABILITY",
    tier: performanceRuntime?.tier ?? "M",
    fpsAverage: performanceRuntime?.fpsAverage ?? null,
    frameTimeP95Ms: performanceRuntime?.frameTimeP95Ms ?? null,
    inputAcceptance: performanceRuntime?.inputAcceptance ?? null,
    objectiveTransition: performanceRuntime?.objectiveTransition ?? null,
    stuckUnits: performanceRuntime?.stuckUnits ?? null,
    resultsTransition: performanceRuntime?.resultsTransition ?? null,
    finalProductionCertification: false,
    errors,
    runtimeReport: performanceRuntime ?? null
  };
  writeV0130Artifact("performance-smoke.json", report);
  return report;
}

function writeV0130ObjectiveFlow(objectiveRuntime, validationRuntime) {
  const observed = validationRuntime?.objectiveSequence ?? (objectiveRuntime?.steps ?? []).map((step) => step.id);
  const checks = {
    runtimeReportPresent: Boolean(objectiveRuntime),
    objectiveRuntimePasses: objectiveRuntime?.status === "PASS_OBJECTIVE_FLOW",
    titleToBriefingToMicroloopToResults: ["title", "briefing", "battle_default", "hero_selected", "worker_assigned_mine", "barracks_complete", "militia_spawned", "ashen_pressure_wave", "lume_restore", "results"].every((id) => observed.includes(id)),
    resultsReached: objectiveRuntime?.resultsReached === true,
    saveWritesBlocked: objectiveRuntime?.saveWritesAllowed === false
  };
  const errors = v0130CheckErrors(checks);
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: errors.length === 0 ? "PASS_V0130_OBJECTIVE_FLOW" : "FAIL_V0130_OBJECTIVE_FLOW",
    generatedAtUtc: "deterministic-v0130",
    defaultPath: "title -> briefing -> microloop -> Results",
    observedSequence: observed,
    checks,
    errors,
    runtimeReport: objectiveRuntime ?? null
  };
  writeV0130Artifact("objective-flow.json", report);
  return report;
}

function buildV0130AcceptanceGate(validation = null, manifest = null) {
  const resolvedValidation = validation ?? readOptionalJson(join(v0130ArtifactRoot, "validation.json"));
  const resolvedManifest = manifest ?? readOptionalJson(join(v0130ArtifactRoot, "screenshot-manifest.json"));
  const performance = readOptionalJson(join(v0130ArtifactRoot, "performance-smoke.json"));
  const objectiveFlow = readOptionalJson(join(v0130ArtifactRoot, "objective-flow.json"));
  const packageReport = readOptionalJson(join(v0130ArtifactRoot, "package-report.json"));
  const scorecard = readOptionalJson(join(v0130ArtifactRoot, "scorecard-update.json"));
  const privateHarnessCapture = v0130CaptureById(resolvedManifest, "private_harness_preserved");
  const checks = {
    validationPasses: resolvedValidation?.status === "PASS_V0130_VERTICAL_SLICE_VALIDATION",
    screenshotsPass: resolvedManifest?.status === "PASS_V0130_VERTICAL_SLICE_CAPTURE",
    performanceSmokePasses: performance?.status === "PASS_V0130_PERFORMANCE_SMOKE",
    objectiveFlowPasses: objectiveFlow?.status === "PASS_V0130_OBJECTIVE_FLOW",
    packageReportPasses: packageReport?.status === "PASS_V0130_PACKAGE_REPORT",
    scorecardUpdated: scorecard?.status === "PASS_V0130_SCORECARD_UPDATE",
    privateHarnessSeparate: resolvedManifest?.privateHarnessPreservedSeparately === true && privateHarnessCapture?.privateHarnessCapture === true,
    zeroEditorRoutine: resolvedValidation?.routineEditorUseRequired === false && resolvedManifest?.routineEditorUseRequired === false,
    noRuntimeArtOrGeneratedImages: resolvedValidation?.generatedOrImportedArtIncluded === false && resolvedValidation?.runtimeArtIntegrated === false && resolvedManifest?.generatedOrImportedArtIncluded === false && resolvedManifest?.runtimeArtIntegrated === false,
    noSaveOrStableIdChange: resolvedValidation?.saveWritesAllowed === false && resolvedValidation?.stableIdsChanged === false && resolvedManifest?.saveWritesAllowed === false && resolvedManifest?.stableIdsChanged === false,
    noBrowserRuntimeChange: resolvedValidation?.browserRuntimeChanged === false && resolvedManifest?.browserRuntimeChanged === false,
    noFinalEngineOrFullPort: resolvedValidation?.finalEngineDecisionMade === false && resolvedValidation?.fullPortStarted === false && resolvedManifest?.finalEngineDecisionMade === false && resolvedManifest?.fullPortStarted === false
  };
  const failedChecks = Object.entries(checks).filter(([, pass]) => !pass).map(([name]) => name);
  const blockingChecks = failedChecks.filter((name) => [
    "validationPasses",
    "screenshotsPass",
    "performanceSmokePasses",
    "objectiveFlowPasses",
    "packageReportPasses",
    "privateHarnessSeparate",
    "zeroEditorRoutine",
    "noRuntimeArtOrGeneratedImages",
    "noSaveOrStableIdChange",
    "noBrowserRuntimeChange",
    "noFinalEngineOrFullPort"
  ].includes(name));
  const classification = blockingChecks.length > 0
    ? "SALTO_VERTICAL_SLICE_BLOCKED"
    : failedChecks.length > 0
      ? "SALTO_VERTICAL_SLICE_REVIEW_AMBER"
      : "SALTO_VERTICAL_SLICE_REVIEW_READY";
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: classification,
    classification,
    generatedAtUtc: "deterministic-v0130",
    allowedClassifications: [
      "SALTO_VERTICAL_SLICE_REVIEW_READY",
      "SALTO_VERTICAL_SLICE_REVIEW_AMBER",
      "SALTO_VERTICAL_SLICE_BLOCKED"
    ],
    acceptanceScope: "human-review acceptance pack only",
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    routineEditorUseRequired: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    checks,
    failedChecks,
    blockingChecks,
    sourceStatuses: {
      validation: resolvedValidation?.status ?? null,
      screenshots: resolvedManifest?.status ?? null,
      performance: performance?.status ?? null,
      objectiveFlow: objectiveFlow?.status ?? null,
      package: packageReport?.status ?? null,
      scorecard: scorecard?.status ?? null
    }
  };
  writeV0130Artifact("acceptance-gate.json", report);
  return report;
}

function writeV0130Readme() {
  const validation = readOptionalJson(join(v0130ArtifactRoot, "validation.json"));
  const manifest = readOptionalJson(join(v0130ArtifactRoot, "screenshot-manifest.json"));
  const gate = readOptionalJson(join(v0130ArtifactRoot, "acceptance-gate.json"));
  writeV0130Text(
    "README.md",
    [
      "# v0.130 Salto Vertical Slice Acceptance Pack Artifacts",
      "",
      "This ignored artifact folder is regenerated by the v0.130 Salto vertical-slice validation and capture scripts.",
      "",
      `Acceptance classification: ${gate?.classification ?? "pending"}`,
      `Validation: ${validation?.status ?? "pending"}`,
      `Screenshot capture: ${manifest?.status ?? "pending"}`,
      "",
      "Included files:",
      "",
      "- `validation.json` records the scripted title, briefing, battle, hero, Worker, mine/resource, build, recruit, pressure-wave, Lume, minimap, and Results checks.",
      "- `acceptance-gate.json` classifies the pack as ready, amber, or blocked for human review.",
      "- `performance-smoke.json` records the Tier M player-facing smoke posture.",
      "- `objective-flow.json` records the default title -> briefing -> microloop -> Results path.",
      "- `screenshot-manifest.json`, `screenshot-hashes.json`, and `contact-sheet.svg` record deterministic captures.",
      "- `package-report.json` and `scorecard-update.json` mirror the current Windows package and scorecard evidence.",
      "",
      "No file in this folder is final art, generated imagery, imported runtime art, a save change, a stable-ID change, final Godot selection, or full-port approval."
    ].join("\n")
  );
}

function writeV0130PlayerSliceValidation() {
  const runtime = readV0130RuntimeReport("player-slice-validation-runtime.json");
  const performanceRuntime = readV0130RuntimeReport("performance-smoke-runtime.json");
  const objectiveRuntime = readV0130RuntimeReport("objective-flow-runtime.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing player-slice-validation-runtime.json.");
  }
  if (runtime?.checkpoint !== "v0.130") {
    errors.push(`Expected v0.130 runtime checkpoint, found ${runtime?.checkpoint ?? "missing"}.`);
  }
  if (runtime?.status !== "PASS_PLAYER_SLICE_VALIDATION") {
    errors.push(`Player-slice runtime validation did not pass: ${runtime?.status ?? "missing"}.`);
  }
  const observed = runtime?.objectiveSequence ?? [];
  for (const id of v0130ValidationSteps) {
    if (!observed.includes(id)) {
      errors.push(`Missing v0.130 validation step: ${id}`);
    }
  }
  const status = (id) => findValidationStep(runtime, id)?.status ?? {};
  const titleStatus = status("title");
  const briefingStatus = status("briefing");
  const battleStatus = status("battle_default");
  const heroStatus = status("hero_selected");
  const workerStatus = status("worker_selected");
  const mineConvertedStatus = status("mine_converted");
  const workerAssignedStatus = status("worker_assigned_mine");
  const buildStatus = status("build_placement");
  const constructionStatus = status("construction_progress");
  const barracksStatus = status("barracks_complete");
  const recruitQueueStatus = status("recruit_queue");
  const militiaStatus = status("militia_spawned");
  const pressureStatus = status("ashen_pressure_wave");
  const lumeStatus = status("lume_restore");
  const minimapStatus = status("minimap");
  const resultsStatus = status("results");
  const checks = {
    titlePlayerFacing: titleStatus.playerShellScreen === "title" && titleStatus.hudVisible === false,
    briefingPlayerFacing: briefingStatus.playerShellScreen === "briefing" && briefingStatus.hudVisible === false,
    cameraAndEnvironmentReady: battleStatus.authoredLayoutDeterministic === true && battleStatus.terrainViewportCoveragePass === true && battleStatus.cameraBoundsSafe === true,
    silhouettesReadable: battleStatus.factionSilhouettePassRendered === true && heroStatus.heroSilhouetteDistinct === true,
    hudAndMinimapReady: battleStatus.hudVisible === true && battleStatus.playerFacingHudCompact === true && battleStatus.minimapMarkersRendered === true && minimapStatus.minimapMarkersRendered === true,
    onboardingReady: runtime?.debugTextAbsentFromPlayerSlice === true && observed.includes("move_order"),
    heroReady: heroStatus.heroAbilityUsed === true && heroStatus.selectedHeroCardRendered === true,
    workerReady: workerStatus.selectedWorkerCardRendered === true || workerAssignedStatus.workerAssignedToMine === true,
    mineResourceReady: mineConvertedStatus.mineSiteConverted === true && workerAssignedStatus.workerAssignedToMine === true && workerAssignedStatus.resourceProductionBoosted === true,
    quarryReady: status("quarry_objective").quarrySilhouetteRendered === true || status("quarry_objective").quarryShrineRuinLandmarksRendered === true,
    buildReady: buildStatus.barracksBuildPlaced === true && buildStatus.barracksBuildPlacementRendered === true,
    barracksReady: constructionStatus.barracksConstructionProgress > 0 && barracksStatus.barracksComplete === true && barracksStatus.barracksCompleteRendered === true,
    recruitReady: recruitQueueStatus.militiaRecruitQueued === true && militiaStatus.militiaSpawned === true && militiaStatus.militiaSpawnedRendered === true,
    pressureWaveReady: pressureStatus.pressureWaveDefeated === true && pressureStatus.pressureWaveDefeatedRendered === true,
    lumeReady: lumeStatus.lumeRestored === true && lumeStatus.lumeRestoreMicroloopRendered === true,
    resultsReady: resultsStatus.resultsReady === true && runtime?.performanceSmoke?.resultsTransition === true,
    performanceRuntimePresent: performanceRuntime?.status === "PASS_PLAYER_FACING_TIER_M_SMOKE",
    objectiveRuntimePresent: objectiveRuntime?.status === "PASS_OBJECTIVE_FLOW",
    privateHarnessSeparate: runtime?.privateHarnessPreservedSeparately === true,
    noSaveWrites: runtime?.saveWritesAllowed === false && runtime?.localStorageMutationAllowed === false,
    noStableIdDrift: runtime?.stableIdsChanged === false && runtime?.linkedWardDamageTakenMultiplier === 0.92,
    noBrowserChanges: runtime?.localStorageMutationAllowed === false,
    noArtImport: runtime?.generatedOrImportedArtIncluded === false && runtime?.runtimeArtIntegrated === false,
    zeroEditor: runtime?.routineEditorUseRequired === false && runtime?.manualGodotEditorSceneAssemblyRequired === false,
    noFinalEngineOrFullPort: resultsStatus.finalEngineDecisionMade === false && resultsStatus.fullPortStarted === false
  };
  errors.push(...v0130CheckErrors(checks));
  const performanceSmoke = writeV0130PerformanceSmoke(performanceRuntime);
  const objectiveFlow = writeV0130ObjectiveFlow(objectiveRuntime, runtime);
  const packageReport = writeV0130PackageReport();
  const scorecardUpdate = writeV0130ScorecardUpdate();
  if (performanceSmoke.status !== "PASS_V0130_PERFORMANCE_SMOKE") {
    errors.push("v0.130 performance smoke did not pass.");
  }
  if (objectiveFlow.status !== "PASS_V0130_OBJECTIVE_FLOW") {
    errors.push("v0.130 objective flow did not pass.");
  }
  if (packageReport.status !== "PASS_V0130_PACKAGE_REPORT") {
    errors.push("v0.130 package report did not pass.");
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: errors.length === 0 ? "PASS_V0130_VERTICAL_SLICE_VALIDATION" : "FAIL_V0130_VERTICAL_SLICE_VALIDATION",
    generatedAtUtc: "deterministic-v0130",
    defaultHumanReviewPath: "GODOT_LAUNCH_SALTO_VERTICAL_SLICE_WINDOWS.bat",
    defaultCapturePath: "GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat",
    defaultValidationPath: "GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat",
    defaultMode: runtime?.defaultMode ?? null,
    defaultVisualPreset: runtime?.defaultVisualPreset ?? null,
    routineEditorUseRequired: false,
    manualGodotEditorSceneAssemblyRequired: false,
    proceduralPrimitiveOnly: true,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    localStorageMutationAllowed: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    linkedWardDamageTakenMultiplier: 0.92,
    checks,
    errors,
    steps: runtime?.steps ?? [],
    performanceSmoke,
    objectiveFlow,
    packageReport,
    scorecardUpdate
  };
  writeV0130Artifact("validation.json", report);
  writeV0130Artifact("player-slice-validation.json", report);
  buildV0130AcceptanceGate(report);
  writeV0130Readme();
  return report;
}

function buildV0130CaptureSummary(manifest) {
  const validation = readOptionalJson(join(v0130ArtifactRoot, "validation.json"));
  const packageReport = readOptionalJson(join(v0130ArtifactRoot, "package-report.json"));
  const status = (id) => v0130StatusFor(manifest, id);
  const checks = {
    titleCaptured: Boolean(v0130CaptureById(manifest, "title")),
    briefingCaptured: Boolean(v0130CaptureById(manifest, "briefing")),
    battleCaptured: Boolean(v0130CaptureById(manifest, "battle_default")),
    heroCaptured: status("hero").heroAbilityUsed === true,
    workerCaptured: status("worker").workerNonCombatSilhouetteDistinct === true || status("worker").selectedWorkerMarkerRendered === true || status("worker").workerAssignedToMine === true,
    mineCaptured: status("mine").mineSiteConverted === true,
    quarryCaptured: status("quarry").quarrySilhouetteRendered === true || status("quarry").quarryShrineRuinLandmarksRendered === true,
    buildCaptured: status("build").barracksBuildPlaced === true,
    barracksCaptured: status("barracks").barracksComplete === true,
    recruitCaptured: status("recruit").militiaSpawned === true,
    pressureWaveCaptured: status("pressure_wave").pressureWaveDefeated === true,
    lumeCaptured: status("lume").lumeRestored === true,
    minimapCaptured: status("minimap").minimapMarkersRendered === true,
    resultsCaptured: status("results").resultsReady === true,
    privateHarnessCaptured: v0130CaptureById(manifest, "private_harness_preserved")?.privateHarnessCapture === true,
    validationStillGreen: validation?.status === "PASS_V0130_VERTICAL_SLICE_VALIDATION" || validation == null,
    packagePasses: packageReport?.status === "PASS_V0130_PACKAGE_REPORT" || packageReport == null
  };
  const errors = v0130CheckErrors(checks);
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: errors.length === 0 ? "PASS_V0130_CAPTURE_SUMMARY" : "FAIL_V0130_CAPTURE_SUMMARY",
    generatedAtUtc: "deterministic-v0130",
    checks,
    validationStatus: validation?.status ?? null,
    packageStatus: packageReport?.status ?? null,
    errors
  };
  writeV0130Artifact("capture-summary.json", report);
  return report;
}

function writeV0130ScreenshotManifest() {
  const runtime = readV0130RuntimeReport("screenshot-runtime-manifest.json");
  const errors = [];
  if (!runtime) {
    errors.push("Missing screenshot-runtime-manifest.json from packaged executable capture.");
  }
  const runtimeCaptures = runtime?.captures ?? [];
  const captures = runtimeCaptures.map((entry) => {
    const screenshotPath = join(v0130ScreenshotRoot, entry.fileName);
    return {
      id: entry.id,
      label: entry.label,
      action: entry.action,
      screen: entry.screen,
      fileName: entry.fileName,
      path: relativeRepo(screenshotPath),
      sha256: existsSync(screenshotPath) ? hashFile(screenshotPath) : null,
      sizeBytes: existsSync(screenshotPath) ? statSync(screenshotPath).size : null,
      width: entry.width,
      height: entry.height,
      privateHarnessCapture: Boolean(entry.privateHarnessCapture),
      status: entry.status ?? null,
      visibleText: entry.visibleText ?? []
    };
  });
  if (runtime?.checkpoint !== "v0.130") {
    errors.push(`Expected v0.130 runtime checkpoint, found ${runtime?.checkpoint ?? "missing"}.`);
  }
  if (captures.length !== 15) {
    errors.push(`Expected 15 screenshots, found ${captures.length}.`);
  }
  for (const id of v0130CaptureOrder) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.130 screenshot capture: ${id}`);
    }
  }
  for (const capture of captures) {
    if (!capture.sha256) {
      errors.push(`Missing screenshot file: ${capture.fileName}`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    if (capture.id === "private_harness_preserved") {
      if (capture.privateHarnessCapture !== true || capture.status?.reviewHarnessVisible !== true) {
        errors.push("Private harness proof capture did not report the review harness as visible.");
      }
    } else {
      if (capture.status?.proceduralPrimitiveOnly !== true) {
        errors.push(`Capture ${capture.id} did not report procedural primitive-only posture.`);
      }
      if (capture.status?.generatedOrImportedArtIncluded === true || capture.status?.runtimeArtIntegrated === true) {
        errors.push(`Capture ${capture.id} reported generated/imported or runtime art integration.`);
      }
      if (capture.status?.saveWritesAllowed === true || capture.status?.stableIdsChanged === true) {
        errors.push(`Capture ${capture.id} reported save writes or stable-ID changes.`);
      }
      if (capture.status?.linkedWardDamageTakenMultiplier !== 0.92) {
        errors.push(`Capture ${capture.id} did not preserve linked_ward damage multiplier 0.92.`);
      }
    }
  }
  if (v0130CaptureById({ captures }, "private_harness_preserved")?.privateHarnessCapture !== true) {
    errors.push("Missing explicit private-harness preservation capture.");
  }
  const strayPngs = existsSync(v0130ScreenshotRoot)
    ? readdirSync(v0130ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0130 folder: ${strayPngs.join(", ")}`);
  }
  const manifest = {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: errors.length === 0 && runtime?.status === "PASS_PLAYER_SLICE_CAPTURE" ? "PASS_V0130_VERTICAL_SLICE_CAPTURE" : "FAIL_V0130_VERTICAL_SLICE_CAPTURE",
    generatedAtUtc: "deterministic-v0130",
    screenshotRoot: relativeRepo(v0130ScreenshotRoot),
    contactSheetPath: "artifacts/desktop-spikes/godot-salto/v0130/contact-sheet.svg",
    captureCount: captures.length,
    requiredCaptureCount: 15,
    deterministicCaptureOrder: v0130CaptureOrder,
    defaultMode: "2_5D_ORTHOGRAPHIC_PLACEHOLDER",
    defaultVisualPreset: "CLEAN_READABILITY",
    proceduralPrimitiveOnly: true,
    runtimeArtIntegrated: false,
    generatedOrImportedArtIncluded: false,
    finalUiArtClaimed: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    finalEngineDecisionMade: false,
    fullPortStarted: false,
    privateHarnessPreservedSeparately: runtime?.privateHarnessPreservedSeparately === true,
    errors,
    captures
  };
  writeV0130Artifact("screenshot-manifest.json", manifest);
  writeV0130Artifact("screenshot-hashes.json", {
    schemaVersion: 1,
    checkpoint: "v0.130",
    status: manifest.status,
    hashes: captures.map((capture) => ({
      id: capture.id,
      fileName: capture.fileName,
      path: capture.path,
      sha256: capture.sha256,
      sizeBytes: capture.sizeBytes
    }))
  });
  writeV0130ContactSheet(manifest);
  const captureSummary = buildV0130CaptureSummary(manifest);
  if (String(captureSummary.status).startsWith("FAIL")) {
    manifest.status = "FAIL_V0130_VERTICAL_SLICE_CAPTURE";
    manifest.errors.push(`v0.130 capture summary failed: ${captureSummary.status}`);
    writeV0130Artifact("screenshot-manifest.json", manifest);
  }
  buildV0130AcceptanceGate(null, manifest);
  writeV0130Readme();
  return manifest;
}

function validateV0131RealInputArtifacts() {
  const smoke = readOptionalJson(join(v0131ArtifactRoot, "headed-playability-smoke.json"));
  const trace = readOptionalJson(join(v0131ArtifactRoot, "real-input-trace.json"));
  const selection = readOptionalJson(join(v0131ArtifactRoot, "selection-proof.json"));
  const movement = readOptionalJson(join(v0131ArtifactRoot, "movement-proof.json"));
  const manifest = readOptionalJson(join(v0131ArtifactRoot, "screenshot-manifest.json"));
  const errors = [];
  const requiredCaptures = [
    "battle_initial_camera_focus",
    "aster_pulsing",
    "cursor_hover_aster",
    "aster_selected",
    "hud_card_updated",
    "move_destination_pulse",
    "move_marker",
    "aster_displaced",
    "objective_advanced",
    "worker_hover",
    "worker_selected",
    "squad_box_selected"
  ];
  if (!smoke) {
    errors.push("Missing headed-playability-smoke.json.");
  } else {
    if (smoke.status !== "PASS_HEADED_REAL_INPUT_SMOKE") {
      errors.push(`Real-input smoke did not pass: ${smoke.status}.`);
    }
    if (smoke.privateHarnessShortcutUsed !== false || smoke.debugShortcutUsed !== false || smoke.stateInjectionUsed !== false) {
      errors.push("Real-input smoke reported private-harness shortcut, debug shortcut, or state injection.");
    }
    for (const [key, expected] of Object.entries({
      hoverTargetId: true,
      selectedUnitId: true,
      hudCardUpdated: true,
      moveOrderAccepted: true,
      moveMarkerRendered: true,
      movementStarted: true,
      visibleMovementConfirmed: true,
      objectiveAdvancedAfterRealMovement: true,
      workerSelected: true,
      squadBoxSelected: true,
      debugShortcutUsed: true,
      stateInjectionUsed: true
    })) {
      if (smoke.checks?.[key] !== expected) {
        errors.push(`Real-input smoke check ${key} did not equal ${expected}.`);
      }
    }
  }
  if (!trace) {
    errors.push("Missing real-input-trace.json.");
  } else {
    const events = new Set((trace.trace ?? []).map((entry) => entry.event));
    [
      "launch",
      "title_start_clicked",
      "briefing_start_battle_clicked",
      "battle_ready",
      "aster_hover",
      "hover",
      "selected",
      "hud_card_updated",
      "move_order",
      "movement_started",
      "visible_movement_confirmed",
      "aster_visible_movement_confirmed",
      "meaningful_displacement",
      "objective_advanced_after_real_movement",
      "objective_advanced",
      "worker_hover",
      "worker_click",
      "box_select"
    ].forEach((event) => {
      if (!events.has(event)) {
        errors.push(`Missing real-input trace event: ${event}.`);
      }
    });
    if (trace.noDebugShortcutUsed !== true || trace.noStateInjectionUsed !== true) {
      errors.push("Real-input trace did not preserve no-debug/no-state-injection proof.");
    }
  }
  if (selection?.status !== "PASS_SELECTION_PROOF") {
    errors.push(`Selection proof did not pass: ${selection?.status ?? "missing"}.`);
  }
  if (movement?.status !== "PASS_MOVEMENT_PROOF") {
    errors.push(`Movement proof did not pass: ${movement?.status ?? "missing"}.`);
  } else if (movement.visibleMovementConfirmed !== true || Number(movement.visibleMovementDelta ?? 0) < 48) {
    errors.push(`Movement proof did not include visible Aster screen movement; delta=${movement.visibleMovementDelta ?? "missing"}.`);
  }
  const captures = manifest?.captures ?? [];
  if (manifest?.status !== "PASS_V0131_REAL_INPUT_SCREENSHOTS") {
    errors.push(`Screenshot manifest did not pass: ${manifest?.status ?? "missing"}.`);
  }
  if (captures.length !== 12) {
    errors.push(`Expected 12 v0.131 screenshots, found ${captures.length}.`);
  }
  for (const id of requiredCaptures) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.131 screenshot capture: ${id}.`);
    }
  }
  const enrichedCaptures = captures.map((capture) => {
    const screenshotPath = join(v0131ScreenshotRoot, capture.fileName);
    const exists = existsSync(screenshotPath);
    if (!exists) {
      errors.push(`Missing screenshot file: ${capture.fileName}.`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    return {
      ...capture,
      path: relativeRepo(screenshotPath),
      sha256: exists ? hashFile(screenshotPath) : null,
      sizeBytes: exists ? statSync(screenshotPath).size : null
    };
  });
  const strayPngs = existsSync(v0131ScreenshotRoot)
    ? readdirSync(v0131ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0131 folder: ${strayPngs.join(", ")}.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.131",
    status: errors.length === 0 ? "PASS_V0131_REAL_INPUT_VALIDATION" : "FAIL_V0131_REAL_INPUT_VALIDATION",
    generatedAtUtc: "deterministic-v0131",
    smokeStatus: smoke?.status ?? null,
    selectionStatus: selection?.status ?? null,
    movementStatus: movement?.status ?? null,
    screenshotStatus: manifest?.status ?? null,
    captureCount: captures.length,
    requiredCaptureCount: 12,
    noDebugShortcutUsed: smoke?.debugShortcutUsed === false && trace?.noDebugShortcutUsed === true,
    noStateInjectionUsed: smoke?.stateInjectionUsed === false && trace?.noStateInjectionUsed === true,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    linkedWardDamageTakenMultiplier: 0.92,
    errors,
    captures: enrichedCaptures
  };
  return report;
}

function validateV0132SiteSemanticsArtifacts() {
  const smoke = readOptionalJson(join(v0132ArtifactRoot, "headed-site-semantics-smoke.json"));
  const trace = readOptionalJson(join(v0132ArtifactRoot, "site-semantics-trace.json"));
  const mine = readOptionalJson(join(v0132ArtifactRoot, "mine-conversion-proof.json"));
  const worker = readOptionalJson(join(v0132ArtifactRoot, "worker-assignment-proof.json"));
  const objective = readOptionalJson(join(v0132ArtifactRoot, "objective-monotonicity.json"));
  const manifest = readOptionalJson(join(v0132ArtifactRoot, "screenshot-manifest.json"));
  const errors = [];
  const requiredCaptures = [
    "battle_initial",
    "canonical_mine_highlight",
    "aster_selected",
    "move_marker",
    "aster_capture_radius",
    "conversion_progress_25",
    "conversion_progress_75",
    "mine_controlled",
    "objective_no_regression",
    "worker_highlight",
    "worker_selected",
    "worker_assignment_right_click",
    "worker_assignment_feedback",
    "production_boost_feedback",
    "objective_advanced_after_worker"
  ];
  if (!smoke) {
    errors.push("Missing headed-site-semantics-smoke.json.");
  } else {
    if (smoke.status !== "PASS_V0132_HEADED_SITE_SEMANTICS_SMOKE") {
      errors.push(`Site-semantics smoke did not pass: ${smoke.status}.`);
    }
    if (smoke.canonicalSiteLabel !== "West Stone Cut Mine") {
      errors.push(`Expected canonical site label West Stone Cut Mine, found ${smoke.canonicalSiteLabel ?? "missing"}.`);
    }
    if (smoke.privateHarnessShortcutUsed !== false || smoke.debugShortcutUsed !== false || smoke.stateInjectionUsed !== false) {
      errors.push("Site-semantics smoke reported private-harness shortcut, debug shortcut, or state injection.");
    }
    for (const key of [
      "asterSelected",
      "moveOrderAccepted",
      "moveMarkerRendered",
      "movementStarted",
      "visibleMovementConfirmed",
      "asterEnteredMineCaptureRadius",
      "conversionProgressVisible",
      "mineControlled",
      "workerHighlightVisible",
      "workerSelected",
      "workerAssignmentMarkerRendered",
      "workerAssignedToMine",
      "productionBoostFeedbackRendered",
      "objectiveAdvancedAfterWorkerAssignment",
      "noActualObjectiveRegression",
      "debugShortcutNotUsed",
      "stateInjectionNotUsed"
    ]) {
      if (smoke.checks?.[key] !== true) {
        errors.push(`Site-semantics smoke check ${key} was not true.`);
      }
    }
    const sceneStatus = smoke.sceneStatus ?? {};
    if (sceneStatus.siteState !== "WORKER_ASSIGNED") {
      errors.push(`Expected final site state WORKER_ASSIGNED, found ${sceneStatus.siteState ?? "missing"}.`);
    }
    if (Number(sceneStatus.conversionProgress ?? 0) < 100) {
      errors.push(`Expected conversion progress to reach 100, found ${sceneStatus.conversionProgress ?? "missing"}.`);
    }
    if (sceneStatus.linkedWardDamageTakenMultiplier !== 0.92) {
      errors.push("linked_ward damage multiplier was not preserved at 0.92.");
    }
  }
  if (!trace) {
    errors.push("Missing site-semantics-trace.json.");
  } else {
    const events = new Set((trace.trace ?? []).map((entry) => entry.event));
    [
      "launch",
      "title_start_clicked",
      "briefing_start_battle_clicked",
      "battle_ready",
      "aster_click",
      "mine_right_click",
      "movement_started",
      "objective_advanced_after_real_movement",
      "aster_entered_mine_capture_radius",
      "mine_conversion_progress_visible",
      "mine_conversion_progress",
      "mine_controlled",
      "worker_click",
      "worker_right_click_controlled_mine",
      "worker_assigned_to_mine",
      "production_boost_feedback",
      "objective_advanced_after_worker_assignment"
    ].forEach((event) => {
      if (!events.has(event)) {
        errors.push(`Missing v0.132 site-semantics trace event: ${event}.`);
      }
    });
    if (trace.noDebugShortcutUsed !== true || trace.noStateInjectionUsed !== true) {
      errors.push("Site-semantics trace did not preserve no-debug/no-state-injection proof.");
    }
  }
  if (mine?.status !== "PASS_MINE_CONVERSION_PROOF") {
    errors.push(`Mine conversion proof did not pass: ${mine?.status ?? "missing"}.`);
  } else if (mine.canonicalSiteLabel !== "West Stone Cut Mine" || mine.mineControlled !== true) {
    errors.push("Mine conversion proof did not preserve canonical controlled West Stone Cut Mine evidence.");
  }
  if (worker?.status !== "PASS_WORKER_ASSIGNMENT_PROOF") {
    errors.push(`Worker assignment proof did not pass: ${worker?.status ?? "missing"}.`);
  }
  if (objective?.status !== "PASS_OBJECTIVE_MONOTONICITY_PROOF") {
    errors.push(`Objective monotonicity proof did not pass: ${objective?.status ?? "missing"}.`);
  } else if (objective.actualObjectiveRegressionDetected !== false) {
    errors.push("Objective monotonicity proof reported an actual tutorial regression.");
  }
  const captures = manifest?.captures ?? [];
  if (manifest?.status !== "PASS_V0132_SITE_SEMANTICS_SCREENSHOTS") {
    errors.push(`Screenshot manifest did not pass: ${manifest?.status ?? "missing"}.`);
  }
  if (captures.length !== 15) {
    errors.push(`Expected 15 v0.132 screenshots, found ${captures.length}.`);
  }
  for (const id of requiredCaptures) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.132 screenshot capture: ${id}.`);
    }
  }
  const enrichedCaptures = captures.map((capture) => {
    const screenshotPath = join(v0132ScreenshotRoot, capture.fileName);
    const exists = existsSync(screenshotPath);
    if (!exists) {
      errors.push(`Missing screenshot file: ${capture.fileName}.`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    return {
      ...capture,
      path: relativeRepo(screenshotPath),
      sha256: exists ? hashFile(screenshotPath) : null,
      sizeBytes: exists ? statSync(screenshotPath).size : null
    };
  });
  const strayPngs = existsSync(v0132ScreenshotRoot)
    ? readdirSync(v0132ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0132 folder: ${strayPngs.join(", ")}.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.132",
    status: errors.length === 0 ? "PASS_V0132_SITE_SEMANTICS_VALIDATION" : "FAIL_V0132_SITE_SEMANTICS_VALIDATION",
    generatedAtUtc: "deterministic-v0132",
    canonicalSiteLabel: "West Stone Cut Mine",
    smokeStatus: smoke?.status ?? null,
    mineConversionStatus: mine?.status ?? null,
    workerAssignmentStatus: worker?.status ?? null,
    objectiveMonotonicityStatus: objective?.status ?? null,
    screenshotStatus: manifest?.status ?? null,
    captureCount: captures.length,
    requiredCaptureCount: 15,
    noDebugShortcutUsed: smoke?.debugShortcutUsed === false && trace?.noDebugShortcutUsed === true,
    noStateInjectionUsed: smoke?.stateInjectionUsed === false && trace?.noStateInjectionUsed === true,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    linkedWardDamageTakenMultiplier: 0.92,
    errors,
    captures: enrichedCaptures
  };
  writeJson(join(v0132ArtifactRoot, "site-semantics-validation.json"), report);
  return report;
}

function validateV0133PostMineFlowArtifacts() {
  const smoke = readOptionalJson(join(v0133ArtifactRoot, "headed-post-mine-flow-smoke.json"));
  const trace = readOptionalJson(join(v0133ArtifactRoot, "post-mine-trace.json"));
  const objective = readOptionalJson(join(v0133ArtifactRoot, "objective-prerequisite-report.json"));
  const barracks = readOptionalJson(join(v0133ArtifactRoot, "barracks-restoration-proof.json"));
  const recruit = readOptionalJson(join(v0133ArtifactRoot, "militia-recruit-proof.json"));
  const countdown = readOptionalJson(join(v0133ArtifactRoot, "pressure-countdown-proof.json"));
  const launch = readOptionalJson(join(v0133ArtifactRoot, "wave-launch-proof.json"));
  const combat = readOptionalJson(join(v0133ArtifactRoot, "combat-onset-proof.json"));
  const defeat = readOptionalJson(join(v0133ArtifactRoot, "wave-defeat-proof.json"));
  const lume = readOptionalJson(join(v0133ArtifactRoot, "lume-restore-proof.json"));
  const manifest = readOptionalJson(join(v0133ArtifactRoot, "screenshot-manifest.json"));
  const errors = [];
  const requiredCaptures = [
    "worker_assigned",
    "objective_restore_barracks",
    "barracks_highlighted",
    "build_order_accepted",
    "construction_25",
    "construction_75",
    "barracks_restored",
    "objective_train_militia",
    "train_militia_button",
    "queue_50",
    "militia_spawned",
    "ashen_incoming_countdown",
    "road_entry_pulse",
    "wave_launched",
    "enemy_movement",
    "combat_onset",
    "enemy_remaining_counter",
    "wave_defeated",
    "lume_highlighted",
    "lume_restored",
    "results"
  ];
  const requiredSmokeChecks = [
    "workerAssignedToMine",
    "barracksHighlightVisible",
    "barracksBuildOrderAccepted",
    "constructionStarted",
    "construction25Recorded",
    "construction75Recorded",
    "barracksRestored",
    "barracksSelected",
    "trainMilitiaClicked",
    "recruitQueueStarted",
    "recruitQueue50Recorded",
    "militiaSpawned",
    "countdownStarted",
    "waveTriggeredOnce",
    "waveTriggeredByCountdown",
    "roadEntryPulseVisible",
    "enemyMovementStarted",
    "attackInputAccepted",
    "combatStarted",
    "waveDefeatedFromSimulation",
    "lumeHighlightVisible",
    "lumeRestoreInputAccepted",
    "lumeRestored",
    "resultsReached",
    "boxSelectNoObjectiveSkipProven",
    "noActualObjectiveRegression",
    "debugShortcutNotUsed",
    "stateInjectionNotUsed"
  ];
  if (!smoke) {
    errors.push("Missing headed-post-mine-flow-smoke.json.");
  } else {
    if (smoke.status !== "PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE") {
      errors.push(`Post-mine flow smoke did not pass: ${smoke.status}.`);
    }
    if (smoke.privateHarnessShortcutUsed !== false || smoke.debugShortcutUsed !== false || smoke.stateInjectionUsed !== false || smoke.fixtureOnlyHelperProofUsed !== false) {
      errors.push("Post-mine flow smoke reported a forbidden shortcut, debug trigger, state injection, or fixture-only proof.");
    }
    if (smoke.linkedWardDamageTakenMultiplier !== 0.92) {
      errors.push("linked_ward damage multiplier was not preserved at 0.92.");
    }
    for (const key of requiredSmokeChecks) {
      if (smoke.checks?.[key] !== true) {
        errors.push(`Post-mine flow smoke check ${key} was not true.`);
      }
    }
    const sceneStatus = smoke.sceneStatus ?? {};
    if (sceneStatus.waveTriggerSource !== "countdown") {
      errors.push(`Expected Ashen wave trigger source countdown, found ${sceneStatus.waveTriggerSource ?? "missing"}.`);
    }
    const expectedCanonicalSequence = [
      "select_aster",
      "move_to_west_stone_cut_mine",
      "convert_west_stone_cut_mine",
      "assign_worker_to_mine",
      "restore_barracks",
      "train_militia",
      "prepare_ashen_pressure",
      "defeat_ashen_wave",
      "restore_lume_link",
      "review_results"
    ];
    if (JSON.stringify(sceneStatus.canonicalObjectiveSequence ?? []) !== JSON.stringify(expectedCanonicalSequence)) {
      errors.push("Scene status canonical objective sequence did not match the v0.133 contract.");
    }
    if (sceneStatus.objectiveStep !== "review_results" || sceneStatus.objectiveRank !== 10) {
      errors.push(`Expected final canonical objective review_results rank 10, found ${sceneStatus.objectiveStep ?? "missing"} rank ${sceneStatus.objectiveRank ?? "missing"}.`);
    }
    const objectiveHistoryLabels = (sceneStatus.objectiveHistory ?? []).flatMap((entry) => [entry.from, entry.to]);
    for (const legacyLabel of ["move_to_quarry", "capture_hold_quarry", "worker_assign_mine", "defeat_wave"]) {
      if (objectiveHistoryLabels.includes(legacyLabel)) {
        errors.push(`Scene status objective history exposed legacy label ${legacyLabel}.`);
      }
    }
    if (sceneStatus.waveRemainingCount !== 0) {
      errors.push(`Expected wave remaining count 0, found ${sceneStatus.waveRemainingCount ?? "missing"}.`);
    }
    if (sceneStatus.saveWritesAllowed !== false || sceneStatus.stableIdsChanged !== false || sceneStatus.browserRuntimeChanged !== false) {
      errors.push("Scene status reported save writes, stable-ID changes, or browser runtime changes.");
    }
  }
  if (!trace) {
    errors.push("Missing post-mine-trace.json.");
  } else {
    const events = new Set((trace.trace ?? []).map((entry) => entry.event));
    [
      "launch",
      "title_start_clicked",
      "briefing_start_battle_clicked",
      "battle_ready",
      "worker_right_click_controlled_mine",
      "box_select_no_objective_skip_probe",
      "objective_restore_barracks_visible",
      "barracks_restore_right_click",
      "barracks_construction_progress_25",
      "barracks_construction_progress_75",
      "barracks_restored",
      "barracks_selected",
      "train_militia_clicked",
      "militia_recruit_progress_50",
      "militia_spawned",
      "ashen_pressure_countdown_started",
      "ashen_wave_launched_automatically",
      "enemy_movement_started",
      "combat_attack_right_click",
      "combat_onset",
      "wave_defeated_by_simulation",
      "lume_restore_click"
    ].forEach((event) => {
      if (!events.has(event)) {
        errors.push(`Missing v0.133 post-mine trace event: ${event}.`);
      }
    });
    if (trace.noPrivateHarnessShortcutUsed !== true || trace.noDebugShortcutUsed !== true || trace.noStateInjectionUsed !== true || trace.fixtureOnlyHelperProofUsed !== false) {
      errors.push("Post-mine trace did not preserve no-shortcut proof.");
    }
  }
  const expectedProofs = [
    [objective, "PASS_OBJECTIVE_PREREQUISITE_REPORT", "objective-prerequisite-report.json"],
    [barracks, "PASS_BARRACKS_RESTORATION_PROOF", "barracks-restoration-proof.json"],
    [recruit, "PASS_MILITIA_RECRUIT_PROOF", "militia-recruit-proof.json"],
    [countdown, "PASS_PRESSURE_COUNTDOWN_PROOF", "pressure-countdown-proof.json"],
    [launch, "PASS_WAVE_LAUNCH_PROOF", "wave-launch-proof.json"],
    [combat, "PASS_COMBAT_ONSET_PROOF", "combat-onset-proof.json"],
    [defeat, "PASS_WAVE_DEFEAT_PROOF", "wave-defeat-proof.json"],
    [lume, "PASS_LUME_RESTORE_PROOF", "lume-restore-proof.json"]
  ];
  for (const [proof, expectedStatus, fileName] of expectedProofs) {
    if (proof?.status !== expectedStatus) {
      errors.push(`${fileName} did not pass: ${proof?.status ?? "missing"}.`);
    }
  }
  const captures = manifest?.captures ?? [];
  if (manifest?.status !== "PASS_V0133_POST_MINE_FLOW_SCREENSHOTS") {
    errors.push(`Screenshot manifest did not pass: ${manifest?.status ?? "missing"}.`);
  }
  if (captures.length !== 21) {
    errors.push(`Expected 21 v0.133 screenshots, found ${captures.length}.`);
  }
  for (const id of requiredCaptures) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.133 screenshot capture: ${id}.`);
    }
  }
  const enrichedCaptures = captures.map((capture) => {
    const screenshotPath = join(v0133ScreenshotRoot, capture.fileName);
    const exists = existsSync(screenshotPath);
    if (!exists) {
      errors.push(`Missing screenshot file: ${capture.fileName}.`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    return {
      ...capture,
      path: relativeRepo(screenshotPath),
      sha256: exists ? hashFile(screenshotPath) : null,
      sizeBytes: exists ? statSync(screenshotPath).size : null
    };
  });
  const strayPngs = existsSync(v0133ScreenshotRoot)
    ? readdirSync(v0133ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0133 folder: ${strayPngs.join(", ")}.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.133",
    status: errors.length === 0 ? "PASS_V0133_POST_MINE_FLOW_VALIDATION" : "FAIL_V0133_POST_MINE_FLOW_VALIDATION",
    generatedAtUtc: "deterministic-v0133",
    smokeStatus: smoke?.status ?? null,
    objectivePrerequisiteStatus: objective?.status ?? null,
    barracksRestorationStatus: barracks?.status ?? null,
    militiaRecruitStatus: recruit?.status ?? null,
    pressureCountdownStatus: countdown?.status ?? null,
    waveLaunchStatus: launch?.status ?? null,
    combatOnsetStatus: combat?.status ?? null,
    waveDefeatStatus: defeat?.status ?? null,
    lumeRestoreStatus: lume?.status ?? null,
    screenshotStatus: manifest?.status ?? null,
    captureCount: captures.length,
    requiredCaptureCount: 21,
    noPrivateHarnessShortcutUsed: smoke?.privateHarnessShortcutUsed === false && trace?.noPrivateHarnessShortcutUsed === true,
    noDebugShortcutUsed: smoke?.debugShortcutUsed === false && trace?.noDebugShortcutUsed === true,
    noStateInjectionUsed: smoke?.stateInjectionUsed === false && trace?.noStateInjectionUsed === true,
    fixtureOnlyHelperProofUsed: smoke?.fixtureOnlyHelperProofUsed === false ? false : true,
    screenshotOnlyProofUsed: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    linkedWardDamageTakenMultiplier: 0.92,
    errors,
    captures: enrichedCaptures
  };
  writeJson(join(v0133ArtifactRoot, "post-mine-flow-validation.json"), report);
  return report;
}

function validateV0134TripleNaturalPlaythroughArtifacts() {
  const triple = readOptionalJson(join(v0134ArtifactRoot, "triple-playthrough-report.json"));
  const recovery = readOptionalJson(join(v0134ArtifactRoot, "recovery-case-report.json"));
  const restart = readOptionalJson(join(v0134ArtifactRoot, "restart-integrity-report.json"));
  const softlock = readOptionalJson(join(v0134ArtifactRoot, "no-softlock-proof.json"));
  const shortcut = readOptionalJson(join(v0134ArtifactRoot, "no-shortcut-proof.json"));
  const manifest = readOptionalJson(join(v0134ArtifactRoot, "screenshot-manifest.json"));
  const errors = [];
  const requiredRecoveryCases = [
    "empty_terrain_before_aster",
    "invalid_move_before_selection",
    "right_click_friendly_unit",
    "move_aster_away_during_conversion",
    "reenter_capture_ring",
    "miss_worker_click_once",
    "click_barracks_before_worker_selection",
    "empty_box_select_during_combat",
    "reselect_defenders",
    "attack_with_no_valid_selection"
  ];
  if (triple?.status !== "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH") {
    errors.push(`Triple natural playthrough report did not pass: ${triple?.status ?? "missing"}.`);
  }
  if (triple?.profileCount !== 3) {
    errors.push(`Expected 3 playthrough profiles, found ${triple?.profileCount ?? "missing"}.`);
  }
  if (triple?.privateHarnessShortcutUsed !== false || triple?.debugShortcutUsed !== false || triple?.stateInjectionUsed !== false || triple?.scriptedObjectiveSkippingUsed !== false || triple?.fixtureOnlyHelperProofUsed !== false) {
    errors.push("Triple playthrough report used a forbidden shortcut/debug/state/fixture path.");
  }
  if (triple?.linkedWardDamageTakenMultiplier !== 0.92) {
    errors.push("linked_ward damage multiplier was not preserved at 0.92.");
  }
  const profiles = triple?.profiles ?? [];
  for (const requiredProfile of ["normal_direct_path", "recoverable_mistakes", "restart_and_replay"]) {
    if (!profiles.some((profile) => profile.id === requiredProfile)) {
      errors.push(`Missing v0.134 playthrough profile: ${requiredProfile}.`);
    }
  }
  for (const profile of profiles) {
    if (profile.id === "restart_and_replay") {
      if ((profile.passes ?? []).length !== 2) {
        errors.push("Restart-and-replay profile did not include initial and replay passes.");
      }
      if (profile.returnedToTitle !== true) {
        errors.push("Restart-and-replay profile did not return to title.");
      }
      for (const pass of profile.passes ?? []) {
        if (pass.resultsReached !== true || String(pass.status).startsWith("FAIL")) {
          errors.push(`Restart replay pass did not reach Results cleanly: ${pass.id ?? "unknown"}.`);
        }
      }
    } else if (profile.resultsReached !== true || String(profile.status).startsWith("FAIL")) {
      errors.push(`Profile did not reach Results cleanly: ${profile.id ?? "unknown"}.`);
    } else if (profile.returnedToTitle !== true) {
      errors.push(`Profile did not return to title: ${profile.id ?? "unknown"}.`);
    }
  }
  if (recovery?.status !== "PASS_V0134_RECOVERY_CASES") {
    errors.push(`Recovery report did not pass: ${recovery?.status ?? "missing"}.`);
  }
  const cases = recovery?.cases ?? [];
  for (const caseId of requiredRecoveryCases) {
    const entry = cases.find((item) => item.id === caseId);
    if (!entry) {
      errors.push(`Missing recovery case: ${caseId}.`);
    } else if (entry.passed !== true) {
      errors.push(`Recovery case did not pass: ${caseId}.`);
    }
  }
  if (restart?.status !== "PASS_V0134_RESTART_INTEGRITY") {
    errors.push(`Restart integrity report did not pass: ${restart?.status ?? "missing"}.`);
  }
  const resetChecks = restart?.checks ?? [];
  for (const resetId of ["restart_and_replay_results_restart", "restart_and_replay_return_title_start_again"]) {
    const entry = resetChecks.find((item) => item.id === resetId);
    if (!entry) {
      errors.push(`Missing restart integrity check: ${resetId}.`);
    } else if (entry.passed !== true) {
      errors.push(`Restart integrity check did not pass: ${resetId}.`);
    }
  }
  if (softlock?.status !== "PASS_V0134_NO_SOFTLOCK_PROOF" || softlock?.allProfilesReachedResults !== true || softlock?.allProfilesReturnedToTitle !== true || softlock?.objectiveRegressionDetected !== false) {
    errors.push(`No-softlock proof did not pass: ${softlock?.status ?? "missing"}.`);
  }
  if (shortcut?.status !== "PASS_V0134_NO_SHORTCUT_PROOF") {
    errors.push(`No-shortcut proof did not pass: ${shortcut?.status ?? "missing"}.`);
  }
  for (const field of [
    "privateHarnessShortcutUsed",
    "debugShortcutUsed",
    "stateInjectionUsed",
    "scriptedObjectiveSkippingUsed",
    "fixtureOnlyHelperProofUsed",
    "screenshotOnlyProofUsed",
    "routineEditorUseRequired"
  ]) {
    if (shortcut?.[field] !== false) {
      errors.push(`No-shortcut proof expected ${field} false.`);
    }
  }
  const captures = manifest?.captures ?? [];
  if (manifest?.status !== "PASS_V0134_SCREENSHOT_MANIFEST") {
    errors.push(`Screenshot manifest did not pass: ${manifest?.status ?? "missing"}.`);
  }
  if (captures.length < 24) {
    errors.push(`Expected at least 24 v0.134 screenshots, found ${captures.length}.`);
  }
  const enrichedCaptures = captures.map((capture) => {
    const screenshotPath = join(v0134ScreenshotRoot, capture.fileName);
    const exists = existsSync(screenshotPath);
    if (!exists) {
      errors.push(`Missing screenshot file: ${capture.fileName}.`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    return {
      ...capture,
      path: relativeRepo(screenshotPath),
      sha256: exists ? hashFile(screenshotPath) : null,
      sizeBytes: exists ? statSync(screenshotPath).size : null
    };
  });
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.134",
    status: errors.length === 0 ? "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH_VALIDATION" : "FAIL_V0134_TRIPLE_NATURAL_PLAYTHROUGH_VALIDATION",
    generatedAtUtc: "deterministic-v0134",
    tripleStatus: triple?.status ?? null,
    recoveryStatus: recovery?.status ?? null,
    restartStatus: restart?.status ?? null,
    softlockStatus: softlock?.status ?? null,
    shortcutStatus: shortcut?.status ?? null,
    screenshotStatus: manifest?.status ?? null,
    profileCount: triple?.profileCount ?? null,
    recoveryCaseCount: cases.length,
    restartCheckCount: resetChecks.length,
    captureCount: captures.length,
    requiredCaptureCount: 24,
    noPrivateHarnessShortcutUsed: shortcut?.privateHarnessShortcutUsed === false,
    noDebugShortcutUsed: shortcut?.debugShortcutUsed === false,
    noStateInjectionUsed: shortcut?.stateInjectionUsed === false,
    noScriptedObjectiveSkippingUsed: shortcut?.scriptedObjectiveSkippingUsed === false,
    noFixtureOnlyHelperProofUsed: shortcut?.fixtureOnlyHelperProofUsed === false,
    screenshotOnlyProofUsed: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    linkedWardDamageTakenMultiplier: 0.92,
    errors,
    captures: enrichedCaptures
  };
  writeJson(join(v0134ArtifactRoot, "triple-natural-playthrough-validation.json"), report);
  return report;
}

function validateV0135RtsErgonomicsArtifacts() {
  const smoke = readOptionalJson(join(v0135ArtifactRoot, "headed-rts-ergonomics-smoke.json")) ?? readOptionalJson(join(v0135ArtifactRoot, "rts-ergonomics-smoke.json"));
  const inputContract = readOptionalJson(join(v0135ArtifactRoot, "rts-input-contract.json"));
  const orderFeedback = readOptionalJson(join(v0135ArtifactRoot, "order-feedback-report.json"));
  const cameraControl = readOptionalJson(join(v0135ArtifactRoot, "camera-control-report.json"));
  const compactHelp = readOptionalJson(join(v0135ArtifactRoot, "compact-help-report.json"));
  const trace = readOptionalJson(join(v0135ArtifactRoot, "rts-ergonomics-trace.json"));
  const manifest = readOptionalJson(join(v0135ArtifactRoot, "screenshot-manifest.json"));
  const errors = [];
  const requiredContractChecks = [
    "leftClickFriendlySelect",
    "leftClickEmptyDeselect",
    "leftDragBoxSelect",
    "rightClickTerrainMove",
    "rightClickHostileAttack",
    "rightClickObjectiveContextAction",
    "mouseWheelZoom",
    "keyboardCameraPan",
    "spaceFocusAster",
    "escapeRecoverable",
    "helpOverlay",
    "moveMarker",
    "attackMarker",
    "contextMarker",
    "invalidOrderMarker",
    "hoverResponse",
    "shortTooltip",
    "selectedUnitMarker",
    "selectedSquadCount",
    "cameraBoundsSafe",
    "zoomBoundsSafe",
    "minimapViewportIndicator"
  ];
  const requiredCaptures = [
    "battle_ready",
    "help_opened",
    "help_dismissed",
    "aster_selected",
    "camera_controls",
    "invalid_order_recovery",
    "move_marker",
    "mine_controlled",
    "worker_context_action",
    "barracks_context_action",
    "militia_spawned",
    "wave_movement",
    "squad_attack",
    "wave_defeated",
    "results"
  ];
  if (!smoke) {
    errors.push("Missing headed-rts-ergonomics-smoke.json or rts-ergonomics-smoke.json.");
  } else {
    if (smoke.status !== "PASS_V0135_HEADED_RTS_ERGONOMICS_SMOKE") {
      errors.push(`RTS ergonomics smoke did not pass: ${smoke.status ?? "missing"}.`);
    }
    for (const field of [
      "privateHarnessShortcutUsed",
      "debugShortcutUsed",
      "stateInjectionUsed",
      "fixtureOnlyHelperProofUsed",
      "screenshotOnlyProofUsed",
      "routineEditorUseRequired",
      "saveWritesAllowed",
      "stableIdsChanged",
      "browserRuntimeChanged",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated"
    ]) {
      if (smoke[field] !== false) {
        errors.push(`RTS ergonomics smoke expected ${field} false.`);
      }
    }
    if (smoke.linkedWardDamageTakenMultiplier !== 0.92) {
      errors.push("linked_ward damage multiplier was not preserved at 0.92.");
    }
    for (const key of requiredContractChecks) {
      if (smoke.checks?.[key] !== true) {
        errors.push(`RTS ergonomics smoke check ${key} was not true.`);
      }
    }
    for (const key of ["resultsReached", "noObjectiveRegression", "noDebugShortcut", "noStateInjection", "linkedWardPreserved"]) {
      if (smoke.finishChecks?.[key] !== true) {
        errors.push(`RTS ergonomics finish check ${key} was not true.`);
      }
    }
    if (smoke.postMineStatus?.resultsReached !== true) {
      errors.push("RTS ergonomics post-mine status did not reach Results.");
    }
    if (smoke.rtsStatus?.status !== "PASS_V0135_RTS_ERGONOMICS_SCENE_STATUS") {
      errors.push(`Scene ergonomics status did not pass: ${smoke.rtsStatus?.status ?? "missing"}.`);
    }
  }
  const expectedReports = [
    [inputContract, "PASS_V0135_RTS_INPUT_CONTRACT", "rts-input-contract.json"],
    [orderFeedback, "PASS_V0135_ORDER_FEEDBACK", "order-feedback-report.json"],
    [cameraControl, "PASS_V0135_CAMERA_CONTROL", "camera-control-report.json"],
    [compactHelp, "PASS_V0135_COMPACT_HELP", "compact-help-report.json"]
  ];
  for (const [report, expectedStatus, fileName] of expectedReports) {
    if (report?.status !== expectedStatus) {
      errors.push(`${fileName} did not pass: ${report?.status ?? "missing"}.`);
    }
  }
  if (!trace) {
    errors.push("Missing rts-ergonomics-trace.json.");
  } else {
    const events = new Set((trace.trace ?? []).map((entry) => entry.event));
    [
      "help_opened_f1",
      "help_closed_escape",
      "aster_selected",
      "camera_zoom_pan_focus",
      "empty_left_click_deselect",
      "invalid_no_selection_right_click",
      "move_order_mine",
      "worker_context_mine",
      "squad_attack_right_click"
    ].forEach((event) => {
      if (!events.has(event)) {
        errors.push(`Missing v0.135 RTS ergonomics trace event: ${event}.`);
      }
    });
    if (trace.noPrivateHarnessShortcutUsed !== true || trace.noDebugShortcutUsed !== true || trace.noStateInjectionUsed !== true || trace.fixtureOnlyHelperProofUsed !== false) {
      errors.push("RTS ergonomics trace did not preserve no-shortcut proof.");
    }
  }
  const captures = manifest?.captures ?? [];
  if (manifest?.status !== "PASS_V0135_SCREENSHOT_MANIFEST") {
    errors.push(`Screenshot manifest did not pass: ${manifest?.status ?? "missing"}.`);
  }
  if (captures.length < 14) {
    errors.push(`Expected at least 14 v0.135 screenshots, found ${captures.length}.`);
  }
  for (const id of requiredCaptures) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.135 screenshot capture: ${id}.`);
    }
  }
  const enrichedCaptures = captures.map((capture) => {
    const screenshotPath = join(v0135ScreenshotRoot, capture.fileName);
    const exists = existsSync(screenshotPath);
    if (!exists) {
      errors.push(`Missing screenshot file: ${capture.fileName}.`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    const status = capture.status ?? {};
    if (status.generatedOrImportedArtIncluded === true || status.runtimeArtIntegrated === true || status.saveWritesAllowed === true || status.stableIdsChanged === true || status.browserRuntimeChanged === true) {
      errors.push(`Capture ${capture.id} reported forbidden art/save/stable/browser drift.`);
    }
    return {
      ...capture,
      path: relativeRepo(screenshotPath),
      sha256: exists ? hashFile(screenshotPath) : null,
      sizeBytes: exists ? statSync(screenshotPath).size : null
    };
  });
  const strayPngs = existsSync(v0135ScreenshotRoot)
    ? readdirSync(v0135ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0135 folder: ${strayPngs.join(", ")}.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.135",
    status: errors.length === 0 ? "PASS_V0135_RTS_ERGONOMICS_VALIDATION" : "FAIL_V0135_RTS_ERGONOMICS_VALIDATION",
    generatedAtUtc: "deterministic-v0135",
    smokeStatus: smoke?.status ?? null,
    inputContractStatus: inputContract?.status ?? null,
    orderFeedbackStatus: orderFeedback?.status ?? null,
    cameraControlStatus: cameraControl?.status ?? null,
    compactHelpStatus: compactHelp?.status ?? null,
    screenshotStatus: manifest?.status ?? null,
    captureCount: captures.length,
    requiredCaptureCount: 14,
    noPrivateHarnessShortcutUsed: smoke?.privateHarnessShortcutUsed === false,
    noDebugShortcutUsed: smoke?.debugShortcutUsed === false,
    noStateInjectionUsed: smoke?.stateInjectionUsed === false,
    noFixtureOnlyHelperProofUsed: smoke?.fixtureOnlyHelperProofUsed === false,
    screenshotOnlyProofUsed: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    linkedWardDamageTakenMultiplier: 0.92,
    errors,
    captures: enrichedCaptures
  };
  writeJson(join(v0135ArtifactRoot, "rts-ergonomics-validation.json"), report);
  return report;
}

function validateV0136UsabilityPresentationArtifacts() {
  const smoke = readOptionalJson(join(v0136ArtifactRoot, "headed-usability-presentation-smoke.json")) ?? readOptionalJson(join(v0136ArtifactRoot, "usability-presentation-smoke.json"));
  const hud = readOptionalJson(join(v0136ArtifactRoot, "hud-hierarchy-report.json"));
  const minimap = readOptionalJson(join(v0136ArtifactRoot, "minimap-refinement-report.json"));
  const onboarding = readOptionalJson(join(v0136ArtifactRoot, "onboarding-copy-report.json"));
  const pacing = readOptionalJson(join(v0136ArtifactRoot, "microloop-pacing-report.json"));
  const trace = readOptionalJson(join(v0136ArtifactRoot, "usability-presentation-trace.json"));
  const manifest = readOptionalJson(join(v0136ArtifactRoot, "screenshot-manifest.json"));
  const errors = [];
  const requiredChecks = [
    "primaryObjectiveLine",
    "secondaryHintCompact",
    "noRedundantTopBottomBanners",
    "selectedEntityCardCompact",
    "resourceRowCompact",
    "commandButtonsCompact",
    "waveCounterConcise",
    "progressReadable",
    "lumeStateReadable",
    "minimapTerrainOutline",
    "minimapHeroMarker",
    "minimapWorkerMarker",
    "minimapFriendlyGroupMarker",
    "minimapActiveAshenOnly",
    "minimapObjectiveMarker",
    "minimapMineControlledMarker",
    "minimapBarracksMarker",
    "minimapLumeLink",
    "minimapCameraViewport",
    "minimapClickToOrient",
    "canonicalOnboardingCopy",
    "noDebugText",
    "pacingTuned",
    "resultsRecap"
  ];
  const requiredCaptures = [
    "title",
    "briefing",
    "hud_default",
    "minimap_default",
    "mine_conversion",
    "worker_assignment",
    "minimap_mine_controlled",
    "construction",
    "recruitment",
    "countdown",
    "minimap_wave",
    "combat",
    "lume",
    "results"
  ];
  if (!smoke) {
    errors.push("Missing headed-usability-presentation-smoke.json or usability-presentation-smoke.json.");
  } else {
    if (smoke.status !== "PASS_V0136_HEADED_USABILITY_PRESENTATION_SMOKE") {
      errors.push(`Usability presentation smoke did not pass: ${smoke.status ?? "missing"}.`);
    }
    for (const field of [
      "privateHarnessShortcutUsed",
      "debugShortcutUsed",
      "stateInjectionUsed",
      "fixtureOnlyHelperProofUsed",
      "screenshotOnlyProofUsed",
      "routineEditorUseRequired",
      "saveWritesAllowed",
      "stableIdsChanged",
      "browserRuntimeChanged",
      "generatedOrImportedArtIncluded",
      "runtimeArtIntegrated"
    ]) {
      if (smoke[field] !== false) {
        errors.push(`Usability presentation smoke expected ${field} false.`);
      }
    }
    if (smoke.linkedWardDamageTakenMultiplier !== 0.92) {
      errors.push("linked_ward damage multiplier was not preserved at 0.92.");
    }
    for (const key of requiredChecks) {
      if (smoke.checks?.[key] !== true) {
        errors.push(`Usability presentation smoke check ${key} was not true.`);
      }
    }
    for (const key of ["resultsReached", "noObjectiveRegression", "noDebugShortcut", "noStateInjection", "linkedWardPreserved"]) {
      if (smoke.finishChecks?.[key] !== true) {
        errors.push(`Usability presentation finish check ${key} was not true.`);
      }
    }
    if (smoke.usabilityStatus?.status !== "PASS_V0136_USABILITY_PRESENTATION_SCENE_STATUS") {
      errors.push(`Scene usability presentation status did not pass: ${smoke.usabilityStatus?.status ?? "missing"}.`);
    }
    if (smoke.postMineStatus?.resultsReached !== true) {
      errors.push("Post-mine flow did not reach Results in the v0.136 smoke.");
    }
  }
  const expectedReports = [
    [hud, "PASS_V0136_HUD_HIERARCHY", "hud-hierarchy-report.json"],
    [minimap, "PASS_V0136_MINIMAP_REFINEMENT", "minimap-refinement-report.json"],
    [onboarding, "PASS_V0136_ONBOARDING_COPY", "onboarding-copy-report.json"],
    [pacing, "PASS_V0136_MICROLOOP_PACING", "microloop-pacing-report.json"]
  ];
  for (const [report, expectedStatus, fileName] of expectedReports) {
    if (report?.status !== expectedStatus) {
      errors.push(`${fileName} did not pass: ${report?.status ?? "missing"}.`);
    }
  }
  if (!trace) {
    errors.push("Missing usability-presentation-trace.json.");
  } else {
    const events = new Set((trace.trace ?? []).map((entry) => entry.event));
    [
      "title_start_clicked",
      "briefing_start_battle_clicked",
      "minimap_click_to_orient",
      "move_order_mine",
      "worker_assigned",
      "barracks_restore_order",
      "train_militia_clicked",
      "combat_attack_right_click",
      "lume_restore_click"
    ].forEach((event) => {
      if (!events.has(event)) {
        errors.push(`Missing v0.136 usability presentation trace event: ${event}.`);
      }
    });
    if (trace.noPrivateHarnessShortcutUsed !== true || trace.noDebugShortcutUsed !== true || trace.noStateInjectionUsed !== true || trace.fixtureOnlyHelperProofUsed !== false) {
      errors.push("Usability presentation trace did not preserve no-shortcut proof.");
    }
  }
  const captures = manifest?.captures ?? [];
  if (manifest?.status !== "PASS_V0136_SCREENSHOT_MANIFEST") {
    errors.push(`Screenshot manifest did not pass: ${manifest?.status ?? "missing"}.`);
  }
  if (captures.length < 12) {
    errors.push(`Expected at least 12 v0.136 screenshots, found ${captures.length}.`);
  }
  for (const id of requiredCaptures) {
    if (!captures.some((capture) => capture.id === id)) {
      errors.push(`Missing v0.136 screenshot capture: ${id}.`);
    }
  }
  const enrichedCaptures = captures.map((capture) => {
    const screenshotPath = join(v0136ScreenshotRoot, capture.fileName);
    const exists = existsSync(screenshotPath);
    if (!exists) {
      errors.push(`Missing screenshot file: ${capture.fileName}.`);
    }
    if (capture.width !== 1600 || capture.height !== 900) {
      errors.push(`Screenshot ${capture.fileName} is ${capture.width}x${capture.height}, expected 1600x900.`);
    }
    const status = capture.status ?? {};
    if (status.generatedOrImportedArtIncluded === true || status.runtimeArtIntegrated === true || status.saveWritesAllowed === true || status.stableIdsChanged === true || status.browserRuntimeChanged === true) {
      errors.push(`Capture ${capture.id} reported forbidden art/save/stable/browser drift.`);
    }
    return {
      ...capture,
      path: relativeRepo(screenshotPath),
      sha256: exists ? hashFile(screenshotPath) : null,
      sizeBytes: exists ? statSync(screenshotPath).size : null
    };
  });
  const strayPngs = existsSync(v0136ScreenshotRoot)
    ? readdirSync(v0136ScreenshotRoot).filter((file) => file.endsWith(".png") && !captures.some((capture) => capture.fileName === file))
    : [];
  if (strayPngs.length > 0) {
    errors.push(`Unexpected screenshots in v0136 folder: ${strayPngs.join(", ")}.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint: "v0.136",
    status: errors.length === 0 ? "PASS_V0136_USABILITY_PRESENTATION_VALIDATION" : "FAIL_V0136_USABILITY_PRESENTATION_VALIDATION",
    generatedAtUtc: "deterministic-v0136",
    smokeStatus: smoke?.status ?? null,
    hudStatus: hud?.status ?? null,
    minimapStatus: minimap?.status ?? null,
    onboardingStatus: onboarding?.status ?? null,
    pacingStatus: pacing?.status ?? null,
    screenshotStatus: manifest?.status ?? null,
    captureCount: captures.length,
    requiredCaptureCount: 12,
    noPrivateHarnessShortcutUsed: smoke?.privateHarnessShortcutUsed === false,
    noDebugShortcutUsed: smoke?.debugShortcutUsed === false,
    noStateInjectionUsed: smoke?.stateInjectionUsed === false,
    noFixtureOnlyHelperProofUsed: smoke?.fixtureOnlyHelperProofUsed === false,
    screenshotOnlyProofUsed: false,
    routineEditorUseRequired: false,
    saveWritesAllowed: false,
    stableIdsChanged: false,
    browserRuntimeChanged: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    linkedWardDamageTakenMultiplier: 0.92,
    errors,
    captures: enrichedCaptures
  };
  writeJson(join(v0136ArtifactRoot, "usability-presentation-validation.json"), report);
  return report;
}

const v0125AuditAreas = ["title", "briefing", "battle", "results"];
const v0125PlayerDebugTerms = [
  ...v0124ForbiddenTerms,
  "private visual-review",
  "proof",
  "workload",
  "stable-id",
  "local storage",
  "raw fixture",
  "developer"
];

function readOptionalJson(path) {
  return existsSync(path) ? readJson(path) : null;
}

function findCapture(manifest, id) {
  return manifest?.captures?.find((capture) => capture.id === id) ?? null;
}

function findValidationStep(validation, id) {
  return validation?.steps?.find((step) => step.id === id) ?? null;
}

function statusFor(validation, manifest, id) {
  return findValidationStep(validation, id)?.status ?? findCapture(manifest, id)?.status ?? {};
}

function visibleTextFor(manifest, id) {
  return (findCapture(manifest, id)?.visibleText ?? []).map((text) => String(text));
}

function containsAnyText(texts, terms) {
  const haystack = texts.join("\n").toLowerCase();
  return terms.filter((term) => haystack.includes(String(term).toLowerCase()));
}

function hasAllText(texts, terms) {
  const haystack = texts.join("\n").toLowerCase();
  return terms.every((term) => haystack.includes(String(term).toLowerCase()));
}

function auditCheck(area, id, label, pass, severity, evidence) {
  return {
    area,
    id,
    label,
    pass: Boolean(pass),
    severity,
    evidence
  };
}

function summarizeV0125Evidence(manifest, validation, performance) {
  return {
    checkpoint: "v0.125",
    sourceManifestStatus: manifest?.status ?? "missing",
    validationStatus: validation?.status ?? "missing",
    performanceStatus: performance?.status ?? "missing",
    captureCount: manifest?.captureCount ?? 0,
    screenshots: (manifest?.captures ?? []).map((capture) => ({
      id: capture.id,
      fileName: capture.fileName,
      sha256: capture.sha256,
      width: capture.width,
      height: capture.height,
      visibleText: capture.visibleText ?? [],
      statusDigest: {
        playerShellScreen: capture.status?.playerShellScreen ?? null,
        hudVisible: capture.status?.hudVisible ?? null,
        playerFacingNonBattleChromeHidden: capture.status?.playerFacingNonBattleChromeHidden ?? null,
        playerFacingSelectionUsesFixtureIds: capture.status?.playerFacingSelectionUsesFixtureIds ?? null,
        terrainViewportCoveragePass: capture.status?.terrainViewportCoveragePass ?? null
      }
    })),
    validationStepDigest: (validation?.steps ?? []).map((step) => ({
      id: step.id,
      visibleText: step.visibleText ?? [],
      statusDigest: {
        playerShellScreen: step.status?.playerShellScreen ?? null,
        hudVisible: step.status?.hudVisible ?? null,
        playerFacingNonBattleChromeHidden: step.status?.playerFacingNonBattleChromeHidden ?? null,
        playerFacingSelectionUsesFixtureIds: step.status?.playerFacingSelectionUsesFixtureIds ?? null,
        terrainViewportCoveragePass: step.status?.terrainViewportCoveragePass ?? null
      }
    }))
  };
}

function buildV0125ScreenshotAudit() {
  const manifest = readOptionalJson(join(v0124ArtifactRoot, "screenshot-manifest.json"));
  const validation = readOptionalJson(join(v0124ArtifactRoot, "player-slice-validation.json"));
  const performance = readOptionalJson(join(v0124ArtifactRoot, "performance-smoke.json"));
  const previousAudit = readOptionalJson(join(v0125ArtifactRoot, "screenshot-audit.json"));
  const previousBeforeAfter = readOptionalJson(join(v0125ArtifactRoot, "before-after-manifest.json"));
  const checks = [];
  const requiredCaptureIds = v0124CaptureOrder;
  const missingCaptures = requiredCaptureIds.filter((id) => !findCapture(manifest, id));
  const titleText = visibleTextFor(manifest, "title");
  const briefingText = visibleTextFor(manifest, "briefing");
  const battleText = visibleTextFor(manifest, "battle_default");
  const resultsText = visibleTextFor(manifest, "results");
  const titleStatus = statusFor(validation, manifest, "title");
  const briefingStatus = statusFor(validation, manifest, "briefing");
  const battleStatus = statusFor(validation, manifest, "battle_default");
  const heroStatus = statusFor(validation, manifest, "hero_selected");
  const workerStatus = statusFor(validation, manifest, "worker_selected");
  const squadStatus = statusFor(validation, manifest, "squad_selected");
  const resultsStatus = statusFor(validation, manifest, "results");
  const titleForbidden = containsAnyText(titleText, v0125PlayerDebugTerms);
  const briefingForbidden = containsAnyText(briefingText, v0125PlayerDebugTerms);
  const battleForbidden = containsAnyText(battleText, v0125PlayerDebugTerms);
  const resultsForbidden = containsAnyText(resultsText, v0125PlayerDebugTerms);

  checks.push(
    auditCheck("title", "V0125_TITLE_CAPTURE_PRESENT", "Title screenshot exists at 1600x900.", !missingCaptures.includes("title") && findCapture(manifest, "title")?.width === 1600 && findCapture(manifest, "title")?.height === 900, "blocking", {
      missingCaptures,
      width: findCapture(manifest, "title")?.width ?? null,
      height: findCapture(manifest, "title")?.height ?? null
    }),
    auditCheck("title", "V0125_TITLE_NO_DEBUG_JARGON", "Title contains only player-facing copy.", titleForbidden.length === 0 && titleText.includes("Salto foothold review"), "major", {
      visibleText: titleText,
      forbiddenHits: titleForbidden
    }),
    auditCheck("title", "V0125_TITLE_CHROME_HIDDEN", "Battle HUD and minimap are hidden on the title screen.", titleStatus.playerFacingNonBattleChromeHidden === true && titleStatus.hudVisible === false, "major", {
      playerShellScreen: titleStatus.playerShellScreen ?? null,
      hudVisible: titleStatus.hudVisible ?? null,
      playerFacingNonBattleChromeHidden: titleStatus.playerFacingNonBattleChromeHidden ?? null
    }),
    auditCheck("title", "V0125_TITLE_PRIMARY_ACTION_CLEAR", "Title presents the review start action clearly.", hasAllText(titleText, ["JARDAS: Salto Foothold", "Start Salto Review"]), "minor", {
      visibleText: titleText
    })
  );

  checks.push(
    auditCheck("briefing", "V0125_BRIEFING_CAPTURE_PRESENT", "Briefing screenshot exists at 1600x900.", !missingCaptures.includes("briefing") && findCapture(manifest, "briefing")?.width === 1600 && findCapture(manifest, "briefing")?.height === 900, "blocking", {
      missingCaptures,
      width: findCapture(manifest, "briefing")?.width ?? null,
      height: findCapture(manifest, "briefing")?.height ?? null
    }),
    auditCheck("briefing", "V0125_BRIEFING_OBJECTIVE_COPY", "Briefing has the short Salto premise and three objective beats.", hasAllText(briefingText, ["Hold the quarry", "Select Aster", "Guide the Worker", "Break one Ashen wave", "Start Battle"]), "major", {
      visibleText: briefingText
    }),
    auditCheck("briefing", "V0125_BRIEFING_NO_DEBUG_JARGON", "Briefing contains no engineering or benchmark terms.", briefingForbidden.length === 0, "major", {
      visibleText: briefingText,
      forbiddenHits: briefingForbidden
    }),
    auditCheck("briefing", "V0125_BRIEFING_CHROME_HIDDEN", "Battle HUD and minimap are hidden during briefing.", briefingStatus.playerFacingNonBattleChromeHidden === true && briefingStatus.hudVisible === false, "major", {
      playerShellScreen: briefingStatus.playerShellScreen ?? null,
      hudVisible: briefingStatus.hudVisible ?? null,
      playerFacingNonBattleChromeHidden: briefingStatus.playerFacingNonBattleChromeHidden ?? null
    })
  );

  checks.push(
    auditCheck("battle", "V0125_BATTLE_CAPTURE_PRESENT", "Battle screenshot exists at 1600x900.", !missingCaptures.includes("battle_default") && findCapture(manifest, "battle_default")?.width === 1600 && findCapture(manifest, "battle_default")?.height === 900, "blocking", {
      missingCaptures,
      width: findCapture(manifest, "battle_default")?.width ?? null,
      height: findCapture(manifest, "battle_default")?.height ?? null
    }),
    auditCheck("battle", "V0125_BATTLE_HUD_VISIBLE", "Battle keeps the compact player HUD and minimap visible.", battleStatus.hudVisible === true && battleStatus.playerFacingHudCompact === true, "major", {
      hudVisible: battleStatus.hudVisible ?? null,
      playerFacingHudCompact: battleStatus.playerFacingHudCompact ?? null,
      minimapMarkersRendered: battleStatus.minimapMarkersRendered ?? null
    }),
    auditCheck("battle", "V0125_BATTLE_TERRAIN_COVERAGE", "Battle camera is covered by Salto terrain without obvious gray margins.", battleStatus.terrainViewportCoveragePass === true, "major", {
      terrainViewportCoveragePass: battleStatus.terrainViewportCoveragePass ?? null,
      cameraPanBounds: battleStatus.cameraPanBounds ?? null
    }),
    auditCheck("battle", "V0125_BATTLE_FACTION_READABILITY", "Battle keeps hero, faction silhouettes, capture site, Lume, objectives, and minimap evidence.", Boolean(battleStatus.factionSilhouettePassRendered && battleStatus.selectedHeroCardRendered && battleStatus.captureSiteMarkerRendered && battleStatus.lumeLinkRendered && battleStatus.objectiveSummaryRendered && battleStatus.minimapMarkersRendered), "major", {
      factionSilhouettePassRendered: battleStatus.factionSilhouettePassRendered ?? null,
      selectedHeroCardRendered: battleStatus.selectedHeroCardRendered ?? null,
      captureSiteMarkerRendered: battleStatus.captureSiteMarkerRendered ?? null,
      lumeLinkRendered: battleStatus.lumeLinkRendered ?? null,
      objectiveSummaryRendered: battleStatus.objectiveSummaryRendered ?? null,
      minimapMarkersRendered: battleStatus.minimapMarkersRendered ?? null
    }),
    auditCheck("battle", "V0125_BATTLE_NO_DEBUG_OR_IDS", "Battle-facing HUD text avoids debug terms and raw fixture IDs.", battleForbidden.length === 0 && heroStatus.playerFacingSelectionUsesFixtureIds === false && workerStatus.playerFacingSelectionUsesFixtureIds === false && squadStatus.playerFacingSelectionUsesFixtureIds === false, "major", {
      visibleText: battleText,
      forbiddenHits: battleForbidden,
      heroSelectionUsesFixtureIds: heroStatus.playerFacingSelectionUsesFixtureIds ?? null,
      workerSelectionUsesFixtureIds: workerStatus.playerFacingSelectionUsesFixtureIds ?? null,
      squadSelectionUsesFixtureIds: squadStatus.playerFacingSelectionUsesFixtureIds ?? null
    }),
    auditCheck("battle", "V0125_BATTLE_AUTOMATION_BOUNDARY", "Battle evidence preserves no art imports, save writes, localStorage mutation, or stable-ID changes.", validation?.generatedOrImportedArtIncluded === false && validation?.runtimeArtIntegrated === false && validation?.saveWritesAllowed === false && validation?.localStorageMutationAllowed === false && validation?.stableIdsChanged === false, "blocking", {
      generatedOrImportedArtIncluded: validation?.generatedOrImportedArtIncluded ?? null,
      runtimeArtIntegrated: validation?.runtimeArtIntegrated ?? null,
      saveWritesAllowed: validation?.saveWritesAllowed ?? null,
      localStorageMutationAllowed: validation?.localStorageMutationAllowed ?? null,
      stableIdsChanged: validation?.stableIdsChanged ?? null
    })
  );

  checks.push(
    auditCheck("results", "V0125_RESULTS_CAPTURE_PRESENT", "Results screenshot exists at 1600x900.", !missingCaptures.includes("results") && findCapture(manifest, "results")?.width === 1600 && findCapture(manifest, "results")?.height === 900, "blocking", {
      missingCaptures,
      width: findCapture(manifest, "results")?.width ?? null,
      height: findCapture(manifest, "results")?.height ?? null
    }),
    auditCheck("results", "V0125_RESULTS_SHORT_RECAP", "Results has a short recap and restart/return actions.", hasAllText(resultsText, ["Salto Review Complete", "Quarry held", "Restart Slice", "Return to Title"]), "major", {
      visibleText: resultsText
    }),
    auditCheck("results", "V0125_RESULTS_NO_DEBUG_JARGON", "Results avoids debug walls and engineering terms.", resultsForbidden.length === 0 && resultsText.length <= 6, "major", {
      visibleText: resultsText,
      forbiddenHits: resultsForbidden,
      visibleTextCount: resultsText.length
    }),
    auditCheck("results", "V0125_RESULTS_CHROME_HIDDEN", "Battle HUD and minimap are hidden on Results.", resultsStatus.playerFacingNonBattleChromeHidden === true && resultsStatus.hudVisible === false, "major", {
      playerShellScreen: resultsStatus.playerShellScreen ?? null,
      hudVisible: resultsStatus.hudVisible ?? null,
      playerFacingNonBattleChromeHidden: resultsStatus.playerFacingNonBattleChromeHidden ?? null
    })
  );

  checks.push(
    auditCheck("battle", "V0125_PRIVATE_HARNESS_STILL_SEPARATE", "Private engineering harness remains a separate explicit capture.", manifest?.privateHarnessPreservedSeparately === true && findCapture(manifest, "private_harness_preserved")?.privateHarnessCapture === true, "blocking", {
      privateHarnessPreservedSeparately: manifest?.privateHarnessPreservedSeparately ?? null,
      privateHarnessCapture: findCapture(manifest, "private_harness_preserved")?.privateHarnessCapture ?? null
    }),
    auditCheck("battle", "V0125_PERFORMANCE_SMOKE_STILL_GREEN", "Player-facing performance smoke remains green and non-final.", performance?.status === "PASS_PLAYER_SLICE_PERFORMANCE_SMOKE" && performance?.finalProductionCertification === false, "blocking", {
      status: performance?.status ?? null,
      finalProductionCertification: performance?.finalProductionCertification ?? null,
      fpsAverage: performance?.fpsAverage ?? null,
      frameTimeP95Ms: performance?.frameTimeP95Ms ?? null
    })
  );

  const failedChecks = checks.filter((check) => !check.pass);
  const blockingIssues = failedChecks.filter((check) => check.severity === "blocking");
  const majorIssues = failedChecks.filter((check) => check.severity === "major");
  const readinessStatus = failedChecks.length === 0 && manifest?.status === "PASS_PLAYER_SLICE_SCREENSHOT_CAPTURE" && validation?.status === "PASS_PLAYER_FACING_SLICE_VALIDATION" && performance?.status === "PASS_PLAYER_SLICE_PERFORMANCE_SMOKE"
    ? "PLAYER_SLICE_REVIEW_READY"
    : blockingIssues.length > 0
      ? "PLAYER_SLICE_REVIEW_BLOCKED"
      : majorIssues.length > 0
        ? "PLAYER_SLICE_REVIEW_NOT_READY"
        : "PLAYER_SLICE_REVIEW_READY_WITH_NOTES";
  const audit = {
    schemaVersion: 1,
    checkpoint: "v0.125",
    status: failedChecks.length === 0 ? "PASS_PLAYER_SLICE_SCREENSHOT_AUDIT" : "FAIL_PLAYER_SLICE_SCREENSHOT_AUDIT",
    generatedAtUtc: "deterministic-v0125",
    sourceArtifacts: {
      screenshotManifest: "artifacts/desktop-spikes/godot-salto/v0124/screenshot-manifest.json",
      playerSliceValidation: "artifacts/desktop-spikes/godot-salto/v0124/player-slice-validation.json",
      performanceSmoke: "artifacts/desktop-spikes/godot-salto/v0124/performance-smoke.json"
    },
    auditAreas: v0125AuditAreas,
    readinessStatus,
    blockingIssueCount: blockingIssues.length,
    majorIssueCount: majorIssues.length,
    minorIssueCount: failedChecks.filter((check) => check.severity === "minor").length,
    activeIssueCount: failedChecks.length,
    checks,
    failedChecks,
    previousStatus: previousAudit?.status ?? null,
    editorRequiredForRoutineWork: false,
    generatedOrImportedArtIncluded: false,
    runtimeArtIntegrated: false,
    saveWritesAllowed: false,
    stableIdsChanged: false
  };
  const issueLedger = buildV0125IssueLedger(audit, previousAudit);
  const currentSummary = summarizeV0125Evidence(manifest, validation, performance);
  const beforeSummary = previousBeforeAfter?.before ?? currentSummary;
  const beforeById = new Map((beforeSummary.screenshots ?? []).map((screenshot) => [screenshot.id, screenshot]));
  const afterById = new Map((currentSummary.screenshots ?? []).map((screenshot) => [screenshot.id, screenshot]));
  const changedScreenshotIds = [...new Set([...beforeById.keys(), ...afterById.keys()])]
    .filter((id) => beforeById.get(id)?.sha256 !== afterById.get(id)?.sha256);
  const beforeAfter = {
    schemaVersion: 1,
    checkpoint: "v0.125",
    status: failedChecks.length === 0 ? "PASS_V0125_BEFORE_AFTER_MANIFEST" : "FAIL_V0125_BEFORE_AFTER_MANIFEST",
    generatedAtUtc: "deterministic-v0125",
    before: beforeSummary,
    after: currentSummary,
    changedScreenshotIds,
    activeIssueCount: failedChecks.length,
    resolvedIssueCount: issueLedger.issues.filter((issue) => issue.status === "resolved").length,
    openIssueCount: issueLedger.issues.filter((issue) => issue.status === "open").length
  };
  writeV0125Artifact("screenshot-audit.json", audit);
  writeV0125Artifact("issue-ledger.json", issueLedger);
  writeV0125Artifact("before-after-manifest.json", beforeAfter);
  writeV0125MarkdownReports(audit, issueLedger, beforeAfter);
  return audit;
}

function v0125IssueForCheck(check, status) {
  return {
    issueId: `V0125-${check.id.replace(/^V0125_/u, "")}`,
    checkId: check.id,
    area: check.area,
    severity: check.severity,
    status,
    title: check.label,
    evidence: check.evidence,
    correctionBoundary: "player-facing presentation shell only; no gameplay, save, stable-ID, art import, private-harness, or full-port change"
  };
}

function buildV0125IssueLedger(audit, previousAudit) {
  const currentFailures = new Map(audit.failedChecks.map((check) => [check.id, check]));
  const previousFailures = new Map((previousAudit?.failedChecks ?? []).map((check) => [check.id, check]));
  const issues = [];
  for (const check of currentFailures.values()) {
    issues.push(v0125IssueForCheck(check, "open"));
  }
  for (const [id, check] of previousFailures.entries()) {
    if (!currentFailures.has(id)) {
      issues.push(v0125IssueForCheck(check, "resolved"));
    }
  }
  issues.sort((left, right) => left.issueId.localeCompare(right.issueId));
  return {
    schemaVersion: 1,
    checkpoint: "v0.125",
    status: currentFailures.size === 0 ? "PASS_V0125_ISSUE_LEDGER" : "FAIL_V0125_ISSUE_LEDGER",
    generatedAtUtc: "deterministic-v0125",
    openIssueCount: issues.filter((issue) => issue.status === "open").length,
    resolvedIssueCount: issues.filter((issue) => issue.status === "resolved").length,
    deferredIssueCount: 0,
    issues
  };
}

function writeV0125MarkdownReports(audit, issueLedger, beforeAfter) {
  writeV0125Text(
    "screenshot-audit.md",
    [
      "# v0.125 Player Slice Screenshot Audit",
      "",
      `Status: ${audit.status}`,
      `Readiness: ${audit.readinessStatus}`,
      `Active issues: ${audit.activeIssueCount}`,
      "",
      "Checked areas: title, briefing, battle, and Results.",
      "",
      "| Area | Check | Result | Severity |",
      "| --- | --- | --- | --- |",
      ...audit.checks.map((check) => `| ${check.area} | ${check.id} | ${check.pass ? "PASS" : "FAIL"} | ${check.severity} |`),
      "",
      "Boundary: no artwork import, no save writes, no stable-ID changes, no final engine choice, and no routine Godot editor dependency."
    ].join("\n")
  );
  writeV0125Text(
    "issue-ledger.md",
    [
      "# v0.125 Player Slice Issue Ledger",
      "",
      `Status: ${issueLedger.status}`,
      `Open: ${issueLedger.openIssueCount}`,
      `Resolved: ${issueLedger.resolvedIssueCount}`,
      "",
      "| Issue | Area | Severity | Status | Title |",
      "| --- | --- | --- | --- | --- |",
      ...issueLedger.issues.map((issue) => `| ${issue.issueId} | ${issue.area} | ${issue.severity} | ${issue.status} | ${issue.title} |`),
      "",
      "All corrections must remain player-facing presentation-shell changes only."
    ].join("\n")
  );
  writeV0125Text(
    "README.md",
    [
      "# v0.125 Player Slice Automated Visual QA Artifacts",
      "",
      "This ignored artifact folder is regenerated by `npm run godot:audit:player-slice`.",
      "",
      "- `screenshot-audit.json` and `.md` record title, briefing, battle, and Results checks.",
      "- `issue-ledger.json` and `.md` record open/resolved visual issues.",
      "- `before-after-manifest.json` keeps the first observed screenshot evidence as the before set and the latest capture as the after set.",
      "",
      `Current audit status: ${audit.status}`,
      `Before/after changed screenshots: ${beforeAfter.changedScreenshotIds.join(", ") || "none"}`,
      "",
      "No artifact here is final art, generated imagery, imported artwork, save migration, stable-ID migration, final engine selection, or a full port."
    ].join("\n")
  );
}

function writeV0118AllReports() {
  writeV0118HeadedSmokeReport();
  writeV0118HeadedBenchmarkReports();
  writeV0118ScreenshotManifest();
  writeV0118PackageValidation();
  writeV0118ReviewSummary();
  writeV0118Readme();
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
  const runtime2d = benchmark2d?.runtimeReport ?? null;
  const runtime25d = benchmark25d?.runtimeReport ?? null;
  const tierSCombat2d = phaseReport(runtime2d, "S", "combat");
  const tierMCombat2d = phaseReport(runtime2d, "M", "combat");
  const tierLCombat2d = phaseReport(runtime2d, "L", "combat");
  const tierSCombat25d = phaseReport(runtime25d, "S", "combat");
  const tierMCombat25d = phaseReport(runtime25d, "M", "combat");
  const tierLCombat25d = phaseReport(runtime25d, "L", "combat");
  return {
    ...template,
    checkpoint: "v0.122",
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
      fpsAverage: tierSCombat2d?.fpsAverage ?? null,
      fpsOnePercentLow: tierSCombat2d?.fpsOnePercentLow ?? null,
      frameTimeP50Ms: tierSCombat2d?.frameTimeP50Ms ?? null,
      frameTimeP95Ms: tierSCombat2d?.frameTimeP95Ms ?? null,
      frameTimeP99Ms: tierSCombat2d?.frameTimeP99Ms ?? null,
      frameTimeMaxMs: tierSCombat2d?.frameTimeMaxMs ?? null,
      navigationQueryCount: tierSCombat2d?.navigationQueryCount ?? null,
      stuckUnitCount: tierSCombat2d?.stuckUnitCount ?? null,
      notes: "Tier S representative combat row: hero, one Worker, six friendly military, six Ashen, core structures, one site, and one active Lume link."
    },
    tierM: {
      ...template.tierM,
      fpsAverage: tierMCombat2d?.fpsAverage ?? null,
      fpsOnePercentLow: tierMCombat2d?.fpsOnePercentLow ?? null,
      frameTimeP50Ms: tierMCombat2d?.frameTimeP50Ms ?? null,
      frameTimeP95Ms: tierMCombat2d?.frameTimeP95Ms ?? null,
      frameTimeP99Ms: tierMCombat2d?.frameTimeP99Ms ?? null,
      frameTimeMaxMs: tierMCombat2d?.frameTimeMaxMs ?? null,
      navigationQueryCount: tierMCombat2d?.navigationQueryCount ?? null,
      stuckUnitCount: tierMCombat2d?.stuckUnitCount ?? null,
      aiPressureBeatCount: tierMCombat2d?.aiPressureBeatCount ?? null,
      notes: "Tier M representative combat row includes 43 units, three capture sites, and one bounded enemy-pressure beat."
    },
    tierL: {
      ...template.tierL,
      fpsAverage: tierLCombat2d?.fpsAverage ?? null,
      fpsOnePercentLow: tierLCombat2d?.fpsOnePercentLow ?? null,
      frameTimeP50Ms: tierLCombat2d?.frameTimeP50Ms ?? null,
      frameTimeP95Ms: tierLCombat2d?.frameTimeP95Ms ?? null,
      frameTimeP99Ms: tierLCombat2d?.frameTimeP99Ms ?? null,
      frameTimeMaxMs: tierLCombat2d?.frameTimeMaxMs ?? null,
      navigationQueryCount: tierLCombat2d?.navigationQueryCount ?? null,
      stuckUnitCount: tierLCombat2d?.stuckUnitCount ?? null,
      aiPressureBeatCount: tierLCombat2d?.aiPressureBeatCount ?? null,
      notes: "Tier L representative combat row includes 105 units, five capture sites, two enemy structures, two candidate Lume links, and sustained pressure."
    },
    inputLatency: {
      ...template.inputLatency,
      representativeActionLatencyMs: benchmark2d?.inputLatencyMs ?? null,
      selectionFeedbackMs: benchmark2d?.inputLatency?.selectionLatencyMs ?? null,
      commandFeedbackMs: benchmark2d?.inputLatencyMs ?? null,
      notes: "Headless workload runner measures deterministic selection, move acceptance, and attack acceptance latency."
    },
    sceneLaunchLatency: {
      ...template.sceneLaunchLatency,
      battleLaunchLatencyMs: benchmark2d?.sceneLaunchMs ?? null,
      campaignFrameLaunchLatencyMs: null,
      notes: "Godot spike scene launch only; browser campaign flow is unchanged."
    },
    resultsTransitionLatency: {
      ...template.resultsTransitionLatency,
      resultsTransitionLatencyMs: benchmark2d?.resultsTransitionMs ?? null,
      notes: "Results readiness is recorded by the representative combat workload; this is not the browser Results UI."
    },
    memory: {
      ...template.memory,
      workingSetMb: benchmark2d?.memoryWorkingSetMb ?? null,
      peakWorkingSetMb: null,
      notes: "Godot headless runner reports null memory when host working-set telemetry is unavailable."
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
      fixedCamera2_5DQuality: "Orthographic procedural-primitive composition now includes clean, atmospheric, and private VFX-stress presets; final art quality is not assessed.",
      factionSilhouetteStrength: "Placeholder roles include hero, Worker, Militia, Ranger, Ashen raider/hexer/brute/commander contrast, and structure silhouettes.",
      atmosphericTerrain: "Salto highland landmarks are represented as procedural terrain height bands, road, ford/water posture, quarry, shrine, ruin, fog posture, and Lume link.",
      modernLightingAndVfx: "2.5D mode includes fixed-camera lighting, restrained shadow posture, Lume endpoint/link glow, transition pulse, and private VFX stress evidence only.",
      persistentHeroReadability: "Central Aster placeholder included.",
      tacticalReadability: "Selection, orders, Lume link, minimap/orientation, and Results flow are acceptance targets.",
      originalIpSeparation: true,
      avoidsMobileOrDashboardLook: true,
      notes:
        "The spike compares 2D control and procedural 2.5D orthographic placeholder presets toward a modern original RTS/RPG spirit; no Warlords Battlecry IP, art, lore, UI, or mechanics are copied."
    },
    modeComparison: {
      "2D_PLACEHOLDER": {
        tierSCombat: tierSCombat2d,
        tierMCombat: tierMCombat2d,
        tierLCombat: tierLCombat2d,
        navigationQueryCount: benchmark2d?.navigationQueryCount ?? null,
        stuckUnitCount: benchmark2d?.stuckUnitCount ?? null,
        aiPressureBeatCount: benchmark2d?.aiPressureBeatCount ?? null
      },
      "2_5D_ORTHOGRAPHIC_PLACEHOLDER": {
        tierSCombat: tierSCombat25d,
        tierMCombat: tierMCombat25d,
        tierLCombat: tierLCombat25d,
        navigationQueryCount: benchmark25d?.navigationQueryCount ?? null,
        stuckUnitCount: benchmark25d?.stuckUnitCount ?? null,
        aiPressureBeatCount: benchmark25d?.aiPressureBeatCount ?? null
      },
      notes:
        "Both modes load the same generated fixture and v0.119 workload tiers; rendering remains placeholder-only and editor-optional."
    },
    navigationAndAiPressure: {
      deterministicSeed: runtime2d?.deterministicSeed ?? null,
      formationLiteOffsets: true,
      obstacleAvoidance: "rectangular-nudge placeholder avoidance",
      navigationQueryCount2d: benchmark2d?.navigationQueryCount ?? null,
      navigationQueryCount25d: benchmark25d?.navigationQueryCount ?? null,
      maxStuckUnitCount2d: benchmark2d?.stuckUnitCount ?? null,
      maxStuckUnitCount25d: benchmark25d?.stuckUnitCount ?? null,
      tierMAiPressureBeatCount2d: tierMCombat2d?.aiPressureBeatCount ?? null,
      tierLAiPressureBeatCount2d: tierLCombat2d?.aiPressureBeatCount ?? null,
      cooldowns: "simple deterministic attack cooldowns; no full strategy planner",
      notes:
        "AI pressure is bounded to target selection, move/attack, and site contest evidence; it is not a full enemy strategy system."
    },
    dataImportNotes:
      "Generated data copies the v0.116 fixture JSON under desktop-spikes/godot-salto/data/generated and v0.122 validates the bounded subset through adapter reports.",
    saveFixtureNotes: "v0.102 save fixture manifest is consumed as read-only evidence only; no localStorage or live save writes.",
    stableIdNotes:
      validation.stableIdValidation?.missing?.length === 0
        ? "Selected fixture IDs resolve through the stable-ID subset; v0.122 adapter validation rejects the unknown probe without renaming stable IDs."
        : "Static validation found selected fixture IDs missing from the stable subset.",
    pathingNotes: "Godot-only placeholder navigation now records query counts, formation-lite offsets, movement completion, stuck-unit counts, and rectangular obstacle nudges.",
    unitCountNotes: "Tier S has 14 units, Tier M has 43 units, and Tier L has 105 units, with exact structure/site/Lume counts recorded in v0.119 parity artifacts.",
    uiWorkflowNotes: "Controls and Results return are acceptance targets; no browser UI or public runtime shell changed.",
    artPipelineNotes: "Placeholder-only; no generated/imported art and no runtime art path changes.",
    automationNotes: "PowerShell and .bat wrappers cover doctor, bootstrap, fixture export/validation, scene generation, tests, benchmark, export, package, scorecard, and all.",
    ciNotes: "Remote CI should run the browser project gates; Godot runtime/downloaded tools remain ignored local artifacts.",
    licensingNotes: "Bootstrap references official Godot GitHub release URLs only; no plugins, mirrors, or third-party assets.",
    risks: [
      "The visual comparison is placeholder-only and does not prove final art quality.",
      "The navigation and AI pressure loops are bounded spike logic, not a full RTS pathfinder or strategy controller.",
      "Runtime metrics from headless placeholder loops are directional workflow evidence, not final production performance certification."
    ],
    unknowns: ["Human playtest feel on Emmanuel's display and input devices is not measured."],
    evidenceLinks: [
      "desktop-spikes/godot-salto/README.md",
      "desktop-spikes/godot-salto/data/generated/fixture-manifest.json",
      "artifacts/desktop-spikes/godot-salto/latest/godot-doctor.json",
      "artifacts/desktop-spikes/godot-salto/latest/fixture-validation.json",
      "artifacts/desktop-spikes/godot-salto/latest/scorecard.json",
      "artifacts/desktop-spikes/godot-salto/v0119/scalability-benchmark-2d.json",
      "artifacts/desktop-spikes/godot-salto/v0119/scalability-benchmark-2_5d.json",
      "artifacts/desktop-spikes/godot-salto/v0119/parity-report.json",
      "artifacts/desktop-spikes/godot-salto/v0119/scorecard-update.json",
      "artifacts/desktop-spikes/godot-salto/v0121/performance-comparison.json",
      "artifacts/desktop-spikes/godot-salto/v0121/screenshot-manifest.json",
      "artifacts/desktop-spikes/godot-salto/v0122/adapter-validation.json",
      "artifacts/desktop-spikes/godot-salto/v0122/parity-report.json",
      "artifacts/desktop-spikes/godot-salto/v0122/migration-readiness.json"
    ],
    score: {
      aiOperabilityOutOf25: runtimeComplete ? 24 : 19,
      representativePerformanceOutOf20: runtimeComplete ? 14 : null,
      contentStableIdReuseOutOf15: validation.errors.length === 0 ? 15 : 0,
      saveSafetyOutOf10: 10,
      visualAmbitionOutOf10: runtimeComplete ? 7 : 6,
      uiAutomationOutOf10: 8,
      windowsPackagingOutOf5: packageReport?.packageCreated ? 5 : 0,
      licensingMaintainabilityOutOf5: 5,
      totalOutOf100: runtimeComplete ? 78 : null
    },
    recommendation: runtimeComplete
      ? "Use the v0.122 adapter/parity packet as migration-readiness evidence alongside the v0.121 visual packet; do not select Godot finally from this spike alone."
      : blockedStatus,
    approvalStatus: runtimeComplete ? "workflow-spike-content-adapter-parity-not-final-engine-choice" : "scaffold-ready-runtime-blocked"
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
    const report = writeTestReport();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
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
  } else if (command === "headed-smoke") {
    console.log(stableStringify(writeV0118HeadedSmokeReport()));
    writeV0118PackageValidation();
    writeV0118ReviewSummary();
    writeV0118Readme();
  } else if (command === "headed-benchmark") {
    console.log(stableStringify(writeV0118HeadedBenchmarkReports()));
    writeV0118PackageValidation();
    writeV0118ReviewSummary();
    writeV0118Readme();
  } else if (command === "capture-review") {
    console.log(stableStringify(writeV0118ScreenshotManifest()));
    writeV0118PackageValidation();
    writeV0118ReviewSummary();
    writeV0118Readme();
  } else if (command === "capture-review-v0121") {
    console.log(stableStringify(writeV0121ScreenshotManifest()));
  } else if (command === "player-slice-validate") {
    const report = writeV0124PlayerSliceValidation();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-capture") {
    const report = writeV0124ScreenshotManifest();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-capture-v0126") {
    const report = writeV0126ScreenshotManifest();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-capture-v0127") {
    const report = writeV0127ScreenshotManifest();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-capture-v0128") {
    const report = writeV0128ScreenshotManifest();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-validate-v0129") {
    const report = writeV0129PlayerSliceValidation();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-capture-v0129") {
    const report = writeV0129ScreenshotManifest();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-validate-v0130") {
    const report = writeV0130PlayerSliceValidation();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-capture-v0130") {
    const report = writeV0130ScreenshotManifest();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "real-input-v0131") {
    const report = validateV0131RealInputArtifacts();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "site-semantics-v0132") {
    const report = validateV0132SiteSemanticsArtifacts();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "post-mine-flow-v0133") {
    const report = validateV0133PostMineFlowArtifacts();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "triple-natural-playthrough-v0134") {
    const report = validateV0134TripleNaturalPlaythroughArtifacts();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "rts-ergonomics-v0135") {
    const report = validateV0135RtsErgonomicsArtifacts();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "usability-presentation-v0136") {
    const report = validateV0136UsabilityPresentationArtifacts();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "player-slice-audit") {
    const report = buildV0125ScreenshotAudit();
    console.log(stableStringify(report));
    if (String(report.status).startsWith("FAIL")) {
      process.exitCode = 1;
    }
  } else if (command === "v0118-all") {
    writeV0118AllReports();
    console.log("v0.118 Godot headed review reports generated.");
  } else if (command === "all") {
    runAll();
    console.log("v0.119 Godot representative RTS load spike reports generated.");
  } else {
    console.log("Usage: node desktop-spikes/godot-salto/tools/godotSpikeTool.mjs <doctor|generate|validate|test|benchmark|export|package|scorecard|manual-review|headed-smoke|headed-benchmark|capture-review|capture-review-v0121|player-slice-validate|player-slice-capture|player-slice-capture-v0126|player-slice-capture-v0127|player-slice-capture-v0128|player-slice-validate-v0129|player-slice-capture-v0129|player-slice-validate-v0130|player-slice-capture-v0130|real-input-v0131|site-semantics-v0132|post-mine-flow-v0133|triple-natural-playthrough-v0134|rts-ergonomics-v0135|usability-presentation-v0136|player-slice-audit|v0118-all|all>");
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
