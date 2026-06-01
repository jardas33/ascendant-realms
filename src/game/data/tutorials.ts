import type { TutorialDefinition } from "../core/GameTypes";

export const TUTORIALS: TutorialDefinition[] = [
  {
    id: "proving_grounds_basics",
    title: "Tutorial / Proving Grounds",
    description:
      "Optional no-reward onboarding path for selection, movement, capture income, Worker assignment, construction, training, rally, hero ability, safe pressure, and completion loops.",
    status: "playable",
    launchMode: "battle",
    mapId: "first_claim",
    noReward: true,
    steps: [
      {
        id: "select_hero",
        type: "selectHero",
        title: "Select Aster",
        description: "Teach selecting the hero before issuing orders.",
        instruction: "Click Aster or press H.",
        reason: "Your hero anchors early fights and ability use.",
        moreHelp: "Pan with WASD or arrow keys. Space recenters on Aster after camera movement. Selected units are the only units that receive your orders.",
        objectiveType: "selectHero",
        requiredAction: "selectHero",
        hint: "H selects Aster. Space centers the camera on the hero.",
        focusTarget: { type: "hero", label: "Focus Aster" }
      },
      {
        id: "select_starting_troops",
        type: "selectTroops",
        title: "Select Starting Troops",
        description: "Teach selecting ordinary army units before moving as a group.",
        instruction: "Click or drag-select one starting soldier.",
        reason: "Troops should move with Aster instead of fighting alone.",
        moreHelp: "Drag a box around the Militia or Ranger near Aster. A selected group can move together, attack together, and later use control groups.",
        objectiveType: "selectTroops",
        requiredAction: "selectTroops",
        hint: "Militia hold the front; Rangers attack from range.",
        references: {
          mapIds: ["first_claim"],
          unitIds: ["militia", "ranger"]
        },
        focusTarget: { type: "friendlyTroops", label: "Focus Troops" }
      },
      {
        id: "move_hero",
        type: "moveHero",
        title: "Move To The Road",
        description: "Teach right-click movement using the existing hero and battlefield.",
        instruction: "Right-click ground near the road.",
        reason: "Right-click movement works for any selected friendly unit.",
        moreHelp: "Select Aster or your starting troops, then right-click clear ground. The command line will confirm movement; blocked terrain will give a path warning.",
        objectiveType: "moveHero",
        requiredAction: "moveHero",
        hint: "Right-click clear ground to move selected friendly units.",
        focusTarget: { type: "captureSite", id: "crown_shrine", label: "Focus Road" }
      },
      {
        id: "capture_crown_shrine",
        type: "captureSite",
        title: "Capture Crown Shrine",
        description: "Teach capture-site ownership with the safest existing First Claim opening.",
        instruction: "Move into the Crown Shrine ring until it turns green.",
        reason: "Captured sites pay temporary battle resources.",
        moreHelp: "Hold units inside the ring until ownership changes. Green means player-owned. Side sites later provide additional battle income.",
        objectiveType: "captureSite",
        requiredAction: "captureSite",
        hint: "Green ownership starts battle income.",
        references: {
          mapIds: ["first_claim"],
          captureSiteIds: ["crown_shrine"],
          resourceIds: ["crowns"]
        },
        focusTarget: { type: "captureSite", id: "crown_shrine", label: "Focus Crown Shrine" }
      },
      {
        id: "select_command_hall",
        type: "selectBuilding",
        title: "Select Command Hall",
        description: "Teach selecting the starting Command Hall to access Worker training.",
        instruction: "Select your Command Hall.",
        reason: "Command Hall trains Workers, not army units.",
        moreHelp: "Workers handle construction, repairs, and site assignment. Army training starts after you build a Barracks.",
        objectiveType: "selectBuilding",
        requiredAction: "selectBuilding",
        hint: "Command Hall -> Worker. Workers handle construction.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["command_hall"]
        },
        focusTarget: { type: "building", id: "command_hall", label: "Focus Command Hall" }
      },
      {
        id: "build_barracks",
        type: "buildStructure",
        title: "Build Barracks",
        description: "Teach Worker Barracks placement and completed construction using existing build rules.",
        instruction: "Train a Worker, then build a Barracks near your base.",
        reason: "Barracks unlocks basic army production.",
        moreHelp: "Use Command Hall -> Worker, select the Worker, choose Barracks, then place it on clear ground. Construction pauses if the Worker leaves the site.",
        objectiveType: "buildStructure",
        requiredAction: "buildStructure",
        hint: "Worker -> building. Stay near the site until construction finishes.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["command_hall", "barracks"],
          unitIds: ["worker"]
        },
        focusTarget: { type: "worker", id: "worker", label: "Focus Worker" }
      },
      {
        id: "assign_worker_to_shrine",
        type: "assignWorker",
        title: "Assign Worker To Shrine",
        description: "Teach Worker assignment to a captured resource site.",
        instruction: "Assign a Worker to the captured Crown Shrine.",
        reason: "Assigned Workers improve site income during the battle.",
        moreHelp: "Select a Worker, then use the Crown Shrine assignment command or right-click the captured site. Full or enemy sites will show a reason instead.",
        objectiveType: "assignWorker",
        requiredAction: "assignWorker",
        hint: "Worker -> captured site. Assignment is battle-local.",
        references: {
          mapIds: ["first_claim"],
          captureSiteIds: ["crown_shrine"],
          unitIds: ["worker"]
        },
        focusTarget: { type: "captureSite", id: "crown_shrine", label: "Focus Crown Shrine" }
      },
      {
        id: "train_militia",
        type: "trainUnit",
        title: "Train Militia",
        description: "Teach basic unit training from a completed Barracks.",
        instruction: "Select Barracks and queue one Militia.",
        reason: "A larger group is safer than rushing alone.",
        moreHelp: "Barracks handles basic army and upgrades. Mystic Lodge handles Acolytes later. Watchtower is a defensive building once complete.",
        objectiveType: "trainUnit",
        requiredAction: "trainUnit",
        hint: "Barracks -> army and upgrades.",
        references: {
          mapIds: ["first_claim"],
          buildingIds: ["barracks"],
          unitIds: ["militia"],
          resourceIds: ["crowns", "iron"]
        },
        focusTarget: { type: "building", id: "barracks", label: "Focus Barracks" }
      },
      {
        id: "set_barracks_rally",
        type: "setRally",
        title: "Set Rally Point",
        description: "Teach rallying trained units toward a safe staging point.",
        instruction: "With Barracks selected, right-click safe ground near the road.",
        reason: "New units gather near the fight instead of idling at home.",
        moreHelp: "Rally points work on completed production buildings. If the selected building cannot rally, the command panel will not offer the rally behavior.",
        objectiveType: "setRally",
        requiredAction: "setRally",
        hint: "New units move toward that marker after training; gather them near Aster before pressure arrives.",
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
        reason: "Hero abilities spend mana and then wait on cooldown.",
        moreHelp: "The button shows disabled reasons for cooldown or mana. Campaign battles can save hero XP on victory; this training route remains no-reward.",
        objectiveType: "useHeroAbility",
        requiredAction: "useHeroAbility",
        hint: "Rally Banner helps nearby troops hold a fight.",
        references: {
          mapIds: ["first_claim"],
          abilityIds: ["rally_banner"]
        },
        focusTarget: { type: "hero", label: "Focus Aster" }
      },
      {
        id: "hold_safe_pressure",
        type: "defeatEnemy",
        title: "Group Up And Hold",
        description: "Teach that a staged force handles small existing enemy contact better than rushing alone.",
        instruction: "Keep hero and troops together, then defeat the Raider.",
        reason: "Grouped units survive pressure better than lone chases.",
        moreHelp: "Right-click the enemy with your selected group. If the enemy is off-screen, use the minimap warning and rally near Aster before pushing.",
        objectiveType: "defeatEnemy",
        requiredAction: "defeatEnemy",
        hint: "A grouped force with captured income is safer than chasing alone.",
        references: {
          mapIds: ["first_claim"],
          unitIds: ["raider"]
        },
        focusTarget: { type: "enemy", id: "raider", label: "Focus Raider" }
      },
      {
        id: "finish_training",
        type: "finish",
        title: "Training Complete",
        description: "End the tutorial without campaign rewards, hero XP, items, or campaign node completion.",
        instruction: "Training complete. No rewards or campaign progress were granted.",
        reason: "Use the campaign when you are ready for persistent progress.",
        moreHelp: "Complete Tutorial opens a no-save Results summary. Nothing is saved, and no XP, items, resources, relics, Retinue status, or campaign node completion is granted.",
        objectiveType: "finish",
        requiredAction: "finish",
        hint: "Complete Tutorial opens a no-save results summary; nothing is saved."
      }
    ]
  }
];
