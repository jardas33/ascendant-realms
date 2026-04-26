import type { BattleMapDefinition } from "../../core/GameTypes";
import { ASHEN_OUTPOST_MAP } from "./ashenOutpost";
import { BROKEN_FORD_MAP } from "./brokenFord";
import { FIRST_CLAIM_MAP } from "./firstClaim";

export { ASHEN_OUTPOST_MAP } from "./ashenOutpost";
export { BROKEN_FORD_MAP } from "./brokenFord";
export { FIRST_CLAIM_MAP } from "./firstClaim";

export const MAPS: BattleMapDefinition[] = [FIRST_CLAIM_MAP, BROKEN_FORD_MAP, ASHEN_OUTPOST_MAP];
export const DEFAULT_MAP_ID = "first_claim";
export const MAP_BY_ID: Record<string, BattleMapDefinition> = Object.fromEntries(MAPS.map((map) => [map.id, map]));

export function getMapById(mapId: string): BattleMapDefinition | undefined {
  return MAP_BY_ID[mapId];
}
