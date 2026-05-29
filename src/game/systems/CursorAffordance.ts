import type { EntityKind, Team } from "../core/GameTypes";

export type BattleCursorIntent = "" | "attack" | "build" | "repair" | "assign" | "invalid";

interface CursorUnit {
  id: string;
  alive: boolean;
  team: Team;
  definition: {
    id: string;
    buildOptions?: readonly string[];
  };
}

interface CursorEntity {
  alive: boolean;
  kind: EntityKind;
  team: Team;
  hp?: number;
  maxHp?: number;
  owner?: Team;
  siteLevel?: number;
  workerAssignments?: readonly unknown[];
  definition?: {
    id: string;
  };
  isCompleted?: () => boolean;
  isUnderConstruction?: () => boolean;
  hasWorkerAssignment?: (workerId: string) => boolean;
}

export interface BattleCursorView {
  intent: BattleCursorIntent;
  cursor: string;
  label: string;
}

export function deriveBattleCursorIntent(
  target: CursorEntity | undefined,
  selectedUnits: readonly CursorUnit[]
): BattleCursorIntent {
  if (!target?.alive) {
    return "";
  }

  const activeSelectedUnits = selectedUnits.filter((unit) => unit.alive && unit.team === "player");
  if (isHostileAttackTarget(target) && activeSelectedUnits.length > 0) {
    return "attack";
  }

  const worker = activeSelectedUnits.find(isWorkerUnit);
  if (!worker) {
    return "";
  }

  if (isFriendlyBuildingTarget(target)) {
    if (target.isUnderConstruction?.()) {
      return worker.definition.buildOptions?.includes(target.definition?.id ?? "") ? "build" : "invalid";
    }
    if (target.isCompleted?.()) {
      return (target.hp ?? 0) < (target.maxHp ?? 0) ? "repair" : "invalid";
    }
  }

  if (target.kind === "capture-site") {
    if (target.owner === "player") {
      const assignedToWorker = target.hasWorkerAssignment?.(worker.id) ?? false;
      const workerCount = target.workerAssignments?.length ?? 0;
      return assignedToWorker || workerCount < workerSlotCapacity(target) ? "assign" : "invalid";
    }
    return "invalid";
  }

  return "";
}

export function battleCursorView(intent: BattleCursorIntent): BattleCursorView {
  return {
    intent,
    cursor: cursorStyleForIntent(intent),
    label: cursorLabelForIntent(intent)
  };
}

export function cursorStyleForIntent(intent: BattleCursorIntent): string {
  if (intent === "attack") {
    return "crosshair";
  }
  if (intent === "build" || intent === "repair") {
    return "copy";
  }
  if (intent === "assign") {
    return "alias";
  }
  if (intent === "invalid") {
    return "not-allowed";
  }
  return "";
}

export function cursorLabelForIntent(intent: BattleCursorIntent): string {
  if (intent === "attack") {
    return "Attack target";
  }
  if (intent === "build") {
    return "Build or continue construction";
  }
  if (intent === "repair") {
    return "Repair damaged building";
  }
  if (intent === "assign") {
    return "Assign Worker to resource site";
  }
  if (intent === "invalid") {
    return "Invalid target";
  }
  return "";
}

function isHostileAttackTarget(target: CursorEntity): boolean {
  return target.kind !== "capture-site" && target.team !== "player";
}

function isFriendlyBuildingTarget(target: CursorEntity): boolean {
  return target.kind === "building" && target.team === "player";
}

function isWorkerUnit(unit: CursorUnit): boolean {
  return unit.definition.id === "worker";
}

function workerSlotCapacity(target: CursorEntity): number {
  return (target.siteLevel ?? 1) >= 2 ? 2 : 1;
}
