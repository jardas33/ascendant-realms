import { ASSET_IDS } from "../assets/AssetKeys";
import { LEVEL_XP_THRESHOLDS } from "../core/Constants";
import { getResultsGuidance } from "../core/FirstExperienceGuidance";
import type { BattleDifficultyDefinition, BattleMapDefinition } from "../core/GameTypes";
import { formatTime } from "../core/MathUtils";
import { xpProgressForLevel } from "../core/Progression";
import { getBattleDifficulty } from "../data/battlePacing";
import { MAP_BY_ID } from "../data/contentIndex";
import type { HeroSaveData } from "../save/SaveTypes";
import type { ResultsData } from "./ResultsTypes";

export interface ResultsGuidanceViewModel {
  title: string;
  body: string;
  actions: string[];
}

export interface ResultsXpViewModel {
  before: ReturnType<typeof xpProgressForLevel>;
  after: ReturnType<typeof xpProgressForLevel>;
  beforeHero: HeroSaveData;
  afterHero: HeroSaveData;
  levelsGained: number;
  skillPointsGained: number;
}

export interface ResultsViewModel {
  isVictory: boolean;
  isPrivatePlaytestDemo: boolean;
  title: string;
  backgroundId: string;
  map?: BattleMapDefinition;
  difficulty?: BattleDifficultyDefinition;
  subtitle: string;
  rewardItemCount: number;
  skillPointsGained: number;
  guidance: ResultsGuidanceViewModel;
  xp: ResultsXpViewModel;
}

export function createResultsViewModel(data: ResultsData): ResultsViewModel {
  const isVictory = data.stats.outcome === "victory";
  const isPrivatePlaytestDemo = Boolean(data.launchRequest?.privatePlaytestDemoId);
  const map = data.launchRequest ? MAP_BY_ID[data.launchRequest.mapId] : undefined;
  const difficulty = data.launchRequest ? getBattleDifficulty(data.launchRequest.difficulty) : undefined;
  const beforeHero = data.startingHeroSave ?? data.heroSave;
  const afterHero = isVictory ? data.heroSave : beforeHero;
  const rewardItemCount =
    (data.reward?.itemIds.length ?? data.rewardItemIds?.length ?? 0) +
    (data.campaignResult?.nodeReward.itemIds.length ?? 0);
  const skillPointsGained = isVictory
    ? (data.rewardLevelUp?.skillPointsGained ?? 0) + (data.campaignResult?.nodeLevelUp.skillPointsGained ?? 0)
    : 0;
  return {
    isVictory,
    isPrivatePlaytestDemo,
    title: isPrivatePlaytestDemo ? "PRIVATE DEMO COMPLETE" : isVictory ? "Victory" : "Defeat",
    backgroundId: isVictory ? ASSET_IDS.ui.victoryScreenBackground : ASSET_IDS.ui.defeatScreenBackground,
    map,
    difficulty,
    subtitle: isPrivatePlaytestDemo
      ? "Lume Network test - rewards and campaign progress were not saved"
      : `${map?.name ?? "Unknown battlefield"} - ${difficulty?.name ?? "Unknown difficulty"} - ${formatTime(data.stats.timeSeconds)}`,
    rewardItemCount,
    skillPointsGained,
    guidance: getResultsGuidance({
      outcome: data.stats.outcome,
      mode: data.launchRequest?.mode,
      completedNodeId: data.campaignResult?.completedNodeId,
      completedNodeName: data.campaignResult?.completedNodeName,
      unlockedNodeNames: data.campaignResult?.unlockedNodeNames,
      wasReplay: data.campaignResult?.wasReplay,
      optionalObjectives: data.campaignResult?.optionalObjectives,
      rewardItemCount,
      skillPointsGained
    }),
    xp: {
      before: xpProgressForLevel(beforeHero.xp, beforeHero.level, LEVEL_XP_THRESHOLDS),
      after: xpProgressForLevel(afterHero.xp, afterHero.level, LEVEL_XP_THRESHOLDS),
      beforeHero,
      afterHero,
      levelsGained: isVictory ? Math.max(0, afterHero.level - beforeHero.level) : 0,
      skillPointsGained
    }
  };
}

export function initialResultsStatus(data: ResultsData): string {
  if (data.stats.outcome === "defeat") {
    if (data.launchRequest?.privatePlaytestDemoId) {
      return "Private playtest demo ended. Rewards, campaign progress, hero XP, Retinue, and reputation were not saved.";
    }
    if (data.launchRequest?.mode === "tutorial") {
      return "Tutorial attempt ended. This training run is no-save and no-reward, so no campaign progress, items, XP, or hero changes were saved.";
    }
    return "No victory rewards or battle XP were saved. Use Defeat Tips to rebuild economy, train a larger army, and retry when ready.";
  }
  if (data.launchRequest?.mode === "tutorial") {
    return "Tutorial run complete. This training path is no-save and no-reward, so campaign progress, items, XP, and hero changes were not saved.";
  }
  if (data.launchRequest?.privatePlaytestDemoId) {
    return "Private demo complete. Lume behavior was available for testing, but rewards, campaign progress, hero XP, Retinue, and reputation were not saved.";
  }
  if (data.relicRewardChoice) {
    const optionNames = data.relicRewardChoice.options.map((option) => option.item.name).join(" or ");
    const milestoneCopy = data.campaignResult?.completedNodeId === "ashen_outpost" ? " Spend skill points or replay optional objectives after the choice." : "";
    return `Relic choice available: choose ${optionNames}. Relic effects are active when equipped.${milestoneCopy}`;
  }
  if (data.relicReward?.status === "granted") {
    return `${data.relicReward.item.name} was added to inventory. Relic effects are active when equipped.`;
  }
  if (data.relicReward?.status === "duplicate_converted") {
    return `${data.relicReward.item.name} was already owned, so the duplicate relic converted to resources.`;
  }
  if (data.campaignResult?.wasReplay) {
    return `${data.campaignResult.completedNodeName} replay complete. Reduced repeat battle rewards were applied; campaign node rewards and one-time objective credit do not duplicate.`;
  }
  if (isRepeatBattleClear(data)) {
    return "Repeat clear complete. Reduced repeat rewards were applied; weighted item rolls and campaign node rewards do not duplicate.";
  }
  if (data.campaignResult?.completedNodeId === "cinderfen_crossing") {
    return "Cinderfen Crossing secured. First-clear battle rewards and Cinderfen Crossing node rewards were applied; Cinderfen Watch is now open.";
  }
  if (data.campaignResult?.completedNodeId === "cinderfen_watch") {
    return "Cinderfen Watch secured. First-clear battle rewards and node rewards were applied; resolve Cinderfen Aftermath to finish the current v0.3 route.";
  }
  if (data.campaignResult) {
    const unlockCopy =
      data.campaignResult.unlockedNodeNames.length > 0
        ? ` Next mission unlocked: ${data.campaignResult.unlockedNodeNames.join(", ")}.`
        : " Replay is available for completed battle nodes.";
    const skillCopy =
      (data.campaignResult.nodeLevelUp.skillPointsGained ?? 0) > 0 ? " Spend new skill points in Hero Inventory." : "";
    return `${data.campaignResult.completedNodeName} secured. First-clear battle rewards and campaign node rewards were applied.${unlockCopy}${skillCopy}`;
  }
  const rewardCount = data.reward?.itemIds.length ?? data.rewardItemIds?.length ?? 0;
  const skillPointsGained = data.rewardLevelUp?.skillPointsGained ?? 0;
  if (rewardCount > 0 && skillPointsGained > 0) {
    return "You received an item and gained a skill point. Equip the reward and open hero progression before the next node.";
  }
  if (skillPointsGained > 0) {
    return "You gained a skill point. Open hero progression to spend it before the next battle.";
  }
  return rewardCount > 0
    ? "You received an item. It was added to inventory; equip it now to improve your hero."
    : "Victory rewards were applied. No new equipment dropped this time.";
}

export function isRepeatBattleClear(data: ResultsData): boolean {
  const mapId = data.launchRequest?.mapId;
  return data.stats.outcome === "victory" && Boolean(mapId && data.startingHeroSave?.clearedMapIds.includes(mapId));
}
