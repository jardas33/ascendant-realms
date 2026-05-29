import type { CampaignMissionTypeDefinition, CampaignMissionTypeId } from "../core/GameTypes";

export const CAMPAIGN_MISSION_TYPES: CampaignMissionTypeDefinition[] = [
  {
    id: "assault",
    name: "Assault",
    shortDescription: "Break an enemy base, commander, or fortified position.",
    objectiveHint: "Build a decisive army, then remove the enemy strongpoint.",
    recommendedBuildTags: ["Warrior", "Commander"]
  },
  {
    id: "control",
    name: "Control",
    shortDescription: "Contest the map economy and hold resource sites long enough to outpace the enemy.",
    objectiveHint: "Capture and defend resource sites before committing to the final push.",
    recommendedBuildTags: ["Commander", "Seer"]
  },
  {
    id: "defense",
    name: "Defense",
    shortDescription: "Protect your Command Hall and hold the line under heavier pressure.",
    objectiveHint: "Keep the base standing while turning defensive wins into a counterattack.",
    recommendedBuildTags: ["Commander", "Warrior"]
  },
  {
    id: "skirmish_training",
    name: "Skirmish / Training",
    shortDescription: "A clear, low-noise battle route for early campaign or tutorial-safe play.",
    objectiveHint: "Secure the basics, capture resources, and defeat the enemy base.",
    recommendedBuildTags: ["Any build"]
  }
];

export const CAMPAIGN_MISSION_TYPE_BY_ID: Record<CampaignMissionTypeId, CampaignMissionTypeDefinition> =
  Object.fromEntries(CAMPAIGN_MISSION_TYPES.map((missionType) => [missionType.id, missionType])) as Record<
    CampaignMissionTypeId,
    CampaignMissionTypeDefinition
  >;

export function isCampaignMissionTypeId(value: string): value is CampaignMissionTypeId {
  return value in CAMPAIGN_MISSION_TYPE_BY_ID;
}
