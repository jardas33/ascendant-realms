import type { EnemyStrategicPressurePlanDefinition } from "../core/GameTypes";

// Enemy pressure plans describe staged commander intent. They are not enemy construction,
// worker logic, harvesting, build placement, or save-affecting campaign progression.
export const ENEMY_PRESSURE_PLANS: EnemyStrategicPressurePlanDefinition[] = [
  {
    id: "ashen_watch_captain_pressure",
    name: "Ashen Watch Captain Pressure",
    description:
      "A modest watch-road response that makes the existing Cinderfen Watch enemy commander feel attentive without adding construction or workers.",
    scope: "campaign_node",
    allowedMapIds: ["cinderfen_watchpost"],
    allowedNodeIds: ["cinderfen_watch"],
    personalityTags: ["hexfire_cult"],
    enabledByDefault: true,
    telemetryTags: ["watch_road", "hexfire", "defensive_hold"],
    notes:
      "Pressure events only. This plan may warn, mark telemetry, and use existing units or existing waves; it must not place buildings, create workers, harvest, or simulate enemy construction.",
    stages: [
      {
        id: "watch_road_response",
        trigger: { type: "player_captures_site", captureSiteId: "watch_road_toll" },
        action: { type: "show_warning" },
        intensity: "minor",
        warningCopy: "Enemy commander is reinforcing the watch road.",
        telemetryLabel: "watch_road_response"
      },
      {
        id: "watch_road_reinforcement",
        trigger: { type: "player_captures_site", captureSiteId: "watch_road_toll" },
        delaySeconds: 35,
        condition: { type: "stage_completed", stageId: "watch_road_response" },
        action: { type: "reinforce_next_wave", unitIds: ["raider"], count: 1 },
        intensity: "minor",
        warningCopy: "Ashen patrols are contesting the raised road.",
        telemetryLabel: "watch_road_reinforcement"
      },
      {
        id: "late_watch_hold",
        trigger: { type: "late_battle_time" },
        battleTimeSeconds: 420,
        action: { type: "defensive_hold", radius: 360 },
        intensity: "minor",
        warningCopy: "The watchpost is pulling defenders around its stronghold.",
        telemetryLabel: "late_watch_hold"
      }
    ]
  },
  {
    id: "causeway_contest_pressure",
    name: "Causeway Contest",
    description:
      "A restrained response to the Cinder Shrine route that makes the existing causeway defenders acknowledge the player's tempo gain.",
    scope: "campaign_node",
    allowedMapIds: ["cinderfen_causeway"],
    allowedNodeIds: ["cinderfen_crossing"],
    personalityTags: ["hexfire_cult"],
    enabledByDefault: true,
    telemetryTags: ["cinder_shrine", "hexfire", "causeway"],
    notes:
      "Pressure events only. This plan may warn, mark telemetry, and use existing units or existing waves; it must not place buildings, create workers, harvest, or simulate enemy construction.",
    stages: [
      {
        id: "shrine_route_warning",
        trigger: { type: "player_captures_site", captureSiteId: "cinder_crossing" },
        action: { type: "show_warning" },
        intensity: "minor",
        warningCopy: "Ashen patrols are contesting the shrine route.",
        telemetryLabel: "shrine_route_warning"
      },
      {
        id: "causeway_contest",
        trigger: { type: "player_captures_site", captureSiteId: "cinder_crossing" },
        delaySeconds: 30,
        condition: { type: "stage_completed", stageId: "shrine_route_warning" },
        action: { type: "contest_capture_site", captureSiteId: "cinder_crossing", unitIds: ["raider"], count: 2 },
        intensity: "minor",
        warningCopy: "The causeway commander is pressing the center road.",
        telemetryLabel: "causeway_contest"
      },
      {
        id: "late_causeway_push",
        trigger: { type: "late_battle_time" },
        battleTimeSeconds: 390,
        action: { type: "adjust_next_wave_timing", seconds: -12 },
        intensity: "minor",
        warningCopy: "Ashen forces are gathering for a late causeway push.",
        telemetryLabel: "late_causeway_push"
      }
    ]
  }
];
