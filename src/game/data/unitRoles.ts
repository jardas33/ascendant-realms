export const UNIT_ROLE_TAGS = [
  "frontline",
  "melee",
  "holds-ground",
  "ranged",
  "focus-fire",
  "fragile",
  "aether",
  "support",
  "special-damage",
  "commander",
  "champion",
  "utility",
  "build",
  "repair",
  "site-support",
  "enemy-pressure",
  "neutral-threat"
] as const;

export type UnitRoleTag = (typeof UNIT_ROLE_TAGS)[number];

export interface UnitRoleIdentity {
  unitId: string;
  label: string;
  tags: readonly UnitRoleTag[];
  summary: string;
  tacticalHint: string;
}

export const PLAYER_UNIT_ROLE_IDS = ["worker", "militia", "ranger", "acolyte"] as const;

export const HERO_ROLE_IDENTITY: UnitRoleIdentity = {
  unitId: "hero",
  label: "Commander / Champion",
  tags: ["commander", "champion"],
  summary: "Hero centerpiece that anchors fights, spends skills, and carries relic build identity.",
  tacticalHint: "Keep the hero near the army, then spend skill points and equip a matching relic after victories."
};

export const UNIT_ROLE_IDENTITIES: readonly UnitRoleIdentity[] = [
  {
    unitId: "worker",
    label: "Utility / Site Support",
    tags: ["utility", "build", "repair", "site-support"],
    summary: "Builder and economy support. Workers are useful in combat only as a last resort.",
    tacticalHint: "Use Workers to build, repair, finish construction, and boost captured resource sites."
  },
  {
    unitId: "militia",
    label: "Frontline / Melee",
    tags: ["frontline", "melee", "holds-ground"],
    summary: "Durable enough to stand in front and hold enemies away from fragile units.",
    tacticalHint: "Put Militia in front, use Hold Ground when defending, and let them screen Rangers or Acolytes."
  },
  {
    unitId: "ranger",
    label: "Ranged / Focus Fire",
    tags: ["ranged", "focus-fire", "fragile"],
    summary: "Longer-ranged damage that needs space and frontline cover.",
    tacticalHint: "Focus Rangers on priority targets from behind Militia; move them if enemies close the gap."
  },
  {
    unitId: "acolyte",
    label: "Aether / Support Damage",
    tags: ["aether", "support", "special-damage", "fragile"],
    summary: "Fragile aether attacker that helps finish armored or dangerous targets from range.",
    tacticalHint: "Keep Acolytes protected and use them to add special ranged damage to focused fights."
  },
  {
    unitId: "raider",
    label: "Enemy Pressure / Melee",
    tags: ["enemy-pressure", "melee"],
    summary: "Fast melee pressure that contests workers, sites, and exposed ranged units.",
    tacticalHint: "Screen with Militia and avoid letting Raiders reach fragile backline units."
  },
  {
    unitId: "hexer",
    label: "Enemy Aether / Ranged",
    tags: ["enemy-pressure", "aether", "ranged"],
    summary: "Fragile ranged caster that punishes clumped or wounded units.",
    tacticalHint: "Focus fire Hexers before they chip down grouped troops."
  },
  {
    unitId: "brute",
    label: "Enemy Frontline / Heavy",
    tags: ["enemy-pressure", "frontline", "melee"],
    summary: "Slow heavy melee unit built to soak damage during enemy pushes.",
    tacticalHint: "Kite Brutes with range and do not let them tie up fragile units for long."
  },
  {
    unitId: "enemy_commander",
    label: "Enemy Commander / Champion",
    tags: ["enemy-pressure", "commander", "champion"],
    summary: "Rival battlefield leader that turns larger enemy attacks into a serious threat.",
    tacticalHint: "Defeating the commander is a major objective and can unlock the relic reward flow."
  },
  {
    unitId: "wild_hound",
    label: "Neutral Threat / Fast",
    tags: ["neutral-threat", "melee"],
    summary: "Fast neutral monster that punishes isolated units.",
    tacticalHint: "Clear camps with a small group rather than a single fragile unit."
  },
  {
    unitId: "stone_imp",
    label: "Neutral Threat / Tough",
    tags: ["neutral-threat", "frontline", "melee"],
    summary: "Tough neutral monster guarding side routes and ruins.",
    tacticalHint: "Bring enough damage before fighting tough neutral camps."
  }
];

const UNIT_ROLE_BY_ID = new Map(UNIT_ROLE_IDENTITIES.map((identity) => [identity.unitId, identity]));

export function getUnitRoleIdentity(unitId: string): UnitRoleIdentity {
  if (unitId === HERO_ROLE_IDENTITY.unitId || unitId.startsWith("hero_")) {
    return HERO_ROLE_IDENTITY;
  }
  return (
    UNIT_ROLE_BY_ID.get(unitId) ?? {
      unitId,
      label: "Battle Unit",
      tags: [],
      summary: "Standard combat role.",
      tacticalHint: "Use current orders and unit stats to decide its battlefield job."
    }
  );
}

export function formatUnitRoleTags(identity: UnitRoleIdentity): string {
  return identity.tags.map(formatUnitRoleTag).join(" / ");
}

export function formatUnitRoleTag(tag: UnitRoleTag): string {
  return tag
    .split("-")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

export function summarizeUnitRoleMix(units: readonly { definition: { id: string } }[]): string {
  const counts = units.reduce<Record<string, number>>((summary, unit) => {
    const label = getUnitRoleIdentity(unit.definition.id).label;
    summary[label] = (summary[label] ?? 0) + 1;
    return summary;
  }, {});

  return Object.entries(counts)
    .map(([label, count]) => `${count} ${label}`)
    .join(", ");
}
