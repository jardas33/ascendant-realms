import { describe, expect, it, vi } from "vitest";
import {
  DEFAULT_BEHAVIOUR_MODE,
  behaviourModeDefinition,
  normalizeBehaviourMode,
  setBehaviourMode,
  summarizeBehaviourModes
} from "./BehaviourModeSystem";

describe("BehaviourModeSystem", () => {
  it("normalizes invalid or missing modes to Guard Area", () => {
    expect(normalizeBehaviourMode(undefined)).toBe(DEFAULT_BEHAVIOUR_MODE);
    expect(normalizeBehaviourMode("patrol")).toBe(DEFAULT_BEHAVIOUR_MODE);
    expect(behaviourModeDefinition("hold_ground").label).toBe("Hold Ground");
  });

  it("applies a behaviour mode to selected units as session-only state", () => {
    const units = [{ behaviourMode: "guard_area" as const }, { behaviourMode: "guard_area" as const }];

    expect(setBehaviourMode(units, "press_attack")).toBe(2);
    expect(units.map((unit) => unit.behaviourMode)).toEqual(["press_attack", "press_attack"]);
  });

  it("cancels patrol routes when an explicit behaviour mode is chosen", () => {
    const units = [
      { behaviourMode: "guard_area" as const, clearPatrolRoute: vi.fn() },
      { behaviourMode: "guard_area" as const, clearPatrolRoute: vi.fn() }
    ];

    expect(setBehaviourMode(units, "hold_ground")).toBe(2);
    expect(units[0].clearPatrolRoute).toHaveBeenCalledTimes(1);
    expect(units[1].clearPatrolRoute).toHaveBeenCalledTimes(1);
  });

  it("applies a group command without requiring persisted unit data", () => {
    const units: Array<{ behaviourMode?: "hold_ground" | "guard_area" | "press_attack" }> = [
      {},
      { behaviourMode: "hold_ground" },
      { behaviourMode: "press_attack" }
    ];

    expect(summarizeBehaviourModes(units)).toMatchObject({ label: "Mixed", mixed: true });
    expect(setBehaviourMode(units, "guard_area")).toBe(3);
    expect(summarizeBehaviourModes(units)).toMatchObject({
      label: "Guard Area",
      mixed: false,
      mode: "guard_area"
    });
  });

  it("summarizes homogeneous and mixed selected groups", () => {
    expect(summarizeBehaviourModes([{ behaviourMode: "hold_ground" }, { behaviourMode: "hold_ground" }])).toMatchObject({
      label: "Hold Ground",
      mixed: false,
      mode: "hold_ground"
    });
    expect(summarizeBehaviourModes([{ behaviourMode: "hold_ground" }, { behaviourMode: "press_attack" }])).toMatchObject({
      label: "Mixed",
      mixed: true
    });
    expect(summarizeBehaviourModes([])).toMatchObject({
      label: "None",
      mixed: false
    });
  });
});
