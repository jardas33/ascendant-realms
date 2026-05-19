import { describe, expect, it } from "vitest";
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
  });
});
