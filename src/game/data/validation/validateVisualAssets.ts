import {
  VISUAL_ASSET_CATEGORIES,
  VISUAL_ASSET_LICENSE_STATUSES,
  VISUAL_ASSET_REPLACEMENT_PRIORITIES,
  VISUAL_ASSET_REVIEW_RATINGS,
  VISUAL_ASSET_SCALE_CLASSES,
  VISUAL_ASSET_SOURCE_TYPES,
  VISUAL_ASSET_STATUSES,
  VISUAL_ASSET_USAGES,
  type VisualAssetManifestEntry
} from "../../assets/VisualAssetManifestTypes";
import { VISUAL_ASSET_MANIFEST } from "../../assets/visualAssetManifest";
import { assertUniqueIds } from "./ValidationTypes";

export interface VisualAssetValidationOptions {
  fileExists?: (filePath: string) => boolean;
}

export function validateVisualAssetManifest(
  errors: string[],
  options: VisualAssetValidationOptions = {}
): void {
  if (VISUAL_ASSET_MANIFEST.version !== 1) {
    errors.push(`Visual asset manifest has unsupported version ${VISUAL_ASSET_MANIFEST.version}.`);
  }
  if (!VISUAL_ASSET_MANIFEST.updatedAt.trim() || !VISUAL_ASSET_MANIFEST.notes.trim()) {
    errors.push("Visual asset manifest needs updatedAt and notes.");
  }
  if (VISUAL_ASSET_MANIFEST.assets.length === 0) {
    errors.push("Visual asset manifest must include at least one asset.");
  }

  assertUniqueIds(VISUAL_ASSET_MANIFEST.assets, "visual asset", errors);
  VISUAL_ASSET_MANIFEST.assets.forEach((asset) => validateVisualAsset(asset, errors, options));
}

function validateVisualAsset(
  asset: VisualAssetManifestEntry,
  errors: string[],
  options: VisualAssetValidationOptions
): void {
  const label = `Visual asset ${asset.id}`;

  if (!asset.id.trim() || !asset.displayName.trim() || !asset.filePath.trim()) {
    errors.push(`${label} needs id, displayName, and filePath.`);
  }
  if (!asset.notes.trim()) {
    errors.push(`${label} needs notes.`);
  }
  if (!asset.visualFamily.trim()) {
    errors.push(`${label} needs visualFamily.`);
  }
  if (!VISUAL_ASSET_CATEGORIES.includes(asset.category)) {
    errors.push(`${label} has invalid category ${asset.category}.`);
  }
  if (!VISUAL_ASSET_STATUSES.includes(asset.currentStatus)) {
    errors.push(`${label} has invalid currentStatus ${asset.currentStatus}.`);
  }
  if (!VISUAL_ASSET_SOURCE_TYPES.includes(asset.sourceType)) {
    errors.push(`${label} has invalid sourceType ${asset.sourceType}.`);
  }
  if (!VISUAL_ASSET_LICENSE_STATUSES.includes(asset.licenseStatus)) {
    errors.push(`${label} has invalid licenseStatus ${asset.licenseStatus}.`);
  }
  if (!VISUAL_ASSET_USAGES.includes(asset.usage)) {
    errors.push(`${label} has invalid usage ${asset.usage}.`);
  }
  if (!VISUAL_ASSET_SCALE_CLASSES.includes(asset.scaleClass)) {
    errors.push(`${label} has invalid scaleClass ${asset.scaleClass}.`);
  }
  if (!VISUAL_ASSET_REVIEW_RATINGS.includes(asset.silhouetteReadability)) {
    errors.push(`${label} has invalid silhouetteReadability ${asset.silhouetteReadability}.`);
  }
  if (!VISUAL_ASSET_REVIEW_RATINGS.includes(asset.styleConsistency)) {
    errors.push(`${label} has invalid styleConsistency ${asset.styleConsistency}.`);
  }
  if (!VISUAL_ASSET_REPLACEMENT_PRIORITIES.includes(asset.replacementPriority)) {
    errors.push(`${label} has invalid replacementPriority ${asset.replacementPriority}.`);
  }
  if (typeof asset.allowedInProduction !== "boolean") {
    errors.push(`${label} allowedInProduction must be boolean.`);
  }
  if (typeof asset.needsReview !== "boolean") {
    errors.push(`${label} needsReview must be boolean.`);
  }
  if (asset.usage === "runtime" && asset.usedBy.length === 0) {
    errors.push(`${label} runtime usage must include at least one usedBy reference.`);
  }
  if (asset.usedBy.some((reference) => !reference.trim())) {
    errors.push(`${label} has an empty usedBy reference.`);
  }
  if (asset.usage === "runtime" && (asset.licenseStatus === "reference-only" || asset.licenseStatus === "do-not-ship")) {
    errors.push(`${label} runtime asset cannot use licenseStatus ${asset.licenseStatus}.`);
  }
  if (asset.usage === "runtime" && asset.licenseStatus === "unknown" && !asset.needsReview) {
    errors.push(`${label} runtime asset with unknown license must set needsReview true.`);
  }
  if (asset.currentStatus === "final" && (asset.sourceType === "unknown" || asset.licenseStatus === "unknown")) {
    errors.push(`${label} final asset cannot have unknown source or license.`);
  }
  if (asset.allowedInProduction && (asset.licenseStatus === "reference-only" || asset.licenseStatus === "do-not-ship")) {
    errors.push(`${label} cannot be allowed in production with licenseStatus ${asset.licenseStatus}.`);
  }
  if (asset.allowedInProduction && (asset.sourceType === "unknown" || asset.licenseStatus === "unknown")) {
    errors.push(`${label} cannot be allowed in production with unknown source or license.`);
  }
  if (asset.currentStatus === "deprecated" && asset.usage === "runtime") {
    errors.push(`${label} deprecated asset must not be used by runtime.`);
  }
  if (asset.intendedWorldHeightPx !== undefined && (!Number.isFinite(asset.intendedWorldHeightPx) || asset.intendedWorldHeightPx <= 0)) {
    errors.push(`${label} intendedWorldHeightPx must be positive when present.`);
  }
  if (asset.currentRenderHeightPx !== undefined && (!Number.isFinite(asset.currentRenderHeightPx) || asset.currentRenderHeightPx <= 0)) {
    errors.push(`${label} currentRenderHeightPx must be positive when present.`);
  }
  if (asset.usage === "runtime" && shouldCheckRuntimeFile(asset.filePath) && options.fileExists && !options.fileExists(asset.filePath)) {
    errors.push(`${label} runtime filePath does not exist: ${asset.filePath}`);
  }
}

function shouldCheckRuntimeFile(filePath: string): boolean {
  return !filePath.startsWith("procedural:");
}

