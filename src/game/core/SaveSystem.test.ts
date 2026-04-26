import { describe, expect, it } from "vitest";
import { LEVEL_XP_THRESHOLDS } from "./Constants";
import { calculateLevelFromXp, xpProgressForLevel } from "./Progression";
import { createFallbackHeroSave, isHeroSaveData, normalizeHeroSaveData } from "./SaveSystem";

describe("calculateLevelFromXp", () => {
  it("keeps a fresh hero at level 1", () => {
    expect(calculateLevelFromXp(0, LEVEL_XP_THRESHOLDS)).toBe(1);
  });

  it("returns the highest earned level", () => {
    expect(calculateLevelFromXp(250, LEVEL_XP_THRESHOLDS)).toBe(3);
    expect(calculateLevelFromXp(699, LEVEL_XP_THRESHOLDS)).toBe(4);
    expect(calculateLevelFromXp(700, LEVEL_XP_THRESHOLDS)).toBe(5);
  });

  it("calculates XP bar progress from the shared level curve", () => {
    expect(xpProgressForLevel(50, 1, LEVEL_XP_THRESHOLDS).percent).toBe(50);
    expect(xpProgressForLevel(175, 2, LEVEL_XP_THRESHOLDS).percent).toBe(50);
    expect(xpProgressForLevel(999, 5, LEVEL_XP_THRESHOLDS).percent).toBe(100);
  });

  it("rejects malformed hero saves before loading", () => {
    expect(isHeroSaveData(createFallbackHeroSave())).toBe(true);
    expect(isHeroSaveData({ heroName: "Broken" })).toBe(false);
    expect(isHeroSaveData({ ...createFallbackHeroSave(), level: "2" })).toBe(false);
  });

  it("migrates older item saves into the inventory field", () => {
    const migrated = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      inventory: undefined,
      items: ["founders_promise"]
    });

    expect(migrated?.inventory).toEqual(["founders_promise"]);
    expect(migrated?.equipment).toEqual({});
    expect(migrated?.allocatedSkills).toEqual({});
  });

  it("normalizes numeric progression fields into safe ranges", () => {
    const normalized = normalizeHeroSaveData({
      ...createFallbackHeroSave(),
      level: -5,
      xp: -10,
      skillPoints: -3,
      completedBattles: -1,
      allocatedSkills: {
        combat_drill: 1.9
      },
      stats: {
        might: -2,
        command: 8,
        arcana: 2,
        faith: 3
      }
    });

    expect(normalized?.level).toBe(1);
    expect(normalized?.xp).toBe(0);
    expect(normalized?.skillPoints).toBe(0);
    expect(normalized?.completedBattles).toBe(0);
    expect(normalized?.allocatedSkills.combat_drill).toBe(1);
    expect(normalized?.stats.might).toBe(0);
  });
});
