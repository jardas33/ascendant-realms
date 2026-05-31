import type { Team } from "../core/GameTypes";

export type CaptureSiteVisualState = "selected" | "contested" | "friendly" | "enemy" | "neutral" | "objective";

export interface CaptureSitePresentationOptions {
  owner: Team;
  capturingTeam: Team;
  captureProgress: number;
  selected?: boolean;
  objectiveRelevant?: boolean;
  resourceColor: number;
}

export interface CaptureSitePresentation {
  state: CaptureSiteVisualState;
  labelPrefix: string;
  labelColor: string;
  labelBackground: string;
  ringColor: number;
  ringAlpha: number;
  ringWidth: number;
  progressColor: number;
}

export function resolveCaptureSitePresentation(options: CaptureSitePresentationOptions): CaptureSitePresentation {
  const contested =
    options.captureProgress > 0 &&
    options.captureProgress < 1 &&
    options.capturingTeam !== "neutral" &&
    options.capturingTeam !== options.owner;
  if (options.selected) {
    return {
      state: "selected",
      labelPrefix: "SELECTED",
      labelColor: "#fff4b3",
      labelBackground: "rgba(40, 34, 14, 0.88)",
      ringColor: 0xffdf7a,
      ringAlpha: 1,
      ringWidth: 6,
      progressColor: 0xffdf7a
    };
  }
  if (contested) {
    return {
      state: "contested",
      labelPrefix: "CONTESTED",
      labelColor: "#ffe08a",
      labelBackground: "rgba(51, 31, 8, 0.9)",
      ringColor: 0xffb84a,
      ringAlpha: 1,
      ringWidth: 5,
      progressColor: 0xffc966
    };
  }
  if (options.objectiveRelevant) {
    return {
      state: "objective",
      labelPrefix: "OBJECTIVE",
      labelColor: "#b8efff",
      labelBackground: "rgba(10, 34, 44, 0.88)",
      ringColor: 0x74d3f2,
      ringAlpha: 0.95,
      ringWidth: 5,
      progressColor: 0x74d3f2
    };
  }
  if (options.owner === "player") {
    return {
      state: "friendly",
      labelPrefix: "HELD",
      labelColor: "#c9ffd2",
      labelBackground: "rgba(9, 43, 21, 0.86)",
      ringColor: 0x7de087,
      ringAlpha: 0.96,
      ringWidth: 4,
      progressColor: 0xaef7b7
    };
  }
  if (options.owner === "enemy") {
    return {
      state: "enemy",
      labelPrefix: "ENEMY",
      labelColor: "#ffc0ba",
      labelBackground: "rgba(55, 13, 13, 0.88)",
      ringColor: 0xe15e55,
      ringAlpha: 0.98,
      ringWidth: 4,
      progressColor: 0xff9a64
    };
  }
  return {
    state: "neutral",
    labelPrefix: "NEUTRAL",
    labelColor: "#fff1bc",
    labelBackground: "rgba(40, 34, 20, 0.82)",
    ringColor: options.resourceColor,
    ringAlpha: 0.92,
    ringWidth: 4,
    progressColor: 0xf3e7a3
  };
}
