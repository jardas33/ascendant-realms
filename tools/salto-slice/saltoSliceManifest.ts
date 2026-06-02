import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { RUNTIME_ART_SLOT_IDS } from "../../src/game/art/RuntimeArtSlots";
import type { VisualAssetRegistry } from "../../src/game/art/VisualAssetReviewRegistry";

export const SALTO_SLICE_MANIFEST_PATH = path.join("docs", "V0107_SALTO_VERTICAL_SLICE_MANIFEST.json");
export const SALTO_SLICE_PACKET_DIR = path.join("artifacts", "art-review", "salto-slice-packet");
export const VISUAL_ASSET_REGISTRY_PATH = path.join("src", "game", "art", "visual-asset-registry.json");

export const EXPECTED_SALTO_SLICE_ASSET_IDS = [
  "v0107_salto_environment_style_frame",
  "v0107_battlefield_style_frame",
  "v0107_hud_frame",
  "v0107_results_frame",
  "v0107_lume_style_frame",
  "v0107_campaign_map_style_frame",
  "v0107_barrosan_worker_concept",
  "v0107_barrosan_militia_concept",
  "v0107_barrosan_ranger_concept",
  "v0107_barrosan_hero_concept",
  "v0107_barrosan_command_hall",
  "v0107_barrosan_barracks",
  "v0107_barrosan_mine",
  "v0107_barrosan_shrine",
  "v0107_ashen_enemy_contrast_sheet"
] as const;

const EXPECTED_PACKET_FILES = [
  "generation-order.md",
  "asset-checklist.md",
  "asset-dimension-contracts.json",
  "prompt-reference-index.md",
  "human-review-checklist.md",
  "runtime-slot-map.json",
  "qa-scenario-map.json"
] as const;

interface SaltoSliceManifest {
  schemaVersion: 1;
  checkpoint: string;
  status: string;
  generatedAssetsIncluded: boolean;
  runtimeIntegrationApproved: boolean;
  generatedImagePaths: string[];
  packetOutput: string;
  runtimePosture: {
    status: string;
    candidateApprovalIsLoadable: boolean;
    requiresFutureRuntimeIntegratedState: boolean;
    requiresRuntimeArtSlotValidation: boolean;
    separateIntegrationMilestoneRequired: boolean;
    notes: string;
  };
  privateMockComposition: {
    implemented: boolean;
    visibility: string;
    deferredReason?: string;
  };
  qaScenarios: SaltoSliceQaScenario[];
  assets: SaltoSliceAsset[];
  dependencyOrder: SaltoSliceDependencyEntry[];
  notes: string[];
}

interface SaltoSliceQaScenario {
  scenarioId: string;
  surface: string;
  runtimeSlotIds: string[];
  reviewTarget: string;
}

interface SaltoSliceAsset {
  assetId: string;
  registryAssetIds: string[];
  runtimeSlotIds: string[];
  category: string;
  sourceConceptFormat: string;
  runtimeCandidateFormat: string;
  canvasSize: {
    width: number;
    height: number;
    aspectRatio: string;
  };
  cameraRule: string;
  transparencyRequirement: string;
  pivot: string;
  safeCrop: {
    left: number;
    right: number;
    top: number;
    bottom: number;
    rule: string;
  };
  silhouetteRule: string;
  rtsScaleThumbnailSize: {
    width: number;
    height: number;
    rule: string;
  };
  maximumVisualNoise: string;
  animationPosture: string;
  mipDownscalePosture: string;
  fallbackBehavior: {
    required: boolean;
    owner: string;
    behavior: string;
  };
  visualQaScenarioId: string;
  humanApprovalQuestions: string[];
  reviewGates: string[];
  runtimePosture: string;
  status: string;
  assetDependencyIds: string[];
  notes: string;
}

interface SaltoSliceDependencyEntry {
  orderLabel: string;
  phase: string;
  assetId?: string;
  milestoneId?: string;
  dependsOn: string[];
  notes?: string;
}

export interface SaltoSliceValidationIssue {
  path: string;
  message: string;
}

export interface SaltoSliceValidationResult {
  ok: boolean;
  checks: string[];
  errors: SaltoSliceValidationIssue[];
  warnings: SaltoSliceValidationIssue[];
}

export interface SaltoSlicePacketResult {
  outputDir: string;
  files: string[];
}

export async function loadSaltoSliceManifest(projectRoot = process.cwd()): Promise<SaltoSliceManifest> {
  return readJsonFile<SaltoSliceManifest>(path.join(projectRoot, SALTO_SLICE_MANIFEST_PATH));
}

export async function loadVisualAssetRegistryForSaltoSlice(projectRoot = process.cwd()): Promise<VisualAssetRegistry> {
  return readJsonFile<VisualAssetRegistry>(path.join(projectRoot, VISUAL_ASSET_REGISTRY_PATH));
}

export async function validateCommittedSaltoSliceManifest(projectRoot = process.cwd()): Promise<SaltoSliceValidationResult> {
  const [manifest, registry] = await Promise.all([
    loadSaltoSliceManifest(projectRoot),
    loadVisualAssetRegistryForSaltoSlice(projectRoot)
  ]);
  return validateSaltoSliceManifest(manifest, {
    registryAssetIds: new Set(registry.assets.map((asset) => asset.assetId))
  });
}

export function validateSaltoSliceManifest(
  manifest: SaltoSliceManifest,
  options: { registryAssetIds?: Set<string>; runtimeSlotIds?: Set<string> } = {}
): SaltoSliceValidationResult {
  const checks: string[] = [];
  const errors: SaltoSliceValidationIssue[] = [];
  const warnings: SaltoSliceValidationIssue[] = [];
  const runtimeSlotIds = options.runtimeSlotIds ?? new Set<string>(RUNTIME_ART_SLOT_IDS);
  const registryAssetIds = options.registryAssetIds;

  if (!isRecord(manifest)) {
    return {
      ok: false,
      checks,
      errors: [{ path: "manifest", message: "Salto slice manifest must be a JSON object." }],
      warnings
    };
  }

  if (manifest.schemaVersion !== 1) {
    addError(errors, "schemaVersion", "schemaVersion must be 1.");
  }
  if (manifest.status !== "planning-only") {
    addError(errors, "status", "status must remain planning-only.");
  }
  if (manifest.generatedAssetsIncluded !== false) {
    addError(errors, "generatedAssetsIncluded", "v0.107 must not include generated assets.");
  }
  if (manifest.runtimeIntegrationApproved !== false) {
    addError(errors, "runtimeIntegrationApproved", "v0.107 must not approve runtime integration.");
  }
  if (!Array.isArray(manifest.generatedImagePaths) || manifest.generatedImagePaths.length > 0) {
    addError(errors, "generatedImagePaths", "generatedImagePaths must exist and remain empty.");
  }
  if (manifest.runtimePosture?.candidateApprovalIsLoadable !== false) {
    addError(errors, "runtimePosture.candidateApprovalIsLoadable", "candidate approval must remain non-loadable.");
  }
  if (manifest.privateMockComposition?.implemented && manifest.privateMockComposition.visibility !== "private-only") {
    addError(errors, "privateMockComposition.visibility", "Implemented mock composition previews must be private-only.");
  }

  const qaScenarioIds = new Set<string>();
  if (!Array.isArray(manifest.qaScenarios) || manifest.qaScenarios.length === 0) {
    addError(errors, "qaScenarios", "At least one QA scenario is required.");
  } else {
    manifest.qaScenarios.forEach((scenario, index) => {
      const pathPrefix = `qaScenarios[${index}]`;
      if (!scenario.scenarioId) {
        addError(errors, `${pathPrefix}.scenarioId`, "QA scenario is missing scenarioId.");
      }
      if (qaScenarioIds.has(scenario.scenarioId)) {
        addError(errors, `${pathPrefix}.scenarioId`, `Duplicate QA scenario ID ${scenario.scenarioId}.`);
      }
      qaScenarioIds.add(scenario.scenarioId);
      validateRuntimeSlots(scenario.runtimeSlotIds, `${pathPrefix}.runtimeSlotIds`, runtimeSlotIds, errors);
      if (!scenario.reviewTarget?.trim()) {
        addError(errors, `${pathPrefix}.reviewTarget`, "QA scenario is missing reviewTarget.");
      }
    });
  }

  const assets = Array.isArray(manifest.assets) ? manifest.assets : [];
  if (assets.length === 0) {
    addError(errors, "assets", "Manifest must include planned assets.");
  }
  const actualAssetOrder = assets.map((asset) => asset.assetId);
  if (actualAssetOrder.join("|") === EXPECTED_SALTO_SLICE_ASSET_IDS.join("|")) {
    checks.push(`stable Salto slice asset order preserved: ${EXPECTED_SALTO_SLICE_ASSET_IDS.length} assets`);
  } else {
    addError(errors, "assets", "Manifest assets must match the v0.107 deterministic first-slice order.");
  }

  const assetIds = new Set<string>();
  assets.forEach((asset, index) => {
    const pathPrefix = `assets[${index}]`;
    if (!asset.assetId?.trim()) {
      addError(errors, `${pathPrefix}.assetId`, "Asset is missing assetId.");
      return;
    }
    if (assetIds.has(asset.assetId)) {
      addError(errors, `${pathPrefix}.assetId`, `Duplicate assetId ${asset.assetId}.`);
    }
    assetIds.add(asset.assetId);
    validateAsset(asset, pathPrefix, qaScenarioIds, runtimeSlotIds, registryAssetIds, errors);
  });

  validateDependencyOrder(manifest.dependencyOrder, assetIds, errors);
  validateDependencyCycles(assets, errors);
  validateNoGeneratedImagePaths(manifest, errors);

  if (errors.length === 0) {
    checks.push("manifest parses and remains planning-only");
    checks.push("all registry mappings resolve to the v0.105 visual asset registry");
    checks.push("all runtime slots are known v0.106 slots");
    checks.push("no generated image path or runtime integration approval is present");
    checks.push("fallback, QA scenario, dimension, and dependency contracts are complete");
  }

  return { ok: errors.length === 0, checks, errors, warnings };
}

export async function generateSaltoSlicePacket(projectRoot = process.cwd()): Promise<SaltoSlicePacketResult> {
  const manifest = await loadSaltoSliceManifest(projectRoot);
  const registry = await loadVisualAssetRegistryForSaltoSlice(projectRoot);
  const validation = validateSaltoSliceManifest(manifest, {
    registryAssetIds: new Set(registry.assets.map((asset) => asset.assetId))
  });
  if (!validation.ok) {
    throw new Error(
      `Salto slice manifest validation failed:\n${validation.errors.map((error) => `- ${error.path}: ${error.message}`).join("\n")}`
    );
  }

  const outputDir = path.resolve(projectRoot, SALTO_SLICE_PACKET_DIR);
  assertInside(path.resolve(projectRoot, "artifacts", "art-review"), outputDir);
  await rm(outputDir, { recursive: true, force: true });
  await mkdir(outputDir, { recursive: true });

  const outputs: Record<(typeof EXPECTED_PACKET_FILES)[number], string> = {
    "generation-order.md": renderGenerationOrder(manifest),
    "asset-checklist.md": renderAssetChecklist(manifest),
    "asset-dimension-contracts.json": `${stableJson({
      schemaVersion: manifest.schemaVersion,
      checkpoint: manifest.checkpoint,
      generatedAssetsIncluded: false,
      runtimeIntegrationApproved: false,
      assets: manifest.assets.map((asset) => ({
        assetId: asset.assetId,
        category: asset.category,
        registryAssetIds: asset.registryAssetIds,
        runtimeSlotIds: asset.runtimeSlotIds,
        sourceConceptFormat: asset.sourceConceptFormat,
        runtimeCandidateFormat: asset.runtimeCandidateFormat,
        canvasSize: asset.canvasSize,
        cameraRule: asset.cameraRule,
        transparencyRequirement: asset.transparencyRequirement,
        pivot: asset.pivot,
        safeCrop: asset.safeCrop,
        silhouetteRule: asset.silhouetteRule,
        rtsScaleThumbnailSize: asset.rtsScaleThumbnailSize,
        maximumVisualNoise: asset.maximumVisualNoise,
        animationPosture: asset.animationPosture,
        mipDownscalePosture: asset.mipDownscalePosture,
        fallbackBehavior: asset.fallbackBehavior,
        visualQaScenarioId: asset.visualQaScenarioId,
        runtimePosture: asset.runtimePosture
      }))
    })}\n`,
    "prompt-reference-index.md": renderPromptReferenceIndex(manifest, registry),
    "human-review-checklist.md": renderHumanReviewChecklist(manifest),
    "runtime-slot-map.json": `${stableJson({
      schemaVersion: manifest.schemaVersion,
      checkpoint: manifest.checkpoint,
      runtimeIntegrationApproved: false,
      assets: manifest.assets.map((asset) => ({
        assetId: asset.assetId,
        runtimeSlotIds: asset.runtimeSlotIds,
        registryAssetIds: asset.registryAssetIds,
        runtimePosture: asset.runtimePosture,
        fallbackOwner: asset.fallbackBehavior.owner
      }))
    })}\n`,
    "qa-scenario-map.json": `${stableJson({
      schemaVersion: manifest.schemaVersion,
      checkpoint: manifest.checkpoint,
      qaScenarios: manifest.qaScenarios,
      assetScenarioMap: manifest.assets.map((asset) => ({
        assetId: asset.assetId,
        visualQaScenarioId: asset.visualQaScenarioId
      }))
    })}\n`
  };

  const files: string[] = [];
  for (const fileName of EXPECTED_PACKET_FILES) {
    const filePath = path.join(outputDir, fileName);
    await writeFile(filePath, outputs[fileName], "utf8");
    files.push(normalizePath(path.relative(projectRoot, filePath)));
  }

  return { outputDir, files };
}

export function expectedSaltoSlicePacketFiles(): string[] {
  return [...EXPECTED_PACKET_FILES];
}

function validateAsset(
  asset: SaltoSliceAsset,
  pathPrefix: string,
  qaScenarioIds: Set<string>,
  runtimeSlotIds: Set<string>,
  registryAssetIds: Set<string> | undefined,
  errors: SaltoSliceValidationIssue[]
): void {
  if (!Array.isArray(asset.registryAssetIds) || asset.registryAssetIds.length === 0) {
    addError(errors, `${pathPrefix}.registryAssetIds`, "Asset must map to at least one registry asset ID.");
  } else if (registryAssetIds) {
    asset.registryAssetIds.forEach((assetId) => {
      if (!registryAssetIds.has(assetId)) {
        addError(errors, `${pathPrefix}.registryAssetIds`, `Unknown registry asset ID ${assetId}.`);
      }
    });
  }

  validateRuntimeSlots(asset.runtimeSlotIds, `${pathPrefix}.runtimeSlotIds`, runtimeSlotIds, errors);

  if (!asset.canvasSize || asset.canvasSize.width <= 0 || asset.canvasSize.height <= 0 || !asset.canvasSize.aspectRatio) {
    addError(errors, `${pathPrefix}.canvasSize`, "Asset must define width, height, and aspectRatio.");
  }
  if (!asset.cameraRule?.trim()) {
    addError(errors, `${pathPrefix}.cameraRule`, "Asset must define a camera rule.");
  }
  if (!asset.transparencyRequirement?.trim()) {
    addError(errors, `${pathPrefix}.transparencyRequirement`, "Asset must define transparency requirement.");
  }
  if (!asset.pivot?.trim()) {
    addError(errors, `${pathPrefix}.pivot`, "Asset must define pivot posture.");
  }
  if (!asset.safeCrop?.rule?.trim()) {
    addError(errors, `${pathPrefix}.safeCrop`, "Asset must define safe crop posture.");
  }
  if (!asset.silhouetteRule?.trim()) {
    addError(errors, `${pathPrefix}.silhouetteRule`, "Asset must define silhouette rule.");
  }
  if (!asset.rtsScaleThumbnailSize || asset.rtsScaleThumbnailSize.width <= 0 || asset.rtsScaleThumbnailSize.height <= 0) {
    addError(errors, `${pathPrefix}.rtsScaleThumbnailSize`, "Asset must define RTS-scale thumbnail size.");
  }
  if (!asset.maximumVisualNoise?.trim()) {
    addError(errors, `${pathPrefix}.maximumVisualNoise`, "Asset must define maximum visual noise.");
  }
  if (!asset.animationPosture?.trim()) {
    addError(errors, `${pathPrefix}.animationPosture`, "Asset must define animation posture.");
  }
  if (!asset.mipDownscalePosture?.trim()) {
    addError(errors, `${pathPrefix}.mipDownscalePosture`, "Asset must define mip/downscale posture.");
  }
  if (!asset.fallbackBehavior?.required || !asset.fallbackBehavior.owner?.trim() || !asset.fallbackBehavior.behavior?.trim()) {
    addError(errors, `${pathPrefix}.fallbackBehavior`, "Asset must define a required fallback owner and behavior.");
  }
  if (!asset.visualQaScenarioId?.trim() || !qaScenarioIds.has(asset.visualQaScenarioId)) {
    addError(errors, `${pathPrefix}.visualQaScenarioId`, "Asset must reference a known QA scenario.");
  }
  if (!Array.isArray(asset.humanApprovalQuestions) || asset.humanApprovalQuestions.length === 0) {
    addError(errors, `${pathPrefix}.humanApprovalQuestions`, "Asset must define human approval questions.");
  }
  if (asset.runtimePosture !== "reference-only:not-runtime") {
    addError(errors, `${pathPrefix}.runtimePosture`, "Asset runtime posture must remain reference-only:not-runtime.");
  }
  if (asset.status !== "not-created") {
    addError(errors, `${pathPrefix}.status`, "Asset status must remain not-created during v0.107.");
  }
}

function validateRuntimeSlots(
  values: string[],
  pathPrefix: string,
  runtimeSlotIds: Set<string>,
  errors: SaltoSliceValidationIssue[]
): void {
  if (!Array.isArray(values) || values.length === 0) {
    addError(errors, pathPrefix, "At least one known runtime slot ID is required.");
    return;
  }
  values.forEach((slotId) => {
    if (!runtimeSlotIds.has(slotId)) {
      addError(errors, pathPrefix, `Unknown runtime slot ID ${slotId}.`);
    }
  });
}

function validateDependencyOrder(
  dependencyOrder: SaltoSliceDependencyEntry[],
  assetIds: Set<string>,
  errors: SaltoSliceValidationIssue[]
): void {
  if (!Array.isArray(dependencyOrder) || dependencyOrder.length === 0) {
    addError(errors, "dependencyOrder", "dependencyOrder is required.");
    return;
  }

  const orderedAssetIds = dependencyOrder
    .filter((entry) => Boolean(entry.assetId))
    .map((entry) => entry.assetId ?? "");
  if (orderedAssetIds.join("|") !== EXPECTED_SALTO_SLICE_ASSET_IDS.join("|")) {
    addError(errors, "dependencyOrder", "dependencyOrder must preserve the deterministic v0.107 asset order.");
  }

  const knownDependencyIds = new Set([...assetIds, "runtime-candidates-chosen", "separate-runtime-integration-milestone"]);
  dependencyOrder.forEach((entry, index) => {
    if (!entry.orderLabel?.trim()) {
      addError(errors, `dependencyOrder[${index}].orderLabel`, "Dependency entry is missing orderLabel.");
    }
    if (!entry.phase?.trim()) {
      addError(errors, `dependencyOrder[${index}].phase`, "Dependency entry is missing phase.");
    }
    if (!entry.assetId && !entry.milestoneId) {
      addError(errors, `dependencyOrder[${index}]`, "Dependency entry must define assetId or milestoneId.");
    }
    if (entry.assetId && !assetIds.has(entry.assetId)) {
      addError(errors, `dependencyOrder[${index}].assetId`, `Unknown dependency-order assetId ${entry.assetId}.`);
    }
    if (!Array.isArray(entry.dependsOn)) {
      addError(errors, `dependencyOrder[${index}].dependsOn`, "dependsOn must be an array.");
      return;
    }
    entry.dependsOn.forEach((dependencyId) => {
      if (!knownDependencyIds.has(dependencyId)) {
        addError(errors, `dependencyOrder[${index}].dependsOn`, `Unknown dependency ID ${dependencyId}.`);
      }
    });
  });
}

function validateDependencyCycles(assets: SaltoSliceAsset[], errors: SaltoSliceValidationIssue[]): void {
  const graph = new Map<string, string[]>();
  assets.forEach((asset) => graph.set(asset.assetId, asset.assetDependencyIds ?? []));

  const visiting = new Set<string>();
  const visited = new Set<string>();
  const pathStack: string[] = [];

  const visit = (assetId: string): void => {
    if (visited.has(assetId)) {
      return;
    }
    if (visiting.has(assetId)) {
      const cycleStart = pathStack.indexOf(assetId);
      const cycle = [...pathStack.slice(cycleStart), assetId].join(" -> ");
      addError(errors, "assetDependencyIds", `Dependency cycle detected: ${cycle}.`);
      return;
    }

    visiting.add(assetId);
    pathStack.push(assetId);
    for (const dependencyId of graph.get(assetId) ?? []) {
      if (!graph.has(dependencyId)) {
        addError(errors, `${assetId}.assetDependencyIds`, `Unknown asset dependency ${dependencyId}.`);
        continue;
      }
      visit(dependencyId);
    }
    pathStack.pop();
    visiting.delete(assetId);
    visited.add(assetId);
  };

  for (const assetId of graph.keys()) {
    visit(assetId);
  }
}

function validateNoGeneratedImagePaths(value: unknown, errors: SaltoSliceValidationIssue[]): void {
  const blockedPathPattern = /(?:public\/assets|\/assets\/|artifacts\/art-review\/[^"\s]*\/images\/)[^"\s]*\.(?:avif|jpeg|jpg|png|svg|webp)/iu;
  const candidatePathPattern = /artifacts\/art-review\/candidates\/[^"\s]*\.(?:avif|jpeg|jpg|png|svg|webp)/iu;
  const strings: Array<{ path: string; value: string }> = [];
  collectStrings(value, "manifest", strings);
  strings.forEach((entry) => {
    if (blockedPathPattern.test(entry.value) || candidatePathPattern.test(entry.value)) {
      addError(errors, entry.path, "Manifest must not contain generated image, candidate image, or runtime image paths.");
    }
  });
}

function collectStrings(value: unknown, pathName: string, target: Array<{ path: string; value: string }>): void {
  if (typeof value === "string") {
    target.push({ path: pathName, value });
    return;
  }
  if (Array.isArray(value)) {
    value.forEach((entry, index) => collectStrings(entry, `${pathName}[${index}]`, target));
    return;
  }
  if (!isRecord(value)) {
    return;
  }
  Object.entries(value).forEach(([key, entry]) => collectStrings(entry, `${pathName}.${key}`, target));
}

function renderGenerationOrder(manifest: SaltoSliceManifest): string {
  const lines = [
    "# v0.107 Salto Slice Generation Order",
    "",
    "Status: packet metadata only. Do not generate images from this file without a separate explicit request.",
    "",
    "| Order | Phase | Item | Depends on |",
    "| --- | --- | --- | --- |"
  ];

  manifest.dependencyOrder.forEach((entry) => {
    const item = entry.assetId ?? entry.milestoneId ?? "";
    lines.push(`| ${entry.orderLabel} | ${entry.phase} | ${item} | ${entry.dependsOn.join(", ") || "none"} |`);
  });

  lines.push(
    "",
    "The Results frame is recorded as `3b` because the v0.107 slice must cover Results framing, but it remains a companion to the HUD frame rather than a separate runtime UI kit approval."
  );
  return `${lines.join("\n")}\n`;
}

function renderAssetChecklist(manifest: SaltoSliceManifest): string {
  const lines = [
    "# v0.107 Salto Slice Asset Checklist",
    "",
    "Status: reference-only planning checklist. No candidate images are included.",
    "",
    "| Asset | Category | Status | Runtime posture | QA scenario |",
    "| --- | --- | --- | --- | --- |"
  ];
  manifest.assets.forEach((asset) => {
    lines.push(
      `| ${asset.assetId} | ${asset.category} | ${asset.status} | ${asset.runtimePosture} | ${asset.visualQaScenarioId} |`
    );
  });
  return `${lines.join("\n")}\n`;
}

function renderPromptReferenceIndex(manifest: SaltoSliceManifest, registry: VisualAssetRegistry): string {
  const registryById = new Map(registry.assets.map((asset) => [asset.assetId, asset]));
  const lines = [
    "# v0.107 Prompt Reference Index",
    "",
    "Status: prompt-reference index only. Paste final prompt text into a candidate workspace only after human approval.",
    "",
    "| v0.107 asset | Registry reference | Prompt template | Negative prompt |",
    "| --- | --- | --- | --- |"
  ];

  manifest.assets.forEach((asset) => {
    asset.registryAssetIds.forEach((registryAssetId) => {
      const registryAsset = registryById.get(registryAssetId);
      lines.push(
        `| ${asset.assetId} | ${registryAssetId} | ${registryAsset?.promptTemplateReference ?? "missing"} | ${
          registryAsset?.negativePromptReference ?? "missing"
        } |`
      );
    });
  });

  return `${lines.join("\n")}\n`;
}

function renderHumanReviewChecklist(manifest: SaltoSliceManifest): string {
  const lines = [
    "# v0.107 Human Review Checklist",
    "",
    "Status: Emmanuel review checklist only. Approval is reference-only unless a later runtime gate is explicitly opened."
  ];

  manifest.assets.forEach((asset) => {
    lines.push("", `## ${asset.assetId}`, "");
    asset.humanApprovalQuestions.forEach((question) => lines.push(`- [ ] ${question}`));
    lines.push(`- [ ] Fallback remains owned by ${asset.fallbackBehavior.owner}.`);
    lines.push("- [ ] Candidate remains reference-only:not-runtime.");
  });

  return `${lines.join("\n")}\n`;
}

function stableJson(value: unknown): string {
  return JSON.stringify(value, null, 2);
}

async function readJsonFile<T>(filePath: string): Promise<T> {
  return JSON.parse(await readFile(filePath, "utf8")) as T;
}

function addError(errors: SaltoSliceValidationIssue[], pathName: string, message: string): void {
  errors.push({ path: pathName, message });
}

function assertInside(parent: string, child: string): void {
  const relativePath = path.relative(path.resolve(parent), path.resolve(child));
  if (relativePath.startsWith("..") || relativePath === "" || relativePath.includes(`..${path.sep}`)) {
    throw new Error(`Refusing to write Salto slice packet outside ${parent}: ${child}`);
  }
}

function normalizePath(value: string): string {
  return value.replaceAll("\\", "/");
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
