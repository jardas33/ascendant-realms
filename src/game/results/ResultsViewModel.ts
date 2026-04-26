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
  const map = data.launchRequest ? MAP_BY_ID[data.launchRequest.mapId] : undefined;
  const difficulty = data.launchRequest ? getBattleDifficulty(data.launchRequest.difficulty) : undefined;
  const beforeHero = data.startingHeroSave ?? data.heroSave;
  const rewardItemCount =
    (data.reward?.itemIds.length ?? data.rewardItemIds?.length ?? 0) +
    (data.campaignResult?.nodeReward.itemIds.length ?? 0);
  const skillPointsGained =
    (data.rewardLevelUp?.skillPointsGained ?? 0) + (data.campaignResult?.nodeLevelUp.skillPointsGained ?? 0);
  return {
    isVictory,
    title: isVictory ? "Victory" : "Defeat",
    backgroundId: isVictory ? ASSET_IDS.ui.victoryScreenBackground : ASSET_IDS.ui.defeatScreenBackground,
    map,
    difficulty,
    subtitle: `${map?.name ?? "Unknown battlefield"} - ${difficulty?.name ?? "Unknown difficulty"} - ${formatTime(data.stats.timeSeconds)}`,
    rewardItemCount,
    skillPointsGained,
    guidance: getResultsGuidance({
      outcome: data.stats.outcome,
      mode: data.launchRequest?.mode,
      completedNodeId: data.campaignResult?.completedNodeId,
      completedNodeName: data.campaignResult?.completedNodeName,
      unlockedNodeNames: data.campaignResult?.unlockedNodeNames,
      rewardItemCount,
      skillPointsGained
    }),
    xp: {
      before: xpProgressForLevel(beforeHero.xp, beforeHero.level, LEVEL_XP_THRESHOLDS),
      after: xpProgressForLevel(data.heroSave.xp, data.heroSave.level, LEVEL_XP_THRESHOLDS),
      beforeHero,
      afterHero: data.heroSave,
      levelsGained: Math.max(0, data.heroSave.level - beforeHero.level),
      skillPointsGained
    }
  };
}

export function initialResultsStatus(data: ResultsData): string {
  if (data.stats.outcome === "defeat") {
    return "No victory rewards were granted. Retry when ready, or return and adjust your plan.";
  }
  const rewardCount = (data.reward?.itemIds.length ?? data.rewardItemIds?.length ?? 0) + (data.campaignResult?.nodeReward.itemIds.length ?? 0);
  const skillPointsGained = (data.rewardLevelUp?.skillPointsGained ?? 0) + (data.campaignResult?.nodeLevelUp.skillPointsGained ?? 0);
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
