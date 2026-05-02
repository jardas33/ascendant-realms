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
  });
}
