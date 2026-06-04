import { createHash } from "node:crypto";
import { mkdir, mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";
import { tmpdir } from "node:os";
import { LUME_NETWORKS } from "../data/lumeNetworks";
import { CURRENT_SAVE_VERSION } from "../save/SaveDefaults";
import {
  createPortableContentExport,
  createStableIdManifest,
  readStableIdSnapshot,
  stableStringify,
  validatePortableContentExport,
  type PortableContentCategoryId,
  type PortableContentEntry,
  type PortableContentExport,
  type StableIdManifestEntry,
  type StableIdSnapshot
} from "../portable/PortableContentExport";
import {
  REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS,
  REPRESENTATIVE_BATTLE_CONTENT_PROFILE,
  REPRESENTATIVE_BATTLE_TIER_PROFILES,
  V0108_DESKTOP_ACCEPTANCE_PROFILE
} from "../playtest/RepresentativeBattleBenchmark";

export const DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION = 1;
export const DESKTOP_SPIKE_FIXTURE_CHECKPOINT = "v0.116";
export const DESKTOP_SPIKE_FIXTURE_GENERATED_AT = "deterministic-v0116";
export const DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR = "artifacts/desktop-spike-fixture/latest";
export const DESKTOP_SPIKE_SCORECARD_TEMPLATE_PATH = "docs/V0116_ENGINE_SPIKE_SCORECARD_TEMPLATE.json";

export const DESKTOP_SPIKE_FIXTURE_FILE_NAMES = [
  "README.md",
  "scene-fixture.json",
  "content-subset.json",
  "stable-id-subset.json",
  "save-fixture-index.json",
  "benchmark-contract.json",
  "expected-parity.json",
  "visual-placeholder-contract.json",
  "input-contract.json",
  "results-contract.json",
  "qa-checklist.md",
  "fixture-hashes.json"
] as const;

type FixtureFileName = (typeof DESKTOP_SPIKE_FIXTURE_FILE_NAMES)[number];
type SerializableRecord = Record<string, unknown>;

export interface DesktopSpikeFixturePayload {
  readme: string;
  sceneFixture: SerializableRecord;
  contentSubset: SerializableRecord;
  stableIdSubset: SerializableRecord;
  saveFixtureIndex: SerializableRecord;
  benchmarkContract: SerializableRecord;
  expectedParity: SerializableRecord;
  visualPlaceholderContract: SerializableRecord;
  inputContract: SerializableRecord;
  resultsContract: SerializableRecord;
  qaChecklist: string;
  sourceLinks: SerializableRecord;
}

export interface DesktopSpikeFixtureWriteResult {
  outputDir: string;
  files: Record<FixtureFileName, string>;
  hashes: DesktopSpikeFixtureHashes;
}

export interface DesktopSpikeFixtureHashes {
  schemaVersion: number;
  checkpoint: string;
  generatedAtUtc: string;
  algorithm: "sha256";
  fixtureHash: string;
  files: Record<Exclude<FixtureFileName, "fixture-hashes.json">, string>;
}

export interface DesktopSpikeFixtureValidationResult {
  ok: boolean;
  errors: string[];
  outputDir: string;
  fixtureHash?: string;
  deterministicFiles?: number;
}

const REQUIRED_SOURCE_LINKS = [
  "LLM_GAME_HANDOFF.md",
  "README.md",
  "ROADMAP.md",
  "CHANGELOG.md",
  "DEVELOPMENT_CHECKPOINT.md",
  "RELEASE_CHECKLIST.md",
  "docs/V091_CURRENT_ARCHITECTURE_REUSE_MATRIX.md",
  "docs/V091_DESKTOP_ENGINE_DECISION_CRITERIA.md",
  "docs/V091_DESKTOP_VERTICAL_SLICE_SCOPE.md",
  "docs/V091_STAGED_TRANSITION_EXPERIMENTS.md",
  "docs/V091_SAVE_CONTENT_AND_TEST_REUSE_PLAN.md",
  "docs/V0101_PORTABLE_CONTENT_EXPORT_CONTRACT.md",
  "docs/V0101_STABLE_ID_FREEZE_POLICY.md",
  "docs/V0102_SAVE_TRANSLATION_PROOF_REPORT.md",
  "docs/V0102_DESKTOP_SAVE_ENVELOPE_CONTRACT.md",
  "docs/V0107_SALTO_VERTICAL_SLICE_COMPOSITION_SPEC.md",
  "docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json",
  "docs/V0108_BENCHMARK_SCENARIO_MANIFEST.json",
  "docs/V0109_TRUSTED_BROWSER_BENCHMARK_PROTOCOL.md",
  "docs/V0109_ROOT_CAUSE_MATRIX_REPORT.md",
  "docs/V0110_BROWSER_PERFORMANCE_GATE.md",
  "docs/V0111_BROWSER_CONTROL_BASELINES.md",
  "docs/V0111_MACHINE_PRESSURE_CLASSIFICATION.md",
  "docs/V0112_IDLE_COST_MATRIX.md",
  "docs/V0113_SPATIAL_QUERY_PROFILE.md",
  "docs/V0114_RENDER_LIFECYCLE_AUDIT.md",
  "docs/V0115_BROWSER_PERFORMANCE_GATE.md",
  "src/game/portable/PortableContentExport.ts",
  "src/game/portable/stable-id-snapshot.json",
  "src/game/save/SaveTranslationContract.ts",
  "tests/fixtures/saves/v0102/manifest.json",
  "src/game/playtest/RepresentativeBattleBenchmark.ts",
  "src/game/data/lumeNetworks.ts",
  "src/game/art/visual-asset-registry.json",
  "tools/runtime-art-slots/validateRuntimeArtSlots.ts"
] as const;

const SELECTED_CONTENT_IDS: Partial<Record<PortableContentCategoryId, string[]>> = {
  factions: ["free_marches", "ashen_covenant"],
  resources: ["crowns", "stone", "iron", "aether"],
  heroClasses: ["warlord", "arcanist", "shepherd"],
  origins: ["exiled_noble"],
  abilities: ["rally_banner"],
  units: [
    REPRESENTATIVE_BATTLE_CONTENT_PROFILE.workerUnitId,
    ...REPRESENTATIVE_BATTLE_CONTENT_PROFILE.playerMilitaryUnitIds,
    ...REPRESENTATIVE_BATTLE_CONTENT_PROFILE.enemyUnitIds
  ],
  unitRoles: [
    REPRESENTATIVE_BATTLE_CONTENT_PROFILE.workerUnitId,
    ...REPRESENTATIVE_BATTLE_CONTENT_PROFILE.playerMilitaryUnitIds,
    ...REPRESENTATIVE_BATTLE_CONTENT_PROFILE.enemyUnitIds
  ],
  buildings: [...REPRESENTATIVE_BATTLE_CONTENT_PROFILE.buildingIds],
  maps: [REPRESENTATIVE_BATTLE_CONTENT_PROFILE.mapId],
  captureSites: [
    REPRESENTATIVE_BATTLE_CONTENT_PROFILE.mineEquivalentSiteId,
    REPRESENTATIVE_BATTLE_CONTENT_PROFILE.shrineEquivalentSiteId,
    "north_aether_spring"
  ],
  nodes: [REPRESENTATIVE_BATTLE_CONTENT_PROFILE.campaignNodeId],
  missionTypes: ["control"],
  rewards: ["broken_ford_rewards"],
  enemyPersonalities: ["hexfire_cult"],
  enemyHeroes: ["veyra_cinders"],
  enemyHeroAbilities: ["hexfire_bolt", "hold_the_line"],
  enemyDoctrines: ["raider", "hunter", "warband"],
  tacticalPlans: ["guarded_advance", "resource_push"],
  lumeNetworks: [REPRESENTATIVE_BATTLE_CONTENT_PROFILE.lumeNetworkId],
  retinueRuleReferences: ["retinue_rules"]
};

const SCORECARD_REQUIRED_FIELDS = [
  "schemaVersion",
  "checkpoint",
  "candidate",
  "engineVersion",
  "reviewer",
  "sourceCommit",
  "fixtureHash",
  "buildStatus",
  "packageStatus",
  "windowsPackagePath",
  "startupMs",
  "tierS",
  "tierM",
  "tierL",
  "inputLatency",
  "sceneLaunchLatency",
  "resultsTransitionLatency",
  "memory",
  "packageSize",
  "buildTime",
  "aiOperability",
  "visualAmbition",
  "dataImportNotes",
  "saveFixtureNotes",
  "stableIdNotes",
  "pathingNotes",
  "unitCountNotes",
  "uiWorkflowNotes",
  "artPipelineNotes",
  "automationNotes",
  "ciNotes",
  "licensingNotes",
  "risks",
  "unknowns",
  "evidenceLinks",
  "score",
  "recommendation",
  "approvalStatus"
] as const;

export async function createDesktopSpikeFixturePayload(projectRoot = process.cwd()): Promise<DesktopSpikeFixturePayload> {
  const contentExport = createPortableContentExport();
  const stableIdManifest = createStableIdManifest(contentExport);
  const stableIdSnapshot = await readStableIdSnapshot(join(projectRoot, "src/game/portable/stable-id-snapshot.json"));
  const saltoManifest = await readJson(join(projectRoot, "docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json"));
  const saveManifest = await readJson(join(projectRoot, "tests/fixtures/saves/v0102/manifest.json"));
  const gateResult = await readV0115GateResult(projectRoot);
  const sourceLinks = createSourceLinks();
  const linkedWard = linkedWardBenefit();
  const sceneFixture = createSceneFixture(linkedWard.damageTakenMultiplier, gateResult, sourceLinks);
  const contentSubset = createContentSubset(contentExport, sourceLinks);
  const stableIdSubset = createStableIdSubset(stableIdManifest, stableIdSnapshot, sourceLinks);
  const saveFixtureIndex = createSaveFixtureIndex(saveManifest, sourceLinks);
  const benchmarkContract = createBenchmarkContract(gateResult, sourceLinks);
  const expectedParity = createExpectedParity(linkedWard.damageTakenMultiplier, sourceLinks);
  const visualPlaceholderContract = createVisualPlaceholderContract(saltoManifest, sourceLinks);
  const inputContract = createInputContract(sourceLinks);
  const resultsContract = createResultsContract(sourceLinks);
  return {
    readme: renderReadme(gateResult),
    sceneFixture,
    contentSubset,
    stableIdSubset,
    saveFixtureIndex,
    benchmarkContract,
    expectedParity,
    visualPlaceholderContract,
    inputContract,
    resultsContract,
    qaChecklist: renderQaChecklist(),
    sourceLinks
  };
}

export async function writeDesktopSpikeFixtureExport(
  outputDir = DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR,
  projectRoot = process.cwd()
): Promise<DesktopSpikeFixtureWriteResult> {
  const payload = await createDesktopSpikeFixturePayload(projectRoot);
  const files = createDesktopSpikeFixtureFiles(payload);
  await mkdir(outputDir, { recursive: true });
  await Promise.all(Object.entries(files).map(([fileName, contents]) => writeFile(join(outputDir, fileName), contents, "utf8")));
  return {
    outputDir,
    files,
    hashes: JSON.parse(files["fixture-hashes.json"]) as DesktopSpikeFixtureHashes
  };
}

export async function validateDesktopSpikeFixtureArtifacts(options: {
  outputDir?: string;
  projectRoot?: string;
  scorecardPath?: string;
} = {}): Promise<DesktopSpikeFixtureValidationResult> {
  const outputDir = options.outputDir ?? DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR;
  const projectRoot = options.projectRoot ?? process.cwd();
  const errors: string[] = [];
  const writeResult = await writeDesktopSpikeFixtureExport(outputDir, projectRoot);
  const payload = await createDesktopSpikeFixturePayload(projectRoot);
  errors.push(...validateDesktopSpikeFixturePayload(payload));
  errors.push(...(await validateRepositorySpikeBoundaries(projectRoot)));
  errors.push(...validateFixtureHashes(writeResult.files));
  const scorecardPath = options.scorecardPath ?? join(projectRoot, DESKTOP_SPIKE_SCORECARD_TEMPLATE_PATH);
  errors.push(...(await validateScorecardTemplateFile(scorecardPath)));

  const secondRoot = await mkdtemp(join(tmpdir(), "ascendant-realms-desktop-spike-fixture-"));
  const secondDir = join(secondRoot, "latest");
  try {
    const second = await writeDesktopSpikeFixtureExport(secondDir, projectRoot);
    await Promise.all(
      DESKTOP_SPIKE_FIXTURE_FILE_NAMES.map(async (fileName) => {
        const left = await readFile(join(outputDir, fileName), "utf8");
        const right = await readFile(join(second.outputDir, fileName), "utf8");
        if (left !== right) {
          errors.push(`Desktop spike fixture export is nondeterministic for ${fileName}.`);
        }
      })
    );
  } finally {
    await rm(secondRoot, { force: true, recursive: true });
  }

  return {
    ok: errors.length === 0,
    errors,
    outputDir,
    fixtureHash: writeResult.hashes.fixtureHash,
    deterministicFiles: DESKTOP_SPIKE_FIXTURE_FILE_NAMES.length
  };
}

export function createDesktopSpikeFixtureFiles(payload: DesktopSpikeFixturePayload): Record<FixtureFileName, string> {
  const withoutHashes: Record<Exclude<FixtureFileName, "fixture-hashes.json">, string> = {
    "README.md": payload.readme,
    "scene-fixture.json": stableStringify(payload.sceneFixture),
    "content-subset.json": stableStringify(payload.contentSubset),
    "stable-id-subset.json": stableStringify(payload.stableIdSubset),
    "save-fixture-index.json": stableStringify(payload.saveFixtureIndex),
    "benchmark-contract.json": stableStringify(payload.benchmarkContract),
    "expected-parity.json": stableStringify(payload.expectedParity),
    "visual-placeholder-contract.json": stableStringify(payload.visualPlaceholderContract),
    "input-contract.json": stableStringify(payload.inputContract),
    "results-contract.json": stableStringify(payload.resultsContract),
    "qa-checklist.md": payload.qaChecklist
  };
  const fileHashes = Object.fromEntries(
    Object.entries(withoutHashes).map(([fileName, contents]) => [fileName, hashText(contents)])
  ) as DesktopSpikeFixtureHashes["files"];
  const hashes: DesktopSpikeFixtureHashes = {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    algorithm: "sha256",
    fixtureHash: hashText(stableStringify(fileHashes)),
    files: fileHashes
  };
  return {
    ...withoutHashes,
    "fixture-hashes.json": stableStringify(hashes)
  };
}

export function validateDesktopSpikeFixturePayload(payload: DesktopSpikeFixturePayload): string[] {
  const errors: string[] = [];
  const contentExport = createPortableContentExport();
  const manifest = createStableIdManifest(contentExport);
  errors.push(...validatePortableContentExport(contentExport));
  validateSourceLinks(payload.sourceLinks, errors);
  validateSceneFixture(payload.sceneFixture, contentExport, errors);
  validateContentSubset(payload.contentSubset, contentExport, errors);
  validateStableIdSubset(payload.stableIdSubset, manifest.entries, errors);
  validateSaveFixtureIndex(payload.saveFixtureIndex, errors);
  validateBenchmarkContract(payload.benchmarkContract, errors);
  validateExpectedParity(payload.expectedParity, errors);
  validateVisualPlaceholderContract(payload.visualPlaceholderContract, errors);
  validateInputContract(payload.inputContract, errors);
  validateResultsContract(payload.resultsContract, errors);
  return errors;
}

export function validateDesktopSpikeScorecardTemplate(scorecard: unknown): string[] {
  const errors: string[] = [];
  if (!scorecard || typeof scorecard !== "object") {
    return ["Desktop spike scorecard template is not an object."];
  }
  const record = scorecard as Record<string, unknown>;
  SCORECARD_REQUIRED_FIELDS.forEach((field) => {
    if (!(field in record)) {
      errors.push(`Desktop spike scorecard template is missing ${field}.`);
    }
  });
  if (record.schemaVersion !== DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION) {
    errors.push(`Desktop spike scorecard schemaVersion must be ${DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION}.`);
  }
  if (record.checkpoint !== DESKTOP_SPIKE_FIXTURE_CHECKPOINT) {
    errors.push(`Desktop spike scorecard checkpoint must be ${DESKTOP_SPIKE_FIXTURE_CHECKPOINT}.`);
  }
  if (record.approvalStatus !== "template-not-approved") {
    errors.push("Desktop spike scorecard template must remain template-not-approved.");
  }
  if (record.candidate !== "unselected") {
    errors.push("Desktop spike scorecard template must not select an engine candidate.");
  }
  const aiOperability = record.aiOperability as Record<string, unknown> | undefined;
  if (!aiOperability) {
    errors.push("Desktop spike scorecard template is missing aiOperability.");
  } else {
    [
      "scoreOutOf25",
      "freshCheckoutSetupScripted",
      "oneCommandValidation",
      "sceneCreationScriptableOrTextEditable",
      "manifestDrivenContentImport",
      "editorOptionalRoutineWorkflow",
      "assetRegistrationWithoutManualDragDrop",
      "cliBuildExportBenchmarkPackage",
      "codexCanModifyValidateBuildPackage",
      "unavoidableManualEditorSteps",
      "debuggableWithoutRoutineEditorUse"
    ].forEach((field) => {
      if (!(field in aiOperability)) {
        errors.push(`Desktop spike scorecard aiOperability is missing ${field}.`);
      }
    });
  }
  const visualAmbition = record.visualAmbition as Record<string, unknown> | undefined;
  if (!visualAmbition) {
    errors.push("Desktop spike scorecard template is missing visualAmbition.");
  } else {
    [
      "scoreOutOf10",
      "topDown2DQuality",
      "fixedCamera2_5DQuality",
      "factionSilhouetteStrength",
      "atmosphericTerrain",
      "modernLightingAndVfx",
      "persistentHeroReadability",
      "tacticalReadability",
      "originalIpSeparation",
      "avoidsMobileOrDashboardLook"
    ].forEach((field) => {
      if (!(field in visualAmbition)) {
        errors.push(`Desktop spike scorecard visualAmbition is missing ${field}.`);
      }
    });
  }
  ["tierS", "tierM", "tierL"].forEach((tierField) => {
    const tier = record[tierField];
    if (!tier || typeof tier !== "object") {
      errors.push(`Desktop spike scorecard ${tierField} must be an object.`);
      return;
    }
    ["fpsAverage", "fpsOnePercentLow", "frameTimeP50Ms", "frameTimeP95Ms", "frameTimeP99Ms", "frameTimeMaxMs"].forEach(
      (metric) => {
        if (!(metric in (tier as Record<string, unknown>))) {
          errors.push(`Desktop spike scorecard ${tierField} is missing ${metric}.`);
        }
      }
    );
  });
  return errors;
}

export async function validateRepositorySpikeBoundaries(projectRoot = process.cwd()): Promise<string[]> {
  const errors: string[] = [];
  const packageJson = await readJson(join(projectRoot, "package.json"));
  const dependencies = {
    ...((packageJson as { dependencies?: Record<string, string> }).dependencies ?? {}),
    ...((packageJson as { devDependencies?: Record<string, string> }).devDependencies ?? {})
  };
  const forbiddenDependencies = [
    "electron",
    "@electron-forge/cli",
    "electron-builder",
    "@tauri-apps/api",
    "three",
    "@react-three/fiber",
    "unity",
    "unreal",
    "godot"
  ];
  forbiddenDependencies.forEach((dependency) => {
    if (dependency in dependencies) {
      errors.push(`Forbidden desktop engine or wrapper dependency is present: ${dependency}.`);
    }
  });

  const rootFiles = await readdir(projectRoot);
  const forbiddenRootFiles = ["project.godot", "Cargo.toml", "electron-builder.json"];
  forbiddenRootFiles.forEach((fileName) => {
    if (rootFiles.includes(fileName)) {
      errors.push(`Forbidden desktop engine or wrapper project file is present: ${fileName}.`);
    }
  });

  const docsFiles = await readdir(join(projectRoot, "docs"));
  if (docsFiles.some((fileName) => fileName.startsWith("V0121_GODOT_") || fileName.startsWith("V0121_EMMANUEL_GODOT_"))) {
    errors.push("v0.121 Godot follow-up appears to have been started; docs/V0121_GODOT_* is present.");
  }
  return errors;
}

async function validateScorecardTemplateFile(path: string): Promise<string[]> {
  try {
    return validateDesktopSpikeScorecardTemplate(await readJson(path));
  } catch (error) {
    return [`Desktop spike scorecard template could not be read: ${String(error)}.`];
  }
}

function createSceneFixture(linkedWardDamageTakenMultiplier: number, gateResult: string, sourceLinks: SerializableRecord): SerializableRecord {
  const profile = REPRESENTATIVE_BATTLE_CONTENT_PROFILE;
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    purpose: "Engine-neutral Salto representative vertical-slice fixture for future desktop spike review.",
    authority: "derived-from-existing-typescript-source-and-existing-docs",
    engineNeutral: true,
    selectedEngine: null,
    engineProjectCreated: false,
    desktopWrapperCreated: false,
    runtimeBehaviorChanged: false,
    gameplayChanged: false,
    saveSchemaChanged: false,
    stableIdsChanged: false,
    runtimeArtIntegrated: false,
    browserPerformanceGateResult: gateResult,
    sourceLinks,
    map: {
      mapId: profile.mapId,
      campaignNodeId: profile.campaignNodeId,
      region: "Salto-inspired highland foothold",
      terrainReadabilityTargets: ["road", "ford", "quarry", "ruin", "resource-site ring", "UI-safe negative space"]
    },
    player: {
      factionId: "free_marches",
      hero: { name: profile.hero, placeholderOnly: true },
      worker: { unitId: profile.workerUnitId, count: 1 },
      units: profile.playerMilitaryUnitIds.map((unitId) => ({ unitId, representativeRole: unitId }))
    },
    enemy: {
      factionId: profile.enemyFactionId,
      units: profile.enemyUnitIds.map((unitId) => ({ unitId, representativeRole: unitId })),
      pressureBeat: "readable Ashen approach warning"
    },
    structures: profile.buildingIds.map((buildingId) => ({
      buildingId,
      posture: buildingId.startsWith("enemy_") ? "enemy-placeholder-structure" : "player-placeholder-structure"
    })),
    sites: [
      {
        siteId: profile.mineEquivalentSiteId,
        role: "mine-equivalent-existing-capture-site",
        newBuildingIdAdded: false
      },
      {
        siteId: profile.shrineEquivalentSiteId,
        role: "shrine-equivalent-existing-capture-site",
        newBuildingIdAdded: false
      }
    ],
    lume: {
      networkId: profile.lumeNetworkId,
      linkId: profile.lumeLinkId,
      benefitId: "linked_ward",
      linkedWardDamageTakenMultiplier,
      mustRemainExact: 0.92,
      battleLocalOnly: true,
      saveMutationAllowed: false
    },
    requiredSurfaces: ["battlefield", "HUD", "minimap", "campaign map frame", "Results frame"],
    prohibitedOutputs: ["engine project", "desktop wrapper", "runtime art import", "save migration", "stable ID rename", "v0.117 work"]
  };
}

function createContentSubset(contentExport: PortableContentExport, sourceLinks: SerializableRecord): SerializableRecord {
  const categories = Object.fromEntries(
    Object.entries(SELECTED_CONTENT_IDS).map(([category, ids]) => [
      category,
      selectEntries(contentExport, category as PortableContentCategoryId, ids ?? [])
    ])
  );
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    authority: "typescript-source-via-portable-content-export",
    fullExportCheckpoint: contentExport.checkpoint,
    runtimeBehavior: "unchanged-downstream-export",
    sourceLinks,
    categories
  };
}

function createStableIdSubset(
  stableIdManifest: { entries: StableIdManifestEntry[] },
  stableIdSnapshot: StableIdSnapshot,
  sourceLinks: SerializableRecord
): SerializableRecord {
  const selectedIds = selectedIdPairs();
  const entries = stableIdManifest.entries.filter((entry) => selectedIds.has(`${entry.category}:${entry.id}`));
  const snapshotCategories = Object.fromEntries(
    Object.entries(SELECTED_CONTENT_IDS).map(([category, ids]) => [
      category,
      (ids ?? []).filter((id) => stableIdSnapshot.categories[category]?.includes(id))
    ])
  );
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    authority: "src/game/portable/stable-id-snapshot.json",
    stableIdPolicyCheckpoint: stableIdSnapshot.checkpoint,
    policy: stableIdSnapshot.policy,
    sourceLinks,
    categories: snapshotCategories,
    manifestEntries: entries
  };
}

function createSaveFixtureIndex(saveManifest: unknown, sourceLinks: SerializableRecord): SerializableRecord {
  const fixtures = ((saveManifest as { fixtures?: SerializableRecord[] }).fixtures ?? []).map((fixture) => ({
    id: fixture.id,
    filename: fixture.filename,
    expectedStatus: fixture.expectedStatus,
    expectedSaveVersion: fixture.expectedSaveVersion,
    expectedUnsafeFieldCount: fixture.expectedUnsafeFieldCount ?? 0,
    expectedUnknownContentIdCount: fixture.expectedUnknownContentIdCount ?? 0,
    expectedRejectionReason: fixture.expectedRejectionReason ?? null,
    purpose: fixture.purpose,
    readOnly: true,
    rawSaveIncludedInDesktopSpikeFixture: false
  }));
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    authority: "tests/fixtures/saves/v0102/manifest.json",
    currentSaveVersion: CURRENT_SAVE_VERSION,
    sourceLinks,
    fixtureRoot: "tests/fixtures/saves/v0102/",
    counts: {
      total: fixtures.length,
      translated: fixtures.filter((fixture) => fixture.expectedStatus === "translated").length,
      translatedWithQuarantine: fixtures.filter((fixture) => fixture.expectedStatus === "translated_with_quarantine").length,
      rejected: fixtures.filter((fixture) => fixture.expectedStatus === "rejected").length
    },
    fixtures
  };
}

function createBenchmarkContract(gateResult: string, sourceLinks: SerializableRecord): SerializableRecord {
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    authority: "v0.108-representative-battle-profile-plus-v0.109-v0.115-evidence",
    browserPerformanceGateResult: gateResult,
    engineNeutral: true,
    finalHardwareCertification: false,
    selectedEngine: null,
    sourceLinks,
    acceptanceProfile: V0108_DESKTOP_ACCEPTANCE_PROFILE,
    contentProfile: REPRESENTATIVE_BATTLE_CONTENT_PROFILE,
    tiers: REPRESENTATIVE_BATTLE_TIER_PROFILES,
    scenarios: REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS,
    requiredMetrics: [
      "fpsAverage",
      "fpsOnePercentLow",
      "frameTimeP50Ms",
      "frameTimeP95Ms",
      "frameTimeP99Ms",
      "frameTimeMaxMs",
      "longTaskCount",
      "longTaskTotalMs",
      "inputLatencyMs",
      "battleLaunchLatencyMs",
      "representativeActionLatencyMs",
      "resultsTransitionLatencyMs",
      "startupMs",
      "memoryWorkingSetMb",
      "packageSizeMb",
      "buildTimeSeconds"
    ],
    aiOperabilityCriteria: [
      "fresh checkout setup is reproducible from repository files and scripts",
      "scene creation and configuration are scriptable or text-editable wherever practical",
      "content import is manifest-driven and automatically validated",
      "engine editor is optional for Emmanuel during routine work",
      "builds, exports, tests, benchmarks, and Windows packaging run through simple scripts or CLI commands",
      "routine asset registration does not require manual editor drag-and-drop",
      "Codex can create, modify, validate, build, export, and package the Salto slice with minimal human interaction",
      "unavoidable manual editor steps are explicitly identified and minimized"
    ],
    visualAmbitionCriteria: [
      "modern top-down RTS/RPG presentation",
      "polished 2D versus 2.5D fixed-camera comparison",
      "strong Barrosan and Ashen faction silhouettes",
      "atmospheric Salto terrain",
      "modern lighting and VFX",
      "central persistent hero readability",
      "tactical readability",
      "original IP, lore, assets, UI, mechanics, and visual identity",
      "no generic mobile-game or developer-dashboard appearance"
    ],
    decisionRules: {
      electronControl: "Use only as a packaging control if explicitly approved later; it is not a cure for the current browser battle-loop bottleneck.",
      godotUnityUnreal: "Compare only with this same fixture and scorecard in future spikes; v0.116 does not choose an engine.",
      browserPrototype: "Remain source of truth for current behavior and content until a future explicit migration decision."
    }
  };
}

function createExpectedParity(linkedWardDamageTakenMultiplier: number, sourceLinks: SerializableRecord): SerializableRecord {
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    sourceLinks,
    mustMatch: {
      stableIds: "Every selected fixture id must resolve through the v0.101 stable-id snapshot.",
      unknownIds: "Unknown IDs must be rejected or quarantined by the receiving spike; do not silently remap.",
      saveFixtures: "Use the v0.102 manifest as read-only translation evidence; do not mutate localStorage or live saves.",
      gameplay: "No balance, AI, pathing, damage, reward, result, campaign, Retinue, relic, or Lume behavior changes.",
      linkedWardDamageTakenMultiplier,
      visualArt: "Use placeholders only; runtime art remains fallback-owned and not integrated.",
      sceneFlow: ["launch representative battle", "issue basic movement/attack/control input", "observe Lume link", "transition to Results", "return to shell"]
    },
    mustNotCreate: ["engine project", "desktop wrapper", "new engine dependency", "new stable ID", "save migration", "runtime art path", "v0.117 document"]
  };
}

function createVisualPlaceholderContract(saltoManifest: unknown, sourceLinks: SerializableRecord): SerializableRecord {
  const manifest = saltoManifest as {
    status?: string;
    generatedAssetsIncluded?: boolean;
    runtimeIntegrationApproved?: boolean;
    generatedImagePaths?: unknown[];
    assets?: SerializableRecord[];
    qaScenarios?: SerializableRecord[];
  };
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    sourceLinks,
    status: "placeholder-only-reference-boundary",
    sourceManifestStatus: manifest.status,
    generatedAssetsIncluded: manifest.generatedAssetsIncluded ?? false,
    runtimeIntegrationApproved: manifest.runtimeIntegrationApproved ?? false,
    generatedImagePaths: manifest.generatedImagePaths ?? [],
    runtimeArtIntegrated: false,
    fallbackOwnershipRequired: true,
    qaScenarios: manifest.qaScenarios ?? [],
    assets: (manifest.assets ?? []).map((asset) => ({
      assetId: asset.assetId,
      category: asset.category,
      runtimeSlotIds: asset.runtimeSlotIds,
      runtimePosture: asset.runtimePosture,
      status: asset.status,
      fallbackBehavior: asset.fallbackBehavior,
      visualQaScenarioId: asset.visualQaScenarioId
    }))
  };
}

function createInputContract(sourceLinks: SerializableRecord): SerializableRecord {
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    sourceLinks,
    posture: "representative-rts-control-contract-not-runtime-input-change",
    requiredFlows: [
      "select hero or military unit",
      "move to readable ground",
      "focus mine-equivalent capture site",
      "focus shrine-equivalent capture site",
      "read Lume link state",
      "complete no-save Results transition"
    ],
    requiredSignals: [
      "selection feedback",
      "movement command feedback",
      "attack/control command feedback",
      "minimap remains readable",
      "HUD remains readable",
      "Results return is measurable"
    ],
    prohibitedChanges: ["new keybindings", "new command semantics", "automation-only force click fallback", "runtime input refactor"]
  };
}

function createResultsContract(sourceLinks: SerializableRecord): SerializableRecord {
  return {
    schemaVersion: DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION,
    checkpoint: DESKTOP_SPIKE_FIXTURE_CHECKPOINT,
    generatedAtUtc: DESKTOP_SPIKE_FIXTURE_GENERATED_AT,
    sourceLinks,
    posture: "no-save-results-parity-contract",
    requiredFields: [
      "outcome",
      "objective summary",
      "no-save marker",
      "Lume summary",
      "performance scorecard link",
      "return action"
    ],
    saveMutationAllowed: false,
    rewardMutationAllowed: false,
    localStorageMutationAllowed: false,
    evidenceRequired: ["resultsTransitionLatencyMs", "readable outcome state", "return-to-shell proof"]
  };
}

function renderReadme(gateResult: string): string {
  return [
    "# v0.116 Desktop Spike Fixture",
    "",
    "This folder is generated by `npm run export:desktop-spike-fixture`.",
    "",
    `Checkpoint: ${DESKTOP_SPIKE_FIXTURE_CHECKPOINT}`,
    `Generated: ${DESKTOP_SPIKE_FIXTURE_GENERATED_AT}`,
    `Browser performance gate carried forward from v0.115: ${gateResult}`,
    "",
    "Boundary:",
    "- Engine-neutral fixture only.",
    "- No engine is selected.",
    "- No desktop engine project, desktop wrapper, or engine dependency is created.",
    "- No runtime gameplay, save, stable-ID, network, or art integration changes are authorized.",
    "- `linked_ward` remains exactly `0.92`.",
    "",
    "Files:",
    "- `scene-fixture.json` defines the Salto-inspired representative scene contract.",
    "- `content-subset.json` and `stable-id-subset.json` derive selected IDs from the existing portable-content export.",
    "- `save-fixture-index.json` points at the existing v0.102 read-only save fixtures.",
    "- `benchmark-contract.json` carries the representative Tier S/M/L benchmark shape and required metrics.",
    "- `expected-parity.json`, `input-contract.json`, and `results-contract.json` define future spike parity checks.",
    "- `visual-placeholder-contract.json` preserves the v0.107 reference-only art boundary.",
    "- `fixture-hashes.json` records deterministic SHA-256 hashes.",
    ""
  ].join("\n");
}

function renderQaChecklist(): string {
  return [
    "# v0.116 Desktop Spike Fixture QA Checklist",
    "",
    "- Confirm the candidate spike uses this fixture without selecting an engine during v0.116.",
    "- Confirm every content ID resolves through `content-subset.json` and `stable-id-subset.json`.",
    "- Confirm unknown IDs are rejected or quarantined, not remapped silently.",
    "- Confirm save fixtures are read-only and no localStorage or live save mutation occurs.",
    "- Confirm Tier S, Tier M, and Tier L metrics are reported with p50, p95, p99, max, 1% low, long tasks, and latency fields.",
    "- Confirm `linked_ward` remains exactly `0.92`.",
    "- Confirm visual assets remain placeholders and no runtime art path is introduced.",
    "- Confirm no engine project, wrapper, or dependency has been added.",
    "- Confirm no v0.117 files exist before closing v0.116.",
    ""
  ].join("\n");
}

function selectEntries(
  contentExport: PortableContentExport,
  category: PortableContentCategoryId,
  ids: readonly string[]
): PortableContentEntry[] {
  const entries = contentExport.categories[category];
  return ids.map((id) => {
    const entry = entries.find((candidate) => candidate.id === id);
    if (!entry) {
      throw new Error(`Desktop spike fixture selected unknown ${category} id ${id}.`);
    }
    return entry;
  });
}

function selectedIdPairs(): Set<string> {
  return new Set(
    Object.entries(SELECTED_CONTENT_IDS).flatMap(([category, ids]) => (ids ?? []).map((id) => `${category}:${id}`))
  );
}

function linkedWardBenefit(): { damageTakenMultiplier: number } {
  const network = LUME_NETWORKS.find((candidate) => candidate.id === REPRESENTATIVE_BATTLE_CONTENT_PROFILE.lumeNetworkId);
  if (!network || network.benefit.id !== "linked_ward") {
    throw new Error("Desktop spike fixture could not resolve linked_ward.");
  }
  return { damageTakenMultiplier: network.benefit.damageTakenMultiplier };
}

async function readV0115GateResult(projectRoot: string): Promise<string> {
  const gate = await readFile(join(projectRoot, "docs/V0115_BROWSER_PERFORMANCE_GATE.md"), "utf8");
  const match = gate.match(/^## Result:\s+([A-Z]+)$/mu);
  return match?.[1] ?? "UNKNOWN";
}

function createSourceLinks(): SerializableRecord {
  return {
    required: [...REQUIRED_SOURCE_LINKS],
    generatedDocs: [
      "docs/V0116_ARCHITECTURE_DECISION_RECORD.md",
      "docs/V0116_ENGINE_CANDIDATE_MATRIX.md",
      "docs/V0116_RECOMMENDED_ENGINE_SPIKE_ORDER.md",
      "docs/V0116_DESKTOP_SPIKE_ACCEPTANCE_CONTRACT.md",
      "docs/V0116_DESKTOP_SPIKE_FIXTURE_EXPORT_SPEC.md",
      "docs/V0116_ENGINE_SPIKE_SCORECARD_TEMPLATE.json",
      "docs/V0116_EMMANUEL_ARCHITECTURE_REVIEW_PACKET.md",
      "docs/V0116_REFERENCE_ART_CONTINUATION_BOUNDARY.md",
      "docs/V0116_IMPLEMENTATION_REPORT.md"
    ],
    generatedArtifactRoot: DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR
  };
}

function validateSourceLinks(sourceLinks: SerializableRecord, errors: string[]): void {
  const required = new Set((sourceLinks.required as string[]) ?? []);
  REQUIRED_SOURCE_LINKS.forEach((path) => {
    if (!required.has(path)) {
      errors.push(`Desktop spike fixture source links are missing ${path}.`);
    }
  });
}

function validateSceneFixture(sceneFixture: SerializableRecord, contentExport: PortableContentExport, errors: string[]): void {
  expectEqual(sceneFixture.schemaVersion, DESKTOP_SPIKE_FIXTURE_SCHEMA_VERSION, "scene fixture schemaVersion", errors);
  expectEqual(sceneFixture.checkpoint, DESKTOP_SPIKE_FIXTURE_CHECKPOINT, "scene fixture checkpoint", errors);
  expectEqual(sceneFixture.engineNeutral, true, "scene fixture engineNeutral", errors);
  expectEqual(sceneFixture.selectedEngine, null, "scene fixture selectedEngine", errors);
  [
    "engineProjectCreated",
    "desktopWrapperCreated",
    "runtimeBehaviorChanged",
    "gameplayChanged",
    "saveSchemaChanged",
    "stableIdsChanged",
    "runtimeArtIntegrated"
  ].forEach((field) => expectEqual(sceneFixture[field], false, `scene fixture ${field}`, errors));
  expectEqual(sceneFixture.browserPerformanceGateResult, "RED", "scene fixture browserPerformanceGateResult", errors);
  const lume = sceneFixture.lume as SerializableRecord;
  expectEqual(lume.linkedWardDamageTakenMultiplier, 0.92, "scene fixture linked_ward damageTakenMultiplier", errors);
  collectSceneIds(sceneFixture).forEach(({ category, id, label }) => {
    if (!contentExport.categories[category].some((entry) => entry.id === id)) {
      errors.push(`Desktop spike fixture ${label} references unknown ${category} id ${id}.`);
    }
  });
}

function collectSceneIds(sceneFixture: SerializableRecord): { category: PortableContentCategoryId; id: string; label: string }[] {
  const player = sceneFixture.player as SerializableRecord;
  const enemy = sceneFixture.enemy as SerializableRecord;
  const map = sceneFixture.map as SerializableRecord;
  const lume = sceneFixture.lume as SerializableRecord;
  return [
    { category: "factions", id: String(player.factionId), label: "player faction" },
    { category: "factions", id: String(enemy.factionId), label: "enemy faction" },
    { category: "maps", id: String(map.mapId), label: "map" },
    { category: "nodes", id: String(map.campaignNodeId), label: "campaign node" },
    { category: "units", id: String((player.worker as SerializableRecord).unitId), label: "worker" },
    ...((player.units as SerializableRecord[]) ?? []).map((unit, index) => ({
      category: "units" as const,
      id: String(unit.unitId),
      label: `player unit ${index}`
    })),
    ...((enemy.units as SerializableRecord[]) ?? []).map((unit, index) => ({
      category: "units" as const,
      id: String(unit.unitId),
      label: `enemy unit ${index}`
    })),
    ...((sceneFixture.structures as SerializableRecord[]) ?? []).map((structure, index) => ({
      category: "buildings" as const,
      id: String(structure.buildingId),
      label: `structure ${index}`
    })),
    ...((sceneFixture.sites as SerializableRecord[]) ?? []).map((site, index) => ({
      category: "captureSites" as const,
      id: String(site.siteId),
      label: `site ${index}`
    })),
    { category: "lumeNetworks", id: String(lume.networkId), label: "Lume network" }
  ];
}

function validateContentSubset(contentSubset: SerializableRecord, contentExport: PortableContentExport, errors: string[]): void {
  expectEqual(contentSubset.fullExportCheckpoint, contentExport.checkpoint, "content subset fullExportCheckpoint", errors);
  const categories = contentSubset.categories as Record<string, PortableContentEntry[]>;
  Object.entries(SELECTED_CONTENT_IDS).forEach(([category, ids]) => {
    const actualIds = (categories[category] ?? []).map((entry) => entry.id);
    if (actualIds.join("\n") !== (ids ?? []).join("\n")) {
      errors.push(`Desktop spike fixture content subset ${category} ids do not match the selected fixture ids.`);
    }
  });
}

function validateStableIdSubset(
  stableIdSubset: SerializableRecord,
  manifestEntries: StableIdManifestEntry[],
  errors: string[]
): void {
  expectEqual(stableIdSubset.policy, "stable-id-freeze", "stable id subset policy", errors);
  const selected = selectedIdPairs();
  const subsetEntries = (stableIdSubset.manifestEntries as StableIdManifestEntry[]) ?? [];
  subsetEntries.forEach((entry) => {
    if (!selected.has(`${entry.category}:${entry.id}`)) {
      errors.push(`Desktop spike stable-id subset includes unexpected ${entry.category}:${entry.id}.`);
    }
  });
  selected.forEach((pair) => {
    const [category, id] = pair.split(":");
    if (!manifestEntries.some((entry) => entry.category === category && entry.id === id)) {
      errors.push(`Desktop spike stable-id subset is missing ${pair}.`);
    }
  });
}

function validateSaveFixtureIndex(saveFixtureIndex: SerializableRecord, errors: string[]): void {
  expectEqual(saveFixtureIndex.currentSaveVersion, CURRENT_SAVE_VERSION, "save fixture currentSaveVersion", errors);
  const counts = saveFixtureIndex.counts as SerializableRecord;
  expectEqual(counts.total, 16, "save fixture total count", errors);
  expectEqual(counts.translated, 11, "save fixture translated count", errors);
  expectEqual(counts.translatedWithQuarantine, 2, "save fixture quarantine count", errors);
  expectEqual(counts.rejected, 3, "save fixture rejected count", errors);
  ((saveFixtureIndex.fixtures as SerializableRecord[]) ?? []).forEach((fixture) => {
    expectEqual(fixture.readOnly, true, `save fixture ${String(fixture.id)} readOnly`, errors);
    expectEqual(
      fixture.rawSaveIncludedInDesktopSpikeFixture,
      false,
      `save fixture ${String(fixture.id)} rawSaveIncludedInDesktopSpikeFixture`,
      errors
    );
  });
}

function validateBenchmarkContract(benchmarkContract: SerializableRecord, errors: string[]): void {
  expectEqual(benchmarkContract.browserPerformanceGateResult, "RED", "benchmark contract browserPerformanceGateResult", errors);
  expectEqual(benchmarkContract.selectedEngine, null, "benchmark contract selectedEngine", errors);
  const tiers = benchmarkContract.tiers as Record<string, unknown>;
  ["S", "M", "L"].forEach((tier) => {
    if (!(tier in tiers)) {
      errors.push(`Desktop spike benchmark contract missing Tier ${tier}.`);
    }
  });
  const requiredMetrics = new Set((benchmarkContract.requiredMetrics as string[]) ?? []);
  [
    "fpsAverage",
    "fpsOnePercentLow",
    "frameTimeP50Ms",
    "frameTimeP95Ms",
    "frameTimeP99Ms",
    "frameTimeMaxMs",
    "inputLatencyMs",
    "resultsTransitionLatencyMs",
    "startupMs",
    "packageSizeMb"
  ].forEach((metric) => {
    if (!requiredMetrics.has(metric)) {
      errors.push(`Desktop spike benchmark contract missing metric ${metric}.`);
    }
  });
}

function validateExpectedParity(expectedParity: SerializableRecord, errors: string[]): void {
  const mustMatch = expectedParity.mustMatch as SerializableRecord;
  expectEqual(mustMatch.linkedWardDamageTakenMultiplier, 0.92, "expected parity linked_ward damageTakenMultiplier", errors);
  const mustNotCreate = new Set((expectedParity.mustNotCreate as string[]) ?? []);
  ["engine project", "desktop wrapper", "new engine dependency", "save migration", "runtime art path", "v0.117 document"].forEach(
    (item) => {
      if (!mustNotCreate.has(item)) {
        errors.push(`Desktop spike expected parity missing prohibition: ${item}.`);
      }
    }
  );
}

function validateVisualPlaceholderContract(visualPlaceholderContract: SerializableRecord, errors: string[]): void {
  expectEqual(
    visualPlaceholderContract.generatedAssetsIncluded,
    false,
    "visual placeholder generatedAssetsIncluded",
    errors
  );
  expectEqual(
    visualPlaceholderContract.runtimeIntegrationApproved,
    false,
    "visual placeholder runtimeIntegrationApproved",
    errors
  );
  expectEqual(visualPlaceholderContract.runtimeArtIntegrated, false, "visual placeholder runtimeArtIntegrated", errors);
  if (((visualPlaceholderContract.generatedImagePaths as unknown[]) ?? []).length !== 0) {
    errors.push("Desktop spike visual placeholder contract must not include generated image paths.");
  }
}

function validateInputContract(inputContract: SerializableRecord, errors: string[]): void {
  const prohibited = new Set((inputContract.prohibitedChanges as string[]) ?? []);
  if (!prohibited.has("runtime input refactor")) {
    errors.push("Desktop spike input contract must prohibit runtime input refactors.");
  }
}

function validateResultsContract(resultsContract: SerializableRecord, errors: string[]): void {
  expectEqual(resultsContract.saveMutationAllowed, false, "results contract saveMutationAllowed", errors);
  expectEqual(resultsContract.rewardMutationAllowed, false, "results contract rewardMutationAllowed", errors);
  expectEqual(resultsContract.localStorageMutationAllowed, false, "results contract localStorageMutationAllowed", errors);
}

function validateFixtureHashes(files: Record<FixtureFileName, string>): string[] {
  const errors: string[] = [];
  const parsed = JSON.parse(files["fixture-hashes.json"]) as DesktopSpikeFixtureHashes;
  Object.entries(parsed.files).forEach(([fileName, expectedHash]) => {
    const contents = files[fileName as Exclude<FixtureFileName, "fixture-hashes.json">];
    if (!contents) {
      errors.push(`Desktop spike fixture hashes include missing file ${fileName}.`);
      return;
    }
    const actualHash = hashText(contents);
    if (actualHash !== expectedHash) {
      errors.push(`Desktop spike fixture hash mismatch for ${fileName}.`);
    }
  });
  const actualFixtureHash = hashText(stableStringify(parsed.files));
  if (actualFixtureHash !== parsed.fixtureHash) {
    errors.push("Desktop spike fixture aggregate hash does not match file hashes.");
  }
  return errors;
}

function expectEqual(actual: unknown, expected: unknown, label: string, errors: string[]): void {
  if (actual !== expected) {
    errors.push(`Expected ${label} to be ${String(expected)}, got ${String(actual)}.`);
  }
}

async function readJson(path: string): Promise<unknown> {
  return JSON.parse(await readFile(resolve(path), "utf8")) as unknown;
}

function hashText(contents: string): string {
  return createHash("sha256").update(contents).digest("hex");
}
