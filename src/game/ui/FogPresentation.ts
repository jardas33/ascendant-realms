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
      fillAlpha: 0.76,
      strokeColor: 0x102018,
      strokeAlpha: 0.16,
      cornerRadius: 10
    };
  }
  return {
    fillColor: 0x07120f,
    fillColorCss: "#07120f",
    fillAlpha: 0.34,
    strokeColor: 0x1c3028,
    strokeAlpha: 0.12,
    cornerRadius: 8
  };
}
