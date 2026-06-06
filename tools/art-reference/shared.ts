import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { mkdir, readFile, readdir, stat, writeFile } from "node:fs/promises";
import path from "node:path";

export const REFERENCE_ART_ROOT = path.join("artifacts", "art-review", "v0138");
export const REFERENCE_CANDIDATES_DIR = path.join(REFERENCE_ART_ROOT, "candidates");
export const REFERENCE_CONTACT_SHEETS_DIR = path.join(REFERENCE_ART_ROOT, "contact-sheets");
export const REFERENCE_METADATA_DIR = path.join(REFERENCE_ART_ROOT, "metadata");
export const REFERENCE_REVIEW_NOTES_DIR = path.join(REFERENCE_ART_ROOT, "review-notes");
export const REFERENCE_WORKSPACE_README = path.join(REFERENCE_ART_ROOT, "README.md");

export const REFERENCE_BRIEF_IDS = [
  "V0138_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME",
  "V0138_02_HUD_STYLE_FRAME",
  "V0138_03_ASTER_HERO_SILHOUETTE_SHEET",
  "V0138_04_WORKER_SILHOUETTE_SHEET"
] as const;

export type ReferenceBriefId = (typeof REFERENCE_BRIEF_IDS)[number];

export interface ReferenceCandidateMetadata {
  schemaVersion: 1;
  candidateId: string;
  briefId: ReferenceBriefId | string;
  purpose: string;
  generator: string;
  model: string;
  date: string;
  source: {
    type: string;
    promptDocument: string;
    candidateImagePath?: string;
    notes: string;
  };
  licencePosture: {
    status: string;
    terms: string;
    runtimeUse: string;
    notes: string;
  };
  protectedIpReview: {
    status: string;
    protectedLookalikeRisk: string;
    notes: string;
  };
  visualNotes: string[];
  humanStatus: string;
  runtimeIntegrationStatus: "forbidden";
  hash: {
    algorithm: "sha256";
    value: string;
  };
  dimensions: {
    width: number;
    height: number;
    unit: "px";
  };
  aspect: string;
  revisionLineage: {
    parentCandidateId: string | null;
    revision: number;
    notes: string;
  };
}

export interface ReferenceWorkspacePaths {
  rootDir: string;
  candidatesDir: string;
  contactSheetsDir: string;
  metadataDir: string;
  reviewNotesDir: string;
  readmePath: string;
}

export interface ReferenceCandidateImageSummary {
  filename: string;
  relativePath: string;
  absolutePath: string;
  width: number | null;
  height: number | null;
  hash: string;
}

export interface ReferenceValidationIssue {
  path: string;
  message: string;
}

export interface ReferenceValidationSummary {
  status: string;
  checkedMetadataFiles: number;
  checkedCandidateImages: number;
  errors: ReferenceValidationIssue[];
  warnings: ReferenceValidationIssue[];
}

export function referenceWorkspacePaths(projectRoot: string): ReferenceWorkspacePaths {
  return {
    rootDir: path.join(projectRoot, REFERENCE_ART_ROOT),
    candidatesDir: path.join(projectRoot, REFERENCE_CANDIDATES_DIR),
    contactSheetsDir: path.join(projectRoot, REFERENCE_CONTACT_SHEETS_DIR),
    metadataDir: path.join(projectRoot, REFERENCE_METADATA_DIR),
    reviewNotesDir: path.join(projectRoot, REFERENCE_REVIEW_NOTES_DIR),
    readmePath: path.join(projectRoot, REFERENCE_WORKSPACE_README)
  };
}

export async function initializeReferenceArtWorkspace(projectRoot = process.cwd()): Promise<ReferenceWorkspacePaths> {
  const paths = referenceWorkspacePaths(projectRoot);
  await mkdir(paths.candidatesDir, { recursive: true });
  await mkdir(paths.contactSheetsDir, { recursive: true });
  await mkdir(paths.metadataDir, { recursive: true });
  await mkdir(paths.reviewNotesDir, { recursive: true });
  if (!existsSync(paths.readmePath)) {
    await writeFile(paths.readmePath, `${renderWorkspaceReadme()}\n`, "utf8");
  }
  return paths;
}

export function renderWorkspaceReadme(): string {
  return [
    "# v0.138 Reference-Art Workspace",
    "",
    "This ignored workspace is for reference-only candidate images generated outside the repo.",
    "",
    "Folders:",
    "",
    "- `candidates/`: manually placed image candidates for review only.",
    "- `metadata/`: one JSON metadata record per candidate.",
    "- `contact-sheets/`: generated SVG and manifest outputs.",
    "- `review-notes/`: generated validation and review-pack reports.",
    "",
    "Rules:",
    "",
    "- Do not place runtime assets here.",
    "- Do not import these images into Godot or the browser runtime.",
    "- Every metadata record must keep `runtimeIntegrationStatus` set to `forbidden`.",
    "- Candidate files remain local until a future, separately authorized art-intake decision."
  ].join("\n");
}

export async function collectReferenceCandidateImages(
  projectRoot = process.cwd()
): Promise<ReferenceCandidateImageSummary[]> {
  const paths = referenceWorkspacePaths(projectRoot);
  if (!existsSync(paths.candidatesDir)) {
    return [];
  }

  const files: string[] = [];
  await visitFiles(paths.candidatesDir, files);
  const images: ReferenceCandidateImageSummary[] = [];
  for (const filePath of files.filter(isCandidateImageFile).sort()) {
    const dimensions = await readImageDimensions(filePath);
    images.push({
      filename: normalizePath(path.relative(paths.candidatesDir, filePath)),
      relativePath: normalizePath(path.relative(projectRoot, filePath)),
      absolutePath: filePath,
      width: dimensions?.width ?? null,
      height: dimensions?.height ?? null,
      hash: await sha256File(filePath)
    });
  }
  return images;
}

export async function collectReferenceMetadataFiles(projectRoot = process.cwd()): Promise<string[]> {
  const paths = referenceWorkspacePaths(projectRoot);
  if (!existsSync(paths.metadataDir)) {
    return [];
  }
  const files: string[] = [];
  await visitFiles(paths.metadataDir, files);
  return files.filter((filePath) => path.extname(filePath).toLowerCase() === ".json").sort();
}

export async function readJsonFile<T>(filePath: string): Promise<T> {
  return JSON.parse(await readFile(filePath, "utf8")) as T;
}

export async function writeStableJson(filePath: string, value: unknown): Promise<void> {
  await ensureDirectoryForFile(filePath);
  await writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

export async function writeTextFile(filePath: string, value: string): Promise<void> {
  await ensureDirectoryForFile(filePath);
  await writeFile(filePath, `${value}\n`, "utf8");
}

export async function ensureDirectoryForFile(filePath: string): Promise<void> {
  await mkdir(path.dirname(filePath), { recursive: true });
}

export function normalizePath(value: string): string {
  return value.replaceAll("\\", "/");
}

export function relativeToProject(projectRoot: string, filePath: string): string {
  return normalizePath(path.relative(projectRoot, filePath));
}

export function formatIssueList(issues: ReferenceValidationIssue[]): string {
  return issues.map((issue) => `- ${issue.path}: ${issue.message}`).join("\n");
}

export function isReferenceBriefId(value: string): value is ReferenceBriefId {
  return REFERENCE_BRIEF_IDS.includes(value as ReferenceBriefId);
}

export function imageSummaryByRelativePath(
  images: ReferenceCandidateImageSummary[]
): Map<string, ReferenceCandidateImageSummary> {
  const summaries = new Map<string, ReferenceCandidateImageSummary>();
  for (const image of images) {
    summaries.set(normalizePath(image.relativePath), image);
    summaries.set(normalizePath(image.filename), image);
  }
  return summaries;
}

async function visitFiles(directory: string, files: string[]): Promise<void> {
  const entries = await readdir(directory, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      await visitFiles(fullPath, files);
      continue;
    }
    if (entry.isFile()) {
      files.push(fullPath);
    }
  }
}

function isCandidateImageFile(filePath: string): boolean {
  return /\.(?:png|jpe?g|webp)$/iu.test(filePath);
}

async function sha256File(filePath: string): Promise<string> {
  const buffer = await readFile(filePath);
  return createHash("sha256").update(buffer).digest("hex");
}

async function readImageDimensions(filePath: string): Promise<{ width: number; height: number } | undefined> {
  const file = await stat(filePath);
  if (file.size < 24) {
    return undefined;
  }
  const buffer = Buffer.from(await readFile(filePath));
  if (isPng(buffer)) {
    return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20) };
  }
  if (isJpeg(buffer)) {
    return readJpegDimensions(buffer);
  }
  return undefined;
}

function isPng(buffer: Buffer): boolean {
  return (
    buffer.length >= 24 &&
    buffer[0] === 0x89 &&
    buffer[1] === 0x50 &&
    buffer[2] === 0x4e &&
    buffer[3] === 0x47 &&
    buffer[12] === 0x49 &&
    buffer[13] === 0x48 &&
    buffer[14] === 0x44 &&
    buffer[15] === 0x52
  );
}

function isJpeg(buffer: Buffer): boolean {
  return buffer.length >= 4 && buffer[0] === 0xff && buffer[1] === 0xd8;
}

function readJpegDimensions(buffer: Buffer): { width: number; height: number } | undefined {
  let offset = 2;
  while (offset < buffer.length - 9) {
    if (buffer[offset] !== 0xff) {
      offset += 1;
      continue;
    }
    const marker = buffer[offset + 1];
    const segmentLength = buffer.readUInt16BE(offset + 2);
    if (marker >= 0xc0 && marker <= 0xc3 && offset + 8 < buffer.length) {
      return {
        height: buffer.readUInt16BE(offset + 5),
        width: buffer.readUInt16BE(offset + 7)
      };
    }
    offset += 2 + segmentLength;
  }
  return undefined;
}
