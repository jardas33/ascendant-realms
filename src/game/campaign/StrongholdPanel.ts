import type { StrongholdUpgradeDefinition } from "../core/GameTypes";
import {
  getStrongholdUpgradeAvailability,
  getStrongholdUpgradeRank,
  getPurchasedStrongholdUpgrades
} from "../core/StrongholdRules";
import { STRONGHOLD_UPGRADES } from "../data/strongholdUpgrades";
import type { CampaignSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./CampaignPresentationTypes";
import { formatResourceRewards } from "./CampaignResourcePanel";

export function renderStrongholdPanel(campaignSave: CampaignSaveData): string {
  const purchased = getPurchasedStrongholdUpgrades(campaignSave);
  return `
    <section class="stronghold-panel" data-testid="stronghold-panel">
      <div class="stronghold-header">
        <div>
          <p class="eyebrow">Command Camp</p>
          <h2>Stronghold</h2>
        </div>
        <strong data-testid="stronghold-purchased-count">${purchased.length}/${STRONGHOLD_UPGRADES.length}</strong>
      </div>
      <p class="quiet">Spend campaign resources on permanent upgrades for later battles.</p>
      <div class="stronghold-resource-line" data-testid="stronghold-resources">
        ${escapeHtml(formatResourceRewards(campaignSave.resources).join(" - ") || "No campaign resources")}
      </div>
      <div class="stronghold-upgrade-list">
        ${STRONGHOLD_UPGRADES.map((upgrade) => renderStrongholdUpgrade(campaignSave, upgrade)).join("")}
      </div>
    </section>
  `;
}

function renderStrongholdUpgrade(campaignSave: CampaignSaveData, upgrade: StrongholdUpgradeDefinition): string {
  const rank = getStrongholdUpgradeRank(campaignSave, upgrade.id);
  const availability = getStrongholdUpgradeAvailability(campaignSave, upgrade);
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
      <small>Cost: ${escapeHtml(formatResourceRewards(upgrade.cost).join(", ") || "None")}</small>
      <small>Effect: ${escapeHtml(formatStrongholdEffects(upgrade))}</small>
      <small class="flavor">${escapeHtml(upgrade.flavorText)}</small>
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
      return `Player building vision +${effect.amount}`;
    })
    .join("; ");
}
