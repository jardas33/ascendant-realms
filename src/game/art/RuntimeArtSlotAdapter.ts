import { EXPECTED_RUNTIME_ART_SLOT_IDS, RUNTIME_ART_SLOTS, V0105_VISUAL_REGISTRY_ASSET_IDS } from "./RuntimeArtSlots";
import { RUNTIME_ART_SLOT_GROUPS, type RuntimeArtSlotDefinition, type RuntimeArtSlotResolution, type RuntimeArtSlotValidationResult } from "./RuntimeArtSlotTypes";

const ALLOWED_RUNTIME_ART_EXTENSIONS = [".avif", ".jpeg", ".jpg", ".png", ".svg", ".webp"] as const;
const ALLOWED_RUNTIME_PATH_PREFIXES = ["public/assets/runtime-art/", "/assets/runtime-art/", "assets/runtime-art/"] as const;
const FORBIDDEN_RUNTIME_PATH_PARTS = [
  "artifacts/art-review/candidates/",
  "artifacts/art-review/contact-sheets/",
  "artifacts/art-review/reports/",
  "public/assets/final/",
  "/assets/final/",
  "src/game/art/visual-asset-registry"
] as const;

export interface RuntimeArtSlotResolveOptions {
  slots?: readonly RuntimeArtSlotDefinition[];
  privateToolsEnabled?: boolean;
  privateMockMode?: boolean;
  fileExists?: (path: string) => boolean;
}

export interface RuntimeArtSlotValidationOptions {
  slots?: readonly RuntimeArtSlotDefinition[];
  fileExists?: (path: string) => boolean;
}

export function resolveRuntimeArtSlot(slotId: string, options: RuntimeArtSlotResolveOptions = {}): RuntimeArtSlotResolution {
  const slots = options.slots ?? RUNTIME_ART_SLOTS;
  const slot = slots.find((entry) => entry.slotId === slotId);
  if (!slot) {
    throw new Error(`Unknown runtime art slot: ${slotId}.`);
  }

  if (options.privateToolsEnabled && options.privateMockMode) {
    return {
      slotId: slot.slotId,
      group: slot.group,
      source: "mock",
      shouldLoadAsset: false,
      fallback: slot.fallback,
      diagnostics: "private mock routing",
      reason: "Private mock mode routes the slot through generated diagnostic styling only.",
      mockStyleToken: `runtime-art-mock-${slot.group}`
    };
  }

  const approvedAsset = slot.approvedAsset;
  if (approvedAsset && isRuntimeAssetLoadable(slot, options.fileExists)) {
    return {
      slotId: slot.slotId,
      group: slot.group,
      source: "runtime-asset",
      shouldLoadAsset: true,
      fallback: slot.fallback,
      assetPath: approvedAsset.path,
      diagnostics: "runtime-integrated",
      reason: `Runtime-integrated asset ${approvedAsset.assetId} passed the v0.106 slot gate.`
    };
  }

  return {
    slotId: slot.slotId,
    group: slot.group,
    source: "fallback",
    shouldLoadAsset: false,
    fallback: slot.fallback,
    diagnostics: "placeholder fallback",
    reason: approvedAsset
      ? `Asset ${approvedAsset.assetId} is not runtime-loadable in review state ${approvedAsset.reviewState}.`
      : "No runtime-integrated asset is assigned to this slot."
  };
}

export function resolveRuntimeArtSlots(options: RuntimeArtSlotResolveOptions = {}): RuntimeArtSlotResolution[] {
  return (options.slots ?? RUNTIME_ART_SLOTS).map((slot) => resolveRuntimeArtSlot(slot.slotId, options));
}

export function isRuntimeAssetLoadable(slot: RuntimeArtSlotDefinition, fileExists?: (path: string) => boolean): boolean {
  const asset = slot.approvedAsset;
  if (!asset || asset.reviewState !== "runtime-integrated") {
    return false;
  }
  if (!isAllowedRuntimeAssetPath(asset.path)) {
    return false;
  }
  return fileExists ? fileExists(asset.path) : true;
}

export function isAllowedRuntimeAssetPath(assetPath: string): boolean {
  const normalized = normalizeRuntimeAssetPath(assetPath);
  const hasAllowedPrefix = ALLOWED_RUNTIME_PATH_PREFIXES.some((prefix) => normalized.startsWith(prefix));
  const hasAllowedExtension = ALLOWED_RUNTIME_ART_EXTENSIONS.some((extension) => normalized.endsWith(extension));
  const hasForbiddenPart = FORBIDDEN_RUNTIME_PATH_PARTS.some((part) => normalized.includes(part));
  return hasAllowedPrefix && hasAllowedExtension && !hasForbiddenPart;
}

export function validateRuntimeArtSlots(options: RuntimeArtSlotValidationOptions = {}): RuntimeArtSlotValidationResult {
  const slots = options.slots ?? RUNTIME_ART_SLOTS;
  const result: RuntimeArtSlotValidationResult = {
    slotCount: slots.length,
    checks: [],
    errors: [],
    warnings: []
  };

  const seen = new Set<string>();
  const registryAssetIds = new Set<string>(V0105_VISUAL_REGISTRY_ASSET_IDS);
  const groupIds = new Set<string>(RUNTIME_ART_SLOT_GROUPS);
  const actualSlotIds = slots.map((slot) => slot.slotId);
  const enforceFullContract = !options.slots;

  if (!enforceFullContract) {
    result.checks.push(`custom slot fixture validated: ${actualSlotIds.length} slot(s)`);
  } else if (actualSlotIds.join("|") === EXPECTED_RUNTIME_ART_SLOT_IDS.join("|")) {
    result.checks.push(`stable slot order preserved: ${EXPECTED_RUNTIME_ART_SLOT_IDS.length} slots`);
  } else {
    addError(result, "slots", "Runtime art slot IDs must match the v0.106 stable slot contract in order.");
  }

  for (const slot of slots) {
    if (!slot.slotId.match(/^[a-z0-9]+(?:-[a-z0-9]+)*$/u)) {
      addError(result, `slots.${slot.slotId}.slotId`, `Runtime art slot ID ${slot.slotId} must be kebab-case.`, slot.slotId);
    }
    if (seen.has(slot.slotId)) {
      addError(result, `slots.${slot.slotId}.slotId`, `Duplicate runtime art slot ID: ${slot.slotId}.`, slot.slotId);
    }
    seen.add(slot.slotId);

    if (!groupIds.has(slot.group)) {
      addError(result, `slots.${slot.slotId}.group`, `Runtime art slot ${slot.slotId} uses unknown group ${slot.group}.`, slot.slotId);
    }
    if (!slot.label.trim() || !slot.runtimeSurface.trim()) {
      addError(result, `slots.${slot.slotId}`, "Runtime art slot must define label and runtimeSurface.", slot.slotId);
    }
    if (!slot.fallback.description.trim() || !slot.fallback.owner.trim() || !slot.fallback.proofSurface.trim()) {
      addError(result, `slots.${slot.slotId}.fallback`, "Runtime art slot must define a concrete placeholder fallback owner, proof surface, and description.", slot.slotId);
    }
    if (slot.publicDiagnosticsAllowed === true) {
      addError(result, `slots.${slot.slotId}.publicDiagnosticsAllowed`, "Runtime art slot diagnostics must not be public.", slot.slotId);
    }
    if (!slot.registryMapping.notes.trim()) {
      addError(result, `slots.${slot.slotId}.registryMapping`, "Runtime art slot must explain its v0.105 registry mapping posture.", slot.slotId);
    }
    for (const assetId of slot.registryMapping.referenceAssetIds) {
      if (!registryAssetIds.has(assetId)) {
        addError(result, `slots.${slot.slotId}.registryMapping.referenceAssetIds`, `Unknown v0.105 visual registry asset ID: ${assetId}.`, slot.slotId);
      }
    }

    validateApprovedAsset(slot, result, options.fileExists);
  }

  if (result.errors.length === 0) {
    result.checks.push("all slots resolve to fallback, private mock, or runtime-integrated asset without throwing");
    result.checks.push("runtime-candidate-approved and unapproved assets remain non-loadable");
    result.checks.push("candidate-review workspaces and public/assets/final are blocked as runtime slot paths");
  }

  return result;
}

function validateApprovedAsset(
  slot: RuntimeArtSlotDefinition,
  result: RuntimeArtSlotValidationResult,
  fileExists?: (path: string) => boolean
): void {
  const asset = slot.approvedAsset;
  if (!asset) {
    return;
  }
  if (!asset.assetId.trim()) {
    addError(result, `slots.${slot.slotId}.approvedAsset.assetId`, "Approved runtime asset must define assetId.", slot.slotId);
  }
  if (asset.reviewState !== "runtime-integrated") {
    addError(
      result,
      `slots.${slot.slotId}.approvedAsset.reviewState`,
      `Runtime art slot ${slot.slotId} cannot load asset ${asset.assetId} from review state ${asset.reviewState}; runtime-integrated is required.`,
      slot.slotId
    );
    return;
  }
  if (!isAllowedRuntimeAssetPath(asset.path)) {
    addError(
      result,
      `slots.${slot.slotId}.approvedAsset.path`,
      `Runtime art asset path ${asset.path} must live under public/assets/runtime-art with an approved image extension and must not bypass via candidate or final-art folders.`,
      slot.slotId
    );
  }
  if (fileExists && !fileExists(asset.path)) {
    addError(result, `slots.${slot.slotId}.approvedAsset.path`, `Runtime art asset path does not exist: ${asset.path}.`, slot.slotId);
  }
  if (!asset.proof.humanApprovalDoc.trim() || !asset.proof.validator.trim()) {
    addError(result, `slots.${slot.slotId}.approvedAsset.proof`, "Runtime-integrated assets must carry human approval and validator proof.", slot.slotId);
  }
}

function normalizeRuntimeAssetPath(assetPath: string): string {
  return assetPath.trim().replace(/\\/gu, "/").replace(/^\.\//u, "").toLowerCase();
}

function addError(result: RuntimeArtSlotValidationResult, path: string, message: string, slotId?: string): void {
  result.errors.push({ path, message, slotId });
}
