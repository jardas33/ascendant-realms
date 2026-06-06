import path from "node:path";
import { fileURLToPath } from "node:url";
import { initializeReferenceArtWorkspace, normalizePath, relativeToProject } from "./shared";

export async function runReferenceArtInit(projectRoot = process.cwd()): Promise<void> {
  const paths = await initializeReferenceArtWorkspace(projectRoot);
  console.log("v0.138 reference-art workspace ready.");
  console.log(`Root: ${relativeToProject(projectRoot, paths.rootDir)}`);
  console.log(`Candidates: ${relativeToProject(projectRoot, paths.candidatesDir)}`);
  console.log(`Contact sheets: ${relativeToProject(projectRoot, paths.contactSheetsDir)}`);
  console.log(`Metadata: ${relativeToProject(projectRoot, paths.metadataDir)}`);
  console.log(`Review notes: ${relativeToProject(projectRoot, paths.reviewNotesDir)}`);
  console.log(`README: ${normalizePath(path.relative(projectRoot, paths.readmePath))}`);
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  runReferenceArtInit().catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
