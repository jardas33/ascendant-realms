import {
  activeRetinueUnits,
  formatRetinueUnitName,
  getRetinueCapacity
} from "../core/RetinueRules";
import { UNIT_BY_ID } from "../data/contentIndex";
import { getUnitVeterancyRank } from "../data/unitVeterancy";
import type { CampaignSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./CampaignPresentationTypes";

export function renderRetinuePanel(campaign: CampaignSaveData): string {
  const capacity = getRetinueCapacity(campaign);
  const units = activeRetinueUnits(campaign);
  return `
    <section class="stronghold-panel retinue-panel" data-testid="retinue-panel">
      <div class="stronghold-heading">
        <div>
          <h2>Retinue Camp</h2>
          <p class="quiet">Saved veterans deploy near your hero in future campaign battles.</p>
        </div>
        <span class="tag" data-testid="retinue-capacity">${units.length}/${capacity}</span>
      </div>
      ${
        units.length === 0
          ? `<p class="quiet">No veterans saved yet. Win campaign battles and add surviving Seasoned or better units from Results.</p>`
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
      <p>${escapeHtml(definition?.name ?? unit.unitTypeId)} - ${unit.xp} XP - ${unit.kills} kills</p>
      <button class="hud-button compact mini" data-retinue-dismiss="${escapeHtml(unit.retinueUnitId)}">Dismiss</button>
    </article>
  `;
}
