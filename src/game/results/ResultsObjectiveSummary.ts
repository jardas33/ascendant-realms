import type { BattleMapDefinition } from "../core/GameTypes";
import { getActiveHeroBuildSynergy } from "../core/HeroProgressionRules";
import { formatTime } from "../core/MathUtils";
import { formatRelicBuildArchetype } from "../core/RelicRewardRules";
import { formatRetinueDeploymentLabel, isRetinueEligibleVeteran, retinueEligibilityReason } from "../core/RetinueRules";
import { formatUnitVeterancyBonusSummary, formatUnitVeterancyXpProgress } from "../data/unitVeterancy";
import { escapeHtml, formatDuplicateConversions, formatTags, formatXpProgress, formatStatMods, titleCase } from "./ResultsFormatting";
import { ITEM_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
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
    ${renderRetinueBattleSummary(data)}
    ${renderRivalOutcome(data)}
    ${renderRelicReward(data)}
    ${renderSpecialObjectives(data, viewModel.map)}
  `;
}

export function renderRetinueBattleSummary(data: ResultsData): string {
  const deployed = data.launchRequest?.mode === "campaign_node" ? data.launchRequest.retinueUnits ?? [] : [];
  if (deployed.length === 0) {
    return "";
  }
  const lostIds = new Set(data.stats.retinueUnitIdsLost ?? []);
  const lost = deployed.filter((unit) => lostIds.has(unit.retinueUnitId));
  const survived = deployed.filter((unit) => !lostIds.has(unit.retinueUnitId));
  return `
    <section class="result-block wide retinue-battle-summary" data-testid="results-retinue-battle-summary">
      <h2>Retinue Deployed</h2>
      <div class="results-grid compact">
        <span>Deployed count</span><strong>${deployed.length} ${deployed.length === 1 ? "unit" : "units"}</strong>
        <span>Deployed</span><strong>${escapeHtml(deployed.map(formatRetinueDeploymentLabel).join(", "))}</strong>
        <span>Survived</span><strong>${survived.length > 0 ? escapeHtml(survived.map(formatRetinueDeploymentLabel).join(", ")) : "None"}</strong>
        <span>Lost</span><strong>${lost.length > 0 ? escapeHtml(lost.map(formatRetinueDeploymentLabel).join(", ")) : "None"}</strong>
      </div>
      <p class="quiet">Surviving deployed Retinue units update their campaign record. Lost Retinue units are removed from the roster after battle.</p>
    </section>
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
        ${
          rival.relicRewardText
            ? `<span>Relic reward</span><strong>${escapeHtml(rival.relicRewardText)}</strong>`
            : ""
        }
      </div>
      <p class="quiet">Rival state persists on the campaign save. V1 rematch modifiers are small: escaped rivals gain +5% HP, and triumphant rivals gain +5% damage.</p>
    </section>
  `;
}

export function renderRelicReward(data: ResultsData): string {
  if (!data.relicReward && data.relicRewardChoice) {
    return renderRelicRewardChoice(data);
  }
  const reward = data.relicReward;
  if (!reward) {
    return "";
  }
  const { definition, item } = reward;
  const equipped = reward.itemInstance ? data.heroSave.equipment.relic === reward.itemInstance.instanceId : false;
  const inventoryStatus =
    reward.status === "granted"
      ? reward.inventoryLabel
      : `Duplicate handling: ${formatDuplicateConversions(reward.duplicateConversion ? [reward.duplicateConversion] : [])}`;
  return `
    <section class="result-block wide relic-reward" data-testid="results-relic-reward">
      <h2>Relic Reward</h2>
      <div class="results-grid compact">
        <span>Relic result</span><strong>${escapeHtml(definition.name)}</strong>
        <span>Source</span><strong>${escapeHtml(definition.sourceLabel)}</strong>
        <span>Build identity</span><strong>${escapeHtml(formatRelicBuildArchetype(definition))}</strong>
        <span>Inventory</span><strong>${escapeHtml(inventoryStatus)}</strong>
        <span>Equipped effect</span><strong>${escapeHtml(definition.effectSummary)}</strong>
        <span>Build support</span><strong>${escapeHtml(definition.buildSummary)}</strong>
        <span>Stat summary</span><strong>${escapeHtml(formatStatMods(item.statMods))}</strong>
        <span>Final equipped relic</span><strong>${equipped ? escapeHtml(item.name) : "No relic equipped from this reward yet"}</strong>
      </div>
      <p class="quiet">Relic effects are active when equipped.</p>
      ${
        reward.itemInstance
          ? `<div class="reward-actions relic-actions">
              <button data-results-action="equip" data-item-id="${escapeHtml(reward.itemInstance.instanceId)}" ${
                equipped ? "disabled" : ""
              }>${equipped ? "Relic Equipped" : "Equip Relic"}</button>
            </div>`
          : ""
      }
    </section>
  `;
}

export function renderRelicRewardChoice(data: ResultsData): string {
  const choice = data.relicRewardChoice;
  if (!choice) {
    return "";
  }
  return `
    <section class="result-block wide relic-reward" data-testid="results-relic-choice">
      <h2>Relic Reward Choice</h2>
      <div class="results-grid compact">
        <span>Source</span><strong>${escapeHtml(choice.sourceLabel)}</strong>
        <span>Choice rule</span><strong>${escapeHtml(choice.choiceLabel)}</strong>
      </div>
      <div class="reward-list relic-choice-list">
        ${choice.options
          .map(
            (option) => `
              <article class="reward-card relic-choice-card ${option.sourceMatched ? "new" : ""}" data-testid="results-relic-choice-option">
                <div>
                  <strong>${escapeHtml(option.definition.name)} <span class="rarity-pill rarity-${escapeHtml(option.definition.rarity)}">${titleCase(option.definition.rarity)}</span></strong>
                  <p>${escapeHtml(option.definition.choiceCopy)}</p>
                  <small>${option.sourceMatched ? "Source champion choice" : "Alternate build choice"} - ${escapeHtml(formatRelicBuildArchetype(option.definition))}</small>
                  <small>${escapeHtml(option.definition.effectSummary)}</small>
                  <small>${escapeHtml(formatStatMods(option.item.statMods))}</small>
                  <small>${escapeHtml(option.definition.buildSummary)}</small>
                  <small>${escapeHtml(formatTags(option.definition.tags))}</small>
                  <small>${option.owned ? "Owned already" : "Available for inventory"}</small>
                </div>
                <button data-results-action="choose_relic" data-relic-id="${escapeHtml(option.definition.id)}" ${option.owned ? "disabled" : ""}>
                  ${option.owned ? "Already Owned" : choice.options.length === 1 ? "Claim Relic" : "Choose Relic"}
                </button>
              </article>
            `
          )
          .join("")}
      </div>
      <p class="quiet">Relic effects are active when equipped. Choosing a relic adds it to hero inventory; Equip Relic applies its build effects.</p>
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
        <span>Veterancy scope</span><strong>Battle-only for normal trained units</strong>
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
      <p class="quiet">Battle XP is earned by live units here. Normal trained units stay battle-only unless you add an eligible survivor to the small Retinue Camp.</p>
    </section>
  `;
}

export function renderSpecialObjectives(data: ResultsData, map?: BattleMapDefinition): string {
  const objectives = map?.scenario.objectives.secondaryObjectives ?? [];
  if (objectives.length === 0) {
    return "";
  }
  const completed = new Set(data.stats.completedObjectiveIds ?? []);
  const campaignStates = new Map((data.campaignResult?.optionalObjectives ?? []).map((objective) => [objective.objectiveId, objective]));
  return `
    <section class="result-block wide special-objectives">
      <h2>Special Objectives</h2>
      <div class="results-grid compact">
        ${objectives
          .map(
            (objective) => `
              <span>${escapeHtml(objective.name)}</span>
              <strong>${escapeHtml(formatObjectiveResultStatus(objective.id, completed, campaignStates))}</strong>
            `
          )
          .join("")}
      </div>
    </section>
  `;
}

function formatObjectiveResultStatus(
  objectiveId: string,
  completed: Set<string>,
  campaignStates: Map<string, NonNullable<NonNullable<ResultsData["campaignResult"]>["optionalObjectives"]>[number]>
): string {
  const campaignState = campaignStates.get(objectiveId);
  if (campaignState?.newlyRecorded) {
    return "Completed - newly recorded";
  }
  if (completed.has(objectiveId) && campaignState?.persisted) {
    return "Completed - already recorded";
  }
  if (campaignState?.persisted) {
    return "Previously recorded";
  }
  return completed.has(objectiveId) ? "Completed" : "Incomplete";
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
      ${renderHeroBuildProgressionRows(data, viewModel)}
    </div>
    <div class="xp-compare-bars">
      <div><span>Before</span><i style="width: ${Math.round(before.percent)}%"></i></div>
      <div><span>After</span><i style="width: ${Math.round(after.percent)}%"></i></div>
    </div>
  `;
}

function renderHeroBuildProgressionRows(data: ResultsData, viewModel: ResultsViewModel): string {
  if (data.launchRequest?.mode === "tutorial") {
    return "";
  }
  const relicInstance = data.heroSave.equipment.relic
    ? data.heroSave.inventory.find((instance) => instance.instanceId === data.heroSave.equipment.relic)
    : undefined;
  const relicItem = relicInstance ? ITEM_BY_ID[relicInstance.itemId] : undefined;
  const synergy = getActiveHeroBuildSynergy(data.heroSave, SKILL_NODE_BY_ID, ITEM_BY_ID);
  const skillReminder =
    viewModel.skillPointsGained > 0 || data.heroSave.skillPoints > 0
      ? `<span>Skill point reminder</span><strong>Spend skill points in Hero Inventory</strong>`
      : "";
  return `
    <span>Equipped relic</span><strong>${escapeHtml(relicItem ? `${relicItem.name} - ${relicBuildLabel(relicItem.tags)}` : "None")}</strong>
    <span>Relic synergy</span><strong>${escapeHtml(synergy ? `${synergy.summary} ${synergy.abilitySummary}` : "No matching equipped relic and branch skill yet")}</strong>
    ${skillReminder}
  `;
}

function relicBuildLabel(tags: string[]): string {
  if (tags.includes("warrior")) {
    return "Warrior build";
  }
  if (tags.includes("seer")) {
    return "Seer build";
  }
  if (tags.includes("commander")) {
    return "Commander build";
  }
  return "Build relic";
}
