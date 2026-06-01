import type { Position } from "../core/GameTypes";

export type CommandFeedbackMarkerKind =
  | "move"
  | "attack-move"
  | "attack"
  | "patrol"
  | "rally"
  | "build"
  | "ability"
  | "invalid"
  | "focus";

export interface CommandFeedbackMarkerEvent {
  kind: CommandFeedbackMarkerKind;
  point: Position;
  origin?: Position;
  label?: string;
  count?: number;
}

export interface CommandFeedbackMarkerPresentation {
  kind: CommandFeedbackMarkerKind;
  label: string;
  strokeColor: number;
  fillColor: number;
  textColor: string;
  radius: number;
  strokeWidth: number;
  durationMs: number;
  shape: "ring" | "hostile" | "route" | "banner" | "square" | "spark" | "cross" | "focus";
}

const BASE_PRESENTATIONS: Record<
  CommandFeedbackMarkerKind,
  Omit<CommandFeedbackMarkerPresentation, "kind" | "label" | "durationMs">
> = {
  move: {
    strokeColor: 0x9cf7b1,
    fillColor: 0x14351f,
    textColor: "#b9f7c7",
    radius: 15,
    strokeWidth: 3,
    shape: "ring"
  },
  "attack-move": {
    strokeColor: 0xf0d978,
    fillColor: 0x3b2f10,
    textColor: "#f6edb4",
    radius: 16,
    strokeWidth: 3,
    shape: "hostile"
  },
  attack: {
    strokeColor: 0xff8a7d,
    fillColor: 0x451919,
    textColor: "#ffb1a9",
    radius: 17,
    strokeWidth: 3,
    shape: "hostile"
  },
  patrol: {
    strokeColor: 0x74d3f2,
    fillColor: 0x0e3848,
    textColor: "#aee6f7",
    radius: 15,
    strokeWidth: 3,
    shape: "route"
  },
  rally: {
    strokeColor: 0xb9f7c7,
    fillColor: 0x14351f,
    textColor: "#d9eee8",
    radius: 15,
    strokeWidth: 3,
    shape: "banner"
  },
  build: {
    strokeColor: 0xf6edb4,
    fillColor: 0x443514,
    textColor: "#f6edb4",
    radius: 18,
    strokeWidth: 3,
    shape: "square"
  },
  ability: {
    strokeColor: 0xc9b9ff,
    fillColor: 0x211b43,
    textColor: "#dfd7ff",
    radius: 18,
    strokeWidth: 3,
    shape: "spark"
  },
  invalid: {
    strokeColor: 0xff9b90,
    fillColor: 0x4a1613,
    textColor: "#ffb1a9",
    radius: 16,
    strokeWidth: 4,
    shape: "cross"
  },
  focus: {
    strokeColor: 0x74d3f2,
    fillColor: 0x0e3848,
    textColor: "#aee6f7",
    radius: 18,
    strokeWidth: 3,
    shape: "focus"
  }
};

export function commandFeedbackMarkerPresentation(
  event: Pick<CommandFeedbackMarkerEvent, "kind" | "label" | "count">,
  options: { reducedMotion?: boolean } = {}
): CommandFeedbackMarkerPresentation {
  const base = BASE_PRESENTATIONS[event.kind];
  return {
    ...base,
    kind: event.kind,
    label: event.label ?? defaultCommandFeedbackMarkerLabel(event.kind, event.count),
    durationMs: options.reducedMotion ? 650 : 950
  };
}

export function defaultCommandFeedbackMarkerLabel(kind: CommandFeedbackMarkerKind, count = 1): string {
  switch (kind) {
    case "move":
      return count > 1 ? "Group Move" : "Move";
    case "attack-move":
      return count > 1 ? "Group Attack-Move" : "Attack-Move";
    case "attack":
      return "Attack";
    case "patrol":
      return "Patrol";
    case "rally":
      return "Rally";
    case "build":
      return "Build";
    case "ability":
      return "Ability";
    case "invalid":
      return "Invalid";
    case "focus":
      return "Focus";
  }
}
