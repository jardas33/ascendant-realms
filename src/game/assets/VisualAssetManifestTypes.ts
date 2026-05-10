export const VISUAL_ASSET_CATEGORIES = [
  "hero-sprite",
  "unit-sprite",
  "building-sprite",
  "unit-concept",
  "building-concept",
  "portrait",
  "ability-icon",
  "resource-icon",
  "capture-site-icon",
  "faction-emblem",
  "ui-background",
  "ui-frame",
  "splash",
  "terrain",
  "vfx",
  "audio",
  "reference"
] as const;

export type VisualAssetCategory = (typeof VISUAL_ASSET_CATEGORIES)[number];

export const VISUAL_ASSET_STATUSES = [
  "placeholder",
  "prototype",
  "candidate",
  "final",
  "reference",
  "deprecated"
] as const;

export type VisualAssetStatus = (typeof VISUAL_ASSET_STATUSES)[number];

export const VISUAL_ASSET_SOURCE_TYPES = [
  "manual",
  "generated",
  "purchased",
  "original",
  "unknown",
  "external-reference"
] as const;

export type VisualAssetSourceType = (typeof VISUAL_ASSET_SOURCE_TYPES)[number];

export const VISUAL_ASSET_LICENSE_STATUSES = [
  "owned",
  "generated-review-needed",
  "licensed",
  "unknown",
  "reference-only",
  "do-not-ship"
] as const;

export type VisualAssetLicenseStatus = (typeof VISUAL_ASSET_LICENSE_STATUSES)[number];

export const VISUAL_ASSET_REVIEW_STATUSES = [
  "approved-for-prototype",
  "approved-for-production",
  "needs-source-proof",
  "generated-review-needed",
  "reference-only",
  "do-not-ship",
  "deprecated"
] as const;

export type VisualAssetReviewStatus = (typeof VISUAL_ASSET_REVIEW_STATUSES)[number];

export const VISUAL_ASSET_USAGES = [
  "runtime",
  "manual-reference",
  "docs-reference",
  "unused",
  "test-only"
] as const;

export type VisualAssetUsage = (typeof VISUAL_ASSET_USAGES)[number];

export const VISUAL_ASSET_SCALE_CLASSES = [
  "hero",
  "infantry",
  "ranged",
  "caster",
  "large-enemy",
  "enemy-commander",
  "small-monster",
  "building-small",
  "building-medium",
  "building-large",
  "capture-site",
  "ui",
  "portrait",
  "terrain",
  "audio",
  "reference",
  "unknown"
] as const;

export type VisualAssetScaleClass = (typeof VISUAL_ASSET_SCALE_CLASSES)[number];

export const VISUAL_ASSET_REVIEW_RATINGS = ["low", "medium", "high", "unknown"] as const;

export type VisualAssetReviewRating = (typeof VISUAL_ASSET_REVIEW_RATINGS)[number];

export const VISUAL_ASSET_REPLACEMENT_PRIORITIES = ["low", "medium", "high", "critical"] as const;

export type VisualAssetReplacementPriority = (typeof VISUAL_ASSET_REPLACEMENT_PRIORITIES)[number];

export interface VisualAssetManifestEntry {
  id: string;
  filePath: string;
  category: VisualAssetCategory;
  displayName: string;
  currentStatus: VisualAssetStatus;
  sourceType: VisualAssetSourceType;
  licenseStatus: VisualAssetLicenseStatus;
  reviewStatus: VisualAssetReviewStatus;
  usage: VisualAssetUsage;
  usedBy: string[];
  visualFamily: string;
  scaleClass: VisualAssetScaleClass;
  intendedWorldHeightPx?: number;
  currentRenderHeightPx?: number;
  silhouetteReadability: VisualAssetReviewRating;
  styleConsistency: VisualAssetReviewRating;
  replacementPriority: VisualAssetReplacementPriority;
  notes: string;
  sourceReviewNotes: string;
  allowedInProduction: boolean;
  needsReview: boolean;
  screenshotQaTargets?: string[];
}

export interface VisualAssetManifest {
  version: 1;
  updatedAt: string;
  notes: string;
  assets: VisualAssetManifestEntry[];
}
