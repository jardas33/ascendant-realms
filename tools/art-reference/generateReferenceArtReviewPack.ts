import path from "node:path";
import { fileURLToPath } from "node:url";
import { generateReferenceArtContactSheet } from "./generateReferenceArtContactSheet";
import {
  initializeReferenceArtWorkspace,
  REFERENCE_BRIEF_IDS,
  referenceWorkspacePaths,
  relativeToProject,
  writeStableJson,
  writeTextFile
} from "./shared";
import { validateReferenceArtWorkspace } from "./validateReferenceArt";

export interface ReferenceReviewPackResult {
  status: string;
  validationStatus: string;
  contactSheetStatus: string;
  checklistPath: string;
  summaryPath: string;
}

export async function generateReferenceArtReviewPack(projectRoot = process.cwd()): Promise<ReferenceReviewPackResult> {
  await initializeReferenceArtWorkspace(projectRoot);
  const validation = await validateReferenceArtWorkspace(projectRoot);
  const contactSheet = await generateReferenceArtContactSheet(projectRoot);
  const paths = referenceWorkspacePaths(projectRoot);
  const status =
    validation.errors.length > 0
      ? "FAIL_V0138_REFERENCE_REVIEW_PACK"
      : contactSheet.imageCount === 0
        ? "PENDING_V0138_REFERENCE_REVIEW_PACK_NO_CANDIDATES"
        : "PASS_V0138_REFERENCE_REVIEW_PACK";
  const checklistPath = path.join(paths.reviewNotesDir, "v0138-reference-review-checklist.md");
  const summaryPath = path.join(paths.reviewNotesDir, "v0138-reference-review-pack.json");
  const summary = {
    schemaVersion: 1,
    status,
    validationStatus: validation.status,
    contactSheetStatus: contactSheet.status,
    referenceOnly: true,
    runtimeIntegrationStatus: "forbidden",
    briefIds: [...REFERENCE_BRIEF_IDS],
    candidateImages: contactSheet.imageCount,
    validationErrors: validation.errors.length,
    validationWarnings: validation.warnings.length,
    outputs: {
      validationReport: relativeToProject(projectRoot, path.join(paths.reviewNotesDir, "reference-validation.md")),
      contactSheet: relativeToProject(projectRoot, contactSheet.svgPath),
      contactSheetManifest: relativeToProject(projectRoot, contactSheet.manifestPath),
      checklist: relativeToProject(projectRoot, checklistPath)
    }
  };
  await writeStableJson(summaryPath, summary);
  await writeTextFile(checklistPath, renderReviewChecklist(status, validation.status, contactSheet.status));
  return {
    status,
    validationStatus: validation.status,
    contactSheetStatus: contactSheet.status,
    checklistPath,
    summaryPath
  };
}

function renderReviewChecklist(status: string, validationStatus: string, contactSheetStatus: string): string {
  return [
    "# v0.138 Reference-Art Review Checklist",
    "",
    `Status: ${status}`,
    `Metadata validation: ${validationStatus}`,
    `Contact sheet: ${contactSheetStatus}`,
    "",
    "Use this checklist after Emmanuel places candidate images and metadata in the ignored workspace.",
    "",
    "## Candidate Review",
    "",
    "- Candidate has a matching metadata JSON record.",
    "- `runtimeIntegrationStatus` is exactly `forbidden`.",
    "- SHA-256 hash and dimensions match the candidate file.",
    "- Licence posture is recorded and does not approve runtime use.",
    "- Protected-IP review says no protected lookalike, logo, UI, faction, character, or artist imitation.",
    "- Visual target reads as original Barrosan highland fantasy.",
    "- Tactical shapes remain clear at fixed-camera RTS/RPG distance.",
    "- Image is atmospheric without muddying units, UI, terrain landmarks, or objectives.",
    "- Image avoids generic mobile-game gloss and developer-dashboard framing.",
    "- Image contains no excessive baked-in text.",
    "",
    "## Stop Conditions",
    "",
    "- Reject candidates with unclear source, unclear licence, protected-IP risk, runtime-use language, or copied franchise identity.",
    "- Do not import candidates into Godot, browser runtime, public assets, save data, stable IDs, or runtime registries.",
    "- Do not mark any candidate final or runtime-approved in v0.138."
  ].join("\n");
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  generateReferenceArtReviewPack()
    .then((result) => {
      console.log(`v0.138 reference-art review pack: ${result.status}`);
      console.log(`Validation: ${result.validationStatus}`);
      console.log(`Contact sheet: ${result.contactSheetStatus}`);
      console.log(`Checklist: ${relativeToProject(process.cwd(), result.checklistPath)}`);
      console.log(`Summary: ${relativeToProject(process.cwd(), result.summaryPath)}`);
      if (result.status.startsWith("FAIL_")) {
        process.exitCode = 1;
      }
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.stack ?? error.message : String(error));
      process.exitCode = 1;
    });
}
