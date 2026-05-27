import type { BattleLaunchMode } from "../battle/BattleLaunchRequest";
import { RELIC_REWARD_BY_ENEMY_HERO_ID, type RelicRewardDefinition } from "../data/relicRewards";

export interface RelicRewardPreviewInput {
  outcome: "victory" | "defeat";
  mode?: BattleLaunchMode;
  rewardsDisabled?: boolean;
  enemyHeroId?: string;
  enemyHeroDefeated?: boolean;
}

export interface RelicRewardPreview {
  definition: RelicRewardDefinition;
  earnedLabel: string;
  persistenceLabel: string;
}

export const RELIC_REWARD_PREVIEW_PERSISTENCE_COPY =
  "Future persistence pending: this relic is shown for reward-readability testing only and is not added to inventory or saved.";

export function selectRelicRewardPreview(input: RelicRewardPreviewInput): RelicRewardPreview | undefined {
  if (
    input.outcome !== "victory" ||
    input.mode === "tutorial" ||
    input.rewardsDisabled ||
    !input.enemyHeroId ||
    !input.enemyHeroDefeated
  ) {
    return undefined;
  }
  const definition = RELIC_REWARD_BY_ENEMY_HERO_ID[input.enemyHeroId];
  if (!definition) {
    return undefined;
  }
  return {
    definition,
    earnedLabel: `${definition.name} previewed from ${definition.sourceLabel}.`,
    persistenceLabel: RELIC_REWARD_PREVIEW_PERSISTENCE_COPY
  };
}
