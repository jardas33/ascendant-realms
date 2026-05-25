import { describe, expect, it, vi } from "vitest";
import { CAPTURE_TIME_SECONDS } from "../core/Constants";
import type { CaptureSiteDefinition, ResourceBag, Team } from "../core/GameTypes";
import { CaptureSite } from "../entities/CaptureSite";
import type { Unit } from "../entities/Unit";
import { ResourceSystem, workerSiteBonusAmount } from "./ResourceSystem";

const EMPTY_RESOURCES: ResourceBag = { crowns: 0, stone: 0, iron: 0, aether: 0 };

function createSite(definition: Partial<CaptureSiteDefinition> = {}): CaptureSite {
  const siteDefinition: CaptureSiteDefinition = {
    id: "cinder_crossing",
    name: "Cinder Shrine",
    resource: "aether",
    x: 100,
    y: 100,
    radius: 80,
    incomeAmount: 16,
    incomeInterval: 999,
    firstCaptureBonus: {
      id: "cinder_shrine_surge",
      label: "Cinder Shrine Surge",
      description: "The first claim releases +20 Aether.",
      resources: { aether: 20 }
    },
    ...definition
  };
  const site = {
    id: siteDefinition.id,
    definition: siteDefinition,
    owner: "neutral" as Team,
    team: "neutral" as Team,
    capturingTeam: "neutral" as Team,
    captureProgress: 0,
    incomeTimer: 0,
    position: { x: siteDefinition.x, y: siteDefinition.y },
    radius: siteDefinition.radius,
    alive: true,
    assignedWorkerId: undefined as string | undefined,
    assignedWorkerName: undefined as string | undefined,
    workerAssignmentStatusDetail: "Empty worker slot",
    workerAssignmentBoostActive: false,
    setOwner(owner: Team) {
      this.owner = owner;
      this.team = owner;
      this.capturingTeam = "neutral";
      this.captureProgress = 0;
      this.incomeTimer = 0;
      this.clearWorkerAssignment();
    },
    setWorkerAssignment(workerId: string, workerName: string, status = `${workerName} traveling`) {
      this.assignedWorkerId = workerId;
      this.assignedWorkerName = workerName;
      this.workerAssignmentStatusDetail = status;
      this.workerAssignmentBoostActive = false;
    },
    clearWorkerAssignment(status = "Empty worker slot") {
      this.assignedWorkerId = undefined;
      this.assignedWorkerName = undefined;
      this.workerAssignmentStatusDetail = status;
      this.workerAssignmentBoostActive = false;
    },
    updateVisuals() {}
  };
  Object.setPrototypeOf(site, CaptureSite.prototype);
  return site as unknown as CaptureSite;
}

function createUnit(team: Team, x = 100, y = 100): Unit {
  return {
    id: `${team}-unit`,
    alive: true,
    team,
    position: { x, y }
  } as unknown as Unit;
}

function createWorker(id = "worker-1", x = 100, y = 100): Unit {
  return {
    id,
    alive: true,
    team: "player",
    position: { x, y },
    radius: 18,
    definition: { id: "worker", name: "Worker" },
    moveTarget: undefined as Unit["moveTarget"],
    activeResourceSiteId: undefined as Unit["activeResourceSiteId"],
    activeResourceSiteLabel: undefined as Unit["activeResourceSiteLabel"],
    attackTargetId: undefined as Unit["attackTargetId"],
    attackTargetLabel: undefined as Unit["attackTargetLabel"],
    attackMove: false,
    activeConstructionSiteId: undefined as Unit["activeConstructionSiteId"],
    activeRepairTargetId: undefined as Unit["activeRepairTargetId"],
    commandResourceSiteMove(this: Unit, target: { x: number; y: number }, siteId: string, siteLabel: string) {
      this.activeConstructionSiteId = undefined;
      this.activeRepairTargetId = undefined;
      this.activeResourceSiteId = siteId;
      this.activeResourceSiteLabel = siteLabel;
      this.moveTarget = { ...target };
      this.attackTargetId = undefined;
      this.attackTargetLabel = undefined;
      this.attackMove = false;
    },
    markResourceSiteWork(this: Unit, siteId: string, siteLabel: string) {
      this.activeConstructionSiteId = undefined;
      this.activeRepairTargetId = undefined;
      this.activeResourceSiteId = siteId;
      this.activeResourceSiteLabel = siteLabel;
      this.attackTargetId = undefined;
      this.attackTargetLabel = undefined;
      this.attackMove = false;
    },
    clearResourceSiteWork(this: Unit, siteId?: string) {
      if (!siteId || this.activeResourceSiteId === siteId) {
        this.activeResourceSiteId = undefined;
        this.activeResourceSiteLabel = undefined;
      }
    },
    commandMove(this: Unit, target: { x: number; y: number }) {
      this.activeResourceSiteId = undefined;
      this.activeResourceSiteLabel = undefined;
      this.moveTarget = { ...target };
      this.attackTargetId = undefined;
      this.attackTargetLabel = undefined;
      this.attackMove = false;
    },
    commandAttack(this: Unit, targetId: string, targetLabel?: string) {
      this.activeResourceSiteId = undefined;
      this.activeResourceSiteLabel = undefined;
      this.attackTargetId = targetId;
      this.attackTargetLabel = targetLabel;
      this.attackMove = true;
    }
  } as unknown as Unit;
}

function createResourceBank(): Record<"player" | "enemy", ResourceBag> {
  return {
    player: { ...EMPTY_RESOURCES },
    enemy: { ...EMPTY_RESOURCES }
  };
}

describe("ResourceSystem first-capture bonuses", () => {
  it("grants a capture-site first-capture bonus when the player claims the site", () => {
    const resources = createResourceBank();
    const site = createSite();
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);

    expect(site.owner).toBe("player");
    expect(resources.player.aether).toBe(20);
    expect(onCaptureBonus).toHaveBeenCalledWith(site, "player", site.definition.firstCaptureBonus);
  });

  it("does not duplicate a first-capture bonus when the same team recaptures the site", () => {
    const resources = createResourceBank();
    const site = createSite();
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);
    site.setOwner("neutral");
    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);

    expect(resources.player.aether).toBe(20);
    expect(onCaptureBonus).toHaveBeenCalledTimes(1);
  });

  it("tracks first-capture bonuses separately for player and enemy teams", () => {
    const resources = createResourceBank();
    const site = createSite();
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);
    site.setOwner("neutral");
    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("enemy")]);

    expect(resources.player.aether).toBe(20);
    expect(resources.enemy.aether).toBe(20);
    expect(onCaptureBonus).toHaveBeenCalledTimes(2);
  });

  it("applies an adjusted first-capture bonus without changing duplicate prevention", () => {
    const resources = createResourceBank();
    const site = createSite();
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus,
      adjustFirstCaptureBonus: (_site, owner, bonus) =>
        owner === "player"
          ? {
              ...bonus,
              resources: { ...bonus.resources, aether: (bonus.resources.aether ?? 0) + 5 }
            }
          : bonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);
    site.setOwner("neutral");
    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);

    expect(resources.player.aether).toBe(25);
    expect(onCaptureBonus).toHaveBeenCalledTimes(1);
    expect(onCaptureBonus).toHaveBeenCalledWith(
      site,
      "player",
      expect.objectContaining({
        resources: { aether: 25 }
      })
    );
  });

  it("falls back to ordinary capture behavior when a site has no bonus", () => {
    const resources = createResourceBank();
    const site = createSite({ firstCaptureBonus: undefined });
    const onCaptureBonus = vi.fn();
    const system = new ResourceSystem({
      resources,
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onCaptureBonus
    });

    system.update(CAPTURE_TIME_SECONDS, [site], [createUnit("player")]);

    expect(site.owner).toBe("player");
    expect(resources.player.aether).toBe(0);
    expect(onCaptureBonus).not.toHaveBeenCalled();
  });
});

describe("ResourceSystem Worker site assignment", () => {
  it("rejects neutral and enemy sites for Worker assignment", () => {
    const resources = createResourceBank();
    const worker = createWorker();
    const neutralSite = createSite();
    const enemySite = createSite({ id: "enemy_mine", name: "Enemy Mine" });
    enemySite.setOwner("enemy");
    const messages: string[] = [];
    const system = new ResourceSystem({
      resources,
      getCaptureSites: () => [neutralSite, enemySite],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: (message) => messages.push(message)
    });

    expect(system.requestWorkerAssignment(worker, neutralSite)).toBe(false);
    expect(system.requestWorkerAssignment(worker, enemySite)).toBe(false);
    expect(worker.activeResourceSiteId).toBeUndefined();
    expect(messages).toContain("Capture the resource site before assigning a Worker.");
  });

  it("consumes invalid Worker site orders with feedback instead of falling through to movement", () => {
    const resources = createResourceBank();
    const worker = createWorker();
    const neutralSite = createSite();
    const messages: string[] = [];
    const system = new ResourceSystem({
      resources,
      getCaptureSites: () => [neutralSite],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: (message) => messages.push(message)
    });

    expect(system.issueWorkerAssignmentOrder(neutralSite, [worker])).toBe(true);

    expect(worker.activeResourceSiteId).toBeUndefined();
    expect(worker.moveTarget).toBeUndefined();
    expect(messages).toContain("Capture the resource site before assigning a Worker.");
  });

  it("assigns a Worker to a friendly captured site only after an explicit command", () => {
    const resources = createResourceBank();
    const site = createSite({ incomeAmount: 20, incomeInterval: 1 });
    site.setOwner("player");
    const worker = createWorker("worker-1", 100, 100);
    const system = new ResourceSystem({
      resources,
      getCaptureSites: () => [site],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: vi.fn()
    });

    system.update(1, [site], [worker]);
    expect(site.assignedWorkerId).toBeUndefined();
    expect(site.workerAssignmentBoostActive).toBe(false);
    expect(resources.player.aether).toBe(20);

    expect(system.requestWorkerAssignment(worker, site)).toBe(true);
    system.update(1, [site], [worker]);

    expect(site.assignedWorkerId).toBe(worker.id);
    expect(site.workerAssignmentBoostActive).toBe(true);
    expect(worker.activeResourceSiteId).toBe(site.id);
    expect(resources.player.aether).toBe(20 + 20 + workerSiteBonusAmount(site));
  });

  it("moves a Worker into range before the site bonus starts", () => {
    const resources = createResourceBank();
    const site = createSite({ incomeAmount: 20, incomeInterval: 1 });
    site.setOwner("player");
    const worker = createWorker("worker-1", 10, 10);
    const system = new ResourceSystem({
      resources,
      getCaptureSites: () => [site],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: vi.fn()
    });

    expect(system.requestWorkerAssignment(worker, site)).toBe(true);
    system.update(1, [site], [worker]);

    expect(worker.moveTarget).toEqual(site.position);
    expect(site.workerAssignmentBoostActive).toBe(false);
    expect(resources.player.aether).toBe(20);

    worker.position = { ...site.position };
    worker.moveTarget = undefined;
    system.update(1, [site], [worker]);

    expect(site.workerAssignmentBoostActive).toBe(true);
    expect(resources.player.aether).toBe(20 + 20 + workerSiteBonusAmount(site));
  });

  it("stops the bonus when the assigned Worker is moved or ordered to attack", () => {
    const resources = createResourceBank();
    const site = createSite({ incomeAmount: 20, incomeInterval: 1 });
    site.setOwner("player");
    const worker = createWorker();
    const system = new ResourceSystem({
      resources,
      getCaptureSites: () => [site],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: vi.fn()
    });

    system.requestWorkerAssignment(worker, site);
    system.update(1, [site], [worker]);
    const afterBoost = resources.player.aether;

    worker.commandMove({ x: 240, y: 240 });
    system.update(1, [site], [worker]);

    expect(site.assignedWorkerId).toBeUndefined();
    expect(site.workerAssignmentBoostActive).toBe(false);
    expect(resources.player.aether).toBe(afterBoost + 20);

    system.requestWorkerAssignment(worker, site);
    system.update(1, [site], [worker]);
    const afterReassign = resources.player.aether;

    worker.commandAttack("enemy-building", "Enemy Building");
    system.update(1, [site], [worker]);

    expect(site.assignedWorkerId).toBeUndefined();
    expect(resources.player.aether).toBe(afterReassign + 20);
  });

  it("reassigns a Worker by moving the bonus to the new site", () => {
    const resources = createResourceBank();
    const aetherSite = createSite({ id: "aether_well", name: "Aether Well", incomeAmount: 20, incomeInterval: 1 });
    const crownSite = createSite({
      id: "crown_shrine",
      name: "Crown Shrine",
      resource: "crowns",
      incomeAmount: 30,
      incomeInterval: 1
    });
    aetherSite.setOwner("player");
    crownSite.setOwner("player");
    const worker = createWorker();
    const system = new ResourceSystem({
      resources,
      getCaptureSites: () => [aetherSite, crownSite],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: vi.fn()
    });

    expect(system.requestWorkerAssignment(worker, aetherSite)).toBe(true);
    system.update(1, [aetherSite, crownSite], [worker]);
    expect(aetherSite.assignedWorkerId).toBe(worker.id);

    expect(system.requestWorkerAssignment(worker, crownSite)).toBe(true);
    system.update(1, [aetherSite, crownSite], [worker]);

    expect(aetherSite.assignedWorkerId).toBeUndefined();
    expect(crownSite.assignedWorkerId).toBe(worker.id);
    expect(crownSite.workerAssignmentBoostActive).toBe(true);
    expect(resources.player.crowns).toBe(30 + 30 + workerSiteBonusAmount(crownSite));
  });

  it("clears assignment when the Worker dies or site control is lost", () => {
    const resources = createResourceBank();
    const site = createSite({ incomeAmount: 20, incomeInterval: 1 });
    site.setOwner("player");
    const worker = createWorker();
    const system = new ResourceSystem({
      resources,
      getCaptureSites: () => [site],
      onCapture: vi.fn(),
      onIncome: vi.fn(),
      onMessage: vi.fn()
    });

    system.requestWorkerAssignment(worker, site);
    system.update(1, [site], [worker]);
    worker.alive = false;
    system.update(1, [site], [worker]);

    expect(site.assignedWorkerId).toBeUndefined();
    expect(site.workerAssignmentBoostActive).toBe(false);
    expect(worker.activeResourceSiteId).toBeUndefined();

    worker.alive = true;
    system.requestWorkerAssignment(worker, site);
    system.update(1, [site], [worker]);
    site.setOwner("enemy");
    system.update(1, [site], [worker]);

    expect(site.assignedWorkerId).toBeUndefined();
    expect(site.workerAssignmentBoostActive).toBe(false);
    expect(worker.activeResourceSiteId).toBeUndefined();
  });
});
