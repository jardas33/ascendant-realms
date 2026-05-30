import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID } from "../../data/contentIndex";
import { createUnitVeterancyState } from "../../data/unitVeterancy";
import { Building } from "../../entities/Building";
import { CaptureSite } from "../../entities/CaptureSite";
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

  it("renders compact control group summaries when groups exist", () => {
    const markup = renderSelectionSummary(
      undefined,
      [fakeUnit("player-1", "Militia", "guard_area"), fakeUnit("player-2", "Ranger", "guard_area")],
      [
        { slot: 1, count: 2 },
        { slot: 3, count: 1 }
      ]
    );

    expect(markup).toContain('data-testid="control-group-summary"');
    expect(markup).toContain("1:2 3:1");
    expect(markup).toContain("Ctrl+1-5 assigns; 1-5 recalls.");
  });

  it("shows role identity and battle-only veteran progress for a selected army unit", () => {
    const militia = fakeUnit("player-1", "Militia", "hold_ground", { unitId: "militia", veterancyXp: 140 });

    const markup = renderSelectionSummary(militia, [militia]);

    expect(markup).toContain('data-testid="selected-role-summary"');
    expect(markup).toContain("Frontline / Melee");
    expect(markup).toContain("Put Militia in front");
    expect(markup).toContain("Role Frontline / Melee");
    expect(markup).toContain("Tags Frontline / Melee / Holds Ground");
    expect(markup).toContain("Rank Veteran");
    expect(markup).toContain("Veterancy Battle-only unit");
  });

  it("summarizes selected group roles and ranked members", () => {
    const militia = fakeUnit("player-1", "Militia", "guard_area", { unitId: "militia", veterancyXp: 140 });
    const ranger = fakeUnit("player-2", "Ranger", "guard_area", { unitId: "ranger" });

    const markup = renderSelectionSummary(undefined, [militia, ranger]);

    expect(markup).toContain("Army Roles");
    expect(markup).toContain("1 Frontline / Melee, 1 Ranged / Focus Fire");
    expect(markup).toContain("1 ranked unit selected");
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
    expect(markup).toContain("Continue: select Worker and right-click site");
    expect(markup).toContain("Role Army production");
    expect(markup).toContain("Unlocks when complete: trains Militia, Ranger; researches Infantry Weapons I, Reinforced Armor I, Ranger Training I.");
  });

  it("labels completed building roles for production and defense", () => {
    const barracksMarkup = renderSelectionSummary(fakeBuilding("barracks", "barracks"), []);
    const lodgeMarkup = renderSelectionSummary(fakeBuilding("mystic-lodge", "mystic_lodge"), []);
    const towerMarkup = renderSelectionSummary(fakeBuilding("watchtower", "watchtower"), []);

    expect(barracksMarkup).toContain("Role Army production: trains Militia and Rangers and researches basic troop upgrades.");
    expect(lodgeMarkup).toContain("Role Mystic support: trains Acolytes and researches Aether Study I.");
    expect(towerMarkup).toContain("Role Defense: inactive while incomplete, attacks nearby enemies when complete, and researches tower defenses.");
    expect(towerMarkup).toContain("Defense ready");
    expect(towerMarkup).toContain("Repair Full health");
    expect(towerMarkup).toContain("Research idle");
    expect(towerMarkup).not.toContain("Queue idle");
  });

  it("shows damaged completed buildings can be repaired by a Worker", () => {
    const markup = renderSelectionSummary(fakeBuilding("barracks", "barracks", { hp: 420, maxHp: 600 }), []);

    expect(markup).toContain("HP 420/600");
    expect(markup).toContain("Repair Damaged - select a Worker and use Repair/right-click");
  });

  it("shows captured resource-site Worker slot and income boost details", () => {
    const site = fakeCaptureSite({
      owner: "player",
      assignedWorkerName: "Worker",
      workerAssignmentStatusDetail: "Worker working",
      workerAssignmentBoostActive: true
    });

    const markup = renderSelectionSummary(site, []);

    expect(markup).toContain("Control Friendly captured");
    expect(markup).toContain("Level 1/2");
    expect(markup).toContain("Resource crowns");
    expect(markup).toContain("Base income +30/5s");
    expect(markup).toContain("Upgrade bonus +0/5s");
    expect(markup).toContain("Worker slots 1/1");
    expect(markup).toContain("Assigned Worker");
    expect(markup).toContain("Worker bonus +6/5s (6 each)");
    expect(markup).toContain("Total income +36/5s");
    expect(markup).toContain("Status Worker working");
  });

  it("explains neutral resource sites must be captured before Worker assignment", () => {
    const site = fakeCaptureSite({ owner: "neutral", workerAssignmentStatusDetail: "Empty worker slot" });

    const markup = renderSelectionSummary(site, []);

    expect(markup).toContain("Control Neutral");
    expect(markup).toContain("Worker slots 0/1");
    expect(markup).toContain("Assigned Empty");
    expect(markup).toContain("Status Capture this site before assigning a Worker.");
    expect(markup).toContain("Capture this site before assigning a Worker.");
  });
});

function fakeUnit(
  id: string,
  name: string,
  behaviourMode: "hold_ground" | "guard_area" | "press_attack",
  options: { unitId?: string; veterancyXp?: number } = {}
): Unit {
  const unitId = options.unitId ?? name.toLowerCase();
  return Object.assign(Object.create(Unit.prototype), {
    id,
    kind: "unit",
    team: "player",
    alive: true,
    behaviourMode,
    hp: 90,
    maxHp: 90,
    armor: 1,
    veterancy: createUnitVeterancyState(id, unitId, options.veterancyXp ?? 0),
    damageBuffMultiplier: 1,
    upgradeDamageMultiplier: 1,
    veterancyDamageMultiplier: 1,
    upgradeRangeMultiplier: 1,
    upgradeAttackCooldownMultiplier: 1,
    definition: {
      id: unitId,
      name,
      stats: {
        maxHp: 90,
        damage: 9,
        range: 28,
        attackCooldown: 1,
        speed: 90,
        armor: 1
      }
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
    hp?: number;
    maxHp?: number;
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
    hp: options.hp ?? 100,
    maxHp: options.maxHp ?? 100,
    armor: 1,
    constructionProgress: options.constructionProgress ?? 1,
    constructionStatusDetail: options.constructionStatusDetail,
    assignedWorkerName: options.assignedWorkerName,
    definition,
    isCompleted: () => !options.underConstruction,
    isUnderConstruction: () => Boolean(options.underConstruction)
  }) as Building;
}

function fakeCaptureSite(
  options: {
    owner: "player" | "enemy" | "neutral";
    assignedWorkerName?: string;
    workerAssignmentStatusDetail?: string;
    workerAssignmentBoostActive?: boolean;
  }
): CaptureSite {
  return Object.assign(Object.create(CaptureSite.prototype), {
    id: "crown_shrine",
    kind: "capture-site",
    team: options.owner,
    owner: options.owner,
    alive: true,
    siteLevel: 1,
    workerAssignments: options.assignedWorkerName
      ? [
          {
            workerId: "worker-1",
            workerName: options.assignedWorkerName,
            statusDetail: options.workerAssignmentStatusDetail ?? "Worker traveling",
            boostActive: Boolean(options.workerAssignmentBoostActive)
          }
        ]
      : [],
    definition: {
      id: "crown_shrine",
      name: "Crown Shrine",
      resource: "crowns",
      x: 850,
      y: 780,
      radius: 76,
      incomeAmount: 30,
      incomeInterval: 5
    },
    assignedWorkerName: options.assignedWorkerName,
    workerAssignmentStatusDetail: options.workerAssignmentStatusDetail ?? "Empty worker slot",
    workerAssignmentBoostActive: Boolean(options.workerAssignmentBoostActive)
  }) as CaptureSite;
}
