export const BEHAVIOUR_MODE_IDS = ["hold_ground", "guard_area", "press_attack"] as const;

export type BehaviourMode = (typeof BEHAVIOUR_MODE_IDS)[number];

export interface BehaviourModeDefinition {
  id: BehaviourMode;
  label: string;
  shortLabel: string;
  description: string;
  orderDetail: string;
}

export const DEFAULT_BEHAVIOUR_MODE: BehaviourMode = "guard_area";

export const BEHAVIOUR_MODE_DEFINITIONS: BehaviourModeDefinition[] = [
  {
    id: "hold_ground",
    label: "Hold Ground",
    shortLabel: "Hold",
    description: "Stay near the current point. Attack enemies in immediate reach or enemies directly attacking this unit.",
    orderDetail: "Staying put; attacks only immediate threats or direct attackers."
  },
  {
    id: "guard_area",
    label: "Guard Area",
    shortLabel: "Guard",
    description: "Balanced default. Defend the nearby area and respond to close threats.",
    orderDetail: "Defending nearby space and responding to close threats."
  },
  {
    id: "press_attack",
    label: "Press Attack",
    shortLabel: "Press",
    description: "More assertive pursuit within a local leash. Explicit move and attack orders still take priority.",
    orderDetail: "Looking for nearby enemies more assertively within a local leash."
  }
];

const BEHAVIOUR_MODE_BY_ID = new Map(BEHAVIOUR_MODE_DEFINITIONS.map((definition) => [definition.id, definition]));

export interface BehaviourModeOwner {
  behaviourMode?: BehaviourMode;
}

export function isBehaviourMode(value: string | undefined): value is BehaviourMode {
  return BEHAVIOUR_MODE_IDS.includes(value as BehaviourMode);
}

export function normalizeBehaviourMode(value: string | undefined): BehaviourMode {
  return isBehaviourMode(value) ? value : DEFAULT_BEHAVIOUR_MODE;
}

export function behaviourModeDefinition(mode: string | undefined): BehaviourModeDefinition {
  return BEHAVIOUR_MODE_BY_ID.get(normalizeBehaviourMode(mode)) ?? BEHAVIOUR_MODE_BY_ID.get(DEFAULT_BEHAVIOUR_MODE)!;
}

export function setBehaviourMode(units: BehaviourModeOwner[], mode: BehaviourMode): number {
  units.forEach((unit) => {
    unit.behaviourMode = mode;
  });
  return units.length;
}

export function summarizeBehaviourModes(units: BehaviourModeOwner[]): { label: string; mixed: boolean; mode?: BehaviourMode } {
  const modes = new Set(units.map((unit) => normalizeBehaviourMode(unit.behaviourMode)));
  if (modes.size === 0) {
    return { label: "None", mixed: false };
  }
  if (modes.size > 1) {
    return { label: "Mixed", mixed: true };
  }
  const [mode] = [...modes];
  return { label: behaviourModeDefinition(mode).label, mixed: false, mode };
}
