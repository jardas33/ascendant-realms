import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  collectReferenceCandidateImages,
  collectReferenceMetadataFiles,
  formatIssueList,
  imageSummaryByRelativePath,
  initializeReferenceArtWorkspace,
  isReferenceBriefId,
  normalizePath,
  readJsonFile,
  referenceWorkspacePaths,
  relativeToProject,
  type ReferenceCandidateMetadata,
  type ReferenceCandidateImageSummary,
  type ReferenceValidationIssue,
  type ReferenceValidationSummary,
  writeStableJson,
  writeTextFile
} from "./shared";

export async function validateReferenceArtWorkspace(projectRoot = process.cwd()): Promise<ReferenceValidationSummary> {
  await initializeReferenceArtWorkspace(projectRoot);
  const metadataFiles = await collectReferenceMetadataFiles(projectRoot);
  const candidateImages = await collectReferenceCandidateImages(projectRoot);
  const errors: ReferenceValidationIssue[] = [];
  const warnings: ReferenceValidationIssue[] = [];
  const imagesByPath = imageSummaryByRelativePath(candidateImages);
  const metadataImagePaths = new Set<string>();

  for (const metadataFile of metadataFiles) {
    const relativeMetadataPath = relativeToProject(projectRoot, metadataFile);
    let metadata: ReferenceCandidateMetadata;
    try {
      metadata = await readJsonFile<ReferenceCandidateMetadata>(metadataFile);
    } catch (error) {
      errors.push({
        path: relativeMetadataPath,
        message: `Invalid candidate metadata JSON: ${error instanceof Error ? error.message : String(error)}`
      });
      continue;
    }
    validateMetadataRecord(metadata, relativeMetadataPath, errors, warnings);
    const candidateImagePath = metadata.source?.candidateImagePath;
    if (typeof candidateImagePath === "string" && candidateImagePath.trim().length > 0) {
      const normalizedCandidatePath = normalizePath(candidateImagePath.trim());
      metadataImagePaths.add(normalizedCandidatePath);
      const image = imagesByPath.get(normalizedCandidatePath);
      if (!image) {
        errors.push({
          path: `${relativeMetadataPath}.source.candidateImagePath`,
          message: `Candidate image is not present in the v0.138 candidates workspace: ${normalizedCandidatePath}.`
        });
      } else {
        validateImageAgainstMetadata(metadata, image, relativeMetadataPath, errors, warnings);
      }
    } else {
      warnings.push({
        path: `${relativeMetadataPath}.source.candidateImagePath`,
        message: "Candidate image path is not recorded; hash and dimension checks are metadata-only."
      });
    }
  }

  for (const image of candidateImages) {
    if (!metadataImagePaths.has(image.relativePath) && !metadataImagePaths.has(image.filename)) {
      errors.push({
        path: image.relativePath,
        message: "Candidate image is present without a matching metadata record."
      });
    }
  }

  const status = determineValidationStatus(metadataFiles.length, candidateImages.length, errors.length);
  const summary: ReferenceValidationSummary = {
    status,
    checkedMetadataFiles: metadataFiles.length,
    checkedCandidateImages: candidateImages.length,
    errors,
    warnings
  };
  await writeValidationReports(projectRoot, summary);
  return summary;
}

function validateMetadataRecord(
  metadata: ReferenceCandidateMetadata,
  pathPrefix: string,
  errors: ReferenceValidationIssue[],
  warnings: ReferenceValidationIssue[]
): void {
  requireString(metadata.candidateId, `${pathPrefix}.candidateId`, "candidateId", errors);
  requireString(metadata.briefId, `${pathPrefix}.briefId`, "briefId", errors);
  requireString(metadata.purpose, `${pathPrefix}.purpose`, "purpose", errors);
  requireString(metadata.generator, `${pathPrefix}.generator`, "generator", errors);
  requireString(metadata.model, `${pathPrefix}.model`, "model", errors);
  requireString(metadata.date, `${pathPrefix}.date`, "date", errors);
  requireString(metadata.humanStatus, `${pathPrefix}.humanStatus`, "humanStatus", errors);
  requireString(metadata.aspect, `${pathPrefix}.aspect`, "aspect", errors);

  if (metadata.schemaVersion !== 1) {
    errors.push({ path: `${pathPrefix}.schemaVersion`, message: "schemaVersion must be 1." });
  }
  if (typeof metadata.briefId === "string" && metadata.briefId && !isReferenceBriefId(metadata.briefId)) {
    errors.push({
      path: `${pathPrefix}.briefId`,
      message: `briefId must be one of the four v0.138 brief IDs; received ${metadata.briefId}.`
    });
  }
  if (metadata.runtimeIntegrationStatus !== "forbidden") {
    errors.push({
      path: `${pathPrefix}.runtimeIntegrationStatus`,
      message: "runtimeIntegrationStatus must remain exactly `forbidden`."
    });
  }
  if (!/^\d{4}-\d{2}-\d{2}$/u.test(String(metadata.date))) {
    warnings.push({ path: `${pathPrefix}.date`, message: "date should use YYYY-MM-DD for stable review sorting." });
  }

  requireRecord(metadata.source, `${pathPrefix}.source`, errors);
  requireString(metadata.source?.type, `${pathPrefix}.source.type`, "source.type", errors);
  requireString(metadata.source?.promptDocument, `${pathPrefix}.source.promptDocument`, "source.promptDocument", errors);
  requireString(metadata.source?.notes, `${pathPrefix}.source.notes`, "source.notes", errors);

  requireRecord(metadata.licencePosture, `${pathPrefix}.licencePosture`, errors);
  requireString(metadata.licencePosture?.status, `${pathPrefix}.licencePosture.status`, "licencePosture.status", errors);
  requireString(metadata.licencePosture?.terms, `${pathPrefix}.licencePosture.terms`, "licencePosture.terms", errors);
  requireString(metadata.licencePosture?.runtimeUse, `${pathPrefix}.licencePosture.runtimeUse`, "licencePosture.runtimeUse", errors);
  requireString(metadata.licencePosture?.notes, `${pathPrefix}.licencePosture.notes`, "licencePosture.notes", errors);

  requireRecord(metadata.protectedIpReview, `${pathPrefix}.protectedIpReview`, errors);
  requireString(metadata.protectedIpReview?.status, `${pathPrefix}.protectedIpReview.status`, "protectedIpReview.status", errors);
  requireString(
    metadata.protectedIpReview?.protectedLookalikeRisk,
    `${pathPrefix}.protectedIpReview.protectedLookalikeRisk`,
    "protectedIpReview.protectedLookalikeRisk",
    errors
  );
  requireString(metadata.protectedIpReview?.notes, `${pathPrefix}.protectedIpReview.notes`, "protectedIpReview.notes", errors);

  if (!Array.isArray(metadata.visualNotes) || metadata.visualNotes.length === 0) {
    errors.push({ path: `${pathPrefix}.visualNotes`, message: "visualNotes must be a non-empty array." });
  } else if (metadata.visualNotes.some((note) => typeof note !== "string" || note.trim().length === 0)) {
    errors.push({ path: `${pathPrefix}.visualNotes`, message: "visualNotes entries must be non-empty strings." });
  }

  requireRecord(metadata.hash, `${pathPrefix}.hash`, errors);
  if (metadata.hash?.algorithm !== "sha256") {
    errors.push({ path: `${pathPrefix}.hash.algorithm`, message: "hash.algorithm must be `sha256`." });
  }
  requireString(metadata.hash?.value, `${pathPrefix}.hash.value`, "hash.value", errors);

  requireRecord(metadata.dimensions, `${pathPrefix}.dimensions`, errors);
  if (!Number.isInteger(metadata.dimensions?.width) || metadata.dimensions.width <= 0) {
    errors.push({ path: `${pathPrefix}.dimensions.width`, message: "dimensions.width must be a positive integer." });
  }
  if (!Number.isInteger(metadata.dimensions?.height) || metadata.dimensions.height <= 0) {
    errors.push({ path: `${pathPrefix}.dimensions.height`, message: "dimensions.height must be a positive integer." });
  }
  if (metadata.dimensions?.unit !== "px") {
    errors.push({ path: `${pathPrefix}.dimensions.unit`, message: "dimensions.unit must be `px`." });
  }

  requireRecord(metadata.revisionLineage, `${pathPrefix}.revisionLineage`, errors);
  if (!Number.isInteger(metadata.revisionLineage?.revision) || metadata.revisionLineage.revision < 1) {
    errors.push({
      path: `${pathPrefix}.revisionLineage.revision`,
      message: "revisionLineage.revision must be a positive integer."
    });
  }
  requireString(metadata.revisionLineage?.notes, `${pathPrefix}.revisionLineage.notes`, "revisionLineage.notes", errors);
}

function validateImageAgainstMetadata(
  metadata: ReferenceCandidateMetadata,
  image: ReferenceCandidateImageSummary,
  pathPrefix: string,
  errors: ReferenceValidationIssue[],
  warnings: ReferenceValidationIssue[]
): void {
  if (metadata.hash?.value !== image.hash) {
    errors.push({ path: `${pathPrefix}.hash.value`, message: "Metadata hash does not match the candidate image file." });
  }
  if (image.width === null || image.height === null) {
    warnings.push({
      path: `${pathPrefix}.dimensions`,
      message: "Candidate dimensions could not be read automatically; metadata dimensions were not cross-checked."
    });
    return;
  }
  if (metadata.dimensions.width !== image.width || metadata.dimensions.height !== image.height) {
    errors.push({
      path: `${pathPrefix}.dimensions`,
      message: `Metadata dimensions ${metadata.dimensions.width}x${metadata.dimensions.height} do not match image ${image.width}x${image.height}.`
    });
  }
}

function requireString(
  value: unknown,
  issuePath: string,
  fieldName: string,
  errors: ReferenceValidationIssue[]
): void {
  if (typeof value !== "string" || value.trim().length === 0) {
    errors.push({ path: issuePath, message: `${fieldName} is required.` });
  }
}

function requireRecord(value: unknown, issuePath: string, errors: ReferenceValidationIssue[]): void {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    errors.push({ path: issuePath, message: "Expected an object." });
  }
}

function determineValidationStatus(metadataCount: number, imageCount: number, errorCount: number): string {
  if (errorCount > 0) {
    return "FAIL_V0138_REFERENCE_METADATA";
  }
  if (metadataCount === 0 && imageCount === 0) {
    return "PENDING_V0138_REFERENCE_ART_CANDIDATES";
  }
  return "PASS_V0138_REFERENCE_METADATA";
}

async function writeValidationReports(projectRoot: string, summary: ReferenceValidationSummary): Promise<void> {
  const paths = referenceWorkspacePaths(projectRoot);
  const jsonPath = path.join(paths.reviewNotesDir, "reference-validation.json");
  const markdownPath = path.join(paths.reviewNotesDir, "reference-validation.md");
  await writeStableJson(jsonPath, summary);
  await writeTextFile(markdownPath, renderValidationMarkdown(summary));
}

function renderValidationMarkdown(summary: ReferenceValidationSummary): string {
  const errors = summary.errors.length === 0 ? ["- none"] : summary.errors.map((issue) => `- ${issue.path}: ${issue.message}`);
  const warnings =
    summary.warnings.length === 0 ? ["- none"] : summary.warnings.map((issue) => `- ${issue.path}: ${issue.message}`);
  return [
    "# v0.138 Reference-Art Metadata Validation",
    "",
    `Status: ${summary.status}`,
    "",
    `Checked metadata files: ${summary.checkedMetadataFiles}`,
    `Checked candidate images: ${summary.checkedCandidateImages}`,
    "",
    "## Errors",
    "",
    ...errors,
    "",
    "## Warnings",
    "",
    ...warnings,
    "",
    "Runtime integration status remains forbidden by schema and validation."
  ].join("\n");
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  validateReferenceArtWorkspace()
    .then((summary) => {
      console.log(`v0.138 reference-art validation: ${summary.status}`);
      console.log(`Metadata files: ${summary.checkedMetadataFiles}`);
      console.log(`Candidate images: ${summary.checkedCandidateImages}`);
      if (summary.warnings.length > 0) {
        console.warn("Warnings:");
        console.warn(formatIssueList(summary.warnings));
      }
      if (summary.errors.length > 0) {
        console.error("Errors:");
        console.error(formatIssueList(summary.errors));
        process.exitCode = 1;
        return;
      }
      const paths = referenceWorkspacePaths(process.cwd());
      console.log(`Report: ${relativeToProject(process.cwd(), path.join(paths.reviewNotesDir, "reference-validation.md"))}`);
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.stack ?? error.message : String(error));
      process.exitCode = 1;
    });
}
