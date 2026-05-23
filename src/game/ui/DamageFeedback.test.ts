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

  it("marks incoming player damage as a more readable hit", () => {
    expect(createDamageFeedbackView("player", 12)).toEqual({
      text: "HIT -12",
      color: "#ff5f67",
      yOffset: -12
    });
  });

  it("honors the normal direct-damage threshold and status-tick override", () => {
    expect(createDamageFeedbackView("player", 3)).toBeUndefined();
    expect(createDamageFeedbackView("player", 3, { threshold: 1 })?.text).toBe("HIT -3");
  });
});
