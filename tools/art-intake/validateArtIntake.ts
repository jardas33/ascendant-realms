import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { inflateSync } from "node:zlib";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { VISUAL_ASSET_MANIFEST } from "../../src/game/assets/visualAssetManifest";
import type { VisualAssetPresentationMetadata } from "../../src/game/assets/VisualAssetManifestTypes";

export interface ArtIntakeValidationIssue {
  filePath: string;
  message: string;
}

export interface ArtIntakeValidationResult {
  checkedMetadataFiles: number;
  checkedManifestFiles: number;
  checkedPresentationMetadata: number;
  errors: ArtIntakeValidationIssue[];
  warnings: ArtIntakeValidationIssue[];
}

type CandidateMetadataRecord = Record<string, unknown>;

const METADATA_DIR = path.join("art-review", "cinderfen-style-frames", "metadata");
const RUNTIME_TEST_SOURCE_REQUIRED_FIELDS = ["sourceType", "createdBy", "licenseStatus", "usagePermission"];
const CONTENT_AWARE_ASSET_IDS = new Set([
  "warlord_hero_battle_sprite",
  "militia_unit_sprite",
  "ranger_unit_sprite"
]);
const PNG_SIGNATURE = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

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

interface DecodedRgbaPng {
  readonly width: number;
  readonly height: number;
  readonly rgba: Uint8Array;
}

function paeth(a: number, b: number, c: number): number {
  const p = a + b - c;
  const pa = Math.abs(p - a);
  const pb = Math.abs(p - b);
  const pc = Math.abs(p - c);
  return pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
}

function decodeRgbaPng(filePath: string): DecodedRgbaPng {
  const data = readFileSync(filePath);
  if (!data.subarray(0, 8).equals(PNG_SIGNATURE)) {
    throw new Error("PNG signature is invalid.");
  }
  let offset = 8;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  const compressed: Buffer[] = [];
  while (offset + 12 <= data.length) {
    const length = data.readUInt32BE(offset);
    const type = data.toString("ascii", offset + 4, offset + 8);
    const start = offset + 8;
    const end = start + length;
    if (end + 4 > data.length) {
      throw new Error("PNG chunk exceeds file bounds.");
    }
    if (type === "IHDR") {
      width = data.readUInt32BE(start);
      height = data.readUInt32BE(start + 4);
      bitDepth = data[start + 8];
      colorType = data[start + 9];
    } else if (type === "IDAT") {
      compressed.push(data.subarray(start, end));
    } else if (type === "IEND") {
      break;
    }
    offset = end + 4;
  }
  if (!width || !height || bitDepth !== 8 || colorType !== 6 || compressed.length === 0) {
    throw new Error("Only 8-bit RGBA PNG sources are supported for metadata verification.");
  }
  const raw = inflateSync(Buffer.concat(compressed));
  const bytesPerPixel = 4;
  const rowLength = width * bytesPerPixel;
  const expectedLength = height * (rowLength + 1);
  if (raw.length < expectedLength) {
    throw new Error("PNG scanline data is truncated.");
  }
  const rgba = new Uint8Array(width * height * 4);
  let rawOffset = 0;
  const previous = new Uint8Array(rowLength);
  for (let y = 0; y < height; y += 1) {
    const filter = raw[rawOffset++];
    const row = new Uint8Array(raw.subarray(rawOffset, rawOffset + rowLength));
    rawOffset += rowLength;
    for (let x = 0; x < rowLength; x += 1) {
      const left = x >= bytesPerPixel ? row[x - bytesPerPixel] : 0;
      const above = previous[x];
      const upperLeft = x >= bytesPerPixel ? previous[x - bytesPerPixel] : 0;
      if (filter === 1) row[x] = (row[x] + left) & 0xff;
      else if (filter === 2) row[x] = (row[x] + above) & 0xff;
      else if (filter === 3) row[x] = (row[x] + Math.floor((left + above) / 2)) & 0xff;
      else if (filter === 4) row[x] = (row[x] + paeth(left, above, upperLeft)) & 0xff;
      else if (filter !== 0) throw new Error(`Unsupported PNG filter type: ${filter}.`);
    }
    rgba.set(row, y * rowLength);
    previous.set(row);
  }
  return { width, height, rgba };
}

function recomputeAlphaBounds(
  png: DecodedRgbaPng,
  alphaThreshold: number
): VisualAssetPresentationMetadata["alphaContentBounds"] {
  let left = png.width;
  let top = png.height;
  let right = -1;
  let bottom = -1;
  for (let y = 0; y < png.height; y += 1) {
    for (let x = 0; x < png.width; x += 1) {
      if (png.rgba[(y * png.width + x) * 4 + 3] <= alphaThreshold) continue;
      left = Math.min(left, x);
      top = Math.min(top, y);
      right = Math.max(right, x + 1);
      bottom = Math.max(bottom, y + 1);
    }
  }
  return {
    left: left / png.width,
    top: top / png.height,
    right: right / png.width,
    bottom: bottom / png.height
  };
}

function sameFloat(a: number, b: number): boolean {
  return Math.abs(a - b) <= 1e-9;
}

function validatePresentationMetadata(projectRoot: string, result: ArtIntakeValidationResult): void {
  const sourceRoot = path.join(projectRoot, "public", "assets", "final", "units");
  if (!existsSync(sourceRoot)) return;
  const entries = VISUAL_ASSET_MANIFEST.assets.filter((entry) => entry.presentationMetadata);
  const actualIds = new Set(entries.map((entry) => entry.id));
  if (entries.length !== CONTENT_AWARE_ASSET_IDS.size || [...CONTENT_AWARE_ASSET_IDS].some((id) => !actualIds.has(id))) {
    addIssue(result.errors, "src/game/assets/visualAssetManifest.ts", "Content-aware humanoid metadata must cover exactly the three authorized asset IDs.");
    return;
  }
  for (const entry of entries) {
    const metadata = entry.presentationMetadata;
    if (!metadata) continue;
    result.checkedPresentationMetadata += 1;
    const sourcePath = path.join(projectRoot, entry.filePath);
    if (!existsSync(sourcePath)) {
      addIssue(result.errors, entry.filePath, "Content-aware metadata source file does not exist.");
      continue;
    }
    try {
      const png = decodeRgbaPng(sourcePath);
      if (png.width !== metadata.sourceCanvas.width || png.height !== metadata.sourceCanvas.height) {
        addIssue(result.errors, entry.filePath, `Source canvas ${png.width}x${png.height} disagrees with committed metadata.`);
        continue;
      }
      const actualBounds = recomputeAlphaBounds(png, metadata.alphaThreshold);
      const expected = metadata.alphaContentBounds;
      if (!(sameFloat(actualBounds.left, expected.left) && sameFloat(actualBounds.top, expected.top) && sameFloat(actualBounds.right, expected.right) && sameFloat(actualBounds.bottom, expected.bottom))) {
        addIssue(result.errors, entry.filePath, "Committed alpha-content bounds disagree with the source PNG at the declared threshold.");
      }
      if (metadata.feetAnchor.x < expected.left || metadata.feetAnchor.x > expected.right || metadata.feetAnchor.y < expected.top || metadata.feetAnchor.y > expected.bottom) {
        addIssue(result.errors, entry.filePath, "Committed feet anchor is outside the declared alpha-content bounds.");
      }
    } catch (error) {
      addIssue(result.errors, entry.filePath, `Unable to verify content-aware metadata: ${(error as Error).message}`);
    }
  }
}

export function validateArtIntake(projectRoot = process.cwd()): ArtIntakeValidationResult {
  const result: ArtIntakeValidationResult = {
    checkedMetadataFiles: 0,
    checkedManifestFiles: 0,
    checkedPresentationMetadata: 0,
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

  validatePresentationMetadata(projectRoot, result);

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
  console.log(`Checked ${result.checkedPresentationMetadata} content-aware presentation metadata record(s).`);
  if (result.warnings.length > 0) {
    console.warn("Warnings:");
    console.warn(result.warnings.map(formatIssue).join("\n"));
  }
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  runCli();
}
