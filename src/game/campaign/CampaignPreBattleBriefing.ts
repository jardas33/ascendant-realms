import type { CampaignNodeDefinition } from "../core/GameTypes";
import { getCampaignMissionBriefing } from "../core/campaign/CampaignMissionRules";
import { FACTION_BY_ID, HERO_CLASS_BY_ID, MAP_BY_ID, ORIGIN_BY_ID } from "../data/contentIndex";
import type { HeroSaveData } from "../save/SaveTypes";
import { escapeHtml, titleCase } from "./CampaignPresentationTypes";

export interface CampaignPreBattleBriefingOptions {
  node: CampaignNodeDefinition;
  heroSave: HeroSaveData;
  campaignName: string;
  stateLabel: string;
  lockReason: string;
  canStart: boolean;
}

/**
 * Player-facing setup summary sourced only from the canonical campaign node,
 * map, faction, and hero catalogs. It is presentation-only and does not alter
 * the battle launch request or any campaign state.
 */
export function renderCampaignPreBattleBriefing(options: CampaignPreBattleBriefingOptions): string {
  const { node, heroSave, campaignName, stateLabel, lockReason, canStart } = options;
  if (node.nodeType !== "battle" || node.isPlaceholder) {
    return "";
  }
  const map = MAP_BY_ID[node.mapId];
  const enemyFaction = FACTION_BY_ID[node.enemyFactionId];
  const playerFaction = FACTION_BY_ID["free_marches"];
  const heroClass = HERO_CLASS_BY_ID[heroSave.classId];
  const origin = ORIGIN_BY_ID[heroSave.originId];
  const missionBriefing = getCampaignMissionBriefing(node);
  const mapObjective = map?.scenario.objectives.primaryObjective;
  const objective = missionBriefing?.primaryObjective ?? mapObjective?.description ?? "Complete the mission objective.";
  const victoryCondition = mapObjective?.name ?? missionBriefing?.primaryObjective ?? "Complete the mission objective.";
  const readiness = canStart ? "Ready to launch." : `Unavailable: ${lockReason || "This battle cannot be started yet."}`;

  return `
    <section class="campaign-briefing-card" data-testid="campaign-prebattle-briefing" aria-labelledby="campaign-prebattle-heading">
      <div class="campaign-briefing-heading">
        <div>
          <p class="eyebrow">Battle briefing</p>
          <h3 id="campaign-prebattle-heading">Battle setup</h3>
        </div>
        <span class="campaign-briefing-readiness ${canStart ? "ready" : "blocked"}" data-testid="campaign-readiness">${escapeHtml(readiness)}</span>
      </div>
      <p class="campaign-briefing-identity" data-testid="campaign-identity">
        ${escapeHtml(heroSave.heroName)}${heroClass ? ` / ${escapeHtml(heroClass.name)}` : ""}${origin ? ` / ${escapeHtml(origin.name)}` : ""} / ${escapeHtml(campaignName)}
      </p>
      <dl class="campaign-briefing-facts">
        <div><dt>Location</dt><dd>${escapeHtml(map?.name ?? node.mapId)}</dd></div>
        <div><dt>Player</dt><dd>${escapeHtml(playerFaction?.name ?? "Barrosan Freeholds")}</dd></div>
        <div><dt>Opponent</dt><dd>${escapeHtml(enemyFaction?.name ?? node.enemyFactionId)}</dd></div>
        <div><dt>Difficulty</dt><dd>${escapeHtml(titleCase(node.difficulty))}</dd></div>
        <div><dt>Victory condition</dt><dd>${escapeHtml(victoryCondition)}</dd></div>
      </dl>
      <p class="campaign-briefing-objective"><span>Main objective</span><strong>${escapeHtml(objective)}</strong></p>
      <p class="campaign-briefing-state" data-testid="campaign-briefing-state"><span>Availability</span><strong>${escapeHtml(stateLabel)}</strong></p>
    </section>
  `;
}
