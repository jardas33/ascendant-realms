import { existsSync } from "node:fs";
import { writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  collectCandidateImages,
  ensureDirectoryForFile,
  loadVisualAssetRegistry,
  normalizePath,
  parseAssetArg,
  readCandidateMetadata,
  readPromptReference,
  requireVisualAsset,
  workspacePaths,
  writeStableJson
} from "./shared";

export interface ArtReviewReportResult {
  assetId: string;
  markdownPath: string;
  jsonPath: string;
}

export async function generateArtReviewReport(projectRoot = process.cwd(), assetId: string): Promise<ArtReviewReportResult> {
  if (!assetId) {
    throw new Error("Usage: npm run art:review:report -- --asset <assetId>");
  }

  const registry = await loadVisualAssetRegistry(projectRoot);
  const asset = requireVisualAsset(registry, assetId);
  const paths = workspacePaths(projectRoot, assetId);
  const metadata = await readCandidateMetadata(paths);
  const promptReference = await readPromptReference(paths);
  const images = await collectCandidateImages(paths);
  const contactSheetSvg = path.join(paths.contactSheetDir, "contact-sheet.svg");
  const report = {
    schemaVersion: 1,
    assetId,
    category: asset.category,
    faction: asset.faction,
    registryReviewState: asset.reviewState,
    workspaceReviewState: metadata?.reviewState ?? "no-workspace-metadata",
    runtimeSlot: asset.runtimeSlot,
    integrationReadiness: metadata?.integrationReadiness ?? asset.integrationReadiness,
    promptVersion: metadata?.prompt.promptVersion ?? asset.promptVersion,
    promptReferencePresent: Boolean(promptReference),
    candidateCount: images.length,
    candidates: images.map((image) => ({
      filename: image.filename,
      dimensions: image.width && image.height ? `${image.width}x${image.height}` : "unknown",
      reviewStatus: metadata?.candidateFiles.find((candidate) => candidate.filename === image.filename)?.reviewStatus ?? "not-reviewed"
    })),
    contactSheet: existsSync(contactSheetSvg) ? normalizePath(path.relative(projectRoot, contactSheetSvg)) : "not-generated",
    sourceTool: metadata?.source.tool ?? "",
    sourceModel: metadata?.source.model ?? "",
    licenseTerms: metadata?.license.terms ?? asset.license,
    protectedIpAssessment: metadata?.protectedIp.assessment ?? asset.protectedIpPosture,
    humanReviewer: metadata?.humanReview.reviewer ?? "",
    runtimePosture: metadata?.runtimeSlotPosture.posture ?? asset.runtimeSlot,
    referenceOnly: true
  };

  const jsonPath = path.join(paths.reportDir, "art-review-report.json");
  const markdownPath = path.join(paths.reportDir, "art-review-report.md");
  await writeStableJson(jsonPath, report);
  await ensureDirectoryForFile(markdownPath);
  await writeFile(markdownPath, `${renderMarkdownReport(report)}\n`, "utf8");

  return { assetId, markdownPath, jsonPath };
}

function renderMarkdownReport(report: {
  assetId: string;
  category: string;
  faction: string;
  registryReviewState: string;
  workspaceReviewState: string;
  runtimeSlot: string;
  integrationReadiness: string;
  promptVersion: string;
  promptReferencePresent: boolean;
  candidateCount: number;
  candidates: Array<{ filename: string; dimensions: string; reviewStatus: string }>;
  contactSheet: string;
  sourceTool: string;
  sourceModel: string;
  licenseTerms: string;
  protectedIpAssessment: string;
  humanReviewer: string;
  runtimePosture: string;
  referenceOnly: boolean;
}): string {
  const candidateRows =
    report.candidates.length === 0
      ? ["| none | n/a | n/a |"]
      : report.candidates.map((candidate) =>
          `| ${candidate.filename} | ${candidate.dimensions} | ${candidate.reviewStatus} |`
        );
  return [
    `# Art Review Report: ${report.assetId}`,
    "",
    "Status: deterministic local summary. Reference-only; not runtime approval.",
    "",
    "## Asset",
    "",
    `- Category: ${report.category}`,
    `- Faction: ${report.faction}`,
    `- Registry state: ${report.registryReviewState}`,
    `- Workspace state: ${report.workspaceReviewState}`,
    `- Runtime slot: ${report.runtimeSlot}`,
    `- Integration readiness: ${report.integrationReadiness}`,
    "",
    "## Metadata",
    "",
    `- Prompt version: ${report.promptVersion}`,
    `- Prompt reference present: ${report.promptReferencePresent ? "yes" : "no"}`,
    `- Source tool: ${report.sourceTool || "not-recorded"}`,
    `- Source model: ${report.sourceModel || "not-recorded"}`,
    `- License terms: ${report.licenseTerms || "not-recorded"}`,
    `- Protected-IP assessment: ${report.protectedIpAssessment || "not-recorded"}`,
    `- Human reviewer: ${report.humanReviewer || "not-reviewed"}`,
    `- Runtime posture: ${report.runtimePosture}`,
    "",
    "## Candidates",
    "",
    "| Filename | Dimensions | Review status |",
    "| --- | --- | --- |",
    ...candidateRows,
    "",
    "## Outputs",
    "",
    `- Candidate count: ${report.candidateCount}`,
    `- Contact sheet: ${report.contactSheet}`,
    `- Reference-only: ${report.referenceOnly ? "yes" : "no"}`
  ].join("\n");
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  generateArtReviewReport(process.cwd(), parseAssetArg(process.argv.slice(2)))
    .then((result) => {
      console.log(`Art review report generated for ${result.assetId}.`);
      console.log(`Markdown: ${normalizePath(path.relative(process.cwd(), result.markdownPath))}`);
      console.log(`JSON: ${normalizePath(path.relative(process.cwd(), result.jsonPath))}`);
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.message : String(error));
      process.exitCode = 1;
    });
}
