import { ENEMY_DOCTRINES, ENEMY_ELITE_SQUADS } from "../enemyDoctrines";
import type { ValidationContext } from "./ValidationTypes";
import { assertUniqueIds } from "./ValidationTypes";

export function validateEnemyDoctrines(errors: string[], context: ValidationContext): void {
  assertUniqueIds(ENEMY_DOCTRINES, "Enemy doctrine", errors);
  ENEMY_DOCTRINES.forEach((doctrine) => {
    if (!doctrine.name.trim() || !doctrine.shortDescription.trim() || !doctrine.threatWarning.trim() || !doctrine.counterplay.trim()) {
      errors.push(`Enemy doctrine ${doctrine.id} needs player-facing copy.`);
    }
    if (doctrine.tags.length === 0) {
      errors.push(`Enemy doctrine ${doctrine.id} needs at least one tag.`);
    }
    doctrine.preferredMissionTypeIds.forEach((missionTypeId) => {
      if (!context.campaignMissionTypeIds.has(missionTypeId)) {
        errors.push(`Enemy doctrine ${doctrine.id} references missing mission type ${missionTypeId}.`);
      }
    });
    doctrine.preferredModifierIds.forEach((modifierId) => {
      if (!context.campaignModifierIds.has(modifierId)) {
        errors.push(`Enemy doctrine ${doctrine.id} references missing modifier ${modifierId}.`);
      }
    });
    const activity = doctrine.activity;
    if (activity.resourceRaidCooldownMultiplier !== undefined && (activity.resourceRaidCooldownMultiplier < 0.65 || activity.resourceRaidCooldownMultiplier > 1.15)) {
      errors.push(`Enemy doctrine ${doctrine.id} has unsafe raid cooldown multiplier.`);
    }
    if (activity.resourceRaidSquadBonus !== undefined && (activity.resourceRaidSquadBonus < 0 || activity.resourceRaidSquadBonus > 1)) {
      errors.push(`Enemy doctrine ${doctrine.id} has unsafe raid squad bonus.`);
    }
    if (activity.defenseReserveBonus !== undefined && (activity.defenseReserveBonus < 0 || activity.defenseReserveBonus > 1)) {
      errors.push(`Enemy doctrine ${doctrine.id} has unsafe defense reserve bonus.`);
    }
    if (activity.attackWaveSizeBonus !== undefined && (activity.attackWaveSizeBonus < 0 || activity.attackWaveSizeBonus > 1)) {
      errors.push(`Enemy doctrine ${doctrine.id} has unsafe attack wave bonus.`);
    }
  });
}

export function validateEnemyEliteSquads(errors: string[], context: ValidationContext): void {
  assertUniqueIds(ENEMY_ELITE_SQUADS, "Enemy elite squad", errors);
  const doctrineIds = new Set(ENEMY_DOCTRINES.map((doctrine) => doctrine.id));
  ENEMY_ELITE_SQUADS.forEach((squad) => {
    if (!squad.name.trim() || !squad.shortLabel.trim() || !squad.description.trim() || !squad.counterplay.trim()) {
      errors.push(`Enemy elite squad ${squad.id} needs player-facing copy.`);
    }
    squad.eligibleDoctrineIds.forEach((doctrineId) => {
      if (!doctrineIds.has(doctrineId)) {
        errors.push(`Enemy elite squad ${squad.id} references missing doctrine ${doctrineId}.`);
      }
    });
    squad.eligibleMissionTypeIds.forEach((missionTypeId) => {
      if (!context.campaignMissionTypeIds.has(missionTypeId)) {
        errors.push(`Enemy elite squad ${squad.id} references missing mission type ${missionTypeId}.`);
      }
    });
    squad.eligibleUnitIds.forEach((unitId) => {
      if (!context.unitIds.has(unitId)) {
        errors.push(`Enemy elite squad ${squad.id} references missing unit ${unitId}.`);
      }
    });
    if (!Number.isInteger(squad.maxUnitsPerBattle) || squad.maxUnitsPerBattle < 1 || squad.maxUnitsPerBattle > 2) {
      errors.push(`Enemy elite squad ${squad.id} has unsafe max units.`);
    }
    if (squad.maxHpMultiplier < 1 || squad.maxHpMultiplier > 1.1) {
      errors.push(`Enemy elite squad ${squad.id} has unsafe HP multiplier.`);
    }
    if (squad.damageMultiplier < 1 || squad.damageMultiplier > 1.08) {
      errors.push(`Enemy elite squad ${squad.id} has unsafe damage multiplier.`);
    }
    if (!Number.isInteger(squad.armorBonus) || squad.armorBonus < 0 || squad.armorBonus > 1) {
      errors.push(`Enemy elite squad ${squad.id} has unsafe armor bonus.`);
    }
  });
}
