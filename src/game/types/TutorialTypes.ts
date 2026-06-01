export type TutorialStatus = "planned" | "scaffolded" | "playable";

export type TutorialStepType =
  | "info"
  | "selectHero"
  | "selectTroops"
  | "moveHero"
  | "captureSite"
  | "gatherResources"
  | "selectBuilding"
  | "buildStructure"
  | "assignWorker"
  | "trainUnit"
  | "setRally"
  | "useHeroAbility"
  | "defeatEnemy"
  | "finish";

export type TutorialLaunchMode = "battle";

export type TutorialObjectiveType =
  | "acknowledge"
  | "selectHero"
  | "selectTroops"
  | "moveHero"
  | "captureSite"
  | "resourceThreshold"
  | "selectBuilding"
  | "buildStructure"
  | "assignWorker"
  | "trainUnit"
  | "setRally"
  | "useHeroAbility"
  | "defeatEnemy"
  | "finish";

export type TutorialRequiredAction =
  | "readInstructions"
  | "selectHero"
  | "selectTroops"
  | "moveHero"
  | "captureSite"
  | "waitForIncome"
  | "selectBuilding"
  | "buildStructure"
  | "assignWorker"
  | "trainUnit"
  | "setRally"
  | "useHeroAbility"
  | "defeatEnemy"
  | "finish";

export type TutorialFocusTargetType =
  | "hero"
  | "friendlyTroops"
  | "captureSite"
  | "building"
  | "worker"
  | "enemy";

export interface TutorialFocusTargetDefinition {
  type: TutorialFocusTargetType;
  id?: string;
  label: string;
}

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
  reason?: string;
  moreHelp?: string;
  focusTarget?: TutorialFocusTargetDefinition;
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
