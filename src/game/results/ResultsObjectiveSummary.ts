import type { BattleMapDefinition } from "../core/GameTypes";
import { getActiveHeroBuildSynergy } from "../core/HeroProgressionRules";
import { formatTime } from "../core/MathUtils";
import { formatRelicBuildArchetype } from "../core/RelicRewardRules";
import { formatRetinueDeploymentLabel, isRetinueEligibleVeteran, retinueEligibilityReason } from "../core/RetinueRules";
import type { RetinueUnitSaveData } from "../save/SaveTypes";
import { formatUnitVeterancyBonusSummary, formatUnitVeterancyXpProgress } from "../data/unitVeterancy";
import { escapeHtml, formatDuplicateConversions, formatTags, formatXpProgress, formatStatMods, titleCase } from "./ResultsFormatting";
import { ENEMY_DOCTRINE_BY_ID, ENEMY_ELITE_SQUAD_BY_ID, ITEM_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { getTacticalPlan, tacticalPlanFromLaunchModifiers } from "../data/tacticalPlans";
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
          <span>Enemy doctrine</span><strong>${escapeHtml(formatEnemyDoctrineResult(data))}</strong>
          <span>Elite squads</span><strong>${escapeHtml(formatEliteSquadResult(data))}</strong>
          <span>Tactical plan</span><strong>${escapeHtml(formatTacticalPlanResult(data))}</strong>
        </div>
      </section>
      <section class="result-block">
        <h2>Hero XP</h2>
        ${renderXpProgress(data, viewModel)}
      </section>
    </div>
    ${renderVeteranSummary(data)}
    ${renderRetinueBattleSummary(data)}
    ${renderTacticalPlanSummary(data)}
    ${renderEnemyDoctrineSummary(data)}
    ${renderRivalOutcome(data)}
    ${renderRelicReward(data)}
    ${renderSpecialObjectives(data, viewModel.map)}
  `;
}

export function renderTacticalPlanSummary(data: ResultsData): string {
  const plan = data.launchRequest?.tacticalPlanId
    ? getTacticalPlan(data.launchRequest.tacticalPlanId)
    : tacticalPlanFromLaunchModifiers(data.launchRequest?.modifiers);
  if (!plan || data.launchRequest?.mode === "tutorial") {
    return "";
  }
  const doctrine = data.stats.enemyDoctrineId ? ENEMY_DOCTRINE_BY_ID[data.stats.enemyDoctrineId] : undefined;
  return `
    <section class="result-block wide tactical-plan-summary" data-testid="results-tactical-plan-summary">
      <h2>Tactical Plan</h2>
      <div class="results-grid compact">
        <span>Selected plan</span><strong>${escapeHtml(plan.name)}</strong>
        <span>Plan effect</span><strong>${escapeHtml(plan.effectSummary)}</strong>
        <span>After-action note</span><strong>${escapeHtml(plan.afterActionSummary)}</strong>
        <span>Doctrine response</span><strong>${escapeHtml(doctrine ? doctrine.counterplay : plan.recommendedCounterplay)}</strong>
      </div>
      <p class="quiet">Tactical plans are launch-local. They do not add save fields or stack across battles.</p>
    </section>
  `;
}

export function renderEnemyDoctrineSummary(data: ResultsData): string {
  const doctrine = data.stats.enemyDoctrineId ? ENEMY_DOCTRINE_BY_ID[data.stats.enemyDoctrineId] : undefined;
  const eliteIds = data.stats.enemyEliteSquadIds ?? [];
  const defeatedIds = data.stats.enemyEliteUnitsDefeated ?? [];
  if (!doctrine && eliteIds.length === 0) {
    return "";
  }
  const defeatedNames = defeatedIds.map((id) => ENEMY_ELITE_SQUAD_BY_ID[id]?.name ?? id);
  return `
    <section class="result-block wide enemy-doctrine-summary" data-testid="results-enemy-doctrine-summary">
      <h2>Enemy Tactics</h2>
      <div class="results-grid compact">
        <span>Doctrine</span><strong>${escapeHtml(doctrine ? doctrine.name : "Standard pressure")}</strong>
        <span>Threat read</span><strong>${escapeHtml(doctrine?.threatWarning ?? "No special doctrine was active.")}</strong>
        <span>Counterplay</span><strong>${escapeHtml(doctrine?.counterplay ?? "Use normal economy, scouting, and army control.")}</strong>
        <span>Doctrine actions</span><strong>${escapeHtml(formatDoctrineActions(data.stats.enemyDoctrineTelemetryLabels ?? []))}</strong>
        <span>Elite present</span><strong>${escapeHtml(formatEliteSquadNames(eliteIds))}</strong>
        <span>Elite defeated</span><strong>${defeatedNames.length > 0 ? escapeHtml(defeatedNames.join(", ")) : "None"}</strong>
      </div>
      <p class="quiet">Enemy doctrine and elite tags are battle-only readability signals. They do not change campaign saves.</p>
    </section>
  `;
}

function formatEnemyDoctrineResult(data: ResultsData): string {
  const doctrine = data.stats.enemyDoctrineId ? ENEMY_DOCTRINE_BY_ID[data.stats.enemyDoctrineId] : undefined;
  return doctrine ? `${doctrine.name} - ${doctrine.counterplay}` : "Standard pressure";
}

function formatEliteSquadResult(data: ResultsData): string {
  const eliteIds = data.stats.enemyEliteSquadIds ?? [];
  const defeated = data.stats.enemyEliteUnitsDefeated?.length ?? 0;
  if (eliteIds.length === 0) {
    return "None";
  }
  return `${formatEliteSquadNames(eliteIds)}; defeated ${defeated}`;
}

function formatTacticalPlanResult(data: ResultsData): string {
  if (data.launchRequest?.mode === "tutorial") {
    return "Tutorial plan disabled";
  }
  const plan = data.launchRequest?.tacticalPlanId
    ? getTacticalPlan(data.launchRequest.tacticalPlanId)
    : tacticalPlanFromLaunchModifiers(data.launchRequest?.modifiers);
  return plan ? `${plan.name} - ${plan.effectSummary}` : "None";
}

function formatEliteSquadNames(ids: string[]): string {
  const names = ids
    .map((id) => ENEMY_ELITE_SQUAD_BY_ID[id]?.name ?? id)
    .filter((name, index, entries) => entries.indexOf(name) === index);
  return names.length > 0 ? names.join(", ") : "None";
}

function formatDoctrineActions(labels: string[]): string {
  if (labels.length === 0) {
    return "No special actions recorded";
  }
  return labels.slice(0, 4).join("; ");
}

export function renderRetinueBattleSummary(data: ResultsData): string {
  const participants = retinueResultParticipants(data);
  const lostIds = new Set(data.stats.retinueUnitIdsLost ?? []);
  const recoveryIds = new Set(data.stats.retinueUnitIdsRecovering ?? []);
  const returnedIds = new Set(data.stats.retinueUnitIdsReturnedReady ?? []);
  const lost = participants.filter((unit) => lostIds.has(unit.retinueUnitId));
  const survived = participants.filter((unit) => !lostIds.has(unit.retinueUnitId));
  const recovering = participants.filter((unit) => recoveryIds.has(unit.retinueUnitId));
  const returnedReady = retinueResultRoster(data).filter((unit) => returnedIds.has(unit.retinueUnitId));
  const reinforcement = data.stats.retinueReinforcementUnitId
    ? retinueResultRoster(data).find((unit) => unit.retinueUnitId === data.stats.retinueReinforcementUnitId)
    : undefined;
  if (participants.length === 0 && returnedReady.length === 0 && !data.stats.retinueReinforcementUsed) {
    return "";
  }
  return `
    <section class="result-block wide retinue-battle-summary" data-testid="results-retinue-battle-summary">
      <h2>Retinue Deployed</h2>
      <div class="results-grid compact">
        <span>Participated</span><strong>${participants.length} ${participants.length === 1 ? "unit" : "units"}</strong>
        <span>Battle Retinue</span><strong>${escapeHtml(participants.map(formatRetinueDeploymentLabel).join(", "))}</strong>
        <span>Reinforcement</span><strong>${reinforcement ? escapeHtml(formatRetinueDeploymentLabel(reinforcement)) : data.stats.retinueReinforcementUsed ? "Used" : "Not used"}</strong>
        <span>Survived</span><strong>${survived.length > 0 ? escapeHtml(survived.map(formatRetinueDeploymentLabel).join(", ")) : "None"}</strong>
        <span>Lost</span><strong>${lost.length > 0 ? escapeHtml(lost.map(formatRetinueDeploymentLabel).join(", ")) : "None"}</strong>
        <span>Entering recovery</span><strong>${recovering.length > 0 ? escapeHtml(recovering.map(formatRetinueDeploymentLabel).join(", ")) : "None"}</strong>
        <span>Returned Ready</span><strong>${returnedReady.length > 0 ? escapeHtml(returnedReady.map(formatRetinueDeploymentLabel).join(", ")) : "None"}</strong>
      </div>
      <p class="quiet">Low-HP Retinue survivors recover for one first-clear campaign progression step. Lost Retinue units are removed from the roster after battle.</p>
    </section>
  `;
}

function retinueResultRoster(data: ResultsData): RetinueUnitSaveData[] {
  if (data.launchRequest?.mode !== "campaign_node") {
    return [];
  }
  const seen = new Set<string>();
  return [...(data.launchRequest.retinueUnits ?? []), ...(data.launchRequest.retinueReserveUnits ?? [])].filter((unit) => {
    if (seen.has(unit.retinueUnitId)) {
      return false;
    }
    seen.add(unit.retinueUnitId);
    return true;
  });
}

function retinueResultParticipants(data: ResultsData): RetinueUnitSaveData[] {
  const participants = new Set(
    data.stats.retinueParticipatingUnitIds ??
      (data.launchRequest?.mode === "campaign_node" ? (data.launchRequest.retinueUnits ?? []).map((unit) => unit.retinueUnitId) : [])
  );
  return retinueResultRoster(data).filter((unit) => participants.has(unit.retinueUnitId));
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
