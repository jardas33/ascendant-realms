import { describe, expect, it } from "vitest";
import { BUILDING_BY_ID } from "../../data/contentIndex";
import { createUnitVeterancyState } from "../../data/unitVeterancy";
import { Building, type TrainingQueueItem, type UpgradeQueueItem } from "../../entities/Building";
import { CaptureSite } from "../../entities/CaptureSite";
import { Unit } from "../../entities/Unit";
import { renderSelectionSummary } from "./SelectedEntityPanel";

describe("SelectedEntityPanel", () => {
  it("summarizes multi-selection composition, ownership, health, focus, and current orders", () => {
    const militia = fakeUnit("player-1", "Militia", "guard_area");
    const ranger = fakeUnit("player-2", "Ranger", "press_attack");
    ranger.hp = 65;

    const markup = renderSelectionSummary(undefined, [militia, ranger]);

    expect(markup).toContain('data-testid="multi-selection-summary"');
    expect(markup).toContain("2 selected");
    expect(markup).toContain("1 Militia");
    expect(markup).toContain("1 Ranger");
    expect(markup).toContain("Ownership</strong><span>Player");
    expect(markup).toContain("1 healthy · 1 damaged");
    expect(markup).toContain("Primary</strong><span>Militia");
    expect(markup).toContain("Order</strong><span>Mixed orders");
    expect(markup).toContain("Commands</strong><span>2 player units eligible.");
    expect(markup).not.toContain("friendly selections");
  });

  it("fails closed for mixed ownership without exposing an actionable enemy order", () => {
    const player = fakeUnit("player-1", "Militia", "guard_area");
    const enemy = fakeUnit("enemy-1", "Raider", "press_attack", { team: "enemy" });

    const markup = renderSelectionSummary(undefined, [player, enemy]);

    expect(markup).toContain("Mixed ownership");
    expect(markup).toContain("Order</strong><span>unavailable");
    expect(markup).toContain("Commands</strong><span>1 player units eligible.");
  });

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

    expect(markup).toContain('data-testid="selection-focus-summary"');
    expect(markup).toContain("Unit selected");
    expect(markup).toContain('data-testid="selected-role-summary"');
    expect(markup).toContain("Frontline / Melee");
    expect(markup).toContain("Put Militia in front");
    expect(markup).toContain("Role Frontline / Melee");
    expect(markup).toContain("Tags Frontline / Melee / Holds Ground");
    expect(markup).toContain("Rank Veteran");
    expect(markup).toContain("Veterancy Battle-only unit");
  });

  it("shows enemy elite squad label, modest bonus, and counterplay on selected units", () => {
    const raider = fakeUnit("enemy-1", "Raider", "guard_area", {
      unitId: "raider",
      team: "enemy",
      enemyEliteSquadId: "ash_raider_vanguard",
      enemyEliteSquadName: "Ash Raider Vanguard",
      enemyEliteBonusSummary: "+8% HP, +6% damage",
      enemyEliteCounterplay: "Screen with Militia and fight near towers or your main army."
    });

    const markup = renderSelectionSummary(raider, [raider]);

    expect(markup).toContain("Enemy inspected");
    expect(markup).toContain("Read-only target information");
    expect(markup).toContain("Enemy Pressure / Melee");
    expect(markup).toContain("Elite Ash Raider Vanguard");
    expect(markup).toContain("Elite bonus +8% HP, +6% damage");
    expect(markup).toContain("Counterplay Screen with Militia");
    expect(markup).not.toContain('data-testid="behaviour-mode-panel"');
  });

  it("distinguishes selected Workers as utility units", () => {
    const worker = fakeUnit("player-worker", "Worker", "guard_area", { unitId: "worker" });

    const markup = renderSelectionSummary(worker, [worker]);

    expect(markup).toContain("Worker selected");
    expect(markup).toContain("Utility unit");
  });

  it("exposes the current order as a readable status region", () => {
    const unit = fakeUnit("player-1", "Militia", "hold_ground", { unitId: "militia" });

    const markup = renderSelectionSummary(unit, [unit]);

    expect(markup).toContain('data-testid="unit-order-summary"');
    expect(markup).toContain('role="status"');
    expect(markup).toContain('aria-label="Current order"');
    expect(markup).toContain(">Holding Ground</strong>");
    expect(markup).toContain("Staying put; attacks only immediate threats");
  });

  it("makes a selected Worker's resource-site assignment explicit", () => {
    const assigned = fakeUnit("player-worker", "Worker", "guard_area", { unitId: "worker" });
    assigned.activeResourceSiteId = "crown_shrine";
    assigned.activeResourceSiteLabel = "Crown Shrine";
    const assignedMarkup = renderSelectionSummary(assigned, [assigned]);

    expect(assignedMarkup).toContain('data-testid="selected-worker-resource-assignment"');
    expect(assignedMarkup).toContain("Assigned to Crown Shrine");
    expect(assignedMarkup).toContain("assigning elsewhere will replace");

    const unassigned = fakeUnit("player-worker-2", "Worker", "guard_area", { unitId: "worker" });
    const unassignedMarkup = renderSelectionSummary(unassigned, [unassigned]);
    expect(unassignedMarkup).toContain("No resource site assigned");
    expect(unassignedMarkup).toContain("Select a captured resource site");
  });

  it("does not expose player resource assignment guidance for an enemy Worker", () => {
    const enemyWorker = fakeUnit("enemy-worker", "Worker", "guard_area", { unitId: "worker" });
    enemyWorker.team = "enemy";
    enemyWorker.activeResourceSiteId = "stone_quarry";
    enemyWorker.activeResourceSiteLabel = "Stone Quarry";

    const markup = renderSelectionSummary(enemyWorker, [enemyWorker]);

    expect(markup).not.toContain('data-testid="selected-worker-resource-assignment"');
    expect(markup).not.toContain("Assigning elsewhere will replace");
  });

  it("keeps player density focused on role, orders, and combat essentials", () => {
    const militia = fakeUnit("player-1", "Militia", "guard_area", { unitId: "militia", veterancyXp: 140 });

    const markup = renderSelectionSummary(militia, [militia], [], {}, "minimal");

    expect(markup).toContain("Frontline / Melee");
    expect(markup).toContain("HP 90/90");
    expect(markup).toContain('class="density-optional">Tags Frontline / Melee / Holds Ground</span>');
    expect(markup).toContain('class="density-optional">XP ');
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
      constructionProgressing: true,
      assignedWorkerId: "worker-1",
      assignedWorkerName: "Worker",
      underConstruction: true
    }), []);

    expect(markup).toContain("Status Building");
    expect(markup).toContain("Construction 44%");
    expect(markup).toContain("Worker Worker");
    expect(markup).toContain("construction is advancing");
    expect(markup).toContain("no input required");
    expect(markup).toContain('role="progressbar"');
    expect(markup).toContain('aria-valuenow="44"');
    expect(markup).toContain('aria-label="Construction progress 44%"');
    expect(markup).toContain("Role Army production");
    expect(markup).toContain("Unlocks when complete: trains Militia, Ranger; researches Infantry Weapons I, Reinforced Armor I, Ranger Training I.");
  });

  it.each([
    ["unassigned", {}, "Status Unassigned", "No Worker is assigned", "Continue: select Worker and right-click site."],
    ["traveling", { assignedWorkerId: "worker-1", assignedWorkerName: "Worker", constructionStatusDetail: "Worker traveling" }, "Status Worker traveling", "progress resumes on arrival", "wait for the Worker to arrive"],
    ["paused", { assignedWorkerId: "worker-1", assignedWorkerName: "Worker", constructionStatusDetail: "Paused - issue Build to resume" }, "Status Paused", "progress is not advancing", "issue Build/Resume"],
    ["missing", { assignedWorkerId: "worker-1", assignedWorkerName: "Worker", constructionStatusDetail: "Worker missing" }, "Status Worker missing", "is unavailable", "select another Worker"]
  ])("explains the construction state and resume action for %s", (_state, options, status, detail, action) => {
    const markup = renderSelectionSummary(fakeBuilding("construction-site", "barracks", {
      constructionProgress: 0.32,
      underConstruction: true,
      ...options
    }), []);

    expect(markup).toContain('data-testid="construction-status"');
    expect(markup).toContain(status);
    expect(markup).toContain(detail);
    expect(markup).toContain(action);
  });

  it.each([
    [0, "0"],
    [0.5, "50"],
    [1.4, "100"],
    [-0.2, "0"],
    [Number.NaN, "0"]
  ])("clamps construction progress %s to an accessible finite value", (progress, expected) => {
    const markup = renderSelectionSummary(fakeBuilding("construction-site", "barracks", {
      constructionProgress: progress,
      underConstruction: true
    }), []);

    expect(markup).toContain(`aria-valuenow="${expected}"`);
    expect(markup).not.toContain("NaN");
    expect(markup).not.toContain("Infinity");
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

  it("renders active and waiting training entries with canonical positions and cancel indexes", () => {
    const trainingQueue: TrainingQueueItem[] = [
      { unitId: "worker", remaining: 40, total: 100, announce: true, paidCost: { crowns: 50 } },
      { unitId: "militia", remaining: 100, total: 100, announce: true, paidCost: { crowns: 60, iron: 20 } }
    ];
    const building = fakeBuilding("player-barracks", "barracks", { trainingQueue });

    const markup = renderSelectionSummary(building, []);

    expect(markup).toContain('data-testid="training-queue"');
    expect(markup).toContain("Training now");
    expect(markup).toContain("Queued · Position 2");
    expect(markup).toContain('data-queue-index="1"');
    expect(markup).toContain('aria-valuenow="60"');
    expect(markup).toContain('aria-label="Cancel Militia training, queue position 2"');
    expect(markup.match(/role="progressbar"/g)).toHaveLength(1);
    expect(markup).not.toContain('aria-valuenow="100"');
  });

  it("keeps research separate and fails safely for malformed progress", () => {
    const upgradeQueue: UpgradeQueueItem[] = [
      { upgradeId: "camp_foundations_1", remaining: 10, total: 20, announce: true, paidCost: { crowns: 90, stone: 70 } },
      { upgradeId: "sentry_bracing_1", remaining: 0, total: 0, announce: true, paidCost: { crowns: 90, stone: 80, iron: 40 } }
    ];
    const building = fakeBuilding("player-watchtower", "watchtower", {
      trainingQueue: [{ unitId: "worker", remaining: -5, total: 100, announce: true, paidCost: { crowns: 50 } }],
      upgradeQueue
    });
    const before = JSON.stringify({ training: building.trainingQueue, upgrade: building.upgradeQueue });

    const markup = renderSelectionSummary(building, []);

    expect(markup).toContain('data-testid="training-queue"');
    expect(markup).toContain('data-testid="research-queue"');
    expect(markup).toContain("Researching now");
    expect(markup).toContain("Queued · Position 2");
    expect(markup).toContain('aria-valuenow="100"');
    expect(markup).toContain('aria-valuenow="50"');
    expect(markup).not.toContain("NaN");
    expect(markup).not.toContain("Infinity");
    expect(JSON.stringify({ training: building.trainingQueue, upgrade: building.upgradeQueue })).toBe(before);
  });

  it("keeps enemy and dead building inspection free of player queue controls", () => {
    const enemyMarkup = renderSelectionSummary(
      fakeBuilding("enemy-barracks", "barracks", {
        team: "enemy",
        trainingQueue: [{ unitId: "militia", remaining: 10, total: 20, announce: false, paidCost: { crowns: 60, iron: 20 } }]
      }),
      []
    );
    const deadMarkup = renderSelectionSummary(
      fakeBuilding("dead-barracks", "barracks", {
        alive: false,
        trainingQueue: [{ unitId: "militia", remaining: 10, total: 20, announce: false, paidCost: { crowns: 60, iron: 20 } }]
      }),
      []
    );

    expect(enemyMarkup).toContain("Enemy building inspected");
    expect(enemyMarkup).not.toContain("Training Queue");
    expect(enemyMarkup).not.toContain('data-action="cancel-train"');
    expect(deadMarkup).not.toContain("Training Queue");
    expect(deadMarkup).not.toContain('data-action="cancel-train"');
  });

  it("shows captured resource-site Worker slot and income boost details", () => {
    const site = fakeCaptureSite({
      owner: "player",
      assignedWorkerName: "Worker",
      workerAssignmentStatusDetail: "Worker working",
      workerAssignmentBoostActive: true
    });

    const markup = renderSelectionSummary(site, []);

    expect(markup).toContain("Owner Friendly captured");
    expect(markup).toContain("Level 1/2");
    expect(markup).toContain("Crowns");
    expect(markup).toContain("Income every 5s");
    expect(markup).toContain("Workers 1/1");
    expect(markup).toContain("Base +30 · Upgrade +0 · Workers +6");
    expect(markup).toContain("Total +36 Crowns every 5s");
    expect(markup).toContain("Assigned: Worker");
    expect(markup).toContain("Status: Worker working");
    expect(markup).toContain("Effect: adds upgrade income and one additional Worker slot.");
  });

  it("explains neutral resource sites must be captured before Worker assignment", () => {
    const site = fakeCaptureSite({ owner: "neutral", workerAssignmentStatusDetail: "Empty worker slot" });

    const markup = renderSelectionSummary(site, []);

    expect(markup).toContain("Owner Neutral");
    expect(markup).toContain("Workers 0/1");
    expect(markup).toContain("Assigned: Empty");
    expect(markup).toContain("Player income inactive until this site is captured.");
    expect(markup).toContain("Capture this site before assigning a Worker.");
    expect(markup).not.toContain("Total +30 crowns");
    expect(markup).not.toContain("Workers +0");
  });

  it("keeps enemy resource-site inspection free of player income claims", () => {
    const markup = renderSelectionSummary(
      fakeCaptureSite({ owner: "enemy", workerAssignmentStatusDetail: "Enemy logistics 1/1 boosting" }),
      []
    );

    expect(markup).toContain("Owner Enemy controlled");
    expect(markup).toContain("Enemy controlled income");
    expect(markup).toContain("Player income inactive until this site is captured.");
    expect(markup).not.toContain("Total +30 crowns");
    expect(markup).not.toContain("Worker bonus");
  });

  it("shows Lume link status for eligible selected sites", () => {
    const site = fakeCaptureSite({ id: "ford_toll", name: "Ford Toll", owner: "player" });

    const markup = renderSelectionSummary(site, [], [], {
      ford_toll: {
        title: "Lume Link",
        state: "active",
        linkedSites: "West Stone Cut, North Aether Spring",
        benefit: "Friendly units and buildings near active linked sites take 8% less incoming damage.",
        counterplay: "Enemy recapture severs the link; retake both endpoints to restore it."
      }
    });

    expect(markup).toContain('data-testid="selected-lume-site-summary"');
    expect(markup).toContain("Lume Link: Active");
    expect(markup).toContain("Linked to West Stone Cut, North Aether Spring");
    expect(markup).toContain("8% less incoming damage");
  });
});

function fakeUnit(
  id: string,
  name: string,
  behaviourMode: "hold_ground" | "guard_area" | "press_attack",
  options: {
    unitId?: string;
    veterancyXp?: number;
    team?: "player" | "enemy";
    enemyEliteSquadId?: string;
    enemyEliteSquadName?: string;
    enemyEliteBonusSummary?: string;
    enemyEliteCounterplay?: string;
    activeResourceSiteId?: string;
    activeResourceSiteLabel?: string;
  } = {}
): Unit {
  const unitId = options.unitId ?? name.toLowerCase();
  return Object.assign(Object.create(Unit.prototype), {
    id,
    kind: "unit",
    team: options.team ?? "player",
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
    eliteDamageMultiplier: 1,
    enemyEliteSquadId: options.enemyEliteSquadId,
    enemyEliteSquadName: options.enemyEliteSquadName,
    enemyEliteBonusSummary: options.enemyEliteBonusSummary,
    enemyEliteCounterplay: options.enemyEliteCounterplay,
    activeResourceSiteId: options.activeResourceSiteId,
    activeResourceSiteLabel: options.activeResourceSiteLabel,
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
    constructionProgressing?: boolean;
    assignedWorkerId?: string;
    assignedWorkerName?: string;
    underConstruction?: boolean;
    hp?: number;
    maxHp?: number;
    team?: "player" | "enemy" | "neutral";
    alive?: boolean;
    trainingQueue?: TrainingQueueItem[];
    upgradeQueue?: UpgradeQueueItem[];
  } = {}
): Building {
  const definition = BUILDING_BY_ID[buildingId];
  if (!definition) {
    throw new Error(`Missing building ${buildingId}`);
  }

  return Object.assign(Object.create(Building.prototype), {
    id,
    kind: "building",
    team: options.team ?? "player",
    alive: options.alive ?? true,
    rallyPoint: undefined,
    trainingQueue: options.trainingQueue ?? [],
    upgradeQueue: options.upgradeQueue ?? [],
    hp: options.hp ?? 100,
    maxHp: options.maxHp ?? 100,
    armor: 1,
    constructionProgress: options.constructionProgress ?? 1,
    constructionStatusDetail: options.constructionStatusDetail,
    constructionProgressing: options.constructionProgressing ?? false,
    assignedWorkerId: options.assignedWorkerId,
    assignedWorkerName: options.assignedWorkerName,
    definition,
    isCompleted: () => !options.underConstruction,
    isUnderConstruction: () => Boolean(options.underConstruction)
  }) as Building;
}

function fakeCaptureSite(
  options: {
    id?: string;
    name?: string;
    owner: "player" | "enemy" | "neutral";
    assignedWorkerName?: string;
    workerAssignmentStatusDetail?: string;
    workerAssignmentBoostActive?: boolean;
  }
): CaptureSite {
  return Object.assign(Object.create(CaptureSite.prototype), {
    id: options.id ?? "crown_shrine",
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
      id: options.id ?? "crown_shrine",
      name: options.name ?? "Crown Shrine",
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
