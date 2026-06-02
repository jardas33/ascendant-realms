import path from "node:path";
import { fileURLToPath } from "node:url";
import { generateSaltoSlicePacket, validateCommittedSaltoSliceManifest } from "./saltoSliceManifest";

async function runCli(): Promise<void> {
  const validation = await validateCommittedSaltoSliceManifest();
  if (!validation.ok) {
    console.error("Salto slice manifest validation failed:");
    console.error(validation.errors.map((error) => `- ${error.path}: ${error.message}`).join("\n"));
    process.exitCode = 1;
    return;
  }

  validation.checks.forEach((check) => console.log(`[salto-slice] OK ${check}`));
  const result = await generateSaltoSlicePacket();
  console.log(`[salto-slice] generated packet: ${result.outputDir}`);
  result.files.forEach((file) => console.log(`[salto-slice] wrote ${file}`));
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : "";
if (invokedPath === fileURLToPath(import.meta.url)) {
  runCli().catch((error) => {
    console.error(error instanceof Error ? error.stack ?? error.message : String(error));
    process.exitCode = 1;
  });
}
