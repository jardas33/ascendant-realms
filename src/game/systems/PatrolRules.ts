import type { Unit } from "../entities/Unit";

export function isPatrolEligibleUnit(unit: Unit): boolean {
  return (
    unit.alive &&
    unit.team === "player" &&
    (unit.kind === "unit" || unit.kind === "hero") &&
    unit.definition.id !== "worker" &&
    unit.definition.stats.damage > 0
  );
}

export function patrolEligibilityMessage(selectedUnits: readonly Unit[]): string {
  if (selectedUnits.length === 0) {
    return "Select combat units to Patrol.";
  }
  return selectedUnits.some(isPatrolEligibleUnit)
    ? "Patrol: click a destination"
    : "Patrol needs combat units; Workers keep build, repair, and site duties.";
}
