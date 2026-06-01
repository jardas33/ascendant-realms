import type { CampaignNodeDefinition, EnemyDoctrineDefinition, TacticalPlanDefinition, TacticalPlanId } from "../core/GameTypes";
import { getCampaignNodeGuidance } from "../core/FirstExperienceGuidance";
import { getCampaignNodeStatus } from "../core/CampaignRules";
import {
  formatCampaignActMechanicFocus,
  formatCampaignActStepLabel,
  getCampaignActStepForNode,
  getCampaignActStepStatus,
  getCampaignNodeLockedReason
} from "../core/campaign/CampaignActSpineRules";
import {
  formatCampaignScenarioModifierSummary,
  getCampaignMissionBriefing,
  getCampaignMissionRewardState,
  getCampaignScenarioModifierDefinitions,
  getMissionOptionalObjectiveStates
} from "../core/campaign/CampaignMissionRules";
import { getRivalNodePreview } from "../core/RivalRules";
import { selectEnemyDoctrineForCampaignNode, selectEnemyEliteSquadForBattle } from "../data/enemyDoctrines";
import { lumeNetworkForCampaignNode } from "../data/lumeNetworks";
import {
  DEFAULT_TACTICAL_PLAN_ID,
  formatTacticalPlanRecommendation,
  getTacticalPlan,
  getTacticalPlanRecommendations,
  tacticalPlanMatchesDoctrine,
  TACTICAL_PLANS
} from "../data/tacticalPlans";
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
  selectedTacticalPlanId?: TacticalPlanId;
}

export function renderNodeButton(nodeView: CampaignNodeViewModel): string {
  const { node } = nodeView;
  return `
      <button
        class="${escapeHtml(nodeView.cssClass)}"
        data-testid="${escapeHtml(nodeView.testId)}"
        data-campaign-node="${node.id}"
        data-campaign-chapter="${escapeHtml(nodeView.chapterId)}"
        data-campaign-state="${escapeHtml(nodeView.status)}"
        aria-label="${escapeHtml(`${node.name} ${nodeView.nodeTypeLabel} ${nodeView.statusLabel}${nodeView.rewardStateLabel ? ` ${nodeView.rewardStateLabel}` : ""}`)}"
        title="${escapeHtml(nodeView.rewardStateLabel ?? nodeView.statusLabel)}"
        style="${escapeHtml(nodeView.style)}"
      >
        <strong>${escapeHtml(node.name)}</strong>
        <span class="campaign-node-meta campaign-node-state">${escapeHtml(`${nodeView.nodeTypeLabel} - ${nodeView.statusLabel}`)}</span>
      </button>
    `;
}

export function renderNodeDetails(options: RenderNodeDetailsOptions): string {
  const { node, campaignSave, heroSave, selectedTacticalPlanId } = options;
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
  const lumeNetwork = lumeNetworkForCampaignNode(node.id);
  const scenarioModifiers = getCampaignScenarioModifierDefinitions(node);
  const enemyDoctrine = selectEnemyDoctrineForCampaignNode(node);
  const eliteSquad = selectEnemyEliteSquadForBattle({
    mode: node.nodeType === "battle" ? "campaign_node" : undefined,
    campaignNodeId: node.id,
    missionTypeId: node.missionTypeId,
    modifierIds: node.scenarioModifierIds,
    enemyHeroId: node.enemyHeroId,
    difficulty: node.difficulty
  });
  const objectiveStates = getMissionOptionalObjectiveStates({ campaign: campaignSave, node });
  const buildHint = recommendedBuildHint(node);
  const selectedTacticalPlan = getTacticalPlan(selectedTacticalPlanId ?? DEFAULT_TACTICAL_PLAN_ID);
  const showsTacticalPlan = node.nodeType === "battle" && !node.isPlaceholder;
  const actStep = getCampaignActStepForNode(node.id);
  const lockedReason = getCampaignNodeLockedReason(node, campaignSave);
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
        ${actStep ? renderAct1SpineMessage(actStep, campaignSave) : ""}
        ${missionBriefing ? renderMissionBriefingMessage(missionBriefing, scenarioModifiers) : ""}
        ${lumeNetwork ? renderLumeBriefingMessage(lumeNetwork) : ""}
        ${enemyDoctrine ? renderEnemyDoctrineMessage(enemyDoctrine, eliteSquad) : ""}
        ${renderPreBattleIntelligenceMessage(node, heroSave, enemyDoctrine, eliteSquad, selectedTacticalPlan)}
        ${renderTacticalPlanSelector(node, enemyDoctrine, selectedTacticalPlan)}
        ${renderMissionRewardMessage(node, missionReward)}
        ${objectiveStates.length > 0 ? renderOptionalObjectiveMessage(objectiveStates) : ""}
        ${buildHint ? renderGuidanceMessage(buildHint.title, buildHint.body, buildHint.actions, "compact") : ""}
        <div class="results-grid compact">
          <span>Map</span><strong>${escapeHtml(mapLabel)}</strong>
          <span>Act 1 role</span><strong>${escapeHtml(actStep ? formatCampaignActStepLabel(actStep) : "Side route / support")}</strong>
          <span>Pacing tier</span><strong>${escapeHtml(actStep ? titleCase(actStep.pacingTier) : "Standard")}</strong>
          <span>Locked reason</span><strong>${escapeHtml(lockedReason)}</strong>
          <span>Act 1 unlock</span><strong>${escapeHtml(actStep?.unlockSummary ?? "Follow existing campaign prerequisites.")}</strong>
          <span>Mission type</span><strong>${escapeHtml(missionBriefing?.missionType?.name ?? "None")}</strong>
          <span>Primary objective</span><strong>${escapeHtml(missionBriefing?.primaryObjective ?? "Complete the mission.")}</strong>
          <span>Onboarding hint</span><strong>${escapeHtml(actStep?.onboardingHint ?? nodeGuidance.body)}</strong>
          <span>Next action</span><strong>${escapeHtml(actStep?.nextAction ?? "Complete available nodes to open the next route.")}</strong>
          <span>Scenario modifiers</span><strong>${escapeHtml(formatScenarioModifierNames(scenarioModifiers))}</strong>
          <span>Modifier effects</span><strong>${escapeHtml(formatCampaignScenarioModifierSummary(node))}</strong>
          <span>Lume Network</span><strong>${escapeHtml(lumeNetwork ? `${lumeNetwork.benefit.name}: ${lumeNetwork.briefingCopy}` : "None")}</strong>
          <span>Reward preview</span><strong>${escapeHtml(missionBriefing?.rewardPreview ?? "See listed rewards.")}</strong>
          <span>Difficulty</span><strong>${titleCase(node.difficulty)}</strong>
          <span>Mission status</span><strong>${escapeHtml(missionReward.statusLabel)}</strong>
          <span>Campaign reward</span><strong>${escapeHtml(missionReward.rewardLabel)}</strong>
          <span>Replay rule</span><strong>${missionReward.isReplay ? "Reduced repeat battle rewards; node rewards do not duplicate" : "Full first-clear mission rewards available"}</strong>
          <span>Enemy</span><strong>${escapeHtml(faction?.name ?? node.enemyFactionId)}</strong>
          <span>Enemy Style</span><strong>${escapeHtml(personality ? `${personality.name}: ${personality.shortDescription}` : "Balanced Warlord: Mixed expansion and attacks.")}</strong>
          <span>Enemy doctrine</span><strong>${escapeHtml(enemyDoctrine ? enemyDoctrine.statusLabel : "Standard pressure")}</strong>
          <span>Counterplay</span><strong>${escapeHtml(enemyDoctrine ? enemyDoctrine.counterplay : "Use normal scouting, economy, and army timing.")}</strong>
          <span>Elite squad</span><strong>${escapeHtml(eliteSquad ? `${eliteSquad.name}: ${eliteSquad.counterplay}` : "None expected")}</strong>
          <span>Recommended plan</span><strong>${escapeHtml(showsTacticalPlan ? formatTacticalPlanRecommendation(enemyDoctrine?.id) : "Not applicable")}</strong>
          <span>Selected plan</span><strong>${escapeHtml(showsTacticalPlan ? `${selectedTacticalPlan.name}: ${selectedTacticalPlan.effectSummary}` : "Not applicable")}</strong>
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

function renderLumeBriefingMessage(network: NonNullable<ReturnType<typeof lumeNetworkForCampaignNode>>): string {
  return renderGuidanceMessage(
    network.benefit.name,
    network.briefingCopy,
    [network.benefit.summary, network.counterplay, "Battle-local only"],
    "compact"
  );
}

function renderPreBattleIntelligenceMessage(
  node: CampaignNodeDefinition,
  heroSave: HeroSaveData,
  doctrine: EnemyDoctrineDefinition | undefined,
  eliteSquad: ReturnType<typeof selectEnemyEliteSquadForBattle>,
  selectedPlan: TacticalPlanDefinition
): string {
  if (node.nodeType !== "battle" || node.isPlaceholder) {
    return "";
  }
  const doctrineName = doctrine?.name ?? "Standard pressure";
  const planFit = tacticalPlanMatchesDoctrine(selectedPlan.id, doctrine?.id)
    ? "Plan fits scouted doctrine"
    : `Suggested: ${formatTacticalPlanRecommendation(doctrine?.id)}`;
  return renderGuidanceMessage(
    "Pre-battle intelligence",
    `${doctrineName}. ${doctrine?.shortDescription ?? "No special doctrine scouted."} ${eliteSquad ? `Elite risk: ${eliteSquad.shortLabel}.` : "No elite squad expected."}`,
    [
      planFit,
      `Retinue: deploy Ready units or keep zero selected safely`,
      formatHeroLoadoutHint(heroSave)
    ],
    "compact"
  );
}

function renderTacticalPlanSelector(
  node: CampaignNodeDefinition,
  doctrine: EnemyDoctrineDefinition | undefined,
  selectedPlan: TacticalPlanDefinition
): string {
  if (node.nodeType !== "battle" || node.isPlaceholder) {
    return "";
  }
  const recommendations = new Set(getTacticalPlanRecommendations(doctrine?.id).map((plan) => plan.id));
  return `
      <section class="tactical-plan-panel" data-testid="campaign-tactical-plan-panel">
        <div>
          <strong>Tactical plan</strong>
          <p class="quiet">Choose one launch-local plan before battle. It does not change saves and will not stack.</p>
        </div>
        <div class="tactical-plan-grid">
          ${TACTICAL_PLANS.map((plan) => {
            const selected = plan.id === selectedPlan.id;
            const recommended = recommendations.has(plan.id);
            return `
              <button
                class="tactical-plan-button ${selected ? "selected" : ""}"
                data-tactical-plan="${escapeHtml(plan.id)}"
                data-testid="campaign-tactical-plan-${escapeHtml(plan.id)}"
                aria-pressed="${selected ? "true" : "false"}"
                title="${escapeHtml(`${plan.name}. ${plan.description} ${plan.effectSummary}`)}"
              >
                <span>
                  <strong>${escapeHtml(plan.name)}</strong>
                  <small>${escapeHtml(recommended ? "Recommended response" : plan.shortLabel)}</small>
                </span>
                <small>${escapeHtml(plan.effectSummary)}</small>
              </button>
            `;
          }).join("")}
        </div>
      </section>
    `;
}

function formatHeroLoadoutHint(heroSave: HeroSaveData): string {
  const relicInstance = heroSave.equipment.relic
    ? heroSave.inventory.find((item) => item.instanceId === heroSave.equipment.relic)
    : undefined;
  const relic = relicInstance ? ITEM_BY_ID[relicInstance.itemId] : undefined;
  const skillCount = Object.values(heroSave.allocatedSkills ?? {}).reduce((total, rank) => total + Math.max(0, rank), 0);
  if (relic) {
    return `Hero: ${relic.name} equipped, ${skillCount} skill unlock${skillCount === 1 ? "" : "s"}`;
  }
  if (heroSave.skillPoints > 0) {
    return `Hero: ${heroSave.skillPoints} skill point${heroSave.skillPoints === 1 ? "" : "s"} ready`;
  }
  return "Hero: equip a relic or spend skill points when available";
}

function renderAct1SpineMessage(step: NonNullable<ReturnType<typeof getCampaignActStepForNode>>, campaignSave: CampaignSaveData): string {
  const stepStatus = getCampaignActStepStatus(step, campaignSave);
  return renderGuidanceMessage(
    formatCampaignActStepLabel(step),
    step.playerGoal,
    [
      `Pacing: ${titleCase(step.pacingTier)}`,
      `Status: ${titleCase(String(stepStatus))}`,
      formatCampaignActMechanicFocus(step)
    ],
    "compact"
  );
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

function renderEnemyDoctrineMessage(
  doctrine: NonNullable<ReturnType<typeof selectEnemyDoctrineForCampaignNode>>,
  eliteSquad: ReturnType<typeof selectEnemyEliteSquadForBattle>
): string {
  return renderGuidanceMessage(
    `Enemy doctrine: ${doctrine.name}`,
    doctrine.threatWarning,
    [
      doctrine.counterplay,
      eliteSquad ? `Elite: ${eliteSquad.shortLabel}` : "No elite squad expected",
      doctrine.tags.slice(0, 2).join(" / ")
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

export function formatCampaignMissionPanelNextStep(node: CampaignNodeDefinition, campaignSave: CampaignSaveData): string {
  const lockedReason = getCampaignNodeLockedReason(node, campaignSave);
  const status = getCampaignNodeStatus(node, campaignSave);
  if (status === "locked" || node.isPlaceholder) {
    return lockedReason;
  }
  if (status === "completed" && node.nodeType === "battle") {
    const actStep = getCampaignActStepForNode(node.id);
    if (node.id === "ashen_outpost") {
      return "Act 1 complete; replay optional objectives safely or continue toward Cinderfen.";
    }
    return actStep?.replayHint ?? "Replay safely; first-clear rewards and one-time objective credit stay claimed.";
  }
  if (node.choices?.length) {
    return "Pick a support choice when useful; choices use existing campaign resources and rewards.";
  }
  const actStep = getCampaignActStepForNode(node.id);
  return actStep?.nextAction ?? "Complete this node to advance the campaign route.";
}
