import type {
  EnemyHeroAbilityDefinition,
  EnemyHeroAbilityId,
  EnemyHeroDefinition,
  UnitDefinition
} from "../core/GameTypes";

export const ENEMY_HERO_ABILITIES: EnemyHeroAbilityDefinition[] = [
  {
    id: "ember_strike",
    name: "Ember Strike",
    description: "A close strike that deals a burst of damage and leaves a short burn.",
    cooldownSeconds: 10,
    range: 48,
    effect: {
      type: "damage-and-burn",
      damage: 18,
      burn: {
        damagePerSecond: 3,
        durationSeconds: 3,
        tickInterval: 1
      }
    }
  },
  {
    id: "rally_raiders",
    name: "Rally Raiders",
    description: "Nearby raiders briefly hit harder while the commander holds formation.",
    cooldownSeconds: 18,
    range: 210,
    effect: {
      type: "damage-buff",
      multiplier: 1.18,
      durationSeconds: 5,
      radius: 190,
      maxTargets: 5
    }
  },
  {
    id: "hexfire_bolt",
    name: "Hexfire Bolt",
    description: "A measured ranged spell that punishes exposed troops.",
    cooldownSeconds: 8,
    range: 185,
    effect: {
      type: "direct-damage",
      damage: 20,
      projectileColor: 0xb775ff
    }
  },
  {
    id: "hold_the_line",
    name: "Hold the Line",
    description: "A fortress order that briefly reinforces nearby defenders.",
    cooldownSeconds: 20,
    range: 230,
    effect: {
      type: "armor-aura",
      armorBonus: 2,
      durationSeconds: 6,
      radius: 215,
      requiresNearEnemyBase: true
    }
  }
];

export const ENEMY_HERO_ABILITY_BY_ID: Record<EnemyHeroAbilityId, EnemyHeroAbilityDefinition> =
  Object.fromEntries(ENEMY_HERO_ABILITIES.map((ability) => [ability.id, ability])) as Record<
    EnemyHeroAbilityId,
    EnemyHeroAbilityDefinition
  >;

export const ENEMY_HEROES: EnemyHeroDefinition[] = [
  {
    id: "gorak_emberhand",
    name: "Gorak Emberhand",
    title: "Ashen Raider Captain",
    factionId: "ashen_covenant",
    personalityId: "fortress_keeper",
    archetype: "melee_commander",
    level: 3,
    unitId: "enemy_commander",
    stats: {
      maxHp: 235,
      damage: 17,
      range: 38,
      attackCooldown: 1.05,
      speed: 92,
      armor: 3
    },
    xpValue: 130,
    abilities: ["ember_strike", "rally_raiders"],
    flavorText: "Gorak keeps the hillfort raiders in a tight, angry line until he sees the assault fully form.",
    campaignNodeIds: ["bandit_hillfort"],
    mapIds: ["broken_ford"]
  },
  {
    id: "veyra_cinders",
    name: "Veyra of the Cinders",
    title: "Hexfire Seer",
    factionId: "ashen_covenant",
    personalityId: "hexfire_cult",
    archetype: "hexfire_seer",
    level: 3,
    unitId: "enemy_commander",
    stats: {
      maxHp: 180,
      damage: 12,
      range: 170,
      attackCooldown: 1.35,
      speed: 84,
      armor: 1
    },
    xpValue: 135,
    abilities: ["hexfire_bolt", "rally_raiders"],
    flavorText: "Veyra reads the smoke around the Aether Well and punishes armies that cross the ford unsupported.",
    campaignNodeIds: ["aether_well_ruins"],
    mapIds: ["broken_ford"]
  },
  {
    id: "captain_malrec",
    name: "Captain Malrec",
    title: "Outpost Commander",
    factionId: "ashen_covenant",
    personalityId: "hexfire_cult",
    archetype: "fortress_commander",
    level: 4,
    unitId: "enemy_commander",
    stats: {
      maxHp: 265,
      damage: 16,
      range: 42,
      attackCooldown: 1.15,
      speed: 82,
      armor: 4
    },
    xpValue: 165,
    abilities: ["hold_the_line", "rally_raiders", "ember_strike"],
    flavorText:
      "Malrec believes disciplined control over Lume is the only way to prevent collapse; he waits behind the outpost ridge before committing to the final defense.",
    campaignNodeIds: ["ashen_outpost"],
    mapIds: ["ashen_outpost"]
  }
];

export const ENEMY_HERO_BY_ID: Record<string, EnemyHeroDefinition> = Object.fromEntries(
  ENEMY_HEROES.map((hero) => [hero.id, hero])
);

export function requireEnemyHero(id: string): EnemyHeroDefinition {
  const definition = ENEMY_HERO_BY_ID[id];
  if (!definition) {
    throw new Error(`Unknown enemy hero id: ${id}`);
  }
  return definition;
}

export function createEnemyHeroUnitDefinition(hero: EnemyHeroDefinition, baseUnit: UnitDefinition): UnitDefinition {
  return {
    ...baseUnit,
    name: hero.name,
    factionId: hero.factionId,
    role: hero.title,
    description: hero.flavorText,
    stats: { ...hero.stats },
    xpValue: hero.xpValue,
    projectileColor: hero.abilities.includes("hexfire_bolt") ? 0xb775ff : baseUnit.projectileColor
  };
}
