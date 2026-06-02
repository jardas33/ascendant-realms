import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  collectCandidateMetadataFiles,
  emptyValidationResult,
  formatIssueList,
  loadVisualAssetRegistry,
  mergeValidationResults,
  normalizePath,
  readJsonFile,
  readPromptReference,
  validateCommittedRegistry,
  workspacePaths
} from "./shared";
import {
  findVisualAsset,
  validateArtReviewCandidateMetadata,
  validatePromptReferenceMetadata,
  type ArtReviewCandidateMetadata
} from "../../src/game/art/VisualAssetReviewRegistry";

export interface ArtReviewValidationSummary {
  checkedRegistry: boolean;
  checkedCandidateMetadataFiles: number;
  checkedPromptReferences: number;
  errors: Array<{ path: string; message: string }>;
  warnings: Array<{ path: string; message: string }>;
}

export async function validateArtReviewWorkspace(projectRoot = process.cwd()): Promise<ArtReviewValidationSummary> {
  const result = emptyValidationResult();
  const registryResult = await validateCommittedRegistry(projectRoot);
  mergeValidationResults(result, registryResult);

  const registry = await loadVisualAssetRegistry(projectRoot);
  const metadataFiles = await collectCandidateMetadataFiles(projectRoot);
  let checkedPromptReferences = 0;

  for (const metadataFile of metadataFiles) {
    const relativeMetadataPath = normalizePath(path.relative(projectRoot, metadataFile));
    let metadata: ArtReviewCandidateMetadata;
    try {
      metadata = await readJsonFile<ArtReviewCandidateMetadata>(metadataFile);
    } catch (error) {
      result.errors.push({
        path: relativeMetadataPath,
        message: `Invalid candidate metadata JSON: ${error instanceof Error ? error.message : String(error)}`
      });
      continue;
    }

    const metadataResult = validateArtReviewCandidateMetadata(metadata, registry);
    metadataResult.errors.forEach((issue) =>
      result.errors.push({ path: `${relativeMetadataPath}.${issue.path}`, message: issue.message })
    );
    metadataResult.warnings.forEach((issue) =>
      result.warnings.push({ path: `${relativeMetadataPath}.${issue.path}`, message: issue.message })
    );

    const asset = findVisualAsset(registry, metadata.assetId);
    if (!asset) {
      continue;
    }

    const paths = workspacePaths(projectRoot, metadata.assetId);
    const promptReference = await readPromptReference(paths);
    if (!promptReference) {
      result.errors.push({
        path: normalizePath(path.relative(projectRoot, paths.promptReferencePath)),
        message: "Candidate workspace is missing prompt-reference.json."
      });
      continue;
    }
    checkedPromptReferences += 1;
    const promptResult = validatePromptReferenceMetadata(promptReference, asset);
    const relativePromptPath = normalizePath(path.relative(projectRoot, paths.promptReferencePath));
    promptResult.errors.forEach((issue) =>
      result.errors.push({ path: `${relativePromptPath}.${issue.path}`, message: issue.message })
    );

    for (const candidateFile of metadata.candidateFiles ?? []) {
      const candidatePath = path.join(paths.imagesDir, candidateFile.filename);
      if (!existsSync(candidatePath)) {
        result.errors.push({
          path: `${relativeMetadataPath}.candidateFiles`,
          message: `Candidate file is listed but missing from images workspace: ${candidateFile.filename}.`
        });
      }
    }
  }

  return {
    checkedRegistry: true,
    checkedCandidateMetadataFiles: metadataFiles.length,
    checkedPromptReferences,
    errors: result.errors,
    warnings: result.warnings
  };
}

function runCli(): void {
  validateArtReviewWorkspace()
    .then((result) => {
      if (result.errors.length > 0) {
        console.error("Art review validation failed:");
        console.error(formatIssueList(result));
        process.exitCode = 1;
        return;
      }
      console.log("Art review validation passed.");
      console.log("Checked committed visual asset registry and schema.");
      console.log(`Checked ${result.checkedCandidateMetadataFiles} candidate metadata file(s).`);
      console.log(`Checked ${result.checkedPromptReferences} prompt reference file(s).`);
      if (result.warnings.length > 0) {
        console.warn("Warnings:");
        console.warn(result.warnings.map((issue) => `- ${issue.path}: ${issue.message}`).join("\n"));
      }
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.stack ?? error.message : String(error));
      process.exitCode = 1;
    });
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  runCli();
}
