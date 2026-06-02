import type { VisualAssetReviewState } from "./VisualAssetReviewRegistry";

export const RUNTIME_ART_SLOT_GROUPS = [
  "main-menu",
  "campaign",
  "battlefield",
  "units",
  "buildings",
  "ui"
] as const;

export type RuntimeArtSlotGroup = (typeof RUNTIME_ART_SLOT_GROUPS)[number];

export type RuntimeArtSlotFallbackKind = "css" | "dom-layout" | "phaser-vector" | "procedural";

export interface RuntimeArtSlotFallback {
  kind: RuntimeArtSlotFallbackKind;
  owner: string;
  proofSurface: string;
  description: string;
  dataTestId?: string;
}

export interface RuntimeArtSlotRegistryMapping {
  status: "deferred-final-art-requirement" | "mapped-to-v0105-reference";
  referenceAssetIds: string[];
  notes: string;
}

export interface RuntimeArtSlotApprovedAsset {
  assetId: string;
  reviewState: VisualAssetReviewState;
  path: string;
  mimeType: string;
  width: number;
  height: number;
  integratedAtCheckpoint: string;
  proof: {
    humanApprovalDoc: string;
    validator: string;
    screenshotId?: string;
  };
}

export interface RuntimeArtSlotDefinition {
  slotId: string;
  group: RuntimeArtSlotGroup;
  label: string;
  runtimeSurface: string;
  fallback: RuntimeArtSlotFallback;
  registryMapping: RuntimeArtSlotRegistryMapping;
  approvedAsset?: RuntimeArtSlotApprovedAsset;
  publicDiagnosticsAllowed?: boolean;
}

export type RuntimeArtSlotResolutionSource = "fallback" | "mock" | "runtime-asset";

export interface RuntimeArtSlotResolution {
  slotId: string;
  group: RuntimeArtSlotGroup;
  source: RuntimeArtSlotResolutionSource;
  shouldLoadAsset: boolean;
  fallback: RuntimeArtSlotFallback;
  assetPath?: string;
  diagnostics: string;
  reason: string;
  mockStyleToken?: string;
}

export interface RuntimeArtSlotValidationIssue {
  slotId?: string;
  path: string;
  message: string;
}

export interface RuntimeArtSlotValidationResult {
  slotCount: number;
  checks: string[];
  errors: RuntimeArtSlotValidationIssue[];
  warnings: RuntimeArtSlotValidationIssue[];
}
