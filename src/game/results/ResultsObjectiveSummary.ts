import type { BattleMapDefinition } from "../core/GameTypes";
import { formatTime } from "../core/MathUtils";
import { isRetinueEligibleVeteran, retinueEligibilityReason } from "../core/RetinueRules";
import { formatUnitVeterancyBonusSummary, formatUnitVeterancyXpProgress } from "../data/unitVeterancy";
import { escapeHtml, formatXpProgress, titleCase } from "./ResultsFormatting";
import type { ResultsData } from "./ResultsTypes";
import type { ResultsViewModel } from "./ResultsViewModel";

export function renderBattleSummary(data: ResultsData, viewModel: ResultsViewModel): string {
  const { stats } = data;
  return `
    <div class="results-sections">
      <section class="result-block">
        <h2>Battle</h2>
        <div class="results-grid compact">
          <span>Map</span><strong>${escapeHtml(viewModel.map?.name ?? "Unknown")}</strong>
          <span>Difficulty</span><strong>${escapeHtml(viewModel.difficulty?.name ?? "Unknown")}</strong>
          <span>Battle time</span><strong>${formatTime(stats.timeSeconds)}</strong>
          <span>First site captured</span><strong>${stats.firstSiteCaptured ? titleCase(stats.firstSiteCaptured) : "None"}</strong>
          <span>Buildings built</span><strong>${stats.buildingsBuilt}</strong>
          <span>Units trained</span><strong>${stats.unitsTrained}</strong>
          <span>Enemy waves survived</span><strong>${stats.enemyWavesSurvived}</strong>
          <span>Units killed</span><strong>${stats.unitsKilled}</strong>
          <span>Buildings destroyed</span><strong>${stats.buildingsDestroyed}</strong>
          <span>Sites captured</span><strong>${stats.resourcesCaptured}</strong>
          <span>Enemy commander</span><strong>${escapeHtml(stats.enemyHeroName ?? "None")}</strong>
          <span>Commander defeated</span><strong>${stats.enemyHeroId ? (stats.enemyHeroDefeated ? `Yes (${formatTime(stats.enemyHeroDefeatedAtSeconds ?? stats.timeSeconds)})` : "No") : "None"}</strong>
        </div>
      </section>
      <section class="result-block">
        <h2>Hero XP</h2>
        ${renderXpProgress(data, viewModel)}
      </section>
    </div>
    ${renderVeteranSummary(data)}
    ${renderRivalOutcome(data)}
    ${renderSpecialObjectives(data, viewModel.map)}
  `;
}

export function renderRivalOutcome(data: ResultsData): string {
  const rival = data.rivalResult;
  if (!rival) {
    return "";
  }
  const title = rival.lastOutcome === "defeated" ? "Rival Defeated" : "Rival Outcome";
  return `
    <section class="result-block wide rival-outcome" data-testid="results-rival-outcome">
      <h2>${title}</h2>
      <div class="results-grid compact">
        <span>Rival encountered</span><strong>${escapeHtml(rival.name)}, ${escapeHtml(rival.title)}</strong>
        <span>Outcome</span><strong>${escapeHtml(rival.outcomeLabel)}</strong>
        <span>Disposition</span><strong>${escapeHtml(rival.dispositionLabel)}</strong>
        <span>Record</span><strong>${rival.encounters} encounters, ${rival.defeats} defeats, ${rival.victoriesAgainstPlayer} rival victories</strong>
        <span>Consequence</span><strong>${escapeHtml(rival.consequenceText)}</strong>
        ${
          rival.rewardText
            ? `<span>One-time first-defeat reward</span><strong>${escapeHtml(rival.rewardText)}</strong>`
            : rival.duplicateFirstDefeatRewardPrevented
              ? `<span>One-time first-defeat reward</span><strong>Already claimed for this campaign</strong>`
              : ""
        }
        ${
          rival.trophyEarned
            ? `<span>Trophy earned</span><strong>${escapeHtml(rival.trophyEarned.label)}</strong>
               <span>Trophy note</span><strong>${escapeHtml(rival.trophyEarned.description)}</strong>`
            : ""
        }
      </div>
      <p class="quiet">Rival state persists on the campaign save. V1 rematch modifiers are small: escaped rivals gain +5% HP, and triumphant rivals gain +5% damage.</p>
    </section>
  `;
}

export function renderVeteranSummary(data: ResultsData): string {
  const summary = data.stats.veteranSummary;
  if (data.stats.outcome !== "victory" || !summary || (!summary.topSurvivor && summary.rankedUpUnits.length === 0)) {
    return "";
  }

  const rankedUp = summary.rankedUpUnits.slice(0, 4);
  const notable = summary.notableVeterans.slice(0, 6);
  const top = summary.topSurvivor;
  const eligibleCount = summary.notableVeterans.filter(isRetinueEligibleVeteran).length;
  return `
    <section class="result-block wide veteran-summary">
      <h2>Notable Veterans</h2>
      <div class="results-grid compact">
        ${
          top
            ? `
              <span>Top survivor</span><strong>${escapeHtml(top.unitName)} - ${escapeHtml(top.rankName)} (${top.xp} XP)</strong>
              <span>Top survivor kills</span><strong>${top.kills}</strong>
            `
            : ""
        }
        ${
          rankedUp.length > 0
            ? rankedUp
                .map(
                  (entry) => `
                    <span>Rank-up</span><strong>${escapeHtml(entry.unitName)} - ${escapeHtml(
                      entry.previousRank ? titleCase(entry.previousRank) : "Recruit"
                    )} to ${escapeHtml(entry.rankName)}</strong>
                    <span>${escapeHtml(entry.unitName)} record</span><strong>${entry.kills} kills, ${entry.damageDealt} damage</strong>
                  `
                )
                .join("")
            : `<span>Rank-ups this battle</span><strong>None</strong>`
        }
        <span>Retinue candidates</span><strong>${eligibleCount}</strong>
      </div>
      ${
        notable.length > 0
          ? `<div class="reward-list veteran-list">
              ${notable
                .map(
                  (entry) => `
                    <article class="reward-card veteran-card">
                      <div>
                        <strong>${escapeHtml(entry.unitName)} - ${escapeHtml(entry.rankName)}</strong>
                        <p>${escapeHtml(formatUnitVeterancyXpProgress(entry.xp))} - ${entry.kills} kills - ${entry.damageDealt} damage</p>
                        <small>Rank bonus: ${escapeHtml(formatUnitVeterancyBonusSummary(entry.rank))}</small>
                        <small>${escapeHtml(retinueEligibilityReason(entry))}</small>
                      </div>
                    </article>
                  `
                )
                .join("")}
            </div>`
          : ""
      }
      <p class="quiet">Campaign victories can add selected surviving Seasoned or better units to the Retinue Camp. Retinue death is permanent in V1.</p>
    </section>
  `;
}

export function renderSpecialObjectives(data: ResultsData, map?: BattleMapDefinition): string {
  const objectives = map?.scenario.objectives.secondaryObjectives ?? [];
  if (objectives.length === 0) {
    return "";
  }
  const completed = new Set(data.stats.completedObjectiveIds ?? []);
  return `
    <section class="result-block wide special-objectives">
      <h2>Special Objectives</h2>
      <div class="results-grid compact">
        ${objectives
          .map(
            (objective) => `
              <span>${escapeHtml(objective.name)}</span>
              <strong>${completed.has(objective.id) ? "Completed" : "Incomplete"}</strong>
            `
          )
          .join("")}
      </div>
    </section>
  `;
}

function renderXpProgress(data: ResultsData, viewModel: ResultsViewModel): string {
  const { before, after, beforeHero, afterHero, levelsGained, skillPointsGained } = viewModel.xp;
  const isDefeat = data.stats.outcome === "defeat";
  return `
    <div class="results-grid compact">
      <span>${isDefeat ? "XP saved" : "XP gained"}</span><strong>${isDefeat ? 0 : data.stats.xpGained}</strong>
      ${
        isDefeat && data.stats.xpGained > 0
          ? `<span>Battle XP earned</span><strong>${data.stats.xpGained} (not saved)</strong>`
          : ""
      }
      <span>Before</span><strong>Level ${beforeHero.level} - ${formatXpProgress(beforeHero.xp, beforeHero.level, before)}</strong>
      <span>After</span><strong>Level ${afterHero.level} - ${formatXpProgress(afterHero.xp, afterHero.level, after)}</strong>
      <span>Level-up</span><strong>${levelsGained > 0 ? `+${levelsGained} level${levelsGained === 1 ? "" : "s"}` : "No level-up"}</strong>
      <span>Skill points gained</span><strong>${skillPointsGained}</strong>
    </div>
    <div class="xp-compare-bars">
      <div><span>Before</span><i style="width: ${Math.round(before.percent)}%"></i></div>
      <div><span>After</span><i style="width: ${Math.round(after.percent)}%"></i></div>
    </div>
  `;
}
