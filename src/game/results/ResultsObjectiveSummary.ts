import type { BattleMapDefinition } from "../core/GameTypes";
import { formatTime } from "../core/MathUtils";
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
        </div>
      </section>
      <section class="result-block">
        <h2>Hero XP</h2>
        ${renderXpProgress(data, viewModel)}
      </section>
    </div>
    ${renderSpecialObjectives(data, viewModel.map)}
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
  return `
    <div class="results-grid compact">
      <span>XP gained</span><strong>${data.stats.xpGained}</strong>
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
