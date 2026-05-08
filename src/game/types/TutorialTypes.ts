export type TutorialStatus = "planned" | "scaffolded" | "playable";

export type TutorialStepType =
  | "info"
  | "selectHero"
  | "moveHero"
  | "captureSite"
  | "gatherResources"
  | "selectBuilding"
  | "buildStructure"
  | "trainUnit"
  | "setRally"
  | "useHeroAbility"
  | "defeatEnemy"
  | "finish";

export type TutorialLaunchMode = "battle";

export type TutorialObjectiveType =
  | "acknowledge"
  | "selectHero"
  | "moveHero"
  | "captureSite"
  | "resourceThreshold"
  | "selectBuilding"
  | "buildStructure"
  | "trainUnit"
  | "setRally"
  | "useHeroAbility"
  | "defeatEnemy"
  | "finish";

export type TutorialRequiredAction =
  | "readInstructions"
  | "selectHero"
  | "moveHero"
  | "captureSite"
  | "waitForIncome"
  | "selectBuilding"
  | "buildStructure"
  | "trainUnit"
  | "setRally"
  | "useHeroAbility"
  | "defeatEnemy"
  | "finish";

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
  instruction: string;
  objectiveType: TutorialObjectiveType;
  requiredAction: TutorialRequiredAction;
  hint?: string;
  references?: TutorialStepReferences;
}

export interface TutorialDefinition {
  id: string;
  title: string;
  description: string;
  status: TutorialStatus;
  launchMode?: TutorialLaunchMode;
  mapId?: string;
  noReward: boolean;
  steps: TutorialStepDefinition[];
}
