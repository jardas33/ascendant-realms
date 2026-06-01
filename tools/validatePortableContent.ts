import {
  DEFAULT_PORTABLE_CONTENT_OUT_DIR,
  DEFAULT_STABLE_ID_SNAPSHOT_PATH,
  validatePortableContentArtifacts
} from "../src/game/portable/PortableContentExport";

function valueAfter(flag: string): string | undefined {
  const index = process.argv.indexOf(flag);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

const result = await validatePortableContentArtifacts({
  outputDir: valueAfter("--out") ?? DEFAULT_PORTABLE_CONTENT_OUT_DIR,
  snapshotPath: valueAfter("--snapshot") ?? DEFAULT_STABLE_ID_SNAPSHOT_PATH
});

if (!result.ok) {
  console.error(`Portable content validation failed with ${result.errors.length} error(s):`);
  result.errors.forEach((error) => console.error(`- ${error}`));
  process.exitCode = 1;
} else {
  console.log("Portable content validation passed.");
  console.log(`Output: ${result.outputDir}`);
  console.log(`Stable ID snapshot: ${result.snapshotPath}`);
  console.log(`Stable ID manifest entries: ${result.manifestEntryCount}`);
  console.log("Determinism: generated twice and matched byte-for-byte.");
}
