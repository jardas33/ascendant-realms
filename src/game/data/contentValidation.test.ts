import { describe, expect, it } from "vitest";
import { AI_PERSONALITIES } from "./aiPersonalities";
import { BATTLE_DIFFICULTIES } from "./battlePacing";
import { BORDER_MARCHES_NODES } from "./borderMarchesNodes";
import { CAMPAIGN_CHAPTERS } from "./campaignChapters";
import { CAMPAIGN_MODIFIERS } from "./campaignModifiers";
import { CAMPAIGN_NODES } from "./campaignNodes";
import { BORDER_MARCHES_REWARD_TABLES, CINDERFEN_ROAD_REWARD_TABLES } from "./campaignRewards";
import { CINDERFEN_ROAD_NODES } from "./cinderfenRoadNodes";
import { DEFAULT_AGGRO_RADIUS, FORMATION_SPACING } from "../core/Constants";
import { FACTIONS } from "./factions";
import { ITEMS } from "./items";
import { ITEM_AFFIXES } from "./itemAffixes";
import { MAPS } from "./maps";
import { ENEMY_PRESSURE_PLANS } from "./enemyPressurePlans";
import { ENEMY_DOCTRINES, ENEMY_ELITE_SQUADS } from "./enemyDoctrines";
import { ENEMY_HERO_ABILITIES, ENEMY_HEROES, createEnemyHeroUnitDefinition } from "./enemyHeroes";
import { REPUTATION_EFFECTS, TRACKED_REPUTATION_FACTION_IDS } from "./reputation";
import { REWARD_TABLES } from "./rewards";
import { RELIC_REWARD_DEFINITIONS } from "./relicRewards";
import { RIVAL_REWARDS } from "./rivalRewards";
import { SKILL_NODES, SKILL_TREES } from "./skillTrees";
import { HERO_CLASSES } from "./heroClasses";
import { STRONGHOLD_UPGRADES } from "./strongholdUpgrades";
import { TUTORIALS } from "./tutorials";
import { validateContent } from "./contentValidation";
import { UNIT_BY_ID, UNIT_ROLE_BY_ID } from "./contentIndex";
import { VISUAL_ASSET_MANIFEST } from "../assets/visualAssetManifest";
import { validateVisualAssetManifest, type VisualAssetValidationOptions } from "./validation/validateVisualAssets";

function validateVisualAssets(options: VisualAssetValidationOptions = {}): string[] {
  const errors: string[] = [];
  validateVisualAssetManifest(errors, options);
  return errors;
}

describe("content validation", () => {
  it("keeps data references valid for non-coder edits", () => {
    expect(validateContent()).toEqual([]);
  });

  it("validates player-facing unit role identities", () => {
    expect(Object.keys(UNIT_ROLE_BY_ID)).toEqual(
      expect.arrayContaining(["worker", "militia", "ranger", "acolyte", "enemy_commander"])
    );
    expect(UNIT_ROLE_BY_ID.militia.tags).toEqual(expect.arrayContaining(["frontline", "melee", "holds-ground"]));
    expect(UNIT_ROLE_BY_ID.ranger.label).toBe("Ranged / Focus Fire");
    expect(UNIT_ROLE_BY_ID.acolyte.summary).toContain("aether");
    expect(UNIT_ROLE_BY_ID.worker.tacticalHint).toContain("build");
  });

  it("validates enemy doctrine and elite squad readability data", () => {
    expect(ENEMY_DOCTRINES.map((doctrine) => doctrine.id)).toEqual(["raider", "fortress", "hunter", "warband"]);
    expect(ENEMY_DOCTRINES.find((doctrine) => doctrine.id === "raider")?.counterplay).toContain("Protect");
    expect(ENEMY_ELITE_SQUADS.map((squad) => squad.id)).toEqual(["ash_raider_vanguard", "cinder_iron_guard"]);
    expect(ENEMY_ELITE_SQUADS.every((squad) => squad.maxUnitsPerBattle <= 2)).toBe(true);
  });

  it("defines the initial visual asset metadata manifest without production-final claims", () => {
    const ids = new Set(VISUAL_ASSET_MANIFEST.assets.map((asset) => asset.id));

    expect(VISUAL_ASSET_MANIFEST.assets).toHaveLength(89);
    expect(ids.size).toBe(VISUAL_ASSET_MANIFEST.assets.length);
    expect(VISUAL_ASSET_MANIFEST.assets.some((asset) => asset.currentStatus === "final")).toBe(false);
    expect(VISUAL_ASSET_MANIFEST.assets.some((asset) => asset.reviewStatus === "approved-for-production")).toBe(false);
    expect(VISUAL_ASSET_MANIFEST.assets.filter((asset) => asset.reviewStatus === "needs-source-proof")).toHaveLength(87);
    expect(VISUAL_ASSET_MANIFEST.assets.find((asset) => asset.id === "procedural_battle_terrain")).toMatchObject({
      category: "terrain",
      currentStatus: "placeholder",
      reviewStatus: "approved-for-prototype",
      replacementPriority: "critical",
      usage: "runtime"
    });
    expect(VISUAL_ASSET_MANIFEST.assets.find((asset) => asset.id === "crown_shrine_icon")).toMatchObject({
      category: "capture-site-icon",
      replacementPriority: "high",
      needsReview: true
    });
    expect(VISUAL_ASSET_MANIFEST.assets.find((asset) => asset.id === "manual_source_militia_unit_sprite")).toMatchObject({
      usage: "manual-reference",
      currentStatus: "reference"
    });
  });

  it("rejects invalid visual asset metadata enum values", () => {
    const asset = VISUAL_ASSET_MANIFEST.assets[0];
    VISUAL_ASSET_MANIFEST.assets.push({
      ...asset,
      id: "bad_visual_asset_enums",
      category: "bad_category" as typeof asset.category,
      currentStatus: "bad_status" as typeof asset.currentStatus,
      sourceType: "bad_source" as typeof asset.sourceType,
      licenseStatus: "bad_license" as typeof asset.licenseStatus,
      reviewStatus: "bad_review" as typeof asset.reviewStatus,
      usage: "bad_usage" as typeof asset.usage,
      scaleClass: "bad_scale" as typeof asset.scaleClass,
      silhouetteReadability: "bad_silhouette" as typeof asset.silhouetteReadability,
      styleConsistency: "bad_style" as typeof asset.styleConsistency,
      replacementPriority: "bad_priority" as typeof asset.replacementPriority
    });
    try {
      expect(validateVisualAssets()).toEqual(
        expect.arrayContaining([
          "Visual asset bad_visual_asset_enums has invalid category bad_category.",
          "Visual asset bad_visual_asset_enums has invalid currentStatus bad_status.",
          "Visual asset bad_visual_asset_enums has invalid sourceType bad_source.",
          "Visual asset bad_visual_asset_enums has invalid licenseStatus bad_license.",
          "Visual asset bad_visual_asset_enums has invalid reviewStatus bad_review.",
          "Visual asset bad_visual_asset_enums has invalid usage bad_usage.",
          "Visual asset bad_visual_asset_enums has invalid scaleClass bad_scale.",
          "Visual asset bad_visual_asset_enums has invalid silhouetteReadability bad_silhouette.",
          "Visual asset bad_visual_asset_enums has invalid styleConsistency bad_style.",
          "Visual asset bad_visual_asset_enums has invalid replacementPriority bad_priority."
        ])
      );
    } finally {
      VISUAL_ASSET_MANIFEST.assets.pop();
    }
  });

  it("rejects unsafe visual asset metadata guards", () => {
    const asset = VISUAL_ASSET_MANIFEST.assets[0];
    const original = { ...asset, usedBy: [...asset.usedBy] };
    VISUAL_ASSET_MANIFEST.assets.push({ ...asset, usedBy: [...asset.usedBy] });
    asset.currentStatus = "final";
    asset.sourceType = "unknown";
    asset.licenseStatus = "unknown";
    asset.usage = "runtime";
    asset.usedBy = [];
    asset.needsReview = false;
    asset.allowedInProduction = true;
    asset.intendedWorldHeightPx = 0;
    asset.currentRenderHeightPx = -1;
    try {
      expect(validateVisualAssets()).toEqual(
        expect.arrayContaining([
          `Duplicate visual asset id: ${asset.id}`,
          `Visual asset ${asset.id} runtime usage must include at least one usedBy reference.`,
          `Visual asset ${asset.id} runtime asset with unknown license must set needsReview true.`,
          `Visual asset ${asset.id} final asset cannot have unknown source or license.`,
          `Visual asset ${asset.id} cannot be allowed in production with unknown source or license.`,
          `Visual asset ${asset.id} intendedWorldHeightPx must be positive when present.`,
          `Visual asset ${asset.id} currentRenderHeightPx must be positive when present.`
        ])
      );
    } finally {
      VISUAL_ASSET_MANIFEST.assets.pop();
      Object.assign(asset, original);
    }
  });

  it("checks runtime visual asset file paths when the CLI provides a file-existence callback", () => {
    const asset = VISUAL_ASSET_MANIFEST.assets[0];
    const originalFilePath = asset.filePath;
    asset.filePath = "public/assets/final/units/missing_visual_asset.png";
    try {
      expect(
        validateVisualAssets({
          fileExists: (filePath) => filePath !== "public/assets/final/units/missing_visual_asset.png"
        })
      ).toContain(`Visual asset ${asset.id} runtime filePath does not exist: public/assets/final/units/missing_visual_asset.png`);
    } finally {
      asset.filePath = originalFilePath;
    }
  });

  it("keeps runtime asset references covered by the visual manifest", () => {
    const asset = VISUAL_ASSET_MANIFEST.assets.find((entry) => entry.id === "warlord_hero_battle_sprite")!;
    const originalId = asset.id;
    const originalUsage = asset.usage;
    asset.usage = "manual-reference";
    try {
      expect(validateVisualAssets()).toContain(
        "Visual asset warlord_hero_battle_sprite is required by runtime asset references but has usage manual-reference."
      );
      asset.usage = originalUsage;
      asset.id = "missing_warlord_manifest_entry";
      expect(validateVisualAssets()).toContain(
        "Runtime visual asset id warlord_hero_battle_sprite is missing from the visual asset manifest."
      );
    } finally {
      asset.id = originalId;
      asset.usage = originalUsage;
    }
  });

  it("hardens visual source review and production approval metadata", () => {
    const asset = VISUAL_ASSET_MANIFEST.assets.find((entry) => entry.id === "warlord_hero_battle_sprite")!;
    const original = { ...asset, usedBy: [...asset.usedBy] };
    try {
      asset.reviewStatus = "reference-only";
      asset.usage = "runtime";
      expect(validateVisualAssets()).toContain(`Visual asset ${asset.id} runtime asset cannot use reviewStatus reference-only.`);

      Object.assign(asset, original, { usedBy: [...original.usedBy] });
      asset.currentStatus = "final";
      asset.reviewStatus = "approved-for-production";
      asset.sourceType = "external-reference";
      asset.licenseStatus = "generated-review-needed";
      asset.allowedInProduction = false;
      asset.replacementPriority = "critical";
      asset.notes = "";
      asset.sourceReviewNotes = "";

      expect(validateVisualAssets()).toEqual(
        expect.arrayContaining([
          `Visual asset ${asset.id} needs notes.`,
          `Visual asset ${asset.id} needs sourceReviewNotes.`,
          `Visual asset ${asset.id} final asset must be allowed in production.`,
          `Visual asset ${asset.id} approved-for-production review status requires allowedInProduction true.`,
          `Visual asset ${asset.id} approved-for-production review status requires owned or licensed asset rights.`,
          `Visual asset ${asset.id} approved-for-production review status requires a non-reference known source.`,
          `Visual asset ${asset.id} critical replacement priority must include notes and sourceReviewNotes.`
        ])
      );
    } finally {
      Object.assign(asset, original, { usedBy: [...original.usedBy] });
    }
  });

  it("defines the playable Tutorial / Proving Grounds metadata shell", () => {
    expect(TUTORIALS.map((tutorial) => tutorial.id)).toEqual(["proving_grounds_basics"]);
    expect(TUTORIALS[0]).toMatchObject({
      title: "Tutorial / Proving Grounds",
      status: "playable",
      launchMode: "battle",
      mapId: "first_claim",
      noReward: true
    });
    expect(TUTORIALS[0].steps.map((step) => step.id)).toEqual([
      "camera_controls",
      "select_hero",
      "move_hero",
      "capture_crown_shrine",
      "gather_crowns",
      "select_command_hall",
      "build_barracks",
      "train_militia",
      "set_barracks_rally",
      "use_rally_banner",
      "hold_safe_pressure",
      "finish_training"
    ]);
    expect(TUTORIALS[0].steps.every((step) => step.instruction.trim().length > 0)).toBe(true);
  });

  it("rejects duplicate tutorial ids", () => {
    TUTORIALS.push({ ...TUTORIALS[0], steps: [...TUTORIALS[0].steps] });
    try {
      expect(validateContent()).toEqual(expect.arrayContaining(["Duplicate tutorial id: proving_grounds_basics"]));
    } finally {
      TUTORIALS.pop();
    }
  });

  it("rejects invalid tutorial metadata references before a launch path exists", () => {
    const tutorial = TUTORIALS[0];
    const originalStatus = tutorial.status;
    const originalLaunchMode = tutorial.launchMode;
    const originalMapId = tutorial.mapId;
    const originalNoReward = tutorial.noReward;
    const firstStep = tutorial.steps[0];
    const originalReferences = firstStep.references;
    const originalInstruction = firstStep.instruction;
    const originalType = firstStep.type;
    const originalObjectiveType = firstStep.objectiveType;
    const originalRequiredAction = firstStep.requiredAction;
    tutorial.status = "missing_status" as typeof tutorial.status;
    tutorial.launchMode = "missing_mode" as typeof tutorial.launchMode;
    tutorial.mapId = "missing_map";
    tutorial.noReward = false;
    firstStep.instruction = "";
    firstStep.type = "bad_step" as typeof firstStep.type;
    firstStep.objectiveType = "bad_objective" as typeof firstStep.objectiveType;
    firstStep.requiredAction = "bad_action" as typeof firstStep.requiredAction;
    firstStep.references = {
      mapIds: ["missing_step_map"],
      unitIds: ["missing_unit"],
      buildingIds: ["missing_building"],
      abilityIds: ["missing_ability"],
      resourceIds: ["missing_resource"],
      captureSiteIds: ["missing_site"]
    };
    tutorial.steps.push({ ...firstStep });
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Tutorial proving_grounds_basics has invalid launch mode missing_mode.",
          "Tutorial proving_grounds_basics has invalid status missing_status.",
          "Tutorial proving_grounds_basics references missing map missing_map.",
          "Tutorial proving_grounds_basics must keep noReward true.",
          "Duplicate Tutorial proving_grounds_basics step id: camera_controls",
          "Tutorial proving_grounds_basics step camera_controls needs title, description, and instruction.",
          "Tutorial proving_grounds_basics step camera_controls has invalid type bad_step.",
          "Tutorial proving_grounds_basics step camera_controls has invalid objective type bad_objective.",
          "Tutorial proving_grounds_basics step camera_controls has invalid required action bad_action.",
          "Tutorial proving_grounds_basics step camera_controls references missing map missing_step_map.",
          "Tutorial proving_grounds_basics step camera_controls references missing unit missing_unit.",
          "Tutorial proving_grounds_basics step camera_controls references missing building missing_building.",
          "Tutorial proving_grounds_basics step camera_controls references missing ability missing_ability.",
          "Tutorial proving_grounds_basics step camera_controls references missing resource missing_resource.",
          "Tutorial proving_grounds_basics step camera_controls references missing capture site missing_site."
        ])
      );
    } finally {
      tutorial.steps.pop();
      firstStep.references = originalReferences;
      firstStep.instruction = originalInstruction;
      firstStep.type = originalType;
      firstStep.objectiveType = originalObjectiveType;
      firstStep.requiredAction = originalRequiredAction;
      tutorial.launchMode = originalLaunchMode;
      tutorial.mapId = originalMapId;
      tutorial.noReward = originalNoReward;
      tutorial.status = originalStatus;
    }
  });

  it("rejects invalid enemy pressure plan references and stage metadata", () => {
    const plan = ENEMY_PRESSURE_PLANS[0];
    const originalScope = plan.scope;
    const originalAllowedMapIds = plan.allowedMapIds;
    const originalAllowedNodeIds = plan.allowedNodeIds;
    const originalPersonalityTags = plan.personalityTags;
    const originalStages = plan.stages;
    const firstStage = plan.stages[0];
    const originalTrigger = firstStage.trigger;
    const originalAction = firstStage.action;
    plan.scope = "bad_scope" as typeof plan.scope;
    plan.allowedMapIds = ["missing_map"];
    plan.allowedNodeIds = ["missing_node"];
    plan.personalityTags = ["missing_personality" as never];
    firstStage.trigger = { type: "missing_trigger" as never, captureSiteId: "missing_site" };
    firstStage.action = { type: "missing_action" as never, unitIds: ["missing_unit"], captureSiteId: "missing_site" };
    plan.stages = [...plan.stages, { ...firstStage }];
    ENEMY_PRESSURE_PLANS.push({ ...plan, stages: [...plan.stages] });
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Duplicate enemy pressure plan id: ashen_watch_captain_pressure",
          "Enemy pressure plan ashen_watch_captain_pressure has invalid scope bad_scope.",
          "Enemy pressure plan ashen_watch_captain_pressure references missing map missing_map.",
          "Enemy pressure plan ashen_watch_captain_pressure references missing campaign node missing_node.",
          "Enemy pressure plan ashen_watch_captain_pressure references missing AI personality missing_personality.",
          "Duplicate Enemy pressure plan ashen_watch_captain_pressure stage id: watch_road_response",
          "Enemy pressure plan ashen_watch_captain_pressure stage watch_road_response has invalid trigger missing_trigger.",
          "Enemy pressure plan ashen_watch_captain_pressure stage watch_road_response has invalid action missing_action."
        ])
      );
    } finally {
      ENEMY_PRESSURE_PLANS.pop();
      plan.stages = originalStages;
      firstStage.trigger = originalTrigger;
      firstStage.action = originalAction;
      plan.personalityTags = originalPersonalityTags;
      plan.allowedNodeIds = originalAllowedNodeIds;
      plan.allowedMapIds = originalAllowedMapIds;
      plan.scope = originalScope;
    }
  });

  it("rejects forbidden worker construction or economy fields in pressure plans", () => {
    const plan = ENEMY_PRESSURE_PLANS[0] as typeof ENEMY_PRESSURE_PLANS[number] & {
      workerUnitIds?: string[];
    };
    const action = plan.stages[0].action as typeof plan.stages[0]["action"] & {
      constructionBuildingId?: string;
      economyBudget?: number;
    };
    plan.workerUnitIds = ["peasant"];
    action.constructionBuildingId = "barracks";
    action.economyBudget = 100;
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Enemy pressure plan ashen_watch_captain_pressure contains forbidden worker/construction/economy field workerUnitIds.",
          "Enemy pressure plan ashen_watch_captain_pressure contains forbidden worker/construction/economy field stages.0.action.constructionBuildingId.",
          "Enemy pressure plan ashen_watch_captain_pressure contains forbidden worker/construction/economy field stages.0.action.economyBudget."
        ])
      );
    } finally {
      delete action.economyBudget;
      delete action.constructionBuildingId;
      delete plan.workerUnitIds;
    }
  });

  it("rejects campaign pressure plan attachments outside their allowed nodes or missing ids", () => {
    const crossing = CINDERFEN_ROAD_NODES.find((entry) => entry.id === "cinderfen_crossing")!;
    const road = BORDER_MARCHES_NODES.find((entry) => entry.id === "old_stone_road")!;
    const originalCrossingPlan = crossing.enemyPressurePlanId;
    const originalRoadPlan = road.enemyPressurePlanId;
    crossing.enemyPressurePlanId = "missing_pressure_plan";
    road.enemyPressurePlanId = "causeway_contest_pressure";
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Campaign node cinderfen_crossing references missing enemy pressure plan missing_pressure_plan.",
          "Campaign node old_stone_road uses enemy pressure plan causeway_contest_pressure outside its allowed nodes or maps."
        ])
      );
    } finally {
      road.enemyPressurePlanId = originalRoadPlan;
      crossing.enemyPressurePlanId = originalCrossingPlan;
    }
  });

  it("requires playable tutorial metadata to point at a map and keep at least one step", () => {
    const tutorial = TUTORIALS[0];
    const originalStatus = tutorial.status;
    const originalMapId = tutorial.mapId;
    const originalSteps = tutorial.steps;
    tutorial.status = "playable";
    tutorial.mapId = undefined;
    tutorial.steps = [];
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Playable tutorial proving_grounds_basics must include mapId.",
          "Tutorial proving_grounds_basics needs at least one planned step."
        ])
      );
    } finally {
      tutorial.steps = originalSteps;
      tutorial.mapId = originalMapId;
      tutorial.status = originalStatus;
    }
  });

  it("rejects duplicate chapter node and prerequisite entries", () => {
    const chapter = CAMPAIGN_CHAPTERS[0];
    chapter.nodeIds.push(chapter.nodeIds[0]);
    chapter.unlockPrerequisiteNodeIds.push("border_village", "border_village");
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          `Campaign chapter ${chapter.id} lists node ${chapter.nodeIds[0]} more than once.`,
          "Campaign chapter border_marches lists unlock prerequisite border_village more than once."
        ])
      );
    } finally {
      chapter.nodeIds.pop();
      chapter.unlockPrerequisiteNodeIds.pop();
      chapter.unlockPrerequisiteNodeIds.pop();
    }
  });

  it("rejects Cinderfen capture-bonus modifiers that target missing or non-Cinderfen sites", () => {
    const modifier = CAMPAIGN_MODIFIERS.find((entry) => entry.id === "shrine_attunement")!;
    const originalAdditions = modifier.effects.firstCaptureBonusResourceAdditions;
    modifier.effects.firstCaptureBonusResourceAdditions = {
      missing_site: { aether: 5 },
      crown_shrine: { crowns: 5 },
      cinder_crossing: { aether: 0 }
    };
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Campaign modifier shrine_attunement targets missing capture site missing_site.",
          "Campaign modifier shrine_attunement targets non-Cinderfen capture site crown_shrine on first_claim.",
          "Campaign modifier shrine_attunement capture bonus cinder_crossing must grant positive aether."
        ])
      );
    } finally {
      modifier.effects.firstCaptureBonusResourceAdditions = originalAdditions;
    }
  });

  it("rejects map AI building references that are not spawned for the expected team", () => {
    const map = MAPS.find((entry) => entry.id === "first_claim")!;
    const originalBaseBuildingId = map.scenario.enemyAI.baseBuildingId;
    map.scenario.enemyAI.baseBuildingId = "command_hall";
    try {
      expect(validateContent()).toContain(
        "Map first_claim AI references enemy building command_hall that is not spawned for the enemy team."
      );
    } finally {
      map.scenario.enemyAI.baseBuildingId = originalBaseBuildingId;
    }
  });

  it("rejects reward tables without explicit repeat policy or with duplicate item pools", () => {
    const table = REWARD_TABLES[0];
    const originalRepeatClearReward = table.repeatClearReward;
    table.repeatClearReward = undefined;
    table.weightedItemPool.push({ ...table.weightedItemPool[0] });
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          `Reward table ${table.id} needs an explicit repeat-clear reward.`,
          `Reward table ${table.id} duplicates weighted item ${table.weightedItemPool[0].itemId}.`
        ])
      );
    } finally {
      table.weightedItemPool.pop();
      table.repeatClearReward = originalRepeatClearReward;
    }
  });

  it("rejects repeat-clear rewards that exceed first-clear rewards or grant direct items", () => {
    const table = REWARD_TABLES.find((entry) => entry.id === "cinderfen_causeway_rewards")!;
    const originalRepeatClearReward = table.repeatClearReward;
    table.repeatClearReward = {
      itemIds: ["scouts_bow"],
      resources: { crowns: 999 },
      xp: 999
    };
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Reward table cinderfen_causeway_rewards repeat-clear reward must not grant direct items.",
          "Reward table cinderfen_causeway_rewards repeat-clear XP exceeds first-clear XP.",
          "Reward table cinderfen_causeway_rewards repeat-clear crowns exceeds first-clear crowns."
        ])
      );
    } finally {
      table.repeatClearReward = originalRepeatClearReward;
    }
  });

  it("rejects unreachable chapter graphs and battle nodes without any continuation", () => {
    const chapter = CAMPAIGN_CHAPTERS.find((entry) => entry.id === "cinderfen_road")!;
    const overlook = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_overlook")!;
    const originalPrerequisites = overlook.prerequisites;
    const borderMarches = CAMPAIGN_CHAPTERS.find((entry) => entry.id === "border_marches")!;
    const orphanBattle = {
      ...CAMPAIGN_NODES.find((entry) => entry.id === "border_village")!,
      id: "orphan_battle",
      prerequisites: ["border_village"],
      unlocks: []
    };
    overlook.prerequisites = ["cinderfen_watch"];
    CAMPAIGN_NODES.push(orphanBattle);
    borderMarches.nodeIds.push(orphanBattle.id);
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Campaign chapter cinderfen_road has no reachable entry node.",
          "Campaign chapter cinderfen_road cannot reach node cinderfen_overlook from its chapter entry/prerequisite graph.",
          "Campaign battle node orphan_battle has no unlock, prerequisite dependent, or chapter continuation."
        ])
      );
      expect(chapter.nodeIds).toContain("cinderfen_overlook");
    } finally {
      borderMarches.nodeIds.pop();
      CAMPAIGN_NODES.pop();
      overlook.prerequisites = originalPrerequisites;
    }
  });

  it("rejects costed campaign choices that have no visible saved effect", () => {
    const node = CAMPAIGN_NODES.find((entry) => entry.id === "cinderfen_waystation")!;
    const choice = node.choices!.find((entry) => entry.id === "ash_filters")!;
    const originalRewards = choice.rewards;
    choice.rewards = undefined;
    try {
      expect(validateContent()).toContain("Campaign choice cinderfen_waystation:ash_filters has a cost but no visible saved effect.");
    } finally {
      choice.rewards = originalRewards;
    }
  });

  it("rejects non-town no-complete choices without path flow and one-time town item services without stock guards", () => {
    const chapel = CAMPAIGN_NODES.find((entry) => entry.id === "chapel_of_the_marches")!;
    const guidance = chapel.choices!.find((entry) => entry.id === "ask_for_guidance")!;
    const originalGuidanceRewards = guidance.rewards;
    guidance.rewards = { xp: 15 };

    const town = CAMPAIGN_NODES.find((entry) => entry.id === "marcher_camp")!;
    const purchase = town.choices!.find((entry) => entry.id === "purchase_emberglass_wand")!;
    const originalStockItemId = purchase.stockItemId;
    purchase.stockItemId = undefined;
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Campaign choice chapel_of_the_marches:ask_for_guidance does not complete the node and has no unlock or lock effect.",
          "Campaign town choice marcher_camp:purchase_emberglass_wand grants one-time items without a stockItemId duplicate guard."
        ])
      );
    } finally {
      purchase.stockItemId = originalStockItemId;
      guidance.rewards = originalGuidanceRewards;
    }
  });

  it("rejects battle campaign nodes whose maps resolve to missing reward tables", () => {
    const map = MAPS.find((entry) => entry.id === "first_claim")!;
    const originalRewardTableId = map.scenario.rewardTableId;
    map.scenario.rewardTableId = "missing_reward_table";
    try {
      expect(validateContent()).toEqual(
        expect.arrayContaining([
          "Campaign battle node border_village uses map first_claim with missing reward table missing_reward_table.",
          "Map first_claim references missing reward table missing_reward_table."
        ])
      );
    } finally {
      map.scenario.rewardTableId = originalRewardTableId;
    }
  });

  it("keeps focused chapter data modules wired through public data barrels", () => {
    expect(CAMPAIGN_NODES).toEqual([...BORDER_MARCHES_NODES, ...CINDERFEN_ROAD_NODES]);
    expect(CAMPAIGN_CHAPTERS.find((chapter) => chapter.id === "border_marches")?.nodeIds).toEqual(
      BORDER_MARCHES_NODES.map((node) => node.id)
    );
    expect(CAMPAIGN_CHAPTERS.find((chapter) => chapter.id === "cinderfen_road")?.nodeIds).toEqual(
      CINDERFEN_ROAD_NODES.map((node) => node.id)
    );
    expect(REWARD_TABLES).toEqual([...BORDER_MARCHES_REWARD_TABLES, ...CINDERFEN_ROAD_REWARD_TABLES]);
  });

  it("covers multiple skirmish maps with complete setup metadata", () => {
    expect(MAPS.map((map) => map.id)).toEqual(
      expect.arrayContaining(["first_claim", "broken_ford", "ashen_outpost", "cinderfen_causeway", "cinderfen_watchpost"])
    );
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
    const cinderfenCauseway = MAPS.find((map) => map.id === "cinderfen_causeway");
    expect(cinderfenCauseway?.captureSites).toHaveLength(4);
    expect(cinderfenCauseway?.neutralCamps).toHaveLength(3);
    expect(cinderfenCauseway?.captureSites.find((site) => site.id === "cinder_crossing")).toMatchObject({
      name: "Cinder Shrine",
      firstCaptureBonus: {
        id: "cinder_shrine_surge",
        label: "Cinder Shrine Surge",
        resources: { aether: 20 }
      }
    });
    expect(cinderfenCauseway?.scenario.rewardTableId).toBe("cinderfen_causeway_rewards");
    expect(cinderfenCauseway?.scenario.objectives.secondaryObjectives?.map((objective) => objective.id)).toEqual(
      expect.arrayContaining(["capture_cinder_crossing", "clear_cinder_guardians", "destroy_cinderfen_barracks"])
    );
    expect(REWARD_TABLES.map((table) => table.id)).toContain("cinderfen_causeway_rewards");
    const cinderfenWatchpost = MAPS.find((map) => map.id === "cinderfen_watchpost");
    expect(cinderfenWatchpost?.captureSites).toHaveLength(3);
    expect(cinderfenWatchpost?.neutralCamps).toHaveLength(2);
    expect(cinderfenWatchpost?.scenario.rewardTableId).toBe("cinderfen_watchpost_rewards");
    expect(cinderfenWatchpost?.scenario.objectives.secondaryObjectives?.map((objective) => objective.id)).toEqual(
      expect.arrayContaining(["capture_watch_road", "clear_marsh_raider_camp", "destroy_watchpost_tower"])
    );
    expect(REWARD_TABLES.map((table) => table.id)).toContain("cinderfen_watchpost_rewards");
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
    const chapterOneNodeIds = CAMPAIGN_NODES.filter((node) => node.chapterId === "border_marches").map((node) => node.id);

    expect(chapterOneNodeIds).toEqual(
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
    expect(chapterOneNodeIds).toHaveLength(8);
    expect(CAMPAIGN_NODES.find((node) => node.id === "chapel_of_the_marches")?.choices?.length).toBeGreaterThanOrEqual(3);
    expect(CAMPAIGN_NODES.find((node) => node.id === "refugee_caravan")?.choices?.length).toBeGreaterThanOrEqual(3);
    expect(CAMPAIGN_NODES.find((node) => node.id === "marcher_camp")?.choices?.length).toBeGreaterThanOrEqual(6);
  });

  it("defines Chapter 2 with a playable event gate, support node, two compact battle maps, and aftermath event", () => {
    const chapterTwo = CAMPAIGN_CHAPTERS.find((chapter) => chapter.id === "cinderfen_road");
    const overlook = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_overlook");
    const waystation = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_waystation");
    const crossing = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_crossing");
    const watch = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_watch");
    const aftermath = CAMPAIGN_NODES.find((node) => node.id === "cinderfen_aftermath");

    expect(CAMPAIGN_CHAPTERS.map((chapter) => chapter.id)).toEqual(["border_marches", "cinderfen_road"]);
    expect(chapterTwo).toMatchObject({
      title: "Chapter 2: Cinderfen Road",
      nodeIds: [
        "cinderfen_overlook",
        "cinderfen_waystation",
        "cinderfen_crossing",
        "cinderfen_watch",
        "cinderfen_aftermath"
      ],
      unlockPrerequisiteNodeIds: ["ashen_outpost"]
    });
    expect(overlook).toMatchObject({
      nodeType: "event",
      chapterId: "cinderfen_road",
      prerequisites: ["ashen_outpost"],
      unlocks: ["cinderfen_waystation", "cinderfen_crossing"]
    });
    expect(overlook?.isPlaceholder).toBeUndefined();
    expect(overlook?.choices?.map((choice) => choice.id)).toEqual([
      "scout_the_causeway",
      "aid_marsh_refugees",
      "study_the_cinders",
      "raise_malrecs_standard"
    ]);
    expect(overlook?.choices?.find((choice) => choice.id === "raise_malrecs_standard")).toMatchObject({
      requirements: { rivalTrophyIds: ["trophy_malrec_outpost_standard"] },
      rewards: {
        xp: 10,
        modifierIds: ["well_rested"],
        reputationChanges: { free_marches: 3 }
      }
    });
    expect(waystation).toMatchObject({
      nodeType: "town",
      chapterId: "cinderfen_road",
      prerequisites: ["cinderfen_overlook"],
      unlocks: []
    });
    expect(waystation?.choices?.map((choice) => choice.id)).toEqual([
      "marsh_guides",
      "ash_filters",
      "refugee_scouts",
      "shrine_attunement"
    ]);
    expect(waystation?.choices?.filter((choice) => !choice.onceOnly).map((choice) => choice.id)).toEqual([
      "marsh_guides",
      "ash_filters",
      "shrine_attunement"
    ]);
    expect(crossing).toMatchObject({
      nodeType: "battle",
      chapterId: "cinderfen_road",
      mapId: "cinderfen_causeway",
      difficulty: "normal",
      aiPersonalityId: "hexfire_cult",
      prerequisites: ["ashen_outpost", "cinderfen_overlook"],
      unlocks: ["cinderfen_watch"]
    });
    expect(crossing?.isPlaceholder).toBeUndefined();
    expect(crossing?.rewards).toMatchObject({
      xp: 60,
      resources: { crowns: 40, stone: 20, iron: 20, aether: 12 },
      itemIds: ["scouts_bow"]
    });
    expect(MAPS.some((map) => map.id === "cinderfen_causeway")).toBe(true);
    expect(watch).toMatchObject({
      nodeType: "battle",
      chapterId: "cinderfen_road",
      mapId: "cinderfen_watchpost",
      difficulty: "normal",
      aiPersonalityId: "hexfire_cult",
      prerequisites: ["cinderfen_crossing"],
      unlocks: ["cinderfen_aftermath"],
      rewards: {
        xp: 62,
        resources: { crowns: 40, stone: 22, iron: 18, aether: 10 }
      }
    });
    expect(MAPS.some((map) => map.id === "cinderfen_watchpost")).toBe(true);
    expect(aftermath).toMatchObject({
      nodeType: "event",
      chapterId: "cinderfen_road",
      mapId: "cinderfen_watchpost",
      difficulty: "story",
      prerequisites: ["cinderfen_watch"],
      unlocks: []
    });
    expect(aftermath?.choices?.map((choice) => choice.id)).toEqual([
      "secure_watch_road",
      "aid_the_fenfolk",
      "study_ashen_marks",
      "display_malrecs_standard"
    ]);
    expect(aftermath?.choices?.find((choice) => choice.id === "secure_watch_road")).toMatchObject({
      costs: { crowns: 45, stone: 18 },
      rewards: {
        xp: 12,
        resources: { stone: 10 },
        modifierIds: ["local_support"],
        reputationChanges: { free_marches: 4 }
      },
      completesNode: true
    });
    expect(aftermath?.choices?.find((choice) => choice.id === "study_ashen_marks")).toMatchObject({
      costs: { aether: 18 },
      rewards: {
        xp: 12,
        resources: { aether: 6 },
        itemIds: ["pilgrim_crook"],
        reputationChanges: { old_faith: 4, ashen_covenant: -1 }
      }
    });
    expect(aftermath?.choices?.find((choice) => choice.id === "display_malrecs_standard")).toMatchObject({
      requirements: { rivalTrophyIds: ["trophy_malrec_outpost_standard"] },
      rewards: {
        reputationChanges: { free_marches: 1 }
      },
      completesNode: true
    });
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

  it("defines tiny persistent relic reward candidates for rival champion defeats", () => {
    expect(RELIC_REWARD_DEFINITIONS.map((reward) => reward.sourceEnemyHeroId)).toEqual([
      "gorak_emberhand",
      "veyra_cinders",
      "captain_malrec"
    ]);
    RELIC_REWARD_DEFINITIONS.forEach((reward) => {
      const item = ITEMS.find((entry) => entry.id === reward.itemId);
      expect(reward.persistenceStatus).toBe("persistent_inventory");
      expect(reward.duplicateCopiesAllowed).toBe(false);
      expect(reward.duplicatePolicy).toBe("unique_duplicate_conversion");
      expect(reward.effectSummary).toContain("Equipped effect");
      expect(["warrior", "seer", "commander"]).toContain(reward.buildArchetype);
      expect(reward.tags).toContain(reward.buildArchetype);
      expect(reward.buildSummary.length).toBeGreaterThan(0);
      expect(reward.choiceCopy.length).toBeGreaterThan(0);
      expect(item?.slot).toBe("relic");
      expect(item?.unique).toBe(true);
      expect(ENEMY_HEROES.some((hero) => hero.id === reward.sourceEnemyHeroId)).toBe(true);
    });
  });

  it("defines tiny Warrior, Seer, and Commander skill branches with modest ability upgrades", () => {
    expect(SKILL_TREES.map((tree) => tree.name)).toEqual(["Warrior", "Seer", "Commander"]);
    expect(SKILL_TREES.map((tree) => tree.buildArchetype)).toEqual(["warrior", "seer", "commander"]);

    HERO_CLASSES.forEach((heroClass) => {
      SKILL_TREES.forEach((tree) => {
        const visibleNodes = SKILL_NODES.filter((node) => node.treeId === tree.id && !node.hidden && (!node.classId || node.classId === heroClass.id));
        expect(visibleNodes.length).toBeGreaterThanOrEqual(2);
        expect(visibleNodes.length).toBeLessThanOrEqual(3);
        visibleNodes.forEach((node) => {
          expect(node.buildArchetype).toBe(tree.buildArchetype);
        });
      });
    });

    expect(SKILL_NODES.find((node) => node.id === "warlord_cleave")?.abilityUpgrade).toMatchObject({
      abilityIds: ["cleave"],
      amountDelta: 6,
      cooldownDelta: -1
    });
    expect(SKILL_NODES.find((node) => node.id === "magic_warding")?.abilityUpgrade).toMatchObject({
      abilityIds: "all",
      manaCostDelta: -4
    });
    expect(SKILL_NODES.find((node) => node.id === "leadership_presence")?.abilityUpgrade).toMatchObject({
      abilityIds: ["rally_banner"],
      radiusDelta: 8
    });
    expect(SKILL_NODES.filter((node) => node.hidden).map((node) => node.id)).toEqual(
      expect.arrayContaining(["arcanist_blink", "shepherd_blessing", "shepherd_sanctify_ground"])
    );
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

  it("rejects reputation effects that reference missing tracked factions", () => {
    const effect = REPUTATION_EFFECTS[0];
    const originalFactionId = effect.factionId;
    effect.factionId = "missing_faction" as typeof effect.factionId;
    try {
      expect(validateContent()).toContain("Reputation effect common_folk_friendly_services references missing faction missing_faction.");
    } finally {
      effect.factionId = originalFactionId;
    }
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
