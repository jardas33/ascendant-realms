import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const repoRoot = process.cwd();
const artifactRoot = path.join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0139");
const latestRoot = path.join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "latest");
const v0134Root = path.join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0134");
const v0135Root = path.join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0135");
const v0136Root = path.join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0136");
const v0137Root = path.join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0137");
const v0120Root = path.join(repoRoot, "artifacts", "desktop-spikes", "godot-salto", "v0120");
const referenceRoot = path.join(repoRoot, "artifacts", "art-review", "v0138", "review-notes");

mkdirSync(artifactRoot, { recursive: true });

const evidence = {
  tripleValidation: readJsonRequired(path.join(v0134Root, "triple-natural-playthrough-validation.json")),
  tripleReport: readJsonRequired(path.join(v0134Root, "triple-playthrough-report.json")),
  recoveryReport: readJsonRequired(path.join(v0134Root, "recovery-case-report.json")),
  restartReport: readJsonRequired(path.join(v0134Root, "restart-integrity-report.json")),
  noSoftlockProof: readJsonRequired(path.join(v0134Root, "no-softlock-proof.json")),
  noShortcutProof: readJsonRequired(path.join(v0134Root, "no-shortcut-proof.json")),
  rtsValidation: readJsonRequired(path.join(v0135Root, "rts-ergonomics-validation.json")),
  rtsInput: readJsonRequired(path.join(v0135Root, "rts-input-contract.json")),
  orderFeedback: readJsonRequired(path.join(v0135Root, "order-feedback-report.json")),
  cameraControl: readJsonRequired(path.join(v0135Root, "camera-control-report.json")),
  compactHelp: readJsonRequired(path.join(v0135Root, "compact-help-report.json")),
  usabilityValidation: readJsonRequired(path.join(v0136Root, "usability-presentation-validation.json")),
  hudHierarchy: readJsonRequired(path.join(v0136Root, "hud-hierarchy-report.json")),
  minimapRefinement: readJsonRequired(path.join(v0136Root, "minimap-refinement-report.json")),
  onboardingCopy: readJsonRequired(path.join(v0136Root, "onboarding-copy-report.json")),
  microloopPacing: readJsonRequired(path.join(v0136Root, "microloop-pacing-report.json")),
  blockoutValidation: readJsonRequired(path.join(v0137Root, "blockout-quality-validation.json")),
  performanceSmoke: readJsonRequired(path.join(v0137Root, "performance-smoke.json")),
  composition: readJsonRequired(path.join(v0137Root, "composition-readability-report.json")),
  silhouettes: readJsonRequired(path.join(v0137Root, "silhouette-readability-report.json")),
  lightingVfx: readJsonRequired(path.join(v0137Root, "lighting-vfx-report.json")),
  cameraScreenUse: readJsonRequired(path.join(v0137Root, "camera-screen-use-report.json")),
  screenshotManifest: readJsonRequired(path.join(v0137Root, "screenshot-manifest.json")),
  screenshotHashes: readJsonRequired(path.join(v0137Root, "screenshot-hashes.json")),
  packageReport: readJsonRequired(path.join(latestRoot, "package-report.json")),
  scorecard: readJsonRequired(path.join(latestRoot, "scorecard.json")),
  freshCheckout: readJsonRequired(path.join(v0120Root, "fresh-checkout-validation.json")),
  referenceValidation: readJsonRequired(path.join(referenceRoot, "reference-validation.json")),
  referenceReviewPack: readJsonRequired(path.join(referenceRoot, "v0138-reference-review-pack.json"))
};

const checks = {
  repeatedPlaythroughs: isStatus(evidence.tripleValidation, "PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH_VALIDATION"),
  softLockRecovery: isStatus(evidence.noSoftlockProof, "PASS_V0134_NO_SOFTLOCK_PROOF") && isStatus(evidence.recoveryReport, "PASS_V0134_RECOVERY_CASES"),
  restart: isStatus(evidence.restartReport, "PASS_V0134_RESTART_INTEGRITY"),
  rtsControls: isStatus(evidence.rtsValidation, "PASS_V0135_RTS_ERGONOMICS_VALIDATION") && isStatus(evidence.rtsInput, "PASS_V0135_RTS_INPUT_CONTRACT"),
  camera: isStatus(evidence.cameraControl, "PASS_V0135_CAMERA_CONTROL") && isStatus(evidence.cameraScreenUse, "PASS_V0137_CAMERA_SCREEN_USE"),
  hud: isStatus(evidence.hudHierarchy, "PASS_V0136_HUD_HIERARCHY"),
  minimap: isStatus(evidence.minimapRefinement, "PASS_V0136_MINIMAP_REFINEMENT"),
  onboarding: isStatus(evidence.onboardingCopy, "PASS_V0136_ONBOARDING_COPY"),
  mine: completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.mineControlled === true),
  worker: completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.workerAssignedToMine === true),
  barracks: completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.barracksRestored === true),
  recruitment: completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.militiaSpawned === true),
  wave: completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.waveTriggeredOnce === true),
  combat: completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.combatStarted === true && profile?.checks?.waveDefeatedFromSimulation === true),
  lume: completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.lumeRestored === true),
  results: completedObjectiveProfiles(evidence.tripleReport).length >= 2 &&
    completedObjectiveProfiles(evidence.tripleReport).every((profile) => profile?.checks?.resultsReached === true),
  proceduralBlockout: isStatus(evidence.blockoutValidation, "PASS_V0137_BLOCKOUT_QUALITY_VALIDATION") &&
    isStatus(evidence.composition, "PASS_V0137_COMPOSITION_READABILITY") &&
    isStatus(evidence.silhouettes, "PASS_V0137_SILHOUETTE_READABILITY") &&
    isStatus(evidence.lightingVfx, "PASS_V0137_LIGHTING_VFX"),
  performance: isStatus(evidence.performanceSmoke, "PASS_V0137_PERFORMANCE_SMOKE"),
  zeroEditor: evidence.freshCheckout?.routineEditorUseRequired === false &&
    evidence.blockoutValidation?.routineEditorUseRequired === false &&
    evidence.usabilityValidation?.routineEditorUseRequired === false,
  freshCheckout: isStatus(evidence.freshCheckout, "PASS_GODOT_FRESH_CHECKOUT_VALIDATION"),
  package: isStatus(evidence.packageReport, "PASS_WINDOWS_PACKAGE"),
  referenceArtWorkspace: isReferenceWorkspaceReady(evidence.referenceValidation, evidence.referenceReviewPack),
  noRuntimeArtImport: [
    evidence.tripleValidation,
    evidence.rtsValidation,
    evidence.usabilityValidation,
    evidence.blockoutValidation
  ].every((report) => report?.runtimeArtIntegrated === false && report?.generatedOrImportedArtIncluded === false)
};

const redFailures = Object.entries(checks).filter(([, passed]) => !passed).map(([key]) => key);
const classification = redFailures.length === 0 ? "SALTO_SLICE_STABILIZATION_GREEN" : "SALTO_SLICE_STABILIZATION_RED";
const gate = {
  schemaVersion: 1,
  checkpoint: "v0.139",
  generatedAtUtc: "deterministic-v0139",
  classification,
  gate: classification,
  status: classification === "SALTO_SLICE_STABILIZATION_GREEN" ? "PASS_V0139_SALTO_SLICE_STABILIZATION_GATE" : "FAIL_V0139_SALTO_SLICE_STABILIZATION_GATE",
  checks,
  failures: redFailures,
  sourceReports: sourceReportPaths(),
  boundaries: {
    noGameplaySystemsAdded: true,
    noGeneratedImages: true,
    noDownloadedAssets: true,
    noRuntimeArtImport: checks.noRuntimeArtImport,
    noFinalGodotDecision: true,
    noFullPort: true,
    noBrowserRuntimeChange: true,
    noSaveOrStableIdChange: true,
    noMultiplayer: true,
    noV0140Started: true
  }
};

writeJson(path.join(artifactRoot, "gate.json"), gate);
writeJson(path.join(artifactRoot, "triple-playthrough.json"), {
  schemaVersion: 1,
  checkpoint: "v0.139",
  status: checks.repeatedPlaythroughs && checks.softLockRecovery && checks.restart ? "PASS_V0139_TRIPLE_PLAYTHROUGH_SUMMARY" : "FAIL_V0139_TRIPLE_PLAYTHROUGH_SUMMARY",
  sourceValidationStatus: evidence.tripleValidation.status,
  tripleStatus: evidence.tripleValidation.tripleStatus,
  softlockStatus: evidence.tripleValidation.softlockStatus,
  recoveryStatus: evidence.tripleValidation.recoveryStatus,
  restartStatus: evidence.tripleValidation.restartStatus,
  profileCount: evidence.tripleValidation.profileCount,
  captureCount: evidence.tripleValidation.captureCount,
  inputPath: evidence.tripleReport.inputPath,
  sourceReports: {
    validation: "artifacts/desktop-spikes/godot-salto/v0134/triple-natural-playthrough-validation.json",
    tripleReport: "artifacts/desktop-spikes/godot-salto/v0134/triple-playthrough-report.json",
    noSoftlockProof: "artifacts/desktop-spikes/godot-salto/v0134/no-softlock-proof.json",
    recovery: "artifacts/desktop-spikes/godot-salto/v0134/recovery-case-report.json",
    restart: "artifacts/desktop-spikes/godot-salto/v0134/restart-integrity-report.json"
  }
});

writeJson(path.join(artifactRoot, "usability.json"), {
  schemaVersion: 1,
  checkpoint: "v0.139",
  status: checks.rtsControls && checks.camera && checks.hud && checks.minimap && checks.onboarding ? "PASS_V0139_USABILITY_SUMMARY" : "FAIL_V0139_USABILITY_SUMMARY",
  rtsStatus: evidence.rtsValidation.status,
  inputContractStatus: evidence.rtsValidation.inputContractStatus,
  orderFeedbackStatus: evidence.rtsValidation.orderFeedbackStatus,
  cameraControlStatus: evidence.rtsValidation.cameraControlStatus,
  compactHelpStatus: evidence.rtsValidation.compactHelpStatus,
  usabilityStatus: evidence.usabilityValidation.status,
  hudStatus: evidence.usabilityValidation.hudStatus,
  minimapStatus: evidence.usabilityValidation.minimapStatus,
  onboardingStatus: evidence.usabilityValidation.onboardingStatus,
  pacingStatus: evidence.usabilityValidation.pacingStatus,
  sourceReports: {
    rtsValidation: "artifacts/desktop-spikes/godot-salto/v0135/rts-ergonomics-validation.json",
    hudHierarchy: "artifacts/desktop-spikes/godot-salto/v0136/hud-hierarchy-report.json",
    minimapRefinement: "artifacts/desktop-spikes/godot-salto/v0136/minimap-refinement-report.json",
    onboardingCopy: "artifacts/desktop-spikes/godot-salto/v0136/onboarding-copy-report.json",
    microloopPacing: "artifacts/desktop-spikes/godot-salto/v0136/microloop-pacing-report.json"
  }
});

writeJson(path.join(artifactRoot, "performance.json"), {
  schemaVersion: 1,
  checkpoint: "v0.139",
  status: checks.performance ? "PASS_V0139_PERFORMANCE_SUMMARY" : "FAIL_V0139_PERFORMANCE_SUMMARY",
  sourceStatus: evidence.performanceSmoke.status,
  finalProductionCertification: false,
  screenshotCaptureExcludedFromMeasuredWindow: evidence.performanceSmoke.screenshotCaptureExcludedFromMeasuredWindow === true,
  windows: evidence.performanceSmoke.windows,
  sourceReport: "artifacts/desktop-spikes/godot-salto/v0137/performance-smoke.json"
});

writeJson(path.join(artifactRoot, "screenshot-manifest.json"), {
  schemaVersion: 1,
  checkpoint: "v0.139",
  status: checks.proceduralBlockout ? "PASS_V0139_SCREENSHOT_MANIFEST" : "FAIL_V0139_SCREENSHOT_MANIFEST",
  sourceStatus: evidence.screenshotManifest.status,
  sourceCheckpoint: evidence.screenshotManifest.checkpoint,
  captureCount: evidence.screenshotManifest.captureCount,
  requiredCaptureCount: evidence.screenshotManifest.requiredCaptureCount,
  sourceManifest: "artifacts/desktop-spikes/godot-salto/v0137/screenshot-manifest.json",
  captures: evidence.screenshotManifest.captures
});

writeJson(path.join(artifactRoot, "screenshot-hashes.json"), {
  schemaVersion: 1,
  checkpoint: "v0.139",
  status: evidence.screenshotHashes.status === "PASS_V0137_SCREENSHOT_HASHES" ? "PASS_V0139_SCREENSHOT_HASHES" : "FAIL_V0139_SCREENSHOT_HASHES",
  sourceStatus: evidence.screenshotHashes.status,
  sourceCheckpoint: evidence.screenshotHashes.checkpoint,
  sourceReport: "artifacts/desktop-spikes/godot-salto/v0137/screenshot-hashes.json",
  hashes: evidence.screenshotHashes.hashes
});

writeJson(path.join(artifactRoot, "package-report.json"), {
  schemaVersion: 1,
  checkpoint: "v0.139",
  status: checks.package ? "PASS_V0139_STABILIZED_REVIEW_PACKAGE" : "FAIL_V0139_STABILIZED_REVIEW_PACKAGE",
  sourceStatus: evidence.packageReport.status,
  sourceCheckpoint: evidence.packageReport.checkpoint,
  packageCreated: evidence.packageReport.packageCreated === true,
  packagePath: evidence.packageReport.packagePath,
  packageSha256: evidence.packageReport.packageSha256,
  packageSizeMb: evidence.packageReport.packageSizeMb,
  launcher: "GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
  validationLauncher: "GODOT_VALIDATE_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
  captureLauncher: "GODOT_CAPTURE_STABILIZED_SALTO_REVIEW_WINDOWS.bat",
  notes: "v0.139 consolidates the existing packaged player-facing Salto slice for human review; it does not import runtime art or choose Godot finally."
});

writeJson(path.join(artifactRoot, "scorecard-update.json"), {
  schemaVersion: 1,
  checkpoint: "v0.139",
  status: classification === "SALTO_SLICE_STABILIZATION_GREEN" ? "PASS_V0139_SCORECARD_UPDATE" : "FAIL_V0139_SCORECARD_UPDATE",
  sourceScorecardStatus: evidence.scorecard.approvalStatus,
  sourceScorecardCheckpoint: evidence.scorecard.checkpoint,
  aiOperabilityScoreOutOf25: evidence.scorecard.aiOperability?.scoreOutOf25 ?? null,
  stabilizationClassification: classification,
  recommendation: classification === "SALTO_SLICE_STABILIZATION_GREEN"
    ? "Option A: generate four reference-only style frames and stop for human art review."
    : "Option B: run one more bounded usability polish pass before art generation.",
  noFinalEngineChoice: true,
  referenceArtWorkspaceStatus: evidence.referenceReviewPack.status,
  sourceReports: {
    scorecard: "artifacts/desktop-spikes/godot-salto/latest/scorecard.json",
    referenceReviewPack: "artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json"
  }
});

writeText(path.join(artifactRoot, "README.md"), renderReadme(gate));

if (classification !== "SALTO_SLICE_STABILIZATION_GREEN") {
  console.error(`v0.139 stabilization gate failed: ${redFailures.join(", ")}`);
  process.exitCode = 1;
} else {
  console.log("PASS_V0139_SALTO_SLICE_STABILIZATION_GATE");
  console.log(`Wrote ${toRepoPath(artifactRoot)}`);
}

function readJsonRequired(filePath) {
  if (!existsSync(filePath)) {
    throw new Error(`Missing required v0.139 source report: ${toRepoPath(filePath)}`);
  }
  return JSON.parse(readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

function writeText(filePath, value) {
  writeFileSync(filePath, `${value}\n`, "utf8");
}

function isStatus(report, status) {
  return report?.status === status;
}

function isReferenceWorkspaceReady(validation, reviewPack) {
  const validationOk =
    validation?.errors?.length === 0 &&
    ["PENDING_V0138_REFERENCE_ART_CANDIDATES", "PASS_V0138_REFERENCE_METADATA"].includes(validation?.status);
  const reviewPackOk =
    ["PENDING_V0138_REFERENCE_REVIEW_PACK_NO_CANDIDATES", "PASS_V0138_REFERENCE_REVIEW_PACK"].includes(reviewPack?.status) &&
    reviewPack?.runtimeIntegrationStatus === "forbidden";
  return validationOk && reviewPackOk;
}

function completedObjectiveProfiles(report) {
  return Array.isArray(report?.profiles) ? report.profiles.filter((profile) => profile?.checks && profile?.resultsReached === true) : [];
}

function sourceReportPaths() {
  return {
    triplePlaythrough: "artifacts/desktop-spikes/godot-salto/v0134/triple-natural-playthrough-validation.json",
    rtsErgonomics: "artifacts/desktop-spikes/godot-salto/v0135/rts-ergonomics-validation.json",
    usabilityPresentation: "artifacts/desktop-spikes/godot-salto/v0136/usability-presentation-validation.json",
    blockoutQuality: "artifacts/desktop-spikes/godot-salto/v0137/blockout-quality-validation.json",
    performance: "artifacts/desktop-spikes/godot-salto/v0137/performance-smoke.json",
    freshCheckout: "artifacts/desktop-spikes/godot-salto/v0120/fresh-checkout-validation.json",
    package: "artifacts/desktop-spikes/godot-salto/latest/package-report.json",
    scorecard: "artifacts/desktop-spikes/godot-salto/latest/scorecard.json",
    referenceArt: "artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json"
  };
}

function renderReadme(gate) {
  return [
    "# v0.139 Godot Salto Stabilization Review Pack",
    "",
    `Classification: ${gate.classification}`,
    `Gate: ${gate.gate}`,
    "",
    "This ignored artifact pack consolidates the packaged player-facing Salto slice evidence for Emmanuel review.",
    "",
    "Included files:",
    "",
    "- `gate.json` - stabilization gate classification and checklist.",
    "- `triple-playthrough.json` - repeated playthrough, restart, recovery, and no-softlock summary.",
    "- `usability.json` - RTS controls, camera, HUD, minimap, onboarding, and pacing summary.",
    "- `performance.json` - v0.137 bounded performance smoke summary.",
    "- `screenshot-manifest.json` - v0.139 wrapper for the v0.137 review screenshot manifest.",
    "- `screenshot-hashes.json` - v0.139 wrapper for the v0.137 screenshot hash report.",
    "- `package-report.json` - stabilized review package summary.",
    "- `scorecard-update.json` - next-phase recommendation and scorecard summary.",
    "",
    "Boundaries preserved: no generated images, no art import, no runtime art integration, no save or stable-ID changes, no browser runtime change, no final engine choice, no full port, and no v0.140 work."
  ].join("\n");
}

function toRepoPath(filePath) {
  return path.relative(repoRoot, filePath).replaceAll("\\", "/");
}
