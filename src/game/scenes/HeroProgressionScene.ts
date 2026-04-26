import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import type { BattleLaunchRequest } from "../battle/BattleLaunchRequest";
import { LEVEL_XP_THRESHOLDS } from "../core/Constants";
import { getHeroProgressionGuidance } from "../core/FirstExperienceGuidance";
import type {
  BattleRewardResult,
  BattleStats,
  HeroBaseStats,
  HeroStatMods,
  ItemDefinition,
  RewardLevelUpSummary,
  SkillNodeDefinition
} from "../core/GameTypes";
import {
  EQUIPMENT_SLOTS,
  allocateSkillPoint,
  calculateLiveHeroStats,
  canAllocateSkill,
  equipItem,
  saveWithRecalculatedStats,
  unequipItem
} from "../core/HeroProgressionRules";
import { formatTime } from "../core/MathUtils";
import { xpProgressForLevel } from "../core/Progression";
import { SaveSystem, createFallbackHeroSave } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { getBattleDifficulty } from "../data/battlePacing";
import { HERO_CLASS_BY_ID, ITEM_BY_ID, MAP_BY_ID, ORIGIN_BY_ID, SKILL_NODE_BY_ID } from "../data/contentIndex";
import { SKILL_NODES, SKILL_TREES } from "../data/skillTrees";
import type { HeroSaveData } from "../save/SaveTypes";

interface HeroProgressionData {
  stats?: BattleStats;
  heroSave?: HeroSaveData;
  rewardItemIds?: string[];
  reward?: BattleRewardResult;
  rewardLevelUp?: RewardLevelUpSummary;
  launchRequest?: BattleLaunchRequest;
  returnMode?: "campaign" | "skirmish";
}

export class HeroProgressionScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private heroSave: HeroSaveData = createFallbackHeroSave();
  private stats?: BattleStats;
  private rewardItemIds: string[] = [];
  private reward?: BattleRewardResult;
  private rewardLevelUp?: RewardLevelUpSummary;
  private launchRequest?: BattleLaunchRequest;
  private returnMode: "campaign" | "skirmish" = "skirmish";
  private status = "Spend skill points, equip rewards, or continue into another skirmish.";

  constructor() {
    super(SCENE_KEYS.heroProgression);
  }

  init(data: HeroProgressionData): void {
    this.heroSave = data.heroSave ?? SaveSystem.load()?.hero ?? createFallbackHeroSave();
    this.stats = data.stats;
    this.rewardItemIds = data.rewardItemIds ?? [];
    this.reward = data.reward ?? (data.rewardItemIds ? { itemIds: data.rewardItemIds, resources: {}, xp: 0 } : undefined);
    this.rewardLevelUp = data.rewardLevelUp;
    this.launchRequest = data.launchRequest;
    this.returnMode = data.returnMode ?? (data.launchRequest?.mode === "campaign_node" ? "campaign" : "skirmish");
    this.heroSave = this.finalizeHeroSave(this.heroSave);
    this.status = this.initialStatus();
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }

    this.handler = (event) => {
      const button = (event.target as HTMLElement).closest<HTMLButtonElement>("button[data-progression-action]");
      if (!button) {
        return;
      }

      const action = button.dataset.progressionAction;
      const id = button.dataset.id ?? "";
      if (action === "skill") {
        const result = allocateSkillPoint(this.heroSave, id, SKILL_NODE_BY_ID);
        this.applyProgressionResult(result.hero, result.message, result.ok);
      }
      if (action === "equip") {
        const result = equipItem(this.heroSave, id, ITEM_BY_ID);
        this.applyProgressionResult(result.hero, result.message, result.ok);
      }
      if (action === "unequip") {
        const slot = button.dataset.slot;
        if (slot === "weapon" || slot === "armor" || slot === "trinket") {
          const result = unequipItem(this.heroSave, slot);
          this.applyProgressionResult(result.hero, result.message, result.ok);
        }
      }
      if (action === "skirmish") {
        this.scene.start(SCENE_KEYS.skirmishSetup, {
          heroSave: this.heroSave,
          launchRequest: this.launchRequest
        });
      }
      if (action === "campaign") {
        const save = SaveSystem.load();
        if (save) {
          this.scene.start(SCENE_KEYS.campaignMap, {
            heroSave: save.hero,
            campaignSave: save.campaign,
            stats: this.stats
          });
        }
      }
      if (action === "menu") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
    };

    this.root.addEventListener("click", this.handler);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private applyProgressionResult(hero: HeroSaveData, message: string, changed: boolean): void {
    this.heroSave = this.finalizeHeroSave(hero);
    this.status = message;
    if (changed) {
      SaveSystem.saveHero(this.heroSave);
    }
    this.render();
  }

  private finalizeHeroSave(save: HeroSaveData): HeroSaveData {
    const heroClass = HERO_CLASS_BY_ID[save.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[save.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    return saveWithRecalculatedStats(save, heroClass, origin, SKILL_NODE_BY_ID, ITEM_BY_ID);
  }

  private render(): void {
    if (!this.root) {
      return;
    }
    const heroClass = HERO_CLASS_BY_ID[this.heroSave.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[this.heroSave.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    const stats = calculateLiveHeroStats(this.heroSave, heroClass, origin, SKILL_NODE_BY_ID, ITEM_BY_ID);
    const portraitId = heroPortraitAssetId(heroClass.id);
    const hasPortrait = AssetLoader.hasAsset(portraitId);
    const backgroundId = this.stats?.outcome === "victory" ? ASSET_IDS.ui.victoryScreenBackground : undefined;

    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell progression-shell asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: backgroundId })}>
        <section class="menu-panel extra-wide progression-panel ${this.stats?.outcome === "victory" ? "results-panel victory" : ""}">
          <div class="progression-header">
            <div class="progression-title-row">
              <div class="portrait large ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, this.toCssColor(heroClass.color))}></div>
              <div>
              <p class="eyebrow">${this.stats ? "Victory Progression" : "Hero Inventory"}</p>
              <h1>${escapeHtml(this.heroSave.heroName)}</h1>
              <p class="menu-copy">${escapeHtml(heroClass.name)} - ${escapeHtml(origin.name)} - Level ${this.heroSave.level}</p>
              </div>
            </div>
            <div class="skill-points">
              <span>Skill Points</span>
              <strong>${this.heroSave.skillPoints}</strong>
            </div>
          </div>
          ${this.renderBattleResults()}
          ${this.renderGuidancePanel()}
          <div class="status-box">${escapeHtml(this.status)}</div>
          <div class="progression-grid">
            <section>
              <h2>Hero Stats</h2>
              ${this.renderStats(stats)}
              <h2>Abilities</h2>
              <div class="tag-row">${this.heroSave.unlockedAbilities
                .map((abilityId) => `<span class="tag">${escapeHtml(abilityId.replaceAll("_", " "))}</span>`)
                .join("")}</div>
            </section>
            <section>
              <h2>Equipment</h2>
              ${this.renderEquipment()}
              <h2>Inventory</h2>
              ${this.renderInventory()}
            </section>
          </div>
          <h2>Skill Trees</h2>
          <div class="skill-tree-grid">
            ${SKILL_TREES.map((tree) => this.renderSkillTree(tree.id, tree.name, tree.description)).join("")}
          </div>
          <div class="menu-actions row">
            <button data-progression-action="${this.returnMode === "campaign" ? "campaign" : "skirmish"}">
              ${this.returnMode === "campaign" ? "Campaign Map" : "Continue Skirmish"}
            </button>
            <button data-progression-action="menu">Main Menu</button>
          </div>
        </section>
      </main>
    `;
  }

  private renderGuidancePanel(): string {
    const guidance = getHeroProgressionGuidance({
      hero: this.heroSave,
      recentRewardItemCount: this.rewardItemIds.length,
      skillPointsGained: this.rewardLevelUp?.skillPointsGained,
      inCampaign: this.returnMode === "campaign"
    });
    return `
      <div class="guidance-card">
        <strong>${escapeHtml(guidance.title)}</strong>
        <p>${escapeHtml(guidance.body)}</p>
        <div class="tag-row">
          ${guidance.actions.map((action) => `<span class="tag">${escapeHtml(action)}</span>`).join("")}
        </div>
      </div>
    `;
  }

  private renderBattleResults(): string {
    if (!this.stats) {
      return "";
    }
    const reward = this.reward ?? { itemIds: this.rewardItemIds, resources: {}, xp: 0 };
    const rewards = reward.itemIds
      .map((itemId) => ITEM_BY_ID[itemId])
      .filter((item): item is ItemDefinition => item !== undefined);
    const map = this.launchRequest ? MAP_BY_ID[this.launchRequest.mapId] : undefined;
    const difficulty = this.launchRequest ? getBattleDifficulty(this.launchRequest.difficulty) : undefined;
    const progress = xpProgressForLevel(this.heroSave.xp, this.heroSave.level, LEVEL_XP_THRESHOLDS);
    const xpProgressText =
      progress.nextLevelXp > progress.currentLevelXp
        ? `${Math.max(0, this.heroSave.xp - progress.currentLevelXp)} / ${progress.nextLevelXp - progress.currentLevelXp}`
        : "Level cap reached";
    const skillPointsGained = this.rewardLevelUp?.skillPointsGained ?? 0;
    return `
      <div class="results-grid compact">
        <span>Map</span><strong>${escapeHtml(map?.name ?? "Unknown")}</strong>
        <span>Difficulty</span><strong>${escapeHtml(difficulty?.name ?? "Unknown")}</strong>
        <span>XP gained</span><strong>${this.stats.xpGained}${reward.xp > 0 ? ` (${reward.xp} victory bonus)` : ""}</strong>
        <span>XP progress</span><strong>${escapeHtml(xpProgressText)} - ${Math.round(progress.percent)}%</strong>
        <span>Skill points gained</span><strong>${skillPointsGained}</strong>
        <span>Survival time</span><strong>${formatTime(this.stats.timeSeconds)}</strong>
        <span>First site captured</span><strong>${this.stats.firstSiteCaptured ? titleCase(this.stats.firstSiteCaptured) : "None"}</strong>
        <span>Buildings built</span><strong>${this.stats.buildingsBuilt}</strong>
        <span>Units trained</span><strong>${this.stats.unitsTrained}</strong>
        <span>Enemy waves survived</span><strong>${this.stats.enemyWavesSurvived}</strong>
        <span>Units killed</span><strong>${this.stats.unitsKilled}</strong>
        <span>Buildings destroyed</span><strong>${this.stats.buildingsDestroyed}</strong>
        <span>Sites captured</span><strong>${this.stats.resourcesCaptured}</strong>
        <span>Item rewards</span><strong>${rewards.length > 0 ? rewards.map((item) => this.renderItemName(item)).join(", ") : "No new item"}</strong>
        <span>Resource rewards</span><strong>${escapeHtml(this.formatResourceRewards(reward.resources))}</strong>
      </div>
    `;
  }

  private renderStats(stats: HeroBaseStats): string {
    const rows: Array<[string, number]> = [
      ["HP", stats.maxHp],
      ["Mana", stats.maxMana],
      ["Damage", stats.damage],
      ["Armor", stats.armor],
      ["Speed", stats.speed],
      ["Might", stats.might],
      ["Command", stats.command],
      ["Arcana", stats.arcana],
      ["Faith", stats.faith]
    ];
    return `
      <div class="stat-list progression-stats">
        ${rows.map(([label, value]) => `<span>${label} <strong>${Math.round(value)}</strong></span>`).join("")}
      </div>
    `;
  }

  private renderEquipment(): string {
    return `
      <div class="equipment-list">
        ${EQUIPMENT_SLOTS.map((slot) => {
          const itemId = this.heroSave.equipment[slot];
          const item = itemId ? ITEM_BY_ID[itemId] : undefined;
          return `
            <div class="equipment-row ${item ? this.rarityClass(item.rarity) : ""}">
              <div>
                <strong>${titleCase(slot)}</strong>
                ${
                  item
                    ? `<span>${this.renderItemName(item)} - ${escapeHtml(this.formatStatMods(item.statMods))}</span>
                      <p>${escapeHtml(item.description)}</p>
                      <small>${escapeHtml(item.flavorText)}</small>`
                    : "<span>Empty</span>"
                }
              </div>
              <button data-progression-action="unequip" data-slot="${slot}" ${item ? "" : "disabled"}>Unequip</button>
            </div>
          `;
        }).join("")}
      </div>
    `;
  }

  private renderInventory(): string {
    const items = this.heroSave.inventory
      .map((itemId) => ITEM_BY_ID[itemId])
      .filter((item): item is ItemDefinition => item !== undefined);
    if (items.length === 0) {
      return `<p class="quiet">Win battles to earn equipment rewards.</p>`;
    }
    return `
      <div class="inventory-list">
        ${items
          .map((item) => {
            const equipped = this.heroSave.equipment[item.slot] === item.id;
            const rewarded = this.rewardItemIds.includes(item.id);
            const equipText = rewarded && !equipped ? "Equip Now" : equipped ? "Equipped" : "Equip";
            return `
              <div class="inventory-row ${rewarded ? "new" : ""} ${this.rarityClass(item.rarity)}">
                <div>
                  <strong>${this.renderItemName(item)} ${rewarded ? "<span>New</span>" : ""}</strong>
                  <small>${titleCase(item.slot)} - ${escapeHtml(this.formatStatMods(item.statMods))}</small>
                  <p>${escapeHtml(item.description)}</p>
                  <small>${escapeHtml(item.flavorText)}</small>
                  <small>${escapeHtml(this.formatTags(item.tags))}</small>
                  <small class="stat-preview">${escapeHtml(this.previewEquipDelta(item, equipped))}</small>
                </div>
                <button data-progression-action="equip" data-id="${item.id}" ${equipped ? "disabled" : ""}>${equipText}</button>
              </div>
            `;
          })
          .join("")}
      </div>
    `;
  }

  private renderSkillTree(treeId: string, name: string, description: string): string {
    const nodes = SKILL_NODES.filter((node) => node.treeId === treeId && (!node.classId || node.classId === this.heroSave.classId));
    return `
      <section class="skill-tree">
        <h3>${escapeHtml(name)}</h3>
        <p>${escapeHtml(description)}</p>
        ${nodes.map((node) => this.renderSkillNode(node)).join("")}
      </section>
    `;
  }

  private renderSkillNode(node: SkillNodeDefinition): string {
    const rank = this.heroSave.allocatedSkills[node.id] ?? 0;
    const check = canAllocateSkill(this.heroSave, node, SKILL_NODE_BY_ID);
    const mods = node.statModsPerRank ? this.formatStatMods(node.statModsPerRank) : "";
    return `
      <div class="skill-node">
        <div>
          <strong>${escapeHtml(node.name)} <span>${rank}/${node.maxRank}</span></strong>
          <small>${escapeHtml(node.description)}</small>
          ${mods ? `<small>${escapeHtml(mods)} per rank</small>` : ""}
          ${!check.ok && rank < node.maxRank ? `<small>${escapeHtml(check.message)}</small>` : ""}
        </div>
        <button data-progression-action="skill" data-id="${node.id}" ${check.ok ? "" : "disabled"}>Spend</button>
      </div>
    `;
  }

  private formatStatMods(mods: HeroStatMods): string {
    const formatted = Object.entries(mods)
      .map(([key, value]) => `${value && value > 0 ? "+" : ""}${value} ${statLabel(key)}`)
      .join(", ");
    return formatted || "No stat modifiers";
  }

  private previewEquipDelta(item: ItemDefinition, equipped: boolean): string {
    if (equipped) {
      return "Currently equipped.";
    }
    const result = equipItem(this.heroSave, item.id, ITEM_BY_ID);
    if (!result.ok) {
      return result.message;
    }
    const current = this.liveStatsFor(this.heroSave);
    const next = this.liveStatsFor(result.hero);
    const deltas = STAT_PREVIEW_KEYS.map((key) => [key, Math.round((next[key] - current[key]) * 100) / 100] as const)
      .filter(([, delta]) => delta !== 0)
      .map(([key, delta]) => `${delta > 0 ? "+" : ""}${delta} ${statLabel(key)}`);
    return deltas.length > 0 ? `Preview: ${deltas.join(", ")}` : "Preview: no stat change.";
  }

  private liveStatsFor(save: HeroSaveData): HeroBaseStats {
    const heroClass = HERO_CLASS_BY_ID[save.classId] ?? Object.values(HERO_CLASS_BY_ID)[0];
    const origin = ORIGIN_BY_ID[save.originId] ?? Object.values(ORIGIN_BY_ID)[0];
    return calculateLiveHeroStats(save, heroClass, origin, SKILL_NODE_BY_ID, ITEM_BY_ID);
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
      .map(([resource, amount]) => `${amount} ${titleCase(resource)}`);
    return rewards.length > 0 ? rewards.join(", ") : "None";
  }

  private formatTags(tags: string[]): string {
    return tags.length > 0 ? `Tags: ${tags.map(titleCase).join(", ")}` : "No tags";
  }

  private initialStatus(): string {
    if (this.heroSave.skillPoints > 0 && this.rewardItemIds.length > 0) {
      return "You received an item and have a skill point waiting. Equip the item, then spend the point before your next node.";
    }
    if (this.heroSave.skillPoints > 0) {
      return "You gained a skill point. Spend it in a skill tree to unlock abilities or improve stats.";
    }
    if (this.rewardItemIds.length > 0) {
      return "You received an item. Equip it to improve your hero before the next battle.";
    }
    return this.returnMode === "campaign"
      ? "Review your hero, then return to the campaign map."
      : "Spend skill points, equip rewards, or continue into another skirmish.";
  }

  private toCssColor(value: number): string {
    return `#${value.toString(16).padStart(6, "0")}`;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
  }
}

const STAT_PREVIEW_KEYS: Array<keyof HeroBaseStats> = [
  "maxHp",
  "maxMana",
  "damage",
  "armor",
  "range",
  "attackCooldown",
  "speed",
  "might",
  "command",
  "arcana",
  "faith"
];

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
