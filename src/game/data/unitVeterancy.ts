import type {
  CombatStats,
  UnitVeterancyBattleSummary,
  UnitVeterancyRankDefinition,
  UnitVeterancyRankId,
  UnitVeterancyRankUpEvent,
  UnitVeterancyState,
  UnitVeterancySummaryEntry
} from "../core/GameTypes";

export const UNIT_VETERANCY_RANKS: readonly UnitVeterancyRankDefinition[] = [
  {
    id: "recruit",
    name: "Recruit",
    minXp: 0,
    maxHpMultiplier: 1,
    damageMultiplier: 1,
    armorBonus: 0,
    flavorText: "New to the line."
  },
  {
    id: "seasoned",
    name: "Seasoned",
    minXp: 55,
    maxHpMultiplier: 1.04,
    damageMultiplier: 1.04,
    armorBonus: 0,
    flavorText: "Steady under pressure."
  },
  {
    id: "veteran",
    name: "Veteran",
    minXp: 130,
    maxHpMultiplier: 1.08,
    damageMultiplier: 1.08,
    armorBonus: 0,
    flavorText: "Trusted in the hard fighting."
  },
  {
    id: "elite",
    name: "Elite",
    minXp: 230,
    maxHpMultiplier: 1.12,
    damageMultiplier: 1.12,
    armorBonus: 1,
    flavorText: "A standard others rally around."
  }
];

export const UNIT_VETERANCY_XP_RULES = {
  damageDivisor: 4,
  survivalXp: 12
} as const;

export interface UnitVeterancyXpResult {
  state: UnitVeterancyState;
  xpGained: number;
  previousRank: UnitVeterancyRankDefinition;
  currentRank: UnitVeterancyRankDefinition;
  rankedUp: boolean;
}

export interface UnitVeterancySummarySource {
  state: UnitVeterancyState;
  unitName: string;
}

const rankById = new Map(UNIT_VETERANCY_RANKS.map((rank) => [rank.id, rank]));

export const getUnitVeterancyRank = (rankId: UnitVeterancyRankId): UnitVeterancyRankDefinition => {
  const rank = rankById.get(rankId);
  if (!rank) {
    throw new Error(`Unknown unit veterancy rank: ${rankId}`);
  }
  return rank;
};

export const isUnitVeterancyRankId = (value: unknown): value is UnitVeterancyRankId =>
  typeof value === "string" && rankById.has(value as UnitVeterancyRankId);

export const getUnitVeterancyRankForXp = (xp: number): UnitVeterancyRankDefinition => {
  const normalizedXp = Math.max(0, Math.floor(xp));
  let current = UNIT_VETERANCY_RANKS[0];
  for (const rank of UNIT_VETERANCY_RANKS) {
    if (normalizedXp >= rank.minXp) {
      current = rank;
    }
  }
  return current;
};

export const getNextUnitVeterancyRankForXp = (xp: number): UnitVeterancyRankDefinition | undefined => {
  const current = getUnitVeterancyRankForXp(xp);
  return UNIT_VETERANCY_RANKS.find((rank) => rank.minXp > current.minXp);
};

export const formatUnitVeterancyXpProgress = (xp: number): string => {
  const normalizedXp = Math.max(0, Math.floor(xp));
  const nextRank = getNextUnitVeterancyRankForXp(normalizedXp);
  if (!nextRank) {
    return `${normalizedXp} XP - max rank`;
  }
  return `${normalizedXp}/${nextRank.minXp} XP to ${nextRank.name}`;
};

export const formatUnitVeterancyBonusSummary = (rankId: UnitVeterancyRankId): string => {
  const rank = getUnitVeterancyRank(rankId);
  const bonuses: string[] = [];
  const hpPercent = Math.round((rank.maxHpMultiplier - 1) * 100);
  const damagePercent = Math.round((rank.damageMultiplier - 1) * 100);
  if (hpPercent !== 0) {
    bonuses.push(`${hpPercent > 0 ? "+" : ""}${hpPercent}% HP`);
  }
  if (damagePercent !== 0) {
    bonuses.push(`${damagePercent > 0 ? "+" : ""}${damagePercent}% damage`);
  }
  if (rank.armorBonus !== 0) {
    bonuses.push(`${rank.armorBonus > 0 ? "+" : ""}${rank.armorBonus} armor`);
  }
  return bonuses.length > 0 ? bonuses.join(", ") : "No rank bonus yet";
};

export const createUnitVeterancyState = (
  unitInstanceId: string,
  unitTypeId: string,
  xp = 0
): UnitVeterancyState => {
  const rank = getUnitVeterancyRankForXp(xp);
  return {
    unitInstanceId,
    unitTypeId,
    xp: Math.max(0, Math.floor(xp)),
    rank: rank.id,
    kills: 0,
    damageDealt: 0,
    survivedBattle: false,
    rankedUpThisBattle: false
  };
};

export const addUnitVeterancyXp = (
  state: UnitVeterancyState,
  amount: number
): UnitVeterancyXpResult => {
  const xpGained = Math.max(0, Math.floor(amount));
  const previousRank = getUnitVeterancyRank(state.rank);
  const nextXp = Math.max(0, Math.floor(state.xp + xpGained));
  const currentRank = getUnitVeterancyRankForXp(nextXp);
  const rankedUp = currentRank.minXp > previousRank.minXp;

  return {
    state: {
      ...state,
      xp: nextXp,
      rank: currentRank.id,
      rankedUpThisBattle: state.rankedUpThisBattle || rankedUp
    },
    xpGained,
    previousRank,
    currentRank,
    rankedUp
  };
};

export const recordUnitVeterancyDamage = (
  state: UnitVeterancyState,
  amount: number
): UnitVeterancyState => ({
  ...state,
  damageDealt: state.damageDealt + Math.max(0, Math.round(amount))
});

export const recordUnitVeterancyKill = (state: UnitVeterancyState): UnitVeterancyState => ({
  ...state,
  kills: state.kills + 1
});

export const markUnitVeterancySurvived = (state: UnitVeterancyState): UnitVeterancyState => ({
  ...state,
  survivedBattle: true
});

export const getUnitVeterancyXpForDamage = (amount: number): number => {
  if (amount <= 0) {
    return 0;
  }
  return Math.max(1, Math.floor(amount / UNIT_VETERANCY_XP_RULES.damageDivisor));
};

export const getUnitVeterancyXpForKill = (xpValue: number): number =>
  Math.max(0, Math.round(xpValue));

export const applyUnitVeterancyStatBonuses = (
  stats: CombatStats,
  rankId: UnitVeterancyRankId
): CombatStats => {
  const rank = getUnitVeterancyRank(rankId);
  return {
    ...stats,
    maxHp: Math.round(stats.maxHp * rank.maxHpMultiplier),
    damage: Math.round(stats.damage * rank.damageMultiplier * 10) / 10,
    armor: stats.armor + rank.armorBonus
  };
};

export const createUnitVeterancyRankUpEvent = (
  source: UnitVeterancySummarySource,
  fromRank: UnitVeterancyRankId,
  toRank: UnitVeterancyRankId
): UnitVeterancyRankUpEvent => ({
  unitInstanceId: source.state.unitInstanceId,
  unitTypeId: source.state.unitTypeId,
  unitName: source.unitName,
  fromRank,
  toRank,
  xp: source.state.xp,
  kills: source.state.kills,
  damageDealt: source.state.damageDealt,
  survivedBattle: source.state.survivedBattle
});

const toSummaryEntry = (
  source: UnitVeterancySummarySource,
  rankedUp: boolean,
  previousRank?: UnitVeterancyRankId
): UnitVeterancySummaryEntry => {
  const rank = getUnitVeterancyRank(source.state.rank);
  return {
    unitInstanceId: source.state.unitInstanceId,
    unitTypeId: source.state.unitTypeId,
    unitName: source.unitName,
    xp: source.state.xp,
    rank: source.state.rank,
    rankName: rank.name,
    kills: source.state.kills,
    damageDealt: source.state.damageDealt,
    survivedBattle: source.state.survivedBattle,
    rankedUp,
    previousRank
  };
};

const compareVeterancyEntries = (
  left: UnitVeterancySummaryEntry,
  right: UnitVeterancySummaryEntry
): number => {
  const leftRank = getUnitVeterancyRank(left.rank);
  const rightRank = getUnitVeterancyRank(right.rank);
  return (
    rightRank.minXp - leftRank.minXp ||
    right.xp - left.xp ||
    right.kills - left.kills ||
    right.damageDealt - left.damageDealt
  );
};

export const createUnitVeterancyBattleSummary = (
  survivingUnits: UnitVeterancySummarySource[],
  rankUpEvents: UnitVeterancyRankUpEvent[]
): UnitVeterancyBattleSummary => {
  const survivorEntries = survivingUnits.map((source) =>
    toSummaryEntry(source, source.state.rankedUpThisBattle)
  );
  const survivingById = new Map(survivingUnits.map((source) => [source.state.unitInstanceId, source]));
  const latestRankUpById = new Map<string, UnitVeterancyRankUpEvent>();

  for (const event of rankUpEvents) {
    latestRankUpById.set(event.unitInstanceId, event);
  }

  const rankedUpUnits = Array.from(latestRankUpById.values())
    .map((event) => {
      const survivor = survivingById.get(event.unitInstanceId);
      if (survivor) {
        return toSummaryEntry(survivor, true, event.fromRank);
      }
      const rank = getUnitVeterancyRank(event.toRank);
      return {
        unitInstanceId: event.unitInstanceId,
        unitTypeId: event.unitTypeId,
        unitName: event.unitName,
        xp: event.xp,
        rank: event.toRank,
        rankName: rank.name,
        kills: event.kills,
        damageDealt: event.damageDealt,
        survivedBattle: event.survivedBattle,
        rankedUp: true,
        previousRank: event.fromRank
      };
    })
    .sort(compareVeterancyEntries);

  const [topSurvivor] = [...survivorEntries].sort(compareVeterancyEntries);
  const notableById = new Map<string, UnitVeterancySummaryEntry>();

  for (const entry of rankedUpUnits) {
    notableById.set(entry.unitInstanceId, entry);
  }
  if (topSurvivor) {
    notableById.set(topSurvivor.unitInstanceId, topSurvivor);
  }
  for (const entry of survivorEntries.filter((entry) => entry.rank !== "recruit")) {
    notableById.set(entry.unitInstanceId, entry);
  }

  return {
    rankedUpUnits,
    notableVeterans: Array.from(notableById.values()).sort(compareVeterancyEntries),
    topSurvivor
  };
};
