import type { TutorialDefinition } from "../core/GameTypes";

export const TUTORIALS: TutorialDefinition[] = [
  {
    id: "proving_grounds_basics",
    title: "Tutorial / Proving Grounds",
    description:
      "Planned optional onboarding path for existing camera, selection, movement, capture, building, training, rally, hero ability, results, and campaign-persistence concepts. This metadata is not playable yet.",
    status: "planned",
    steps: [
      {
        id: "camera_and_selection",
        type: "selection",
        title: "Camera and Selection",
        description: "Teach hero centering, unit selection, and Command Hall selection using current controls."
      },
      {
        id: "move_and_capture",
        type: "capture",
        title: "Move and Capture",
        description: "Teach movement to an existing capture site and basic capture progress."
      },
      {
        id: "resources_and_building",
        type: "building",
        title: "Resources and Building",
        description: "Teach battle resources, Barracks placement, placement cancellation, and completed construction."
      },
      {
        id: "train_and_rally",
        type: "rally",
        title: "Train and Rally",
        description: "Teach training Militia from a Barracks and setting a ground rally point."
      },
      {
        id: "ability_and_pressure",
        type: "hero_ability",
        title: "Ability and Pressure",
        description: "Teach one unlocked hero ability and a small, clearly messaged enemy contact."
      },
      {
        id: "victory_results_persistence",
        type: "victory_results",
        title: "Victory, Results, and Persistence",
        description: "Teach the results flow and explain that the main campaign persists hero and campaign progress."
      }
    ]
  }
];
