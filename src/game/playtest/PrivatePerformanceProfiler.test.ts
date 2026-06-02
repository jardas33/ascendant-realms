import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import {
  V0103_PERFORMANCE_SCENARIOS,
  V0104_PERFORMANCE_SCENARIOS,
  defaultPerformanceCounters,
  renderPerformanceDeltaMarkdown,
  renderPerformanceSummaryMarkdown,
  summarizePerformanceSamples,
  type PrivatePerformanceSample
} from "./PrivatePerformanceProfiler";

describe("PrivatePerformanceProfiler", () => {
  it("summarizes deterministic frame timing, long tasks, and counter rates", () => {
    const samples: PrivatePerformanceSample[] = [
      sample(0, 16, { hudUpdates: 2, minimapRefreshes: 1, fogRedraws: 0, notificationsEmitted: 0 }),
      sample(1000, 20, { hudUpdates: 8, minimapRefreshes: 4, fogRedraws: 2, notificationsEmitted: 1 }),
      sample(2000, 34, { hudUpdates: 12, minimapRefreshes: 7, fogRedraws: 4, notificationsEmitted: 2, lumeLinks: 1, domNodes: 500 })
    ];

    const summary = summarizePerformanceSamples({
      scenarioId: "perf_lume_auto",
      samples,
      longTaskSupported: true,
      longTasks: [
        { atMs: 1500, durationMs: 72 },
        { atMs: 1700, durationMs: 51 }
      ]
    });

    expect(summary.scenarioId).toBe("perf_lume_auto");
    expect(summary.sampleDurationMs).toBe(2000);
    expect(summary.sampleCount).toBe(3);
    expect(summary.frameTimeMs.p95).toBe(34);
    expect(summary.frameTimeMs.over33_3).toBe(1);
    expect(summary.longTasks).toMatchObject({ supported: true, count: 2, totalDurationMs: 123, maxDurationMs: 72 });
    expect(summary.latestCounters.lumeLinks).toBe(1);
    expect(summary.ratesPerSecond.hudUpdates).toBe(5);
    expect(summary.ratesPerSecond.minimapRefreshes).toBe(3);
  });

  it("keeps the private Performance Lab scenario manifest deterministic and isolated", () => {
    expect(V0103_PERFORMANCE_SCENARIOS).toHaveLength(17);
    const ids = V0103_PERFORMANCE_SCENARIOS.map((entry) => entry.id);
    expect(new Set(ids).size).toBe(ids.length);
    expect(ids).toEqual([...ids].sort());
    expect(V0103_PERFORMANCE_SCENARIOS.map((entry) => entry.group)).toEqual(
      expect.arrayContaining(["battle", "lume", "campaign", "results"])
    );
    V0103_PERFORMANCE_SCENARIOS.forEach((entry) => {
      expect(entry.saveIsolationRule).toContain("not mutated");
      expect(entry.expectedVisibleUi.length).toBeGreaterThan(0);
      expect(entry.evidenceFocus.length).toBeGreaterThan(0);
    });
  });

  it("adds v0.104 HUD density scenarios without mutating the v0.103 baseline set", () => {
    expect(V0104_PERFORMANCE_SCENARIOS).toHaveLength(20);
    expect(V0103_PERFORMANCE_SCENARIOS).toHaveLength(17);
    const ids = V0104_PERFORMANCE_SCENARIOS.map((entry) => entry.id);
    expect(ids).toEqual([...ids].sort());
    expect(ids).toEqual(expect.arrayContaining(["perf_hud_minimal", "perf_hud_standard", "perf_hud_debug"]));
    V0104_PERFORMANCE_SCENARIOS.filter((entry) => entry.id.startsWith("perf_hud_")).forEach((entry) => {
      expect(entry.saveIsolationRule).toContain("not mutated");
      expect(entry.expectedVisibleUi.length).toBeGreaterThan(0);
    });
  });

  it("renders stable markdown without pretending cross-machine benchmark certainty", () => {
    const markdown = renderPerformanceSummaryMarkdown([
      summarizePerformanceSamples({ scenarioId: "perf_battle_baseline", samples: [sample(0, 16), sample(1000, 16)] }),
      summarizePerformanceSamples({ scenarioId: "perf_lume_always", samples: [sample(0, 16), sample(1000, 42)] })
    ]);

    expect(markdown).toContain("not cross-machine benchmark proof");
    expect(markdown).toContain("| perf_battle_baseline |");
    expect(markdown).toContain("| perf_lume_always |");
  });

  it("renders a v0.104 delta report against matching v0.103 scenario IDs", () => {
    const baseline = summarizePerformanceSamples({
      scenarioId: "perf_battle_baseline",
      samples: [sample(0, 16, { domNodes: 600 }), sample(1000, 34, { domNodes: 600, hudUpdates: 12, minimapRefreshes: 7 })]
    });
    const current = summarizePerformanceSamples({
      scenarioId: "perf_battle_baseline",
      samples: [sample(0, 16, { domNodes: 540 }), sample(1000, 20, { domNodes: 540, hudUpdates: 6, minimapRefreshes: 3 })]
    });
    const minimal = summarizePerformanceSamples({
      scenarioId: "perf_hud_minimal",
      samples: [sample(0, 16), sample(1000, 16)]
    });

    const markdown = renderPerformanceDeltaMarkdown([current, minimal], [baseline], {
      checkpoint: "v0.104",
      baselineCheckpoint: "v0.103"
    });

    expect(markdown).toContain("# v0.104 Private Performance Delta");
    expect(markdown).toContain("| perf_battle_baseline |");
    expect(markdown).toContain("perf_hud_minimal");
    expect(markdown).toContain("not cross-machine benchmark proof");
  });

  it("keeps the private profiler panel from intercepting game or hub controls", () => {
    const css = readFileSync(resolve(process.cwd(), "src/game/styles/playtest-hub.css"), "utf8");
    const panelRule = css.match(/\.private-performance-panel\s*\{[^}]+\}/)?.[0] ?? "";

    expect(panelRule).toContain("pointer-events: none");
  });
});

function sample(atMs: number, frameMs: number, counters: Partial<ReturnType<typeof defaultPerformanceCounters>> = {}): PrivatePerformanceSample {
  return {
    atMs,
    frameMs,
    counters: {
      ...defaultPerformanceCounters(),
      ...counters
    }
  };
}
