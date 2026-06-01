import { mkdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";
import {
  createSaveTranslationContractMarkdown,
  createSaveTranslationContractReport
} from "../src/game/save/SaveTranslationContract";
import {
  DEFAULT_STABLE_ID_SNAPSHOT_PATH,
  readStableIdSnapshot,
  stableStringify
} from "../src/game/portable/PortableContentExport";

interface FixtureManifestEntry {
  id: string;
  filename: string;
  expectedStatus: string;
  expectedSaveVersion?: number;
  expectedUnknownContentIdCount?: number;
  expectedUnsafeFieldCount?: number;
  expectedRejectionReason?: string;
  purpose: string;
}

interface FixtureManifest {
  schemaVersion: number;
  checkpoint: string;
  fixtures: FixtureManifestEntry[];
}

const FIXTURE_DIR = "tests/fixtures/saves/v0102";
const OUTPUT_DIR = "artifacts/save-translation-contract/latest";

const manifest = await readJson<FixtureManifest>(join(FIXTURE_DIR, "manifest.json"));
const duplicateIds = duplicateValues(manifest.fixtures.map((fixture) => fixture.id));
if (duplicateIds.length > 0) {
  console.error(`Duplicate save translation fixture ids: ${duplicateIds.join(", ")}`);
  process.exit(1);
}

const fixtureInputs = await Promise.all(
  manifest.fixtures.map(async (fixture) => ({
    id: fixture.id,
    raw: await readFile(join(FIXTURE_DIR, fixture.filename), "utf8")
  }))
);
const snapshot = await readStableIdSnapshot(DEFAULT_STABLE_ID_SNAPSHOT_PATH);
const firstReport = createSaveTranslationContractReport(fixtureInputs, snapshot);
const secondReport = createSaveTranslationContractReport(fixtureInputs, snapshot);
const firstSerialized = stableStringify(firstReport);
const secondSerialized = stableStringify(secondReport);
const errors = validateReportAgainstManifest(firstReport, manifest);

if (firstSerialized !== secondSerialized) {
  errors.push("Save translation contract report is nondeterministic between two in-process runs.");
}

await mkdir(OUTPUT_DIR, { recursive: true });
await writeFile(join(OUTPUT_DIR, "save-translation-contract-summary.json"), firstSerialized, "utf8");
await writeFile(join(OUTPUT_DIR, "save-translation-contract-summary.md"), createSaveTranslationContractMarkdown(firstReport), "utf8");

if (errors.length > 0) {
  console.error(`Save translation contract failed with ${errors.length} error(s):`);
  errors.forEach((error) => console.error(`- ${error}`));
  process.exitCode = 1;
} else {
  console.log("Save translation contract passed.");
  console.log(`Fixtures: ${firstReport.fixtureCount}`);
  console.log(`Translated: ${firstReport.translatedCount}`);
  console.log(`Translated with quarantine: ${firstReport.translatedWithQuarantineCount}`);
  console.log(`Rejected: ${firstReport.rejectedCount}`);
  console.log(`Unknown content ids reported: ${firstReport.unknownContentIdCount}`);
  console.log(`Unsafe fields quarantined: ${firstReport.unsafeFieldCount}`);
  console.log(`Output: ${OUTPUT_DIR}`);
}

async function readJson<T>(path: string): Promise<T> {
  return JSON.parse(await readFile(path, "utf8")) as T;
}

function validateReportAgainstManifest(
  report: ReturnType<typeof createSaveTranslationContractReport>,
  fixtureManifest: FixtureManifest
): string[] {
  const validationErrors: string[] = [];
  const resultsById = new Map(report.results.map((result) => [result.fixtureId, result]));
  fixtureManifest.fixtures.forEach((fixture) => {
    const result = resultsById.get(fixture.id);
    if (!result) {
      validationErrors.push(`Fixture ${fixture.id} did not appear in the contract report.`);
      return;
    }
    if (result.status !== fixture.expectedStatus) {
      validationErrors.push(`Fixture ${fixture.id} expected ${fixture.expectedStatus} but reported ${result.status}.`);
    }
    if (fixture.expectedSaveVersion !== undefined && result.saveVersion !== fixture.expectedSaveVersion) {
      validationErrors.push(
        `Fixture ${fixture.id} expected save version ${fixture.expectedSaveVersion} but reported ${result.saveVersion ?? "none"}.`
      );
    }
    if (
      fixture.expectedUnknownContentIdCount !== undefined &&
      result.quarantine.unknownContentIds.length !== fixture.expectedUnknownContentIdCount
    ) {
      validationErrors.push(
        `Fixture ${fixture.id} expected ${fixture.expectedUnknownContentIdCount} unknown id(s) but reported ${result.quarantine.unknownContentIds.length}.`
      );
    }
    if (
      fixture.expectedUnsafeFieldCount !== undefined &&
      result.quarantine.unsafeFields.length !== fixture.expectedUnsafeFieldCount
    ) {
      validationErrors.push(
        `Fixture ${fixture.id} expected ${fixture.expectedUnsafeFieldCount} unsafe field(s) but reported ${result.quarantine.unsafeFields.length}.`
      );
    }
    if (
      fixture.expectedRejectionReason &&
      !result.quarantine.rejectionReasons.includes(
        fixture.expectedRejectionReason as (typeof result.quarantine.rejectionReasons)[number]
      )
    ) {
      validationErrors.push(`Fixture ${fixture.id} did not report ${fixture.expectedRejectionReason}.`);
    }
  });
  return validationErrors;
}

function duplicateValues(values: string[]): string[] {
  const seen = new Set<string>();
  const duplicates = new Set<string>();
  values.forEach((value) => {
    if (seen.has(value)) {
      duplicates.add(value);
    }
    seen.add(value);
  });
  return [...duplicates].sort();
}
