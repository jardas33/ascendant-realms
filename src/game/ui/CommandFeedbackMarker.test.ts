import { describe, expect, it } from "vitest";
import { commandFeedbackMarkerPresentation, defaultCommandFeedbackMarkerLabel } from "./CommandFeedbackMarker";

describe("CommandFeedbackMarker", () => {
  it("labels existing command intents without requiring art assets", () => {
    expect(defaultCommandFeedbackMarkerLabel("move", 3)).toBe("Group Move");
    expect(defaultCommandFeedbackMarkerLabel("attack-move", 1)).toBe("Attack-Move");
    expect(defaultCommandFeedbackMarkerLabel("attack", 4)).toBe("Attack");
    expect(defaultCommandFeedbackMarkerLabel("patrol", 2)).toBe("Patrol");
    expect(defaultCommandFeedbackMarkerLabel("rally", 1)).toBe("Rally");
    expect(defaultCommandFeedbackMarkerLabel("build", 1)).toBe("Build");
    expect(defaultCommandFeedbackMarkerLabel("invalid", 1)).toBe("Invalid");
  });

  it("uses a shorter non-tween duration when reduced motion is enabled", () => {
    const normal = commandFeedbackMarkerPresentation({ kind: "move", count: 1 });
    const reduced = commandFeedbackMarkerPresentation({ kind: "move", count: 1 }, { reducedMotion: true });

    expect(normal.durationMs).toBeGreaterThan(reduced.durationMs);
    expect(reduced.durationMs).toBe(650);
  });

  it("keeps marker styles distinct for hostile, build, patrol, and focus feedback", () => {
    expect(commandFeedbackMarkerPresentation({ kind: "attack" }).shape).toBe("hostile");
    expect(commandFeedbackMarkerPresentation({ kind: "build" }).shape).toBe("square");
    expect(commandFeedbackMarkerPresentation({ kind: "patrol" }).shape).toBe("route");
    expect(commandFeedbackMarkerPresentation({ kind: "focus" }).shape).toBe("focus");
  });
});
