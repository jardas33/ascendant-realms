import type { ResourceBag } from "../core/GameTypes";
import { CAMPAIGN_MODIFIER_BY_ID, FACTION_BY_ID } from "../data/contentIndex";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import { escapeHtml, titleCase } from "./CampaignPresentationTypes";

export function renderCampaignResourceBank(campaignSave: CampaignSaveData): string {
  return `
      <div class="campaign-bank" data-testid="campaign-bank">
        ${RESOURCE_DEFINITIONS.map(
          (resource) => `
            <div class="resource-pill campaign-bank-pill" style="--resource-color: #${resource.color.toString(16).padStart(6, "0")}">
              <span>${escapeHtml(resource.name)}</span>
              <strong>${campaignSave.resources[resource.id]}</strong>
            </div>
          `
        ).join("")}
      </div>
      <p class="quiet campaign-bank-note">Campaign resources are saved between nodes. Spent so far: ${escapeHtml(formatResourceRewards(campaignSave.resourcesSpent).join(", ") || "None")}.</p>
    `;
}

export function renderReputation(heroSave: HeroSaveData): string {
  const reputationIds = ["free_marches", "ashen_covenant", "sylvan_concord", "common_folk", "old_faith"];
  return `
      <div class="reputation-grid">
        ${reputationIds
          .map((factionId) => {
            const faction = FACTION_BY_ID[factionId];
            const value = heroSave.factionReputation[factionId] ?? 0;
            return `
              <div class="reputation-row">
                <span>${escapeHtml(faction?.name ?? titleCase(factionId))}</span>
                <strong class="${value < 0 ? "negative" : value > 0 ? "positive" : ""}">${value > 0 ? "+" : ""}${value}</strong>
              </div>
            `;
          })
          .join("")}
      </div>
    `;
}

export function renderActiveModifiers(campaignSave: CampaignSaveData): string {
  const modifiers = campaignSave.activeModifierIds
    .map((modifierId) => CAMPAIGN_MODIFIER_BY_ID[modifierId])
    .filter(Boolean);
  if (modifiers.length === 0) {
    return `<p class="quiet">No active campaign modifiers.</p>`;
  }
  return `
      <div class="modifier-list">
        ${modifiers
          .map(
            (modifier) => `
              <div class="modifier-card">
                <strong>${escapeHtml(modifier.name)}</strong>
                <span>${escapeHtml(modifier.description)}</span>
                <small>${escapeHtml(modifier.durationLabel)}</small>
              </div>
            `
          )
          .join("")}
      </div>
    `;
}

export function formatResourceRewards(resources: Partial<ResourceBag>): string[] {
  return Object.entries(resources)
    .filter(([, amount]) => typeof amount === "number" && amount > 0)
    .map(([resource, amount]) => {
      const definition = RESOURCE_DEFINITIONS.find((entry) => entry.id === resource);
      return `${amount} ${definition?.name ?? titleCase(resource)}`;
    });
}
