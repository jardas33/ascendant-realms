import type { EnemyAIPersonalityId } from "./CombatTypes";

export type EnemyStrategicPressureScope = "campaign_node" | "disabled";
export type EnemyPressureIntensity = "minor" | "moderate";

export type EnemyPressureTriggerType =
  | "battle_start_time"
  | "player_captures_site"
  | "player_destroys_structure"
  | "player_trains_first_army_unit"
  | "enemy_hero_damaged"
  | "enemy_hero_defeated"
  | "late_battle_time";

export interface EnemyPressureTriggerDefinition {
  type: EnemyPressureTriggerType;
  captureSiteId?: string;
  buildingId?: string;
  unitIds?: string[];
  enemyHeroId?: string;
}

export type EnemyPressureConditionType = "stage_completed" | "capture_site_not_enemy_owned" | "enemy_base_alive";

export interface EnemyPressureConditionDefinition {
  type: EnemyPressureConditionType;
  stageId?: string;
  captureSiteId?: string;
}

export type EnemyPressureActionType =
  | "show_warning"
  | "mark_telemetry"
  | "adjust_next_wave_timing"
  | "reinforce_next_wave"
  | "defensive_hold"
  | "contest_capture_site";

export interface EnemyPressureActionDefinition {
  type: EnemyPressureActionType;
  seconds?: number;
  unitIds?: string[];
  count?: number;
  captureSiteId?: string;
  radius?: number;
}

export interface PressureStageDefinition {
  id: string;
  trigger: EnemyPressureTriggerDefinition;
  delaySeconds?: number;
  battleTimeSeconds?: number;
  condition?: EnemyPressureConditionDefinition;
  action: EnemyPressureActionDefinition;
  intensity: EnemyPressureIntensity;
  warningCopy?: string;
  telemetryLabel: string;
}

export interface EnemyStrategicPressurePlanDefinition {
  id: string;
  name: string;
  description: string;
  scope: EnemyStrategicPressureScope;
  allowedMapIds: string[];
  allowedNodeIds: string[];
  personalityTags: EnemyAIPersonalityId[];
  stages: PressureStageDefinition[];
  telemetryTags: string[];
  enabledByDefault: boolean;
  notes: string;
}
