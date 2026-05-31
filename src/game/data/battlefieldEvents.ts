import type { BattlefieldEventDefinition, BattlefieldEventId, TacticalPlanId } from "../core/GameTypes";

export const BATTLEFIELD_EVENTS: BattlefieldEventDefinition[] = [
  {
    id: "site_under_threat",
    name: "Site Under Threat",
    shortLabel: "Site Threat",
    description: "Enemy pressure marks a valuable player-held resource site.",
    objectiveKind: "hold_site",
    objectiveSummary: "Hold or recapture the threatened site until the window closes.",
    counterplay: "Screen the site with Militia and pull fragile Workers back before the raid lands.",
    afterActionSummary: "Resource-site pressure tested the army's map control.",
    eligibleDoctrineIds: ["raider", "warband"],
    preferredMissionTypeIds: ["control"],
    preferredModifierIds: ["mission_enemy_patrols", "mission_rich_veins"],
    recommendedTacticalPlanIds: ["resource_push", "guarded_advance"],
    durationSeconds: 34,
    cooldownSeconds: 54,
    pressureNudgeSeconds: 8,
    completionBonus: { crowns: 18 },
    tags: ["site", "raider", "resource"]
  },
  {
    id: "hold_the_line",
    name: "Hold the Line",
    shortLabel: "Hold",
    description: "Enemy pressure tests the player's Command Hall or defensive position.",
    objectiveKind: "protect_command_hall",
    objectiveSummary: "Keep the Command Hall standing through the pressure window.",
    counterplay: "Regroup near the Command Hall and use Guarded Advance or Retinue support if available.",
    afterActionSummary: "Defensive pressure checked whether the base could absorb a push.",
    eligibleDoctrineIds: ["fortress", "warband"],
    preferredMissionTypeIds: ["defense", "assault"],
    preferredModifierIds: ["mission_fortified_enemy", "mission_enemy_patrols"],
    recommendedTacticalPlanIds: ["guarded_advance"],
    durationSeconds: 38,
    cooldownSeconds: 60,
    pressureNudgeSeconds: 10,
    completionBonus: { stone: 10 },
    tags: ["defense", "command hall", "warband"]
  },
  {
    id: "elite_strike",
    name: "Elite Strike",
    shortLabel: "Elite",
    description: "An already-eligible elite enemy squad commits to a readable strike.",
    objectiveKind: "defeat_elite",
    objectiveSummary: "Defeat the elite squad before the strike window ends.",
    counterplay: "Focus the elite squad with a grouped army and avoid isolated Retinue losses.",
    afterActionSummary: "Elite pressure gave a clear tactical focus for the fight.",
    eligibleDoctrineIds: ["raider", "fortress", "hunter", "warband"],
    preferredMissionTypeIds: ["assault", "defense", "control"],
    preferredModifierIds: ["mission_fortified_enemy", "mission_enemy_patrols"],
    recommendedTacticalPlanIds: ["champion_hunt", "guarded_advance"],
    durationSeconds: 44,
    cooldownSeconds: 64,
    pressureNudgeSeconds: 6,
    completionBonus: { aether: 10 },
    tags: ["elite", "counterplay", "focus fire"]
  },
  {
    id: "reinforcement_window",
    name: "Reinforcement Window",
    shortLabel: "Retinue",
    description: "A safe timing opens for the once-per-battle Retinue reinforcement.",
    objectiveKind: "use_reinforcement",
    objectiveSummary: "Call one Ready reserve Retinue unit if the timing is worth the Crowns.",
    counterplay: "Use the reserve near the Command Hall, or save Crowns if the fight is stable.",
    afterActionSummary: "Retinue readiness was highlighted without forcing a reinforcement call.",
    eligibleDoctrineIds: ["hunter", "warband"],
    preferredMissionTypeIds: ["assault", "defense", "control"],
    preferredModifierIds: ["mission_enemy_patrols"],
    recommendedTacticalPlanIds: ["guarded_advance"],
    durationSeconds: 28,
    cooldownSeconds: 58,
    tags: ["retinue", "reserve", "readiness"]
  },
  {
    id: "aether_surge",
    name: "Lume Surge",
    shortLabel: "Lume",
    description: "A short mission-local Lume opportunity favors hero ability use.",
    objectiveKind: "use_ability",
    objectiveSummary: "Use a hero ability while the surge is active.",
    counterplay: "Spend the temporary mana on a decisive ability, then regroup before cooldowns return.",
    afterActionSummary: "Lume timing encouraged readable hero ability pressure.",
    eligibleDoctrineIds: ["hunter", "warband"],
    preferredMissionTypeIds: ["control", "assault"],
    preferredModifierIds: ["mission_aether_surge"],
    recommendedTacticalPlanIds: ["champion_hunt"],
    durationSeconds: 26,
    cooldownSeconds: 56,
    startHeroManaGain: 12,
    completionBonus: { aether: 8 },
    tags: ["aether", "hero", "ability"]
  }
];

export const BATTLEFIELD_EVENT_BY_ID = Object.fromEntries(BATTLEFIELD_EVENTS.map((event) => [event.id, event])) as Record<
  BattlefieldEventId,
  BattlefieldEventDefinition
>;

export function isBattlefieldEventId(value: string | undefined): value is BattlefieldEventId {
  return Boolean(value && value in BATTLEFIELD_EVENT_BY_ID);
}

export function tacticalPlanSupportsBattlefieldEvent(
  eventId: BattlefieldEventId | undefined,
  planId: TacticalPlanId | undefined
): boolean {
  if (!eventId || !planId) {
    return false;
  }
  return BATTLEFIELD_EVENT_BY_ID[eventId].recommendedTacticalPlanIds.includes(planId);
}
