import type { CampaignNodeDefinition } from "../core/GameTypes";
import { getCampaignNodeGuidance } from "../core/FirstExperienceGuidance";
import { getCampaignNodeStatus } from "../core/CampaignRules";
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
  return `
      <div class="campaign-node-details ${status}">
        <p class="eyebrow">${titleCase(node.nodeType)} - ${node.isPlaceholder ? "Upcoming" : titleCase(status)}</p>
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
        <div class="results-grid compact">
          <span>Map</span><strong>${escapeHtml(mapLabel)}</strong>
          <span>Difficulty</span><strong>${titleCase(node.difficulty)}</strong>
          <span>Enemy</span><strong>${escapeHtml(faction?.name ?? node.enemyFactionId)}</strong>
          <span>Enemy Style</span><strong>${escapeHtml(personality ? `${personality.name}: ${personality.shortDescription}` : "Balanced Warlord: Mixed expansion and attacks.")}</strong>
          <span>Enemy Commander</span><strong>${escapeHtml(enemyHero ? `${enemyHero.name}, ${enemyHero.title}` : "None scouted")}</strong>
          <span>Rival Status</span><strong>${escapeHtml(rivalPreview?.summaryText ?? "No known rival")}</strong>
          <span>Prerequisites</span><strong>${escapeHtml(formatCampaignNodeList(node.prerequisites) || "None")}</strong>
          <span>Unlocks</span><strong>${escapeHtml(formatCampaignNodeList(node.unlocks) || "None")}</strong>
          <span>XP reward</span><strong>${node.rewards.xp ?? 0}</strong>
          <span>Item reward</span><strong>${escapeHtml(formatNodeItemRewards(node).join(", ") || "None")}</strong>
          <span>Resource reward</span><strong>${escapeHtml(formatResourceRewards(node.rewards.resources ?? {}).join(", ") || "None")}</strong>
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
