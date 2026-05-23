import { describe, expect, it } from "vitest";
import type { EnemyAIConfig } from "../core/GameTypes";
import { applyTutorialEnemyAIPacing, BATTLE_DIFFICULTIES, getBattleDifficulty, getBattlePhase } from "./battlePacing";

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

  it("applies story-paced enemy escalation only through the tutorial pacing helper", () => {
    const config: EnemyAIConfig = {
      incomeInterval: 5,
      incomePerTick: { crowns: 90, stone: 45, iron: 45, aether: 35 },
      trainInterval: 5.6,
      expandInterval: 21,
      initialExpandDelay: 18,
      attackInterval: 68,
      initialAttackDelay: 210,
      minAttackArmySize: 3,
      attackWaveSize: 6,
      expandSquadSize: 2,
      defenseSquadSize: 6,
      defendRadius: 400,
      baseBuildingId: "enemy_stronghold",
      productionBuildingId: "enemy_barracks",
      attackTargetBuildingId: "command_hall",
      unitPlan: ["raider", "raider", "hexer", "raider", "brute"]
    };

    const paced = applyTutorialEnemyAIPacing(config);

    expect(paced).toMatchObject({
      trainInterval: 9,
      expandInterval: 30,
      initialExpandDelay: 30,
      attackInterval: 100,
      initialAttackDelay: 300,
      minAttackArmySize: 2,
      attackWaveSize: 2,
      expandSquadSize: 1,
      defenseSquadSize: 6,
      unitPlan: config.unitPlan
    });
    expect(config.trainInterval).toBe(5.6);
    expect(config.initialAttackDelay).toBe(210);
  });
});
