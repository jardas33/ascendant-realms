import { LEVEL_XP_THRESHOLDS } from "../Constants";
import type { RewardLevelUpSummary } from "../GameTypes";
import { calculateLevelFromXp } from "../Progression";
import type { HeroSaveData } from "../../save/SaveTypes";

export interface RewardLevelProgress {
  previousLevel: number;
  nextXp: number;
  newLevel: number;
  levelsGained: number;
  levelUp: RewardLevelUpSummary;
}

export function calculateRewardLevelProgress(save: HeroSaveData, rewardXp: number): RewardLevelProgress {
  const previousLevel = save.level;
  const nextXp = Math.max(0, save.xp + Math.max(0, rewardXp));
  const newLevel = Math.max(previousLevel, calculateLevelFromXp(nextXp, LEVEL_XP_THRESHOLDS));
  const levelsGained = Math.max(0, newLevel - previousLevel);

  return {
    previousLevel,
    nextXp,
    newLevel,
    levelsGained,
    levelUp: {
      previousLevel,
      newLevel,
      levelsGained,
      skillPointsGained: levelsGained
    }
  };
}
