import { describe, expect, it, vi } from "vitest";
import { Hero } from "./Hero";

describe("Hero live battle progression", () => {
  it("levels up during battle with HP, mana, damage, armor, and skill point gains", () => {
    const hero = {
      level: 1,
      xp: 240,
      skillPoints: 0,
      maxHp: 260,
      hp: 90,
      maxMana: 60,
      mana: 5,
      definition: {
        stats: {
          damage: 18
        }
      },
      damageBuffMultiplier: 1,
      upgradeDamageMultiplier: 1,
      veterancyDamageMultiplier: 1,
      armor: 4,
      updateHealthBar: vi.fn()
    } as unknown as Hero;
    Object.setPrototypeOf(hero, Hero.prototype);

    const result = Hero.prototype.addXp.call(hero, 10);

    expect(result).toEqual({ leveledUp: true, levelsGained: 2 });
    expect(hero.level).toBe(3);
    expect(hero.xp).toBe(250);
    expect(hero.skillPoints).toBe(2);
    expect(hero.maxHp).toBe(296);
    expect(hero.hp).toBe(296);
    expect(hero.maxMana).toBe(80);
    expect(hero.mana).toBe(80);
    expect(hero.damage).toBe(22);
    expect(hero.armor).toBe(5);
    expect(hero.updateHealthBar).toHaveBeenCalledOnce();
  });
});
