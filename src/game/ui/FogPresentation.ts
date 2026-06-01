import type { VisibilityState } from "../core/GameTypes";

export interface FogCellPresentation {
  fillColor: number;
  fillColorCss: string;
  fillAlpha: number;
  strokeColor: number;
  strokeAlpha: number;
  cornerRadius: number;
}

export function resolveFogCellPresentation(state: Exclude<VisibilityState, "visible">): FogCellPresentation {
  if (state === "unseen") {
    return {
      fillColor: 0x020503,
      fillColorCss: "#020503",
      fillAlpha: 0.7,
      strokeColor: 0x0c1712,
      strokeAlpha: 0.08,
      cornerRadius: 14
    };
  }
  return {
    fillColor: 0x07120f,
    fillColorCss: "#07120f",
    fillAlpha: 0.28,
    strokeColor: 0x1c3028,
    strokeAlpha: 0.06,
    cornerRadius: 12
  };
}
