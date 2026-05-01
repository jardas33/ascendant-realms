import { describe, expect, it } from "vitest";
import { BATTLE_DIFFICULTIES, getBattleDifficulty, getBattlePhase } from "./battlePacing";

describe("battle pacing data", () => {
  it("maps elapsed battle time into the intended first-skirmish phases", () => {
    expect(getBattlePhase(0).id).toBe("opening");
    expect(getBattlePhase(119.9).id).toBe("opening");
    expect(getBattlePhase(120).id).toBe("expansion");
    expect(getBattlePhase(300).id).toBe("pressure");
    expect(getBattlePhase(480).id).toBe("assault");
  });

  it("keeps all required difficulty presets available", () => {
    expect(BATTLE_DIFFICULTIES.map((difficulty) => difficulty.id)).toEqual(["story", "easy", "normal", "hard"]);
    expect(getBattleDifficulty("normal")).toMatchObject({
      firstAttackDelay: 195,
      enemyIncomeMultiplier: 0.82,
      commanderJoinDelay: 630
    });
    expect(getBattleDifficulty("story")).toMatchObject({
      firstAttackDelay: 300,
      fogOfWarEnabled: false
    });
    expect(getBattleDifficulty("easy").firstAttackDelay).toBeGreaterThan(getBattleDifficulty("normal").firstAttackDelay);
  });

  it("keeps difficulty pacing and fog settings ordered from forgiving to punishing", () => {
    const story = getBattleDifficulty("story");
    const easy = getBattleDifficulty("easy");
    const normal = getBattleDifficulty("normal");
    const hard = getBattleDifficulty("hard");

    expect(story.firstAttackDelay).toBeGreaterThan(easy.firstAttackDelay);
    expect(easy.firstAttackDelay).toBeGreaterThan(normal.firstAttackDelay);
    expect(normal.firstAttackDelay).toBeGreaterThan(hard.firstAttackDelay);

    expect(story.attackInterval).toBeGreaterThan(easy.attackInterval);
    expect(easy.attackInterval).toBeGreaterThan(normal.attackInterval);
    expect(normal.attackInterval).toBeGreaterThan(hard.attackInterval);

    expect(story.attackWaveSize).toBeLessThan(easy.attackWaveSize);
    expect(easy.attackWaveSize).toBeLessThan(normal.attackWaveSize);
    expect(normal.attackWaveSize).toBeLessThan(hard.attackWaveSize);

    expect(story.enemyIncomeMultiplier).toBeLessThan(easy.enemyIncomeMultiplier);
    expect(easy.enemyIncomeMultiplier).toBeLessThan(normal.enemyIncomeMultiplier);
    expect(normal.enemyIncomeMultiplier).toBeLessThan(hard.enemyIncomeMultiplier);

    expect(story.trainInterval).toBeGreaterThan(easy.trainInterval);
    expect(easy.trainInterval).toBeGreaterThan(normal.trainInterval);
    expect(normal.trainInterval).toBeGreaterThan(hard.trainInterval);

    expect(story.fogOfWarEnabled).toBe(false);
    expect(easy.fogOfWarEnabled).toBe(true);
    expect(normal.fogOfWarEnabled).toBe(true);
    expect(hard.fogOfWarEnabled).toBe(true);
  });
});
