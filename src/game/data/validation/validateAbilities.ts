import { ABILITIES } from "../abilities";
import { HERO_CLASSES } from "../heroClasses";
import { SKILL_NODES } from "../skillTrees";
import { validateCombatStats, validatePrerequisites, type ValidationContext } from "./ValidationTypes";

export function validateAbilities(errors: string[], context: ValidationContext): void {
  ABILITIES.forEach((ability) => {
    if (!context.heroClassIds.has(ability.heroClassId)) {
      errors.push(`Ability ${ability.id} references missing hero class ${ability.heroClassId}.`);
    }
    if (!ability.hotkey.trim()) {
      errors.push(`Ability ${ability.id} needs a hotkey.`);
    }
    if (ability.manaCost < 0) {
      errors.push(`Ability ${ability.id} cannot have a negative mana cost.`);
    }
    if (ability.cooldown < 0) {
      errors.push(`Ability ${ability.id} cannot have a negative cooldown.`);
    }
    if (ability.range < 0 || ability.radius < 0 || ability.duration < 0) {
      errors.push(`Ability ${ability.id} has a negative range, radius, or duration.`);
    }
    validatePrerequisites(`Ability ${ability.id}`, ability.prerequisites, errors, context);
  });
}

export function validateHeroClasses(errors: string[], context: ValidationContext): void {
  HERO_CLASSES.forEach((heroClass) => {
    if (!context.abilityIds.has(heroClass.primaryAbilityId)) {
      errors.push(`Hero class ${heroClass.id} references missing primary ability ${heroClass.primaryAbilityId}.`);
    }
    heroClass.abilityIds.forEach((abilityId) => {
      if (!context.abilityIds.has(abilityId)) {
        errors.push(`Hero class ${heroClass.id} references missing ability ${abilityId}.`);
      }
    });
    if (!heroClass.abilityIds.includes(heroClass.primaryAbilityId)) {
      errors.push(`Hero class ${heroClass.id} must include its primary ability in abilityIds.`);
    }
    if (heroClass.visionRadius <= 0) {
      errors.push(`Hero class ${heroClass.id} must have a positive vision radius.`);
    }
    validateCombatStats(`Hero class ${heroClass.id}`, heroClass.baseStats, errors);
    if (heroClass.baseStats.maxMana < 0) {
      errors.push(`Hero class ${heroClass.id} cannot have negative max mana.`);
    }
  });
}

export function validateSkillNodes(errors: string[], context: ValidationContext): void {
  HERO_CLASSES.forEach((heroClass) => {
    context.skillTreeIds.forEach((treeId) => {
      const visibleCount = SKILL_NODES.filter((node) => node.treeId === treeId && !node.hidden && (!node.classId || node.classId === heroClass.id)).length;
      if (visibleCount < 2 || visibleCount > 3) {
        errors.push(`Skill tree ${treeId} must show 2-3 visible nodes for hero class ${heroClass.id}; found ${visibleCount}.`);
      }
    });
  });
  SKILL_NODES.forEach((node) => {
    if (!context.skillTreeIds.has(node.treeId)) {
      errors.push(`Skill node ${node.id} references missing tree ${node.treeId}.`);
    }
    if (node.classId && !context.heroClassIds.has(node.classId)) {
      errors.push(`Skill node ${node.id} references missing hero class ${node.classId}.`);
    }
    if (node.unlockAbilityId && !context.abilityIds.has(node.unlockAbilityId)) {
      errors.push(`Skill node ${node.id} unlocks missing ability ${node.unlockAbilityId}.`);
    }
    if (node.buildArchetype && !["warrior", "seer", "commander"].includes(node.buildArchetype)) {
      errors.push(`Skill node ${node.id} has invalid build archetype ${node.buildArchetype}.`);
    }
    if (node.maxRank <= 0) {
      errors.push(`Skill node ${node.id} must have a positive max rank.`);
    }
    if (node.costPerRank <= 0) {
      errors.push(`Skill node ${node.id} must have a positive cost per rank.`);
    }
    node.requires?.forEach((requirement) => {
      if (!context.skillNodeIds.has(requirement.skillId)) {
        errors.push(`Skill node ${node.id} requires missing skill ${requirement.skillId}.`);
      }
      if (requirement.rank <= 0) {
        errors.push(`Skill node ${node.id} has a requirement with non-positive rank.`);
      }
    });
    if (node.abilityUpgrade) {
      if (!node.abilityUpgrade.effectSummary.trim()) {
        errors.push(`Skill node ${node.id} ability upgrade needs effect summary.`);
      }
      const abilityIds = node.abilityUpgrade.abilityIds;
      if (abilityIds !== "all") {
        abilityIds.forEach((abilityId) => {
          if (!context.abilityIds.has(abilityId)) {
            errors.push(`Skill node ${node.id} ability upgrade references missing ability ${abilityId}.`);
          }
        });
      }
      const hasDelta = [
        node.abilityUpgrade.amountDelta,
        node.abilityUpgrade.manaCostDelta,
        node.abilityUpgrade.cooldownDelta,
        node.abilityUpgrade.radiusDelta,
        node.abilityUpgrade.durationDelta
      ].some((value) => typeof value === "number" && value !== 0);
      if (!hasDelta) {
        errors.push(`Skill node ${node.id} ability upgrade must change at least one ability value.`);
      }
    }
  });
}
