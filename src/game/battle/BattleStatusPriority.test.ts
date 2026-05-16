import { describe, expect, it } from "vitest";
import { battleStatusDurationSeconds, shouldReplaceBattleStatus } from "./BattleStatusPriority";

describe("BattleStatusPriority", () => {
  it("keeps active pressure warnings ahead of normal status messages", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "pressure",
        currentTimerSeconds: 3,
        incomingPriority: "normal"
      })
    ).toBe(false);
  });

  it("allows pressure messages to replace normal status messages", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "normal",
        currentTimerSeconds: 2,
        incomingPriority: "pressure"
      })
    ).toBe(true);
  });

  it("lets command acknowledgements replace routine normal messages", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "normal",
        currentTimerSeconds: 2,
        incomingPriority: "command"
      })
    ).toBe(true);
  });

  it("keeps active pressure warnings ahead of command acknowledgements", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "pressure",
        currentTimerSeconds: 3,
        incomingPriority: "command"
      })
    ).toBe(false);
  });

  it("lets objective feedback replace active pressure warnings", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "pressure",
        currentTimerSeconds: 4,
        incomingPriority: "objective"
      })
    ).toBe(true);
  });

  it("allows normal status after the active timer expires", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "pressure",
        currentTimerSeconds: 0,
        incomingPriority: "normal"
      })
    ).toBe(true);
  });

  it("gives pressure warnings a longer status-line read window", () => {
    expect(battleStatusDurationSeconds("pressure")).toBeGreaterThan(battleStatusDurationSeconds("normal"));
  });

  it("gives command acknowledgements a longer read window than routine messages", () => {
    expect(battleStatusDurationSeconds("command")).toBeGreaterThan(battleStatusDurationSeconds("normal"));
    expect(battleStatusDurationSeconds("command")).toBeLessThan(battleStatusDurationSeconds("pressure"));
  });
});
