import { Unit } from "../entities/Unit";

export const CONTROL_GROUP_SLOTS = [1, 2, 3, 4, 5] as const;

export type ControlGroupSlot = (typeof CONTROL_GROUP_SLOTS)[number];

export interface ControlGroupActionResult {
  slot: ControlGroupSlot;
  count: number;
  handled: boolean;
  message: string;
}

export interface ControlGroupRecallResult extends ControlGroupActionResult {
  units: Unit[];
}

export interface ControlGroupSummary {
  slot: ControlGroupSlot;
  count: number;
}

export class ControlGroupSystem {
  private readonly groups = new Map<ControlGroupSlot, string[]>();

  assign(slot: ControlGroupSlot, selectedUnits: Unit[]): ControlGroupActionResult {
    const ids = this.validUnits(selectedUnits).map((unit) => unit.id);
    this.groups.set(slot, ids);
    return {
      slot,
      count: ids.length,
      handled: true,
      message: ids.length > 0 ? `Group ${slot} assigned: ${ids.length} ${ids.length === 1 ? "unit" : "units"}` : `Group ${slot} cleared`
    };
  }

  recall(slot: ControlGroupSlot, availableUnits: Unit[]): ControlGroupRecallResult {
    const hadGroup = this.groups.has(slot);
    const units = this.cleanGroup(slot, availableUnits);
    return {
      slot,
      count: units.length,
      handled: hadGroup,
      units,
      message:
        units.length > 0
          ? `Group ${slot} selected: ${units.length} ${units.length === 1 ? "unit" : "units"}`
          : `Group ${slot} is empty`
    };
  }

  summaries(availableUnits: Unit[]): ControlGroupSummary[] {
    return CONTROL_GROUP_SLOTS.flatMap((slot) => {
      const units = this.cleanGroup(slot, availableUnits);
      return units.length > 0 ? [{ slot, count: units.length }] : [];
    });
  }

  private cleanGroup(slot: ControlGroupSlot, availableUnits: Unit[]): Unit[] {
    const ids = this.groups.get(slot);
    if (!ids) {
      return [];
    }
    const livingById = new Map(this.validUnits(availableUnits).map((unit) => [unit.id, unit]));
    const units = ids.flatMap((id) => {
      const unit = livingById.get(id);
      return unit ? [unit] : [];
    });
    this.groups.set(slot, units.map((unit) => unit.id));
    return units;
  }

  private validUnits(units: Unit[]): Unit[] {
    return units.filter((unit) => unit.alive && unit.team === "player" && (unit.kind === "unit" || unit.kind === "hero"));
  }
}
