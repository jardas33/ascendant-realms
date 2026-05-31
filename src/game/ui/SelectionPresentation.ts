import type { EntityKind, Team } from "../core/GameTypes";

export interface SelectionRingPresentation {
  strokeColor: number;
  strokeAlpha: number;
  strokeWidth: number;
  fillColor: number;
  fillAlpha: number;
}

export function resolveSelectionRingPresentation(team: Team, kind: EntityKind): SelectionRingPresentation {
  if (team === "enemy") {
    return {
      strokeColor: 0xff8a7d,
      strokeAlpha: 0.96,
      strokeWidth: kind === "building" ? 4 : 3,
      fillColor: 0x451919,
      fillAlpha: 0.16
    };
  }
  if (team === "neutral") {
    return {
      strokeColor: 0xf0d978,
      strokeAlpha: 0.92,
      strokeWidth: 3,
      fillColor: 0x443514,
      fillAlpha: 0.13
    };
  }
  return {
    strokeColor: kind === "hero" ? 0xb8efff : 0x9cf7b1,
    strokeAlpha: 0.95,
    strokeWidth: kind === "hero" ? 4 : 3,
    fillColor: kind === "hero" ? 0x0e3848 : 0x11351f,
    fillAlpha: 0.14
  };
}
