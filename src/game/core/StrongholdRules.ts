import type { ResourceBag, StrongholdUpgradeDefinition, StrongholdUpgradeId } from "./GameTypes";
import { STRONGHOLD_UPGRADE_BY_ID, STRONGHOLD_UPGRADES, isStrongholdUpgradeId, strongholdLaunchModifierId } from "../data/strongholdUpgrades";
import type { CampaignSaveData } from "../save/SaveTypes";

export interface StrongholdUpgradeAvailability {
  ok: boolean;
  reasons: string[];
}

export interface StrongholdPurchaseResult {
  ok: boolean;
  reason?: string;
  campaign: CampaignSaveData;
  upgrade?: StrongholdUpgradeDefinition;
}

export function getStrongholdUpgradeRank(campaign: CampaignSaveData, upgradeId: string): number {
  return Math.max(0, Math.floor(campaign.strongholdUpgradeRanks?.[upgradeId] ?? 0));
}

export function getStrongholdUpgradeAvailability(
  campaign: CampaignSaveData,
  upgrade: StrongholdUpgradeDefinition
): StrongholdUpgradeAvailability {
  const reasons: string[] = [];
  const currentRank = getStrongholdUpgradeRank(campaign, upgrade.id);
  if (currentRank >= upgrade.maxRank) {
    reasons.push("Already purchased");
  }

  Object.entries(upgrade.prerequisites.upgradeRanks ?? {}).forEach(([requiredUpgradeId, requiredRank]) => {
    const requiredUpgrade = STRONGHOLD_UPGRADE_BY_ID[requiredUpgradeId as StrongholdUpgradeId];
    if (getStrongholdUpgradeRank(campaign, requiredUpgradeId) < (requiredRank ?? 1)) {
      reasons.push(`Requires ${requiredUpgrade?.name ?? titleCase(requiredUpgradeId)} rank ${requiredRank ?? 1}`);
    }
  });
  upgrade.prerequisites.completedNodeIds?.forEach((nodeId) => {
    if (!campaign.completedNodeIds.includes(nodeId)) {
      reasons.push(`Requires ${titleCase(nodeId)} completed`);
    }
  });

  Object.entries(upgrade.cost).forEach(([resource, amount]) => {
    const current = campaign.resources[resource as keyof ResourceBag] ?? 0;
    if ((amount ?? 0) > current) {
      reasons.push(`Need ${amount} ${titleCase(resource)}`);
    }
  });

  return {
    ok: reasons.length === 0,
    reasons
  };
}

export function purchaseStrongholdUpgrade(campaign: CampaignSaveData, upgradeId: string): StrongholdPurchaseResult {
  if (!isStrongholdUpgradeId(upgradeId)) {
    return {
      ok: false,
      reason: `Unknown stronghold upgrade ${upgradeId}.`,
      campaign
    };
  }
  const upgrade = STRONGHOLD_UPGRADE_BY_ID[upgradeId];
  const availability = getStrongholdUpgradeAvailability(campaign, upgrade);
  if (!availability.ok) {
    return {
      ok: false,
      reason: availability.reasons.join(", "),
      campaign,
      upgrade
    };
  }

  const nextRank = getStrongholdUpgradeRank(campaign, upgrade.id) + 1;
  const paidCampaign = recordCampaignResourceSpending(subtractCampaignResources(campaign, upgrade.cost), upgrade.cost);
  return {
    ok: true,
    campaign: {
      ...paidCampaign,
      strongholdUpgradeRanks: {
        ...(paidCampaign.strongholdUpgradeRanks ?? {}),
        [upgrade.id]: nextRank
      }
    },
    upgrade
  };
}

export function getPurchasedStrongholdUpgrades(campaign: CampaignSaveData): StrongholdUpgradeDefinition[] {
  return STRONGHOLD_UPGRADES.filter((upgrade) => getStrongholdUpgradeRank(campaign, upgrade.id) > 0);
}

export function getStrongholdLaunchModifiers(campaign: CampaignSaveData): Array<{ id: string }> {
  return getPurchasedStrongholdUpgrades(campaign).map((upgrade) => ({
    id: strongholdLaunchModifierId(upgrade.id)
  }));
}

function subtractCampaignResources(campaign: CampaignSaveData, resources: Partial<ResourceBag>): CampaignSaveData {
  return {
    ...campaign,
    resources: {
      crowns: campaign.resources.crowns - (resources.crowns ?? 0),
      stone: campaign.resources.stone - (resources.stone ?? 0),
      iron: campaign.resources.iron - (resources.iron ?? 0),
      aether: campaign.resources.aether - (resources.aether ?? 0)
    }
  };
}

function recordCampaignResourceSpending(campaign: CampaignSaveData, resources: Partial<ResourceBag>): CampaignSaveData {
  return {
    ...campaign,
    resourcesSpent: {
      crowns: campaign.resourcesSpent.crowns + Math.max(0, Math.floor(resources.crowns ?? 0)),
      stone: campaign.resourcesSpent.stone + Math.max(0, Math.floor(resources.stone ?? 0)),
      iron: campaign.resourcesSpent.iron + Math.max(0, Math.floor(resources.iron ?? 0)),
      aether: campaign.resourcesSpent.aether + Math.max(0, Math.floor(resources.aether ?? 0))
    }
  };
}

function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}
