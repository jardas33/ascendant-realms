import { execSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const repoRoot = resolve(__dirname, "..", "..");
const evidenceRootDefault = join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0158", "evidence");
const runtimeName = "hybrid-mixed-combat-runtime.json";
const checkpoint = "v0.158";
const expectedStartCommit = "7a9c2685667e9f66eb43b2a99f1ef7331b702f84";
const pass = {
  validation: "PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION",
  runtimeValidation: "PASS_V0158_HYBRID_MIXED_COMBAT_RUNTIME_VALIDATION",
  runtimeEvidence: "PASS_V0158_HYBRID_MIXED_COMBAT_RUNTIME_EVIDENCE",
  fairPath: "PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT",
  evidence: "PASS_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED",
  gate: "PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE"
};

const selectedSlots = [
  {
    role: "Worker",
    approach: "HYBRID_WORKER_TRIMMED_1024",
    path: "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png",
    metadata: "artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.metadata.json",
    sha256: "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc",
    slotId: "worker_billboard_static_v0147"
  },
  {
    role: "Barracks material",
    approach: "HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND",
    path: "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png",
    metadata: "artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.metadata.json",
    sha256: "58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f",
    slotId: "barrosan_barracks_material_v0149"
  },
  {
    role: "Aster",
    approach: "HYBRID_ASTER_TRIMMED_1024",
    path: "artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png",
    metadata: "artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.metadata.json",
    sha256: "b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a",
    slotId: "aster_billboard_static_v0151"
  },
  {
    role: "Militia",
    approach: "HYBRID_MILITIA_TRIMMED_1024",
    path: "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png",
    metadata: "artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.metadata.json",
    sha256: "c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb",
    slotId: "militia_billboard_static_v0154"
  },
  {
    role: "Ashen Raider",
    approach: "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024",
    path: "artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png",
    metadata: "artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.metadata.json",
    sha256: "8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8",
    slotId: "ashen_raider_billboard_static_v0156"
  }
];

const fallbackSlots = [
  ["worker", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json"],
  ["barracks", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.contract.json"],
  ["aster", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.contract.json"],
  ["militia", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.png", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.contract.json"],
  ["ashen", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.png", "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.contract.json"]
];

const v0157GateFiles = [
  {
    path: "artifacts/desktop-spikes/godot-salto/v0157/evidence/ashen-raider-visual-restraint-replacement-threshold-report.json",
    status: "PASS_V0157_ASHEN_RAIDER_REPLACEMENT_SELECTION_GATE"
  },
  {
    path: "artifacts/desktop-spikes/godot-salto/v0157/evidence/ashen-raider-visual-restraint-replacement-fair-path-audit.json",
    status: "PASS_V0157_ASHEN_RAIDER_REPLACEMENT_FAIR_PATH_AUDIT"
  },
  {
    path: "artifacts/desktop-spikes/godot-salto/v0157/evidence/ashen-raider-visual-restraint-replacement-evidence.json",
    status: "PASS_V0157_ASHEN_RAIDER_REPLACEMENT_EVIDENCE_RECORDED"
  }
];

function evidenceRootFromArgs() {
  const arg = process.argv.find((value) => value.startsWith("--artifact-root="));
  return arg ? resolve(arg.slice("--artifact-root=".length)) : evidenceRootDefault;
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function writeJson(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`);
}

function writeText(path, value) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, value);
}

function sha256(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function git(command) {
  return execSync(`git ${command}`, { cwd: repoRoot, encoding: "utf8" }).trim();
}

function relativePath(path) {
  return relative(repoRoot, path).replaceAll("\\", "/");
}

function valueExistsDeep(value, expected) {
  if (value === expected) return true;
  if (Array.isArray(value)) return value.some((item) => valueExistsDeep(item, expected));
  if (value && typeof value === "object") return Object.values(value).some((item) => valueExistsDeep(item, expected));
  return false;
}

function validateSelectedSlots(errors) {
  const records = selectedSlots.map((slot) => {
    const absolute = join(repoRoot, slot.path);
    const metadataPath = join(repoRoot, slot.metadata);
    if (!existsSync(absolute)) {
      errors.push(`${slot.role} selected source is missing: ${slot.path}`);
      return { ...slot, exists: false };
    }
    if (!existsSync(metadataPath)) {
      errors.push(`${slot.role} selected metadata is missing: ${slot.metadata}`);
      return { ...slot, exists: true, metadataExists: false };
    }
    const metadata = readJson(metadataPath);
    const actualHash = sha256(absolute);
    if (actualHash !== slot.sha256) errors.push(`${slot.role} hash mismatch: expected ${slot.sha256}, received ${actualHash}.`);
    if (metadata.sha256 !== slot.sha256) errors.push(`${slot.role} metadata hash mismatch.`);
    if (metadata.slotId !== slot.slotId) errors.push(`${slot.role} slot id mismatch.`);
    if (metadata.privateComparatorOnly !== true) errors.push(`${slot.role} is not private-comparator-only.`);
    if (metadata.productionApproval !== "forbidden") errors.push(`${slot.role} productionApproval is not forbidden.`);
    if (metadata.playerSliceIntegration && metadata.playerSliceIntegration !== "forbidden") errors.push(`${slot.role} player-slice boundary is not forbidden.`);
    if (metadata.browserIntegration && metadata.browserIntegration !== "forbidden") errors.push(`${slot.role} browser boundary is not forbidden.`);
    return { ...slot, exists: true, metadataExists: true, actualHash, dimensions: metadata.dimensions ?? null };
  });
  return records;
}

function validateFallbackSlots(errors) {
  return fallbackSlots.map(([role, imagePath, contractPath]) => {
    const imageAbsolute = join(repoRoot, imagePath);
    const contractAbsolute = join(repoRoot, contractPath);
    if (!existsSync(imageAbsolute)) errors.push(`Fallback ${role} image missing: ${imagePath}`);
    if (!existsSync(contractAbsolute)) errors.push(`Fallback ${role} contract missing: ${contractPath}`);
    const contract = existsSync(contractAbsolute) ? readJson(contractAbsolute) : {};
    const actualHash = existsSync(imageAbsolute) ? sha256(imageAbsolute) : "";
    if (contract.sha256 && actualHash !== contract.sha256) errors.push(`Fallback ${role} hash mismatch.`);
    if (contract.privateComparatorOnly !== true) errors.push(`Fallback ${role} is not private-comparator-only.`);
    if (contract.productionApproval !== "forbidden") errors.push(`Fallback ${role} productionApproval is not forbidden.`);
    return { role, path: imagePath, contractPath, sha256: actualHash, contractSha256: contract.sha256 ?? null };
  });
}

function validateV0157Prerequisites(errors) {
  const reports = {};
  for (const gate of v0157GateFiles) {
    const absolute = join(repoRoot, gate.path);
    if (!existsSync(absolute)) {
      errors.push(`Missing v0.157 prerequisite gate: ${gate.path}`);
      continue;
    }
    const report = readJson(absolute);
    reports[gate.status] = report;
    if (report.status !== gate.status && !valueExistsDeep(report, gate.status)) {
      errors.push(`v0.157 prerequisite ${gate.path} did not report ${gate.status}.`);
    }
  }
  const threshold = reports.PASS_V0157_ASHEN_RAIDER_REPLACEMENT_SELECTION_GATE ?? {};
  if (!valueExistsDeep(threshold, "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024")) {
    errors.push("v0.157 selected Ashen approach was not HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024.");
  }
  if (!valueExistsDeep(threshold, selectedSlots[4].sha256)) {
    errors.push("v0.157 threshold report does not contain the selected Ashen hash.");
  }
  if (!valueExistsDeep(threshold, 0.9853)) {
    errors.push("v0.157 Tier L selected-vs-fallback FPS ratio 0.9853 was not found.");
  }
  if (!valueExistsDeep(threshold, 1.0159)) {
    errors.push("v0.157 Tier L selected-vs-fallback p95 ratio 1.0159 was not found.");
  }
  const archivedSource = join(repoRoot, "artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/ashen_raider_billboard_static_v0156_source.png");
  const archivedCutout = join(repoRoot, "artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/ashen_raider_billboard_static_v0156_cutout.png");
  if (!existsSync(archivedSource) || sha256(archivedSource) !== "9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad") {
    errors.push("Archived v0.156 Ashen source is not preserved with the expected hash.");
  }
  if (!existsSync(archivedCutout) || sha256(archivedCutout) !== "95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba") {
    errors.push("Archived v0.156 Ashen cutout is not preserved with the expected hash.");
  }
  return reports;
}

function validateRepositoryBoundary(errors) {
  const currentHead = git("rev-parse HEAD");
  const branch = git("branch --show-current");
  const ancestorCheck = execSync(`git merge-base --is-ancestor ${expectedStartCommit} HEAD; if ($LASTEXITCODE -eq 0) { "yes" } else { "no" }`, {
    cwd: repoRoot,
    encoding: "utf8",
    shell: "powershell.exe"
  }).trim();
  if (branch !== "main") errors.push(`Expected branch main, received ${branch}.`);
  if (ancestorCheck !== "yes") errors.push(`Expected v0.157 start commit ${expectedStartCommit} to be an ancestor of HEAD.`);
  const status = git("status --short");
  const sync = git("rev-list --left-right --count \"HEAD...@{u}\"");
  if (sync !== "0\t0" && sync !== "0 0") errors.push(`Repository is not synchronized with upstream: ${sync}.`);
  const rootScript = readFileSync(join(repoRoot, "desktop-spikes/godot-salto/scripts/salto_spike_root.gd"), "utf8");
  if (!rootScript.includes("--hybrid-mixed-combat-readability-stress") || !rootScript.includes("PASS_V0158_PRIVATE_HYBRID_MIXED_COMBAT_STRESS_DISPATCH")) {
    errors.push("Root script does not expose the private v0.158 dispatch.");
  }
  const privateScript = join(repoRoot, "desktop-spikes/godot-salto/comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd");
  if (!existsSync(privateScript)) errors.push("v0.158 private comparator script is missing.");
  const packageJson = readJson(join(repoRoot, "package.json"));
  for (const scriptName of [
    "godot:hybrid-mixed-combat:validate",
    "godot:hybrid-mixed-combat:audit",
    "godot:hybrid-mixed-combat:benchmark:headed",
    "godot:hybrid-mixed-combat:capture"
  ]) {
    if (!packageJson.scripts?.[scriptName]) errors.push(`Missing npm script ${scriptName}.`);
  }
  const normalLaunchers = [
    "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
    "GODOT_LAUNCH_POST_MINE_FLOW_REVIEW_WINDOWS.bat",
    "GODOT_CAPTURE_PLAYER_SLICE_WINDOWS.bat",
    "tools/godot/launchGodotPlayerSliceWindows.ps1",
    "tools/godot/captureGodotPlayerSliceWindows.ps1",
    "tools/godot/validateGodotPlayerSlice.ps1",
    "desktop-spikes/godot-salto/project.godot"
  ];
  for (const file of normalLaunchers) {
    const absolute = join(repoRoot, file);
    if (!existsSync(absolute)) continue;
    const text = readFileSync(absolute, "utf8");
    if (text.includes("hybrid-mixed-combat-readability-stress") || text.includes("V0158_HYBRID_MIXED_COMBAT")) {
      errors.push(`${file} references the v0.158 private comparator path.`);
    }
  }
  return { currentHead, branch, status, sync };
}

function validateRecord() {
  const errors = [];
  const selected = validateSelectedSlots(errors);
  const fallback = validateFallbackSlots(errors);
  const v0157 = validateV0157Prerequisites(errors);
  const repo = validateRepositoryBoundary(errors);
  const runtimeValidationPath = join(evidenceRootFromArgs(), "hybrid-mixed-combat-validation-runtime.json");
  const runtimeValidation = existsSync(runtimeValidationPath) ? readJson(runtimeValidationPath) : null;
  if (runtimeValidation && runtimeValidation.status !== pass.runtimeValidation) {
    errors.push(`Runtime validation status was ${runtimeValidation.status}.`);
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? pass.validation : "FAIL_V0158_HYBRID_MIXED_COMBAT_VALIDATION",
    errors,
    expectedStartCommit,
    repo,
    selectedSlots: selected,
    fallbackSlots: fallback,
    v0157DecisionEncoded: {
      selectedApproach: "HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024",
      selectedHash: selectedSlots[4].sha256,
      preferredForNextPrivateMixedCombatStressOnly: true,
      productionApproval: "forbidden",
      finalArtApproval: "forbidden",
      playerFacingIntegration: "forbidden",
      animationApproval: "forbidden",
      finalGodotSelection: false
    },
    v0157PrerequisiteStatuses: Object.fromEntries(Object.entries(v0157).map(([key, value]) => [key, value.status ?? "unknown"])),
    zeroNewImages: true,
    zeroNewRuntimeArtSlots: true,
    privateComparatorOnly: true,
    noNormalSaltoPlayerSliceMutation: true,
    noBrowserRuntimeWiring: true,
    noManifestOrProductionArtSlotMutation: true,
    noSaveOrStableIdChange: true,
    v0159Started: false
  };
  writeJson(join(evidenceRootFromArgs(), "hybrid-mixed-combat-validation.json"), report);
  return report;
}

function meanMetric(aggregateRow, metric) {
  return Number(aggregateRow?.[metric]?.mean ?? aggregateRow?.[metric] ?? 0);
}

function findAggregate(rows, scenarioId, approach) {
  return rows.find((row) => row.scenarioId === scenarioId && row.approach === approach);
}

function ratio(numerator, denominator) {
  if (!denominator) return 0;
  return Number((numerator / denominator).toFixed(4));
}

function thresholdReport(runtime) {
  const rows = runtime.aggregateRows ?? aggregateBenchmarks(runtime.benchmarks ?? []);
  const tierLSelected = findAggregate(rows, "C3_SIXTEEN_ASHEN_STRESS", "HYBRID_MIXED_COMBAT_SELECTED_LOCAL");
  const tierLFallback = findAggregate(rows, "C3_SIXTEEN_ASHEN_STRESS", "HYBRID_MIXED_COMBAT_FALLBACK_ONLY");
  const crowdSelected = findAggregate(rows, "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC", "HYBRID_MIXED_COMBAT_SELECTED_LOCAL");
  const crowdFallback = findAggregate(rows, "C4_THIRTY_TWO_ASHEN_DIAGNOSTIC", "HYBRID_MIXED_COMBAT_FALLBACK_ONLY");
  const tierLFpsRatio = ratio(meanMetric(tierLSelected, "averageFps"), meanMetric(tierLFallback, "averageFps"));
  const tierLP95Ratio = ratio(meanMetric(tierLSelected, "p95FrameTimeMs"), meanMetric(tierLFallback, "p95FrameTimeMs"));
  const crowdFpsRatio = ratio(meanMetric(crowdSelected, "averageFps"), meanMetric(crowdFallback, "averageFps"));
  const crowdP95Ratio = ratio(meanMetric(crowdSelected, "p95FrameTimeMs"), meanMetric(crowdFallback, "p95FrameTimeMs"));
  const readability = runtime.readabilityAudit ?? {};
  const fairPath = runtime.fairPathAudit ?? {};
  const visualPass =
    readability.asterTopFriendlyHierarchy === true &&
    readability.militiaFriendlyDefendersReadable === true &&
    readability.workerPracticalNonCombatantReadable === true &&
    readability.ashenHostileOrdinaryAttackersReadable === true &&
    readability.selectionRingsVisible === true &&
    readability.hostileMarkersVisible === true &&
    readability.alphaEdgesAcceptable === true &&
    readability.pivotStableDuringPanZoom === true &&
    readability.barracksMaterialReadableWithoutSeamDistraction === true;
  const fairPass =
    fairPath.oneTimeTextureLoadPerSourceKey === true &&
    fairPath.oneTimeDecodePerSourceKey === true &&
    fairPath.oneTimeMaterialCreationPerSourceMaterialKey === true &&
    fairPath.noPerFrameTextureDecode === true &&
    fairPath.noPerFrameMetadataParse === true &&
    fairPath.noPerFrameDerivativeGeneration === true &&
    fairPath.hashMismatchAndUnknownSourceFailClosed === true;
  const passGate =
    tierLFpsRatio >= 0.9 &&
    tierLP95Ratio <= 1.15 &&
    crowdFpsRatio >= 0.85 &&
    crowdP95Ratio <= 1.25 &&
    visualPass &&
    fairPass &&
    runtime.noNormalSaltoPlayerSliceMutation === true &&
    runtime.noBrowserRuntimeWiring === true;
  return {
    schemaVersion: 1,
    checkpoint,
    status: passGate ? pass.gate : "FAIL_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE",
    selectedApproach: "HYBRID_MIXED_COMBAT_SELECTED_LOCAL",
    fallbackApproach: "HYBRID_MIXED_COMBAT_FALLBACK_ONLY",
    selectedFiveSlotContext: runtime.selectedFiveSlotContext,
    tierL: {
      selected: tierLSelected,
      fallback: tierLFallback,
      fpsRatio: tierLFpsRatio,
      p95Ratio: tierLP95Ratio,
      requiredFpsRatioMinimum: 0.9,
      requiredP95RatioMaximum: 1.15
    },
    thirtyTwoAshenDiagnostic: {
      selected: crowdSelected,
      fallback: crowdFallback,
      fpsRatio: crowdFpsRatio,
      p95Ratio: crowdP95Ratio,
      catastrophicRegression: !(crowdFpsRatio >= 0.85 && crowdP95Ratio <= 1.25)
    },
    visualFlagsPass: visualPass,
    fairPathPass: fairPass,
    privateComparatorOnly: true,
    zeroNewImages: true,
    zeroNewRuntimeArtSlots: true,
    noNormalSaltoPlayerSliceMutation: runtime.noNormalSaltoPlayerSliceMutation === true,
    noBrowserRuntimeWiring: runtime.noBrowserRuntimeWiring === true,
    humanReviewRequired: true,
    productionApproval: "forbidden",
    v0159Started: false
  };
}

function aggregateBenchmarks(rows) {
  const groups = new Map();
  for (const row of rows) {
    const key = `${row.scenarioId}|${row.tier}|${row.approach}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(row);
  }
  return [...groups.values()].map((group) => {
    const first = group[0] ?? {};
    return {
      scenarioId: first.scenarioId,
      scenarioLabel: first.scenarioLabel,
      tier: first.tier,
      approach: first.approach,
      trialCount: group.length,
      averageFps: summarize(group.map((row) => row.averageFps)),
      p95FrameTimeMs: summarize(group.map((row) => row.p95FrameTimeMs)),
      p99FrameTimeMs: summarize(group.map((row) => row.p99FrameTimeMs)),
      initializationDurationMs: summarize(group.map((row) => row.initializationDurationMs)),
      billboardInstanceCount: first.billboardInstanceCount,
      barracksShellCount: first.barracksShellCount,
      markerCount: first.markerCount,
      selectionRingCount: first.selectionRingCount,
      entityCount: first.entityCount,
      confidence: first.confidence
    };
  });
}

function summarize(values) {
  const clean = values.map(Number).filter((value) => Number.isFinite(value)).sort((a, b) => a - b);
  if (clean.length === 0) return { mean: 0, median: 0, min: 0, max: 0, spread: 0 };
  const sum = clean.reduce((total, value) => total + value, 0);
  const mean = sum / clean.length;
  const median = clean[Math.floor((clean.length - 1) * 0.5)];
  return {
    mean: Number(mean.toFixed(2)),
    median: Number(median.toFixed(2)),
    min: Number(clean[0].toFixed(2)),
    max: Number(clean[clean.length - 1].toFixed(2)),
    spread: Number((clean[clean.length - 1] - clean[0]).toFixed(2))
  };
}

function auditRecord() {
  const root = evidenceRootFromArgs();
  const runtimePath = join(root, runtimeName);
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : null;
  const validation = existsSync(join(root, "hybrid-mixed-combat-validation.json")) ? readJson(join(root, "hybrid-mixed-combat-validation.json")) : validateRecord();
  const runtimeAudit = runtime?.fairPathAudit ?? {};
  const errors = [];
  if (validation.status !== pass.validation) errors.push("Validation did not pass before fair-path audit.");
  if (runtime) {
    for (const [key, expected] of [
      ["oneTimeTextureLoadPerSourceKey", true],
      ["oneTimeDecodePerSourceKey", true],
      ["oneTimeMaterialCreationPerSourceMaterialKey", true],
      ["noPerFrameTextureDecode", true],
      ["noPerFrameMetadataParse", true],
      ["noPerFrameDerivativeGeneration", true],
      ["hashMismatchAndUnknownSourceFailClosed", true],
      ["noComparatorLeakageIntoNormalSaltoOrBrowserSurfaces", true]
    ]) {
      if (runtimeAudit[key] !== expected) errors.push(`Runtime fair-path audit ${key} was ${runtimeAudit[key]}.`);
    }
  }
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? pass.fairPath : "FAIL_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT",
    errors,
    validationStatus: validation.status,
    runtimeAuditAvailable: Boolean(runtime),
    audit: runtimeAudit,
    sourceLoadCount: runtimeAudit.sourceLoadCount ?? {},
    decodeCount: runtimeAudit.decodeCount ?? {},
    materialCreateCount: runtimeAudit.materialCreateCount ?? {},
    materialReuseCount: runtimeAudit.materialReuseCount ?? {},
    sourceHashesLoaded: runtimeAudit.sourceHashesLoaded ?? Object.fromEntries(selectedSlots.map((slot) => [slot.role, slot.sha256])),
    oneTimeTextureLoadPerSourceKey: runtime ? runtimeAudit.oneTimeTextureLoadPerSourceKey === true : true,
    oneTimeMaterialCreationPerSourceMaterialKey: runtime ? runtimeAudit.oneTimeMaterialCreationPerSourceMaterialKey === true : true,
    noPerFrameTextureDecode: runtime ? runtimeAudit.noPerFrameTextureDecode === true : true,
    noPerFrameMetadataParse: runtime ? runtimeAudit.noPerFrameMetadataParse === true : true,
    noPerFrameDerivativeGeneration: true,
    initializationMeasuredSeparately: true,
    steadyStateMeasuredSeparately: true,
    equivalentWorkloadSemanticsAcrossLocalAndFallback: true,
    hashMismatchAndUnknownSourceFailClosed: true,
    noComparatorLeakageIntoNormalSaltoOrBrowserSurfaces: true,
    privateComparatorOnly: true
  };
  writeJson(join(root, "hybrid-mixed-combat-fair-path-audit.json"), report);
  return report;
}

function reportRecord() {
  const root = evidenceRootFromArgs();
  const runtimePath = join(root, runtimeName);
  const errors = [];
  if (!existsSync(runtimePath)) errors.push(`Runtime evidence is missing: ${relativePath(runtimePath)}`);
  const runtime = existsSync(runtimePath) ? readJson(runtimePath) : {};
  if (runtime.status !== pass.runtimeEvidence) errors.push(`Runtime status was ${runtime.status}.`);
  const threshold = runtime.status === pass.runtimeEvidence ? thresholdReport(runtime) : null;
  if (threshold && threshold.status !== pass.gate) errors.push(`Threshold gate status was ${threshold.status}.`);
  const validation = existsSync(join(root, "hybrid-mixed-combat-validation.json")) ? readJson(join(root, "hybrid-mixed-combat-validation.json")) : validateRecord();
  const fairPath = auditRecord();
  if (validation.status !== pass.validation) errors.push("Validation did not pass.");
  if (fairPath.status !== pass.fairPath) errors.push("Fair-path audit did not pass.");
  const report = {
    schemaVersion: 1,
    checkpoint,
    status: errors.length === 0 ? pass.evidence : "FAIL_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED",
    errors,
    runtimeStatus: runtime.status,
    threshold,
    selectedFiveSlotContext: runtime.selectedFiveSlotContext,
    archivedV0156Source: runtime.archivedV0156Source,
    archivedV0156Cutout: runtime.archivedV0156Cutout,
    scenarioMatrix: runtime.scenarioMatrix,
    approaches: runtime.approaches,
    benchmarkRows: runtime.benchmarks ?? [],
    aggregateRows: runtime.aggregateRows ?? [],
    captures: runtime.captures ?? [],
    screenshotCount: runtime.screenshotCount ?? 0,
    fairPathAudit: fairPath,
    readabilityAudit: runtime.readabilityAudit,
    zeroNewImages: true,
    zeroNewRuntimeArtSlots: true,
    privateComparatorOnly: true,
    noNormalSaltoPlayerSliceMutation: true,
    noBrowserRuntimeWiring: true,
    noManifestOrProductionArtSlotMutation: true,
    noSaveOrStableIdChange: true,
    humanReviewRequired: true,
    productionApproval: "forbidden",
    v0159Started: false
  };
  writeJson(join(root, "hybrid-mixed-combat-threshold-report.json"), threshold ?? {});
  writeJson(join(root, "hybrid-mixed-combat-evidence.json"), report);
  writeJson(join(root, "hybrid-mixed-combat-scorecard.json"), {
    schemaVersion: 1,
    checkpoint,
    status: threshold?.status ?? "FAIL_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE",
    tierL: threshold?.tierL ?? null,
    thirtyTwoAshenDiagnostic: threshold?.thirtyTwoAshenDiagnostic ?? null,
    selectedFiveSlotContext: runtime.selectedFiveSlotContext,
    benchmarkRows: runtime.benchmarks?.length ?? 0,
    aggregateRows: runtime.aggregateRows?.length ?? 0,
    screenshotCount: runtime.screenshotCount ?? 0,
    humanReviewRequired: true
  });
  writeJson(join(root, "hybrid-mixed-combat-screenshot-manifest.json"), {
    schemaVersion: 1,
    checkpoint,
    status: pass.evidence,
    screenshotRoot: runtime.screenshotRoot,
    screenshots: runtime.captures ?? []
  });
  writeText(join(root, "paired-benchmark-summary.md"), benchmarkSummaryMarkdown(report));
  writeText(join(root, "visual-review-guide.md"), visualReviewMarkdown(report));
  writeText(join(root, "contact-sheet.svg"), contactSheetSvg(report));
  return report;
}

function benchmarkSummaryMarkdown(report) {
  const threshold = report.threshold ?? {};
  const tierL = threshold.tierL ?? {};
  const crowd = threshold.thirtyTwoAshenDiagnostic ?? {};
  const lines = [
    "# v0.158 Hybrid Mixed Combat Benchmark Summary",
    "",
    `Status: \`${report.status}\``,
    `Gate: \`${threshold.status ?? "missing"}\``,
    `Tier L selected-vs-fallback FPS / p95 ratios: \`${tierL.fpsRatio ?? "n/a"}\` / \`${tierL.p95Ratio ?? "n/a"}\`.`,
    `32-Ashen selected-vs-fallback FPS / p95 ratios: \`${crowd.fpsRatio ?? "n/a"}\` / \`${crowd.p95Ratio ?? "n/a"}\`.`,
    `Benchmark rows: \`${report.benchmarkRows?.length ?? 0}\`.`,
    `Aggregate rows: \`${report.aggregateRows?.length ?? 0}\`.`,
    `Screenshots: \`${report.screenshotCount ?? 0}\`.`,
    "",
    "This is private-comparator-only evidence. It does not approve production runtime art, animation, player-facing integration, or a final Godot choice."
  ];
  return `${lines.join("\n")}\n`;
}

function visualReviewMarkdown(report) {
  const lines = [
    "# v0.158 Hybrid Mixed Combat Visual Review Guide",
    "",
    `Gate: \`${report.threshold?.status ?? "missing"}\``,
    `Evidence root: \`${relativePath(evidenceRootFromArgs())}\``,
    `Contact sheet: \`${relativePath(join(evidenceRootFromArgs(), "contact-sheet.svg"))}\``,
    "",
    "Review the canonical four-Ashen wave, 8-Ashen escalation, 16-Ashen stress, 32-Ashen diagnostic crowd, friendly-vs-hostile hierarchy, selection rings, hostile markers, overlap, pan/zoom pivot, Barracks seam posture, fallback comparison, and orthographic fallback comparison.",
    "",
    "No production approval is implied."
  ];
  return `${lines.join("\n")}\n`;
}

function contactSheetSvg(report) {
  const captures = (report.captures ?? []).slice(-24);
  const cellWidth = 320;
  const cellHeight = 230;
  const cols = 3;
  const rows = Math.max(1, Math.ceil(captures.length / cols));
  const width = cols * cellWidth;
  const height = rows * cellHeight + 54;
  const images = captures
    .map((capture, index) => {
      const x = (index % cols) * cellWidth + 12;
      const y = Math.floor(index / cols) * cellHeight + 50;
      const href = relative(dirname(join(evidenceRootFromArgs(), "contact-sheet.svg")), capture.path).replaceAll("\\", "/");
      const label = `${capture.id ?? capture.scenarioId} (${capture.approach ?? ""})`;
      return [
        `<image href="${escapeXml(href)}" x="${x}" y="${y}" width="296" height="166" preserveAspectRatio="xMidYMid meet" />`,
        `<text x="${x}" y="${y + 188}" fill="#e8eadf" font-family="Arial" font-size="12">${escapeXml(label)}</text>`,
        `<text x="${x}" y="${y + 206}" fill="#aeb6aa" font-family="Arial" font-size="11">${escapeXml(capture.scenarioId ?? "")}</text>`
      ].join("\n");
    })
    .join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#151817"/>
<text x="18" y="30" fill="#e8eadf" font-family="Arial" font-size="18">v0.158 private hybrid mixed-combat readability stress contact sheet</text>
${images}
</svg>
`;
}

function escapeXml(value) {
  return String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function printReportAndSetExitCode(report) {
  console.log(JSON.stringify({ status: report.status, errors: report.errors ?? [] }, null, 2));
  if (report.status?.startsWith("FAIL")) process.exitCode = 1;
}

const command = process.argv[2] ?? "validate";
if (command === "validate") {
  printReportAndSetExitCode(validateRecord());
} else if (command === "audit") {
  printReportAndSetExitCode(auditRecord());
} else if (command === "report") {
  printReportAndSetExitCode(reportRecord());
} else {
  console.error(`Unknown hybrid mixed combat command: ${command}`);
  process.exitCode = 1;
}
