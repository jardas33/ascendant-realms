import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  collectCandidateImages,
  loadVisualAssetRegistry,
  normalizePath,
  parseAssetArg,
  readCandidateMetadata,
  requireVisualAsset,
  workspacePaths,
  writeStableJson
} from "./shared";

export interface ArtReviewContactSheetResult {
  assetId: string;
  imageCount: number;
  svgPath: string;
  manifestPath: string;
}

export async function generateArtReviewContactSheet(
  projectRoot = process.cwd(),
  assetId: string
): Promise<ArtReviewContactSheetResult> {
  if (!assetId) {
    throw new Error("Usage: npm run art:review:contact-sheet -- --asset <assetId>");
  }

  const registry = await loadVisualAssetRegistry(projectRoot);
  const asset = requireVisualAsset(registry, assetId);
  const paths = workspacePaths(projectRoot, assetId);
  const metadata = await readCandidateMetadata(paths);
  const images = await collectCandidateImages(paths);
  const svgPath = path.join(paths.contactSheetDir, "contact-sheet.svg");
  const manifestPath = path.join(paths.contactSheetDir, "contact-sheet.json");
  const promptVersion = metadata?.prompt.promptVersion || asset.promptVersion;
  const reviewState = metadata?.reviewState || asset.reviewState;

  const svg = renderContactSheetSvg({
    assetId,
    promptVersion,
    reviewState,
    sheetPath: svgPath,
    images
  });

  await writeStableJson(manifestPath, {
    schemaVersion: 1,
    assetId,
    promptVersion,
    reviewState,
    imageCount: images.length,
    images: images.map((image) => ({
      filename: image.filename,
      width: image.width,
      height: image.height,
      relativePath: normalizePath(path.relative(projectRoot, image.absolutePath))
    }))
  });
  await writeSvg(svgPath, svg);

  return { assetId, imageCount: images.length, svgPath, manifestPath };
}

function renderContactSheetSvg(input: {
  assetId: string;
  promptVersion: string;
  reviewState: string;
  sheetPath: string;
  images: Awaited<ReturnType<typeof collectCandidateImages>>;
}): string {
  const columns = 3;
  const tileWidth = 360;
  const tileHeight = 300;
  const margin = 32;
  const headerHeight = 92;
  const rows = Math.max(1, Math.ceil(input.images.length / columns));
  const width = margin * 2 + columns * tileWidth;
  const height = headerHeight + margin + rows * tileHeight;
  const imageElements =
    input.images.length === 0
      ? `<text x="${margin}" y="${headerHeight + 56}" font-family="Arial, sans-serif" font-size="22" fill="#4f5f6b">No candidates found in images workspace.</text>`
      : input.images
          .map((image, index) => {
            const column = index % columns;
            const row = Math.floor(index / columns);
            const x = margin + column * tileWidth;
            const y = headerHeight + row * tileHeight;
            const href = normalizePath(path.relative(path.dirname(input.sheetPath), image.absolutePath));
            const dimensions = image.width && image.height ? `${image.width}x${image.height}` : "dimensions unknown";
            return [
              `<rect x="${x}" y="${y}" width="${tileWidth - 24}" height="${tileHeight - 28}" rx="8" fill="#f7fafc" stroke="#c7d0d9" />`,
              `<image href="${escapeXml(href)}" x="${x + 16}" y="${y + 16}" width="${tileWidth - 56}" height="188" preserveAspectRatio="xMidYMid meet" />`,
              `<text x="${x + 16}" y="${y + 228}" font-family="Arial, sans-serif" font-size="15" fill="#182631">${escapeXml(
                image.filename
              )}</text>`,
              `<text x="${x + 16}" y="${y + 250}" font-family="Arial, sans-serif" font-size="13" fill="#4f5f6b">${escapeXml(
                dimensions
              )} | ${escapeXml(input.assetId)}</text>`,
              `<text x="${x + 16}" y="${y + 270}" font-family="Arial, sans-serif" font-size="13" fill="#4f5f6b">Prompt ${escapeXml(
                input.promptVersion
              )} | ${escapeXml(input.reviewState)}</text>`
            ].join("\n");
          })
          .join("\n");

  return [
    `<?xml version="1.0" encoding="UTF-8"?>`,
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    `<rect width="100%" height="100%" fill="#ffffff" />`,
    `<text x="${margin}" y="38" font-family="Arial, sans-serif" font-size="24" font-weight="700" fill="#17202a">${escapeXml(
      input.assetId
    )}</text>`,
    `<text x="${margin}" y="66" font-family="Arial, sans-serif" font-size="15" fill="#4f5f6b">Prompt ${escapeXml(
      input.promptVersion
    )} | ${escapeXml(input.reviewState)} | reference-only:not-runtime</text>`,
    imageElements,
    `</svg>`
  ].join("\n");
}

async function writeSvg(filePath: string, svg: string): Promise<void> {
  const { ensureDirectoryForFile } = await import("./shared");
  const { writeFile } = await import("node:fs/promises");
  await ensureDirectoryForFile(filePath);
  await writeFile(filePath, `${svg}\n`, "utf8");
}

function escapeXml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  generateArtReviewContactSheet(process.cwd(), parseAssetArg(process.argv.slice(2)))
    .then((result) => {
      console.log(`Art review contact sheet generated for ${result.assetId}.`);
      console.log(`Candidates: ${result.imageCount}`);
      console.log(`SVG: ${normalizePath(path.relative(process.cwd(), result.svgPath))}`);
      console.log(`Manifest: ${normalizePath(path.relative(process.cwd(), result.manifestPath))}`);
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.message : String(error));
      process.exitCode = 1;
    });
}
