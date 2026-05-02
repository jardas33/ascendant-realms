import { CAMPAIGN_NODES } from "../campaignNodes";
import { ENEMY_HERO_ABILITIES, ENEMY_HEROES } from "../enemyHeroes";
import { MAPS } from "../maps";
import { assertUniqueIds, validateCombatStats, type ValidationContext } from "./ValidationTypes";

export function validateEnemyHeroes(errors: string[], context: ValidationContext): void {
  assertUniqueIds(ENEMY_HERO_ABILITIES, "enemy hero ability", errors);
  ENEMY_HERO_ABILITIES.forEach((ability) => {
    if (!ability.name.trim() || !ability.description.trim()) {
      errors.push(`Enemy hero ability ${ability.id} needs name and description.`);
    }
    if (ability.cooldownSeconds <= 0 || ability.range < 0) {
      errors.push(`Enemy hero ability ${ability.id} has invalid timing or range.`);
    }
    validateAbilityEffect(ability.id, ability.effect, errors);
  });

  assertUniqueIds(ENEMY_HEROES, "enemy hero", errors);
  ENEMY_HEROES.forEach((hero) => {
    if (!hero.name.trim() || !hero.title.trim() || !hero.flavorText.trim()) {
      errors.push(`Enemy hero ${hero.id} needs name, title, and flavor text.`);
    }
    if (!context.factionIds.has(hero.factionId)) {
      errors.push(`Enemy hero ${hero.id} references missing faction ${hero.factionId}.`);
    }
    if (!context.aiPersonalityIds.has(hero.personalityId)) {
      errors.push(`Enemy hero ${hero.id} references missing AI personality ${hero.personalityId}.`);
    }
    if (!context.unitIds.has(hero.unitId)) {
      errors.push(`Enemy hero ${hero.id} references missing unit ${hero.unitId}.`);
    }
    if (hero.level <= 0 || hero.xpValue <= 0) {
      errors.push(`Enemy hero ${hero.id} has invalid level or XP value.`);
    }
    validateCombatStats(`Enemy hero ${hero.id}`, hero.stats, errors);
    if (hero.stats.maxHp <= 0 || hero.stats.attackCooldown <= 0) {
      errors.push(`Enemy hero ${hero.id} has invalid HP or attack cooldown.`);
    }
    hero.abilities.forEach((abilityId) => {
      if (!context.enemyHeroAbilityIds.has(abilityId)) {
        errors.push(`Enemy hero ${hero.id} references missing ability ${abilityId}.`);
      }
    });
    hero.campaignNodeIds.forEach((nodeId) => {
      const node = CAMPAIGN_NODES.find((entry) => entry.id === nodeId);
      if (!node) {
        errors.push(`Enemy hero ${hero.id} references missing campaign node ${nodeId}.`);
        return;
      }
      if (node.enemyHeroId && node.enemyHeroId !== hero.id) {
        errors.push(`Enemy hero ${hero.id} claims campaign node ${nodeId}, but node assigns ${node.enemyHeroId}.`);
      }
    });
    hero.mapIds.forEach((mapId) => {
      if (!MAPS.some((map) => map.id === mapId)) {
        errors.push(`Enemy hero ${hero.id} references missing map ${mapId}.`);
      }
    });
  });

  CAMPAIGN_NODES.forEach((node) => {
    if (!node.enemyHeroId) {
      return;
    }
    const hero = ENEMY_HEROES.find((entry) => entry.id === node.enemyHeroId);
    if (hero && !hero.campaignNodeIds.includes(node.id)) {
      errors.push(`Campaign node ${node.id} assigns enemy hero ${hero.id}, but the hero does not list that node.`);
    }
  });
}

function validateAbilityEffect(
  abilityId: string,
  effect: (typeof ENEMY_HERO_ABILITIES)[number]["effect"],
  errors: string[]
): void {
  if (effect.type === "damage-and-burn") {
    if (effect.damage <= 0 || effect.burn.damagePerSecond <= 0 || effect.burn.durationSeconds <= 0 || effect.burn.tickInterval <= 0) {
      errors.push(`Enemy hero ability ${abilityId} has invalid damage-and-burn values.`);
    }
    return;
  }
  if (effect.type === "damage-buff") {
    if (effect.multiplier <= 1 || effect.durationSeconds <= 0 || effect.radius <= 0 || (effect.maxTargets ?? 1) <= 0) {
      errors.push(`Enemy hero ability ${abilityId} has invalid damage-buff values.`);
    }
    return;
  }
  if (effect.type === "direct-damage") {
    if (effect.damage <= 0) {
      errors.push(`Enemy hero ability ${abilityId} has invalid direct-damage values.`);
    }
    return;
  }
  if (effect.armorBonus <= 0 || effect.durationSeconds <= 0 || effect.radius <= 0) {
    errors.push(`Enemy hero ability ${abilityId} has invalid armor-aura values.`);
  }
}
