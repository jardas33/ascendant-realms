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
      firstAttackDelay: 180,
      enemyIncomeMultiplier: 0.9,
      commanderJoinDelay: 540
    });
  });
});
