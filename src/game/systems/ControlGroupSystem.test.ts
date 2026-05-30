import { describe, expect, it } from "vitest";
import type { Unit } from "../entities/Unit";
import { createUnitVeterancyState } from "../data/unitVeterancy";
import { ControlGroupSystem } from "./ControlGroupSystem";

describe("ControlGroupSystem", () => {
  it("assigns and recalls living player units", () => {
    const system = new ControlGroupSystem();
    const militia = fakeUnit("militia-1");
    const ranger = fakeUnit("ranger-1");

    expect(system.assign(1, [militia, ranger])).toMatchObject({
      slot: 1,
      count: 2,
      handled: true,
      message: "Group 1 assigned: 2 units"
    });

    expect(system.recall(1, [militia, ranger])).toMatchObject({
      slot: 1,
      count: 2,
      handled: true,
      units: [militia, ranger],
      message: "Group 1 selected: 2 units"
    });
  });

  it("filters enemies, buildings masquerading in tests, and dead members", () => {
    const system = new ControlGroupSystem();
    const hero = fakeUnit("hero-player", { kind: "hero" });
    const dead = fakeUnit("dead", { alive: false });
    const enemy = fakeUnit("enemy", { team: "enemy" });
    const building = fakeUnit("barracks", { kind: "building" });

    expect(system.assign(2, [hero, dead, enemy, building])).toMatchObject({
      count: 1,
      message: "Group 2 assigned: 1 unit"
    });

    hero.alive = false;
    const recalled = system.recall(2, [hero]);
    expect(recalled).toMatchObject({
      count: 0,
      handled: true,
      units: [],
      message: "Group 2 is empty"
    });
    expect(system.summaries([hero])).toEqual([]);
  });

  it("recalls veteran units without stripping their battle rank state", () => {
    const system = new ControlGroupSystem();
    const militia = fakeUnit("militia-veteran", {
      veterancy: {
        ...createUnitVeterancyState("militia-veteran", "militia", 140),
        kills: 2
      }
    });

    system.assign(1, [militia]);
    const recalled = system.recall(1, [militia]);

    expect(recalled.units[0]).toBe(militia);
    expect(recalled.units[0].veterancy).toMatchObject({
      rank: "veteran",
      xp: 140,
      kills: 2
    });
  });


  it("leaves unknown slots unhandled so ability hotkeys can keep working", () => {
    const system = new ControlGroupSystem();

    expect(system.recall(3, [])).toMatchObject({
      handled: false,
      count: 0,
      message: "Group 3 is empty"
    });
  });
});

function fakeUnit(
  id: string,
  options: {
    alive?: boolean;
    team?: "player" | "enemy";
    kind?: "unit" | "hero" | "building";
    veterancy?: Unit["veterancy"];
  } = {}
): Unit {
  return {
    id,
    alive: options.alive ?? true,
    team: options.team ?? "player",
    kind: options.kind ?? "unit",
    veterancy: options.veterancy
  } as unknown as Unit;
}
