import type { ResourceBag } from "../core/GameTypes";
import { CAMPAIGN_MODIFIER_BY_ID } from "../data/contentIndex";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import { formatReputationValue } from "../data/reputation";
import type { CampaignSaveData } from "../save/SaveTypes";
import type { CampaignReputationViewModel } from "./CampaignPresentationTypes";
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

export function renderReputation(reputation: CampaignReputationViewModel): string {
  return `
      <div class="reputation-grid" data-testid="campaign-reputation">
        ${reputation.rows
          .map(
            (row) => `
              <div class="reputation-row" data-testid="reputation-${row.factionId}">
                <span>${escapeHtml(row.factionName)}</span>
                <span>${escapeHtml(row.rankLabel)}</span>
                <strong class="${row.value < 0 ? "negative" : row.value > 0 ? "positive" : ""}">${escapeHtml(formatReputationValue(row.value))}</strong>
              </div>
            `
          )
          .join("")}
      </div>
      <div class="modifier-list reputation-effects" data-testid="reputation-effects">
        ${
          reputation.activeEffects.length === 0
            ? `<p class="quiet">No active reputation effects.</p>`
            : reputation.activeEffects
                .map(
                  (effect) => `
                    <div class="modifier-card reputation-effect-card" data-testid="reputation-effect-${effect.id}">
                      <strong>${escapeHtml(effect.name)}</strong>
                      <span>${escapeHtml(effect.factionName)} - ${escapeHtml(effect.description)}</span>
                    </div>
                  `
                )
                .join("")
        }
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
