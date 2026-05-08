import type { BattleMapDefinition } from "../../core/GameTypes";
import { MAPS } from "../maps";
import { assertUniqueIds, validatePointInMap, type ValidationContext } from "./ValidationTypes";

export function validateMaps(errors: string[], context: ValidationContext): void {
  MAPS.forEach((map) => validateMap(map, errors, context));
}

function validateMap(map: BattleMapDefinition, errors: string[], context: ValidationContext): void {
  if (map.width <= 0 || map.height <= 0) {
    errors.push(`Map ${map.id} must have positive dimensions.`);
  }
  if (!map.name.trim() || !map.role.trim() || !map.description.trim()) {
    errors.push(`Map ${map.id} must include name, role, and description for setup UI.`);
  }
  if (map.strategicNotes.length === 0) {
    errors.push(`Map ${map.id} should include at least one strategic note.`);
  }
  if (map.visualPaths.length === 0) {
    errors.push(`Map ${map.id} should include at least one visual path.`);
  }
  assertUniqueIds(map.terrainZones, `Map ${map.id} terrain zone`, errors);
  assertUniqueIds(map.visualPaths, `Map ${map.id} visual path`, errors);
  assertUniqueIds(map.captureSites, `Map ${map.id} capture site`, errors);
  assertUniqueIds(map.neutralCamps, `Map ${map.id} neutral camp`, errors);
  assertUniqueIds(map.scenario.buildingSpawns, `Map ${map.id} building spawn`, errors);
  assertUniqueIds(map.scenario.unitSpawns, `Map ${map.id} unit spawn`, errors);

  validatePointInMap(map, map.playerStart, "player start", errors);
  validatePointInMap(map, map.enemyStart, "enemy start", errors);
  validatePointInMap(map, map.scenario.heroSpawn, "hero spawn", errors);

  map.terrainZones.forEach((zone) => {
    if (zone.width <= 0 || zone.height <= 0) {
      errors.push(`Map ${map.id} terrain zone ${zone.id} must have positive size.`);
    }
    if (zone.x < 0 || zone.y < 0 || zone.x + zone.width > map.width || zone.y + zone.height > map.height) {
      errors.push(`Map ${map.id} terrain zone ${zone.id} is outside map bounds.`);
    }
  });

  map.visualPaths.forEach((path) => {
    if (path.width <= 0) {
      errors.push(`Map ${map.id} visual path ${path.id} must have positive width.`);
    }
    if (path.points.length < 2) {
      errors.push(`Map ${map.id} visual path ${path.id} needs at least two points.`);
    }
    path.points.forEach((point, index) => validatePointInMap(map, point, `visual path ${path.id} point ${index}`, errors));
  });

  map.captureSites.forEach((site) => {
    if (!context.resourceIds.has(site.resource)) {
      errors.push(`Map ${map.id} capture site ${site.id} references missing resource ${site.resource}.`);
    }
    if (site.radius <= 0) {
      errors.push(`Map ${map.id} capture site ${site.id} must have a positive radius.`);
    }
    if (site.incomeAmount < 0 || site.incomeInterval <= 0) {
      errors.push(`Map ${map.id} capture site ${site.id} has invalid income settings.`);
    }
    if (site.firstCaptureBonus) {
      if (!site.firstCaptureBonus.id.trim() || !site.firstCaptureBonus.label.trim() || !site.firstCaptureBonus.description.trim()) {
        errors.push(`Map ${map.id} capture site ${site.id} first-capture bonus needs id, label, and description.`);
      }
      Object.entries(site.firstCaptureBonus.resources).forEach(([resource, amount]) => {
        if (!context.resourceIds.has(resource)) {
          errors.push(`Map ${map.id} capture site ${site.id} first-capture bonus references missing resource ${resource}.`);
        }
        if ((amount ?? 0) <= 0) {
          errors.push(`Map ${map.id} capture site ${site.id} first-capture bonus must grant positive ${resource}.`);
        }
      });
      if (Object.keys(site.firstCaptureBonus.resources).length === 0) {
        errors.push(`Map ${map.id} capture site ${site.id} first-capture bonus must grant at least one resource.`);
      }
    }
    validatePointInMap(map, site, `capture site ${site.id}`, errors);
  });

  map.scenario.buildingSpawns.forEach((spawn) => {
    if (!context.buildingIds.has(spawn.buildingId)) {
      errors.push(`Map ${map.id} spawns missing building ${spawn.buildingId}.`);
    }
    validatePointInMap(map, spawn, `building spawn ${spawn.id}`, errors);
  });
  map.scenario.unitSpawns.forEach((spawn) => {
    if (!context.unitIds.has(spawn.unitId)) {
      errors.push(`Map ${map.id} spawns missing unit ${spawn.unitId}.`);
    }
    validatePointInMap(map, spawn, `unit spawn ${spawn.id}`, errors);
  });
  map.neutralCamps.forEach((camp) => {
    validatePointInMap(map, camp, `neutral camp ${camp.id}`, errors);
    if (camp.unitIds.length === 0) {
      errors.push(`Map ${map.id} camp ${camp.id} must include at least one unit.`);
    }
    camp.unitIds.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`Map ${map.id} camp ${camp.id} references missing unit ${unitId}.`);
      }
    });
  });

  const scenario = map.scenario;
  (["player", "enemy"] as const).forEach((team) => {
    Object.entries(scenario.startingResources[team]).forEach(([resource, amount]) => {
      if (!context.resourceIds.has(resource)) {
        errors.push(`Map ${map.id} gives ${team} an unknown starting resource ${resource}.`);
      }
      if (amount < 0) {
        errors.push(`Map ${map.id} gives ${team} negative starting ${resource}.`);
      }
    });
  });
  [scenario.objectives.playerBaseBuildingId, scenario.objectives.enemyBaseBuildingId].forEach((buildingId) => {
    if (!context.buildingIds.has(buildingId)) {
      errors.push(`Map ${map.id} objective references missing building ${buildingId}.`);
    }
  });
  assertUniqueIds(scenario.objectives.secondaryObjectives ?? [], `Map ${map.id} secondary objective`, errors);
  scenario.objectives.secondaryObjectives?.forEach((objective) => {
    if (!objective.name.trim() || !objective.description.trim()) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} needs name and description.`);
    }
    if (!["capture_site", "destroy_building", "defeat_unit"].includes(objective.type)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} has invalid type ${objective.type}.`);
    }
    if (objective.type === "capture_site" && !map.captureSites.some((site) => site.id === objective.targetId)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} references missing capture site ${objective.targetId}.`);
    }
    if (objective.type === "destroy_building" && !context.buildingIds.has(objective.targetId)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} references missing building ${objective.targetId}.`);
    }
    if (
      objective.type === "destroy_building" &&
      context.buildingIds.has(objective.targetId) &&
      !map.scenario.buildingSpawns.some((spawn) => spawn.buildingId === objective.targetId)
    ) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} targets a building not spawned on this map.`);
    }
    if (objective.type === "defeat_unit" && !context.unitIds.has(objective.targetId)) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} references missing unit ${objective.targetId}.`);
    }
    if (
      objective.type === "defeat_unit" &&
      context.unitIds.has(objective.targetId) &&
      !map.scenario.unitSpawns.some((spawn) => spawn.unitId === objective.targetId) &&
      !map.neutralCamps.some((camp) => camp.unitIds.includes(objective.targetId))
    ) {
      errors.push(`Map ${map.id} secondary objective ${objective.id} targets a unit not spawned on this map.`);
    }
  });
  scenario.enemyAI.unitPlan.forEach((unitId) => {
    if (!context.unitIds.has(unitId)) {
      errors.push(`Map ${map.id} AI plan references missing unit ${unitId}.`);
    }
  });
  if (scenario.enemyAI.unitPlan.length === 0) {
    errors.push(`Map ${map.id} AI unit plan must include at least one unit.`);
  }
  [scenario.enemyAI.baseBuildingId, scenario.enemyAI.productionBuildingId, scenario.enemyAI.attackTargetBuildingId].forEach(
    (buildingId) => {
      if (!context.buildingIds.has(buildingId)) {
        errors.push(`Map ${map.id} AI references missing building ${buildingId}.`);
      }
    }
  );
  const enemySpawnBuildingIds = new Set(
    scenario.buildingSpawns.filter((spawn) => spawn.team === "enemy").map((spawn) => spawn.buildingId)
  );
  const playerSpawnBuildingIds = new Set(
    scenario.buildingSpawns.filter((spawn) => spawn.team === "player").map((spawn) => spawn.buildingId)
  );
  [scenario.enemyAI.baseBuildingId, scenario.enemyAI.productionBuildingId].forEach((buildingId) => {
    if (context.buildingIds.has(buildingId) && !enemySpawnBuildingIds.has(buildingId)) {
      errors.push(`Map ${map.id} AI references enemy building ${buildingId} that is not spawned for the enemy team.`);
    }
  });
  if (context.buildingIds.has(scenario.enemyAI.attackTargetBuildingId) && !playerSpawnBuildingIds.has(scenario.enemyAI.attackTargetBuildingId)) {
    errors.push(`Map ${map.id} AI attack target ${scenario.enemyAI.attackTargetBuildingId} is not spawned for the player team.`);
  }
  if (!context.rewardTableIds.has(scenario.rewardTableId)) {
    errors.push(`Map ${map.id} references missing reward table ${scenario.rewardTableId}.`);
  }
}
