export type TutorialStatus = "planned" | "scaffolded";

export type TutorialStepType =
  | "camera"
  | "selection"
  | "movement"
  | "capture"
  | "resources"
  | "building"
  | "training"
  | "rally"
  | "hero_ability"
  | "enemy_pressure"
  | "victory_results"
  | "campaign_persistence";

export interface TutorialStepReferences {
  mapIds?: string[];
  unitIds?: string[];
  buildingIds?: string[];
  abilityIds?: string[];
  resourceIds?: string[];
  captureSiteIds?: string[];
}

export interface TutorialStepDefinition {
  id: string;
  type: TutorialStepType;
  title: string;
  description: string;
  references?: TutorialStepReferences;
}

export interface TutorialDefinition {
  id: string;
  title: string;
  description: string;
  status: TutorialStatus;
  steps: TutorialStepDefinition[];
}
