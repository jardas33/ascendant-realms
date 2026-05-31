import { describe, expect, it } from "vitest";
import {
  battleStatusCategory,
  battleStatusDedupeSeconds,
  battleStatusDurationSeconds,
  formatBattleStatusMessage,
  shouldDisplayBattleStatus,
  shouldReplaceBattleStatus
} from "./BattleStatusPriority";

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

  it("keeps active pressure warnings ahead of objective feedback", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "pressure",
        currentTimerSeconds: 4,
        incomingPriority: "objective"
      })
    ).toBe(false);
  });

  it("lets pressure warnings replace active objective feedback", () => {
    expect(
      shouldReplaceBattleStatus({
        currentPriority: "objective",
        currentTimerSeconds: 4,
        incomingPriority: "pressure"
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

  it("maps legacy priorities into v0.86 notification categories", () => {
    expect(battleStatusCategory("pressure")).toBe("critical");
    expect(battleStatusCategory("objective")).toBe("important");
    expect(battleStatusCategory("command")).toBe("routine");
    expect(battleStatusCategory("debug")).toBe("debug");
  });

  it("keeps debug messages hidden unless explicitly enabled", () => {
    expect(shouldDisplayBattleStatus("debug")).toBe(false);
    expect(shouldDisplayBattleStatus("debug", true)).toBe(true);
  });

  it("shortens routine command confirmations and dedupes routine chatter", () => {
    expect(formatBattleStatusMessage("Move order accepted: 3 units", "command")).toBe("Move: 3 units");
    expect(formatBattleStatusMessage("Your Command Hall is under attack.", "pressure")).toBe("Your Command Hall is under attack.");
    expect(battleStatusDedupeSeconds("command")).toBeGreaterThan(0);
    expect(battleStatusDedupeSeconds("pressure")).toBe(0);
  });
});
