import { MAPS } from "../maps";
import { TUTORIALS } from "../tutorials";
import type { TutorialDefinition, TutorialStepDefinition, TutorialStepType } from "../../core/GameTypes";
import { assertUniqueIds, type ValidationContext } from "./ValidationTypes";

const TUTORIAL_STATUSES: Array<TutorialDefinition["status"]> = ["planned", "scaffolded"];
const TUTORIAL_STEP_TYPES: TutorialStepType[] = [
  "camera",
  "selection",
  "movement",
  "capture",
  "resources",
  "building",
  "training",
  "rally",
  "hero_ability",
  "enemy_pressure",
  "victory_results",
  "campaign_persistence"
];

export function validateTutorials(errors: string[], context: ValidationContext): void {
  assertUniqueIds(TUTORIALS, "tutorial", errors);
  const mapIds = new Set(MAPS.map((map) => map.id));
  const captureSiteIds = new Set(MAPS.flatMap((map) => map.captureSites.map((site) => site.id)));

  TUTORIALS.forEach((tutorial) => {
    if (!tutorial.title.trim() || !tutorial.description.trim()) {
      errors.push(`Tutorial ${tutorial.id} needs title and description.`);
    }
    if (!TUTORIAL_STATUSES.includes(tutorial.status)) {
      errors.push(`Tutorial ${tutorial.id} has invalid status ${tutorial.status}.`);
    }
    if (tutorial.steps.length === 0) {
      errors.push(`Tutorial ${tutorial.id} needs at least one planned step.`);
    }
    assertUniqueIds(tutorial.steps, `Tutorial ${tutorial.id} step`, errors);
    tutorial.steps.forEach((step) => validateTutorialStep(tutorial.id, step, errors, context, mapIds, captureSiteIds));
  });
}

function validateTutorialStep(
  tutorialId: string,
  step: TutorialStepDefinition,
  errors: string[],
  context: ValidationContext,
  mapIds: Set<string>,
  captureSiteIds: Set<string>
): void {
  if (!step.title.trim() || !step.description.trim()) {
    errors.push(`Tutorial ${tutorialId} step ${step.id} needs title and description.`);
  }
  if (!TUTORIAL_STEP_TYPES.includes(step.type)) {
    errors.push(`Tutorial ${tutorialId} step ${step.id} has invalid type ${step.type}.`);
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
    }
  });
}
