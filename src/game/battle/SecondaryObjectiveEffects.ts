import type { Position, Team } from "../core/GameTypes";

export interface SecondaryObjectiveEffectBuilding {
  id: string;
  team: Team;
  alive: boolean;
  hp: number;
  maxHp: number;
  position: Position;
  definition: {
    id: string;
    name: string;
  };
  updateHealthBar?: () => void;
}

export interface SecondaryObjectiveBattleEffectResult {
  affectedBuildingId: string;
  message: string;
  point: Position;
  damageApplied: number;
}

const ASHEN_GATE_WATCHTOWER_POSITION: Position = { x: 2040, y: 570 };
const ASHEN_SHRINE_WATCHTOWER_DAMAGE_RATIO = 0.45;

export function applySecondaryObjectiveBattleEffect(options: {
  mapId: string;
  objectiveId: string;
  buildings: SecondaryObjectiveEffectBuilding[];
}): SecondaryObjectiveBattleEffectResult | undefined {
  if (options.mapId !== "ashen_outpost" || options.objectiveId !== "capture_burned_shrine") {
    return undefined;
  }

  const watchtower = findAshenGateWatchtower(options.buildings);
  if (!watchtower) {
    return undefined;
  }

  const before = watchtower.hp;
  const damage = Math.ceil(watchtower.maxHp * ASHEN_SHRINE_WATCHTOWER_DAMAGE_RATIO);
  watchtower.hp = Math.max(1, watchtower.hp - damage);
  watchtower.updateHealthBar?.();
  const damageApplied = before - watchtower.hp;
  if (damageApplied <= 0) {
    return undefined;
  }

  return {
    affectedBuildingId: watchtower.id,
    message: "Burned Shrine weakens the gate Watchtower.",
    point: watchtower.position,
    damageApplied
  };
}

function findAshenGateWatchtower(
  buildings: SecondaryObjectiveEffectBuilding[]
): SecondaryObjectiveEffectBuilding | undefined {
  return buildings
    .filter((building) => building.alive && building.team === "enemy" && building.definition.id === "watchtower")
    .sort(
      (left, right) =>
        distanceSquared(left.position, ASHEN_GATE_WATCHTOWER_POSITION) -
        distanceSquared(right.position, ASHEN_GATE_WATCHTOWER_POSITION)
    )[0];
}

function distanceSquared(left: Position, right: Position): number {
  const dx = left.x - right.x;
  const dy = left.y - right.y;
  return dx * dx + dy * dy;
}
