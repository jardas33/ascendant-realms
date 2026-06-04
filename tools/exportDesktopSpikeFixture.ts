import {
  DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR,
  writeDesktopSpikeFixtureExport
} from "../src/game/desktop-spike/DesktopSpikeFixture";

function valueAfter(flag: string): string | undefined {
  const index = process.argv.indexOf(flag);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

const outputDir = valueAfter("--out") ?? DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR;
const result = await writeDesktopSpikeFixtureExport(outputDir);

console.log(`Desktop spike fixture exported to ${result.outputDir}.`);
console.log(`Fixture hash: ${result.hashes.fixtureHash}.`);
Object.entries(result.hashes.files).forEach(([fileName, hash]) => {
  console.log(`${fileName}: ${hash}`);
});
