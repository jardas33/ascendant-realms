import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";
import { defaultPerformanceCounters, summarizePerformanceSamples, type PrivatePerformanceSample } from "./PrivatePerformanceProfiler";
import {
  REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS,
  REPRESENTATIVE_BATTLE_CONTENT_PROFILE,
  REPRESENTATIVE_BATTLE_TIER_PROFILES,
  V0108_DESKTOP_ACCEPTANCE_PROFILE,
  representativeBattleScenarioIdsForProfile,
  renderBattleBenchmarkSummaryMarkdown,
  type RepresentativeBattleScenarioResult
} from "./RepresentativeBattleBenchmark";

describe("RepresentativeBattleBenchmark", () => {
  it("defines the requested private benchmark scenarios in deterministic order", () => {
    expect(REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.map((scenario) => scenario.id)).toEqual([
      "benchmark_battle_tier_s_smoke",
      "benchmark_battle_tier_m_representative",
      "benchmark_battle_tier_l_stress",
      "benchmark_battle_lume_hidden",
      "benchmark_battle_lume_auto",
      "benchmark_battle_lume_always",
      "benchmark_battle_fog_heavy",
      "benchmark_battle_notification_heavy",
      "benchmark_battle_minimap_interaction",
      "benchmark_battle_results_transition"
    ]);

    REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.forEach((scenario) => {
      expect(scenario.saveIsolationRule).toContain("No save");
      expect(scenario.saveIsolationRule).toContain("reward");
      expect(scenario.publicPostureRule).toContain("Hidden from public posture");
      expect(scenario.expectedVisibleUi.length).toBeGreaterThan(0);
      expect(scenario.evidenceFocus.length).toBeGreaterThan(0);
    });
  });

  it("keeps smoke bounded, representative broad, and stress private/local only", () => {
    expect(representativeBattleScenarioIdsForProfile("smoke")).toEqual(["benchmark_battle_tier_s_smoke"]);
    expect(representativeBattleScenarioIdsForProfile("representative")).toEqual([
      "benchmark_battle_tier_m_representative",
      "benchmark_battle_lume_hidden",
      "benchmark_battle_lume_auto",
      "benchmark_battle_lume_always",
      "benchmark_battle_fog_heavy",
      "benchmark_battle_notification_heavy",
      "benchmark_battle_minimap_interaction",
      "benchmark_battle_results_transition"
    ]);
    expect(representativeBattleScenarioIdsForProfile("stress")).toEqual(["benchmark_battle_tier_l_stress"]);
    expect(REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.find((scenario) => scenario.id === "benchmark_battle_tier_l_stress")).toMatchObject({
      localOnly: true,
      includeInCiSmoke: false
    });
  });

  it("uses only existing content IDs and documents current mine/shrine proxies", () => {
    expect(REPRESENTATIVE_BATTLE_CONTENT_PROFILE.mapId).toBe("broken_ford");
    expect(REPRESENTATIVE_BATTLE_CONTENT_PROFILE.campaignNodeId).toBe("aether_well_ruins");
    expect(REPRESENTATIVE_BATTLE_CONTENT_PROFILE.playerMilitaryUnitIds).toEqual(["militia", "ranger"]);
    expect(REPRESENTATIVE_BATTLE_CONTENT_PROFILE.enemyUnitIds).toEqual(["raider", "hexer", "brute", "enemy_commander"]);
    expect(REPRESENTATIVE_BATTLE_CONTENT_PROFILE.mineEquivalentSiteId).toBe("west_stone_cut");
    expect(REPRESENTATIVE_BATTLE_CONTENT_PROFILE.shrineEquivalentSiteId).toBe("ford_toll");
    expect(REPRESENTATIVE_BATTLE_CONTENT_PROFILE.currentContentBoundary).toContain("No mine or shrine building IDs");
    expect(REPRESENTATIVE_BATTLE_TIER_PROFILES.M.player.workers).toBe(1);
  });

  it("keeps the committed scenario manifest aligned with the source manifest", () => {
    const manifest = JSON.parse(readFileSync(resolve(process.cwd(), "docs", "V0108_BENCHMARK_SCENARIO_MANIFEST.json"), "utf8")) as {
      scenarios: Array<{ id: string }>;
    };
    expect(manifest.scenarios.map((scenario) => scenario.id)).toEqual(
      REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.map((scenario) => scenario.id)
    );
  });

  it("renders stable benchmark markdown without claiming final hardware targets", () => {
    const result: RepresentativeBattleScenarioResult = {
      scenarioId: "benchmark_battle_tier_s_smoke",
      launchScenarioId: "benchmark_battle_tier_s_smoke",
      title: "Tier S smoke",
      profile: "smoke",
      tier: "S",
      variant: "tier",
      viewport: "1366x768",
      localOnly: false,
      includeInCiSmoke: true,
      summary: summarizePerformanceSamples({
        scenarioId: "benchmark_battle_tier_s_smoke",
        samples: [sample(0, 16, { units: 8, buildings: 4, domNodes: 500 }), sample(1000, 20, { units: 8, buildings: 4, domNodes: 500 })],
        longTaskSupported: true
      }),
      latency: {
        battleLaunchLatencyMs: 320,
        representativeActionLatencyMs: 12,
        saveMutationDetected: false
      }
    };

    const markdown = renderBattleBenchmarkSummaryMarkdown([result]);
    expect(markdown).toContain("not cross-machine benchmark proof");
    expect(markdown).toContain("| benchmark_battle_tier_s_smoke | S |");
    expect(markdown).toContain("Mine and shrine coverage uses existing capture-site infrastructure");
  });

  it("defines a provisional desktop acceptance profile without final hardware claims", () => {
    expect(V0108_DESKTOP_ACCEPTANCE_PROFILE.targetTier).toBe("M");
    expect(V0108_DESKTOP_ACCEPTANCE_PROFILE.viewports).toEqual(["1920x1080", "1600x900", "1366x768"]);
    expect(V0108_DESKTOP_ACCEPTANCE_PROFILE.evidenceBoundary).toContain("not final hardware certification");
    expect(V0108_DESKTOP_ACCEPTANCE_PROFILE.packageAndCi.stressLane).toContain("private/local only");
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
