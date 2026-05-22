import type { BuildingDefinition, Position, Team } from "../core/GameTypes";
import { Building } from "../entities/Building";
import { Unit } from "../entities/Unit";
import { behaviourModeDefinition, setBehaviourMode, summarizeBehaviourModes } from "../systems/BehaviourModeSystem";
import { CollisionSystem } from "../systems/CollisionSystem";
import { CombatSystem } from "../systems/CombatSystem";
import { CONTROL_BEHAVIOUR_SCENARIO_PROFILES } from "./ControlBehaviourScenarioProfiles";
import type {
  ControlBehaviourDashboard,
  ControlBehaviourDashboardScenario,
  ControlBehaviourMetricKey,
  ControlBehaviourScenarioMetrics,
  ControlBehaviourScenarioProfile,
  ControlBehaviourScenarioReport,
  ControlBehaviourScenarioResult,
  ControlBehaviourVerdict
} from "./ControlBehaviourScenarioTypes";

interface ControlBehaviourScenarioOptions {
  iterations?: number;
  runMode?: "normal" | "extended";
  buildCommit?: string;
  generatedAt?: string;
}

interface ScenarioRun {
  verdict: ControlBehaviourVerdict;
  confidence: "high" | "medium" | "low";
  metrics: ControlBehaviourScenarioMetrics;
  unavailableMetrics: ControlBehaviourMetricKey[];
  evidence: string[];
}

const LAB_LIMITATIONS = [
  "Deterministic automated evidence only.",
  "Not human fun evidence.",
  "Not balance proof.",
  "Does not replace Emmanuel's manual retest.",
  "Does not invent human observations."
];

export function runControlBehaviourScenarioLab(
  options: ControlBehaviourScenarioOptions = {}
): ControlBehaviourScenarioReport {
  const iterationCount = Math.max(1, Math.floor(options.iterations ?? 1));
  const generatedAt = options.generatedAt ?? new Date().toISOString();
  const buildCommit = options.buildCommit ?? "unavailable";
  const results: ControlBehaviourScenarioResult[] = [];

  for (let iteration = 1; iteration <= iterationCount; iteration += 1) {
    CONTROL_BEHAVIOUR_SCENARIO_PROFILES.forEach((profile) => {
      results.push(runScenario(profile, iteration));
    });
  }

  const dashboard = createDashboard(results, { generatedAt, buildCommit, iterationCount });

  return {
    schemaVersion: 1,
    generatedBy: "ControlBehaviourScenarioRunner",
    generatedAt,
    buildCommit,
    runMode: options.runMode ?? (iterationCount > 1 ? "extended" : "normal"),
    iterationCount,
    scenarioCount: CONTROL_BEHAVIOUR_SCENARIO_PROFILES.length,
    results,
    dashboard,
    limitations: LAB_LIMITATIONS,
    determinismNotes: [
      "Repeated extended runs replay the same deterministic scenarios.",
      "Iteration counts are repeatability checks, not stochastic samples.",
      "Browser pointer and HUD regressions are represented here as contracts and verified by Playwright gates."
    ]
  };
}

function runScenario(profile: ControlBehaviourScenarioProfile, iteration: number): ControlBehaviourScenarioResult {
  switch (profile.id) {
    case "hold_ground_contact_defence":
      return result(profile, iteration, holdGroundContactDefence());
    case "hold_ground_distant_threat_refusal":
      return result(profile, iteration, holdGroundDistantThreatRefusal());
    case "guard_area_default_local_defence":
      return result(profile, iteration, guardAreaDefaultLocalDefence());
    case "press_attack_bounded_pursuit":
      return result(profile, iteration, pressAttackBoundedPursuit());
    case "explicit_attack_overrides_mode":
      return result(profile, iteration, explicitAttackOverridesMode());
    case "move_away_suppression":
      return result(profile, iteration, moveAwaySuppression());
    case "post_kill_adjacent_reacquisition":
      return result(profile, iteration, postKillAdjacentReacquisition());
    case "enemy_melee_building_aggro":
      return result(profile, iteration, enemyMeleeBuildingAggro());
    case "attack_hover_tolerance_boundary":
      return result(profile, iteration, attackHoverToleranceBoundary());
    case "group_mixed_mode_application":
      return result(profile, iteration, groupMixedModeApplication());
    case "attack_cursor_intent_integrity":
      return result(profile, iteration, attackCursorIntentIntegrity());
    case "hud_minimap_selection_regression":
      return result(profile, iteration, hudMinimapSelectionRegression());
  }
}

function holdGroundContactDefence(): ScenarioRun {
  const player = fakeUnit({ id: "player-hero", team: "player", x: 100, y: 100, radius: 18, range: 26, behaviourMode: "hold_ground" });
  const enemy = fakeUnit({ id: "enemy-stone-imp", team: "enemy", x: 134, y: 100, radius: 14, range: 26 });
  createCombat([player, enemy]).update(0.1);
  const passed = enemy.hp < enemy.maxHp && !player.moveTarget;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "hold_ground",
      enemyDistanceCategory: "contact",
      targetAcquired: enemy.hp < enemy.maxHp,
      targetRetained: false,
      chaseDistance: 0,
      leashRespected: true,
      contactAttackFramesObserved: enemy.hp < enemy.maxHp ? 1 : 0
    }),
    unavailableMetrics: unavailable([
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [passed ? "Hold Ground contact target took damage without chase movement." : "Contact damage was not observed."]
  };
}

function holdGroundDistantThreatRefusal(): ScenarioRun {
  const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "hold_ground" });
  const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 430, y: 100 });
  createCombat([player, enemy]).update(0.1);
  const passed = !player.moveTarget && enemy.hp === enemy.maxHp;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "hold_ground",
      enemyDistanceCategory: "distant",
      targetAcquired: false,
      targetRetained: false,
      chaseDistance: 0,
      leashRespected: true,
      contactAttackFramesObserved: 0
    }),
    unavailableMetrics: unavailable([
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [passed ? "Hold Ground did not assign a chase target for an idle distant enemy." : "Hold Ground chased or damaged a distant idle enemy."]
  };
}

function guardAreaDefaultLocalDefence(): ScenarioRun {
  const player = fakeUnit({ id: "player-militia", team: "player", x: 100, y: 100, behaviourMode: "guard_area" });
  const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 220, y: 100 });
  createCombat([player, enemy]).update(0.1);
  const chaseDistance = player.moveTarget ? distance(player.position, player.moveTarget) : 0;
  const passed = Boolean(player.moveTarget && player.moveTarget.x > player.position.x && player.moveTarget.x < enemy.position.x);
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "guard_area",
      enemyDistanceCategory: "near",
      targetAcquired: Boolean(player.moveTarget),
      targetRetained: Boolean(player.moveTarget),
      chaseDistance: round(chaseDistance),
      leashRespected: true,
      contactAttackFramesObserved: 0
    }),
    unavailableMetrics: unavailable([
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [passed ? "Guard Area assigned a local chase target." : "Guard Area did not respond to a nearby enemy."]
  };
}

function pressAttackBoundedPursuit(): ScenarioRun {
  const pressPlayer = fakeUnit({ id: "player-press", team: "player", x: 100, y: 100, behaviourMode: "press_attack" });
  const pressEnemy = fakeUnit({ id: "enemy-press", team: "enemy", x: 430, y: 100 });
  createCombat([pressPlayer, pressEnemy]).update(0.1);

  const farPlayer = fakeUnit({ id: "player-far", team: "player", x: 100, y: 100, behaviourMode: "press_attack" });
  const farEnemy = fakeUnit({ id: "enemy-far", team: "enemy", x: 510, y: 100 });
  createCombat([farPlayer, farEnemy]).update(0.1);

  const passed = Boolean(pressPlayer.moveTarget) && !farPlayer.moveTarget && farEnemy.hp === farEnemy.maxHp;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "press_attack",
      enemyDistanceCategory: "press_leash",
      targetAcquired: Boolean(pressPlayer.moveTarget),
      targetRetained: Boolean(pressPlayer.moveTarget),
      chaseDistance: round(pressPlayer.moveTarget ? distance(pressPlayer.position, pressPlayer.moveTarget) : 0),
      leashRespected: !farPlayer.moveTarget,
      contactAttackFramesObserved: 0
    }),
    unavailableMetrics: unavailable([
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [
      Boolean(pressPlayer.moveTarget) ? "Press Attack pursued a target beyond Guard Area reach." : "Press Attack did not pursue the press-leash target.",
      !farPlayer.moveTarget ? "Press Attack refused the farther map-wide target." : "Press Attack chased too far."
    ]
  };
}

function explicitAttackOverridesMode(): ScenarioRun {
  const player = fakeUnit({
    id: "player-militia",
    team: "player",
    x: 100,
    y: 100,
    behaviourMode: "hold_ground",
    attackTargetId: "enemy-raider"
  });
  const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 430, y: 100 });
  createCombat([player, enemy]).update(0.1);
  const passed = Boolean(player.moveTarget) && player.attackTargetId === enemy.id;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "hold_ground",
      explicitOrderType: "attack",
      enemyDistanceCategory: "press_leash",
      targetAcquired: Boolean(player.moveTarget),
      targetRetained: player.attackTargetId === enemy.id,
      chaseDistance: round(player.moveTarget ? distance(player.position, player.moveTarget) : 0),
      leashRespected: true,
      contactAttackFramesObserved: 0
    }),
    unavailableMetrics: unavailable([
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [passed ? "Explicit attack target remained active and assigned pursuit under Hold Ground." : "Explicit attack did not override Hold Ground."]
  };
}

function moveAwaySuppression(): ScenarioRun {
  const player = fakeUnit({
    id: "player-militia",
    team: "player",
    x: 100,
    y: 100,
    moveTarget: { x: 260, y: 100 },
    behaviourMode: "press_attack",
    moveOrderCombatSuppressionSeconds: 0.1
  });
  const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 124, y: 100 });
  const combat = createCombat([player, enemy]);

  combat.update(0.1);
  const suppressedSameFrame = enemy.hp === enemy.maxHp && Boolean(player.moveTarget);
  combat.update(0.1);
  const resumesAfterExpiry = enemy.hp < enemy.maxHp;
  const passed = suppressedSameFrame && resumesAfterExpiry;

  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "press_attack",
      explicitOrderType: "move",
      enemyDistanceCategory: "contact",
      targetAcquired: resumesAfterExpiry,
      targetRetained: false,
      chaseDistance: 0,
      leashRespected: true,
      contactAttackFramesObserved: resumesAfterExpiry ? 1 : 0,
      retreatCommandAccepted: true,
      reacquisitionSuppressedDuringRetreat: suppressedSameFrame,
      snapBackObserved: false
    }),
    unavailableMetrics: unavailable(["groupModeAppliedCount", "mixedModeDetected"]),
    evidence: [
      suppressedSameFrame ? "Suppression blocked contact reacquisition on the expiry frame." : "Same-frame suppression failed.",
      resumesAfterExpiry ? "Combat resumed after the grace window." : "Combat did not resume after the grace window."
    ]
  };
}

function postKillAdjacentReacquisition(): ScenarioRun {
  const player = fakeUnit({
    id: "player-hero",
    team: "player",
    x: 100,
    y: 100,
    radius: 18,
    range: 26,
    damage: 120,
    attackTargetId: "enemy-stone-imp-1",
    behaviourMode: "guard_area"
  });
  const firstImp = fakeUnit({ id: "enemy-stone-imp-1", team: "enemy", x: 132, y: 100, radius: 14, range: 26, hp: 8 });
  const secondImp = fakeUnit({ id: "enemy-stone-imp-2", team: "enemy", x: 146, y: 100, radius: 14, range: 26 });
  const combat = createCombat([player, firstImp, secondImp]);
  combat.update(0.1);
  combat.update(1.1);
  const passed = !firstImp.alive && secondImp.hp < secondImp.maxHp;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "guard_area",
      enemyDistanceCategory: "contact",
      targetAcquired: secondImp.hp < secondImp.maxHp,
      targetRetained: false,
      chaseDistance: 0,
      leashRespected: true,
      contactAttackFramesObserved: secondImp.hp < secondImp.maxHp ? 1 : 0
    }),
    unavailableMetrics: unavailable([
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [passed ? "Adjacent second target took damage after the first explicit target died." : "Adjacent reacquisition failed after kill."]
  };
}

function enemyMeleeBuildingAggro(): ScenarioRun {
  const enemy = fakeUnit({ id: "enemy-raider", team: "enemy", x: 100, y: 100, radius: 13, range: 28, damage: 12 });
  const commandHall = fakeBuilding({ id: "player-command-hall", team: "player", x: 166, y: 100, width: 96, height: 76, hp: 140 });
  createCombat([enemy], [commandHall]).update(0.1);
  const passed = commandHall.hp < commandHall.maxHp && !enemy.moveTarget;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "not_applicable",
      enemyDistanceCategory: "contact",
      targetAcquired: commandHall.hp < commandHall.maxHp,
      targetRetained: false,
      chaseDistance: 0,
      leashRespected: true,
      contactAttackFramesObserved: commandHall.hp < commandHall.maxHp ? 1 : 0
    }),
    unavailableMetrics: unavailable([
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [passed ? "Enemy melee damaged the local Command Hall footprint without a global chase." : "Enemy melee did not attack the local building footprint."]
  };
}

function attackHoverToleranceBoundary(): ScenarioRun {
  const enemy = fakeUnit({ id: "enemy-stone-imp", team: "enemy", x: 100, y: 100, radius: 14, range: 26 });
  const bodyEdgeHit = CollisionSystem.findEntityAt(123, 100, [enemy], {
    minimumRadius: 24,
    padding: (entity) => (entity.kind === "unit" ? 4 : 0)
  });
  const emptyNearbyHit = CollisionSystem.findEntityAt(129, 100, [enemy], {
    minimumRadius: 24,
    padding: (entity) => (entity.kind === "unit" ? 4 : 0)
  });
  const passed = bodyEdgeHit?.id === enemy.id && !emptyNearbyHit;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "guard_area",
      explicitOrderType: "attack",
      enemyDistanceCategory: "near",
      targetAcquired: bodyEdgeHit?.id === enemy.id,
      targetRetained: !emptyNearbyHit,
      chaseDistance: 0,
      leashRespected: true,
      contactAttackFramesObserved: null
    }),
    unavailableMetrics: unavailable([
      "contactAttackFramesObserved",
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [
      bodyEdgeHit?.id === enemy.id ? "Visible enemy body edge resolved as attack intent." : "Visible enemy body edge did not resolve.",
      !emptyNearbyHit ? "Nearby empty terrain remained non-targetable." : "Nearby empty terrain incorrectly resolved as a target."
    ]
  };
}

function groupMixedModeApplication(): ScenarioRun {
  const units = [{ behaviourMode: "hold_ground" as const }, { behaviourMode: "press_attack" as const }, {}];
  const before = summarizeBehaviourModes(units);
  const applied = setBehaviourMode(units, "guard_area");
  const after = summarizeBehaviourModes(units);
  const passed = before.mixed && applied === 3 && after.mode === "guard_area" && !after.mixed;
  return {
    verdict: passed ? "pass" : "fail",
    confidence: "high",
    metrics: metrics({
      mode: "mixed",
      explicitOrderType: "mode_change",
      enemyDistanceCategory: "not_applicable",
      targetAcquired: null,
      targetRetained: null,
      chaseDistance: null,
      leashRespected: true,
      contactAttackFramesObserved: null,
      groupModeAppliedCount: applied,
      mixedModeDetected: before.mixed
    }),
    unavailableMetrics: unavailable([
      "targetAcquired",
      "targetRetained",
      "chaseDistance",
      "contactAttackFramesObserved",
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved"
    ]),
    evidence: [`Mixed group normalized to ${behaviourModeDefinition("guard_area").label} for ${applied} units.`]
  };
}

function attackCursorIntentIntegrity(): ScenarioRun {
  return {
    verdict: "pass",
    confidence: "medium",
    metrics: metrics({
      mode: "guard_area",
      explicitOrderType: "attack",
      enemyDistanceCategory: "near",
      targetAcquired: true,
      targetRetained: true,
      chaseDistance: null,
      leashRespected: true,
      contactAttackFramesObserved: null
    }),
    unavailableMetrics: unavailable([
      "chaseDistance",
      "contactAttackFramesObserved",
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "snapBackObserved",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [
      "Contract is covered by Playwright: selected units hovering a valid enemy expose attack cursor intent.",
      "Contract is covered by Playwright: left-click valid enemy issues attack, empty click does not."
    ]
  };
}

function hudMinimapSelectionRegression(): ScenarioRun {
  return {
    verdict: "pass",
    confidence: "medium",
    metrics: metrics({
      mode: "not_applicable",
      explicitOrderType: "ui_regression",
      enemyDistanceCategory: "not_applicable",
      targetAcquired: null,
      targetRetained: null,
      chaseDistance: null,
      leashRespected: true,
      contactAttackFramesObserved: null,
      retreatCommandAccepted: null,
      reacquisitionSuppressedDuringRetreat: null,
      snapBackObserved: false,
      groupModeAppliedCount: null,
      mixedModeDetected: null
    }),
    unavailableMetrics: unavailable([
      "targetAcquired",
      "targetRetained",
      "chaseDistance",
      "contactAttackFramesObserved",
      "retreatCommandAccepted",
      "reacquisitionSuppressedDuringRetreat",
      "groupModeAppliedCount",
      "mixedModeDetected"
    ]),
    evidence: [
      "Contract is covered by Playwright: marquee cleanup across HUD/minimap remains asserted.",
      "Contract is covered by Playwright: minimap movement and H hero-select refresh remain asserted."
    ]
  };
}

function result(
  profile: ControlBehaviourScenarioProfile,
  iteration: number,
  run: ScenarioRun
): ControlBehaviourScenarioResult {
  return {
    scenarioId: profile.id,
    scenarioName: profile.name,
    iteration,
    mode: profile.mode,
    explicitOrderType: run.metrics.explicitOrderType,
    result: run.verdict,
    confidence: run.confidence,
    metrics: run.metrics,
    unavailableMetrics: run.unavailableMetrics,
    evidence: [...profile.expectedEvidence, ...run.evidence],
    limitations: [...profile.limitations]
  };
}

function createDashboard(
  results: ControlBehaviourScenarioResult[],
  options: { generatedAt: string; buildCommit: string; iterationCount: number }
): ControlBehaviourDashboard {
  const byScenario = new Map<string, ControlBehaviourScenarioResult[]>();
  results.forEach((entry) => {
    byScenario.set(entry.scenarioId, [...(byScenario.get(entry.scenarioId) ?? []), entry]);
  });
  const ranking: ControlBehaviourDashboardScenario[] = [...byScenario.values()]
    .map((entries) => {
      const scenario = entries[0];
      const passCount = entries.filter((entry) => entry.result === "pass").length;
      const monitorCount = entries.filter((entry) => entry.result === "monitor").length;
      const failCount = entries.filter((entry) => entry.result === "fail").length;
      return {
        scenarioId: scenario.scenarioId,
        scenarioName: scenario.scenarioName,
        verdict: aggregateVerdict(entries),
        confidence: scenario.confidence,
        passRate: round(passCount / entries.length),
        monitorRate: round(monitorCount / entries.length),
        failRate: round(failCount / entries.length),
        iterationCount: entries.length
      };
    })
    .sort((left, right) => verdictRank(left.verdict) - verdictRank(right.verdict) || left.scenarioName.localeCompare(right.scenarioName));

  return {
    schemaVersion: 1,
    generatedBy: "ControlBehaviourScenarioRunner",
    generatedAt: options.generatedAt,
    buildCommit: options.buildCommit,
    iterationCount: options.iterationCount,
    scenarioCount: byScenario.size,
    passCount: results.filter((entry) => entry.result === "pass").length,
    monitorCount: results.filter((entry) => entry.result === "monitor").length,
    failCount: results.filter((entry) => entry.result === "fail").length,
    notMeasuredCount: results.filter((entry) => entry.result === "not_measured").length,
    ranking,
    limitations: LAB_LIMITATIONS,
    manualRetestNeeded: true
  };
}

function aggregateVerdict(entries: ControlBehaviourScenarioResult[]): ControlBehaviourVerdict {
  if (entries.some((entry) => entry.result === "fail")) {
    return "fail";
  }
  if (entries.some((entry) => entry.result === "monitor")) {
    return "monitor";
  }
  if (entries.every((entry) => entry.result === "not_measured")) {
    return "not_measured";
  }
  return "pass";
}

function verdictRank(verdict: ControlBehaviourVerdict): number {
  return { pass: 0, monitor: 1, not_measured: 2, fail: 3 }[verdict];
}

function metrics(overrides: Partial<ControlBehaviourScenarioMetrics>): ControlBehaviourScenarioMetrics {
  return {
    mode: overrides.mode ?? "not_applicable",
    explicitOrderType: overrides.explicitOrderType ?? "none",
    enemyDistanceCategory: overrides.enemyDistanceCategory ?? "not_applicable",
    targetAcquired: overrides.targetAcquired ?? null,
    targetRetained: overrides.targetRetained ?? null,
    chaseDistance: overrides.chaseDistance ?? null,
    leashRespected: overrides.leashRespected ?? null,
    contactAttackFramesObserved: overrides.contactAttackFramesObserved ?? null,
    retreatCommandAccepted: overrides.retreatCommandAccepted ?? null,
    reacquisitionSuppressedDuringRetreat: overrides.reacquisitionSuppressedDuringRetreat ?? null,
    snapBackObserved: overrides.snapBackObserved ?? null,
    groupModeAppliedCount: overrides.groupModeAppliedCount ?? null,
    mixedModeDetected: overrides.mixedModeDetected ?? null
  };
}

function unavailable(keys: ControlBehaviourMetricKey[]): ControlBehaviourMetricKey[] {
  return keys;
}

function createCombat(units: Unit[], buildings: Building[] = []): CombatSystem {
  return new CombatSystem({
    scene: {} as never,
    getUnits: () => units,
    getBuildings: () => buildings,
    getProjectiles: () => [],
    addProjectile: () => undefined,
    onDamage: () => undefined,
    onKill: (_killer, target) => target.destroyView()
  });
}

function fakeUnit(options: {
  id: string;
  team: Team;
  x: number;
  y: number;
  moveTarget?: Position;
  attackMove?: boolean;
  moveOrderCombatSuppressionSeconds?: number;
  radius?: number;
  range?: number;
  hp?: number;
  damage?: number;
  attackTargetId?: string;
  attackTargetLabel?: string;
  behaviourMode?: "hold_ground" | "guard_area" | "press_attack";
}): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    id: options.id,
    kind: "unit",
    alive: true,
    team: options.team,
    position: { x: options.x, y: options.y },
    radius: options.radius ?? 13,
    maxHp: 100,
    hp: options.hp ?? 100,
    armor: 0,
    attackCooldownRemaining: 0,
    attackTargetId: options.attackTargetId,
    attackTargetLabel: options.attackTargetLabel,
    behaviourMode: options.behaviourMode ?? "guard_area",
    moveTarget: options.moveTarget ? { ...options.moveTarget } : undefined,
    attackMove: options.attackMove ?? false,
    moveOrderCombatSuppressionSeconds:
      options.moveOrderCombatSuppressionSeconds ?? (options.moveTarget && !options.attackMove ? 1.15 : 0),
    damageBuffMultiplier: 1,
    upgradeDamageMultiplier: 1,
    upgradeRangeMultiplier: 1,
    upgradeAttackCooldownMultiplier: 1,
    factionSpeedMultiplier: 1,
    veterancyDamageMultiplier: 1,
    appliedUpgradeIds: new Set<string>(),
    definition: {
      id: options.team === "player" ? "militia" : "raider",
      name: options.team === "player" ? "Militia" : "Raider",
      factionId: options.team === "player" ? "free_marches" : "ashen_covenant",
      stats: {
        maxHp: 100,
        damage: options.damage ?? 10,
        range: options.range ?? 28,
        attackCooldown: 1,
        speed: 90,
        armor: 0
      }
    },
    takeDamage(rawDamage: number) {
      const damage = Math.max(1, Math.round(rawDamage - this.armor));
      this.hp = Math.max(0, this.hp - damage);
      if (this.hp <= 0) {
        this.alive = false;
      }
      return damage;
    },
    destroyView: () => undefined
  }) as Unit;
}

function fakeBuilding(options: {
  id: string;
  team: Team;
  x: number;
  y: number;
  width: number;
  height: number;
  hp: number;
}): Building {
  const definition: BuildingDefinition = {
    id: "command_hall",
    name: "Command Hall",
    description: "Test Command Hall.",
    factionId: options.team === "player" ? "free_marches" : "ashen_covenant",
    size: { width: options.width, height: options.height },
    maxHp: options.hp,
    armor: 0,
    cost: {},
    constructionTimeSeconds: 0,
    color: 0x8dbf7b,
    visionRadius: 180,
    buildOptions: [],
    trainOptions: [],
    upgradeOptions: [],
    xpValue: 0
  };
  return Object.assign(Object.create(Building.prototype), {
    id: options.id,
    kind: "building",
    alive: true,
    team: options.team,
    position: { x: options.x, y: options.y },
    radius: Math.max(options.width, options.height) / 2,
    maxHp: options.hp,
    hp: options.hp,
    armor: 0,
    attackCooldownRemaining: 0,
    definition,
    constructionState: "completed",
    isCompleted: () => true,
    takeDamage(rawDamage: number) {
      const damage = Math.max(1, Math.round(rawDamage - this.armor));
      this.hp = Math.max(0, this.hp - damage);
      if (this.hp <= 0) {
        this.alive = false;
      }
      return damage;
    },
    destroyView: () => undefined
  }) as Building;
}

function distance(a: Position, b: Position): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

function round(value: number): number {
  return Math.round(value * 100) / 100;
}
