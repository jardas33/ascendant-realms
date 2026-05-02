import {
  activeRetinueUnits,
  formatRetinueDeploymentLabel,
  formatRetinueUnitName,
  getRetinueCapacityBreakdown
} from "../core/RetinueRules";
import { UNIT_BY_ID } from "../data/contentIndex";
import {
  formatUnitVeterancyBonusSummary,
  formatUnitVeterancyXpProgress,
  getUnitVeterancyRank
} from "../data/unitVeterancy";
import type { CampaignSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./CampaignPresentationTypes";

export function renderRetinuePanel(campaign: CampaignSaveData): string {
  const capacity = getRetinueCapacityBreakdown(campaign);
  const units = activeRetinueUnits(campaign);
  return `
    <section class="stronghold-panel retinue-panel" data-testid="retinue-panel">
      <div class="stronghold-heading">
        <div>
          <h2>Retinue Camp</h2>
          <p class="quiet">Saved veterans deploy near your hero in future campaign battles. Retinue death is permanent in V1.</p>
        </div>
        <span class="tag" data-testid="retinue-capacity">${capacity.activeCount}/${capacity.capacity} active</span>
      </div>
      <div class="results-grid compact">
        <span>Base capacity</span><strong>${capacity.baseCapacity}</strong>
        <span>Training Yard II</span><strong>${capacity.trainingYardBonus > 0 ? "+1 capacity active" : "No capacity bonus"}</strong>
      </div>
      ${
        units.length === 0
          ? `<p class="quiet">No veterans saved yet. Win campaign battles and add selected surviving Seasoned or better units from Results.</p>`
          : `<div class="stronghold-grid">
              ${units.map(renderRetinueUnit).join("")}
            </div>`
      }
    </section>
  `;
}

function renderRetinueUnit(unit: ReturnType<typeof activeRetinueUnits>[number]): string {
  const definition = UNIT_BY_ID[unit.unitTypeId];
  const rank = getUnitVeterancyRank(unit.rank);
  return `
    <article class="stronghold-card purchased" data-testid="retinue-unit-${escapeHtml(unit.retinueUnitId)}">
      <div class="stronghold-title">
        <strong>${escapeHtml(formatRetinueUnitName(unit))}</strong>
        <span>${escapeHtml(rank.name)}</span>
      </div>
      <p>${escapeHtml(formatRetinueDeploymentLabel(unit))}</p>
      <p>${escapeHtml(definition?.name ?? unit.unitTypeId)} - ${escapeHtml(formatUnitVeterancyXpProgress(unit.xp))} - ${unit.kills} kills</p>
      <small>Rank bonus: ${escapeHtml(formatUnitVeterancyBonusSummary(unit.rank))}</small>
      <button class="hud-button compact mini" data-retinue-dismiss="${escapeHtml(unit.retinueUnitId)}" aria-label="Dismiss ${escapeHtml(formatRetinueUnitName(unit))} from retinue">Dismiss from Retinue</button>
    </article>
  `;
}
