import type {
  EnemyPressureActionDefinition,
  EnemyPressureActionType,
  EnemyPressureConditionDefinition,
  EnemyPressureConditionType,
  EnemyPressureTriggerDefinition,
  EnemyPressureTriggerType,
  EnemyStrategicPressurePlanDefinition,
  EnemyStrategicPressureScope,
  PressureStageDefinition
} from "../../core/GameTypes";
import { CAMPAIGN_NODES } from "../campaignNodes";
import { ENEMY_PRESSURE_PLANS } from "../enemyPressurePlans";
import { MAPS } from "../maps";
import { assertUniqueIds, type ValidationContext } from "./ValidationTypes";

const PLAN_SCOPES: EnemyStrategicPressureScope[] = ["campaign_node", "disabled"];
const TRIGGER_TYPES: EnemyPressureTriggerType[] = [
  "battle_start_time",
  "player_captures_site",
  "player_destroys_structure",
  "player_trains_first_army_unit",
  "enemy_hero_damaged",
  "enemy_hero_defeated",
  "late_battle_time"
];
const ACTION_TYPES: EnemyPressureActionType[] = [
  "show_warning",
  "mark_telemetry",
  "adjust_next_wave_timing",
  "reinforce_next_wave",
  "defensive_hold",
  "contest_capture_site"
];
const CONDITION_TYPES: EnemyPressureConditionType[] = ["stage_completed", "capture_site_not_enemy_owned", "enemy_base_alive"];
const FORBIDDEN_FIELD_TERMS = ["worker", "harvest", "economy", "construction", "placement"];

export function validateEnemyPressurePlans(errors: string[], context: ValidationContext): void {
  assertUniqueIds(ENEMY_PRESSURE_PLANS, "enemy pressure plan", errors);
  ENEMY_PRESSURE_PLANS.forEach((plan) => validateEnemyPressurePlan(plan, errors, context));
}

function validateEnemyPressurePlan(
  plan: EnemyStrategicPressurePlanDefinition,
  errors: string[],
  context: ValidationContext
): void {
  validateForbiddenPressureFields(`Enemy pressure plan ${plan.id}`, plan, errors);

  if (!plan.name.trim() || !plan.description.trim() || !plan.notes.trim()) {
    errors.push(`Enemy pressure plan ${plan.id} needs name, description, and notes.`);
  }
  if (!PLAN_SCOPES.includes(plan.scope)) {
    errors.push(`Enemy pressure plan ${plan.id} has invalid scope ${plan.scope}.`);
  }
  if (typeof plan.enabledByDefault !== "boolean") {
    errors.push(`Enemy pressure plan ${plan.id} enabledByDefault must be boolean.`);
  }
  if (plan.allowedMapIds.length === 0) {
    errors.push(`Enemy pressure plan ${plan.id} must include at least one allowed map.`);
  }
  if (plan.allowedNodeIds.length === 0) {
    errors.push(`Enemy pressure plan ${plan.id} must include at least one allowed campaign node.`);
  }
  validateUniqueStrings(`Enemy pressure plan ${plan.id} allowed map`, plan.allowedMapIds, errors);
  validateUniqueStrings(`Enemy pressure plan ${plan.id} allowed campaign node`, plan.allowedNodeIds, errors);
  validateUniqueStrings(`Enemy pressure plan ${plan.id} telemetry tag`, plan.telemetryTags, errors);

  plan.allowedMapIds.forEach((mapId) => {
    if (!MAPS.some((map) => map.id === mapId)) {
      errors.push(`Enemy pressure plan ${plan.id} references missing map ${mapId}.`);
    }
  });
  plan.allowedNodeIds.forEach((nodeId) => {
    const node = CAMPAIGN_NODES.find((entry) => entry.id === nodeId);
    if (!node) {
      errors.push(`Enemy pressure plan ${plan.id} references missing campaign node ${nodeId}.`);
      return;
    }
    if (!plan.allowedMapIds.includes(node.mapId)) {
      errors.push(`Enemy pressure plan ${plan.id} campaign node ${nodeId} uses map ${node.mapId} outside allowed maps.`);
    }
  });
  plan.personalityTags.forEach((personalityId) => {
    if (!context.aiPersonalityIds.has(personalityId)) {
      errors.push(`Enemy pressure plan ${plan.id} references missing AI personality ${personalityId}.`);
    }
  });

  if (plan.stages.length === 0) {
    errors.push(`Enemy pressure plan ${plan.id} needs at least one stage.`);
  }
  assertUniqueIds(plan.stages, `Enemy pressure plan ${plan.id} stage`, errors);
  plan.stages.forEach((stage) => validatePressureStage(plan, stage, errors, context));
}

function validatePressureStage(
  plan: EnemyStrategicPressurePlanDefinition,
  stage: PressureStageDefinition,
  errors: string[],
  context: ValidationContext
): void {
  if (!stage.telemetryLabel.trim()) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} needs a telemetry label.`);
  }
  if (!["minor", "moderate"].includes(stage.intensity)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} has invalid intensity ${stage.intensity}.`);
  }
  if (stage.delaySeconds !== undefined && (!Number.isFinite(stage.delaySeconds) || stage.delaySeconds < 0)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} has invalid delaySeconds.`);
  }
  if (stage.battleTimeSeconds !== undefined && (!Number.isFinite(stage.battleTimeSeconds) || stage.battleTimeSeconds < 0)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} has invalid battleTimeSeconds.`);
  }
  validatePressureTrigger(plan, stage, stage.trigger, errors, context);
  validatePressureCondition(plan, stage, stage.condition, errors);
  validatePressureAction(plan, stage, stage.action, errors, context);
}

function validatePressureTrigger(
  plan: EnemyStrategicPressurePlanDefinition,
  stage: PressureStageDefinition,
  trigger: EnemyPressureTriggerDefinition,
  errors: string[],
  context: ValidationContext
): void {
  if (!TRIGGER_TYPES.includes(trigger.type)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} has invalid trigger ${trigger.type}.`);
  }
  if (trigger.type === "battle_start_time" || trigger.type === "late_battle_time") {
    if (stage.battleTimeSeconds === undefined && stage.delaySeconds === undefined) {
      errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} time trigger needs delaySeconds or battleTimeSeconds.`);
    }
  }
  if (trigger.type === "player_captures_site") {
    validatePressureCaptureSite(plan, stage.id, trigger.captureSiteId, "trigger", errors);
  }
  if (trigger.type === "player_destroys_structure") {
    if (!trigger.buildingId || !context.buildingIds.has(trigger.buildingId)) {
      errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} trigger references missing building ${trigger.buildingId ?? "(empty)"}.`);
    }
  }
  if (trigger.type === "player_trains_first_army_unit") {
    validatePressureUnitIds(plan, stage.id, "trigger", trigger.unitIds, errors, context);
  }
  if ((trigger.type === "enemy_hero_damaged" || trigger.type === "enemy_hero_defeated") && trigger.enemyHeroId && !context.enemyHeroIds.has(trigger.enemyHeroId)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} trigger references missing enemy hero ${trigger.enemyHeroId}.`);
  }
}

function validatePressureCondition(
  plan: EnemyStrategicPressurePlanDefinition,
  stage: PressureStageDefinition,
  condition: EnemyPressureConditionDefinition | undefined,
  errors: string[]
): void {
  if (!condition) {
    return;
  }
  if (!CONDITION_TYPES.includes(condition.type)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} has invalid condition ${condition.type}.`);
  }
  if (condition.type === "stage_completed") {
    if (!condition.stageId || !plan.stages.some((candidate) => candidate.id === condition.stageId)) {
      errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} condition references missing stage ${condition.stageId ?? "(empty)"}.`);
    }
  }
  if (condition.type === "capture_site_not_enemy_owned") {
    validatePressureCaptureSite(plan, stage.id, condition.captureSiteId, "condition", errors);
  }
}

function validatePressureAction(
  plan: EnemyStrategicPressurePlanDefinition,
  stage: PressureStageDefinition,
  action: EnemyPressureActionDefinition,
  errors: string[],
  context: ValidationContext
): void {
  if (!ACTION_TYPES.includes(action.type)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} has invalid action ${action.type}.`);
  }
  if (action.type === "show_warning" && !stage.warningCopy?.trim()) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} warning action needs warning copy.`);
  }
  if (action.type === "adjust_next_wave_timing" && !Number.isFinite(action.seconds)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} wave timing action needs finite seconds.`);
  }
  if (action.type === "reinforce_next_wave") {
    validatePressureUnitIds(plan, stage.id, "action", action.unitIds, errors, context);
    if (action.count !== undefined && (!Number.isInteger(action.count) || action.count <= 0)) {
      errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} reinforcement count must be positive.`);
    }
  }
  if (action.type === "contest_capture_site") {
    validatePressureCaptureSite(plan, stage.id, action.captureSiteId, "action", errors);
    validatePressureUnitIds(plan, stage.id, "action", action.unitIds, errors, context);
  }
  if (action.type === "defensive_hold" && action.radius !== undefined && (!Number.isFinite(action.radius) || action.radius <= 0)) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stage.id} defensive hold radius must be positive.`);
  }
}

function validatePressureCaptureSite(
  plan: EnemyStrategicPressurePlanDefinition,
  stageId: string,
  captureSiteId: string | undefined,
  source: "trigger" | "condition" | "action",
  errors: string[]
): void {
  if (!captureSiteId) {
    errors.push(`Enemy pressure plan ${plan.id} stage ${stageId} ${source} needs captureSiteId.`);
    return;
  }
  const allowedMaps = MAPS.filter((map) => plan.allowedMapIds.includes(map.id));
  if (!allowedMaps.some((map) => map.captureSites.some((site) => site.id === captureSiteId))) {
    errors.push(
      `Enemy pressure plan ${plan.id} stage ${stageId} ${source} references capture site ${captureSiteId} outside allowed maps ${plan.allowedMapIds.join(", ") || "(none)"}.`
    );
  }
}

function validatePressureUnitIds(
  plan: EnemyStrategicPressurePlanDefinition,
  stageId: string,
  source: "trigger" | "action",
  unitIds: string[] | undefined,
  errors: string[],
  context: ValidationContext
): void {
  unitIds?.forEach((unitId) => {
    if (!context.unitIds.has(unitId)) {
      errors.push(`Enemy pressure plan ${plan.id} stage ${stageId} ${source} references missing unit ${unitId}.`);
    }
  });
}

function validateUniqueStrings(label: string, ids: string[], errors: string[]): void {
  const seen = new Set<string>();
  ids.forEach((id) => {
    if (!id.trim()) {
      errors.push(`${label} has an empty id.`);
    }
    if (seen.has(id)) {
      errors.push(`${label} ${id} is listed more than once.`);
    }
    seen.add(id);
  });
}

function validateForbiddenPressureFields(label: string, value: unknown, errors: string[], path = ""): void {
  if (!value || typeof value !== "object") {
    return;
  }
  Object.entries(value as Record<string, unknown>).forEach(([key, child]) => {
    const normalizedKey = key.toLowerCase();
    if (FORBIDDEN_FIELD_TERMS.some((term) => normalizedKey.includes(term))) {
      errors.push(`${label} contains forbidden worker/construction/economy field ${path}${key}.`);
    }
    validateForbiddenPressureFields(label, child, errors, `${path}${key}.`);
  });
}
