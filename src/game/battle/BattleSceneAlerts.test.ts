import { describe, expect, it, vi } from "vitest";
import type { BaseEntity } from "../entities/BaseEntity";
import type { Building } from "../entities/Building";
import type { CaptureSite } from "../entities/CaptureSite";
import type { Hero } from "../entities/Hero";
import { firstBattleTutorialHint } from "./BattleSceneAlerts";

vi.mock("phaser", () => ({
  default: {
    Math: {
      Distance: {
        Between: (x1: number, y1: number, x2: number, y2: number) => Math.hypot(x1 - x2, y1 - y2)
      }
    }
  }
}));

function fakeHero(): Hero {
  return {
    alive: true,
    position: { x: 0, y: 0 }
  } as unknown as Hero;
}

function fakeCommandHall(): Building {
  return {
    alive: true,
    team: "player",
    definition: { id: "command_hall" },
    isCompleted: () => true,
    isUnderConstruction: () => false
  } as unknown as Building;
}

function fakeCrownShrine(owner: "player" | "enemy" | "neutral" = "player"): CaptureSite {
  return {
    owner,
    position: { x: 200, y: 200 },
    radius: 64
  } as unknown as CaptureSite;
}

function tutorialHint(options: {
  selected?: BaseEntity[];
  commandHall?: Building;
  buildings?: Building[];
  crownShrine?: CaptureSite;
  hero?: Hero;
}): string {
  const hero = options.hero ?? fakeHero();

  return firstBattleTutorialHint({
    isFirstBattle: true,
    selected: options.selected ?? [hero],
    commandHall: options.commandHall ?? fakeCommandHall(),
    crownShrine: options.crownShrine ?? fakeCrownShrine(),
    hero,
    buildings: options.buildings ?? [],
    elapsedSeconds: 30,
    unitsTrained: 0,
    enemyWavesSurvived: 0
  });
}

describe("firstBattleTutorialHint", () => {
  it("keeps the construction wait hint active when a new Barracks is selected", () => {
    const barracks = {
      alive: true,
      team: "player",
      definition: { id: "barracks" },
      isCompleted: () => false,
      isUnderConstruction: () => true
    } as unknown as Building;

    expect(tutorialHint({ selected: [barracks], buildings: [barracks] })).toBe(
      "Barracks is under construction. Hold near your base until it completes."
    );
  });

  it("still asks for the Command Hall before production is started", () => {
    const commandHall = fakeCommandHall();

    expect(tutorialHint({ selected: [], commandHall })).toBe("Select your Command Hall.");
  });

  it("asks for army selection before retaking a lost Crown Shrine while a building is selected", () => {
    const barracks = {
      alive: true,
      team: "player",
      definition: { id: "barracks" },
      isCompleted: () => true,
      isUnderConstruction: () => false
    } as unknown as Building;

    expect(tutorialHint({ selected: [barracks], buildings: [barracks], crownShrine: fakeCrownShrine("enemy") })).toBe(
      "Select your army, then right-click the Crown Shrine."
    );
  });

  it("uses selected-forces wording when retaking the Crown Shrine with only the hero selected", () => {
    const hero = fakeHero();

    expect(tutorialHint({ selected: [hero], hero, crownShrine: fakeCrownShrine("enemy") })).toBe(
      "Right-click the Crown Shrine with your selected forces."
    );
  });
});
