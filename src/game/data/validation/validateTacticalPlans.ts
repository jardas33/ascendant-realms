import { ENEMY_DOCTRINES } from "../enemyDoctrines";
import { TACTICAL_PLANS } from "../tacticalPlans";
import { assertUniqueIds } from "./ValidationTypes";

const REQUIRED_PLAN_IDS = ["guarded_advance", "resource_push", "champion_hunt"];

export function validateTacticalPlans(errors: string[]): void {
  assertUniqueIds(TACTICAL_PLANS, "Tactical plan", errors);
  const doctrineIds = new Set(ENEMY_DOCTRINES.map((doctrine) => doctrine.id));
  const planIds = TACTICAL_PLANS.map((plan) => plan.id);
  if (REQUIRED_PLAN_IDS.some((id) => !planIds.includes(id as (typeof TACTICAL_PLANS)[number]["id"]))) {
    errors.push(`Tactical plans must include ${REQUIRED_PLAN_IDS.join(", ")}.`);
  }
  TACTICAL_PLANS.forEach((plan) => {
    if (
      !plan.name.trim() ||
      !plan.shortLabel.trim() ||
      !plan.description.trim() ||
      !plan.effectSummary.trim() ||
      !plan.hudSummary.trim() ||
      !plan.afterActionSummary.trim() ||
      !plan.recommendedCounterplay.trim()
    ) {
      errors.push(`Tactical plan ${plan.id} needs complete player-facing copy.`);
    }
    if (!plan.launchModifierId.startsWith("tactical_")) {
      errors.push(`Tactical plan ${plan.id} must use a tactical launch modifier id.`);
    }
    if (plan.tags.length === 0) {
      errors.push(`Tactical plan ${plan.id} needs at least one tag.`);
    }
    if (plan.recommendedDoctrineIds.length === 0) {
      errors.push(`Tactical plan ${plan.id} needs doctrine recommendations.`);
    }
    plan.recommendedDoctrineIds.forEach((doctrineId) => {
      if (!doctrineIds.has(doctrineId)) {
        errors.push(`Tactical plan ${plan.id} references missing enemy doctrine ${doctrineId}.`);
      }
    });
  });
}
