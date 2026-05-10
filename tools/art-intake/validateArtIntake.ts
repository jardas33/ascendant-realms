import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export interface ArtIntakeValidationIssue {
  filePath: string;
  message: string;
}

export interface ArtIntakeValidationResult {
  checkedMetadataFiles: number;
  checkedManifestFiles: number;
  errors: ArtIntakeValidationIssue[];
  warnings: ArtIntakeValidationIssue[];
}

type CandidateMetadataRecord = Record<string, unknown>;

const METADATA_DIR = path.join("art-review", "cinderfen-style-frames", "metadata");
const RUNTIME_TEST_SOURCE_REQUIRED_FIELDS = ["sourceType", "createdBy", "licenseStatus", "usagePermission"];

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function field(record: CandidateMetadataRecord, key: string): string {
  const value = record[key];
  return isNonEmptyString(value) ? value.trim() : "";
}

function addIssue(issues: ArtIntakeValidationIssue[], filePath: string, message: string): void {
  issues.push({ filePath, message });
}

function isApproved(record: CandidateMetadataRecord): boolean {
  const reviewStatus = field(record, "reviewStatus");
  const productionApprovalStatus = field(record, "productionApprovalStatus");
  return reviewStatus.startsWith("approved-") || productionApprovalStatus === "approved";
}

function isSubmitted(record: CandidateMetadataRecord): boolean {
  return (
    field(record, "fileStatus") === "submitted" ||
    field(record, "submissionStatus") === "submitted" ||
    field(record, "candidateFileStatus") === "submitted"
  );
}

function isPathLikeSpec(value: string): boolean {
  return value.startsWith("docs/") || value.startsWith("http://") || value.startsWith("https://");
}

export function validateCandidateMetadataRecord(
  record: CandidateMetadataRecord,
  filePath: string,
  projectRoot: string
): Pick<ArtIntakeValidationResult, "errors" | "warnings"> {
  const errors: ArtIntakeValidationIssue[] = [];
  const warnings: ArtIntakeValidationIssue[] = [];
  const candidateId = field(record, "candidateId");
  const sourceType = field(record, "sourceType");
  const licenseStatus = field(record, "licenseStatus");
  const protectedIpRisk = field(record, "protectedIpRisk");
  const reviewStatus = field(record, "reviewStatus");
  const productionApprovalStatus = field(record, "productionApprovalStatus");
  const relatedSpecDoc = field(record, "relatedSpecDoc");

  if (!candidateId) {
    addIssue(errors, filePath, "Candidate metadata is missing candidateId.");
  }

  if (!sourceType) {
    addIssue(errors, filePath, "Candidate metadata is missing sourceType.");
  }

  if (sourceType === "unknown" && productionApprovalStatus === "approved") {
    addIssue(errors, filePath, "Candidate with unknown sourceType must not be production-approved.");
  }

  if ((licenseStatus === "unknown" || licenseStatus === "blocked") && productionApprovalStatus === "approved") {
    addIssue(errors, filePath, "Candidate with unknown or blocked licenseStatus must not be production-approved.");
  }

  if ((protectedIpRisk === "high" || protectedIpRisk === "unknown") && isApproved(record)) {
    addIssue(errors, filePath, "Candidate with high or unknown protectedIpRisk must not be approved.");
  }

  if (reviewStatus === "approved-for-runtime-test") {
    for (const requiredField of RUNTIME_TEST_SOURCE_REQUIRED_FIELDS) {
      if (!field(record, requiredField)) {
        addIssue(errors, filePath, `Runtime-test candidate is missing ${requiredField}.`);
      }
    }
    if (sourceType === "unknown") {
      addIssue(errors, filePath, "Runtime-test candidate must not use sourceType unknown.");
    }
    if (licenseStatus === "unknown" || licenseStatus === "blocked") {
      addIssue(errors, filePath, "Runtime-test candidate must have usable licenseStatus.");
    }
    if (protectedIpRisk === "high" || protectedIpRisk === "unknown") {
      addIssue(errors, filePath, "Runtime-test candidate must have low or medium protectedIpRisk.");
    }
  }

  if (reviewStatus === "rejected" && !field(record, "reasonForRejection")) {
    addIssue(errors, filePath, "Rejected candidate metadata must include reasonForRejection.");
  }

  if (!relatedSpecDoc) {
    addIssue(warnings, filePath, "Candidate metadata is missing relatedSpecDoc.");
  } else if (isPathLikeSpec(relatedSpecDoc) && relatedSpecDoc.startsWith("docs/")) {
    const specPath = path.join(projectRoot, relatedSpecDoc);
    if (!existsSync(specPath)) {
      addIssue(warnings, filePath, `relatedSpecDoc does not exist: ${relatedSpecDoc}.`);
    }
  }

  if (isSubmitted(record)) {
    const candidatePath = field(record, "filePath");
    if (!candidatePath) {
      addIssue(errors, filePath, "Submitted candidate metadata must include filePath.");
    } else if (!existsSync(path.join(projectRoot, candidatePath))) {
      addIssue(errors, filePath, `Submitted candidate file does not exist: ${candidatePath}.`);
    }
  }

  return { errors, warnings };
}

function validateReviewManifestRecord(
  record: CandidateMetadataRecord,
  filePath: string
): Pick<ArtIntakeValidationResult, "errors" | "warnings"> {
  const errors: ArtIntakeValidationIssue[] = [];
  const warnings: ArtIntakeValidationIssue[] = [];
  const candidates = record.candidates;

  if (!Array.isArray(candidates)) {
    addIssue(errors, filePath, "Review manifest is missing candidates array.");
    return { errors, warnings };
  }

  candidates.forEach((candidate, index) => {
    if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
      addIssue(errors, filePath, `Review manifest candidate ${index} must be an object.`);
      return;
    }
    const entry = candidate as CandidateMetadataRecord;
    const prefix = `Review manifest candidate ${index}`;
    if (!field(entry, "candidateId")) {
      addIssue(errors, filePath, `${prefix} is missing candidateId.`);
    }
    if (field(entry, "sourceStatus") === "unknown" && field(entry, "reviewStage") === "approved-for-runtime-test") {
      addIssue(errors, filePath, `${prefix} with unknown sourceStatus must not be approved for runtime test.`);
    }
    if (
      (field(entry, "ipRisk") === "high" || field(entry, "ipRisk") === "unknown") &&
      field(entry, "reviewStage").startsWith("approved-")
    ) {
      addIssue(errors, filePath, `${prefix} with high or unknown ipRisk must not be approved.`);
    }
  });

  return { errors, warnings };
}

function collectJsonFiles(directory: string): string[] {
  if (!existsSync(directory)) {
    return [];
  }
  const files: string[] = [];
  for (const entry of readdirSync(directory)) {
    const fullPath = path.join(directory, entry);
    const stats = statSync(fullPath);
    if (stats.isDirectory()) {
      files.push(...collectJsonFiles(fullPath));
    } else if (entry.endsWith(".json")) {
      files.push(fullPath);
    }
  }
  return files;
}

export function validateArtIntake(projectRoot = process.cwd()): ArtIntakeValidationResult {
  const result: ArtIntakeValidationResult = {
    checkedMetadataFiles: 0,
    checkedManifestFiles: 0,
    errors: [],
    warnings: []
  };
  const metadataPath = path.join(projectRoot, METADATA_DIR);
  const jsonFiles = collectJsonFiles(metadataPath);

  for (const fullPath of jsonFiles) {
    const relativePath = path.relative(projectRoot, fullPath).replaceAll("\\", "/");
    let parsed: unknown;
    try {
      parsed = JSON.parse(readFileSync(fullPath, "utf8"));
    } catch (error) {
      addIssue(result.errors, relativePath, `Invalid JSON: ${(error as Error).message}`);
      continue;
    }

    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
      addIssue(result.errors, relativePath, "Metadata JSON must contain an object.");
      continue;
    }

    const record = parsed as CandidateMetadataRecord;
    const isManifest = Array.isArray(record.candidates);
    const validation = isManifest
      ? validateReviewManifestRecord(record, relativePath)
      : validateCandidateMetadataRecord(record, relativePath, projectRoot);

    if (isManifest) {
      result.checkedManifestFiles += 1;
    } else {
      result.checkedMetadataFiles += 1;
    }
    result.errors.push(...validation.errors);
    result.warnings.push(...validation.warnings);
  }

  return result;
}

function formatIssue(issue: ArtIntakeValidationIssue): string {
  return `- ${issue.filePath}: ${issue.message}`;
}

function runCli(): void {
  const result = validateArtIntake();
  if (result.errors.length > 0) {
    console.error("Art intake validation failed:");
    console.error(result.errors.map(formatIssue).join("\n"));
    if (result.warnings.length > 0) {
      console.warn("\nWarnings:");
      console.warn(result.warnings.map(formatIssue).join("\n"));
    }
    process.exitCode = 1;
    return;
  }

  console.log("Art intake validation passed.");
  console.log(`Checked ${result.checkedMetadataFiles} candidate metadata JSON file(s).`);
  console.log(`Checked ${result.checkedManifestFiles} review manifest JSON file(s).`);
  if (result.warnings.length > 0) {
    console.warn("Warnings:");
    console.warn(result.warnings.map(formatIssue).join("\n"));
  }
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  runCli();
}
