import { describe, expect, it, vi } from "vitest";
import { HERO_CAPTURE_SITE_XP, HERO_XP_SHARE_RADIUS } from "../core/Constants";
import type { Team } from "../core/GameTypes";
import { Building } from "../entities/Building";
import { CaptureSite } from "../entities/CaptureSite";
import type { Hero } from "../entities/Hero";
import { Unit } from "../entities/Unit";
import { XPSystem } from "./XPSystem";

function createHeroStub(): Hero {
  return {
    id: "hero-player",
    team: "player",
    position: { x: 100, y: 100 },
    xp: 0,
    addXp(this: { xp: number }, amount: number) {
      this.xp += amount;
      return { leveledUp: this.xp >= 100, levelsGained: this.xp >= 100 ? 1 : 0 };
    }
  } as unknown as Hero;
}

function createUnitTarget(options: { team?: Team; xpValue?: number; x?: number; y?: number } = {}): Unit {
  const unit = {
    id: `${options.team ?? "enemy"}-unit`,
    team: options.team ?? "enemy",
    position: { x: options.x ?? 140, y: options.y ?? 100 },
    definition: { xpValue: options.xpValue ?? 15 }
  };
  Object.setPrototypeOf(unit, Unit.prototype);
  return unit as unknown as Unit;
}

function createBuildingTarget(xpValue = 80): Building {
  const building = {
    id: "enemy-building",
    team: "enemy",
    position: { x: 150, y: 100 },
    definition: { xpValue }
  };
  Object.setPrototypeOf(building, Building.prototype);
  return building as unknown as Building;
}

function createSite(id = "crown_shrine", owner: Team = "player"): CaptureSite {
  const site = {
    id,
    alive: true,
    owner,
    team: owner,
    definition: { id, name: id },
    position: { x: 120, y: 100 }
  };
  Object.setPrototypeOf(site, CaptureSite.prototype);
  return site as unknown as CaptureSite;
}

describe("XPSystem", () => {
  it("awards enemy kill XP when the hero participates or is close enough", () => {
    const hero = createHeroStub();
    const onXp = vi.fn();
    const system = new XPSystem(hero, onXp);

    system.awardForKill(createUnitTarget({ team: "player" }), createUnitTarget({ xpValue: 20 }));
    system.awardForKill(createBuildingTarget(), createBuildingTarget(80));

    expect(hero.xp).toBe(100);
    expect(onXp).toHaveBeenCalledWith(20, false);
    expect(onXp).toHaveBeenCalledWith(80, true);
  });

  it("does not award XP for player targets or distant shared kills", () => {
    const hero = createHeroStub();
    const onXp = vi.fn();
    const system = new XPSystem(hero, onXp);

    system.awardForKill(createUnitTarget({ team: "player" }), createUnitTarget({ team: "player", xpValue: 50 }));
    system.awardForKill(
      createUnitTarget({ team: "player", x: hero.position.x + HERO_XP_SHARE_RADIUS + 50 }),
      createUnitTarget({ xpValue: 50, x: hero.position.x + HERO_XP_SHARE_RADIUS + 60 })
    );

    expect(hero.xp).toBe(0);
    expect(onXp).not.toHaveBeenCalled();
  });

  it("awards first player capture XP once per site", () => {
    const hero = createHeroStub();
    const onXp = vi.fn();
    const system = new XPSystem(hero, onXp);
    const site = createSite();

    system.awardForCaptureSite(site);
    system.awardForCaptureSite(site);
    system.awardForCaptureSite(createSite("enemy_mine", "enemy"));

    expect(hero.xp).toBe(HERO_CAPTURE_SITE_XP);
    expect(onXp).toHaveBeenCalledTimes(1);
    expect(onXp).toHaveBeenCalledWith(HERO_CAPTURE_SITE_XP, false);
  });
});
