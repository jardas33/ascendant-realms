import { describe, expect, it } from "vitest";
import {
  applySecondaryObjectiveBattleEffect,
  type SecondaryObjectiveEffectBuilding
} from "./SecondaryObjectiveEffects";

function createBuilding(overrides: Partial<SecondaryObjectiveEffectBuilding> = {}): SecondaryObjectiveEffectBuilding {
  return {
    id: "building-1",
    team: "enemy",
    alive: true,
    hp: 350,
    maxHp: 350,
    position: { x: 2040, y: 570 },
    definition: { id: "watchtower", name: "Watchtower" },
    ...overrides
  };
}

describe("SecondaryObjectiveEffects", () => {
  it("weakens the Ashen gate Watchtower when the Burned Shrine is captured", () => {
    let healthBarUpdated = false;
    const watchtower = createBuilding({
      updateHealthBar: () => {
        healthBarUpdated = true;
      }
    });

    const result = applySecondaryObjectiveBattleEffect({
      mapId: "ashen_outpost",
      objectiveId: "capture_burned_shrine",
      buildings: [watchtower]
    });

    expect(result).toMatchObject({
      affectedBuildingId: "building-1",
      message: "Burned Shrine weakens the gate Watchtower.",
      damageApplied: 158
    });
    expect(watchtower.hp).toBe(192);
    expect(watchtower.alive).toBe(true);
    expect(healthBarUpdated).toBe(true);
  });

  it("leaves the effect inactive for other maps or objectives", () => {
    const watchtower = createBuilding();

    expect(
      applySecondaryObjectiveBattleEffect({
        mapId: "broken_ford",
        objectiveId: "capture_burned_shrine",
        buildings: [watchtower]
      })
    ).toBeUndefined();
    expect(
      applySecondaryObjectiveBattleEffect({
        mapId: "ashen_outpost",
        objectiveId: "destroy_enemy_barracks",
        buildings: [watchtower]
      })
    ).toBeUndefined();
    expect(watchtower.hp).toBe(350);
  });

  it("does not destroy the Watchtower outright if it was already damaged", () => {
    const watchtower = createBuilding({ hp: 25 });

    const result = applySecondaryObjectiveBattleEffect({
      mapId: "ashen_outpost",
      objectiveId: "capture_burned_shrine",
      buildings: [watchtower]
    });

    expect(result?.damageApplied).toBe(24);
    expect(watchtower.hp).toBe(1);
    expect(watchtower.alive).toBe(true);
  });
});
