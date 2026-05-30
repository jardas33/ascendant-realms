import type {
  BattleDifficulty,
  CampaignMissionTypeId,
  CampaignModifierId,
  CampaignNodeDefinition,
  EnemyDoctrineDefinition,
  EnemyDoctrineId,
  EnemyEliteSquadDefinition
} from "../core/GameTypes";
import { CAMPAIGN_NODES } from "./campaignNodes";

export interface EnemyDoctrineSelectionInput {
  mode?: string;
  campaignNodeId?: string;
  missionTypeId?: CampaignMissionTypeId;
  modifierIds?: readonly string[];
  enemyHeroId?: string;
  difficulty?: BattleDifficulty;
  retinueUnitCount?: number;
  retinueReserveCount?: number;
  rewardsDisabled?: boolean;
}

export const ENEMY_DOCTRINES: EnemyDoctrineDefinition[] = [
  {
    id: "raider",
    name: "Raider",
    shortDescription: "Pressures resource sites, assigned Workers, and exposed economy routes.",
    statusLabel: "Raider doctrine: economy pressure",
    threatWarning: "Raiders will look for exposed Workers and resource sites.",
    counterplay: "Protect sites with Militia screens and pull fragile units back before raids land.",
    preferredMissionTypeIds: ["control"],
    preferredModifierIds: ["mission_enemy_patrols"],
    tags: ["resource pressure", "worker threat", "site raids"],
    activity: {
      resourceRaidInitialDelaySeconds: 118,
      resourceRaidCooldownMultiplier: 0.76,
      resourceRaidSquadBonus: 1
    }
  },
  {
    id: "fortress",
    name: "Fortress",
    shortDescription: "Keeps a larger reserve, protects valuable sites, and favors defensive upgrades.",
    statusLabel: "Fortress doctrine: defended strongpoint",
    threatWarning: "The enemy will preserve reserves around its base and valuable sites.",
    counterplay: "Attack economy first or prepare a larger push before committing into defenses.",
    preferredMissionTypeIds: ["assault"],
    preferredModifierIds: ["mission_fortified_enemy"],
    tags: ["defense reserve", "site defense", "fortification"],
    activity: {
      defenseReserveBonus: 1,
      techCooldownMultiplier: 0.9
    }
  },
  {
    id: "hunter",
    name: "Hunter",
    shortDescription: "Sends escorted pressure toward the hero or deployed Retinue when they are exposed.",
    statusLabel: "Hunter doctrine: champion pressure",
    threatWarning: "Hunter squads may probe your hero or Retinue when escorted.",
    counterplay: "Keep hero and Retinue near army cover; avoid isolated dives into enemy space.",
    preferredMissionTypeIds: ["control", "assault"],
    preferredModifierIds: ["mission_aether_surge"],
    tags: ["hero pressure", "retinue pressure", "escorted probe"],
    activity: {
      hunterInitialDelaySeconds: 215,
      hunterCooldownSeconds: 118,
      hunterEscortCount: 3
    }
  },
  {
    id: "warband",
    name: "Warband",
    shortDescription: "Builds toward a late mixed-unit push without increasing early spam.",
    statusLabel: "Warband doctrine: late mixed push",
    threatWarning: "A mixed Warband can form later if the fight drags on.",
    counterplay: "Regroup before the late push and use one Retinue reinforcement at a safe timing.",
    preferredMissionTypeIds: ["defense", "assault"],
    preferredModifierIds: ["mission_enemy_patrols"],
    tags: ["late push", "mixed squad", "regroup check"],
    activity: {
      attackWaveSizeBonus: 1
    }
  }
];

export const ENEMY_DOCTRINE_BY_ID = Object.fromEntries(ENEMY_DOCTRINES.map((doctrine) => [doctrine.id, doctrine])) as Record<
  EnemyDoctrineId,
  EnemyDoctrineDefinition
>;

export const ENEMY_ELITE_SQUADS: EnemyEliteSquadDefinition[] = [
  {
    id: "ash_raider_vanguard",
    name: "Ash Raider Vanguard",
    shortLabel: "Elite Vanguard",
    description: "A small elite raider pair that hits economy routes a little harder.",
    counterplay: "Screen with Militia and fight near towers or your main army.",
    eligibleDoctrineIds: ["raider", "hunter"],
    eligibleMissionTypeIds: ["control", "assault"],
    eligibleUnitIds: ["raider"],
    maxUnitsPerBattle: 2,
    maxHpMultiplier: 1.08,
    damageMultiplier: 1.06,
    armorBonus: 0
  },
  {
    id: "cinder_iron_guard",
    name: "Cinder Iron Guard",
    shortLabel: "Elite Guard",
    description: "Fortified enemy veterans that slightly improve a defensive or late push core.",
    counterplay: "Focus fragile support first, then grind the Guard with a grouped army.",
    eligibleDoctrineIds: ["fortress", "warband"],
    eligibleMissionTypeIds: ["assault", "defense"],
    eligibleUnitIds: ["brute", "enemy_commander", "raider"],
    maxUnitsPerBattle: 2,
    maxHpMultiplier: 1.08,
    damageMultiplier: 1.05,
    armorBonus: 1
  }
];

export const ENEMY_ELITE_SQUAD_BY_ID = Object.fromEntries(
  ENEMY_ELITE_SQUADS.map((squad) => [squad.id, squad])
) as Record<string, EnemyEliteSquadDefinition>;

export function isEnemyDoctrineId(value: string): value is EnemyDoctrineId {
  return value in ENEMY_DOCTRINE_BY_ID;
}

export function selectEnemyDoctrineForCampaignNode(node: CampaignNodeDefinition | undefined): EnemyDoctrineDefinition | undefined {
  if (!node || node.nodeType !== "battle") {
    return undefined;
  }
  return selectEnemyDoctrineForBattle({
    mode: "campaign_node",
    campaignNodeId: node.id,
    missionTypeId: node.missionTypeId,
    modifierIds: node.scenarioModifierIds,
    enemyHeroId: node.enemyHeroId,
    difficulty: node.difficulty
  });
}

export function selectEnemyDoctrineForBattle(input: EnemyDoctrineSelectionInput): EnemyDoctrineDefinition | undefined {
  if (input.mode === "tutorial" || input.rewardsDisabled || input.missionTypeId === "skirmish_training") {
    return undefined;
  }
  const node = input.campaignNodeId ? CAMPAIGN_NODES.find((entry) => entry.id === input.campaignNodeId) : undefined;
  const missionTypeId = input.missionTypeId ?? node?.missionTypeId;
  const modifierIds = new Set([...(node?.scenarioModifierIds ?? []), ...(input.modifierIds ?? [])]);
  const enemyHeroId = input.enemyHeroId ?? node?.enemyHeroId;

  if (enemyHeroId === "veyra_cinders") {
    return ENEMY_DOCTRINE_BY_ID.hunter;
  }
  if (missionTypeId === "control") {
    return ENEMY_DOCTRINE_BY_ID.raider;
  }
  if (missionTypeId === "defense") {
    return ENEMY_DOCTRINE_BY_ID.warband;
  }
  if (modifierIds.has("mission_fortified_enemy")) {
    return ENEMY_DOCTRINE_BY_ID.fortress;
  }
  if (modifierIds.has("mission_enemy_patrols")) {
    return ENEMY_DOCTRINE_BY_ID.warband;
  }
  if (missionTypeId === "assault") {
    return enemyHeroId ? ENEMY_DOCTRINE_BY_ID.warband : ENEMY_DOCTRINE_BY_ID.fortress;
  }
  return undefined;
}

export function selectEnemyDoctrineForBattleLaunch(input: EnemyDoctrineSelectionInput): EnemyDoctrineDefinition | undefined {
  const node = input.campaignNodeId ? CAMPAIGN_NODES.find((entry) => entry.id === input.campaignNodeId) : undefined;
  return selectEnemyDoctrineForBattle({
    ...input,
    missionTypeId: input.missionTypeId ?? node?.missionTypeId,
    modifierIds: [...(node?.scenarioModifierIds ?? []), ...(input.modifierIds ?? [])],
    enemyHeroId: input.enemyHeroId ?? node?.enemyHeroId,
    difficulty: input.difficulty ?? node?.difficulty
  });
}

export function selectEnemyEliteSquadForBattle(input: EnemyDoctrineSelectionInput): EnemyEliteSquadDefinition | undefined {
  if (input.mode === "tutorial" || input.rewardsDisabled) {
    return undefined;
  }
  const node = input.campaignNodeId ? CAMPAIGN_NODES.find((entry) => entry.id === input.campaignNodeId) : undefined;
  const missionTypeId = input.missionTypeId ?? node?.missionTypeId;
  if (!missionTypeId || missionTypeId === "skirmish_training") {
    return undefined;
  }
  const doctrine = selectEnemyDoctrineForBattleLaunch(input);
  if (!doctrine) {
    return undefined;
  }
  const modifierIds = new Set([...(node?.scenarioModifierIds ?? []), ...(input.modifierIds ?? [])]);
  const milestoneEligible =
    Boolean(input.enemyHeroId ?? node?.enemyHeroId) ||
    missionTypeId === "defense" ||
    modifierIds.has("mission_fortified_enemy") ||
    modifierIds.has("mission_enemy_patrols");
  if (!milestoneEligible) {
    return undefined;
  }
  return ENEMY_ELITE_SQUADS.find(
    (squad) =>
      squad.eligibleDoctrineIds.includes(doctrine.id) &&
      squad.eligibleMissionTypeIds.includes(missionTypeId)
  );
}

export function shouldApplyEliteSquadToUnit(
  squad: EnemyEliteSquadDefinition | undefined,
  unitId: string,
  assignedCount: number
): boolean {
  if (!squad || assignedCount >= squad.maxUnitsPerBattle) {
    return false;
  }
  return squad.eligibleUnitIds.includes(unitId);
}

export function enemyDoctrineMissionHookSummary(node: CampaignNodeDefinition): string {
  const doctrine = selectEnemyDoctrineForCampaignNode(node);
  if (!doctrine) {
    return "No special doctrine";
  }
  return `${doctrine.name}: ${doctrine.counterplay}`;
}
