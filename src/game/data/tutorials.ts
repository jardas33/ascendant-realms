import type { TutorialDefinition } from "../core/GameTypes";

export const TUTORIALS: TutorialDefinition[] = [
  {
    id: "proving_grounds_basics",
    title: "Tutorial / Proving Grounds",
    description:
      "Playable optional onboarding path for existing camera, selection, movement, capture, building, training, rally, hero ability, safe pressure, and no-reward completion.",
    status: "playable",
    launchMode: "battle",
    mapId: "first_claim",
    noReward: true,
    steps: [
      {
        id: "camera_controls",
        type: "info",
        title: "Camera Controls",
        description: "Introduce camera panning, hero centering, and the minimap without blocking battle controls.",
        instruction: "Pan with WASD or arrow keys. Press Space to center on Aster when ready.",
        objectiveType: "acknowledge",
        requiredAction: "readInstructions",
        hint: "H selects Aster. Space recenters the camera.",
        references: {
          mapIds: ["first_claim"]
        }
      },
      {
        id: "select_hero",
        type: "selectHero",
        title: "Select Hero",
        description: "Teach selecting the hero before issuing orders.",
        instruction: "Select Aster to show hero commands.",
        objectiveType: "selectHero",
        requiredAction: "selectHero",
        hint: "Press H or click Aster near the Command Hall."
      },
      {
        id: "move_hero",
        type: "moveHero",
        title: "Move Hero",
        description: "Teach right-click movement using the existing hero and battlefield.",
        instruction: "Right-click the road ahead to move Aster.",
        objectiveType: "moveHero",
        requiredAction: "moveHero",
        hint: "Right-click ground to move selected units."
      },
      {
        id: "capture_crown_shrine",
        type: "captureSite",
        title: "Capture Crown Shrine",
        description: "Teach capture-site ownership with the safest existing First Claim opening.",
        instruction: "Move hero and soldiers into the Crown Shrine ring until it turns blue.",
        objectiveType: "captureSite",
        requiredAction: "captureSite",
        hint: "Keep units inside the shrine ring until capture completes.",
        references: {
          mapIds: ["first_claim"],
          captureSiteIds: ["crown_shrine"],
          resourceIds: ["crowns"]
        }
      },
      {
        id: "gather_crowns",
        type: "gatherResources",
        title: "Gather Resources",
        description: "Teach that captured sites generate temporary battle resources.",
        instruction: "Hold the Crown Shrine and watch Crowns tick upward.",
        objectiveType: "resourceThreshold",
        requiredAction: "waitForIncome",
        hint: "Crowns here are battle resources, not campaign-bank rewards.",
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
        instruction: "Select your Command Hall to open build commands.",
        objectiveType: "selectBuilding",
        requiredAction: "selectBuilding",
        hint: "The Command Hall can start Barracks construction.",
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
        instruction: "Build a Barracks on clear ground near your base.",
        objectiveType: "buildStructure",
        requiredAction: "buildStructure",
        hint: "If a spot is blocked, press Esc and try nearby.",
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
        instruction: "Select the completed Barracks and train a Militia.",
        objectiveType: "trainUnit",
        requiredAction: "trainUnit",
        hint: "The unit joins your army when the training queue finishes.",
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
        hint: "Rally points help new units gather without extra selection work.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["barracks"]
        }
      },
      {
        id: "use_rally_banner",
        type: "useHeroAbility",
        title: "Use Hero Ability",
        description: "Teach the first Warlord ability without adding a new ability or class.",
        instruction: "Select Aster and cast Rally Banner, or press 1.",
        objectiveType: "useHeroAbility",
        requiredAction: "useHeroAbility",
        hint: "Abilities spend mana and then enter cooldown.",
        references: {
          mapIds: ["first_claim"],
          abilityIds: ["rally_banner"]
        }
      },
      {
        id: "hold_safe_pressure",
        type: "defeatEnemy",
        title: "Hold Safe Pressure",
        description: "Teach that a staged force handles small existing enemy contact better than rushing alone.",
        instruction: "Keep hero and troops together, then defeat the small Raider pressure.",
        objectiveType: "defeatEnemy",
        requiredAction: "defeatEnemy",
        hint: "A staged force should handle this safely.",
        references: {
          mapIds: ["first_claim"],
          unitIds: ["raider"]
        }
      },
      {
        id: "finish_training",
        type: "finish",
        title: "Finish Training",
        description: "End the tutorial without campaign rewards, hero XP, items, or campaign node completion.",
        instruction: "Training complete. No rewards: no XP, items, resources, or campaign progress were granted.",
        objectiveType: "finish",
        requiredAction: "finish",
        hint: "Exit to the main menu when ready; nothing is saved."
      }
    ]
  }
];
