import { describe, expect, it } from "vitest";
import { resolveFogCellPresentation } from "./FogPresentation";

describe("resolveFogCellPresentation", () => {
  it("keeps unexplored fog darker than explored fog", () => {
    const unseen = resolveFogCellPresentation("unseen");
    const explored = resolveFogCellPresentation("explored");

    expect(unseen.fillAlpha).toBeGreaterThan(explored.fillAlpha);
    expect(unseen.fillColorCss).not.toBe(explored.fillColorCss);
    expect(explored.strokeAlpha).toBeGreaterThan(0);
  });
});
