import {
  DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR,
  DESKTOP_SPIKE_SCORECARD_TEMPLATE_PATH,
  validateDesktopSpikeFixtureArtifacts
} from "../src/game/desktop-spike/DesktopSpikeFixture";

function valueAfter(flag: string): string | undefined {
  const index = process.argv.indexOf(flag);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

const result = await validateDesktopSpikeFixtureArtifacts({
  outputDir: valueAfter("--out") ?? DEFAULT_DESKTOP_SPIKE_FIXTURE_OUT_DIR,
  scorecardPath: valueAfter("--scorecard") ?? DESKTOP_SPIKE_SCORECARD_TEMPLATE_PATH
});

if (!result.ok) {
  console.error(`Desktop spike fixture validation failed with ${result.errors.length} error(s):`);
  result.errors.forEach((error) => console.error(`- ${error}`));
  process.exitCode = 1;
} else {
  console.log("Desktop spike fixture validation passed.");
  console.log(`Output: ${result.outputDir}`);
  console.log(`Fixture hash: ${result.fixtureHash}`);
  console.log(`Determinism: generated twice and matched ${result.deterministicFiles} file(s) byte-for-byte.`);
}
