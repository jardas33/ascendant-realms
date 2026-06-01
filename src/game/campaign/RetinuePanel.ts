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
          <p class="quiet">Choose a small ready reserve before battle. Recovering veterans wait one eligible first-clear step; lost units are removed.</p>
        </div>
        <span class="tag" data-testid="retinue-capacity">${capacity.activeCount}/${capacity.rosterCapacity} roster</span>
      </div>
      <div class="meta-summary-grid retinue-status-grid">
        <span><small>Deployed</small><strong data-testid="retinue-deployment-capacity">${capacity.deploymentCount}/${capacity.deploymentCapacity} selected</strong></span>
        <span><small>Ready reserve</small><strong>${capacity.reserveCount}</strong></span>
        <span><small>Recovering</small><strong>${capacity.recoveringCount}</strong></span>
        <span><small>Roster cap</small><strong>${capacity.baseRosterCapacity} saved units</strong></span>
        <span><small>Training Yard II</small><strong>${capacity.trainingYardDeploymentBonus > 0 ? "+1 deployment slot" : "No deployment bonus"}</strong></span>
        <span><small>Reinforcement</small><strong>${capacity.reserveCount > 0 ? "Ready reserve eligible" : "No ready reserve"}</strong></span>
      </div>
      ${
        units.length === 0
          ? `<p class="quiet">No veterans saved yet. Win campaign battles and add selected surviving Seasoned or better units from Results.</p>`
          : `<div class="stronghold-grid">
              ${units.map((unit) => renderRetinueUnit(unit, selectedIds, capacity.deploymentCount >= capacity.deploymentCapacity)).join("")}
            </div>`
      }
      <details class="support-card-details">
        <summary>Retinue Rules</summary>
        <p class="quiet">Deployment is optional. Recovering units cannot deploy or reinforce. Retinue death is permanent in V1. Tutorial and skirmish routes ignore Retinue deployment.</p>
      </details>
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
  const stateLabel = recovering ? "Recovering" : selected ? "Deployed" : "Ready";
  const reserveLabel = recovering ? "Unavailable" : selected ? "In deployment" : "Reserve";
  const buttonLabel = selected ? "Reserve" : recovering ? "Recovering" : deployDisabled ? "Deployment Full" : "Deploy";
  return `
    <article class="stronghold-card purchased" data-testid="retinue-unit-${escapeHtml(unit.retinueUnitId)}">
      <div class="stronghold-title">
        <strong>${escapeHtml(formatRetinueUnitName(unit))}</strong>
        <span>${escapeHtml(stateLabel)}</span>
      </div>
      <p>${escapeHtml(formatRetinueDeploymentLabel(unit))}</p>
      <div class="tag-row">
        <span class="tag">${escapeHtml(statusLabel)}</span>
        <span class="tag">${escapeHtml(reserveLabel)}</span>
        <span class="tag">${escapeHtml(rank.name)}</span>
      </div>
      <p><strong>Role:</strong> ${escapeHtml(role.label)} - ${escapeHtml(formatUnitRoleTags(role))}</p>
      <p>${escapeHtml(formatUnitVeterancyXpProgress(unit.xp))} - ${unit.kills} kills</p>
      <small>Reinforcement: ${recovering ? "blocked while recovering" : selected ? "deployed at battle start" : "eligible if kept ready in reserve"}</small>
      ${recovering ? `<small>Blocked: recovering units return Ready after one first-clear campaign progression step.</small>` : ""}
      <details class="support-card-details retinue-member-details">
        <summary>Member Details</summary>
        <small>${escapeHtml(definition?.name ?? unit.unitTypeId)}</small>
        <small>Rank bonus: ${escapeHtml(formatUnitVeterancyBonusSummary(unit.rank))}</small>
        <small>${escapeHtml(rank.flavorText ?? "")} ${unit.battlesSurvived ?? 0} survived / ${unit.missionsDeployed ?? 0} deployed.</small>
      </details>
      <button
        class="hud-button compact mini"
        data-retinue-deploy-toggle="${escapeHtml(unit.retinueUnitId)}"
        ${deployDisabled ? "disabled" : ""}
      >${buttonLabel}</button>
      <button class="hud-button compact mini" data-retinue-dismiss="${escapeHtml(unit.retinueUnitId)}" aria-label="Dismiss ${escapeHtml(formatRetinueUnitName(unit))} from retinue">Dismiss from Retinue</button>
    </article>
  `;
}
