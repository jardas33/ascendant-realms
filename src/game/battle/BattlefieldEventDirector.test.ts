import { describe, expect, it } from "vitest";
import { BattlefieldEventDirector, type BattlefieldEventDirectorContext } from "./BattlefieldEventDirector";

describe("BattlefieldEventDirector", () => {
  it("keeps Tutorial/no-reward routes protected", () => {
    const director = new BattlefieldEventDirector();
    const context = createContext({ mode: "tutorial", rewardsDisabled: true, elapsedSeconds: 90 });

    expect(director.update(90, context).transitions).toEqual([]);
    expect(director.forceStartEvent("site_under_threat", context)).toBeUndefined();
  });

  it("starts a doctrine-weighted site event with tactical plan support", () => {
    const director = new BattlefieldEventDirector();
    const update = director.update(
      40,
      createContext({
        elapsedSeconds: 40,
        doctrineId: "raider",
        missionTypeId: "control",
        tacticalPlanId: "resource_push"
      })
    );

    expect(update.transitions[0]).toMatchObject({
      type: "started",
      event: {
        id: "site_under_threat",
        objectiveLabel: "Hold Crown Shrine",
        planMatched: true,
        durationSeconds: 29
      },
      pressureNudgeSeconds: 8
    });
    expect(update.active?.progressLabel).toContain("Held");
  });

  it("enforces one active event and cooldown between events", () => {
    const director = new BattlefieldEventDirector();
    const started = director.forceStartEvent("site_under_threat", createContext({ elapsedSeconds: 50 }));
    expect(started?.type).toBe("started");
    expect(director.forceStartEvent("hold_the_line", createContext({ elapsedSeconds: 51 }))).toBeUndefined();

    const completed = director.resolveActiveEvent("completed", createContext({ elapsedSeconds: 52 }));
    expect(completed?.type).toBe("completed");
    expect(director.update(1, createContext({ elapsedSeconds: 53, doctrineId: "warband", missionTypeId: "defense" })).transitions).toEqual([]);
  });

  it("fails site pressure when the player loses the target before the timer closes", () => {
    const director = new BattlefieldEventDirector();
    const context = createContext({ elapsedSeconds: 40 });
    const started = director.forceStartEvent("site_under_threat", context);
    expect(started?.event.targetId).toBe("crown_shrine");

    const failed = director.update(
      35,
      createContext({
        elapsedSeconds: 75,
        siteOwner: "enemy"
      })
    ).transitions[0];

    expect(failed).toMatchObject({
      type: "failed",
      event: { id: "site_under_threat" }
    });
    expect(failed.telemetryLabel).toContain("lost");
  });

  it("completes elite and Retinue objectives only under matching conditions", () => {
    const eliteDirector = new BattlefieldEventDirector();
    const eliteStarted = eliteDirector.forceStartEvent("elite_strike", createContext({ eliteAlive: true, elapsedSeconds: 50 }));
    expect(eliteStarted?.event.eliteSquadId).toBe("cinder_iron_guard");
    const eliteCompleted = eliteDirector.update(
      1,
      createContext({
        eliteAlive: false,
        elapsedSeconds: 51
      })
    ).transitions[0];
    expect(eliteCompleted.type).toBe("completed");
    expect(eliteCompleted.resourceBonus).toEqual({ aether: 10 });

    const retinueDirector = new BattlefieldEventDirector();
    const retinueStarted = retinueDirector.forceStartEvent(
      "reinforcement_window",
      createContext({ retinueReinforcementAvailable: true, elapsedSeconds: 50 })
    );
    expect(retinueStarted?.event.id).toBe("reinforcement_window");
    const retinueCompleted = retinueDirector.update(
      1,
      createContext({
        retinueReinforcementAvailable: true,
        retinueReinforcementUsed: true,
        elapsedSeconds: 51
      })
    ).transitions[0];
    expect(retinueCompleted.type).toBe("completed");
  });

  it("uses Aether Surge only when a fresh hero ability is used", () => {
    const director = new BattlefieldEventDirector();
    const started = director.forceStartEvent(
      "aether_surge",
      createContext({
        tacticalPlanId: "champion_hunt",
        usedAbilityIds: ["rally_banner"],
        elapsedSeconds: 50
      })
    );

    expect(started?.heroManaGain).toBe(12);
    expect(
      director.update(
        1,
        createContext({
          tacticalPlanId: "champion_hunt",
          usedAbilityIds: ["rally_banner"],
          elapsedSeconds: 51
        })
      ).transitions
    ).toEqual([]);

    const completed = director.update(
      1,
      createContext({
        tacticalPlanId: "champion_hunt",
        usedAbilityIds: ["rally_banner", "cleave"],
        elapsedSeconds: 52
      })
    ).transitions[0];
    expect(completed.type).toBe("completed");
    expect(completed.resourceBonus).toEqual({ aether: 8 });
  });
});

function createContext(overrides: Partial<BattlefieldEventDirectorContext> & { siteOwner?: "player" | "enemy" | "neutral"; eliteAlive?: boolean } = {}): BattlefieldEventDirectorContext {
  const eliteAlive = overrides.eliteAlive ?? true;
  return {
    elapsedSeconds: overrides.elapsedSeconds ?? 0,
    mode: overrides.mode ?? "campaign_node",
    rewardsDisabled: overrides.rewardsDisabled ?? false,
    missionTypeId: overrides.missionTypeId ?? "control",
    modifierIds: overrides.modifierIds ?? [],
    doctrineId: overrides.doctrineId ?? "raider",
    tacticalPlanId: overrides.tacticalPlanId ?? "guarded_advance",
    captureSites: overrides.captureSites ?? [
      {
        siteId: "crown_shrine",
        name: "Crown Shrine",
        owner: overrides.siteOwner ?? "player",
        position: { x: 420, y: 320 },
        incomeAmount: 22,
        siteLevel: 1,
        workerCount: 1
      }
    ],
    units: overrides.units ?? [
      {
        id: "elite-1",
        unitTypeId: "raider",
        name: "Raider",
        team: "enemy",
        alive: eliteAlive,
        position: { x: 860, y: 540 },
        enemyEliteSquadId: eliteAlive ? "cinder_iron_guard" : undefined,
        enemyEliteSquadName: eliteAlive ? "Cinder Iron Guard" : undefined
      }
    ],
    buildings: overrides.buildings ?? [
      {
        id: "command-hall-1",
        buildingId: "command_hall",
        name: "Command Hall",
        team: "player",
        alive: true,
        position: { x: 240, y: 240 }
      }
    ],
    commandHallAlive: overrides.commandHallAlive ?? true,
    retinueReinforcementAvailable: overrides.retinueReinforcementAvailable ?? false,
    retinueReinforcementUsed: overrides.retinueReinforcementUsed ?? false,
    usedAbilityIds: overrides.usedAbilityIds ?? []
  };
}
