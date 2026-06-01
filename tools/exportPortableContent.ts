import {
  DEFAULT_PORTABLE_CONTENT_OUT_DIR,
  writePortableContentExport,
  writeStableIdSnapshot
} from "../src/game/portable/PortableContentExport";

function valueAfter(flag: string): string | undefined {
  const index = process.argv.indexOf(flag);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

const outputDir = valueAfter("--out") ?? DEFAULT_PORTABLE_CONTENT_OUT_DIR;
const snapshotPath = valueAfter("--update-snapshot");

if (snapshotPath) {
  await writeStableIdSnapshot(snapshotPath);
  console.log(`Stable ID snapshot written to ${snapshotPath}.`);
}

const result = await writePortableContentExport(outputDir);

console.log(`Portable content exported to ${result.outputDir}.`);
console.log(`Stable ID manifest entries: ${result.stableIdManifest.entries.length}.`);
Object.entries(result.fileHashes).forEach(([fileName, hash]) => {
  console.log(`${fileName}: ${hash}`);
});
