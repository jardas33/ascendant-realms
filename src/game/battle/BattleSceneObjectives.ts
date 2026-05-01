import type {
  BattleMapDefinition,
  BattleSecondaryObjectiveDefinition,
  BattleSecondaryObjectiveType,
  Position
} from "../core/GameTypes";
import type { BattleRuntime } from "./BattleRuntime";

interface CompleteSecondaryObjectiveOptions {
  activeMap: BattleMapDefinition;
  runtime: BattleRuntime;
  type: BattleSecondaryObjectiveType;
  targetId: string;
  point?: Position;
  showMessage: (message: string, x?: number, y?: number, color?: string) => void;
}

export function completeBattleSecondaryObjective(
  options: CompleteSecondaryObjectiveOptions
): BattleSecondaryObjectiveDefinition | undefined {
  const { activeMap, runtime, type, targetId, point, showMessage } = options;
  const objective = activeMap.scenario.objectives.secondaryObjectives?.find(
    (entry) => entry.type === type && entry.targetId === targetId
  );
  if (!objective || !runtime.recordSecondaryObjective(objective.id)) {
    return undefined;
  }
  showMessage(`Objective complete: ${objective.name}`, point?.x, point ? point.y - 78 : undefined, "#f6e27d");
  return objective;
}
