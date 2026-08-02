import { describe, expect, it } from "vitest";
import { createSkirmishBattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { createFallbackHeroSave } from "../core/SaveSystem";
import { createHudMatchContext } from "../ui/hudPanels/HudTypes";

describe("BattleScene HUD match context", () => {
  it("transports the canonical opponent faction and selected difficulty", () => {
    const request = createSkirmishBattleLaunchRequest(createFallbackHeroSave(), {
      enemyProfileId: "ashen_covenant",
      difficulty: "easy"
    });

    expect(createHudMatchContext(request)).toEqual({
      opponentFactionName: "Ashen Covenant",
      difficultyLabel: "Easy",
      speedLabel: "1×"
    });
  });

  it("uses the selected difficulty label instead of a hardcoded value", () => {
    const hero = createFallbackHeroSave();
    const easy = createHudMatchContext(
      createSkirmishBattleLaunchRequest(hero, { enemyProfileId: "ashen_covenant", difficulty: "easy" })
    );
    const hard = createHudMatchContext(
      createSkirmishBattleLaunchRequest(hero, { enemyProfileId: "ashen_covenant", difficulty: "hard" })
    );

    expect(easy?.difficultyLabel).toBe("Easy");
    expect(hard?.difficultyLabel).toBe("Hard");
  });

  it("fails closed when a special launch has no canonical opponent metadata", () => {
    const request = createSkirmishBattleLaunchRequest(createFallbackHeroSave(), { difficulty: "easy" });
    expect(createHudMatchContext(request)).toBeUndefined();
  });
});
