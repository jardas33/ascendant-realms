import Phaser from "phaser";
import { ASSET_IDS } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { cloneBattleLaunchRequestWithHero, createSkirmishBattleLaunchRequest, type BattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { LEVEL_XP_THRESHOLDS } from "../core/Constants";
import { getResultsGuidance } from "../core/FirstExperienceGuidance";
import type {
  BattleMapDefinition,
  BattleRewardResult,
  BattleStats,
  EquipmentSlot,
  HeroBaseStats,
  ItemDefinition,
  ResourceBag,
  RewardLevelUpSummary
} from "../core/GameTypes";
import { formatTime } from "../core/MathUtils";
import { xpProgressForLevel } from "../core/Progression";
import {
  buildRewardItemPresentations,
  createDefeatTips,
  equipRewardItemNow,
  rewardStateLabel,
  type RewardItemPresentation,
  type StatDelta
} from "../core/ResultsFlow";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { getBattleDifficulty } from "../data/battlePacing";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, MAP_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { RESOURCE_DEFINITIONS } from "../data/resources";
import type { HeroSaveData } from "../save/SaveTypes";
import { calculateLiveHeroStats } from "../core/HeroProgressionRules";

interface CampaignResultsData {
  completedNodeId: string;
  completedNodeName: string;
  unlockedNodeIds: string[];
  unlockedNodeNames: string[];
  nodeReward: BattleRewardResult;
  nodeLevelUp: RewardLevelUpSummary;
  campaignResources: ResourceBag;
}

interface ResultsData {
  stats: BattleStats;
  heroSave: HeroSaveData;
  startingHeroSave?: HeroSaveData;
  rewardItemIds?: string[];
  reward?: BattleRewardResult;
  rewardLevelUp?: RewardLevelUpSummary;
  launchRequest?: BattleLaunchRequest;
  campaignResult?: CampaignResultsData;
}

const EQUIPPABLE_SLOTS: EquipmentSlot[] = ["weapon", "armor", "trinket", "relic"];

export class ResultsScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private dataSnapshot?: ResultsData;
  private status = "";

  constructor() {
    super(SCENE_KEYS.results);
  }

  init(data: ResultsData): void {
    this.dataSnapshot = data;
    this.status = this.initialStatus(data);
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root || !this.dataSnapshot) {
      this.scene.start(SCENE_KEYS.mainMenu);
      return;
    }

    this.handler = (event) => {
      const button = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-results-action]");
      if (!button) {
        return;
      }
      const action = button.dataset.resultsAction;
      const itemId = button.dataset.itemId ?? "";
      if (action === "equip") {
        this.equipRewardItem(itemId);
      }
      if (action === "retry") {
        this.retryBattle();
      }
      if (action === "campaign") {
        this.returnToCampaign();
      }
      if (action === "skirmish") {
        this.scene.start(SCENE_KEYS.skirmishSetup, {
          heroSave: this.dataSnapshot?.heroSave,
          launchRequest: this.dataSnapshot?.launchRequest
        });
      }
      if (action === "inventory") {
        this.scene.start(SCENE_KEYS.heroProgression, {
          heroSave: this.dataSnapshot?.heroSave,
          stats: this.dataSnapshot?.stats,
          rewardItemIds: this.dataSnapshot?.rewardItemIds,
          reward: this.dataSnapshot?.reward,
          rewardLevelUp: this.dataSnapshot?.rewardLevelUp,
          launchRequest: this.dataSnapshot?.launchRequest,
          returnMode: this.dataSnapshot?.launchRequest?.mode === "campaign_node" ? "campaign" : "skirmish"
        });
      }
      if (action === "menu") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
    };
    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private retryBattle(): void {
    if (!this.dataSnapshot) {
      return;
    }
    const retryHero = this.dataSnapshot.stats.outcome === "defeat" ? this.dataSnapshot.startingHeroSave ?? this.dataSnapshot.heroSave : this.dataSnapshot.heroSave;
    this.scene.start(SCENE_KEYS.battle, {
      launchRequest: this.dataSnapshot.launchRequest
        ? cloneBattleLaunchRequestWithHero(this.dataSnapshot.launchRequest, retryHero, { sourceId: "results_retry" })
        : createSkirmishBattleLaunchRequest(retryHero, { sourceId: "results_retry" })
    });
  }

  private returnToCampaign(): void {
    const save = SaveSystem.load();
    if (save) {
      this.scene.start(SCENE_KEYS.campaignMap, {
        heroSave: save.hero,
        campaignSave: save.campaign,
        stats: this.dataSnapshot?.stats,
        completedNodeId: this.dataSnapshot?.campaignResult?.completedNodeId
      });
      return;
    }
    this.scene.start(SCENE_KEYS.mainMenu);
  }

  private equipRewardItem(itemId: string): void {
    if (!this.dataSnapshot) {
      return;
    }
    const heroClass = HERO_CLASS_BY_ID[this.dataSnapshot.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[this.dataSnapshot.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    const result = equipRewardItemNow({
      hero: this.dataSnapshot.heroSave,
      itemId,
      itemById: ITEM_BY_ID,
      heroClass,
      origin,
      skillById: SKILL_NODE_BY_ID
    });
    this.status = result.message;
    if (result.ok) {
      this.dataSnapshot = {
        ...this.dataSnapshot,
        heroSave: result.hero
      };
      SaveSystem.saveHero(result.hero);
    }
    this.render();
  }

  private render(): void {
    if (!this.root || !this.dataSnapshot) {
      return;
    }
    const { stats } = this.dataSnapshot;
    const isVictory = stats.outcome === "victory";
    const title = isVictory ? "Victory" : "Defeat";
    const backgroundId = isVictory ? ASSET_IDS.ui.victoryScreenBackground : ASSET_IDS.ui.defeatScreenBackground;
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell progression-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: backgroundId })}>
        <section class="menu-panel extra-wide results-panel ${stats.outcome}">
          <p class="eyebrow">Battle Results</p>
          <div class="results-title-row">
            <div>
              <h1>${title}</h1>
              <p class="menu-copy">${escapeHtml(this.resultSubtitle())}</p>
            </div>
            <div class="skill-points compact">
              <span>Hero Level</span>
              <strong>${this.dataSnapshot.heroSave.level}</strong>
            </div>
          </div>
          ${this.renderBattleSummary()}
          ${this.renderGuidancePanel()}
          ${isVictory ? this.renderVictoryRewards() : this.renderDefeatTips()}
          <div class="status-box">${escapeHtml(this.status)}</div>
          ${this.renderHeroStats()}
          <div class="menu-actions row">
            ${this.renderPrimaryActions()}
          </div>
        </section>
      </main>
    `;
  }

  private resultSubtitle(): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const map = this.dataSnapshot.launchRequest ? MAP_BY_ID[this.dataSnapshot.launchRequest.mapId] : undefined;
    const difficulty = this.dataSnapshot.launchRequest ? getBattleDifficulty(this.dataSnapshot.launchRequest.difficulty) : undefined;
    return `${map?.name ?? "Unknown battlefield"} - ${difficulty?.name ?? "Unknown difficulty"} - ${formatTime(this.dataSnapshot.stats.timeSeconds)}`;
  }

  private renderBattleSummary(): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const { stats, heroSave, startingHeroSave } = this.dataSnapshot;
    const map = this.dataSnapshot.launchRequest ? MAP_BY_ID[this.dataSnapshot.launchRequest.mapId] : undefined;
    const difficulty = this.dataSnapshot.launchRequest ? getBattleDifficulty(this.dataSnapshot.launchRequest.difficulty) : undefined;
    const beforeHero = startingHeroSave ?? heroSave;
    return `
      <div class="results-sections">
        <section class="result-block">
          <h2>Battle</h2>
          <div class="results-grid compact">
            <span>Map</span><strong>${escapeHtml(map?.name ?? "Unknown")}</strong>
            <span>Difficulty</span><strong>${escapeHtml(difficulty?.name ?? "Unknown")}</strong>
            <span>Battle time</span><strong>${formatTime(stats.timeSeconds)}</strong>
            <span>First site captured</span><strong>${stats.firstSiteCaptured ? titleCase(stats.firstSiteCaptured) : "None"}</strong>
            <span>Buildings built</span><strong>${stats.buildingsBuilt}</strong>
            <span>Units trained</span><strong>${stats.unitsTrained}</strong>
            <span>Enemy waves survived</span><strong>${stats.enemyWavesSurvived}</strong>
            <span>Units killed</span><strong>${stats.unitsKilled}</strong>
            <span>Buildings destroyed</span><strong>${stats.buildingsDestroyed}</strong>
            <span>Sites captured</span><strong>${stats.resourcesCaptured}</strong>
          </div>
        </section>
        <section class="result-block">
          <h2>Hero XP</h2>
          ${this.renderXpProgress(beforeHero, heroSave)}
        </section>
      </div>
      ${this.renderSpecialObjectives(map)}
    `;
  }

  private renderSpecialObjectives(map?: BattleMapDefinition): string {
    const objectives = map?.scenario.objectives.secondaryObjectives ?? [];
    if (!this.dataSnapshot || objectives.length === 0) {
      return "";
    }
    const completed = new Set(this.dataSnapshot.stats.completedObjectiveIds ?? []);
    return `
      <section class="result-block wide special-objectives">
        <h2>Special Objectives</h2>
        <div class="results-grid compact">
          ${objectives
            .map(
              (objective) => `
                <span>${escapeHtml(objective.name)}</span>
                <strong>${completed.has(objective.id) ? "Completed" : "Incomplete"}</strong>
              `
            )
            .join("")}
        </div>
      </section>
    `;
  }

  private renderXpProgress(beforeHero: HeroSaveData, afterHero: HeroSaveData): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const before = xpProgressForLevel(beforeHero.xp, beforeHero.level, LEVEL_XP_THRESHOLDS);
    const after = xpProgressForLevel(afterHero.xp, afterHero.level, LEVEL_XP_THRESHOLDS);
    const skillPointsGained =
      (this.dataSnapshot.rewardLevelUp?.skillPointsGained ?? 0) + (this.dataSnapshot.campaignResult?.nodeLevelUp.skillPointsGained ?? 0);
    const levelsGained = Math.max(0, afterHero.level - beforeHero.level);
    return `
      <div class="results-grid compact">
        <span>XP gained</span><strong>${this.dataSnapshot.stats.xpGained}</strong>
        <span>Before</span><strong>Level ${beforeHero.level} - ${this.formatXpProgress(beforeHero.xp, beforeHero.level, before)}</strong>
        <span>After</span><strong>Level ${afterHero.level} - ${this.formatXpProgress(afterHero.xp, afterHero.level, after)}</strong>
        <span>Level-up</span><strong>${levelsGained > 0 ? `+${levelsGained} level${levelsGained === 1 ? "" : "s"}` : "No level-up"}</strong>
        <span>Skill points gained</span><strong>${skillPointsGained}</strong>
      </div>
      <div class="xp-compare-bars">
        <div><span>Before</span><i style="width: ${Math.round(before.percent)}%"></i></div>
        <div><span>After</span><i style="width: ${Math.round(after.percent)}%"></i></div>
      </div>
    `;
  }

  private renderGuidancePanel(): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const rewardItemCount =
      (this.dataSnapshot.reward?.itemIds.length ?? this.dataSnapshot.rewardItemIds?.length ?? 0) +
      (this.dataSnapshot.campaignResult?.nodeReward.itemIds.length ?? 0);
    const skillPointsGained =
      (this.dataSnapshot.rewardLevelUp?.skillPointsGained ?? 0) + (this.dataSnapshot.campaignResult?.nodeLevelUp.skillPointsGained ?? 0);
    const guidance = getResultsGuidance({
      outcome: this.dataSnapshot.stats.outcome,
      mode: this.dataSnapshot.launchRequest?.mode,
      completedNodeId: this.dataSnapshot.campaignResult?.completedNodeId,
      completedNodeName: this.dataSnapshot.campaignResult?.completedNodeName,
      unlockedNodeNames: this.dataSnapshot.campaignResult?.unlockedNodeNames,
      rewardItemCount,
      skillPointsGained
    });
    return `
      <section class="guidance-card results-guidance">
        <strong>${escapeHtml(guidance.title)}</strong>
        <p>${escapeHtml(guidance.body)}</p>
        <div class="tag-row">
          ${guidance.actions.map((action) => `<span class="tag">${escapeHtml(action)}</span>`).join("")}
        </div>
      </section>
    `;
  }

  private renderVictoryRewards(): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const reward = this.dataSnapshot.reward ?? { itemIds: this.dataSnapshot.rewardItemIds ?? [], resources: {}, xp: 0 };
    const startingInventory = this.dataSnapshot.startingHeroSave?.inventory ?? [];
    const battleItems = buildRewardItemPresentations({
      itemIds: reward.itemIds,
      itemById: ITEM_BY_ID,
      startingInventory
    });
    return `
      <div class="results-sections rewards">
        <section class="result-block wide">
          <h2>Battle Rewards</h2>
          <div class="results-grid compact">
            <span>Reward XP</span><strong>${reward.xp}</strong>
            <span>Resource awards</span><strong>${escapeHtml(this.formatResourceRewards(reward.resources))}</strong>
          </div>
          ${this.renderRewardItems(battleItems)}
        </section>
        ${this.renderCampaignRewards(reward.itemIds)}
      </div>
    `;
  }

  private renderCampaignRewards(alreadyPresentedItemIds: string[]): string {
    const campaign = this.dataSnapshot?.campaignResult;
    if (!campaign || !this.dataSnapshot) {
      return "";
    }
    const startingInventory = this.dataSnapshot.startingHeroSave?.inventory ?? [];
    const items = buildRewardItemPresentations({
      itemIds: campaign.nodeReward.itemIds,
      itemById: ITEM_BY_ID,
      startingInventory,
      alreadyPresentedIds: alreadyPresentedItemIds
    });
    return `
      <section class="result-block wide campaign-reward-block">
        <h2>Campaign Node Complete</h2>
        <div class="results-grid compact">
          <span>Completed</span><strong>${escapeHtml(campaign.completedNodeName)}</strong>
          <span>Unlocked</span><strong>${campaign.unlockedNodeNames.length > 0 ? escapeHtml(campaign.unlockedNodeNames.join(", ")) : "No new nodes"}</strong>
          <span>Node XP</span><strong>${campaign.nodeReward.xp}</strong>
          <span>Node resources added</span><strong>${escapeHtml(this.formatResourceRewards(campaign.nodeReward.resources))}</strong>
          <span>Campaign bank</span><strong>${escapeHtml(this.formatResourceRewards(campaign.campaignResources))}</strong>
        </div>
        <p class="quiet reward-note">Node resources were added to the persistent campaign bank. Shops, mercenaries, repairs, upgrades, node choices, and stronghold development can spend this bank in future systems.</p>
        ${this.renderRewardItems(items)}
      </section>
    `;
  }

  private renderRewardItems(items: RewardItemPresentation[]): string {
    if (items.length === 0) {
      return `<p class="quiet reward-note">No new item from this reward group. Your inventory remains unchanged.</p>`;
    }
    return `
      <div class="reward-card-list">
        ${items.map((entry) => this.renderRewardItem(entry)).join("")}
      </div>
    `;
  }

  private renderRewardItem(entry: RewardItemPresentation): string {
    const item = entry.item;
    const equipped = this.dataSnapshot?.heroSave.equipment[item.slot] === item.id;
    const canEquip = EQUIPPABLE_SLOTS.includes(item.slot);
    const currentItem = this.currentItemInSlot(item.slot);
    const deltas = this.previewEquipDeltas(item);
    return `
      <article class="reward-card ${this.rarityClass(item.rarity)} ${entry.state}">
        <div class="reward-card-main">
          <div>
            <strong>${this.renderItemName(item)} <span class="reward-state">${escapeHtml(rewardStateLabel(entry.state))}</span></strong>
            <small>${titleCase(item.slot)} - ${escapeHtml(this.formatStatMods(item.statMods))}</small>
            <p>${escapeHtml(item.description)}</p>
            <small>${escapeHtml(item.flavorText)}</small>
            <small>${escapeHtml(this.formatTags(item.tags))}</small>
            <small>${entry.state === "new" ? "Added to inventory." : "Inventory kept one copy."}</small>
          </div>
          <div class="reward-actions">
            <small>Current ${titleCase(item.slot)}: ${currentItem ? escapeHtml(currentItem.name) : "Empty"}</small>
            <small class="stat-preview">${escapeHtml(this.formatDeltas(deltas))}</small>
            ${
              canEquip
                ? `<button data-results-action="equip" data-item-id="${item.id}" ${equipped ? "disabled" : ""}>${equipped ? "Equipped" : "Equip Now"}</button>`
                : ""
            }
          </div>
        </div>
      </article>
    `;
  }

  private renderDefeatTips(): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const tips = createDefeatTips(this.dataSnapshot.stats, { hero: this.dataSnapshot.heroSave });
    return `
      <section class="result-block wide defeat-tips">
        <h2>Next Attempt</h2>
        <ul>
          ${tips.map((tip) => `<li>${escapeHtml(tip)}</li>`).join("")}
        </ul>
      </section>
    `;
  }

  private renderHeroStats(): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const stats = this.liveStatsFor(this.dataSnapshot.heroSave);
    const rows: Array<[string, number]> = [
      ["HP", stats.maxHp],
      ["Mana", stats.maxMana],
      ["Damage", stats.damage],
      ["Armor", stats.armor],
      ["Range", stats.range],
      ["Speed", stats.speed],
      ["Might", stats.might],
      ["Command", stats.command],
      ["Arcana", stats.arcana],
      ["Faith", stats.faith]
    ];
    return `
      <section class="result-block wide hero-stat-strip">
        <h2>Current Hero Stats</h2>
        <div class="stat-list progression-stats">
          ${rows.map(([label, value]) => `<span>${label} <strong>${Math.round(value)}</strong></span>`).join("")}
        </div>
      </section>
    `;
  }

  private renderPrimaryActions(): string {
    if (!this.dataSnapshot) {
      return "";
    }
    const isCampaign = this.dataSnapshot.launchRequest?.mode === "campaign_node";
    if (this.dataSnapshot.stats.outcome === "defeat") {
      return `
        <button data-results-action="retry">Retry</button>
        <button data-results-action="${isCampaign ? "campaign" : "menu"}">${isCampaign ? "Campaign Map" : "Main Menu"}</button>
        ${isCampaign ? `<button data-results-action="menu">Main Menu</button>` : ""}
      `;
    }
    return `
      ${isCampaign ? `<button data-results-action="campaign">Campaign Map</button>` : `<button data-results-action="skirmish">Continue Skirmish</button>`}
      <button data-results-action="inventory">Open Hero Inventory</button>
      <button data-results-action="menu">Main Menu</button>
    `;
  }

  private currentItemInSlot(slot: EquipmentSlot): ItemDefinition | undefined {
    const itemId = this.dataSnapshot?.heroSave.equipment[slot];
    return itemId ? ITEM_BY_ID[itemId] : undefined;
  }

  private previewEquipDeltas(item: ItemDefinition): StatDelta[] {
    if (!this.dataSnapshot) {
      return [];
    }
    const heroClass = HERO_CLASS_BY_ID[this.dataSnapshot.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[this.dataSnapshot.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    return equipRewardItemNow({
      hero: this.dataSnapshot.heroSave,
      itemId: item.id,
      itemById: ITEM_BY_ID,
      heroClass,
      origin,
      skillById: SKILL_NODE_BY_ID
    }).deltas;
  }

  private liveStatsFor(save: HeroSaveData): HeroBaseStats {
    const heroClass = HERO_CLASS_BY_ID[save.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[save.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    return calculateLiveHeroStats(save, heroClass, origin, SKILL_NODE_BY_ID, ITEM_BY_ID);
  }

  private formatXpProgress(xp: number, level: number, progress: ReturnType<typeof xpProgressForLevel>): string {
    if (progress.nextLevelXp <= progress.currentLevelXp) {
      return "Level cap reached";
    }
    return `${Math.max(0, xp - progress.currentLevelXp)} / ${progress.nextLevelXp - progress.currentLevelXp} XP (${Math.round(progress.percent)}%)`;
  }

  private formatDeltas(deltas: StatDelta[]): string {
    if (deltas.length === 0) {
      return "No stat change.";
    }
    return deltas.map((delta) => `${delta.delta > 0 ? "+" : ""}${delta.delta} ${statLabel(delta.key)}`).join(", ");
  }

  private formatStatMods(mods: Partial<Record<keyof HeroBaseStats, number>>): string {
    const formatted = Object.entries(mods)
      .map(([key, value]) => `${value && value > 0 ? "+" : ""}${value} ${statLabel(key)}`)
      .join(", ");
    return formatted || "No stat modifiers";
  }

  private renderItemName(item: ItemDefinition): string {
    return `${escapeHtml(item.name)} <span class="rarity-pill ${this.rarityClass(item.rarity)}">${titleCase(item.rarity)}</span>`;
  }

  private rarityClass(rarity: ItemDefinition["rarity"]): string {
    return `rarity-${rarity}`;
  }

  private formatResourceRewards(resources: BattleRewardResult["resources"]): string {
    const rewards = Object.entries(resources)
      .filter(([, amount]) => typeof amount === "number" && amount > 0)
      .map(([resource, amount]) => `${amount} ${RESOURCE_DEFINITIONS.find((definition) => definition.id === resource)?.name ?? titleCase(resource)}`);
    return rewards.length > 0 ? rewards.join(", ") : "None";
  }

  private formatTags(tags: string[]): string {
    return tags.length > 0 ? `Tags: ${tags.map(titleCase).join(", ")}` : "No tags";
  }

  private initialStatus(data: ResultsData): string {
    if (data.stats.outcome === "defeat") {
      return "No victory rewards were granted. Retry when ready, or return and adjust your plan.";
    }
    const rewardCount = (data.reward?.itemIds.length ?? data.rewardItemIds?.length ?? 0) + (data.campaignResult?.nodeReward.itemIds.length ?? 0);
    const skillPointsGained = (data.rewardLevelUp?.skillPointsGained ?? 0) + (data.campaignResult?.nodeLevelUp.skillPointsGained ?? 0);
    if (rewardCount > 0 && skillPointsGained > 0) {
      return "You received an item and gained a skill point. Equip the reward and open hero progression before the next node.";
    }
    if (skillPointsGained > 0) {
      return "You gained a skill point. Open hero progression to spend it before the next battle.";
    }
    return rewardCount > 0
      ? "You received an item. It was added to inventory; equip it now to improve your hero."
      : "Victory rewards were applied. No new equipment dropped this time.";
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}

function statLabel(key: string): string {
  const labels: Record<string, string> = {
    maxHp: "HP",
    maxMana: "Mana",
    attackCooldown: "Attack cooldown"
  };
  return labels[key] ?? key.replace(/([A-Z])/g, " $1").toLowerCase();
}

function titleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).replaceAll("_", " ");
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
