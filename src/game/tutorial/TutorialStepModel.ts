import type { TutorialDefinition, TutorialRequiredAction, TutorialStepDefinition } from "../core/GameTypes";

export interface TutorialCompletionSignals {
  acknowledged?: boolean;
  heroSelected?: boolean;
  heroMoved?: boolean;
  capturedSiteIds?: string[];
  resourceAmounts?: Record<string, number | undefined>;
  selectedBuildingIds?: string[];
  completedBuildingIds?: string[];
  trainedUnitIds?: string[];
  rallyBuildingIds?: string[];
  usedAbilityIds?: string[];
  defeatedUnitIds?: string[];
  finished?: boolean;
}

export interface TutorialStepViewModel {
  tutorialId: string;
  stepId: string;
  stepNumber: number;
  totalSteps: number;
  title: string;
  instruction: string;
  hint?: string;
  completionConditionLabel: string;
  progressLabel: string;
  isComplete: boolean;
  isFinalStep: boolean;
  nextStepId?: string;
}

export function firstTutorialStepId(tutorial: TutorialDefinition): string | undefined {
  return tutorial.steps[0]?.id;
}

export function getTutorialStep(tutorial: TutorialDefinition, stepId: string | undefined): TutorialStepDefinition {
  const targetStepId = stepId ?? firstTutorialStepId(tutorial);
  const step = tutorial.steps.find((entry) => entry.id === targetStepId);
  if (!step || !targetStepId) {
    throw new Error(`Unknown tutorial step id ${targetStepId ?? "(empty)"} for ${tutorial.id}.`);
  }
  return step;
}

export function getNextTutorialStepId(tutorial: TutorialDefinition, stepId: string): string | undefined {
  const index = tutorial.steps.findIndex((step) => step.id === stepId);
  if (index < 0) {
    throw new Error(`Unknown tutorial step id ${stepId} for ${tutorial.id}.`);
  }
  return tutorial.steps[index + 1]?.id;
}

export function createTutorialStepViewModel(
  tutorial: TutorialDefinition,
  stepId?: string,
  signals: TutorialCompletionSignals = {}
): TutorialStepViewModel {
  const step = getTutorialStep(tutorial, stepId);
  const index = tutorial.steps.findIndex((entry) => entry.id === step.id);
  const isComplete = isTutorialStepComplete(step, signals);
  const nextStepId = getNextTutorialStepId(tutorial, step.id);
  const stepNumber = index + 1;
  const totalSteps = tutorial.steps.length;

  return {
    tutorialId: tutorial.id,
    stepId: step.id,
    stepNumber,
    totalSteps,
    title: step.title,
    instruction: step.instruction,
    hint: step.hint,
    completionConditionLabel: createCompletionConditionLabel(step),
    progressLabel: createProgressLabel(stepNumber, totalSteps, isComplete),
    isComplete,
    isFinalStep: nextStepId === undefined,
    nextStepId
  };
}

export function advanceTutorialStep(tutorial: TutorialDefinition, stepId: string): string {
  return getNextTutorialStepId(tutorial, stepId) ?? stepId;
}

export function isTutorialStepComplete(step: TutorialStepDefinition, signals: TutorialCompletionSignals = {}): boolean {
  switch (step.requiredAction) {
    case "readInstructions":
      return Boolean(signals.acknowledged);
    case "selectHero":
      return Boolean(signals.heroSelected);
    case "moveHero":
      return Boolean(signals.heroMoved);
    case "captureSite":
      return hasAnyReference(step.references?.captureSiteIds, signals.capturedSiteIds);
    case "waitForIncome":
      return hasPositiveResource(step.references?.resourceIds, signals.resourceAmounts);
    case "selectBuilding":
      return hasAnyReference(step.references?.buildingIds, signals.selectedBuildingIds);
    case "buildStructure":
      return hasAnyReference(preferredTargetIds(step.references?.buildingIds), signals.completedBuildingIds);
    case "trainUnit":
      return hasAnyReference(step.references?.unitIds, signals.trainedUnitIds);
    case "setRally":
      return hasAnyReference(preferredTargetIds(step.references?.buildingIds), signals.rallyBuildingIds);
    case "useHeroAbility":
      return hasAnyReference(step.references?.abilityIds, signals.usedAbilityIds);
    case "defeatEnemy":
      return hasAnyReference(step.references?.unitIds, signals.defeatedUnitIds);
    case "finish":
      return Boolean(signals.finished);
    default:
      return assertNeverAction(step.requiredAction);
  }
}

export function createCompletionConditionLabel(step: TutorialStepDefinition): string {
  switch (step.requiredAction) {
    case "readInstructions":
      return "Read the objective";
    case "selectHero":
      return "Select the hero";
    case "moveHero":
      return "Move the hero";
    case "captureSite":
      return `Capture ${formatId(step.references?.captureSiteIds?.[0] ?? "site")}`;
    case "waitForIncome":
      return `Gain ${formatId(step.references?.resourceIds?.[0] ?? "resources")}`;
    case "selectBuilding":
      return `Select ${formatId(step.references?.buildingIds?.[0] ?? "building")}`;
    case "buildStructure":
      return `Build ${formatId(preferredTargetIds(step.references?.buildingIds)[0] ?? "structure")}`;
    case "trainUnit":
      return `Train ${formatId(step.references?.unitIds?.[0] ?? "unit")}`;
    case "setRally":
      return "Set a rally point";
    case "useHeroAbility":
      return `Use ${formatId(step.references?.abilityIds?.[0] ?? "hero ability")}`;
    case "defeatEnemy":
      return `Defeat ${formatId(step.references?.unitIds?.[0] ?? "enemy")}`;
    case "finish":
      return "Finish the tutorial";
    default:
      return assertNeverAction(step.requiredAction);
  }
}

function createProgressLabel(stepNumber: number, totalSteps: number, isComplete: boolean): string {
  return `Step ${stepNumber} of ${totalSteps}${isComplete ? ": complete" : ""}`;
}

function preferredTargetIds(ids: string[] | undefined): string[] {
  if (!ids || ids.length === 0) {
    return [];
  }
  return [ids[ids.length - 1]];
}

function hasAnyReference(targetIds: string[] | undefined, completedIds: string[] | undefined): boolean {
  if (!targetIds || targetIds.length === 0 || !completedIds || completedIds.length === 0) {
    return false;
  }
  return targetIds.some((id) => completedIds.includes(id));
}

function hasPositiveResource(resourceIds: string[] | undefined, amounts: Record<string, number | undefined> | undefined): boolean {
  if (!resourceIds || resourceIds.length === 0 || !amounts) {
    return false;
  }
  return resourceIds.some((id) => (amounts[id] ?? 0) > 0);
}

function formatId(id: string): string {
  return id
    .split(/[_-]/g)
    .filter(Boolean)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

function assertNeverAction(action: never): never {
  throw new Error(`Unhandled tutorial required action: ${action}`);
}
