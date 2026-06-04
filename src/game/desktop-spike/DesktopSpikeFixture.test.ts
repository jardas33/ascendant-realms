import { mkdtemp, readFile, rm } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { describe, expect, it } from "vitest";
import {
  createDesktopSpikeFixtureFiles,
  createDesktopSpikeFixturePayload,
  DESKTOP_SPIKE_FIXTURE_FILE_NAMES,
  validateDesktopSpikeFixturePayload,
  validateDesktopSpikeScorecardTemplate,
  validateRepositorySpikeBoundaries,
  writeDesktopSpikeFixtureExport,
  type DesktopSpikeFixturePayload
} from "./DesktopSpikeFixture";
import { stableStringify } from "../portable/PortableContentExport";

function clonePayload(payload: DesktopSpikeFixturePayload): DesktopSpikeFixturePayload {
  return JSON.parse(stableStringify(payload)) as DesktopSpikeFixturePayload;
}

describe("desktop spike fixture", () => {
  it("writes deterministic artifacts byte-for-byte", async () => {
    const root = await mkdtemp(join(tmpdir(), "desktop-spike-fixture-test-"));
    const leftDir = join(root, "left");
    const rightDir = join(root, "right");
    try {
      await writeDesktopSpikeFixtureExport(leftDir);
      await writeDesktopSpikeFixtureExport(rightDir);
      await Promise.all(
        DESKTOP_SPIKE_FIXTURE_FILE_NAMES.map(async (fileName) => {
          const left = await readFile(join(leftDir, fileName), "utf8");
          const right = await readFile(join(rightDir, fileName), "utf8");
          expect(left).toBe(right);
        })
      );
    } finally {
      await rm(root, { force: true, recursive: true });
    }
  });

  it("emits the required file set and passes fixture validation", async () => {
    const payload = await createDesktopSpikeFixturePayload();
    const files = createDesktopSpikeFixtureFiles(payload);

    expect(Object.keys(files).sort()).toEqual([...DESKTOP_SPIKE_FIXTURE_FILE_NAMES].sort());
    expect(validateDesktopSpikeFixturePayload(payload)).toEqual([]);
  });

  it("keeps all scene ids valid and preserves linked_ward at 0.92", async () => {
    const payload = await createDesktopSpikeFixturePayload();
    const scene = payload.sceneFixture;
    const lume = scene.lume as Record<string, unknown>;

    expect(scene.selectedEngine).toBeNull();
    expect(scene.engineProjectCreated).toBe(false);
    expect(scene.desktopWrapperCreated).toBe(false);
    expect(lume.benefitId).toBe("linked_ward");
    expect(lume.linkedWardDamageTakenMultiplier).toBe(0.92);
    expect(validateDesktopSpikeFixturePayload(payload)).toEqual([]);
  });

  it("rejects unknown content ids instead of silently remapping them", async () => {
    const payload = clonePayload(await createDesktopSpikeFixturePayload());
    const player = payload.sceneFixture.player as Record<string, unknown>;
    const units = player.units as Record<string, unknown>[];
    units[0].unitId = "missing_unit";

    expect(validateDesktopSpikeFixturePayload(payload)).toContain(
      "Desktop spike fixture player unit 0 references unknown units id missing_unit."
    );
  });

  it("links back to the authoritative source docs and source tooling", async () => {
    const payload = await createDesktopSpikeFixturePayload();
    const required = new Set((payload.sourceLinks.required as string[]) ?? []);

    [
      "docs/V0101_PORTABLE_CONTENT_EXPORT_CONTRACT.md",
      "docs/V0102_SAVE_TRANSLATION_PROOF_REPORT.md",
      "docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json",
      "docs/V0108_BENCHMARK_SCENARIO_MANIFEST.json",
      "docs/V0115_BROWSER_PERFORMANCE_GATE.md",
      "src/game/portable/PortableContentExport.ts",
      "src/game/save/SaveTranslationContract.ts",
      "tools/runtime-art-slots/validateRuntimeArtSlots.ts"
    ].forEach((path) => expect(required.has(path)).toBe(true));
  });

  it("uses the v0.102 save fixture index as read-only evidence", async () => {
    const payload = await createDesktopSpikeFixturePayload();
    const index = payload.saveFixtureIndex;
    const counts = index.counts as Record<string, unknown>;
    const fixtures = index.fixtures as Record<string, unknown>[];

    expect(index.currentSaveVersion).toBe(2);
    expect(counts).toMatchObject({ total: 16, translated: 11, translatedWithQuarantine: 2, rejected: 3 });
    expect(fixtures.every((fixture) => fixture.readOnly === true)).toBe(true);
    expect(fixtures.every((fixture) => fixture.rawSaveIncludedInDesktopSpikeFixture === false)).toBe(true);
  });

  it("defines the benchmark contract without choosing an engine", async () => {
    const payload = await createDesktopSpikeFixturePayload();
    const contract = payload.benchmarkContract;
    const metrics = new Set((contract.requiredMetrics as string[]) ?? []);

    expect(contract.browserPerformanceGateResult).toBe("RED");
    expect(contract.selectedEngine).toBeNull();
    expect(Object.keys(contract.tiers as Record<string, unknown>).sort()).toEqual(["L", "M", "S"]);
    ["frameTimeP95Ms", "frameTimeP99Ms", "frameTimeMaxMs", "inputLatencyMs", "resultsTransitionLatencyMs"].forEach((metric) =>
      expect(metrics.has(metric)).toBe(true)
    );
  });

  it("keeps the scorecard template complete, AI-first, and unapproved", async () => {
    const scorecardTemplate = JSON.parse(await readFile("docs/V0116_ENGINE_SPIKE_SCORECARD_TEMPLATE.json", "utf8")) as {
      aiOperability: Record<string, unknown>;
    };

    expect(validateDesktopSpikeScorecardTemplate(scorecardTemplate)).toEqual([]);
    expect(scorecardTemplate.aiOperability).toMatchObject({
      editorOptionalRoutineWorkflow: null,
      oneCommandValidation: null,
      manifestDrivenContentImport: null
    });
  });

  it("keeps the repository boundary free of root desktop projects, wrappers, and v0.118 docs", async () => {
    expect(await validateRepositorySpikeBoundaries()).toEqual([]);
  });

  it("does not integrate runtime art or mutate save/stable-id posture", async () => {
    const payload = await createDesktopSpikeFixturePayload();
    const expectedParity = payload.expectedParity;
    const visual = payload.visualPlaceholderContract;
    const visualJson = stableStringify(visual);

    expect((expectedParity.mustMatch as Record<string, unknown>).linkedWardDamageTakenMultiplier).toBe(0.92);
    expect(visual.generatedAssetsIncluded).toBe(false);
    expect(visual.runtimeIntegrationApproved).toBe(false);
    expect(visual.runtimeArtIntegrated).toBe(false);
    expect(visualJson).not.toContain("public/assets/");
    expect(visualJson).not.toContain("/assets/");
  });
});
