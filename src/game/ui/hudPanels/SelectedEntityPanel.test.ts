import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID } from "../../data/contentIndex";
import { Building } from "../../entities/Building";
import { Unit } from "../../entities/Unit";
import { renderSelectionSummary } from "./SelectedEntityPanel";

describe("SelectedEntityPanel", () => {
  it("renders behaviour mode controls for selected unit groups", () => {
    const markup = renderSelectionSummary(undefined, [
      fakeUnit("player-1", "Militia", "guard_area"),
      fakeUnit("player-2", "Ranger", "guard_area")
    ]);

    expect(markup).toContain('data-testid="behaviour-mode-panel"');
    expect(markup).toContain('data-testid="behaviour-mode-current"');
    expect(markup).toContain(">Guard Area</span>");
    expect(markup).toContain('data-testid="behaviour-mode-hold_ground"');
    expect(markup).toContain('data-testid="behaviour-mode-guard_area"');
    expect(markup).toContain('data-testid="behaviour-mode-press_attack"');
    expect(markup).toContain('aria-pressed="true"');
  });

  it("marks mixed behaviour groups clearly", () => {
    const markup = renderSelectionSummary(undefined, [
      fakeUnit("player-1", "Militia", "hold_ground"),
      fakeUnit("player-2", "Ranger", "press_attack")
    ]);

    expect(markup).toContain('data-testid="behaviour-mode-current"');
    expect(markup).toContain(">Mixed</span>");
    expect(markup).toContain('title="Selected units use different behaviour modes."');
  });

  it("does not let selected buildings corrupt unit behaviour mode summary", () => {
    const markup = renderSelectionSummary(undefined, [
      fakeUnit("player-1", "Militia", "guard_area"),
      fakeBuilding("command-hall", "command_hall")
    ]);

    expect(markup).toContain('data-testid="behaviour-mode-current"');
    expect(markup).toContain(">Guard Area</span>");
    expect(markup).not.toContain(">Mixed</span>");
  });

  it("shows assigned worker and progress for incomplete buildings", () => {
    const markup = renderSelectionSummary(fakeBuilding("barracks", "barracks", {
      constructionProgress: 0.44,
      constructionStatusDetail: "Building",
      assignedWorkerName: "Worker",
      underConstruction: true
    }), []);

    expect(markup).toContain("Status Building");
    expect(markup).toContain("Construction 44%");
    expect(markup).toContain("Assigned Worker");
    expect(markup).toContain("Role Army production");
    expect(markup).toContain("Unlocks when complete: trains Militia, Ranger; researches Infantry Weapons I, Reinforced Armor I, Ranger Training I.");
  });

  it("labels completed building roles for production and defense", () => {
    const barracksMarkup = renderSelectionSummary(fakeBuilding("barracks", "barracks"), []);
    const lodgeMarkup = renderSelectionSummary(fakeBuilding("mystic-lodge", "mystic_lodge"), []);
    const towerMarkup = renderSelectionSummary(fakeBuilding("watchtower", "watchtower"), []);

    expect(barracksMarkup).toContain("Role Army production: trains Militia and Rangers and researches basic troop upgrades.");
    expect(lodgeMarkup).toContain("Role Mystic support: trains Acolytes and researches Aether Study.");
    expect(towerMarkup).toContain("Role Defense: attacks nearby enemies after construction.");
    expect(towerMarkup).toContain("Defense ready");
    expect(towerMarkup).not.toContain("Queue idle");
  });
});

function fakeUnit(id: string, name: string, behaviourMode: "hold_ground" | "guard_area" | "press_attack"): Unit {
  return Object.assign(Object.create(Unit.prototype), {
    id,
    kind: "unit",
    team: "player",
    alive: true,
    behaviourMode,
    definition: {
      id: name.toLowerCase(),
      name
    }
  }) as Unit;
}

function fakeBuilding(
  id: string,
  buildingId: string,
  options: {
    constructionProgress?: number;
    constructionStatusDetail?: string;
    assignedWorkerName?: string;
    underConstruction?: boolean;
  } = {}
): Building {
  const definition = BUILDING_BY_ID[buildingId];
  if (!definition) {
    throw new Error(`Missing building ${buildingId}`);
  }

  return Object.assign(Object.create(Building.prototype), {
    id,
    kind: "building",
    team: "player",
    alive: true,
    rallyPoint: undefined,
    trainingQueue: [],
    upgradeQueue: [],
    hp: 100,
    maxHp: 100,
    armor: 1,
    constructionProgress: options.constructionProgress ?? 1,
    constructionStatusDetail: options.constructionStatusDetail,
    assignedWorkerName: options.assignedWorkerName,
    definition,
    isCompleted: () => !options.underConstruction,
    isUnderConstruction: () => Boolean(options.underConstruction)
  }) as Building;
}
