import { describe, expect, it, vi } from "vitest";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { AI_PERSONALITIES, DEFAULT_AI_PERSONALITY_ID } from "../data/aiPersonalities";
import { BATTLE_DIFFICULTIES, DEFAULT_BATTLE_DIFFICULTY } from "../data/battlePacing";
import { DEFAULT_MAP_ID, MAPS } from "../data/maps";
import { createSkirmishSetupSummary } from "./SkirmishSetupScene";

vi.mock("phaser", () => ({
  default: {
    Scene: class MockScene {}
  }
}));

const sceneSource = readFileSync(fileURLToPath(new URL("./SkirmishSetupScene.ts", import.meta.url)), "utf8");
const stylesSource = readFileSync(fileURLToPath(new URL("../styles/ui.css", import.meta.url)), "utf8");

describe("SkirmishSetupScene existing-options contract", () => {
  it("summarizes the canonical default without exposing internal ids", () => {
    const summary = createSkirmishSetupSummary({
      enemyFactionId: "ashen_covenant",
      mapId: DEFAULT_MAP_ID,
      difficultyId: DEFAULT_BATTLE_DIFFICULTY,
      aiPersonalityId: DEFAULT_AI_PERSONALITY_ID
    });

    expect(summary).toEqual({
      enemyName: "Ashen Covenant",
      mapName: MAPS.find((map) => map.id === DEFAULT_MAP_ID)?.name,
      difficultyName: BATTLE_DIFFICULTIES.find((difficulty) => difficulty.id === DEFAULT_BATTLE_DIFFICULTY)?.name,
      personalityName: AI_PERSONALITIES.find((personality) => personality.id === DEFAULT_AI_PERSONALITY_ID)?.name
    });
    expect(Object.values(summary).join(" ")).not.toContain("ashen_covenant");
  });

  it("updates battlefield, difficulty, and personality independently", () => {
    const summary = createSkirmishSetupSummary({
      enemyFactionId: "ashen_covenant",
      mapId: "broken_ford",
      difficultyId: "easy",
      aiPersonalityId: "raider_rush"
    });

    expect(summary.mapName).toBe("Broken Ford");
    expect(summary.difficultyName).toBe("Easy");
    expect(summary.personalityName).toBe("Raider Rush");
    expect(summary.enemyName).toBe("Ashen Covenant");
  });

  it("fails closed without leaking unknown catalog ids", () => {
    const summary = createSkirmishSetupSummary({
      enemyFactionId: "missing_enemy_id",
      mapId: "missing_map_id",
      difficultyId: "missing_difficulty_id" as never,
      aiPersonalityId: "missing_personality_id" as never
    });

    expect(summary).toEqual({
      enemyName: "Unknown enemy faction",
      mapName: "Unknown battlefield",
      difficultyName: "Unknown difficulty",
      personalityName: "Unknown AI personality"
    });
    expect(Object.values(summary).join(" ")).not.toMatch(/missing_|_id/);
  });

  it("keeps the launch callback and payload contract untouched", () => {
    expect(sceneSource).toContain("this.scene.start(SCENE_KEYS.battle");
    expect(sceneSource).toContain("createSkirmishBattleLaunchRequest(this.heroSave");
    expect(sceneSource).toContain('sourceId: "skirmish_setup"');
    expect(sceneSource).toMatch(/mapId:\s*this\.selectedMapId[\s\S]*difficulty:\s*this\.selectedDifficulty[\s\S]*enemyProfileId:\s*this\.selectedEnemyFactionId[\s\S]*aiPersonalityId:\s*this\.selectedAiPersonalityId/);
  });

  it("does not fabricate unavailable Batch 20 controls", () => {
    expect(sceneSource).not.toMatch(/opponentCount|startingResources|victoryCondition|gameSpeed/);
    expect(sceneSource).not.toContain("Rootbound Concord");
    expect(stylesSource).toContain(".setup-shell .setup-grid");
    expect(stylesSource).toContain("overflow-y: auto");
    expect(stylesSource).toContain(".setup-actions");
  });
});
