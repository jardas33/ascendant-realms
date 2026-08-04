/**
 * Presentation-only layout contracts for battlefield entities.
 *
 * This module deliberately contains no gameplay geometry or simulation data.
 * The owning entity continues to provide radius, footprint, position and all
 * other gameplay values when it applies these legacy-equivalent multipliers.
 */

export type PresentationFamily = "unit" | "hero" | "building";

import type {
  VisualAssetBuildingPresentationMetadata,
  VisualAssetPresentationMetadata
} from "../assets/VisualAssetManifestTypes";

export type ContentAwareHumanoidAssetId =
  | "warlord_hero_battle_sprite"
  | "militia_unit_sprite"
  | "ranger_unit_sprite";

export interface UnitContentAwareVisualLayout {
  readonly originX: number;
  readonly originY: number;
  readonly spriteY: 0;
  readonly shadowY: 0;
  readonly scale: number;
  readonly targetContentHeight: number;
  readonly visualTop: number;
  readonly visualBottom: number;
}

export interface BuildingContentAwareVisualLayout {
  readonly originX: number;
  readonly originY: number;
  readonly spriteY: 0;
  readonly shadowY: 0;
  readonly scale: number;
  readonly contentWidth: number;
  readonly contentHeight: number;
  readonly visualTop: number;
  readonly visualBottom: number;
}

export interface CommonPresentationDefaults {
  readonly selection: {
    readonly radiusAddPx: number;
    readonly widthRadiusMultiplier: number;
    readonly heightRadiusMultiplier: number;
    readonly minHeightPx: number;
  };
  readonly health: {
    readonly minWidthPx: number;
    readonly widthRadiusMultiplier: number;
    readonly heightPx: number;
    readonly topOffsetPx: number;
  };
  readonly label: {
    readonly radiusOffsetPx: number;
  };
  readonly depth: {
    readonly building: number;
    readonly nonBuilding: number;
  };
}

export interface UnitPresentationConfig {
  readonly schemaVersion: 1;
  readonly family: "unit" | "hero";
  readonly sprite: {
    readonly yRadiusMultiplier: number;
    readonly originY: number;
    readonly targetHeightRadiusMultiplier: number;
  };
  readonly shadow: {
    readonly yRadiusMultiplier: number;
    readonly widthRadiusMultiplier: number;
    readonly heightRadiusMultiplier: number;
    readonly opacity: number;
  };
  readonly fallback: {
    readonly visualTopRadiusMultiplier: number;
    readonly visualBottomRadiusMultiplier: number;
  };
  readonly layout: {
    readonly healthTopOffsetPx: number;
    readonly healthWidthPx: number;
    readonly healthHeightPx: number;
    readonly labelBottomOffsetPx: number;
    readonly selectionRadiusMinPx: number;
    readonly selectionRadiusAddPx: number;
    readonly selectionWidthRadiusMultiplier: number;
    readonly selectionHeightRadiusMultiplier: number;
    readonly selectionHeightMinPx: number;
    readonly selectionYOffsetPx: number;
  };
  readonly depth: {
    readonly mode: "fixed-type-legacy";
    readonly fixedDepth: number;
    readonly active: false;
  };
  readonly inactiveFuture: {
    readonly alphaBoundsPopulated: false;
    readonly feetAnchorPopulated: false;
    readonly targetContentHeightPopulated: false;
    readonly perAssetOverridesActive: false;
    readonly yDepthPolicyActive: false;
    readonly restrictedDepthBandActive: false;
  };
}

export interface BuildingPresentationConfig {
  readonly schemaVersion: 1;
  readonly family: "building";
  readonly sprite: {
    readonly originY: number;
    readonly maxWidthSizeMultiplier: number;
    readonly maxHeightSizeMultiplier: number;
  };
  readonly shadow: {
    readonly ySizeHeightMultiplier: number;
    readonly widthSizeMultiplier: number;
    readonly heightSizeMultiplier: number;
    readonly opacity: number;
  };
  readonly fallback: {
    readonly visualTopSizeMultiplier: number;
    readonly visualBottomSizeMultiplier: number;
  };
  readonly layout: {
    readonly healthTopOffsetPx: number;
    readonly healthMinWidthPx: number;
    readonly healthWidthSizeMultiplier: number;
    readonly healthHeightPx: number;
    readonly labelBottomOffsetPx: number;
    readonly selectionRadiusAddPx: number;
    readonly selectionRadiusSizeMultiplier: number;
    readonly selectionWidthSizeMultiplier: number;
    readonly selectionWidthRadiusMultiplier: number;
    readonly selectionMinHeightPx: number;
    readonly selectionHeightSizeMultiplier: number;
    readonly selectionYOffsetPx: number;
  };
  readonly depth: {
    readonly mode: "fixed-type-legacy";
    readonly fixedDepth: 5;
    readonly active: false;
  };
  readonly inactiveFuture: {
    readonly alphaBoundsPopulated: false;
    readonly feetAnchorPopulated: false;
    readonly targetContentHeightPopulated: false;
    readonly perAssetOverridesActive: false;
    readonly yDepthPolicyActive: false;
    readonly restrictedDepthBandActive: false;
  };
}

export type EntityPresentationConfig = UnitPresentationConfig | BuildingPresentationConfig;

const COMMON_PRESENTATION_DEFAULTS: CommonPresentationDefaults = {
  selection: {
    radiusAddPx: 7,
    widthRadiusMultiplier: 2.1,
    heightRadiusMultiplier: 0.62,
    minHeightPx: 8
  },
  health: {
    minWidthPx: 34,
    widthRadiusMultiplier: 2.4,
    heightPx: 5,
    topOffsetPx: 13
  },
  label: {
    radiusOffsetPx: 11
  },
  depth: {
    building: 5,
    nonBuilding: 10
  }
};

const CONTENT_AWARE_HUMANOID_METADATA: Record<ContentAwareHumanoidAssetId, VisualAssetPresentationMetadata> = {
  warlord_hero_battle_sprite: {
    schemaVersion: 1,
    assetId: "warlord_hero_battle_sprite",
    sourceCanvas: { width: 512, height: 512 },
    alphaThreshold: 8,
    alphaContentBounds: { left: 0.1875, top: 0.0703125, right: 0.814453125, bottom: 0.9296875 },
    feetAnchor: { x: 0.5009765625, y: 0.9296875 },
    targetContentHeightRule: "legacy-radius-multiplier",
    targetContentHeightRadiusMultiplier: 4.35,
    manualFeetAnchor: false
  },
  militia_unit_sprite: {
    schemaVersion: 1,
    assetId: "militia_unit_sprite",
    sourceCanvas: { width: 512, height: 512 },
    alphaThreshold: 8,
    alphaContentBounds: { left: 0.234375, top: 0.0703125, right: 0.765625, bottom: 0.9296875 },
    feetAnchor: { x: 0.5, y: 0.9296875 },
    targetContentHeightRule: "legacy-radius-multiplier",
    targetContentHeightRadiusMultiplier: 3.65,
    manualFeetAnchor: false
  },
  ranger_unit_sprite: {
    schemaVersion: 1,
    assetId: "ranger_unit_sprite",
    sourceCanvas: { width: 512, height: 512 },
    alphaThreshold: 8,
    alphaContentBounds: { left: 0.1953125, top: 0.0703125, right: 0.806640625, bottom: 0.9296875 },
    feetAnchor: { x: 0.5009765625, y: 0.9296875 },
    targetContentHeightRule: "legacy-radius-multiplier",
    targetContentHeightRadiusMultiplier: 3.65,
    manualFeetAnchor: false
  }
};

const COMMAND_HALL_BUILDING_METADATA: VisualAssetBuildingPresentationMetadata = {
  schemaVersion: 1,
  assetId: "command_hall_building_sprite",
  sourceCanvas: { width: 768, height: 768 },
  alphaThreshold: 8,
  alphaContentBounds: {
    left: 0.0703125,
    top: 0.11848958333333333,
    right: 0.9296875,
    bottom: 0.8815104166666666
  },
  groundAnchor: { x: 0.5, y: 0.8815104166666666 },
  fitPolicy: "content-bounds-within-legacy-envelope",
  groundAnchorMode: "manual-authored"
};

const UNIT_BASE = {
  sprite: { yRadiusMultiplier: 0.1, originY: 0.8, targetHeightRadiusMultiplier: 3.65 },
  shadow: { yRadiusMultiplier: 0.58, widthRadiusMultiplier: 2.5, heightRadiusMultiplier: 0.72, opacity: 0.32 },
  fallback: { visualTopRadiusMultiplier: -1.28, visualBottomRadiusMultiplier: 1.04 },
  layout: {
    healthTopOffsetPx: 11,
    healthWidthPx: 42,
    healthHeightPx: 5,
    labelBottomOffsetPx: 7,
    selectionRadiusMinPx: 20,
    selectionRadiusAddPx: 7,
    selectionWidthRadiusMultiplier: 2.15,
    selectionHeightRadiusMultiplier: 0.56,
    selectionHeightMinPx: 9,
    selectionYOffsetPx: 0.5
  }
} as const;

const HERO_BASE = {
  sprite: { yRadiusMultiplier: 0.1, originY: 0.8, targetHeightRadiusMultiplier: 4.35 },
  shadow: { yRadiusMultiplier: 0.58, widthRadiusMultiplier: 2.5, heightRadiusMultiplier: 0.72, opacity: 0.32 },
  fallback: { visualTopRadiusMultiplier: -1.62, visualBottomRadiusMultiplier: 1.04 },
  layout: {
    healthTopOffsetPx: 13,
    healthWidthPx: 56,
    healthHeightPx: 6,
    labelBottomOffsetPx: 7,
    selectionRadiusMinPx: 23,
    selectionRadiusAddPx: 7,
    selectionWidthRadiusMultiplier: 2.35,
    selectionHeightRadiusMultiplier: 0.62,
    selectionHeightMinPx: 9,
    selectionYOffsetPx: 0.5
  }
} as const;

const BUILDING_BASE = {
  sprite: { originY: 0.66, maxWidthSizeMultiplier: 1.24, maxHeightSizeMultiplier: 1.42 },
  shadow: { ySizeHeightMultiplier: 0.3, widthSizeMultiplier: 1.1, heightSizeMultiplier: 0.46, opacity: 0.28 },
  fallback: { visualTopSizeMultiplier: -0.5, visualBottomSizeMultiplier: 0.5 },
  layout: {
    healthTopOffsetPx: 14,
    healthMinWidthPx: 64,
    healthWidthSizeMultiplier: 1.08,
    healthHeightPx: 7,
    labelBottomOffsetPx: 8,
    selectionRadiusAddPx: 7,
    selectionRadiusSizeMultiplier: 0.64,
    selectionWidthSizeMultiplier: 1.16,
    selectionWidthRadiusMultiplier: 2.05,
    selectionMinHeightPx: 18,
    selectionHeightSizeMultiplier: 0.38,
    selectionYOffsetPx: -2
  }
} as const;

function freeze<T>(value: T): T {
  if (value && typeof value === "object" && !Object.isFrozen(value)) {
    Object.values(value as Record<string, unknown>).forEach((child) => freeze(child));
    Object.freeze(value);
  }
  return value;
}

const COMMON_FROZEN = freeze(COMMON_PRESENTATION_DEFAULTS);
const CONTENT_AWARE_HUMANOID_METADATA_FROZEN = freeze(CONTENT_AWARE_HUMANOID_METADATA);
const COMMAND_HALL_BUILDING_METADATA_FROZEN = freeze(COMMAND_HALL_BUILDING_METADATA);

function isContentAwareHumanoidAssetId(assetId: string): assetId is ContentAwareHumanoidAssetId {
  return Object.prototype.hasOwnProperty.call(CONTENT_AWARE_HUMANOID_METADATA_FROZEN, assetId);
}

function isValidContentAwareMetadata(metadata: VisualAssetPresentationMetadata): boolean {
  const bounds = metadata.alphaContentBounds;
  const feet = metadata.feetAnchor;
  return (
    metadata.schemaVersion === 1 &&
    metadata.sourceCanvas.width > 0 &&
    metadata.sourceCanvas.height > 0 &&
    Number.isInteger(metadata.sourceCanvas.width) &&
    Number.isInteger(metadata.sourceCanvas.height) &&
    validNumber(metadata.alphaThreshold, 0, 255) &&
    metadata.targetContentHeightRule === "legacy-radius-multiplier" &&
    validNumber(metadata.targetContentHeightRadiusMultiplier, 0.01, 20) &&
    metadata.manualFeetAnchor === false &&
    validNumber(bounds.left, 0, 1) &&
    validNumber(bounds.top, 0, 1) &&
    validNumber(bounds.right, 0, 1) &&
    validNumber(bounds.bottom, 0, 1) &&
    bounds.left < bounds.right &&
    bounds.top < bounds.bottom &&
    validNumber(feet.x, bounds.left, bounds.right) &&
    validNumber(feet.y, bounds.top, bounds.bottom)
  );
}

function isValidBuildingContentAwareMetadata(metadata: VisualAssetBuildingPresentationMetadata): boolean {
  const bounds = metadata.alphaContentBounds;
  const ground = metadata.groundAnchor;
  return (
    metadata.schemaVersion === 1 &&
    metadata.assetId === "command_hall_building_sprite" &&
    Number.isInteger(metadata.sourceCanvas.width) &&
    Number.isInteger(metadata.sourceCanvas.height) &&
    validNumber(metadata.sourceCanvas.width, 1, 100000) &&
    validNumber(metadata.sourceCanvas.height, 1, 100000) &&
    validNumber(metadata.alphaThreshold, 0, 255) &&
    metadata.fitPolicy === "content-bounds-within-legacy-envelope" &&
    (metadata.groundAnchorMode === "manual-authored" || metadata.groundAnchorMode === "automatic-lower-contact-center") &&
    validNumber(bounds.left, 0, 1) &&
    validNumber(bounds.top, 0, 1) &&
    validNumber(bounds.right, 0, 1) &&
    validNumber(bounds.bottom, 0, 1) &&
    bounds.left < bounds.right &&
    bounds.top < bounds.bottom &&
    validNumber(ground.x, bounds.left, bounds.right) &&
    validNumber(ground.y, bounds.top, bounds.bottom)
  );
}

export function resolveUnitContentAwarePresentationMetadata(
  assetId: string
): VisualAssetPresentationMetadata | undefined {
  if (!isContentAwareHumanoidAssetId(assetId)) {
    return undefined;
  }
  const metadata = CONTENT_AWARE_HUMANOID_METADATA_FROZEN[assetId];
  return isValidContentAwareMetadata(metadata) ? metadata : undefined;
}

export function calculateUnitContentAwareVisualLayout(
  assetId: string,
  radius: number,
  textureHeight?: number
): UnitContentAwareVisualLayout | undefined {
  const metadata = resolveUnitContentAwarePresentationMetadata(assetId);
  if (!metadata || !validNumber(radius, 0.01, 1000)) {
    return undefined;
  }
  const sourceHeight = textureHeight ?? metadata.sourceCanvas.height;
  const contentHeight = (metadata.alphaContentBounds.bottom - metadata.alphaContentBounds.top) * sourceHeight;
  if (!validNumber(sourceHeight, 1, 100000) || !validNumber(contentHeight, 0.01, 100000)) {
    return undefined;
  }
  const targetContentHeight = radius * metadata.targetContentHeightRadiusMultiplier;
  const scale = targetContentHeight / contentHeight;
  const visualTop =
    (metadata.alphaContentBounds.top - metadata.feetAnchor.y) * sourceHeight * scale;
  const visualBottom =
    (metadata.alphaContentBounds.bottom - metadata.feetAnchor.y) * sourceHeight * scale;
  if (![scale, visualTop, visualBottom].every(Number.isFinite)) {
    return undefined;
  }
  return {
    originX: metadata.feetAnchor.x,
    originY: metadata.feetAnchor.y,
    spriteY: 0,
    shadowY: 0,
    scale,
    targetContentHeight,
    visualTop,
    visualBottom
  };
}

export function resolveBuildingContentAwarePresentationMetadata(
  assetId: string
): VisualAssetBuildingPresentationMetadata | undefined {
  if (assetId !== "command_hall_building_sprite") {
    return undefined;
  }
  return isValidBuildingContentAwareMetadata(COMMAND_HALL_BUILDING_METADATA_FROZEN)
    ? COMMAND_HALL_BUILDING_METADATA_FROZEN
    : undefined;
}

export function calculateBuildingContentAwareVisualLayout(
  assetId: string,
  definitionWidth: number,
  definitionHeight: number,
  textureWidth?: number,
  textureHeight?: number
): BuildingContentAwareVisualLayout | undefined {
  const metadata = resolveBuildingContentAwarePresentationMetadata(assetId);
  if (!metadata || !validNumber(definitionWidth, 0.01, 100000) || !validNumber(definitionHeight, 0.01, 100000)) {
    return undefined;
  }
  const sourceWidth = textureWidth ?? metadata.sourceCanvas.width;
  const sourceHeight = textureHeight ?? metadata.sourceCanvas.height;
  if (
    !validNumber(sourceWidth, 1, 100000) ||
    !validNumber(sourceHeight, 1, 100000) ||
    sourceWidth !== metadata.sourceCanvas.width ||
    sourceHeight !== metadata.sourceCanvas.height
  ) {
    return undefined;
  }
  const sourceContentWidth = (metadata.alphaContentBounds.right - metadata.alphaContentBounds.left) * sourceWidth;
  const sourceContentHeight = (metadata.alphaContentBounds.bottom - metadata.alphaContentBounds.top) * sourceHeight;
  const maxWidth = definitionWidth * BUILDING_BASE.sprite.maxWidthSizeMultiplier;
  const maxHeight = definitionHeight * BUILDING_BASE.sprite.maxHeightSizeMultiplier;
  const scale = Math.min(maxWidth / sourceContentWidth, maxHeight / sourceContentHeight);
  const contentWidth = sourceContentWidth * scale;
  const contentHeight = sourceContentHeight * scale;
  const visualTop = (metadata.alphaContentBounds.top - metadata.groundAnchor.y) * sourceHeight * scale;
  const transformedContentBottom = (metadata.alphaContentBounds.bottom - metadata.groundAnchor.y) * sourceHeight * scale;
  const visualBottom = Math.max(definitionHeight * 0.46, transformedContentBottom);
  if (![sourceContentWidth, sourceContentHeight, contentWidth, contentHeight, maxWidth, maxHeight, scale, visualTop, visualBottom].every(Number.isFinite)) {
    return undefined;
  }
  return {
    originX: metadata.groundAnchor.x,
    originY: metadata.groundAnchor.y,
    spriteY: 0,
    shadowY: 0,
    scale,
    contentWidth,
    contentHeight,
    visualTop,
    visualBottom
  };
}

function buildUnitConfig(family: "unit" | "hero"): UnitPresentationConfig {
  const base = family === "hero" ? HERO_BASE : UNIT_BASE;
  return freeze({
    schemaVersion: 1,
    family,
    sprite: { ...base.sprite },
    shadow: { ...base.shadow },
    fallback: { ...base.fallback },
    layout: { ...base.layout },
    depth: { mode: "fixed-type-legacy", fixedDepth: family === "hero" ? 12 : 10, active: false },
    inactiveFuture: {
      alphaBoundsPopulated: false,
      feetAnchorPopulated: false,
      targetContentHeightPopulated: false,
      perAssetOverridesActive: false,
      yDepthPolicyActive: false,
      restrictedDepthBandActive: false
    }
  });
}

function buildBuildingConfig(): BuildingPresentationConfig {
  return freeze({
    schemaVersion: 1,
    family: "building",
    sprite: { ...BUILDING_BASE.sprite },
    shadow: { ...BUILDING_BASE.shadow },
    fallback: { ...BUILDING_BASE.fallback },
    layout: { ...BUILDING_BASE.layout },
    depth: { mode: "fixed-type-legacy", fixedDepth: 5, active: false },
    inactiveFuture: {
      alphaBoundsPopulated: false,
      feetAnchorPopulated: false,
      targetContentHeightPopulated: false,
      perAssetOverridesActive: false,
      yDepthPolicyActive: false,
      restrictedDepthBandActive: false
    }
  });
}

const DEFAULT_CONFIGS = freeze({
  unit: buildUnitConfig("unit"),
  hero: buildUnitConfig("hero"),
  building: buildBuildingConfig()
});

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}

function validNumber(value: unknown, min: number, max: number): value is number {
  return typeof value === "number" && Number.isFinite(value) && value >= min && value <= max;
}

function validateKnownNumbers(value: unknown, rules: Array<[string, number, number]>): boolean {
  if (value === undefined) {
    return true;
  }
  if (!isRecord(value)) {
    return false;
  }
  return rules.every(([key, min, max]) => value[key] === undefined || validNumber(value[key], min, max));
}

function pickKnownNumbers(
  value: unknown,
  rules: Array<[string, number, number]>
): Record<string, number> {
  if (!isRecord(value)) {
    return {};
  }
  return Object.fromEntries(
    rules.flatMap(([key]) => (typeof value[key] === "number" ? [[key, value[key]] as [string, number]] : []))
  );
}

function resolveOverride<T extends EntityPresentationConfig>(base: T, override: unknown): T {
  if (override === undefined) {
    return base;
  }
  if (!isRecord(override)) {
    return base;
  }
  if (override.schemaVersion !== undefined && override.schemaVersion !== 1) {
    return base;
  }
  if (override.family !== undefined && override.family !== base.family) {
    return base;
  }
  if (override.depth !== undefined && (!isRecord(override.depth) || (override.depth.mode !== undefined && override.depth.mode !== "fixed-type-legacy") || (override.depth.active !== undefined && override.depth.active !== false) || (override.depth.fixedDepth !== undefined && !validNumber(override.depth.fixedDepth, 0, 100)))) {
    return base;
  }
  if (!validateKnownNumbers(override.sprite, base.family === "building" ? [["originY", 0, 1], ["maxWidthSizeMultiplier", 0.01, 10], ["maxHeightSizeMultiplier", 0.01, 10]] : [["yRadiusMultiplier", -10, 10], ["originY", 0, 1], ["targetHeightRadiusMultiplier", 0.01, 20]])) {
    return base;
  }
  if (!validateKnownNumbers(override.shadow, base.family === "building" ? [["ySizeHeightMultiplier", -10, 10], ["widthSizeMultiplier", 0.01, 20], ["heightSizeMultiplier", 0.01, 20], ["opacity", 0, 1]] : [["yRadiusMultiplier", -10, 10], ["widthRadiusMultiplier", 0.01, 20], ["heightRadiusMultiplier", 0.01, 20], ["opacity", 0, 1]])) {
    return base;
  }
  if (!validateKnownNumbers(override.fallback, base.family === "building" ? [["visualTopSizeMultiplier", -10, 10], ["visualBottomSizeMultiplier", -10, 10]] : [["visualTopRadiusMultiplier", -10, 10], ["visualBottomRadiusMultiplier", -10, 10]])) {
    return base;
  }
  const layoutRules = base.family === "building"
    ? [["healthTopOffsetPx", -200, 200], ["healthMinWidthPx", 1, 1000], ["healthWidthSizeMultiplier", 0.01, 20], ["healthHeightPx", 1, 100], ["labelBottomOffsetPx", -200, 200], ["selectionRadiusAddPx", -200, 200], ["selectionRadiusSizeMultiplier", 0.01, 20], ["selectionWidthSizeMultiplier", 0.01, 20], ["selectionWidthRadiusMultiplier", 0.01, 20], ["selectionMinHeightPx", 1, 500], ["selectionHeightSizeMultiplier", 0.01, 20], ["selectionYOffsetPx", -200, 200]] as Array<[string, number, number]>
    : [["healthTopOffsetPx", -200, 200], ["healthWidthPx", 1, 1000], ["healthHeightPx", 1, 100], ["labelBottomOffsetPx", -200, 200], ["selectionRadiusMinPx", 1, 500], ["selectionRadiusAddPx", -200, 200], ["selectionWidthRadiusMultiplier", 0.01, 20], ["selectionHeightRadiusMultiplier", 0.01, 20], ["selectionHeightMinPx", 1, 500], ["selectionYOffsetPx", -200, 200]] as Array<[string, number, number]>;
  if (!validateKnownNumbers(override.layout, layoutRules)) {
    return base;
  }
  if (override.inactiveFuture !== undefined && (!isRecord(override.inactiveFuture) || Object.values(override.inactiveFuture).some((value) => value !== false))) {
    return base;
  }

  const spriteRules = base.family === "building"
    ? [["originY", 0, 1], ["maxWidthSizeMultiplier", 0.01, 10], ["maxHeightSizeMultiplier", 0.01, 10]] as Array<[string, number, number]>
    : [["yRadiusMultiplier", -10, 10], ["originY", 0, 1], ["targetHeightRadiusMultiplier", 0.01, 20]] as Array<[string, number, number]>;
  const shadowRules = base.family === "building"
    ? [["ySizeHeightMultiplier", -10, 10], ["widthSizeMultiplier", 0.01, 20], ["heightSizeMultiplier", 0.01, 20], ["opacity", 0, 1]] as Array<[string, number, number]>
    : [["yRadiusMultiplier", -10, 10], ["widthRadiusMultiplier", 0.01, 20], ["heightRadiusMultiplier", 0.01, 20], ["opacity", 0, 1]] as Array<[string, number, number]>;
  const fallbackRules = base.family === "building"
    ? [["visualTopSizeMultiplier", -10, 10], ["visualBottomSizeMultiplier", -10, 10]] as Array<[string, number, number]>
    : [["visualTopRadiusMultiplier", -10, 10], ["visualBottomRadiusMultiplier", -10, 10]] as Array<[string, number, number]>;
  const next = {
    ...base,
    sprite: { ...base.sprite, ...pickKnownNumbers(override.sprite, spriteRules) },
    shadow: { ...base.shadow, ...pickKnownNumbers(override.shadow, shadowRules) },
    fallback: { ...base.fallback, ...pickKnownNumbers(override.fallback, fallbackRules) },
    layout: { ...base.layout, ...pickKnownNumbers(override.layout, layoutRules) },
    depth: {
      ...base.depth,
      ...(isRecord(override.depth) && typeof override.depth.fixedDepth === "number"
        ? { fixedDepth: override.depth.fixedDepth }
        : {})
    }
  } as T;
  return freeze(next);
}

export function getCommonPresentationDefaults(): CommonPresentationDefaults {
  return COMMON_FROZEN;
}

export function resolveEntityPresentationConfig(family: "unit" | "hero", override?: unknown): UnitPresentationConfig;
export function resolveEntityPresentationConfig(family: "building", override?: unknown): BuildingPresentationConfig;
export function resolveEntityPresentationConfig(family: PresentationFamily, override?: unknown): EntityPresentationConfig;
export function resolveEntityPresentationConfig(family: PresentationFamily, override?: unknown): EntityPresentationConfig {
  const base = DEFAULT_CONFIGS[family];
  return resolveOverride(base, override);
}

export function presentationConfigHasGameplayFields(config: EntityPresentationConfig): boolean {
  const forbidden = new Set(["radius", "position", "size", "footprint", "collision", "range", "vision", "placement", "navigation", "hitRadius", "id", "hp"]);
  return Object.keys(config).some((key) => forbidden.has(key));
}

export const PRESENTATION_CONFIG_SCHEMA_VERSION = 1 as const;
