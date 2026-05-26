import { describe, expect, it } from "vitest";
import { ABILITY_BY_ID } from "../../data/contentIndex";
import type { Hero } from "../../entities/Hero";
import { renderAbilities, renderHeroHudPanel } from "./HeroHudPanel";

function createHero(overrides: Partial<Hero> = {}): Hero {
  return {
    heroName: "Aster",
    classId: "warlord",
    level: 2,
    hp: 180,
    maxHp: 278,
    mana: 12,
    maxMana: 70,
    xp: 125,
    skillPoints: 1,
    damage: 20,
    armor: 4,
    unlockedAbilities: ["rally_banner"],
    abilityCooldowns: {},
    definition: {
      color: 0xe2b34b
    },
    ...overrides
  } as Hero;
}

describe("HeroHudPanel", () => {
  it("renders level, XP, stat, skill, and ability unlock summary", () => {
    const html = renderHeroHudPanel(createHero());

    expect(html).toContain("Aster L2");
    expect(html).toContain("XP 125 - Skill 1 - DMG 20 - ARM 4");
    expect(html).toContain("Abilities 1/3 unlocked");
  });

  it("renders ability availability and disabled states", () => {
    const html = renderAbilities([ABILITY_BY_ID.rally_banner], createHero({ abilityCooldowns: { rally_banner: 5 } }));

    expect(html).toContain('data-action="ability"');
    expect(html).toContain('data-ability-state="cooldown"');
    expect(html).toContain("Cooldown 5s");
    expect(html).toContain("disabled");
  });
});
