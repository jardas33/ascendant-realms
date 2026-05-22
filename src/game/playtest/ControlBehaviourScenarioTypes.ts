import type { BehaviourMode } from "../systems/BehaviourModeSystem";

export type ControlBehaviourScenarioId =
  | "hold_ground_contact_defence"
  | "hold_ground_distant_threat_refusal"
  | "guard_area_default_local_defence"
  | "press_attack_bounded_pursuit"
  | "explicit_attack_overrides_mode"
  | "move_away_suppression"
  | "post_kill_adjacent_reacquisition"
  | "enemy_melee_building_aggro"
  | "attack_hover_tolerance_boundary"
  | "group_mixed_mode_application"
  | "attack_cursor_intent_integrity"
  | "hud_minimap_selection_regression";

export type ControlBehaviourVerdict = "pass" | "monitor" | "fail" | "not_measured";
export type ControlBehaviourConfidence = "high" | "medium" | "low";
export type ControlBehaviourExplicitOrderType =
  | "none"
  | "move"
  | "attack"
  | "attack_move"
  | "mode_change"
  | "ui_regression";
export type ControlBehaviourEnemyDistanceCategory =
  | "contact"
  | "immediate"
  | "near"
  | "press_leash"
  | "distant"
  | "not_applicable";

export const CONTROL_BEHAVIOUR_VERDICTS: ControlBehaviourVerdict[] = ["pass", "monitor", "fail", "not_measured"];
export const CONTROL_BEHAVIOUR_CONFIDENCE_LEVELS: ControlBehaviourConfidence[] = ["high", "medium", "low"];

export interface ControlBehaviourScenarioProfile {
  id: ControlBehaviourScenarioId;
  name: string;
  mode: BehaviourMode | "mixed" | "not_applicable";
  purpose: string;
  expectedEvidence: string[];
  limitations: string[];
}

export interface ControlBehaviourScenarioMetrics {
  mode: BehaviourMode | "mixed" | "not_applicable";
  explicitOrderType: ControlBehaviourExplicitOrderType;
  enemyDistanceCategory: ControlBehaviourEnemyDistanceCategory;
  targetAcquired: boolean | null;
  targetRetained: boolean | null;
  chaseDistance: number | null;
  leashRespected: boolean | null;
  contactAttackFramesObserved: number | null;
  retreatCommandAccepted: boolean | null;
  reacquisitionSuppressedDuringRetreat: boolean | null;
  snapBackObserved: boolean | null;
  groupModeAppliedCount: number | null;
  mixedModeDetected: boolean | null;
}

export type ControlBehaviourMetricKey = keyof ControlBehaviourScenarioMetrics;

export interface ControlBehaviourScenarioResult {
  scenarioId: ControlBehaviourScenarioId;
  scenarioName: string;
  iteration: number;
  mode: ControlBehaviourScenarioProfile["mode"];
  explicitOrderType: ControlBehaviourExplicitOrderType;
  result: ControlBehaviourVerdict;
  confidence: ControlBehaviourConfidence;
  metrics: ControlBehaviourScenarioMetrics;
  unavailableMetrics: ControlBehaviourMetricKey[];
  evidence: string[];
  limitations: string[];
}

export interface ControlBehaviourDashboardScenario {
  scenarioId: ControlBehaviourScenarioId;
  scenarioName: string;
  verdict: ControlBehaviourVerdict;
  confidence: ControlBehaviourConfidence;
  passRate: number;
  monitorRate: number;
  failRate: number;
  iterationCount: number;
}

export interface ControlBehaviourDashboard {
  schemaVersion: 1;
  generatedBy: string;
  generatedAt: string;
  buildCommit: string;
  iterationCount: number;
  scenarioCount: number;
  passCount: number;
  monitorCount: number;
  failCount: number;
  notMeasuredCount: number;
  ranking: ControlBehaviourDashboardScenario[];
  limitations: string[];
  manualRetestNeeded: boolean;
}

export interface ControlBehaviourScenarioReport {
  schemaVersion: 1;
  generatedBy: string;
  generatedAt: string;
  buildCommit: string;
  runMode: "normal" | "extended";
  iterationCount: number;
  scenarioCount: number;
  results: ControlBehaviourScenarioResult[];
  dashboard: ControlBehaviourDashboard;
  limitations: string[];
  determinismNotes: string[];
}
