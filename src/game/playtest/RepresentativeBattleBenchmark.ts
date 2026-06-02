import type { PrivatePerformanceSummary } from "./PrivatePerformanceProfiler";

export const REPRESENTATIVE_BATTLE_BENCHMARK_CHECKPOINT = "v0.108";
export const REPRESENTATIVE_BATTLE_BENCHMARK_TITLE =
  "Representative Battle Benchmark Harness and Desktop Acceptance Profile";
export const REPRESENTATIVE_BATTLE_BENCHMARK_GROUP_TITLE = "REPRESENTATIVE BATTLE BENCHMARK";

export type RepresentativeBattleTier = "S" | "M" | "L";
export type RepresentativeBattleBenchmarkProfile = "smoke" | "representative" | "stress";
export type RepresentativeBattleBenchmarkVariant =
  | "tier"
  | "lume-hidden"
  | "lume-auto"
  | "lume-always"
  | "fog-heavy"
  | "notification-heavy"
  | "minimap-interaction"
  | "results-transition";

export interface RepresentativeBattleTierProfile {
  tier: RepresentativeBattleTier;
  label: string;
  purpose: string;
  mapId: "broken_ford";
  campaignNodeId: "aether_well_ruins";
  player: {
    hero: 1;
    workers: number;
    militia: number;
    rangers: number;
  };
  enemy: {
    raiders: number;
    hexers: number;
    brutes: number;
    commanders: number;
  };
  structures: {
    playerCommandHalls: 1;
    playerBarracks: 1;
    enemyStrongholds: 1;
    enemyBarracks: 1;
  };
  siteInfrastructure: {
    mineEquivalentSiteId: "west_stone_cut";
    shrineEquivalentSiteId: "ford_toll";
    resourceSiteFocusCount: 1;
  };
  lume: {
    networkId: "aether_well_ruins_lume_ward";
    linkId: "west_stone_cut_to_ford_toll";
    requiredVisibleLinks: number;
  };
  pressure: {
    beatLabel: string;
    nearbyEnemyCount: number;
  };
}

export interface RepresentativeBattleBenchmarkScenario {
  id: string;
  title: string;
  profile: RepresentativeBattleBenchmarkProfile;
  tier: RepresentativeBattleTier;
  variant: RepresentativeBattleBenchmarkVariant;
  launchScenarioId: string;
  purpose: string;
  expectedVisibleUi: string[];
  evidenceFocus: string[];
  saveIsolationRule: string;
  publicPostureRule: string;
  localOnly: boolean;
  includeInCiSmoke: boolean;
  viewport: "1366x768" | "1600x900" | "1920x1080";
}

export interface RepresentativeBattleLatencyMetrics {
  battleLaunchLatencyMs: number;
  representativeActionLatencyMs: number;
  resultsTransitionLatencyMs?: number;
  saveMutationDetected: boolean;
}

export interface RepresentativeBattleScenarioResult {
  scenarioId: string;
  launchScenarioId: string;
  title: string;
  profile: RepresentativeBattleBenchmarkProfile;
  tier: RepresentativeBattleTier;
  variant: RepresentativeBattleBenchmarkVariant;
  viewport: string;
  localOnly: boolean;
  includeInCiSmoke: boolean;
  summary: PrivatePerformanceSummary;
  latency: RepresentativeBattleLatencyMetrics;
}

export const REPRESENTATIVE_BATTLE_CONTENT_PROFILE = {
  mapId: "broken_ford",
  campaignNodeId: "aether_well_ruins",
  hero: "Aster",
  workerUnitId: "worker",
  playerMilitaryUnitIds: ["militia", "ranger"],
  enemyFactionId: "ashen_covenant",
  enemyUnitIds: ["raider", "hexer", "brute", "enemy_commander"],
  buildingIds: ["command_hall", "barracks", "enemy_stronghold", "enemy_barracks"],
  mineEquivalentSiteId: "west_stone_cut",
  shrineEquivalentSiteId: "ford_toll",
  resourceSiteFocusId: "west_stone_cut",
  lumeNetworkId: "aether_well_ruins_lume_ward",
  lumeLinkId: "west_stone_cut_to_ford_toll",
  resultsFixture: "private no-save Lume Results transition",
  currentContentBoundary:
    "Mine and shrine coverage uses existing capture-site infrastructure. No mine or shrine building IDs are added by v0.108."
} as const;

export const REPRESENTATIVE_BATTLE_TIER_PROFILES: Record<RepresentativeBattleTier, RepresentativeBattleTierProfile> = {
  S: {
    tier: "S",
    label: "Tier S smoke",
    purpose: "Small representative launch guard for CI-bounded smoke.",
    mapId: "broken_ford",
    campaignNodeId: "aether_well_ruins",
    player: { hero: 1, workers: 1, militia: 2, rangers: 2 },
    enemy: { raiders: 2, hexers: 1, brutes: 1, commanders: 1 },
    structures: { playerCommandHalls: 1, playerBarracks: 1, enemyStrongholds: 1, enemyBarracks: 1 },
    siteInfrastructure: { mineEquivalentSiteId: "west_stone_cut", shrineEquivalentSiteId: "ford_toll", resourceSiteFocusCount: 1 },
    lume: { networkId: "aether_well_ruins_lume_ward", linkId: "west_stone_cut_to_ford_toll", requiredVisibleLinks: 1 },
    pressure: { beatLabel: "single readable Ashen pressure beat", nearbyEnemyCount: 4 }
  },
  M: {
    tier: "M",
    label: "Tier M representative",
    purpose: "Default representative battle posture for desktop acceptance discussion.",
    mapId: "broken_ford",
    campaignNodeId: "aether_well_ruins",
    player: { hero: 1, workers: 1, militia: 8, rangers: 6 },
    enemy: { raiders: 7, hexers: 4, brutes: 3, commanders: 1 },
    structures: { playerCommandHalls: 1, playerBarracks: 1, enemyStrongholds: 1, enemyBarracks: 1 },
    siteInfrastructure: { mineEquivalentSiteId: "west_stone_cut", shrineEquivalentSiteId: "ford_toll", resourceSiteFocusCount: 1 },
    lume: { networkId: "aether_well_ruins_lume_ward", linkId: "west_stone_cut_to_ford_toll", requiredVisibleLinks: 1 },
    pressure: { beatLabel: "representative Ashen approach warning", nearbyEnemyCount: 8 }
  },
  L: {
    tier: "L",
    label: "Tier L stress",
    purpose: "Private/local-only stress posture for density regression hunting.",
    mapId: "broken_ford",
    campaignNodeId: "aether_well_ruins",
    player: { hero: 1, workers: 1, militia: 14, rangers: 12 },
    enemy: { raiders: 12, hexers: 7, brutes: 5, commanders: 1 },
    structures: { playerCommandHalls: 1, playerBarracks: 1, enemyStrongholds: 1, enemyBarracks: 1 },
    siteInfrastructure: { mineEquivalentSiteId: "west_stone_cut", shrineEquivalentSiteId: "ford_toll", resourceSiteFocusCount: 1 },
    lume: { networkId: "aether_well_ruins_lume_ward", linkId: "west_stone_cut_to_ford_toll", requiredVisibleLinks: 1 },
    pressure: { beatLabel: "dense but bounded private Ashen pressure beat", nearbyEnemyCount: 12 }
  }
};

const BENCHMARK_SAVE_RULE =
  "Private benchmark only. No saves, no rewards, XP, campaign progress, Retinue, relic, reputation, stable-ID, or localStorage mutation is allowed; the launcher restores the pre-hub save snapshot and persistent state is not mutated.";
const BENCHMARK_PUBLIC_RULE = "Hidden from public posture because the Playtest Hub itself is gated to dev/private package mode.";

export const REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS: RepresentativeBattleBenchmarkScenario[] = [
  benchmarkScenario(
    "benchmark_battle_tier_s_smoke",
    "Tier S smoke",
    "smoke",
    "S",
    "tier",
    "CI-bounded representative launch, reset, profiler, and no-save guard.",
    ["battle-hud", "battle-minimap", "lume-network-status"],
    ["battle launch latency", "representative action latency", "small active-unit count"],
    "1366x768",
    false,
    true
  ),
  benchmarkScenario(
    "benchmark_battle_tier_m_representative",
    "Tier M representative",
    "representative",
    "M",
    "tier",
    "Default representative battle with hero, Worker, Militia, Rangers, Ashen pressure, resource site, Lume link, HUD, minimap, and profiler counters.",
    ["battle-hud", "battle-minimap", "lume-network-status", "unit-order-summary"],
    ["FPS posture", "frame-time p95/p99", "HUD/minimap/fog counters", "representative action latency"],
    "1600x900",
    false,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_tier_l_stress",
    "Tier L stress",
    "stress",
    "L",
    "tier",
    "Private/local-only high-density battle posture. It is not part of bounded CI smoke.",
    ["battle-hud", "battle-minimap", "lume-network-status", "unit-order-summary"],
    ["stress density", "display objects", "units", "long tasks"],
    "1920x1080",
    true,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_lume_hidden",
    "Tier M with Lume Hidden",
    "representative",
    "M",
    "lume-hidden",
    "Representative Tier M with Lume rendering hidden for overlay-cost comparison.",
    ["battle-hud", "battle-minimap", "lume-visibility-controls"],
    ["Lume links hidden", "DOM nodes", "HUD/minimap rates"],
    "1366x768",
    false,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_lume_auto",
    "Tier M with Lume Auto",
    "representative",
    "M",
    "lume-auto",
    "Representative Tier M with default Lume Auto rendering.",
    ["battle-hud", "battle-minimap", "lume-network-status"],
    ["Lume links", "Lume endpoints", "frame-time p95"],
    "1600x900",
    false,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_lume_always",
    "Tier M with Lume Always",
    "representative",
    "M",
    "lume-always",
    "Representative Tier M with explicit Always-visible Lume inspection mode.",
    ["battle-hud", "battle-minimap", "lume-visibility-controls"],
    ["Lume link count", "display objects", "graphics objects"],
    "1920x1080",
    false,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_fog_heavy",
    "Tier M fog-heavy",
    "representative",
    "M",
    "fog-heavy",
    "Representative Tier M centered on fog/minimap pressure.",
    ["battle-hud", "battle-minimap", "battle-objectives"],
    ["fog visible cells", "fog redraws", "minimap refreshes"],
    "1366x768",
    false,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_notification_heavy",
    "Tier M notification-heavy",
    "representative",
    "M",
    "notification-heavy",
    "Representative Tier M with a bounded notification-pressure beat.",
    ["battle-hud", "battle-status", "battle-minimap"],
    ["notifications emitted", "notifications visible", "status readability"],
    "1600x900",
    false,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_minimap_interaction",
    "Tier M minimap interaction",
    "representative",
    "M",
    "minimap-interaction",
    "Representative Tier M with minimap/camera focus interaction.",
    ["battle-hud", "battle-minimap"],
    ["minimap refreshes", "representative action latency", "command feedback marker"],
    "1366x768",
    false,
    false
  ),
  benchmarkScenario(
    "benchmark_battle_results_transition",
    "Tier M Results transition",
    "representative",
    "M",
    "results-transition",
    "Representative Tier M forced through a no-save victory transition to the private Lume Results surface.",
    ["battle-hud", "private-demo-lume-summary"],
    ["Results transition latency", "DOM nodes", "long tasks"],
    "1366x768",
    false,
    false
  )
];

export const V0108_DESKTOP_ACCEPTANCE_PROFILE = {
  schemaVersion: 1,
  checkpoint: REPRESENTATIVE_BATTLE_BENCHMARK_CHECKPOINT,
  evidenceBoundary:
    "Provisional desktop acceptance profile from local deterministic browser QA. It is not final hardware certification.",
  viewports: ["1920x1080", "1600x900", "1366x768"],
  targetTier: "M",
  minimumProfile: {
    name: "Low",
    posture: "Tier S and ordinary battle smoke should launch, reset, and remain readable at 1366x768.",
    responsiveness: "No obvious input stall during private hub launch, representative focus action, or Results return.",
    frameTime: "Use p95 and long-task evidence as regression signals; do not claim final FPS targets."
  },
  standardProfile: {
    name: "Standard",
    posture: "Tier M representative battle should be the primary desktop benchmark posture at 1600x900 and 1920x1080.",
    responsiveness: "Representative action and Results transition should stay visibly responsive under local deterministic QA.",
    frameTime: "Frame-time p95, p99, long tasks, HUD/minimap/fog counters, and DOM nodes must be reported."
  },
  stretchProfile: {
    name: "Stretch",
    posture: "Tier L stress is private/local only and should be used to find density regressions before future desktop engine decisions.",
    responsiveness: "Stress results are directional evidence only and are not CI release blockers without a future explicit gate.",
    frameTime: "Stress output must remain separate from bounded CI smoke."
  },
  packageAndCi: {
    ciSmoke: "benchmark:battle:smoke runs Tier S only.",
    representativeLane: "benchmark:battle:representative runs Tier M plus Lume, fog, notification, minimap, and Results variants.",
    stressLane: "benchmark:battle:stress is private/local only.",
    package: "Private playtest package metadata must name v0.108 and include the v0.108 benchmark docs."
  }
} as const;

export const V0108_BASELINE_COMPARISON_BY_SCENARIO: Record<string, string> = {
  benchmark_battle_tier_s_smoke: "perf_battle_baseline",
  benchmark_battle_tier_m_representative: "perf_battle_baseline",
  benchmark_battle_tier_l_stress: "perf_large_unit_cluster",
  benchmark_battle_lume_hidden: "perf_lume_hidden",
  benchmark_battle_lume_auto: "perf_lume_auto",
  benchmark_battle_lume_always: "perf_lume_always",
  benchmark_battle_fog_heavy: "perf_fog_heavy_camera",
  benchmark_battle_notification_heavy: "perf_notification_heavy",
  benchmark_battle_minimap_interaction: "perf_minimap_interaction",
  benchmark_battle_results_transition: "perf_results_disclosure"
};

export function representativeBattleScenarioById(id: string): RepresentativeBattleBenchmarkScenario | undefined {
  return REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.find((scenario) => scenario.id === id);
}

export function representativeBattleTierForScenario(id: string): RepresentativeBattleTierProfile {
  const scenario = representativeBattleScenarioById(id);
  return REPRESENTATIVE_BATTLE_TIER_PROFILES[scenario?.tier ?? "M"];
}

export function representativeBattleScenarioIdsForProfile(profile: RepresentativeBattleBenchmarkProfile): string[] {
  return REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.filter((scenario) => scenario.profile === profile).map((scenario) => scenario.id);
}

export function renderBattleBenchmarkSummaryMarkdown(results: RepresentativeBattleScenarioResult[]): string {
  const sorted = sortBenchmarkResults(results);
  const lines = [
    "# v0.108 Representative Battle Benchmark Summary",
    "",
    "This is local deterministic private-QA evidence. It is not cross-machine benchmark proof and does not claim final desktop hardware targets.",
    "",
    "## Scenario Results",
    "",
    "| Scenario | Tier | FPS avg | 1% low | p95 ms | p99 ms | Max ms | Long tasks | Objects | Units | Buildings | Sites | Labels | Rings | Fog/s | Minimap/s | HUD/s | Notify/s | DOM | Launch ms | Action ms | Results ms |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...sorted.map((result) => {
      const summary = result.summary;
      return `| ${result.scenarioId} | ${result.tier} | ${summary.fpsAverage} | ${summary.fpsOnePercentLow} | ${summary.frameTimeMs.p95} | ${summary.frameTimeMs.p99} | ${summary.frameTimeMs.max} | ${summary.longTasks.count} | ${summary.latestCounters.displayObjects} | ${summary.latestCounters.units} | ${summary.latestCounters.buildings} | ${summary.latestCounters.captureSites} | ${summary.latestCounters.labels} | ${summary.latestCounters.captureRings} | ${summary.ratesPerSecond.fogRedraws} | ${summary.ratesPerSecond.minimapRefreshes} | ${summary.ratesPerSecond.hudUpdates} | ${summary.ratesPerSecond.notificationsEmitted} | ${summary.latestCounters.domNodes} | ${result.latency.battleLaunchLatencyMs} | ${result.latency.representativeActionLatencyMs} | ${result.latency.resultsTransitionLatencyMs ?? ""} |`;
    }),
    "",
    "## Boundary",
    "",
    "- All scenarios are private Playtest Hub fixtures with rewards disabled.",
    "- Stress remains private/local only and is excluded from bounded CI smoke.",
    "- Mine and shrine coverage uses existing capture-site infrastructure, not new building IDs.",
    ""
  ];
  return `${lines.join("\n")}\n`;
}

export function renderBrowserBattleBenchmarkReport(results: RepresentativeBattleScenarioResult[]): string {
  const sorted = sortBenchmarkResults(results);
  const scenarioCount = sorted.length;
  const stressIncluded = sorted.some((result) => result.profile === "stress");
  return [
    "# v0.108 Browser Battle Benchmark Report",
    "",
    "## Status",
    "",
    scenarioCount > 0 ? `Latest generated report includes ${scenarioCount} scenario(s).` : "No generated benchmark scenarios have been recorded yet.",
    "",
    "## Evidence Boundary",
    "",
    "The harness uses the existing private browser profiler through Playwright. Results are useful for local regression shape and desktop acceptance discussion, not final hardware certification.",
    "",
    "## Measured Fields",
    "",
    "- FPS average and 1% low estimate.",
    "- Frame-time p50, p95, p99, max, and threshold counts.",
    "- Long-task observer support/count/duration.",
    "- Display objects, units, buildings, sites, labels, rings, fog redraws, minimap refreshes, HUD refreshes, notifications, and DOM nodes.",
    "- Battle launch, representative action, and Results transition latency.",
    "",
    "## Latest Summary",
    "",
    ...renderCompactScenarioBullets(sorted),
    "",
    "## Stress Lane",
    "",
    stressIncluded
      ? "Tier L stress evidence is present in the latest artifact set. Treat it as private/local-only regression-hunting evidence."
      : "Tier L stress evidence is not present in this artifact set unless `npm run benchmark:battle:stress` has been run locally.",
    ""
  ].join("\n");
}

export function renderPerformanceDeltaReport(
  results: RepresentativeBattleScenarioResult[],
  baselines: { checkpoint: "v0.103" | "v0.104"; summaries: PrivatePerformanceSummary[] }[]
): string {
  const sorted = sortBenchmarkResults(results);
  const lines = [
    "# v0.108 Performance Delta Report",
    "",
    "This compares v0.108 representative benchmark scenarios with the closest v0.103/v0.104 private profiler scenarios when a meaningful comparison exists. It is local deterministic QA evidence, not cross-machine benchmark proof.",
    "",
    "| v0.108 scenario | Comparison | v0.103 p95 | v0.104 p95 | v0.108 p95 | v0.108 units | v0.108 DOM | Notes |",
    "| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |"
  ];
  const baselineByCheckpoint = new Map(
    baselines.map((baseline) => [baseline.checkpoint, new Map(baseline.summaries.map((summary) => [summary.scenarioId, summary]))])
  );
  sorted.forEach((result) => {
    const comparisonId = V0108_BASELINE_COMPARISON_BY_SCENARIO[result.scenarioId] ?? "";
    const v0103 = baselineByCheckpoint.get("v0.103")?.get(comparisonId);
    const v0104 = baselineByCheckpoint.get("v0.104")?.get(comparisonId);
    lines.push(
      `| ${result.scenarioId} | ${comparisonId || "new representative shape"} | ${v0103?.frameTimeMs.p95 ?? ""} | ${v0104?.frameTimeMs.p95 ?? ""} | ${result.summary.frameTimeMs.p95} | ${result.summary.latestCounters.units} | ${result.summary.latestCounters.domNodes} | ${deltaNote(result, comparisonId)} |`
    );
  });
  lines.push(
    "",
    "## Interpretation",
    "",
    "- Direct scenario IDs do not all match because v0.108 measures a representative composed battle profile rather than only the older isolated private profiler states.",
    "- Lume Hidden/Auto/Always, fog-heavy, notification-heavy, minimap interaction, and Results transition retain closest v0.103/v0.104 comparison anchors.",
    "- Tier L stress is private/local only and should not be treated as CI acceptance.",
    ""
  );
  return `${lines.join("\n")}\n`;
}

export function renderAcceptanceProfileMarkdown(): string {
  const profile = V0108_DESKTOP_ACCEPTANCE_PROFILE;
  return [
    "# v0.108 Desktop Acceptance Profile",
    "",
    "Status: provisional docs-only acceptance profile for future desktop benchmarking. It does not choose an engine, start a port, add desktop saves, or claim final hardware targets.",
    "",
    "## Viewports",
    "",
    profile.viewports.map((viewport) => `- ${viewport}`).join("\n"),
    "",
    "## Profiles",
    "",
    `- Low: ${profile.minimumProfile.posture} ${profile.minimumProfile.responsiveness}`,
    `- Standard: ${profile.standardProfile.posture} ${profile.standardProfile.responsiveness}`,
    `- Stretch: ${profile.stretchProfile.posture} ${profile.stretchProfile.responsiveness}`,
    "",
    "## Required Evidence",
    "",
    "- Tier M is the target representative unit-count tier.",
    "- Report FPS average, 1% low estimate, frame-time percentiles, long tasks, input/action latency, Results transition latency, and readability at 1920x1080, 1600x900, and 1366x768.",
    "- Keep stress private/local only until a future explicit gate promotes it.",
    "- Do not use these browser numbers as final desktop hardware targets.",
    ""
  ].join("\n");
}

export function buildBattleBenchmarkSummaryJson(results: RepresentativeBattleScenarioResult[]) {
  const sorted = sortBenchmarkResults(results);
  return {
    schemaVersion: 1,
    checkpoint: REPRESENTATIVE_BATTLE_BENCHMARK_CHECKPOINT,
    title: REPRESENTATIVE_BATTLE_BENCHMARK_TITLE,
    generatedAtUtc: "deterministic-v0108",
    note: "Private browser benchmark evidence from local Playwright sampling. FPS varies by machine; compare scenario shape, not absolute numbers.",
    scenarioCount: sorted.length,
    acceptanceProfile: V0108_DESKTOP_ACCEPTANCE_PROFILE,
    contentProfile: REPRESENTATIVE_BATTLE_CONTENT_PROFILE,
    summaries: sorted.map((result) => result.summary),
    latency: sorted.map((result) => ({
      scenarioId: result.scenarioId,
      ...result.latency
    }))
  };
}

function benchmarkScenario(
  id: string,
  title: string,
  profile: RepresentativeBattleBenchmarkProfile,
  tier: RepresentativeBattleTier,
  variant: RepresentativeBattleBenchmarkVariant,
  purpose: string,
  expectedVisibleUi: string[],
  evidenceFocus: string[],
  viewport: RepresentativeBattleBenchmarkScenario["viewport"],
  localOnly: boolean,
  includeInCiSmoke: boolean
): RepresentativeBattleBenchmarkScenario {
  return {
    id,
    title,
    profile,
    tier,
    variant,
    launchScenarioId: id,
    purpose,
    expectedVisibleUi,
    evidenceFocus,
    saveIsolationRule: BENCHMARK_SAVE_RULE,
    publicPostureRule: BENCHMARK_PUBLIC_RULE,
    localOnly,
    includeInCiSmoke,
    viewport
  };
}

function sortBenchmarkResults(results: RepresentativeBattleScenarioResult[]): RepresentativeBattleScenarioResult[] {
  const order = new Map(REPRESENTATIVE_BATTLE_BENCHMARK_SCENARIOS.map((scenario, index) => [scenario.id, index]));
  return [...results].sort((left, right) => (order.get(left.scenarioId) ?? 999) - (order.get(right.scenarioId) ?? 999));
}

function renderCompactScenarioBullets(results: RepresentativeBattleScenarioResult[]): string[] {
  if (results.length === 0) {
    return ["- No scenario results recorded."];
  }
  return results.map(
    (result) =>
      `- ${result.scenarioId}: FPS avg ${result.summary.fpsAverage}, 1% low ${result.summary.fpsOnePercentLow}, p95 ${result.summary.frameTimeMs.p95} ms, units ${result.summary.latestCounters.units}, DOM ${result.summary.latestCounters.domNodes}, launch ${result.latency.battleLaunchLatencyMs} ms, action ${result.latency.representativeActionLatencyMs} ms${
        result.latency.resultsTransitionLatencyMs === undefined ? "" : `, Results ${result.latency.resultsTransitionLatencyMs} ms`
      }.`
  );
}

function deltaNote(result: RepresentativeBattleScenarioResult, comparisonId: string): string {
  if (result.profile === "stress") {
    return "Private/local stress only.";
  }
  if (comparisonId === "perf_battle_baseline") {
    return "Representative composed battle versus ordinary baseline.";
  }
  if (comparisonId.startsWith("perf_lume")) {
    return "Lume overlay comparison.";
  }
  if (comparisonId === "perf_results_disclosure") {
    return "Battle-to-Results transition adds latency evidence.";
  }
  return "Closest available private profiler comparison.";
}
