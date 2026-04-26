import { Building } from "../entities/Building";
import { Hero } from "../entities/Hero";
import { Unit } from "../entities/Unit";

export function selectionTitle(selection: Array<Unit | Building>): string {
  if (selection.length === 0) {
    return "No Selection";
  }
  if (selection.length > 1) {
    return `${selection.length} units selected`;
  }
  const selected = selection[0];
  if (selected instanceof Hero) {
    return `${selected.heroName}, Level ${selected.level}`;
  }
  if (selected instanceof Unit) {
    return selected.definition.name;
  }
  return selected.definition.name;
}
