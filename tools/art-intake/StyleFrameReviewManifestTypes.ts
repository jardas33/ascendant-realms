export type StyleFrameReviewCategory =
  | "terrain-style-frame"
  | "causeway-material"
  | "cinder-shrine-landmark"
  | "cinder-shrine-state-sheet"
  | "ashen-architecture"
  | "ashen-stronghold"
  | "ashen-barracks"
  | "ashen-watchtower"
  | "environmental-prop-sheet"
  | "minimap-readability-reference"
  | "ui-background-mood-frame"
  | "other";

export type StyleFrameReviewStage =
  | "inbox"
  | "metadata-complete"
  | "reference-only"
  | "candidate"
  | "approved-for-prototype"
  | "approved-for-runtime-test"
  | "approved-for-production"
  | "rejected";

export type StyleFrameSourceStatus = "complete" | "partial" | "unknown" | "blocked";

export type StyleFrameLicenseStatus =
  | "user-owned"
  | "commissioned-owned"
  | "licensed-commercial"
  | "licensed-noncommercial"
  | "internal-template"
  | "unknown"
  | "blocked";

export type StyleFrameIpRisk = "low" | "medium" | "high" | "unknown";

export type CinderfenPillarId =
  | "roads-read-first"
  | "shrines-glow-second"
  | "units-above-terrain-noise"
  | "wetland-dangerous-not-messy"
  | "ashen-architecture-angular-scorched-ritualized"
  | "player-structures-grounded-readable"
  | "fog-frames-decisions"
  | "ui-labels-support-not-carry";

export type CinderfenPillarFitStatus = "pass" | "concern" | "fail" | "not-reviewed";

export type StyleFrameAllowedNextStep =
  | "complete-metadata"
  | "source-license-review"
  | "visual-review"
  | "screenshot-comparison"
  | "runtime-test-proposal"
  | "keep-reference-only"
  | "reject"
  | "none";

export interface StyleFrameReviewCandidate {
  candidateId: string;
  metadataPath: string;
  filePath: string;
  category: StyleFrameReviewCategory;
  reviewStage: StyleFrameReviewStage;
  sourceStatus: StyleFrameSourceStatus;
  licenseStatus: StyleFrameLicenseStatus;
  ipRisk: StyleFrameIpRisk;
  visualFitScore: number;
  readabilityScore: number;
  scaleFitScore: number;
  cinderfenPillarFit: Partial<Record<CinderfenPillarId, CinderfenPillarFitStatus>>;
  screenshotTargets: string[];
  replacementTargets: string[];
  allowedNextStep: StyleFrameAllowedNextStep;
  notes: string;
}

export interface StyleFrameReviewManifest {
  schemaVersion: 1;
  updatedAt: string;
  scope: "cinderfen-style-frames";
  notes: string;
  candidates: StyleFrameReviewCandidate[];
}
