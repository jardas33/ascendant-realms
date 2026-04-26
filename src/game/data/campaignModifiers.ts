import type { CampaignModifierDefinition, CampaignModifierId, CampaignNodeDefinition, ResourceBag } from "../core/GameTypes";
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
    description: "The next battle starts your hero with +10% maximum mana for that battle.",
    trigger: "next_battle",
    durationLabel: "Next battle",
    effects: {
      heroManaMultiplier: 1.1
    }
  },
  {
    id: "well_rested",
    name: "Well Rested",
    description: "The next battle starts your hero with +10% maximum HP for that battle.",
    trigger: "next_battle",
    durationLabel: "Next battle",
    effects: {
      heroMaxHpMultiplier: 1.1
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
    description: "The next node resource reward is increased by 10%.",
    trigger: "next_node_resource_reward",
    durationLabel: "Next resource reward",
    effects: {
      campaignResourceRewardMultiplier: 1.1
    }
  }
];

export const CAMPAIGN_MODIFIER_BY_ID: Record<CampaignModifierId, CampaignModifierDefinition> = Object.fromEntries(
  CAMPAIGN_MODIFIERS.map((modifier) => [modifier.id, modifier])
) as Record<CampaignModifierId, CampaignModifierDefinition>;

export function isCampaignModifierId(value: string): value is CampaignModifierId {
  return value in CAMPAIGN_MODIFIER_BY_ID;
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

  options.campaign.activeModifierIds.forEach((modifierId) => {
    if (!isCampaignModifierId(modifierId)) {
      return;
    }
    const modifier = CAMPAIGN_MODIFIER_BY_ID[modifierId];
    const applies =
      modifier.trigger === "next_battle" ||
      (modifier.trigger === "next_ashen_battle" && options.node.enemyFactionId === "ashen_covenant");
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
