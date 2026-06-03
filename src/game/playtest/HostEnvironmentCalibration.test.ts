import { describe, expect, it } from "vitest";
import { CURRENT_SAVE_VERSION } from "../save/SaveDefaults";
import { LUME_NETWORKS } from "../data/lumeNetworks";
import { isPrivatePlaytestToolsEnabledForPosture } from "./PrivatePlaytestTools";
import { defaultPerformanceCounters } from "./PrivatePerformanceProfiler";
import { TRUSTED_DEFAULT_SAMPLE_MS, TRUSTED_DEFAULT_WARMUP_MS, summarizeTrustedFrameIntervals } from "./TrustedBrowserBenchmark";
import {
  V0111_BROWSER_CONTROL_BASELINES,
  V0111_PRIVATE_HUB_ACTIONS,
  classifyEnvironment,
  createCleanProfilePosture,
  createEnvironmentComparisonTemplate,
  redactSensitiveValue,
  renderCleanProfileBenchmarkSpecMarkdown,
  renderHostSnapshotSpecMarkdown,
  renderImplementationReportMarkdown,
  renderMachinePressureClassificationMarkdown,
  renderPostRestartRetestMarkdown,
  type BrowserControlBaselineResult
} from "./HostEnvironmentCalibration";

describe("HostEnvironmentCalibration", () => {
  it("redacts sensitive profile and personal path values", () => {
    expect(redactSensitiveValue("C:\\Users\\barro\\AppData\\Local\\Google\\Chrome\\User Data")).toBe("[redacted]");
    expect(redactSensitiveValue("/Users/emmanuel/Library/Application Support/Browser/Profile")).toBe("[redacted]");
    expect(redactSensitiveValue("chromium-120.0.0")).toBe("chromium-120.0.0");
  });

  it("keeps the temporary clean profile isolated from the user browser profile", () => {
    const posture = createCleanProfilePosture("deleted");

    expect(posture.mode).toBe("temporary");
    expect(posture.userProfileTouched).toBe(false);
    expect(posture.extensionsDisabled).toBe(true);
    expect(posture.profilePath).toBe("[temporary-profile-redacted]");
    expect(renderCleanProfileBenchmarkSpecMarkdown()).toContain("User browser profiles are never touched");
  });

  it("defines all requested control baselines as private no-save evidence", () => {
    expect(V0111_BROWSER_CONTROL_BASELINES.map((entry) => entry.id)).toEqual([
      "blank-page-raf",
      "simple-dom",
      "simple-canvas",
      "phaser-empty-scene",
      "campaign-map",
      "tier-m-representative-battle"
    ]);
    V0111_BROWSER_CONTROL_BASELINES.forEach((entry) => {
      expect(entry.saveIsolationRule).toContain("No save");
      expect(entry.saveIsolationRule).toContain("stable-ID");
      expect(entry.saveIsolationRule).toContain("desktop");
    });
    expect(Object.fromEntries(V0111_BROWSER_CONTROL_BASELINES.map((entry) => [entry.id, entry.launchTarget]))).toEqual({
      "blank-page-raf": { type: "blank-page" },
      "simple-dom": { type: "simple-dom" },
      "simple-canvas": { type: "simple-canvas" },
      "phaser-empty-scene": { type: "phaser-empty-scene" },
      "campaign-map": { type: "private-scenario", scenarioId: "perf_campaign_map_interaction", sceneKind: "campaign" },
      "tier-m-representative-battle": {
        type: "private-scenario",
        scenarioId: "benchmark_battle_tier_m_representative",
        sceneKind: "battle"
      }
    });
  });

  it("keeps private hub controls private and hidden in public posture", () => {
    expect(isPrivatePlaytestToolsEnabledForPosture(false, false)).toBe(false);
    expect(isPrivatePlaytestToolsEnabledForPosture(false, undefined)).toBe(false);
    expect(isPrivatePlaytestToolsEnabledForPosture(false, true)).toBe(true);
    expect(V0111_PRIVATE_HUB_ACTIONS).toHaveLength(5);
    V0111_PRIVATE_HUB_ACTIONS.forEach((action) => {
      expect(action.privateOnly).toBe(true);
      expect(action.saveSafe).toBe(true);
    });
    expect(createEnvironmentComparisonTemplate()).toContain("noUserBrowserProfileMutation");
  });

  it("keeps the v0.111 export schema stable", () => {
    const parsed = JSON.parse(
      createEnvironmentComparisonTemplate({
        activeAction: "Run Browser Control Baselines",
        exportedAtUtc: "2026-06-03T00:00:00.000Z"
      })
    ) as {
      checkpoint: string;
      title: string;
      commands: { command: string; privateOnly: boolean; saveSafe: boolean }[];
      artifactRoots: { hostSnapshots: string; controls: string };
      safety: Record<string, boolean>;
    };

    expect(parsed.checkpoint).toBe("v0.111");
    expect(parsed.title).toContain("Host Environment Calibration");
    expect(parsed.commands.map((entry) => entry.command)).toEqual([
      "npm run perf:host-snapshot",
      "npm run perf:controls:preview",
      "npm run perf:trusted:clean-profile",
      "npm run perf:controls:report"
    ]);
    expect(parsed.commands.every((entry) => entry.privateOnly && entry.saveSafe)).toBe(true);
    expect(parsed.artifactRoots.hostSnapshots).toBe("artifacts/performance/host-snapshots");
    expect(parsed.artifactRoots.controls).toBe("artifacts/performance/v0111");
    expect(parsed.safety).toMatchObject({
      noUserBrowserProfileMutation: true,
      noProcessCommandLines: true,
      noBrowserHistory: true,
      noOpenTabs: true,
      noSaveWrites: true,
      noV0112: true
    });
  });

  it("classifies healthy outside-game controls and slow battle as battle-code dominant", () => {
    const report = classifyEnvironment([
      result("blank-page-raf", 60, 20),
      result("simple-dom", 58, 24),
      result("simple-canvas", 57, 26),
      result("phaser-empty-scene", 55, 30),
      result("campaign-map", 30, 70),
      result("tier-m-representative-battle", 2.5, 516.6)
    ]);

    expect(report.hostClassification).toBe("HOST_PRESSURE_UNLIKELY");
    expect(report.gameCostClassification).toBe("BATTLE_CODE_DOMINANT");
    expect(renderMachinePressureClassificationMarkdown(report)).toContain("BATTLE_CODE_DOMINANT");
  });

  it("documents the v0.111 safety boundary without save, art, desktop, or v0.112 work", () => {
    const implementation = renderImplementationReportMarkdown([]);
    const hostSpec = renderHostSnapshotSpecMarkdown();
    const restart = renderPostRestartRetestMarkdown();
    const linkedWard = LUME_NETWORKS.find((network) => network.benefit.id === "linked_ward")?.benefit;

    expect(CURRENT_SAVE_VERSION).toBe(2);
    expect(linkedWard?.damageTakenMultiplier).toBe(0.92);
    expect(implementation).toContain("No process killing");
    expect(implementation).toContain("save-version bump");
    expect(implementation).toContain("stable-ID change");
    expect(implementation).toContain("art generation/import");
    expect(implementation).toContain("desktop work");
    expect(implementation).toContain("v0.112 work");
    expect(hostSpec).toContain("no browser history");
    expect(restart).toContain("Do not reboot from automation");
  });
});

function result(id: BrowserControlBaselineResult["id"], fpsAverage: number, p95: number): BrowserControlBaselineResult {
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: [
      { index: 0, atMs: 16, frameMs: 16 },
      { index: 1, atMs: 32, frameMs: 20 },
      { index: 2, atMs: 64, frameMs: p95 }
    ],
    sampleDurationMs: TRUSTED_DEFAULT_SAMPLE_MS,
    countersBefore: defaultPerformanceCounters(),
    countersAfter: { ...defaultPerformanceCounters(), domNodes: 20 },
    longTaskSupported: true,
    longTasks: []
  });
  return {
    id,
    title: id,
    category: id === "tier-m-representative-battle" ? "battle" : "outside-game",
    runMode: "preview-headless",
    generatedAtUtc: "deterministic-v0111-test",
    warmupMs: TRUSTED_DEFAULT_WARMUP_MS,
    sampleMs: TRUSTED_DEFAULT_SAMPLE_MS,
    viewport: "1600x900",
    browserVersion: "chromium-test",
    userAgent: "test-agent",
    visibilityState: "visible",
    cleanProfile: false,
    extensionsDisabled: false,
    hardwareAccelerationPosture: "test",
    domNodes: 20,
    hostSnapshotArtifact: "artifacts/performance/host-snapshots/test/host-snapshot.json",
    rawFrameIntervalArtifact: `artifacts/performance/v0111/raw-frame-intervals/${id}.json`,
    steadyState: { ...steadyState, fpsAverage, frameTimeMs: { ...steadyState.frameTimeMs, p95 } },
    saveBefore: null,
    saveAfter: null,
    saveMutationDetected: false
  };
}
