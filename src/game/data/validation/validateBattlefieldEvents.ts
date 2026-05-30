import { BATTLEFIELD_EVENTS } from "../battlefieldEvents";
import type { ValidationContext } from "./ValidationTypes";
import { assertUniqueIds } from "./ValidationTypes";

const REQUIRED_EVENT_IDS = [
  "site_under_threat",
  "hold_the_line",
  "elite_strike",
  "reinforcement_window",
  "aether_surge"
] as const;

export function validateBattlefieldEvents(errors: string[], context: ValidationContext): void {
  assertUniqueIds(BATTLEFIELD_EVENTS, "Battlefield event", errors);
  const ids = BATTLEFIELD_EVENTS.map((event) => event.id);
  REQUIRED_EVENT_IDS.forEach((id) => {
    if (!ids.includes(id)) {
      errors.push(`Battlefield events must include ${REQUIRED_EVENT_IDS.join(", ")}.`);
    }
  });

  const doctrineIds = new Set(["raider", "fortress", "hunter", "warband"]);
  const tacticalPlanIds = new Set(["guarded_advance", "resource_push", "champion_hunt"]);
  BATTLEFIELD_EVENTS.forEach((event) => {
    if (
      !event.name.trim() ||
      !event.shortLabel.trim() ||
      !event.description.trim() ||
      !event.objectiveSummary.trim() ||
      !event.counterplay.trim() ||
      !event.afterActionSummary.trim()
    ) {
      errors.push(`Battlefield event ${event.id} needs complete player-facing copy.`);
    }
    if (event.durationSeconds < 18 || event.durationSeconds > 60) {
      errors.push(`Battlefield event ${event.id} has unsafe duration ${event.durationSeconds}.`);
    }
    if (event.cooldownSeconds < 45) {
      errors.push(`Battlefield event ${event.id} cooldown must be at least 45 seconds.`);
    }
    if (event.tags.length === 0) {
      errors.push(`Battlefield event ${event.id} needs at least one tag.`);
    }
    event.eligibleDoctrineIds.forEach((doctrineId) => {
      if (!doctrineIds.has(doctrineId)) {
        errors.push(`Battlefield event ${event.id} references missing doctrine ${doctrineId}.`);
      }
    });
    event.recommendedTacticalPlanIds.forEach((planId) => {
      if (!tacticalPlanIds.has(planId)) {
        errors.push(`Battlefield event ${event.id} references missing tactical plan ${planId}.`);
      }
    });
    event.preferredMissionTypeIds.forEach((missionTypeId) => {
      if (!context.campaignMissionTypeIds.has(missionTypeId)) {
        errors.push(`Battlefield event ${event.id} references missing mission type ${missionTypeId}.`);
      }
    });
    event.preferredModifierIds.forEach((modifierId) => {
      if (!context.campaignModifierIds.has(modifierId)) {
        errors.push(`Battlefield event ${event.id} references missing campaign modifier ${modifierId}.`);
      }
    });
  });
}
