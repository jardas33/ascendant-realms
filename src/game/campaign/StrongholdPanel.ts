import type { StrongholdUpgradeDefinition } from "../core/GameTypes";
import {
  getStrongholdUpgradeAvailability,
  getStrongholdUpgradeRank,
  getPurchasedStrongholdUpgrades
} from "../core/StrongholdRules";
import { getAdjustedStrongholdUpgradeCost } from "../data/reputation";
import { STRONGHOLD_UPGRADES } from "../data/strongholdUpgrades";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./CampaignPresentationTypes";
import { formatResourceRewards } from "./CampaignResourcePanel";

export function renderStrongholdPanel(campaignSave: CampaignSaveData, heroSave?: HeroSaveData): string {
  const purchased = getPurchasedStrongholdUpgrades(campaignSave);
  const availableCount = STRONGHOLD_UPGRADES.filter((upgrade) => {
    const rank = getStrongholdUpgradeRank(campaignSave, upgrade.id);
    return rank < upgrade.maxRank && getStrongholdUpgradeAvailability(campaignSave, upgrade, heroSave).ok;
  }).length;
  const lockedCount = STRONGHOLD_UPGRADES.length - purchased.length - availableCount;
  return `
    <section class="stronghold-panel" data-testid="stronghold-panel">
      <div class="stronghold-header">
        <div>
          <p class="eyebrow">Command Camp</p>
          <h2>Stronghold</h2>
        </div>
        <strong data-testid="stronghold-purchased-count">${purchased.length}/${STRONGHOLD_UPGRADES.length}</strong>
      </div>
      <div class="meta-summary-grid stronghold-overview" data-testid="stronghold-overview">
        <span><small>Current tier</small><strong>${escapeHtml(formatStrongholdTier(campaignSave))}</strong></span>
        <span><small>Available</small><strong>${availableCount}</strong></span>
        <span><small>Locked</small><strong>${Math.max(0, lockedCount)}</strong></span>
        <span><small>Purchased</small><strong>${purchased.length}</strong></span>
      </div>
      <div class="stronghold-resource-line" data-testid="stronghold-resources">
        ${escapeHtml(formatResourceRewards(campaignSave.resources).join(" - ") || "No campaign resources")}
      </div>
      <div class="stronghold-upgrade-list">
        ${STRONGHOLD_UPGRADES.map((upgrade) => renderStrongholdUpgrade(campaignSave, upgrade, heroSave)).join("")}
      </div>
    </section>
  `;
}

function renderStrongholdUpgrade(
  campaignSave: CampaignSaveData,
  upgrade: StrongholdUpgradeDefinition,
  heroSave?: HeroSaveData
): string {
  const rank = getStrongholdUpgradeRank(campaignSave, upgrade.id);
  const availability = getStrongholdUpgradeAvailability(campaignSave, upgrade, heroSave);
  const purchased = rank >= upgrade.maxRank;
  const locked = !availability.ok && !purchased;
  const reason = availability.reasons.join(", ");
  return `
    <article
      class="stronghold-upgrade ${purchased ? "purchased" : locked ? "locked" : "available"}"
      data-testid="stronghold-upgrade-${upgrade.id}"
    >
      <div class="stronghold-upgrade-title">
        <strong>${escapeHtml(upgrade.name)}</strong>
        <span>Tier ${upgrade.tier} - Rank ${rank}/${upgrade.maxRank}</span>
      </div>
      <p>${escapeHtml(upgrade.description)}</p>
      <small>Cost: ${escapeHtml(formatStrongholdCost(upgrade, heroSave))}</small>
      <small>Prerequisite: ${purchased ? "Complete" : locked ? escapeHtml(reason || "Locked") : "Met"}</small>
      <small>Benefit: ${escapeHtml(formatStrongholdEffects(upgrade))}</small>
      <details class="support-card-details">
        <summary>More Details</summary>
        <small>Status: ${purchased ? "Purchased" : locked ? escapeHtml(reason || "Locked") : "Available"}</small>
        <small class="flavor">${escapeHtml(upgrade.flavorText)}</small>
      </details>
      <div class="stronghold-upgrade-footer">
        <span>${purchased ? "Purchased" : locked ? escapeHtml(reason || "Locked") : "Available"}</span>
        <button
          data-testid="stronghold-purchase-${upgrade.id}"
          data-stronghold-upgrade="${upgrade.id}"
          ${availability.ok ? "" : "disabled"}
        >
          ${purchased ? "Purchased" : "Upgrade"}
        </button>
      </div>
    </article>
  `;
}

function formatStrongholdTier(campaignSave: CampaignSaveData): string {
  const purchasedTiers = STRONGHOLD_UPGRADES.filter((upgrade) => getStrongholdUpgradeRank(campaignSave, upgrade.id) > 0).map(
    (upgrade) => upgrade.tier
  );
  return purchasedTiers.length > 0 ? `Tier ${Math.max(...purchasedTiers)}` : "Tier 0";
}

function formatStrongholdCost(upgrade: StrongholdUpgradeDefinition, heroSave?: HeroSaveData): string {
  const adjustedCost = getAdjustedStrongholdUpgradeCost(upgrade.cost, heroSave);
  const adjusted = formatResourceRewards(adjustedCost).join(", ") || "None";
  const base = formatResourceRewards(upgrade.cost).join(", ") || "None";
  return adjusted === base ? adjusted : `${adjusted} (base ${base})`;
}

function formatStrongholdEffects(upgrade: StrongholdUpgradeDefinition): string {
  return upgrade.effects
    .map((effect) => {
      if (effect.type === "extra-starting-unit") {
        return `+${effect.count} ${effect.unitId} at battle start`;
      }
      if (effect.type === "starting-resources") {
        return `Battle start resources: ${formatResourceRewards(effect.resources).join(", ")}`;
      }
      if (effect.type === "hero-max-hp-multiplier") {
        return `Hero max HP +${Math.round((effect.multiplier - 1) * 100)}%`;
      }
      if (effect.type === "hero-max-mana-multiplier") {
        return `Hero max Mana +${Math.round((effect.multiplier - 1) * 100)}%`;
      }
      if (effect.type === "building-vision-bonus") {
        return `Player building vision +${effect.amount}`;
      }
      if (effect.type === "enemy-wave-warning-lead") {
        return `First enemy wave warning ${effect.seconds}s earlier`;
      }
      if (effect.type === "watchtower-range-multiplier") {
        return `Watchtower attack range +${Math.round((effect.multiplier - 1) * 100)}%`;
      }
      if (effect.type === "first-building-construction-time-multiplier") {
        return `First player building construction ${Math.round((1 - effect.multiplier) * 100)}% faster`;
      }
      return `${effect.unitId} training ${Math.round((1 - effect.multiplier) * 100)}% faster`;
    })
    .join("; ");
}
