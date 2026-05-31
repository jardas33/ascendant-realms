import type {
  CampaignModifierDefinition,
  CampaignModifierId,
  CampaignNodeDefinition,
  CaptureSiteDefinition,
  EnemyAIConfig,
  ResourceBag
} from "../core/GameTypes";
import { MAP_BY_ID } from "./maps";
import type { CampaignSaveData } from "../save/SaveTypes";

interface CampaignLaunchModifier {
  id: string;
  value?: string | number | boolean;
}

export const CAMPAIGN_MODIFIERS: CampaignModifierDefinition[] = [
  {
    id: "inspired_militia",
    name: "Inspired Militia",
    description: "The next battle starts with one extra Militia near your Command Hall.",
    trigger: "next_battle",
    durationLabel: "Next battle",
    effects: {
      extraPlayerUnitIds: ["militia"]
    }
  },
  {
    id: "blessed_road",
    name: "Blessed Road",
    description: "The next battle starts your hero with +15% maximum mana for that battle.",
    trigger: "next_battle",
    durationLabel: "Next battle",
    effects: {
      heroManaMultiplier: 1.15
    }
  },
  {
    id: "well_rested",
    name: "Well Rested",
    description: "The next battle starts your hero with +20% maximum HP for that battle.",
    trigger: "next_battle",
    durationLabel: "Next battle",
    effects: {
      heroMaxHpMultiplier: 1.2
    }
  },
  {
    id: "angered_raiders",
    name: "Angered Raiders",
    description: "The next Ashen Covenant battle starts with one extra Raider.",
    trigger: "next_ashen_battle",
    durationLabel: "Next Ashen battle",
    effects: {
      extraEnemyUnitIds: ["raider"]
    }
  },
  {
    id: "local_support",
    name: "Local Support",
    description: "The next node resource reward is increased by 15%.",
    trigger: "next_node_resource_reward",
    durationLabel: "Next resource reward",
    effects: {
      campaignResourceRewardMultiplier: 1.15
    }
  },
  {
    id: "ashen_hostile_pressure",
    name: "Ashen Hostility",
    description: "Hostile Ashen Covenant reputation adds one extra Raider to Ashen battles.",
    trigger: "next_ashen_battle",
    durationLabel: "Reputation effect",
    effects: {
      extraEnemyUnitIds: ["raider"]
    }
  },
  {
    id: "marsh_guides",
    name: "Marsh Guides",
    description: "The next Cinderfen battle gives first-wave warnings 20s earlier and player buildings +60 vision.",
    trigger: "next_cinderfen_battle",
    durationLabel: "Next Cinderfen battle",
    effects: {
      buildingVisionBonus: 60,
      enemyWarningLeadSeconds: 20
    }
  },
  {
    id: "ash_filters",
    name: "Ash Filters",
    description: "The next Cinderfen battle starts your hero with +8% maximum HP and Mana.",
    trigger: "next_cinderfen_battle",
    durationLabel: "Next Cinderfen battle",
    effects: {
      heroMaxHpMultiplier: 1.08,
      heroManaMultiplier: 1.08
    }
  },
  {
    id: "shrine_attunement",
    name: "Shrine Attunement",
    description: "The next Cinderfen battle's Cinder Shrine Surge grants +5 extra Aether on first capture.",
    trigger: "next_cinderfen_battle",
    durationLabel: "Next Cinderfen battle",
    effects: {
      firstCaptureBonusResourceAdditions: {
        cinder_crossing: { aether: 5 }
      }
    }
  },
  {
    id: "mission_rich_veins",
    name: "Rich Veins",
    description: "Mission modifier: resource sites produce 10% more during this battle.",
    trigger: "mission_battle",
    durationLabel: "Mission modifier",
    effects: {
      captureSiteIncomeMultiplier: 1.1
    }
  },
  {
    id: "mission_enemy_patrols",
    name: "Enemy Patrols",
    description: "Mission modifier: enemy attacks arrive slightly faster during this battle.",
    trigger: "mission_battle",
    durationLabel: "Mission modifier",
    effects: {
      enemyAttackIntervalMultiplier: 0.95
    }
  },
  {
    id: "mission_fortified_enemy",
    name: "Fortified Enemy",
    description: "Mission modifier: enemy defenders hold a slightly stronger reserve.",
    trigger: "mission_battle",
    durationLabel: "Mission modifier",
    effects: {
      enemyInitialAttackDelayMultiplier: 1.06,
      enemyDefenseSquadSizeBonus: 1
    }
  },
  {
    id: "mission_aether_surge",
    name: "Lume Surge",
    description: "Mission modifier: the hero starts with +8% maximum mana for this battle.",
    trigger: "mission_battle",
    durationLabel: "Mission modifier",
    effects: {
      heroManaMultiplier: 1.08
    }
  }
];

export const CAMPAIGN_MODIFIER_BY_ID: Record<CampaignModifierId, CampaignModifierDefinition> = Object.fromEntries(
  CAMPAIGN_MODIFIERS.map((modifier) => [modifier.id, modifier])
) as Record<CampaignModifierId, CampaignModifierDefinition>;

export function isCampaignModifierId(value: string): value is CampaignModifierId {
  return value in CAMPAIGN_MODIFIER_BY_ID;
}

export interface CampaignBattleModifierEffects {
  captureSiteIncomeMultiplier: number;
  enemyAttackIntervalMultiplier: number;
  enemyInitialAttackDelayMultiplier: number;
  enemyDefenseSquadSizeBonus: number;
}

export function getCampaignBattleModifierEffects(modifiers: CampaignLaunchModifier[] = []): CampaignBattleModifierEffects {
  return modifiers.reduce<CampaignBattleModifierEffects>(
    (effects, modifier) => {
      const definition = CAMPAIGN_MODIFIER_BY_ID[modifier.id as CampaignModifierId];
      if (!definition) {
        return effects;
      }
      const modifierEffects = definition.effects;
      return {
        captureSiteIncomeMultiplier: Math.max(
          effects.captureSiteIncomeMultiplier,
          modifierEffects.captureSiteIncomeMultiplier ?? 1
        ),
        enemyAttackIntervalMultiplier: Math.min(
          effects.enemyAttackIntervalMultiplier,
          modifierEffects.enemyAttackIntervalMultiplier ?? 1
        ),
        enemyInitialAttackDelayMultiplier: Math.max(
          effects.enemyInitialAttackDelayMultiplier,
          modifierEffects.enemyInitialAttackDelayMultiplier ?? 1
        ),
        enemyDefenseSquadSizeBonus: Math.min(
          2,
          effects.enemyDefenseSquadSizeBonus + Math.max(0, modifierEffects.enemyDefenseSquadSizeBonus ?? 0)
        )
      };
    },
    {
      captureSiteIncomeMultiplier: 1,
      enemyAttackIntervalMultiplier: 1,
      enemyInitialAttackDelayMultiplier: 1,
      enemyDefenseSquadSizeBonus: 0
    }
  );
}

export function applyCampaignCaptureSiteModifierEffects(
  definition: CaptureSiteDefinition,
  modifiers: CampaignLaunchModifier[] = []
): CaptureSiteDefinition {
  const { captureSiteIncomeMultiplier } = getCampaignBattleModifierEffects(modifiers);
  if (captureSiteIncomeMultiplier === 1) {
    return definition;
  }
  return {
    ...definition,
    incomeAmount: Math.max(1, Math.round(definition.incomeAmount * captureSiteIncomeMultiplier))
  };
}

export function applyCampaignEnemyAIModifierEffects(
  config: EnemyAIConfig,
  modifiers: CampaignLaunchModifier[] = []
): EnemyAIConfig {
  const effects = getCampaignBattleModifierEffects(modifiers);
  if (
    effects.enemyAttackIntervalMultiplier === 1 &&
    effects.enemyInitialAttackDelayMultiplier === 1 &&
    effects.enemyDefenseSquadSizeBonus === 0
  ) {
    return config;
  }
  return {
    ...config,
    attackInterval: Math.max(20, Math.round(config.attackInterval * effects.enemyAttackIntervalMultiplier)),
    initialAttackDelay: Math.max(20, Math.round(config.initialAttackDelay * effects.enemyInitialAttackDelayMultiplier)),
    defenseSquadSize: Math.max(1, config.defenseSquadSize + effects.enemyDefenseSquadSizeBonus)
  };
}

export function grantCampaignModifiers(campaign: CampaignSaveData, modifierIds: string[] = []): CampaignSaveData {
  const active = new Set(campaign.activeModifierIds);
  modifierIds.filter(isCampaignModifierId).forEach((modifierId) => active.add(modifierId));
  return {
    ...campaign,
    activeModifierIds: [...active]
  };
}

export function removeCampaignModifiers(campaign: CampaignSaveData, modifierIds: string[] = []): CampaignSaveData {
  if (modifierIds.length === 0) {
    return campaign;
  }
  const removeIds = new Set(modifierIds);
  return {
    ...campaign,
    activeModifierIds: campaign.activeModifierIds.filter((modifierId) => !removeIds.has(modifierId))
  };
}

export function consumeBattleCampaignModifiers(options: {
  campaign: CampaignSaveData;
  node: CampaignNodeDefinition;
}): { campaign: CampaignSaveData; launchModifiers: CampaignLaunchModifier[]; consumedModifierIds: CampaignModifierId[] } {
  const consumedModifierIds: CampaignModifierId[] = [];
  const launchModifiers: CampaignLaunchModifier[] = [];
  const isCinderfenBattle = options.node.nodeType === "battle" && options.node.chapterId === "cinderfen_road";

  options.campaign.activeModifierIds.forEach((modifierId) => {
    if (!isCampaignModifierId(modifierId)) {
      return;
    }
    const modifier = CAMPAIGN_MODIFIER_BY_ID[modifierId];
    const applies =
      modifier.trigger === "next_battle" ||
      (modifier.trigger === "next_ashen_battle" && options.node.enemyFactionId === "ashen_covenant") ||
      (modifier.trigger === "next_cinderfen_battle" && isCinderfenBattle && cinderfenModifierAppliesToNode(modifier, options.node));
    if (!applies) {
      return;
    }
    consumedModifierIds.push(modifierId);
    launchModifiers.push({ id: modifierId });
  });

  if (consumedModifierIds.length === 0) {
    return { campaign: options.campaign, launchModifiers, consumedModifierIds };
  }

  const consumed = new Set(consumedModifierIds);
  return {
    campaign: {
      ...options.campaign,
      activeModifierIds: options.campaign.activeModifierIds.filter((modifierId) => !consumed.has(modifierId as CampaignModifierId))
    },
    launchModifiers,
    consumedModifierIds
  };
}

function cinderfenModifierAppliesToNode(modifier: CampaignModifierDefinition, node: CampaignNodeDefinition): boolean {
  const firstCaptureAdditions = Object.keys(modifier.effects.firstCaptureBonusResourceAdditions ?? {});
  const hasNonCaptureBattleEffect = Boolean(
    modifier.effects.extraPlayerUnitIds?.length ||
      modifier.effects.extraEnemyUnitIds?.length ||
      modifier.effects.heroManaMultiplier ||
      modifier.effects.heroMaxHpMultiplier ||
      modifier.effects.buildingVisionBonus ||
      modifier.effects.enemyWarningLeadSeconds
  );
  if (hasNonCaptureBattleEffect || firstCaptureAdditions.length === 0) {
    return true;
  }
  const map = node.mapId ? MAP_BY_ID[node.mapId] : undefined;
  return Boolean(map?.captureSites.some((site) => firstCaptureAdditions.includes(site.id)));
}

export function applyCampaignResourceRewardModifiers(options: {
  campaign: CampaignSaveData;
  resources: Partial<ResourceBag>;
}): { campaign: CampaignSaveData; resources: Partial<ResourceBag>; consumedModifierIds: CampaignModifierId[] } {
  const hasResources = Object.values(options.resources).some((amount) => (amount ?? 0) > 0);
  if (!hasResources) {
    return { campaign: options.campaign, resources: options.resources, consumedModifierIds: [] };
  }

  const modifierId = options.campaign.activeModifierIds.find((id) => {
    return isCampaignModifierId(id) && CAMPAIGN_MODIFIER_BY_ID[id].trigger === "next_node_resource_reward";
  });
  if (!modifierId || !isCampaignModifierId(modifierId)) {
    return { campaign: options.campaign, resources: options.resources, consumedModifierIds: [] };
  }

  const multiplier = CAMPAIGN_MODIFIER_BY_ID[modifierId].effects.campaignResourceRewardMultiplier ?? 1;
  const resources = Object.fromEntries(
    Object.entries(options.resources).map(([resource, amount]) => [resource, Math.max(0, Math.round((amount ?? 0) * multiplier))])
  ) as Partial<ResourceBag>;

  return {
    campaign: {
      ...options.campaign,
      activeModifierIds: options.campaign.activeModifierIds.filter((id) => id !== modifierId)
    },
    resources,
    consumedModifierIds: [modifierId]
  };
}
