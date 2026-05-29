import type { CampaignNodeDefinition } from "../core/GameTypes";
import { getCampaignNodeGuidance } from "../core/FirstExperienceGuidance";
import { getCampaignNodeStatus } from "../core/CampaignRules";
import {
  formatCampaignScenarioModifierSummary,
  getCampaignMissionBriefing,
  getCampaignMissionRewardState,
  getCampaignScenarioModifierDefinitions,
  getMissionOptionalObjectiveStates
} from "../core/campaign/CampaignMissionRules";
import { getRivalNodePreview } from "../core/RivalRules";
import {
  AI_PERSONALITY_BY_ID,
  ENEMY_HERO_ABILITY_BY_ID,
  ENEMY_HERO_BY_ID,
  FACTION_BY_ID,
  ITEM_BY_ID,
  MAP_BY_ID
} from "../data/contentIndex";
import type { CampaignSaveData, HeroSaveData } from "../save/SaveTypes";
import { formatCampaignNodeList } from "./CampaignNavigation";
import type { CampaignNodeViewModel } from "./CampaignPresentationTypes";
import { escapeHtml, titleCase } from "./CampaignPresentationTypes";
import { formatResourceRewards } from "./CampaignResourcePanel";
import { renderEventChoices } from "./CampaignChoicePanel";

interface RenderNodeDetailsOptions {
  node: CampaignNodeDefinition;
  campaignSave: CampaignSaveData;
  heroSave: HeroSaveData;
}

export function renderNodeButton(nodeView: CampaignNodeViewModel): string {
  const { node } = nodeView;
  return `
      <button
        class="${escapeHtml(nodeView.cssClass)}"
        data-testid="${escapeHtml(nodeView.testId)}"
        data-campaign-node="${node.id}"
        aria-label="${escapeHtml(`${node.name} ${nodeView.nodeTypeLabel} ${nodeView.statusLabel}${nodeView.rewardStateLabel ? ` ${nodeView.rewardStateLabel}` : ""}`)}"
        title="${escapeHtml(nodeView.rewardStateLabel ?? nodeView.statusLabel)}"
        style="${escapeHtml(nodeView.style)}"
      >
        <strong>${escapeHtml(node.name)}</strong>
        <span>${escapeHtml(nodeView.nodeTypeLabel)} - ${escapeHtml(nodeView.statusLabel)}</span>
      </button>
    `;
}

export function renderNodeDetails(options: RenderNodeDetailsOptions): string {
  const { node, campaignSave, heroSave } = options;
  const status = getCampaignNodeStatus(node, campaignSave);
  const map = MAP_BY_ID[node.mapId];
  const faction = FACTION_BY_ID[node.enemyFactionId];
  const personality = node.aiPersonalityId ? AI_PERSONALITY_BY_ID[node.aiPersonalityId] : undefined;
  const enemyHero = node.enemyHeroId ? ENEMY_HERO_BY_ID[node.enemyHeroId] : undefined;
  const rivalPreview = getRivalNodePreview(campaignSave, node);
  const nodeGuidance = getCampaignNodeGuidance(node.id);
  const mapLabel = node.isPlaceholder ? (node.futureMapName ?? "Future map not implemented") : (map?.name ?? node.mapId);
  const missionReward = getCampaignMissionRewardState(campaignSave, node);
  const missionBriefing = getCampaignMissionBriefing(node);
  const scenarioModifiers = getCampaignScenarioModifierDefinitions(node);
  const objectiveStates = getMissionOptionalObjectiveStates({ campaign: campaignSave, node });
  const buildHint = recommendedBuildHint(node);
  return `
      <div class="campaign-node-details ${status}">
        <p class="eyebrow">${titleCase(node.nodeType)} - ${node.isPlaceholder ? "Upcoming" : status === "completed" && node.nodeType === "battle" ? "Replayable (Completed)" : titleCase(status)}</p>
        <h3>${escapeHtml(node.name)}</h3>
        <p>${escapeHtml(node.description)}</p>
        ${
          node.isPlaceholder
            ? renderGuidanceMessage(
                node.placeholderLabel ?? "Upcoming",
                node.placeholderDescription ?? "This campaign node is visible for future planning and cannot be launched yet.",
                ["Upcoming", "No battle launch", "More content coming later"],
                "compact"
              )
            : ""
        }
        ${renderGuidanceMessage(nodeGuidance.title, nodeGuidance.body, nodeGuidance.actions, "compact")}
        ${missionBriefing ? renderMissionBriefingMessage(missionBriefing, scenarioModifiers) : ""}
        ${renderMissionRewardMessage(node, missionReward)}
        ${objectiveStates.length > 0 ? renderOptionalObjectiveMessage(objectiveStates) : ""}
        ${buildHint ? renderGuidanceMessage(buildHint.title, buildHint.body, buildHint.actions, "compact") : ""}
        <div class="results-grid compact">
          <span>Map</span><strong>${escapeHtml(mapLabel)}</strong>
          <span>Mission type</span><strong>${escapeHtml(missionBriefing?.missionType?.name ?? "None")}</strong>
          <span>Primary objective</span><strong>${escapeHtml(missionBriefing?.primaryObjective ?? "Complete the mission.")}</strong>
          <span>Scenario modifiers</span><strong>${escapeHtml(formatScenarioModifierNames(scenarioModifiers))}</strong>
          <span>Modifier effects</span><strong>${escapeHtml(formatCampaignScenarioModifierSummary(node))}</strong>
          <span>Reward preview</span><strong>${escapeHtml(missionBriefing?.rewardPreview ?? "See listed rewards.")}</strong>
          <span>Difficulty</span><strong>${titleCase(node.difficulty)}</strong>
          <span>Mission status</span><strong>${escapeHtml(missionReward.statusLabel)}</strong>
          <span>Campaign reward</span><strong>${escapeHtml(missionReward.rewardLabel)}</strong>
          <span>Replay rule</span><strong>${missionReward.isReplay ? "Reduced repeat battle rewards; node rewards do not duplicate" : "Full first-clear mission rewards available"}</strong>
          <span>Enemy</span><strong>${escapeHtml(faction?.name ?? node.enemyFactionId)}</strong>
          <span>Enemy Style</span><strong>${escapeHtml(personality ? `${personality.name}: ${personality.shortDescription}` : "Balanced Warlord: Mixed expansion and attacks.")}</strong>
          <span>Enemy Commander</span><strong>${escapeHtml(enemyHero ? `${enemyHero.name}, ${enemyHero.title}` : "None scouted")}</strong>
          <span>Rival Status</span><strong>${escapeHtml(rivalPreview?.summaryText ?? "No known rival")}</strong>
          <span>Prerequisites</span><strong>${escapeHtml(formatCampaignNodeList(node.prerequisites) || "None")}</strong>
          <span>Unlocks</span><strong>${escapeHtml(formatCampaignNodeList(node.unlocks) || "None")}</strong>
          <span>XP reward</span><strong>${node.rewards.xp ?? 0}</strong>
          <span>Item reward</span><strong>${escapeHtml(formatNodeItemRewards(node).join(", ") || "None")}</strong>
          <span>Resource reward</span><strong>${escapeHtml(formatResourceRewards(node.rewards.resources ?? {}).join(", ") || "None")}</strong>
          <span>Optional objectives</span><strong>${escapeHtml(formatOptionalObjectiveSummary(objectiveStates))}</strong>
        </div>
        ${
          enemyHero
            ? renderGuidanceMessage(
                "Enemy commander",
                `${enemyHero.name}, ${enemyHero.title}. ${enemyHero.flavorText}`,
                enemyHero.abilities.map((abilityId) => ENEMY_HERO_ABILITY_BY_ID[abilityId]?.name ?? abilityId),
                "compact"
              )
            : ""
        }
        ${
          rivalPreview
            ? renderGuidanceMessage(
                "Rival intel",
                rivalPreview.effectText,
                [rivalPreview.isKnownToPlayer ? "Known rival" : "First encounter", rivalPreview.summaryText],
                "compact"
              )
            : ""
        }
        ${
          faction
            ? renderGuidanceMessage(
                `${faction.name} doctrine`,
                `${faction.mechanics.economyStyle} ${faction.mechanics.militaryStyle} ${faction.mechanics.magicStyle}`,
                faction.mechanics.factionModifiers.map((modifier) => modifier.name),
                "compact"
              )
            : ""
        }
        ${node.eventText ? `<div class="event-text">${escapeHtml(node.eventText)}</div>` : ""}
        ${node.choices?.length ? renderEventChoices({ node, status, campaignSave, heroSave }) : ""}
      </div>
    `;
}

function renderMissionBriefingMessage(
  briefing: NonNullable<ReturnType<typeof getCampaignMissionBriefing>>,
  scenarioModifiers: ReturnType<typeof getCampaignScenarioModifierDefinitions>
): string {
  const modifierTag =
    scenarioModifiers.length > 0 ? `${scenarioModifiers.length} known modifier${scenarioModifiers.length === 1 ? "" : "s"}` : "No mission modifier";
  return renderGuidanceMessage(
    briefing.missionType?.name ?? "Mission briefing",
    briefing.summary,
    [
      briefing.missionType?.objectiveHint ?? briefing.primaryObjective,
      modifierTag,
      briefing.recommendedBuildHint ?? "Build choice optional"
    ],
    "compact"
  );
}

function formatScenarioModifierNames(
  scenarioModifiers: ReturnType<typeof getCampaignScenarioModifierDefinitions>
): string {
  if (scenarioModifiers.length === 0) {
    return "None";
  }
  return scenarioModifiers.map((modifier) => `${modifier.name} (${modifier.durationLabel})`).join(", ");
}

function renderMissionRewardMessage(
  node: CampaignNodeDefinition,
  missionReward: ReturnType<typeof getCampaignMissionRewardState>
): string {
  if (node.isPlaceholder) {
    return "";
  }
  return renderGuidanceMessage(
    missionReward.statusLabel,
    missionReward.isReplay
      ? "This completed battle can be replayed. Repeat battle rewards are reduced and campaign node rewards stay one-time."
      : "First clear can grant battle rewards, campaign node rewards, hero XP, and any eligible champion relic choice.",
    [
      missionReward.nodeRewardAlreadyClaimed ? "Node reward claimed" : "Node reward available",
      missionReward.isReplay ? "Replay reward" : "First-clear reward",
      "Relics remain champion-gated"
    ],
    "compact"
  );
}

function renderOptionalObjectiveMessage(objectives: ReturnType<typeof getMissionOptionalObjectiveStates>): string {
  const completed = objectives.filter((objective) => objective.persisted).length;
  return renderGuidanceMessage(
    "Optional objectives",
    "Optional objectives are not required to win. Completion credit is recorded once per campaign mission.",
    [`${completed}/${objectives.length} recorded`, "No repeat objective farming", "Shown again on Results"],
    "compact"
  );
}

function formatOptionalObjectiveSummary(objectives: ReturnType<typeof getMissionOptionalObjectiveStates>): string {
  if (objectives.length === 0) {
    return "None";
  }
  return objectives
    .map((objective) => `${objective.name}: ${objective.persisted ? "Recorded" : "Open"}`)
    .join(", ");
}

function recommendedBuildHint(node: CampaignNodeDefinition): { title: string; body: string; actions: string[] } | undefined {
  if (node.enemyHeroId === "gorak_emberhand") {
    return {
      title: "Build hint: Warrior",
      body: "Warrior damage and durability help cut through raider pressure and commander duels.",
      actions: ["Warrior", "Damage", "Durability"]
    };
  }
  if (node.enemyHeroId === "veyra_cinders") {
    return {
      title: "Build hint: Seer",
      body: "Seer mana and cooldown support help answer spell pressure and longer aether fights.",
      actions: ["Seer", "Mana", "Cooldown"]
    };
  }
  if (node.enemyHeroId === "captain_malrec") {
    return {
      title: "Build hint: Commander",
      body: "Commander rally and army support help hold formation against fortified outpost pressure.",
      actions: ["Commander", "Rally", "Army support"]
    };
  }
  return undefined;
}

export function renderGuidanceMessage(title: string, body: string, actions: string[], variant = ""): string {
  return `
      <div class="guidance-card ${variant}">
        <strong>${escapeHtml(title)}</strong>
        <p>${escapeHtml(body)}</p>
        <div class="tag-row">
          ${actions.map((action) => `<span class="tag">${escapeHtml(action)}</span>`).join("")}
        </div>
      </div>
    `;
}

export function formatNodeRewardSummary(node: CampaignNodeDefinition): string {
  const itemNames = formatNodeItemRewards(node);
  const resources = formatResourceRewards(node.rewards.resources ?? {});
  const rewards = [...itemNames, ...resources];
  if (node.rewards.xp) {
    rewards.unshift(`${node.rewards.xp} XP`);
  }
  return rewards.length > 0 ? rewards.join(", ") : "No listed reward";
}

export function formatNodeItemRewards(node: CampaignNodeDefinition): string[] {
  return (node.rewards.itemIds ?? []).map((itemId) => ITEM_BY_ID[itemId]?.name ?? itemId);
}
