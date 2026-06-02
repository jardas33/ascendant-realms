import { existsSync } from "node:fs";
import { mkdir, readFile, readdir, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import {
  createCandidateMetadataTemplate,
  createPromptReferenceTemplate,
  createReviewerChecklist,
  findVisualAsset,
  validateVisualAssetRegistryDocument,
  type ArtReviewCandidateMetadata,
  type ArtReviewValidationResult,
  type PromptReferenceMetadata,
  type VisualAssetRegistry,
  type VisualAssetRegistryEntry,
  type V088AssetManifest
} from "../../src/game/art/VisualAssetReviewRegistry";

export const ART_REVIEW_ROOT = path.join("artifacts", "art-review");
export const CANDIDATE_ROOT = path.join(ART_REVIEW_ROOT, "candidates");
export const CONTACT_SHEET_ROOT = path.join(ART_REVIEW_ROOT, "contact-sheets");
export const REPORT_ROOT = path.join(ART_REVIEW_ROOT, "reports");
export const REGISTRY_PATH = path.join("src", "game", "art", "visual-asset-registry.json");
export const REGISTRY_SCHEMA_PATH = path.join("src", "game", "art", "visual-asset-registry.schema.json");
export const V088_MANIFEST_PATH = path.join("docs", "V088_VERTICAL_SLICE_ASSET_MANIFEST.json");

export interface ArtReviewWorkspacePaths {
  candidateDir: string;
  imagesDir: string;
  contactSheetDir: string;
  reportDir: string;
  metadataPath: string;
  promptReferencePath: string;
  reviewerChecklistPath: string;
}

export interface CandidateImageSummary {
  filename: string;
  relativePath: string;
  absolutePath: string;
  width: number | null;
  height: number | null;
}

export interface ArtReviewWorkspaceInitResult {
  asset: VisualAssetRegistryEntry;
  paths: ArtReviewWorkspacePaths;
  createdFiles: string[];
}

export function workspacePaths(projectRoot: string, assetId: string): ArtReviewWorkspacePaths {
  const candidateDir = path.join(projectRoot, CANDIDATE_ROOT, assetId);
  return {
    candidateDir,
    imagesDir: path.join(candidateDir, "images"),
    contactSheetDir: path.join(projectRoot, CONTACT_SHEET_ROOT, assetId),
    reportDir: path.join(projectRoot, REPORT_ROOT, assetId),
    metadataPath: path.join(candidateDir, "candidate-metadata.json"),
    promptReferencePath: path.join(candidateDir, "prompt-reference.json"),
    reviewerChecklistPath: path.join(candidateDir, "reviewer-checklist.md")
  };
}

export async function initializeArtReviewWorkspace(
  projectRoot: string,
  assetId: string
): Promise<ArtReviewWorkspaceInitResult> {
  const registry = await loadVisualAssetRegistry(projectRoot);
  const asset = requireVisualAsset(registry, assetId);
  const paths = workspacePaths(projectRoot, assetId);
  const createdFiles: string[] = [];

  await mkdir(paths.imagesDir, { recursive: true });
  await mkdir(paths.contactSheetDir, { recursive: true });
  await mkdir(paths.reportDir, { recursive: true });

  await writeJsonIfMissing(paths.metadataPath, createCandidateMetadataTemplate(asset), createdFiles);
  await writeJsonIfMissing(paths.promptReferencePath, createPromptReferenceTemplate(asset), createdFiles);
  await writeTextIfMissing(paths.reviewerChecklistPath, `${createReviewerChecklist(asset)}\n`, createdFiles);

  return { asset, paths, createdFiles };
}

export async function loadVisualAssetRegistry(projectRoot: string): Promise<VisualAssetRegistry> {
  return readJsonFile<VisualAssetRegistry>(path.join(projectRoot, REGISTRY_PATH));
}

export async function loadRegistryValidationInputs(projectRoot: string): Promise<{
  registry: VisualAssetRegistry;
  schema: unknown;
  v088Manifest: V088AssetManifest;
}> {
  const registry = await loadVisualAssetRegistry(projectRoot);
  const schema = await readJsonFile<unknown>(path.join(projectRoot, REGISTRY_SCHEMA_PATH));
  const v088Manifest = await readJsonFile<V088AssetManifest>(path.join(projectRoot, V088_MANIFEST_PATH));
  return { registry, schema, v088Manifest };
}

export function requireVisualAsset(registry: VisualAssetRegistry, assetId: string): VisualAssetRegistryEntry {
  const asset = findVisualAsset(registry, assetId);
  if (!asset) {
    throw new Error(`Unknown visual asset ID: ${assetId}`);
  }
  return asset;
}

export async function validateCommittedRegistry(projectRoot: string): Promise<ArtReviewValidationResult> {
  const { registry, schema, v088Manifest } = await loadRegistryValidationInputs(projectRoot);
  const result = validateVisualAssetRegistryDocument(registry, v088Manifest);
  if (!schema || typeof schema !== "object" || Array.isArray(schema)) {
    result.errors.push({ path: REGISTRY_SCHEMA_PATH, message: "Registry schema JSON must be an object." });
  }
  return result;
}

export async function readCandidateMetadata(paths: ArtReviewWorkspacePaths): Promise<ArtReviewCandidateMetadata | undefined> {
  if (!existsSync(paths.metadataPath)) {
    return undefined;
  }
  return readJsonFile<ArtReviewCandidateMetadata>(paths.metadataPath);
}

export async function readPromptReference(paths: ArtReviewWorkspacePaths): Promise<PromptReferenceMetadata | undefined> {
  if (!existsSync(paths.promptReferencePath)) {
    return undefined;
  }
  return readJsonFile<PromptReferenceMetadata>(paths.promptReferencePath);
}

export async function collectCandidateImages(paths: ArtReviewWorkspacePaths): Promise<CandidateImageSummary[]> {
  if (!existsSync(paths.imagesDir)) {
    return [];
  }
  const entries = await readdir(paths.imagesDir, { withFileTypes: true });
  const images: CandidateImageSummary[] = [];
  for (const entry of entries) {
    if (!entry.isFile() || !isCandidateImageFile(entry.name)) {
      continue;
    }
    const absolutePath = path.join(paths.imagesDir, entry.name);
    const dimensions = await readImageDimensions(absolutePath);
    images.push({
      filename: entry.name,
      relativePath: normalizePath(path.relative(process.cwd(), absolutePath)),
      absolutePath,
      width: dimensions?.width ?? null,
      height: dimensions?.height ?? null
    });
  }
  return images.sort((left, right) => left.filename.localeCompare(right.filename));
}

export async function collectCandidateMetadataFiles(projectRoot: string): Promise<string[]> {
  const root = path.join(projectRoot, CANDIDATE_ROOT);
  if (!existsSync(root)) {
    return [];
  }
  const files: string[] = [];
  await visitJsonFiles(root, files);
  return files.filter((file) => path.basename(file) === "candidate-metadata.json").sort();
}

export async function ensureDirectoryForFile(filePath: string): Promise<void> {
  await mkdir(path.dirname(filePath), { recursive: true });
}

export async function writeStableJson(filePath: string, value: unknown): Promise<void> {
  await ensureDirectoryForFile(filePath);
  await writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

export function normalizePath(value: string): string {
  return value.replaceAll("\\", "/");
}

export function parseAssetArg(args: string[]): string {
  const option = args.find((arg) => arg.startsWith("--asset="));
  if (option) {
    return option.slice("--asset=".length).trim();
  }
  const assetIndex = args.indexOf("--asset");
  if (assetIndex >= 0) {
    return args[assetIndex + 1]?.trim() ?? "";
  }
  return "";
}

export function formatIssueList(result: ArtReviewValidationResult): string {
  return result.errors.map((issue) => `- ${issue.path}: ${issue.message}`).join("\n");
}

export function mergeValidationResults(target: ArtReviewValidationResult, source: ArtReviewValidationResult): void {
  target.errors.push(...source.errors);
  target.warnings.push(...source.warnings);
}

export function emptyValidationResult(): ArtReviewValidationResult {
  return { errors: [], warnings: [] };
}

export async function readJsonFile<T>(filePath: string): Promise<T> {
  return JSON.parse(await readFile(filePath, "utf8")) as T;
}

async function writeJsonIfMissing(filePath: string, value: unknown, createdFiles: string[]): Promise<void> {
  if (existsSync(filePath)) {
    return;
  }
  await writeStableJson(filePath, value);
  createdFiles.push(normalizePath(filePath));
}

async function writeTextIfMissing(filePath: string, value: string, createdFiles: string[]): Promise<void> {
  if (existsSync(filePath)) {
    return;
  }
  await ensureDirectoryForFile(filePath);
  await writeFile(filePath, value, "utf8");
  createdFiles.push(normalizePath(filePath));
}

async function visitJsonFiles(directory: string, files: string[]): Promise<void> {
  const entries = await readdir(directory, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      await visitJsonFiles(fullPath, files);
      continue;
    }
    if (entry.isFile() && entry.name.endsWith(".json")) {
      files.push(fullPath);
    }
  }
}

function isCandidateImageFile(filename: string): boolean {
  return /\.(?:png|jpe?g|webp)$/iu.test(filename);
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
  while (offset < buffer.length) {
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
