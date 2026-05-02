import {
  activeRetinueUnits,
  createRetinueUnitFromVeteran,
  formatRetinueUnitSummary,
  getRetinueCapacity,
  isRetinueEligibleVeteran
} from "../core/RetinueRules";
import type { CampaignSaveData } from "../save/SaveTypes";
import { escapeHtml } from "./ResultsFormatting";
import type { ResultsData } from "./ResultsTypes";

export function renderRetinueRecruitment(data: ResultsData, campaign?: CampaignSaveData): string {
  if (data.stats.outcome !== "victory" || data.launchRequest?.mode !== "campaign_node" || !campaign) {
    return "";
  }
  const summary = data.stats.veteranSummary;
  const eligible = (summary?.notableVeterans ?? []).filter(isRetinueEligibleVeteran);
  const sourceBattleId = retinueSourceBattleId(data);
  const currentRetinue = activeRetinueUnits(campaign);
  const capacity = getRetinueCapacity(campaign);
  const capacityFull = currentRetinue.length >= capacity;

  return `
    <section class="result-block wide retinue-results" data-testid="results-retinue-panel">
      <h2>Retinue Camp</h2>
      <p class="quiet">Add surviving Seasoned or better units to deploy near your hero in future campaign battles.</p>
      <div class="results-grid compact">
        <span>Capacity</span><strong>${currentRetinue.length}/${capacity}</strong>
        ${
          currentRetinue.length > 0
            ? `<span>Current retinue</span><strong>${currentRetinue.map(formatRetinueUnitSummary).map(escapeHtml).join("; ")}</strong>`
            : `<span>Current retinue</span><strong>Empty</strong>`
        }
      </div>
      ${
        eligible.length === 0
          ? `<p class="quiet">No surviving Seasoned or better units are available to add.</p>`
          : `<div class="reward-list">
              ${eligible.map((entry) => renderEligibleVeteran(data, campaign, sourceBattleId, capacityFull, entry.unitInstanceId)).join("")}
            </div>`
      }
    </section>
  `;
}

function renderEligibleVeteran(
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
  const alreadySaved = campaign.retinueUnits.some(
    (unit) => unit.retinueUnitId === candidate.retinueUnitId || unit.retinueUnitId === entry.unitInstanceId
  );
  const disabledReason = alreadySaved ? "Already in retinue" : capacityFull ? "Retinue full" : "";
  return `
    <article class="reward-card">
      <div>
        <strong>${escapeHtml(entry.unitName)} - ${escapeHtml(entry.rankName)}</strong>
        <p>${entry.xp} XP - ${entry.kills} kills - ${entry.damageDealt} damage</p>
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
