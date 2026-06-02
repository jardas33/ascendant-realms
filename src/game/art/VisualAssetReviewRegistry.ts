export const VISUAL_ASSET_REVIEW_STATES = [
  "not-created",
  "candidate-ready",
  "style-approved",
  "revision-requested",
  "rejected",
  "runtime-candidate-approved",
  "runtime-integrated"
] as const;

export type VisualAssetReviewState = (typeof VISUAL_ASSET_REVIEW_STATES)[number];

export interface VisualAssetReviewWorkspace {
  candidateDirectory: string;
  contactSheetDirectory: string;
  reportDirectory: string;
}

export interface VisualAssetRegistryEntry {
  assetId: string;
  category: string;
  faction: string;
  runtimeSlot: string;
  conceptStage: string;
  reviewStatus: string;
  reviewState: VisualAssetReviewState;
  source: string;
  license: string;
  generatedBy: string;
  promptVersion: string;
  promptTemplateReference: string;
  negativePromptReference: string;
  visualConsistencyNotes: string;
  approvalStatus: string;
  integrationReadiness: string;
  sourceLicensePosture: string;
  protectedIpPosture: string;
  reviewWorkspace: VisualAssetReviewWorkspace;
  replacementHistory: string[];
}

export interface VisualAssetRegistry {
  schemaVersion: 1;
  checkpoint: string;
  status: string;
  createdAt: string;
  updatedAt: string;
  sourceManifest: string;
  generatedAssetsIncluded: boolean;
  runtimeIntegrationApproved: boolean;
  registryPurpose: string;
  fieldDefinitions: string[];
  reviewStates: VisualAssetReviewState[];
  assets: VisualAssetRegistryEntry[];
}

export interface V088AssetManifest {
  assets: Array<{ assetId?: unknown }>;
}

export interface ArtReviewIssue {
  path: string;
  message: string;
}

export interface ArtReviewValidationResult {
  errors: ArtReviewIssue[];
  warnings: ArtReviewIssue[];
}

export interface ArtReviewCandidateFile {
  filename: string;
  promptVersion?: string;
  reviewStatus?: string;
  notes?: string;
}

export interface ArtReviewCandidateMetadata {
  schemaVersion: 1;
  assetId: string;
  reviewState: VisualAssetReviewState;
  candidateFiles: ArtReviewCandidateFile[];
  source: {
    tool: string;
    model: string;
    generatedBy: string;
    generatedAtUtc: string;
    sourceType: string;
    notes: string;
  };
  license: {
    terms: string;
    usagePermission: string;
  };
  prompt: {
    promptVersion: string;
    promptReferencePath: string;
    negativePromptVersion: string;
  };
  protectedIp: {
    assessment: string;
    risk: "low" | "medium" | "high" | "unknown";
    notes: string;
  };
  humanReview: {
    reviewer: string;
    reviewedAtUtc: string;
    status: string;
    summary: string;
  };
  runtimeSlotPosture: {
    posture: string;
    integrationProof: string;
    integrationApprovedBy: string;
  };
  integrationReadiness: string;
  rejectionReason: string;
}

export interface PromptReferenceMetadata {
  schemaVersion: 1;
  assetId: string;
  promptVersion: string;
  promptTemplateReference: string;
  negativePromptVersion: string;
  reviewPurpose: string;
  approvedPromptText: string;
  promptNotes: string;
}

const REQUIRED_REGISTRY_ASSET_FIELDS: Array<keyof VisualAssetRegistryEntry> = [
  "assetId",
  "category",
  "faction",
  "runtimeSlot",
  "conceptStage",
  "reviewStatus",
  "reviewState",
  "source",
  "license",
  "generatedBy",
  "promptVersion",
  "promptTemplateReference",
  "negativePromptReference",
  "visualConsistencyNotes",
  "approvalStatus",
  "integrationReadiness",
  "sourceLicensePosture",
  "protectedIpPosture",
  "reviewWorkspace",
  "replacementHistory"
];

const REVIEW_STATES_REQUIRING_CANDIDATE_SOURCE = new Set<VisualAssetReviewState>([
  "candidate-ready",
  "style-approved",
  "revision-requested",
  "runtime-candidate-approved",
  "runtime-integrated"
]);

const REVIEW_STATES_REQUIRING_HUMAN_REVIEW = new Set<VisualAssetReviewState>([
  "style-approved",
  "revision-requested",
  "runtime-candidate-approved",
  "runtime-integrated"
]);

export function validateVisualAssetRegistryDocument(
  document: unknown,
  sourceManifest?: V088AssetManifest
): ArtReviewValidationResult {
  const result = emptyResult();
  if (!isRecord(document)) {
    addError(result, "registry", "Visual asset registry must be a JSON object.");
    return result;
  }

  if (document.schemaVersion !== 1) {
    addError(result, "schemaVersion", "Visual asset registry schemaVersion must be 1.");
  }
  if (readString(document, "status") !== "reference-registry-only") {
    addError(result, "status", "Visual asset registry status must remain reference-registry-only.");
  }
  if (document.generatedAssetsIncluded !== false) {
    addError(result, "generatedAssetsIncluded", "Visual asset registry must not include generated assets.");
  }
  if (document.runtimeIntegrationApproved !== false) {
    addError(result, "runtimeIntegrationApproved", "Visual asset registry must not approve runtime integration.");
  }
  if (readString(document, "sourceManifest") !== "docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json") {
    addError(result, "sourceManifest", "Visual asset registry must remain seeded from the v0.88 vertical-slice manifest.");
  }

  const reviewStates = document.reviewStates;
  if (!Array.isArray(reviewStates)) {
    addError(result, "reviewStates", "Visual asset registry must define reviewStates.");
  } else {
    const expected = VISUAL_ASSET_REVIEW_STATES.join("|");
    const actual = reviewStates.join("|");
    if (actual !== expected) {
      addError(result, "reviewStates", "Visual asset registry reviewStates must match the v0.105 state machine.");
    }
  }

  const assets = document.assets;
  if (!Array.isArray(assets)) {
    addError(result, "assets", "Visual asset registry must include an assets array.");
    return result;
  }
  if (assets.length === 0) {
    addError(result, "assets", "Visual asset registry must include at least one asset.");
  }

  const seen = new Set<string>();
  const assetIds: string[] = [];
  assets.forEach((asset, index) => {
    if (!isRecord(asset)) {
      addError(result, `assets[${index}]`, "Visual asset registry asset must be an object.");
      return;
    }
    const assetId = readString(asset, "assetId");
    assetIds.push(assetId);
    if (!assetId) {
      addError(result, `assets[${index}].assetId`, "Visual asset registry asset is missing assetId.");
    } else if (seen.has(assetId)) {
      addError(result, `assets[${index}].assetId`, `Duplicate visual asset registry assetId: ${assetId}.`);
    } else {
      seen.add(assetId);
    }
    validateRegistryEntry(asset, index, result);
  });

  const sortedAssetIds = [...assetIds].sort((left, right) => left.localeCompare(right));
  if (assetIds.join("|") !== sortedAssetIds.join("|")) {
    addError(result, "assets", "Visual asset registry assets must be sorted by assetId for deterministic review output.");
  }

  if (sourceManifest) {
    const manifestIds = sourceManifest.assets
      .map((asset) => (typeof asset.assetId === "string" ? asset.assetId : ""))
      .filter((assetId) => assetId.length > 0);
    manifestIds.forEach((assetId) => {
      if (!seen.has(assetId)) {
        addError(result, "assets", `Registry is missing v0.88 asset ID ${assetId}.`);
      }
    });
  }

  return result;
}

export function validateArtReviewCandidateMetadata(
  document: unknown,
  registry: VisualAssetRegistry
): ArtReviewValidationResult {
  const result = emptyResult();
  if (!isRecord(document)) {
    addError(result, "candidateMetadata", "Candidate metadata must be a JSON object.");
    return result;
  }

  if (document.schemaVersion !== 1) {
    addError(result, "schemaVersion", "Candidate metadata schemaVersion must be 1.");
  }

  const assetId = readString(document, "assetId");
  const asset = registry.assets.find((candidate) => candidate.assetId === assetId);
  if (!assetId) {
    addError(result, "assetId", "Candidate metadata is missing assetId.");
  } else if (!asset) {
    addError(result, "assetId", `Candidate metadata references unknown assetId ${assetId}.`);
  }

  const reviewState = readString(document, "reviewState");
  if (!isVisualAssetReviewState(reviewState)) {
    addError(result, "reviewState", `Candidate metadata has invalid reviewState ${reviewState || "<missing>"}.`);
  }

  const prompt = recordField(document, "prompt", result);
  if (prompt && !readString(prompt, "promptVersion")) {
    addError(result, "prompt.promptVersion", "Candidate metadata is missing prompt version.");
  }
  if (prompt && !readString(prompt, "promptReferencePath")) {
    addError(result, "prompt.promptReferencePath", "Candidate metadata is missing prompt reference path.");
  }

  const candidateFiles = document.candidateFiles;
  if (!Array.isArray(candidateFiles)) {
    addError(result, "candidateFiles", "Candidate metadata candidateFiles must be an array.");
  } else {
    candidateFiles.forEach((candidate, index) => {
      if (!isRecord(candidate)) {
        addError(result, `candidateFiles[${index}]`, "Candidate file entry must be an object.");
        return;
      }
      if (!readString(candidate, "filename")) {
        addError(result, `candidateFiles[${index}].filename`, "Candidate file entry is missing filename.");
      }
    });
  }

  if (isVisualAssetReviewState(reviewState)) {
    validateReviewStateProgression(document, reviewState, candidateFiles, result);
  }

  if (asset && isVisualAssetReviewState(reviewState) && reviewState !== "runtime-candidate-approved" && reviewState !== "runtime-integrated") {
    const runtimeSlotPosture = recordField(document, "runtimeSlotPosture", result);
    const posture = runtimeSlotPosture ? readString(runtimeSlotPosture, "posture") : "";
    if (!posture.includes("not-runtime")) {
      addError(
        result,
        "runtimeSlotPosture.posture",
        `${reviewState} candidates must remain not-runtime until a future runtime integration gate.`
      );
    }
  }

  return result;
}

export function validatePromptReferenceMetadata(
  document: unknown,
  asset: VisualAssetRegistryEntry
): ArtReviewValidationResult {
  const result = emptyResult();
  if (!isRecord(document)) {
    addError(result, "promptReference", "Prompt reference must be a JSON object.");
    return result;
  }
  if (document.schemaVersion !== 1) {
    addError(result, "promptReference.schemaVersion", "Prompt reference schemaVersion must be 1.");
  }
  if (readString(document, "assetId") !== asset.assetId) {
    addError(result, "promptReference.assetId", `Prompt reference must use assetId ${asset.assetId}.`);
  }
  if (!readString(document, "promptVersion")) {
    addError(result, "promptReference.promptVersion", "Prompt reference is missing promptVersion.");
  }
  if (!readString(document, "promptTemplateReference")) {
    addError(result, "promptReference.promptTemplateReference", "Prompt reference is missing promptTemplateReference.");
  }
  if (!readString(document, "negativePromptVersion")) {
    addError(result, "promptReference.negativePromptVersion", "Prompt reference is missing negativePromptVersion.");
  }
  if (readString(document, "reviewPurpose") !== "reference-only:not-runtime") {
    addError(result, "promptReference.reviewPurpose", "Prompt reference must remain reference-only:not-runtime.");
  }
  return result;
}

export function createCandidateMetadataTemplate(asset: VisualAssetRegistryEntry): ArtReviewCandidateMetadata {
  return {
    schemaVersion: 1,
    assetId: asset.assetId,
    reviewState: "not-created",
    candidateFiles: [],
    source: {
      tool: "",
      model: "",
      generatedBy: "",
      generatedAtUtc: "",
      sourceType: "not-created",
      notes: "Fill only after a manually created/generated candidate exists outside runtime."
    },
    license: {
      terms: "not-applicable-uncreated",
      usagePermission: "reference-only:not-runtime"
    },
    prompt: {
      promptVersion: asset.promptVersion,
      promptReferencePath: "prompt-reference.json",
      negativePromptVersion: "v088-negative-base"
    },
    protectedIp: {
      assessment: "not-assessed-uncreated",
      risk: "unknown",
      notes: "Review before candidate-ready or any approval state."
    },
    humanReview: {
      reviewer: "",
      reviewedAtUtc: "",
      status: "not-reviewed",
      summary: ""
    },
    runtimeSlotPosture: {
      posture: "reference-only:not-runtime",
      integrationProof: "",
      integrationApprovedBy: ""
    },
    integrationReadiness: "not-ready-reference-only",
    rejectionReason: ""
  };
}

export function createPromptReferenceTemplate(asset: VisualAssetRegistryEntry): PromptReferenceMetadata {
  return {
    schemaVersion: 1,
    assetId: asset.assetId,
    promptVersion: asset.promptVersion,
    promptTemplateReference: asset.promptTemplateReference,
    negativePromptVersion: "v088-negative-base",
    reviewPurpose: "reference-only:not-runtime",
    approvedPromptText: "",
    promptNotes: "Paste the final approved prompt text here before creating a candidate."
  };
}

export function createReviewerChecklist(asset: VisualAssetRegistryEntry): string {
  return [
    `# ${asset.assetId} Reviewer Checklist`,
    "",
    "Status: reference-only review workspace. Do not import candidates into runtime folders.",
    "",
    "## Required Before candidate-ready",
    "",
    "- Candidate files are manually placed in this workspace only.",
    "- Source tool, model, generated-by, and source notes are recorded.",
    "- License terms and usage permission are clear.",
    "- Prompt version and prompt reference are recorded.",
    "- Protected-IP assessment is written and does not rely on protected style imitation.",
    "",
    "## Emmanuel Style Review",
    "",
    "- Silhouette reads at thumbnail scale.",
    "- Faction/role matches the approved v0.88 brief.",
    "- Camera and aspect ratio match the prompt packet.",
    "- Image avoids text artifacts, watermarks, copied symbols, and mobile UI drift.",
    "- Approval is reference-only unless a future runtime gate is opened.",
    "",
    "## Runtime Gate",
    "",
    "- `style-approved` still means not-runtime.",
    "- `runtime-candidate-approved` requires a future integration milestone.",
    "- `runtime-integrated` is invalid without separate integration proof."
  ].join("\n");
}

export function isVisualAssetReviewState(value: string): value is VisualAssetReviewState {
  return VISUAL_ASSET_REVIEW_STATES.includes(value as VisualAssetReviewState);
}

export function findVisualAsset(registry: VisualAssetRegistry, assetId: string): VisualAssetRegistryEntry | undefined {
  return registry.assets.find((asset) => asset.assetId === assetId);
}

export function createEmptyArtReviewValidationResult(): ArtReviewValidationResult {
  return emptyResult();
}

export function mergeArtReviewValidationResults(target: ArtReviewValidationResult, source: ArtReviewValidationResult): void {
  target.errors.push(...source.errors);
  target.warnings.push(...source.warnings);
}

function validateRegistryEntry(asset: Record<string, unknown>, index: number, result: ArtReviewValidationResult): void {
  for (const fieldName of REQUIRED_REGISTRY_ASSET_FIELDS) {
    if (!(fieldName in asset)) {
      addError(result, `assets[${index}].${fieldName}`, `Visual asset registry entry is missing ${fieldName}.`);
    }
  }

  const label = readString(asset, "assetId") || `assets[${index}]`;
  for (const fieldName of REQUIRED_REGISTRY_ASSET_FIELDS) {
    if (fieldName === "reviewWorkspace" || fieldName === "replacementHistory") {
      continue;
    }
    if (!readString(asset, fieldName)) {
      addError(result, `${label}.${fieldName}`, `Visual asset registry entry needs ${fieldName}.`);
    }
  }

  const reviewState = readString(asset, "reviewState");
  if (!isVisualAssetReviewState(reviewState)) {
    addError(result, `${label}.reviewState`, `Invalid review state ${reviewState || "<missing>"}.`);
  }
  if (!readString(asset, "runtimeSlot").includes("not-runtime")) {
    addError(result, `${label}.runtimeSlot`, "Registry runtimeSlot must remain not-runtime.");
  }
  if (!readString(asset, "integrationReadiness").includes("not-ready")) {
    addError(result, `${label}.integrationReadiness`, "Registry entries must start as not-ready reference-only assets.");
  }
  if (!Array.isArray(asset.replacementHistory)) {
    addError(result, `${label}.replacementHistory`, "Registry replacementHistory must be an array.");
  }

  const reviewWorkspace = asset.reviewWorkspace;
  if (!isRecord(reviewWorkspace)) {
    addError(result, `${label}.reviewWorkspace`, "Registry reviewWorkspace must be an object.");
  } else {
    for (const fieldName of ["candidateDirectory", "contactSheetDirectory", "reportDirectory"] as const) {
      const value = readString(reviewWorkspace, fieldName);
      if (!value.startsWith("artifacts/art-review/")) {
        addError(result, `${label}.reviewWorkspace.${fieldName}`, "Review workspace paths must stay under artifacts/art-review.");
      }
      if (value.includes("public/assets") || value.includes("src/game/assets")) {
        addError(result, `${label}.reviewWorkspace.${fieldName}`, "Review workspace paths must not touch runtime asset paths.");
      }
    }
  }
}

function validateReviewStateProgression(
  document: Record<string, unknown>,
  reviewState: VisualAssetReviewState,
  candidateFiles: unknown,
  result: ArtReviewValidationResult
): void {
  const source = recordField(document, "source", result);
  const license = recordField(document, "license", result);
  const protectedIp = recordField(document, "protectedIp", result);
  const humanReview = recordField(document, "humanReview", result);
  const runtimeSlotPosture = recordField(document, "runtimeSlotPosture", result);

  if (REVIEW_STATES_REQUIRING_CANDIDATE_SOURCE.has(reviewState)) {
    if (Array.isArray(candidateFiles) && candidateFiles.length === 0) {
      addError(result, "candidateFiles", `${reviewState} candidates must list at least one candidate file.`);
    }
    if (source) {
      for (const fieldName of ["tool", "model", "generatedBy", "sourceType"] as const) {
        if (!readString(source, fieldName)) {
          addError(result, `source.${fieldName}`, `${reviewState} candidates must record source ${fieldName}.`);
        }
      }
    }
    if (license) {
      const licenseTerms = readString(license, "terms").toLowerCase();
      if (!licenseTerms || licenseTerms === "unknown" || licenseTerms === "unclear" || licenseTerms === "tbd") {
        addError(result, "license.terms", `${reviewState} candidates must have clear license terms.`);
      }
      if (readString(license, "usagePermission") !== "reference-only:not-runtime" && reviewState !== "runtime-candidate-approved") {
        addError(result, "license.usagePermission", `${reviewState} candidates must stay reference-only:not-runtime.`);
      }
    }
    if (protectedIp) {
      const assessment = readString(protectedIp, "assessment").toLowerCase();
      if (!assessment || assessment === "unknown" || assessment.startsWith("not-assessed")) {
        addError(result, "protectedIp.assessment", `${reviewState} candidates must include a protected-IP assessment.`);
      }
      const risk = readString(protectedIp, "risk");
      if (risk === "unknown" || risk === "high") {
        addError(result, "protectedIp.risk", `${reviewState} candidates cannot carry unknown or high protected-IP risk.`);
      }
    }
  }

  if (REVIEW_STATES_REQUIRING_HUMAN_REVIEW.has(reviewState) && humanReview) {
    if (!readString(humanReview, "reviewer")) {
      addError(result, "humanReview.reviewer", `${reviewState} candidates must name a human reviewer.`);
    }
    if (!readString(humanReview, "status")) {
      addError(result, "humanReview.status", `${reviewState} candidates must record human review status.`);
    }
  }

  if (reviewState === "style-approved" && runtimeSlotPosture) {
    if (readString(runtimeSlotPosture, "posture") !== "reference-only:not-runtime") {
      addError(result, "runtimeSlotPosture.posture", "style-approved remains reference-only and must not be marked runtime-ready.");
    }
  }

  if (reviewState === "runtime-candidate-approved") {
    if (runtimeSlotPosture && readString(runtimeSlotPosture, "posture") !== "future-runtime-candidate:not-integrated") {
      addError(
        result,
        "runtimeSlotPosture.posture",
        "runtime-candidate-approved requires future-runtime-candidate:not-integrated posture."
      );
    }
    if (readString(document, "integrationReadiness") !== "ready-for-future-runtime-integration-gate") {
      addError(
        result,
        "integrationReadiness",
        "runtime-candidate-approved must wait for a future runtime integration gate."
      );
    }
  }

  if (reviewState === "runtime-integrated" && runtimeSlotPosture) {
    if (!readString(runtimeSlotPosture, "integrationProof")) {
      addError(result, "runtimeSlotPosture.integrationProof", "runtime-integrated requires future integration proof.");
    }
    if (!readString(runtimeSlotPosture, "integrationApprovedBy")) {
      addError(result, "runtimeSlotPosture.integrationApprovedBy", "runtime-integrated requires future integration approval.");
    }
    if (readString(document, "integrationReadiness") !== "integrated-by-future-runtime-gate") {
      addError(
        result,
        "integrationReadiness",
        "runtime-integrated requires integrated-by-future-runtime-gate readiness."
      );
    }
  }

  if (reviewState === "rejected" && !readString(document, "rejectionReason")) {
    addError(result, "rejectionReason", "Rejected candidates must include a rejectionReason.");
  }
}

function emptyResult(): ArtReviewValidationResult {
  return { errors: [], warnings: [] };
}

function addError(result: ArtReviewValidationResult, path: string, message: string): void {
  result.errors.push({ path, message });
}

function readString(record: Record<string, unknown>, key: string): string {
  const value = record[key];
  return typeof value === "string" ? value.trim() : "";
}

function recordField(
  record: Record<string, unknown>,
  key: string,
  result: ArtReviewValidationResult
): Record<string, unknown> | undefined {
  const value = record[key];
  if (!isRecord(value)) {
    addError(result, key, `Candidate metadata ${key} must be an object.`);
    return undefined;
  }
  return value;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
