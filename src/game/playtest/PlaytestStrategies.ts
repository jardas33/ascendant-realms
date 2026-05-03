import type { PlaytestScriptId, PlaytestStrategyDriver } from "./PlaytestTypes";

export const DEFAULT_PLAYTEST_SCRIPTS: PlaytestScriptId[] = ["safe_beginner", "greedy_economy", "fast_army"];

export function runStrategy(scriptId: PlaytestScriptId, driver: PlaytestStrategyDriver): void {
  if (scriptId === "safe_beginner") {
    runSafeBeginner(driver);
  } else if (scriptId === "greedy_economy") {
    runGreedyEconomy(driver);
  } else {
    runFastArmy(driver);
  }
}

function runSafeBeginner(driver: PlaytestStrategyDriver): void {
  driver.selectHero();
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["crown_shrine", "west_supply_pyre", "west_stone_cut"],
    resources: ["crowns", "stone"]
  });
  driver.selectCommandHall();
  driver.buildBuilding("barracks");
  driver.waitForConstruction("barracks");
  driver.trainUnit("militia");
  driver.setRallyPoint({ x: 520, y: 820 });
  driver.waitUntil(245);
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["stone_quarry", "south_iron_cache", "north_stone_scar"],
    resources: ["iron", "stone"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["iron_vein", "south_iron_cache", "burned_shrine"],
    resources: ["iron", "aether"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["aether_well", "north_aether_spring", "burned_shrine"],
    resources: ["aether", "stone"]
  });
  driver.buildIfAffordable("watchtower");
  driver.buildIfAffordable("mystic_lodge");
  driver.waitForConstruction("mystic_lodge");
  driver.trainIfAffordable("acolyte");
  driver.researchIfAffordable("reinforced_armor_1");
  driver.researchIfAffordable("infantry_weapons_1");
  driver.waitUntilArmySize(10, 620);
  driver.attackEnemyBase("safe beginner timing");
  driver.waitUntilArmySize(12, 760);
  driver.attackEnemyBase("safe beginner second push");
}

function runGreedyEconomy(driver: PlaytestStrategyDriver): void {
  driver.selectHero();
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["crown_shrine", "west_supply_pyre", "ford_toll"],
    resources: ["crowns"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["stone_quarry", "west_stone_cut", "north_stone_scar"],
    resources: ["stone"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["iron_vein", "south_iron_cache", "south_iron_pit"],
    resources: ["iron"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["aether_well", "north_aether_spring", "burned_shrine"],
    resources: ["aether"]
  });
  driver.waitUntil(178);
  driver.selectCommandHall();
  driver.buildBuilding("barracks");
  driver.waitForConstruction("barracks");
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.setRallyPoint({ x: 780, y: 880 });
  driver.buildIfAffordable("mystic_lodge");
  driver.waitForConstruction("mystic_lodge");
  driver.trainIfAffordable("acolyte");
  driver.researchIfAffordable("ranger_training_1");
  driver.waitUntilArmySize(11, 760);
  driver.attackEnemyBase("greedy economy push");
}

function runFastArmy(driver: PlaytestStrategyDriver): void {
  driver.selectCommandHall();
  driver.buildBuilding("barracks");
  driver.waitForConstruction("barracks");
  driver.trainUnit("militia");
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.selectHero();
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["crown_shrine", "west_supply_pyre", "west_stone_cut"],
    resources: ["crowns", "stone"]
  });
  driver.moveHeroAndUnitsToPreferredCapturePoint({
    preferredIds: ["iron_vein", "south_iron_cache", "south_iron_pit"],
    resources: ["iron"]
  });
  driver.setRallyPoint({ x: 620, y: 780 });
  driver.trainIfAffordable("militia");
  driver.trainIfAffordable("ranger");
  driver.researchIfAffordable("infantry_weapons_1");
  driver.buildIfAffordable("watchtower");
  driver.waitUntilArmySize(8, 430);
  driver.attackEnemyBase("fast army probe");
  driver.waitUntilArmySize(11, 620);
  driver.attackEnemyBase("fast army follow-up");
}

