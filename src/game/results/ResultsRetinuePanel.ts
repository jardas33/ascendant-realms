import {
  activeRetinueUnits,
  createRetinueUnitFromVeteran,
  formatRetinueDeploymentLabel,
  formatRetinueUnitSummary,
  getRetinueCapacityBreakdown,
  isRetinueEligibleVeteran,
  retinueEligibilityReason
} from "../core/RetinueRules";
import { formatUnitVeterancyBonusSummary, formatUnitVeterancyXpProgress } from "../data/unitVeterancy";
import type { CampaignSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./ResultsFormatting";
import type { ResultsData } from "./ResultsTypes";

export function renderRetinueRecruitment(data: ResultsData, campaign?: CampaignSaveData): string {
  if (data.stats.outcome !== "victory" || data.launchRequest?.mode !== "campaign_node" || !campaign) {
    return "";
  }
  const summary = data.stats.veteranSummary;
  const candidates = summary?.notableVeterans ?? [];
  const eligible = candidates.filter(isRetinueEligibleVeteran);
  const sourceBattleId = retinueSourceBattleId(data);
  const currentRetinue = activeRetinueUnits(campaign);
  const capacity = getRetinueCapacityBreakdown(campaign);
  const capacityFull = capacity.activeCount >= capacity.rosterCapacity;

  return `
    <section class="result-block wide retinue-results" data-testid="results-retinue-panel">
      <h2>Retinue Camp</h2>
      <p class="quiet">Add selected surviving Seasoned or better units to the roster, then choose a small deployment from the Campaign Map. If a retinue unit dies, it is permanently removed after the battle in V1.</p>
      <div class="results-grid compact">
        <span>Roster capacity</span><strong data-testid="results-retinue-capacity">${capacity.activeCount}/${capacity.rosterCapacity} roster</strong>
        <span>Deployment selected</span><strong>${capacity.deploymentCount}/${capacity.deploymentCapacity} selected</strong>
        <span>Base camp</span><strong>${capacity.baseRosterCapacity} roster slots</strong>
        <span>Training Yard II</span><strong>${capacity.trainingYardDeploymentBonus > 0 ? "+1 deployment slot" : "No deployment bonus"}</strong>
        ${
          currentRetinue.length > 0
            ? `<span>Current retinue</span><strong>${currentRetinue.map(formatRetinueUnitSummary).map(escapeHtml).join("; ")}</strong>`
            : `<span>Current retinue</span><strong>Empty</strong>`
        }
      </div>
      ${
        capacityFull
          ? `<p class="quiet retinue-full-message" data-testid="retinue-full-message">Retinue roster is full. Skip recruitment here, or return to the Campaign Map and dismiss a unit before adding another veteran.</p>`
          : ""
      }
      ${
        candidates.length === 0
          ? `<p class="quiet">No notable surviving units were available this battle.</p>`
          : `<p class="quiet">Eligible recruits this battle: ${eligible.length}. Recruits can gain ranks in battle, but only Seasoned or better survivors can join the retinue.</p>
            <div class="reward-list">
              ${candidates.map((entry) => renderRetinueCandidate(data, campaign, sourceBattleId, capacityFull, entry.unitInstanceId)).join("")}
            </div>`
      }
    </section>
  `;
}

function renderRetinueCandidate(
  data: ResultsData,
  campaign: CampaignSaveData,
  sourceBattleId: string,
  capacityFull: boolean,
  unitInstanceId: string
): string {
  const entry = data.stats.veteranSummary?.notableVeterans.find((candidate) => candidate.unitInstanceId === unitInstanceId);
  if (!entry) {
    return "";
  }
  const candidate = createRetinueUnitFromVeteran(entry, sourceBattleId);
  const eligible = isRetinueEligibleVeteran(entry);
  const alreadySaved = campaign.retinueUnits.some(
    (unit) => unit.retinueUnitId === candidate.retinueUnitId || unit.retinueUnitId === entry.unitInstanceId
  );
  const disabledReason = alreadySaved
    ? "Already Saved"
    : !eligible
      ? "Not Eligible"
      : capacityFull
        ? "Capacity Full"
        : "";
  return `
    <article class="reward-card" data-testid="results-retinue-candidate-${escapeHtml(entry.unitInstanceId)}">
      <div>
        <strong>${escapeHtml(formatRetinueDeploymentLabel(candidate))}</strong>
        <p>${escapeHtml(formatUnitVeterancyXpProgress(entry.xp))} - ${entry.kills} kills - ${entry.damageDealt} damage</p>
        <small>Rank bonus: ${escapeHtml(formatUnitVeterancyBonusSummary(entry.rank))}</small>
        <small>${escapeHtml(retinueEligibilityReason(entry))}</small>
      </div>
      <button
        data-results-action="add_retinue"
        data-unit-instance-id="${escapeHtml(entry.unitInstanceId)}"
        ${disabledReason ? "disabled" : ""}
      >${disabledReason || "Add to Retinue"}</button>
    </article>
  `;
}

export function retinueSourceBattleId(data: ResultsData): string {
  return data.launchRequest?.campaignNodeId ?? data.launchRequest?.requestId ?? "campaign_battle";
}
