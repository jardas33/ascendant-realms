import { describe, expect, it } from "vitest";
import { getBattleDifficulty, getBattlePhase } from "./battlePacing";
import {
  AI_PERSONALITIES,
  applyAIPersonalityToConfig,
  applyAIPersonalityToDifficulty,
  applyAIPersonalityToPhase,
  getAIPersonality
} from "./aiPersonalities";
import { MAPS } from "./maps";

const baseConfig = MAPS[0].scenario.enemyAI;

describe("AI personalities", () => {
  it("defines the first four strategic profiles", () => {
    expect(AI_PERSONALITIES.map((personality) => personality.id)).toEqual([
      "balanced_warlord",
      "raider_rush",
      "fortress_keeper",
      "hexfire_cult"
    ]);
  });

  it("changes timing and wave composition by selected personality", () => {
    const normal = getBattleDifficulty("normal");
    const raider = getAIPersonality("raider_rush");
    const fortress = getAIPersonality("fortress_keeper");
    const hexfire = getAIPersonality("hexfire_cult");

    expect(applyAIPersonalityToDifficulty(normal, raider).firstAttackDelay).toBeLessThan(normal.firstAttackDelay);
    expect(applyAIPersonalityToConfig(baseConfig, fortress).defendRadius).toBeGreaterThan(baseConfig.defendRadius);

    const pressure = getBattlePhase(360);
    expect(applyAIPersonalityToPhase(pressure, hexfire).enemy.preferredAttackUnitIds.slice(0, 2)).toEqual(["hexer", "hexer"]);
    expect(applyAIPersonalityToPhase(pressure, raider).enemy.maxAttackByUnitId?.brute).toBeUndefined();
  });
});
