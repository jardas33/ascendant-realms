import { describe, expect, it } from "vitest";
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
      fakeBuilding("command-hall", "Command Hall")
    ]);

    expect(markup).toContain('data-testid="behaviour-mode-current"');
    expect(markup).toContain(">Guard Area</span>");
    expect(markup).not.toContain(">Mixed</span>");
  });

  it("shows assigned worker and progress for incomplete buildings", () => {
    const markup = renderSelectionSummary(fakeBuilding("barracks", "Barracks", {
      constructionProgress: 0.44,
      constructionStatusDetail: "Worker building",
      assignedWorkerName: "Worker",
      underConstruction: true
    }), []);

    expect(markup).toContain("Status Worker building");
    expect(markup).toContain("Construction 44%");
    expect(markup).toContain("Worker Worker");
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
  name: string,
  options: {
    constructionProgress?: number;
    constructionStatusDetail?: string;
    assignedWorkerName?: string;
    underConstruction?: boolean;
  } = {}
): Building {
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
    definition: {
      id: name.toLowerCase().replaceAll(" ", "_"),
      name,
      trainOptions: []
    },
    isCompleted: () => !options.underConstruction,
    isUnderConstruction: () => Boolean(options.underConstruction)
  }) as Building;
}
