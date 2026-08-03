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
      fillColor: 0x0d1c14,
      fillColorCss: "#0d1c14",
      fillAlpha: 0.32,
      strokeColor: 0x0c1712,
      strokeAlpha: 0.02,
      cornerRadius: 14
    };
  }
  return {
    fillColor: 0x163024,
    fillColorCss: "#163024",
    fillAlpha: 0.1,
    strokeColor: 0x1c3028,
    strokeAlpha: 0.015,
    cornerRadius: 12
  };
}
