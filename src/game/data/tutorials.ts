import type { TutorialDefinition } from "../core/GameTypes";

export const TUTORIALS: TutorialDefinition[] = [
  {
    id: "proving_grounds_basics",
    title: "Tutorial / Proving Grounds",
    description:
      "Optional no-reward onboarding path for the existing camera, selection, movement, capture income, construction, training, rally, hero ability, safe pressure, and completion loops.",
    status: "playable",
    launchMode: "battle",
    mapId: "first_claim",
    noReward: true,
    steps: [
      {
        id: "camera_controls",
        type: "info",
        title: "Find Your Army",
        description: "Introduce camera panning, hero centering, and the minimap without blocking battle controls.",
        instruction: "Pan with WASD or arrow keys, then press Space to keep Aster in view.",
        objectiveType: "acknowledge",
        requiredAction: "readInstructions",
        hint: "H selects Aster. Space recenters after camera movement.",
        references: {
          mapIds: ["first_claim"]
        }
      },
      {
        id: "select_hero",
        type: "selectHero",
        title: "Select Aster",
        description: "Teach selecting the hero before issuing orders.",
        instruction: "Click Aster or press H to show hero commands and abilities.",
        objectiveType: "selectHero",
        requiredAction: "selectHero",
        hint: "Selected units are the ones that receive your orders."
      },
      {
        id: "move_hero",
        type: "moveHero",
        title: "Move Aster",
        description: "Teach right-click movement using the existing hero and battlefield.",
        instruction: "With Aster selected, right-click ground near the road.",
        objectiveType: "moveHero",
        requiredAction: "moveHero",
        hint: "Right-click movement works for any selected friendly unit."
      },
      {
        id: "capture_crown_shrine",
        type: "captureSite",
        title: "Capture Crown Shrine",
        description: "Teach capture-site ownership with the safest existing First Claim opening.",
        instruction: "Move Aster and soldiers into the Crown Shrine ring until it turns green.",
        objectiveType: "captureSite",
        requiredAction: "captureSite",
        hint: "Green ownership starts your battle income.",
        references: {
          mapIds: ["first_claim"],
          captureSiteIds: ["crown_shrine"],
          resourceIds: ["crowns"]
        }
      },
      {
        id: "gather_crowns",
        type: "gatherResources",
        title: "Gather Battle Crowns",
        description: "Teach that captured sites generate temporary battle resources.",
        instruction: "Hold the Crown Shrine and watch Crowns rise for this battle.",
        objectiveType: "resourceThreshold",
        requiredAction: "waitForIncome",
        hint: "Crowns earned here are temporary battle resources, not saved rewards.",
        references: {
          mapIds: ["first_claim"],
          captureSiteIds: ["crown_shrine"],
          resourceIds: ["crowns"]
        }
      },
      {
        id: "select_command_hall",
        type: "selectBuilding",
        title: "Select Command Hall",
        description: "Teach selecting the starting Command Hall to access construction.",
        instruction: "Select your Command Hall to show construction commands.",
        objectiveType: "selectBuilding",
        requiredAction: "selectBuilding",
        hint: "The Command Hall starts Barracks construction.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["command_hall"]
        }
      },
      {
        id: "build_barracks",
        type: "buildStructure",
        title: "Build Barracks",
        description: "Teach Barracks placement and completed construction using existing build rules.",
        instruction: "Place a Barracks on clear ground near your base.",
        objectiveType: "buildStructure",
        requiredAction: "buildStructure",
        hint: "If the ground is blocked, press Esc and try a nearby spot.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["command_hall", "barracks"]
        }
      },
      {
        id: "train_militia",
        type: "trainUnit",
        title: "Train Militia",
        description: "Teach basic unit training from a completed Barracks.",
        instruction: "Select the completed Barracks and queue one Militia.",
        objectiveType: "trainUnit",
        requiredAction: "trainUnit",
        hint: "When training finishes, the Militia joins your army.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["barracks"],
          unitIds: ["militia"],
          resourceIds: ["crowns", "iron"]
        }
      },
      {
        id: "set_barracks_rally",
        type: "setRally",
        title: "Set Rally Point",
        description: "Teach rallying trained units toward a safe staging point.",
        instruction: "With Barracks selected, right-click safe ground near the road.",
        objectiveType: "setRally",
        requiredAction: "setRally",
        hint: "New units move toward that marker after training.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["barracks"]
        }
      },
      {
        id: "use_rally_banner",
        type: "useHeroAbility",
        title: "Cast Rally Banner",
        description: "Teach the first Warlord ability without adding a new ability or class.",
        instruction: "Select Aster, then cast Rally Banner or press 1.",
        objectiveType: "useHeroAbility",
        requiredAction: "useHeroAbility",
        hint: "Hero abilities spend mana and then wait on cooldown.",
        references: {
          mapIds: ["first_claim"],
          abilityIds: ["rally_banner"]
        }
      },
      {
        id: "hold_safe_pressure",
        type: "defeatEnemy",
        title: "Group Up And Hold",
        description: "Teach that a staged force handles small existing enemy contact better than rushing alone.",
        instruction: "Keep hero and troops together, then defeat the small Raider pressure.",
        objectiveType: "defeatEnemy",
        requiredAction: "defeatEnemy",
        hint: "A grouped force is safer than chasing alone.",
        references: {
          mapIds: ["first_claim"],
          unitIds: ["raider"]
        }
      },
      {
        id: "finish_training",
        type: "finish",
        title: "Training Complete",
        description: "End the tutorial without campaign rewards, hero XP, items, or campaign node completion.",
        instruction: "Training complete. You practiced the core loop. No rewards: no XP, items, resources, or campaign progress were granted.",
        objectiveType: "finish",
        requiredAction: "finish",
        hint: "Complete Tutorial opens a no-save results summary; nothing is saved."
      }
    ]
  }
];
