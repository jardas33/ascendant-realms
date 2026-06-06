import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  collectReferenceCandidateImages,
  initializeReferenceArtWorkspace,
  normalizePath,
  referenceWorkspacePaths,
  relativeToProject,
  type ReferenceCandidateImageSummary,
  writeStableJson,
  writeTextFile
} from "./shared";

export interface ReferenceContactSheetResult {
  status: string;
  imageCount: number;
  svgPath: string;
  manifestPath: string;
}

export async function generateReferenceArtContactSheet(projectRoot = process.cwd()): Promise<ReferenceContactSheetResult> {
  await initializeReferenceArtWorkspace(projectRoot);
  const paths = referenceWorkspacePaths(projectRoot);
  const images = await collectReferenceCandidateImages(projectRoot);
  const status = images.length === 0 ? "PENDING_V0138_CONTACT_SHEET_NO_CANDIDATES" : "PASS_V0138_REFERENCE_CONTACT_SHEET";
  const svgPath = path.join(paths.contactSheetsDir, "v0138-reference-contact-sheet.svg");
  const manifestPath = path.join(paths.contactSheetsDir, "v0138-reference-contact-sheet.json");

  await writeStableJson(manifestPath, {
    schemaVersion: 1,
    status,
    referenceOnly: true,
    runtimeIntegrationStatus: "forbidden",
    imageCount: images.length,
    images: images.map((image) => ({
      filename: image.filename,
      relativePath: image.relativePath,
      hashAlgorithm: "sha256",
      hash: image.hash,
      width: image.width,
      height: image.height
    }))
  });
  await writeTextFile(svgPath, renderContactSheetSvg(projectRoot, svgPath, status, images));
  return { status, imageCount: images.length, svgPath, manifestPath };
}

function renderContactSheetSvg(
  projectRoot: string,
  sheetPath: string,
  status: string,
  images: ReferenceCandidateImageSummary[]
): string {
  const columns = 2;
  const tileWidth = 420;
  const tileHeight = 330;
  const margin = 32;
  const headerHeight = 118;
  const rows = Math.max(1, Math.ceil(images.length / columns));
  const width = margin * 2 + columns * tileWidth;
  const height = headerHeight + margin + rows * tileHeight;
  const content =
    images.length === 0
      ? [
          `<rect x="${margin}" y="${headerHeight + 18}" width="${width - margin * 2}" height="132" rx="8" fill="#f7fafc" stroke="#c8d1dc" />`,
          `<text x="${margin + 24}" y="${headerHeight + 68}" font-family="Arial, sans-serif" font-size="22" font-weight="700" fill="#1b2836">Pending candidate images</text>`,
          `<text x="${margin + 24}" y="${headerHeight + 104}" font-family="Arial, sans-serif" font-size="16" fill="#4d5b68">Place reviewed reference-only candidates in artifacts/art-review/v0138/candidates/ and rerun.</text>`
        ].join("\n")
      : images
          .map((image, index) => {
            const column = index % columns;
            const row = Math.floor(index / columns);
            const x = margin + column * tileWidth;
            const y = headerHeight + row * tileHeight;
            const href = normalizePath(path.relative(path.dirname(sheetPath), image.absolutePath));
            const dimensions = image.width && image.height ? `${image.width}x${image.height}` : "dimensions unknown";
            const hashShort = image.hash.slice(0, 16);
            return [
              `<rect x="${x}" y="${y}" width="${tileWidth - 24}" height="${tileHeight - 28}" rx="8" fill="#fbfcfd" stroke="#c8d1dc" />`,
              `<image href="${escapeXml(href)}" x="${x + 16}" y="${y + 16}" width="${tileWidth - 56}" height="216" preserveAspectRatio="xMidYMid meet" />`,
              `<text x="${x + 16}" y="${y + 260}" font-family="Arial, sans-serif" font-size="15" fill="#1b2836">${escapeXml(
                image.filename
              )}</text>`,
              `<text x="${x + 16}" y="${y + 282}" font-family="Arial, sans-serif" font-size="13" fill="#4d5b68">${escapeXml(
                dimensions
              )} | sha256 ${escapeXml(hashShort)}</text>`,
              `<text x="${x + 16}" y="${y + 304}" font-family="Arial, sans-serif" font-size="13" fill="#4d5b68">${escapeXml(
                relativeToProject(projectRoot, image.absolutePath)
              )}</text>`
            ].join("\n");
          })
          .join("\n");

  return [
    `<?xml version="1.0" encoding="UTF-8"?>`,
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    `<rect width="100%" height="100%" fill="#ffffff" />`,
    `<text x="${margin}" y="40" font-family="Arial, sans-serif" font-size="26" font-weight="700" fill="#17202a">v0.138 Reference-Art Contact Sheet</text>`,
    `<text x="${margin}" y="70" font-family="Arial, sans-serif" font-size="15" fill="#4d5b68">Status: ${escapeXml(
      status
    )}</text>`,
    `<text x="${margin}" y="96" font-family="Arial, sans-serif" font-size="15" fill="#4d5b68">Reference-only. Runtime integration remains forbidden.</text>`,
    content,
    `</svg>`
  ].join("\n");
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
  generateReferenceArtContactSheet()
    .then((result) => {
      console.log(`v0.138 reference-art contact sheet: ${result.status}`);
      console.log(`Candidate images: ${result.imageCount}`);
      console.log(`SVG: ${relativeToProject(process.cwd(), result.svgPath)}`);
      console.log(`Manifest: ${relativeToProject(process.cwd(), result.manifestPath)}`);
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.stack ?? error.message : String(error));
      process.exitCode = 1;
    });
}
