import { describe, expect, it } from "vitest";
import { AI_PERSONALITIES } from "./aiPersonalities";
import { BATTLE_DIFFICULTIES } from "./battlePacing";
import { CAMPAIGN_NODES } from "./campaignNodes";
import { DEFAULT_AGGRO_RADIUS, FORMATION_SPACING } from "../core/Constants";
import { FACTIONS } from "./factions";
import { ITEM_AFFIXES } from "./itemAffixes";
import { MAPS } from "./maps";
import { ENEMY_HERO_ABILITIES, ENEMY_HEROES, createEnemyHeroUnitDefinition } from "./enemyHeroes";
import { REPUTATION_EFFECTS, TRACKED_REPUTATION_FACTION_IDS } from "./reputation";
import { REWARD_TABLES } from "./rewards";
import { RIVAL_REWARDS } from "./rivalRewards";
import { STRONGHOLD_UPGRADES } from "./strongholdUpgrades";
import { validateContent } from "./contentValidation";
import { UNIT_BY_ID } from "./contentIndex";

describe("content validation", () => {
  it("keeps data references valid for non-coder edits", () => {
    expect(validateContent()).toEqual([]);
  });

  it("covers multiple skirmish maps with complete setup metadata", () => {
    expect(MAPS.map((map) => map.id)).toEqual(expect.arrayContaining(["first_claim", "broken_ford", "ashen_outpost"]));
    MAPS.forEach((map) => {
      expect(map.role.length).toBeGreaterThan(0);
      expect(map.description.length).toBeGreaterThan(0);
      expect(map.captureSites.length).toBeGreaterThan(0);
      expect(map.neutralCamps.length).toBeGreaterThan(0);
      expect(map.visualPaths.length).toBeGreaterThan(0);
      expect(map.scenario.objectives).toMatchObject({
        playerBaseBuildingId: "command_hall",
        enemyBaseBuildingId: "enemy_stronghold"
      });
    });
    expect(MAPS.find((map) => map.id === "broken_ford")?.captureSites).toHaveLength(4);
    expect(MAPS.find((map) => map.id === "broken_ford")?.neutralCamps).toHaveLength(3);
    const ashenOutpost = MAPS.find((map) => map.id === "ashen_outpost");
    expect(ashenOutpost?.captureSites).toHaveLength(4);
    expect(ashenOutpost?.neutralCamps).toHaveLength(3);
    expect(ashenOutpost?.scenario.rewardTableId).toBe("ashen_outpost_rewards");
    expect(ashenOutpost?.scenario.objectives.secondaryObjectives?.map((objective) => objective.id)).toEqual(
      expect.arrayContaining(["capture_burned_shrine", "destroy_enemy_barracks", "defeat_outpost_captain"])
    );
    expect(REWARD_TABLES.map((table) => table.id)).toContain("ashen_outpost_rewards");
  });

  it("keeps the First Claim tutorial capture clear of neutral camp aggro", () => {
    const firstClaim = MAPS.find((map) => map.id === "first_claim");
    const crownShrine = firstClaim?.captureSites.find((site) => site.id === "crown_shrine");
    const sunkenRoadPack = firstClaim?.neutralCamps.find((camp) => camp.id === "sunken_road_pack");
    expect(firstClaim).toBeTruthy();
    expect(crownShrine).toBeTruthy();
    expect(sunkenRoadPack).toBeTruthy();

    const safeOpeningDistance = DEFAULT_AGGRO_RADIUS + (crownShrine?.radius ?? 0) + FORMATION_SPACING * 3;
    const actualDistance = Math.hypot(
      (sunkenRoadPack?.x ?? 0) - (crownShrine?.x ?? 0),
      (sunkenRoadPack?.y ?? 0) - (crownShrine?.y ?? 0)
    );
    expect(actualDistance).toBeGreaterThan(safeOpeningDistance);
  });

  it("defines the first mini-campaign chain", () => {
    expect(CAMPAIGN_NODES.map((node) => node.id)).toEqual(
      expect.arrayContaining([
        "border_village",
        "old_stone_road",
        "marcher_camp",
        "aether_well_ruins",
        "bandit_hillfort",
        "chapel_of_the_marches",
        "refugee_caravan",
        "ashen_outpost"
      ])
    );
    expect(CAMPAIGN_NODES).toHaveLength(8);
    expect(CAMPAIGN_NODES.find((node) => node.id === "chapel_of_the_marches")?.choices?.length).toBeGreaterThanOrEqual(3);
    expect(CAMPAIGN_NODES.find((node) => node.id === "refugee_caravan")?.choices?.length).toBeGreaterThanOrEqual(3);
    expect(CAMPAIGN_NODES.find((node) => node.id === "marcher_camp")?.choices?.length).toBeGreaterThanOrEqual(6);
  });

  it("assigns valid AI personalities to battle nodes", () => {
    const personalityIds = new Set(AI_PERSONALITIES.map((personality) => personality.id));
    CAMPAIGN_NODES.filter((node) => node.nodeType === "battle").forEach((node) => {
      expect(node.aiPersonalityId).toBeTruthy();
      if (node.aiPersonalityId) {
        expect(personalityIds.has(node.aiPersonalityId)).toBe(true);
      }
    });
    expect(CAMPAIGN_NODES.find((node) => node.id === "old_stone_road")?.aiPersonalityId).toBe("raider_rush");
    expect(CAMPAIGN_NODES.find((node) => node.id === "aether_well_ruins")?.aiPersonalityId).toBe("hexfire_cult");
    expect(CAMPAIGN_NODES.find((node) => node.id === "ashen_outpost")?.mapId).toBe("ashen_outpost");
    expect(CAMPAIGN_NODES.find((node) => node.id === "ashen_outpost")?.aiPersonalityId).toBe("hexfire_cult");
  });

  it("defines compact enemy hero commanders for campaign battles", () => {
    expect(ENEMY_HEROES.map((hero) => hero.id)).toEqual(["gorak_emberhand", "veyra_cinders", "captain_malrec"]);
    expect(CAMPAIGN_NODES.find((node) => node.id === "aether_well_ruins")?.enemyHeroId).toBe("veyra_cinders");
    expect(CAMPAIGN_NODES.find((node) => node.id === "bandit_hillfort")?.enemyHeroId).toBe("gorak_emberhand");
    expect(CAMPAIGN_NODES.find((node) => node.id === "ashen_outpost")?.enemyHeroId).toBe("captain_malrec");

    CAMPAIGN_NODES.filter((node) => node.enemyHeroId).forEach((node) => {
      const map = MAPS.find((entry) => entry.id === node.mapId);
      const difficulty = BATTLE_DIFFICULTIES.find((entry) => entry.id === node.difficulty);
      expect(difficulty?.enemyStartingUnitSpawnIds).toContain("enemy_commander_1");
      expect(map?.scenario.unitSpawns.some((spawn) => spawn.id === "enemy_commander_1" && spawn.unitId === "enemy_commander")).toBe(true);
    });

    const baseCommander = UNIT_BY_ID.enemy_commander;
    ENEMY_HEROES.forEach((hero) => {
      const unit = createEnemyHeroUnitDefinition(hero, baseCommander);
      expect(unit.id).toBe("enemy_commander");
      expect(unit.name).toBe(hero.name);
      expect(unit.stats.maxHp).toBeGreaterThan(150);
      expect(unit.stats.damage).toBeGreaterThan(0);
      expect(unit.xpValue).toBeGreaterThanOrEqual(120);
      hero.abilities.forEach((abilityId) => {
        expect(ENEMY_HERO_ABILITIES.some((ability) => ability.id === abilityId)).toBe(true);
      });
    });
  });

  it("defines first-defeat rival rewards and trophy records", () => {
    expect(RIVAL_REWARDS.map((reward) => reward.enemyHeroId)).toEqual([
      "gorak_emberhand",
      "veyra_cinders",
      "captain_malrec"
    ]);
    RIVAL_REWARDS.forEach((reward) => {
      expect(reward.firstDefeat.xp).toBeGreaterThan(0);
      expect(reward.firstDefeat.trophy.trophyId).toContain("trophy_");
      expect(reward.firstDefeat.trophy.label.length).toBeGreaterThan(0);
    });
  });

  it("defines asymmetric faction mechanics", () => {
    const freeMarches = FACTIONS.find((faction) => faction.id === "free_marches");
    const ashen = FACTIONS.find((faction) => faction.id === "ashen_covenant");

    expect(freeMarches?.mechanics.availableUnitIds).toEqual(expect.arrayContaining(["militia", "ranger", "acolyte"]));
    expect(ashen?.mechanics.availableUnitIds).toEqual(expect.arrayContaining(["raider", "hexer", "brute"]));
    expect(ashen?.mechanics.factionModifiers.map((modifier) => modifier.id)).toEqual(
      expect.arrayContaining(["hexfire_burn", "ashen_fury", "smoke_march"])
    );
    expect(ashen?.mechanics.aiPersonalityPreferences).toEqual(expect.arrayContaining(["raider_rush", "hexfire_cult"]));
  });

  it("defines compact Stronghold Tier II upgrades behind matching Tier I upgrades", () => {
    const tierTwoIds = STRONGHOLD_UPGRADES.filter((upgrade) => upgrade.tier === 2).map((upgrade) => upgrade.id);

    expect(tierTwoIds).toEqual([
      "training_yard_ii",
      "watch_post_ii",
      "quartermaster_stores_ii",
      "chapel_corner_ii",
      "ranger_paths_ii"
    ]);
    STRONGHOLD_UPGRADES.filter((upgrade) => upgrade.tier === 2).forEach((upgrade) => {
      const expectedPrerequisiteId = `${upgrade.id.slice(0, -3)}_i`;
      expect(upgrade.prerequisites.upgradeRanks).toMatchObject({ [expectedPrerequisiteId]: 1 });
      expect(upgrade.effects.length).toBeGreaterThan(0);
    });
  });

  it("defines compact reputation thresholds and campaign effects", () => {
    expect([...TRACKED_REPUTATION_FACTION_IDS]).toEqual([
      "free_marches",
      "common_folk",
      "old_faith",
      "ashen_covenant",
      "sylvan_concord"
    ]);
    expect(REPUTATION_EFFECTS.map((effect) => effect.id)).toEqual([
      "common_folk_friendly_services",
      "free_marches_friendly_stronghold",
      "old_faith_friendly_chapel",
      "ashen_covenant_hostile_pressure"
    ]);
  });

  it("defines the first compact item affix set", () => {
    expect(ITEM_AFFIXES.map((affix) => affix.id)).toEqual([
      "sturdy",
      "sharp",
      "guarding",
      "aether_touched",
      "commanding",
      "faithful",
      "swift",
      "embered",
      "rangers"
    ]);
    ITEM_AFFIXES.forEach((affix) => {
      expect(affix.allowedSlots.length).toBeGreaterThan(0);
      expect(Object.keys(affix.statMods).length).toBeGreaterThan(0);
      expect(affix.weight).toBeGreaterThan(0);
    });
  });
});
