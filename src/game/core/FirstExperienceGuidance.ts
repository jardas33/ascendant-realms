import type { BattleStats } from "./GameTypes";
import { getCampaignActRecommendedNextStep, getCampaignActResultsGuidance } from "./campaign/CampaignActSpineRules";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";

export interface GuidanceMessage {
  title: string;
  body: string;
  actions: string[];
}

export interface ResultsGuidanceInput {
  outcome: BattleStats["outcome"];
  mode?: string;
  completedNodeId?: string;
  completedNodeName?: string;
  unlockedNodeNames?: string[];
  wasReplay?: boolean;
  optionalObjectives?: Array<{ persisted: boolean; newlyRecorded: boolean }>;
  rewardItemCount: number;
  skillPointsGained: number;
}

export function heroHasUnequippedItems(hero: HeroSaveData): boolean {
  const equipped = new Set(Object.values(hero.equipment).filter((instanceId): instanceId is string => typeof instanceId === "string"));
  return hero.inventory.some((instance) => !equipped.has(instance.instanceId));
}

export function getCampaignNextAction(campaign: CampaignSaveData, hero: HeroSaveData): GuidanceMessage {
  const completed = new Set(campaign.completedNodeIds);
  const unlocked = new Set(campaign.unlockedNodeIds);
  const shouldImproveHero = hero.skillPoints > 0 || heroHasUnequippedItems(hero);
  const act1Next = getCampaignActRecommendedNextStep(campaign);

  if (completed.has("cinderfen_aftermath")) {
    return {
      title: "Cinderfen route secured",
      body: "Chapter 2 route complete. The Watch Road is held; future Cinderfen roads will open in a later prototype.",
      actions: ["Review rewards", "Try Skirmish maps", "Future Cinderfen roads pending"]
    };
  }

  if (!completed.has("border_village")) {
    return {
      title: "Start Here",
      body: "Begin at Border Village after Tutorial / Proving Grounds. It is the first persistent campaign battle for capturing a site, building a Barracks, training troops, and defending the first wave.",
      actions: [act1Next.title, "Select Border Village", "Win the battle", "Look at your rewards after victory"]
    };
  }

  if (!completed.has("old_stone_road")) {
    if (shouldImproveHero) {
      return {
        title: "Strengthen Your Hero",
        body: "You have new progression waiting. Equip rewards or spend skill points, then take Old Stone Road as the base-development step.",
        actions: ["Open Hero Inventory", "Equip new items", "Spend skill points", "Launch Old Stone Road"]
      };
    }
    return {
      title: "Base Development Next",
      body: "Old Stone Road is still Easy, but it asks you to keep Workers productive, build production sooner, and use the full opening more confidently.",
      actions: ["Select Old Stone Road", "Capture resources earlier", "Keep Workers active", "Bring a larger trained army"]
    };
  }

  if (unlocked.has("refugee_caravan") && !completed.has("refugee_caravan")) {
    return {
      title: "Campaign Choice Moment",
      body: "Visit Refugee Caravan before pushing deeper. Event choices spend or grant campaign resources, affect reputation, and show how the map can change between battles.",
      actions: ["Select Refugee Caravan", "Read the locked choices", "Choose the outcome you want"]
    };
  }

  if (unlocked.has("chapel_of_the_marches") && !completed.has("chapel_of_the_marches")) {
    return {
      title: "Campaign Choice Moment",
      body: "Chapel of the Marches is a non-battle node. You can take a blessing, spend supplies on a lasting repair, or ask for scouting guidance without closing the chapel.",
      actions: ["Select Chapel of the Marches", "Compare choice costs", "Use guidance if you want to scout first"]
    };
  }

  if (!completed.has("aether_well_ruins") && unlocked.has("aether_well_ruins")) {
    return {
      title: "Harder Battle Available",
      body: "Aether Well Ruins is the Act 1 resource-control step. Equip your best item, spend skill points, assign Workers to held sites, and stabilize before pushing.",
      actions: ["Prepare your hero", "Assign and upgrade sites", "Launch Aether Well Ruins", "Use side resources if the center is too risky"]
    };
  }

  if (!completed.has("bandit_hillfort") && unlocked.has("bandit_hillfort")) {
    return {
      title: "Second Front",
      body: "Bandit Hillfort is the rival-pressure step. Use what your hero learned, build a steadier army, and avoid attacking before production is stable.",
      actions: ["Check inventory", "Build a mixed army", "Launch Bandit Hillfort", "Defend before assaulting"]
    };
  }

  if (!completed.has("ashen_outpost") && unlocked.has("ashen_outpost")) {
    return {
      title: "Current Finale",
      body: "Ashen Outpost is the Act 1 champion relic milestone. Enter with upgraded gear, use Chapel or camp support if available, and avoid early probes into the fortress.",
      actions: ["Spend all skill points", "Equip best rewards or relics", "Stage a larger army before attacking", "Replay objectives after victory"]
    };
  }

  if (unlocked.has("cinderfen_aftermath") && !completed.has("cinderfen_aftermath")) {
    return {
      title: "Final Cinderfen Event",
      body: "Cinderfen Aftermath is the last playable node in the current v0.3 route. Resolve one modest consequence choice to secure the Watch Road.",
      actions: ["Select Cinderfen Aftermath", "Choose one outcome", "Secure the Cinderfen route"]
    };
  }

  if (unlocked.has("cinderfen_watch") && !completed.has("cinderfen_watch")) {
    return {
      title: "Hold The Watch Road",
      body: "Cinderfen Watch is the second and final battle in the current Cinderfen route. Use Waystation support if you want one more preparation.",
      actions: ["Check Waystation services", "Launch Cinderfen Watch", "Return for Aftermath"]
    };
  }

  if (unlocked.has("cinderfen_crossing") && !completed.has("cinderfen_crossing")) {
    return {
      title: "Force The Crossing",
      body: "Cinderfen Crossing is the first Chapter 2 battle. Take side income, use the Cinder Shrine surge, clear the guardians, and break the Ashen camp.",
      actions: ["Use Waystation support if needed", "Launch Cinderfen Crossing", "Claim the Cinder Shrine"]
    };
  }

  if (unlocked.has("cinderfen_overlook") && !completed.has("cinderfen_overlook")) {
    return {
      title: "Cinderfen Route Playable",
      body: "The v0.3 Cinderfen route is open. Start at Cinderfen Overlook, pick one preparation, then Waystation and Crossing become playable.",
      actions: ["Select Cinderfen Overlook", "Compare choice costs", "Unlock the Crossing"]
    };
  }

  return {
    title: "Campaign Checkpoint",
    body: "You have cleared the current campaign route. Skirmish maps are ready for more loot and balance practice.",
    actions: ["Try Broken Ford in Skirmish", "Review inventory", "Wait for the next campaign expansion"]
  };
}

export function getCampaignNodeGuidance(nodeId: string): GuidanceMessage {
  switch (nodeId) {
    case "border_village":
      return {
        title: "First Campaign Battle",
        body: "This fight starts the persistent campaign loop: claim a nearby site, build production, train troops, use your hero, and win by destroying the enemy Stronghold.",
        actions: ["Capture the Crown Shrine", "Build a Barracks", "Train Militia", "Defend the first attack"]
      };
    case "old_stone_road":
      return {
        title: "Base Development",
        body: "This is still forgiving, but the enemy gives you less room. Keep Workers active, build production earlier, and use the opening more cleanly.",
        actions: ["Equip a weapon or trinket", "Keep Workers active", "Capture two sites", "Train before attacking"]
      };
    case "refugee_caravan":
      return {
        title: "Campaign Choice",
        body: "This event shows that the campaign is more than battles. Choices can spend resources, grant rewards, and change reputation.",
        actions: ["Compare costs", "Check locked requirements", "Pick a once-only outcome"]
      };
    case "chapel_of_the_marches":
      return {
        title: "Campaign Choice",
        body: "The chapel offers a blessing, a resource-spending repair choice, and a guidance option that scouts the route without completing the node.",
        actions: ["Review your campaign bank", "Choose a blessing or repair", "Use guidance if you are unsure"]
      };
    case "aether_well_ruins":
      return {
        title: "Resource Control",
        body: "Broken Ford introduces tighter lanes and a valuable but dangerous center. Assign Workers to captured sites, upgrade safe sites, and rebuild before attacking.",
        actions: ["Scout carefully", "Assign sites", "Upgrade safe income", "Rebuild before attacking"]
      };
    case "bandit_hillfort":
      return {
        title: "Rival Pressure",
        body: "This fight checks whether you can build an army while under steadier pressure. Fortress waves hit harder if you attack underprepared.",
        actions: ["Build production early", "Train a mixed army", "Answer the commander", "Attack after stabilizing"]
      };
    case "ashen_outpost":
      return {
        title: "Champion Relic Milestone",
        body: "This is the Act 1 champion battle. Bring equipment, skill points, upgrades, and enough troops to break a fortified base and claim a relic choice.",
        actions: ["Prepare hero progression", "Use support choices", "Defeat Captain Malrec", "Equip relic after victory"]
      };
    default:
      return {
        title: "Campaign Node",
        body: "Complete available nodes to earn rewards and unlock the next branch.",
        actions: ["Read rewards", "Check prerequisites", "Choose your next step"]
      };
  }
}

export function getResultsGuidance(input: ResultsGuidanceInput): GuidanceMessage {
  if (input.outcome === "defeat") {
    if (input.mode === "tutorial") {
      return {
        title: "Training Attempt Ended",
        body: "This was a no-save, no-reward tutorial run. Nothing was saved or lost; retry the training battle to practice grouping, retreating, and using your hero before starting a campaign.",
        actions: ["Retry Tutorial", "Practice grouped movement", "Return to Main Menu when ready"]
      };
    }
    const supportAction =
      input.mode === "campaign_node" ? "Use camp or Chapel support" : "Hold after each wave";
    return {
      title: "Recover And Retry",
      body: "Defeat is a planning signal. Read the tips below, rebuild economy and production, hold after each wave, then attack with a larger grouped army.",
      actions: ["Build Barracks earlier", "Set a rally point", supportAction, "Attack with a larger army"]
    };
  }

  if (input.mode === "tutorial") {
    return {
      title: "Training Complete",
      body: "This was a no-save, no-reward tutorial run. Use it for practice, then start or continue a campaign when you are ready.",
      actions: ["Retry Tutorial", "Return to Main Menu", "Start a campaign when ready"]
    };
  }

  if (input.completedNodeId === "border_village") {
    return {
      title: "Border Village Secured",
      body: "You finished the first persistent campaign battle. Your next loop is hero growth, then the Old Stone Road base-development mission.",
      actions: [
        input.rewardItemCount > 0 ? "Equip your new item" : "Check inventory",
        input.skillPointsGained > 0 ? "Spend your skill point" : "Review hero stats",
        "Return to Campaign Map",
        "Launch Old Stone Road"
      ]
    };
  }

  if (input.completedNodeId === "old_stone_road") {
    return {
      title: "Base Development Complete",
      body: "Old Stone Road opens the Act 1 branch. Use support nodes if helpful, then choose resource control or rival pressure.",
      actions: ["Visit Refugee Caravan or Marcher Camp", "Use new rewards", "Prepare for Broken Ford", "Replay available"]
    };
  }

  if (input.completedNodeId === "ashen_outpost") {
    const actGuidance = getCampaignActResultsGuidance(input);
    return {
      title: "Champion Relic Milestone",
      body: actGuidance?.onboardingHint ?? "Captain Malrec is defeated. Choose and equip a relic, spend any skill point, then review replay objectives or continue the campaign.",
      actions: [
        input.rewardItemCount > 0 ? "Equip item rewards" : "Review inventory",
        input.skillPointsGained > 0 ? "Spend skill point" : "Review skill tree",
        "Choose or equip relic",
        "Replay optional objectives"
      ]
    };
  }

  if (input.completedNodeId === "cinderfen_watch") {
    return {
      title: "Cinderfen Watch Secured",
      body: "The Watch Road is won. Return to the campaign map and resolve Cinderfen Aftermath to secure the current v0.3 route.",
      actions: ["Return to Campaign Map", "Resolve Cinderfen Aftermath", "Route ends after Aftermath"]
    };
  }

  if ((input.unlockedNodeNames ?? []).length > 0) {
    const actGuidance = getCampaignActResultsGuidance(input);
    return {
      title: "New Path Unlocked",
      body: actGuidance?.nextAction ?? `${input.completedNodeName ?? "This node"} changed the campaign map. Return to see the new route.`,
      actions: [...(input.unlockedNodeNames ?? []).map((name) => `New node: ${name}`), "Open Hero Inventory if you gained gear"]
    };
  }

  return {
    title: "Hero Progress",
    body: "Victory rewards make the next battle easier. Equip useful items, spend skill points, then choose the next campaign node.",
    actions: [
      input.rewardItemCount > 0 ? "Equip new item rewards" : "Review current gear",
      input.skillPointsGained > 0 ? "Spend new skill points" : "Return to Campaign Map",
      "Choose the next available node"
    ]
  };
}

export function getHeroProgressionGuidance(options: {
  hero: HeroSaveData;
  recentRewardItemCount: number;
  skillPointsGained?: number;
  inCampaign: boolean;
}): GuidanceMessage {
  if (options.hero.skillPoints > 0 && heroHasUnequippedItems(options.hero)) {
    return {
      title: "Power Up Before The Next Node",
      body: "You have both skill points and unequipped items. Spend points and equip your best reward before launching the next battle.",
      actions: ["Equip a reward item", "Spend skill points", options.inCampaign ? "Return to Campaign Map" : "Continue Skirmish"]
    };
  }

  if (options.recentRewardItemCount > 0 || heroHasUnequippedItems(options.hero)) {
    return {
      title: "You Received An Item",
      body: "Equipment changes hero battle stats. Equip useful rewards now so the next fight starts stronger.",
      actions: ["Compare stat preview", "Equip the best item", options.inCampaign ? "Return to Campaign Map" : "Continue Skirmish"]
    };
  }

  if (options.hero.skillPoints > 0 || (options.skillPointsGained ?? 0) > 0) {
    return {
      title: "You Gained A Skill Point",
      body: "Skill points unlock abilities and passive stats. Spend them before the next campaign node.",
      actions: ["Pick a skill tree", "Spend a point", options.inCampaign ? "Return to Campaign Map" : "Continue Skirmish"]
    };
  }

  return {
    title: "Hero Ready",
    body: "Your hero is ready for the next step. Check stats or return to the campaign loop.",
    actions: [options.inCampaign ? "Return to Campaign Map" : "Continue Skirmish"]
  };
}
