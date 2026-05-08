import { MAPS } from "../maps";
import { TUTORIALS } from "../tutorials";
import type {
  TutorialDefinition,
  TutorialLaunchMode,
  TutorialObjectiveType,
  TutorialRequiredAction,
  TutorialStepDefinition,
  TutorialStepType
} from "../../core/GameTypes";
import { assertUniqueIds, type ValidationContext } from "./ValidationTypes";

const TUTORIAL_STATUSES: Array<TutorialDefinition["status"]> = ["planned", "scaffolded", "playable"];
const TUTORIAL_LAUNCH_MODES: TutorialLaunchMode[] = ["battle"];
const TUTORIAL_STEP_TYPES: TutorialStepType[] = [
  "info",
  "selectHero",
  "moveHero",
  "captureSite",
  "gatherResources",
  "selectBuilding",
  "buildStructure",
  "trainUnit",
  "setRally",
  "useHeroAbility",
  "defeatEnemy",
  "finish"
];
const TUTORIAL_OBJECTIVE_TYPES: TutorialObjectiveType[] = [
  "acknowledge",
  "selectHero",
  "moveHero",
  "captureSite",
  "resourceThreshold",
  "selectBuilding",
  "buildStructure",
  "trainUnit",
  "setRally",
  "useHeroAbility",
  "defeatEnemy",
  "finish"
];
const TUTORIAL_REQUIRED_ACTIONS: TutorialRequiredAction[] = [
  "readInstructions",
  "selectHero",
  "moveHero",
  "captureSite",
  "waitForIncome",
  "selectBuilding",
  "buildStructure",
  "trainUnit",
  "setRally",
  "useHeroAbility",
  "defeatEnemy",
  "finish"
];

export function validateTutorials(errors: string[], context: ValidationContext): void {
  assertUniqueIds(TUTORIALS, "tutorial", errors);
  const mapIds = new Set(MAPS.map((map) => map.id));
  const captureSiteIds = new Set(MAPS.flatMap((map) => map.captureSites.map((site) => site.id)));
  const captureSiteIdsByMapId = new Map(MAPS.map((map) => [map.id, new Set(map.captureSites.map((site) => site.id))]));

  TUTORIALS.forEach((tutorial) => {
    if (!tutorial.title.trim() || !tutorial.description.trim()) {
      errors.push(`Tutorial ${tutorial.id} needs title and description.`);
    }
    if (!TUTORIAL_STATUSES.includes(tutorial.status)) {
      errors.push(`Tutorial ${tutorial.id} has invalid status ${tutorial.status}.`);
    }
    if (tutorial.launchMode && !TUTORIAL_LAUNCH_MODES.includes(tutorial.launchMode)) {
      errors.push(`Tutorial ${tutorial.id} has invalid launch mode ${tutorial.launchMode}.`);
    }
    if (tutorial.mapId && !mapIds.has(tutorial.mapId)) {
      errors.push(`Tutorial ${tutorial.id} references missing map ${tutorial.mapId}.`);
    }
    if (tutorial.status === "playable" && !tutorial.mapId) {
      errors.push(`Playable tutorial ${tutorial.id} must include mapId.`);
    }
    if (tutorial.id === "proving_grounds_basics" && tutorial.noReward !== true) {
      errors.push("Tutorial proving_grounds_basics must keep noReward true.");
    }
    if (tutorial.steps.length === 0) {
      errors.push(`Tutorial ${tutorial.id} needs at least one planned step.`);
    }
    assertUniqueIds(tutorial.steps, `Tutorial ${tutorial.id} step`, errors);
    tutorial.steps.forEach((step) =>
      validateTutorialStep(
        tutorial.id,
        tutorial.mapId,
        step,
        errors,
        context,
        mapIds,
        captureSiteIds,
        captureSiteIdsByMapId
      )
    );
  });
}

function validateTutorialStep(
  tutorialId: string,
  tutorialMapId: string | undefined,
  step: TutorialStepDefinition,
  errors: string[],
  context: ValidationContext,
  mapIds: Set<string>,
  captureSiteIds: Set<string>,
  captureSiteIdsByMapId: Map<string, Set<string>>
): void {
  if (!step.title.trim() || !step.description.trim() || !step.instruction.trim()) {
    errors.push(`Tutorial ${tutorialId} step ${step.id} needs title, description, and instruction.`);
  }
  if (!TUTORIAL_STEP_TYPES.includes(step.type)) {
    errors.push(`Tutorial ${tutorialId} step ${step.id} has invalid type ${step.type}.`);
  }
  if (!TUTORIAL_OBJECTIVE_TYPES.includes(step.objectiveType)) {
    errors.push(`Tutorial ${tutorialId} step ${step.id} has invalid objective type ${step.objectiveType}.`);
  }
  if (!TUTORIAL_REQUIRED_ACTIONS.includes(step.requiredAction)) {
    errors.push(`Tutorial ${tutorialId} step ${step.id} has invalid required action ${step.requiredAction}.`);
  }
  step.references?.mapIds?.forEach((mapId) => {
    if (!mapIds.has(mapId)) {
      errors.push(`Tutorial ${tutorialId} step ${step.id} references missing map ${mapId}.`);
    }
  });
  step.references?.unitIds?.forEach((unitId) => {
    if (!context.unitIds.has(unitId)) {
      errors.push(`Tutorial ${tutorialId} step ${step.id} references missing unit ${unitId}.`);
    }
  });
  step.references?.buildingIds?.forEach((buildingId) => {
    if (!context.buildingIds.has(buildingId)) {
      errors.push(`Tutorial ${tutorialId} step ${step.id} references missing building ${buildingId}.`);
    }
  });
  step.references?.abilityIds?.forEach((abilityId) => {
    if (!context.abilityIds.has(abilityId)) {
      errors.push(`Tutorial ${tutorialId} step ${step.id} references missing ability ${abilityId}.`);
    }
  });
  step.references?.resourceIds?.forEach((resourceId) => {
    if (!context.resourceIds.has(resourceId)) {
      errors.push(`Tutorial ${tutorialId} step ${step.id} references missing resource ${resourceId}.`);
    }
  });
  step.references?.captureSiteIds?.forEach((captureSiteId) => {
    if (!captureSiteIds.has(captureSiteId)) {
      errors.push(`Tutorial ${tutorialId} step ${step.id} references missing capture site ${captureSiteId}.`);
      return;
    }
    if (tutorialMapId && !captureSiteIdsByMapId.get(tutorialMapId)?.has(captureSiteId)) {
      errors.push(`Tutorial ${tutorialId} step ${step.id} references capture site ${captureSiteId} outside map ${tutorialMapId}.`);
    }
  });
}
