import {
  formatRetinueDeploymentLabel,
  formatRetinueStatusLabel,
  formatRetinueUnitName,
  getRetinueCapacityBreakdown,
  retinueRosterUnits,
  selectedRetinueUnitIds
} from "../core/RetinueRules";
import { UNIT_BY_ID } from "../data/contentIndex";
import { formatUnitRoleTags, getUnitRoleIdentity } from "../data/unitRoles";
import {
  formatUnitVeterancyBonusSummary,
  formatUnitVeterancyXpProgress,
  getUnitVeterancyRank
} from "../data/unitVeterancy";
import type { CampaignSaveData, RetinueUnitSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./CampaignPresentationTypes";

export function renderRetinuePanel(campaign: CampaignSaveData): string {
  const capacity = getRetinueCapacityBreakdown(campaign);
  const units = retinueRosterUnits(campaign);
  const selectedIds = new Set(selectedRetinueUnitIds(campaign));
  return `
    <section class="stronghold-panel retinue-panel" data-testid="retinue-panel">
      <div class="stronghold-heading">
        <div>
          <h2>Retinue Camp</h2>
          <p class="quiet">Saved veterans can deploy near your hero in eligible campaign battles. Low-HP survivors may need one first-clear mission to recover. Retinue death is permanent in V1.</p>
        </div>
        <span class="tag" data-testid="retinue-capacity">${capacity.activeCount}/${capacity.rosterCapacity} roster</span>
      </div>
      <div class="results-grid compact">
        <span>Deployment selected</span><strong data-testid="retinue-deployment-capacity">${capacity.deploymentCount}/${capacity.deploymentCapacity} selected</strong>
        <span>Ready reserves</span><strong>${capacity.reserveCount}</strong>
        <span>Recovering</span><strong>${capacity.recoveringCount}</strong>
        <span>Roster cap</span><strong>${capacity.baseRosterCapacity} saved units</strong>
        <span>Training Yard II</span><strong>${capacity.trainingYardDeploymentBonus > 0 ? "+1 deployment slot" : "No deployment bonus"}</strong>
      </div>
      ${
        units.length === 0
          ? `<p class="quiet">No veterans saved yet. Win campaign battles and add selected surviving Seasoned or better units from Results.</p>`
          : `<div class="stronghold-grid">
              ${units.map((unit) => renderRetinueUnit(unit, selectedIds, capacity.deploymentCount >= capacity.deploymentCapacity)).join("")}
            </div>`
      }
      <p class="quiet">Deployment is optional. Recovering units cannot deploy or reinforce. Tutorial and skirmish routes ignore Retinue deployment.</p>
    </section>
  `;
}

function renderRetinueUnit(
  unit: RetinueUnitSaveData,
  selectedIds: ReadonlySet<string>,
  deploymentFull: boolean
): string {
  const definition = UNIT_BY_ID[unit.unitTypeId];
  const rank = getUnitVeterancyRank(unit.rank);
  const role = getUnitRoleIdentity(unit.unitTypeId);
  const selected = selectedIds.has(unit.retinueUnitId);
  const recovering = unit.status === "recovering";
  const deployDisabled = recovering || (!selected && deploymentFull);
  const statusLabel = formatRetinueStatusLabel(unit, selected);
  const buttonLabel = selected ? "Reserve" : recovering ? "Recovering" : deployDisabled ? "Deployment Full" : "Deploy";
  return `
    <article class="stronghold-card purchased" data-testid="retinue-unit-${escapeHtml(unit.retinueUnitId)}">
      <div class="stronghold-title">
        <strong>${escapeHtml(formatRetinueUnitName(unit))}</strong>
        <span>${escapeHtml(statusLabel)}</span>
      </div>
      <p>${escapeHtml(formatRetinueDeploymentLabel(unit))}</p>
      <p><strong>Role:</strong> ${escapeHtml(role.label)} - ${escapeHtml(formatUnitRoleTags(role))}</p>
      <p>${escapeHtml(definition?.name ?? unit.unitTypeId)} - ${escapeHtml(formatUnitVeterancyXpProgress(unit.xp))} - ${unit.kills} kills</p>
      <small>Rank bonus: ${escapeHtml(formatUnitVeterancyBonusSummary(unit.rank))}</small>
      <small>${escapeHtml(rank.flavorText ?? "")} ${unit.battlesSurvived ?? 0} survived / ${unit.missionsDeployed ?? 0} deployed.</small>
      ${recovering ? `<small>Blocked: recovering units return Ready after one first-clear campaign progression step.</small>` : ""}
      <button
        class="hud-button compact mini"
        data-retinue-deploy-toggle="${escapeHtml(unit.retinueUnitId)}"
        ${deployDisabled ? "disabled" : ""}
      >${buttonLabel}</button>
      <button class="hud-button compact mini" data-retinue-dismiss="${escapeHtml(unit.retinueUnitId)}" aria-label="Dismiss ${escapeHtml(formatRetinueUnitName(unit))} from retinue">Dismiss from Retinue</button>
    </article>
  `;
}
