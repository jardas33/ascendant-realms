import { describe, expect, it } from "vitest";
import { createDamageFeedbackView } from "./DamageFeedback";

describe("DamageFeedback", () => {
  it("keeps outgoing damage compact for hostile targets", () => {
    expect(createDamageFeedbackView("enemy", 12)).toEqual({
      text: "-12",
      color: "#ffb1a9",
      yOffset: 0
    });
  });

  it("keeps incoming player damage compact but visually distinct", () => {
    expect(createDamageFeedbackView("player", 12)).toEqual({
      text: "-12",
      color: "#ff5f67",
      yOffset: -12
    });
  });

  it("shows small incoming player hits while preserving the normal hostile-target threshold", () => {
    expect(createDamageFeedbackView("player", 4)?.text).toBe("-4");
    expect(createDamageFeedbackView("enemy", 4)).toBeUndefined();
    expect(createDamageFeedbackView("enemy", 4, { threshold: 1 })?.text).toBe("-4");
  });
});
