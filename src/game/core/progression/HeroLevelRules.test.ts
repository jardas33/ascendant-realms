import { describe, expect, it } from "vitest";
import { heroLevelArmorBonus, heroLevelDamageBonus, heroLiveLevelStatGain } from "./HeroLevelRules";

describe("HeroLevelRules", () => {
  it("keeps live battle stat gains in sync with saved level stat bonuses", () => {
    expect(heroLevelDamageBonus(1)).toBe(0);
    expect(heroLevelDamageBonus(3)).toBe(4);
    expect(heroLevelArmorBonus(1)).toBe(0);
    expect(heroLevelArmorBonus(3)).toBe(1);

    expect(heroLiveLevelStatGain(1, 3)).toEqual({
      damage: 4,
      armor: 1
    });
  });
});
