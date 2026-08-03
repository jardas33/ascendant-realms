import { describe, expect, it } from "vitest";
import { resolveFogCellPresentation } from "./FogPresentation";

describe("resolveFogCellPresentation", () => {
  it("keeps the two non-visible styles distinct and ordered", () => {
    const unseen = resolveFogCellPresentation("unseen");
    const explored = resolveFogCellPresentation("explored");

    expect(unseen.fillAlpha).toBeGreaterThan(explored.fillAlpha);
    expect(unseen.fillColorCss).not.toBe(explored.fillColorCss);
    expect(unseen.strokeAlpha).toBeGreaterThan(explored.strokeAlpha);
    expect(unseen.fillColor).toBe(0x0d1c14);
    expect(unseen.fillColorCss).toBe("#0d1c14");
    expect(unseen.fillAlpha).toBe(0.32);
    expect(unseen.strokeColor).toBe(0x0c1712);
    expect(unseen.strokeAlpha).toBe(0.02);
    expect(unseen.cornerRadius).toBe(14);
    expect(explored.fillColor).toBe(0x163024);
    expect(explored.fillColorCss).toBe("#163024");
    expect(explored.fillAlpha).toBe(0.1);
    expect(explored.strokeColor).toBe(0x1c3028);
    expect(explored.strokeAlpha).toBe(0.015);
    expect(explored.cornerRadius).toBe(12);
  });

  it("is deterministic and does not expose a covering visible style", () => {
    expect(resolveFogCellPresentation("unseen")).toEqual(resolveFogCellPresentation("unseen"));
    expect(resolveFogCellPresentation("explored")).toEqual(resolveFogCellPresentation("explored"));
    expect(Object.keys(resolveFogCellPresentation("unseen")).sort()).toEqual([
      "cornerRadius",
      "fillAlpha",
      "fillColor",
      "fillColorCss",
      "strokeAlpha",
      "strokeColor"
    ]);
  });
});
