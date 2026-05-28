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
    inventory: [],
    equipment: {},
    allocatedSkills: {},
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
    expect(html).toContain("Relic: Empty");
  });

  it("renders the equipped relic summary", () => {
    const html = renderHeroHudPanel(
      createHero({
        inventory: [
          {
            instanceId: "test:outpost_command_signet:1",
            itemId: "outpost_command_signet",
            acquiredAt: "2026-05-27T21:30:00.000Z",
            source: "test",
            affixes: []
          }
        ],
        equipment: {
          relic: "test:outpost_command_signet:1"
        }
      })
    );

    expect(html).toContain("Relic: Outpost Command Signet active - Commander build");
  });

  it("renders active relic-build synergy and effective ability copy", () => {
    const relic = {
      instanceId: "test:cinderseer_focus:1",
      itemId: "cinderseer_focus",
      acquiredAt: "2026-05-28T12:00:00.000Z",
      source: "test",
      affixes: []
    };
    const hero = createHero({
      mana: 22,
      inventory: [relic],
      equipment: { relic: relic.instanceId },
      allocatedSkills: { magic_focus: 1, magic_warding: 1 }
    });

    const panelHtml = renderHeroHudPanel(hero);
    const abilityHtml = renderAbilities([ABILITY_BY_ID.rally_banner], hero);

    expect(panelHtml).toContain("Seer synergy active");
    expect(abilityHtml).toContain("Cost: 19 Mana");
    expect(abilityHtml).toContain("Cooldown: 17.5s");
    expect(abilityHtml).toContain("Seer synergy");
  });

  it("renders ability availability and disabled states", () => {
    const html = renderAbilities([ABILITY_BY_ID.rally_banner], createHero({ abilityCooldowns: { rally_banner: 5 } }));

    expect(html).toContain('data-action="ability"');
    expect(html).toContain('data-ability-state="cooldown"');
    expect(html).toContain("Cooldown 5s");
    expect(html).toContain("disabled");
  });
});
