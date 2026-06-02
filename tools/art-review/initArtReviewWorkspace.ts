import { fileURLToPath } from "node:url";
import path from "node:path";
import { initializeArtReviewWorkspace, normalizePath, parseAssetArg } from "./shared";

export async function runArtReviewInit(projectRoot = process.cwd(), assetId: string): Promise<void> {
  if (!assetId) {
    throw new Error("Usage: npm run art:review:init -- --asset <assetId>");
  }
  const result = await initializeArtReviewWorkspace(projectRoot, assetId);
  console.log(`Art review workspace ready for ${result.asset.assetId}.`);
  console.log(`Candidate directory: ${normalizePath(path.relative(projectRoot, result.paths.candidateDir))}`);
  console.log(`Contact sheet directory: ${normalizePath(path.relative(projectRoot, result.paths.contactSheetDir))}`);
  console.log(`Report directory: ${normalizePath(path.relative(projectRoot, result.paths.reportDir))}`);
  if (result.createdFiles.length > 0) {
    console.log("Created template file(s):");
    result.createdFiles.forEach((filePath) => console.log(`- ${normalizePath(path.relative(projectRoot, filePath))}`));
  } else {
    console.log("Existing template files preserved.");
  }
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  runArtReviewInit(process.cwd(), parseAssetArg(process.argv.slice(2))).catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
