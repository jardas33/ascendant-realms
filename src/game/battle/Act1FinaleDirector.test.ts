import { describe, expect, it } from "vitest";
import { Act1FinaleDirector, type Act1FinaleDirectorContext } from "./Act1FinaleDirector";

describe("Act1FinaleDirector", () => {
  it("progresses through the three Ashen Outpost finale phases deterministically", () => {
    const director = new Act1FinaleDirector();
    const started = director.update(context());

    expect(started.transitions.map((transition) => transition.type)).toEqual(["phase_started"]);
    expect(started.activePhase?.id).toBe("secure_foothold");

    const foothold = director.update(context({ completedObjectiveIds: ["capture_burned_shrine"], resourcesCaptured: 1 }));
    expect(foothold.transitions.map((transition) => transition.type)).toEqual(["phase_completed", "phase_started"]);
    expect(foothold.transitions[0].eventIds).toEqual(["site_under_threat", "hold_the_line"]);
    expect(foothold.activePhase?.id).toBe("break_fortified_line");

    const fortified = director.update(
      context({
        completedObjectiveIds: ["capture_burned_shrine", "destroy_enemy_barracks"],
        resourcesCaptured: 1,
        enemyProductionAlive: false
      })
    );
    expect(fortified.transitions.map((transition) => transition.type)).toEqual([
      "phase_completed",
      "commander_released",
      "phase_started"
    ]);
    expect(director.isCommanderReleased).toBe(true);
    expect(fortified.activePhase?.id).toBe("defeat_rival_commander");

    const commander = director.update(
      context({
        completedObjectiveIds: ["capture_burned_shrine", "destroy_enemy_barracks"],
        resourcesCaptured: 1,
        enemyProductionAlive: false,
        enemyCommanderDefeated: true
      })
    );
    expect(commander.transitions.map((transition) => transition.type)).toEqual(["phase_completed", "finale_completed"]);
    expect(director.isCompleted).toBe(true);
  });

  it("marks tactical plan support only for the matching phase", () => {
    const director = new Act1FinaleDirector();

    const started = director.update(context({ tacticalPlanId: "champion_hunt" }));
    expect(started.transitions[0].planMatched).toBe(false);

    director.update(context({ completedObjectiveIds: ["capture_burned_shrine"], resourcesCaptured: 1 }));
    const fortified = director.update(
      context({
        tacticalPlanId: "champion_hunt",
        completedObjectiveIds: ["capture_burned_shrine", "destroy_enemy_barracks"],
        resourcesCaptured: 1,
        enemyProductionAlive: false
      })
    );

    const commanderRelease = fortified.transitions.find((transition) => transition.type === "commander_released");
    const finalPhaseStart = fortified.transitions.find((transition) => transition.type === "phase_started");
    expect(commanderRelease?.planMatched).toBe(true);
    expect(finalPhaseStart?.planMatched).toBe(true);
  });
});

function context(overrides: Partial<Act1FinaleDirectorContext> = {}): Act1FinaleDirectorContext {
  return {
    elapsedSeconds: 120,
    completedObjectiveIds: [],
    resourcesCaptured: 0,
    playerOwnedSiteCount: 0,
    enemyProductionAlive: true,
    enemyCommanderAlive: true,
    enemyCommanderDefeated: false,
    ...overrides
  };
}
