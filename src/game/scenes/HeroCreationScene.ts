import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { createNewHeroSave } from "../data/heroes";
import { HERO_CLASSES } from "../data/heroClasses";
import { ORIGINS } from "../data/origins";
import { ABILITY_BY_ID } from "../data/contentIndex";
import { stopKeyboardEventForEditableTarget } from "../systems/KeyboardFocusGuard";

interface HeroCreationData {
  nextMode?: "campaign" | "skirmish";
}

export class HeroCreationScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
  private keyboardHandler?: (event: KeyboardEvent) => void;
  private selectedClassId = HERO_CLASSES[0].id;
  private selectedOriginId = ORIGINS[0].id;
  private heroName = "Aster";
  private nextMode: "campaign" | "skirmish" = "skirmish";

  constructor() {
    super(SCENE_KEYS.heroCreation);
  }

  init(data: HeroCreationData): void {
    this.nextMode = data.nextMode ?? "skirmish";
  }

  create(): void {
    this.root = document.getElementById("ui-root") ?? undefined;
    if (!this.root) {
      throw new Error("Missing #ui-root");
    }

    this.handler = (event) => {
      const target = event.target as HTMLElement;
      const option = target.closest<HTMLButtonElement>("button[data-option-kind]");
      if (option) {
        this.heroName = this.root?.querySelector<HTMLInputElement>("#hero-name")?.value ?? this.heroName;
        if (option.dataset.optionKind === "class") {
          this.selectedClassId = option.dataset.id ?? this.selectedClassId;
        }
        if (option.dataset.optionKind === "origin") {
          this.selectedOriginId = option.dataset.id ?? this.selectedOriginId;
        }
        this.render();
        return;
      }

      const action = target.closest<HTMLButtonElement>("button[data-hero-action]")?.dataset.heroAction;
      if (action === "back") {
        this.scene.start(SCENE_KEYS.mainMenu);
      }
      if (action === "start") {
        const input = this.root?.querySelector<HTMLInputElement>("#hero-name");
        this.heroName = input?.value ?? this.heroName;
        const save = createNewHeroSave(this.heroName, this.selectedClassId, this.selectedOriginId);
        if (this.nextMode === "campaign") {
          const campaign = createStartedCampaignSave();
          SaveSystem.saveGame(save, campaign);
          this.scene.start(SCENE_KEYS.campaignMap, { heroSave: save, campaignSave: campaign });
          return;
        }
        SaveSystem.saveHero(save);
        this.scene.start(SCENE_KEYS.skirmishSetup, { heroSave: save });
      }
    };

    this.root.addEventListener("click", this.handler);
    this.keyboardHandler = (event) => stopKeyboardEventForEditableTarget(event);
    this.root.addEventListener("keydown", this.keyboardHandler, true);
    this.root.addEventListener("keyup", this.keyboardHandler, true);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private render(): void {
    if (!this.root) {
      return;
    }
    const selectedClass = HERO_CLASSES.find((entry) => entry.id === this.selectedClassId) ?? HERO_CLASSES[0];
    const selectedOrigin = ORIGINS.find((entry) => entry.id === this.selectedOriginId) ?? ORIGINS[0];
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell creation asset-screen-bg" data-testid="hero-creation" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel creation-panel">
          <div class="creation-header">
            <div>
              <p class="eyebrow">${this.nextMode === "campaign" ? "New Campaign" : "Hero Creation"}</p>
              <h1>Choose Your Ascendant</h1>
            </div>
            <div class="creation-selected-strip" aria-label="Selected hero build">
              <span>${escapeHtml(selectedClass.name)}</span>
              <span>${escapeHtml(selectedOrigin.name)}</span>
            </div>
          </div>
          <div class="creation-flow">
            <section class="creation-stage creation-class-stage" data-testid="hero-creation-step-class">
              <div class="creation-stage-heading">
                <p class="eyebrow">Step 1</p>
                <h2>Choose Class</h2>
              </div>
              <div class="creation-option-grid class-options">
                ${HERO_CLASSES.map((heroClass) => this.renderClassOption(heroClass)).join("")}
              </div>
            </section>
            <section class="creation-stage creation-origin-stage" data-testid="hero-creation-step-origin">
              <div class="creation-stage-heading">
                <p class="eyebrow">Step 2</p>
                <h2>Choose Origin</h2>
              </div>
              <div class="creation-option-grid origin-options">
                ${ORIGINS.map((origin) => this.renderOriginOption(origin)).join("")}
              </div>
            </section>
            <section class="creation-stage creation-review-stage" data-testid="hero-creation-step-review">
              <div class="creation-stage-heading">
                <p class="eyebrow">Step 3</p>
                <h2>Review Hero</h2>
              </div>
              <label class="field-label" for="hero-name">Hero Name</label>
              <input id="hero-name" data-testid="hero-name-input" value="${escapeHtml(this.heroName)}" maxlength="24" />
              <div class="creation-review-card">
                <strong>${escapeHtml(selectedClass.name)} from ${escapeHtml(selectedOrigin.name)}</strong>
                <p>${
                  this.nextMode === "campaign"
                    ? "Begin at Salto Outskirts with this persistent hero. Rules, saves, rewards, and class IDs are unchanged."
                    : "Continue to skirmish setup with this persistent hero profile."
                }</p>
                <div class="tag-row">
                  ${classTraitList(selectedClass)
                    .slice(0, 3)
                    .map((trait) => `<span class="tag">${escapeHtml(trait)}</span>`)
                    .join("")}
                </div>
                <small>${escapeHtml(originMechanicsSummary(selectedOrigin))}</small>
              </div>
              <div class="menu-actions row creation-actions">
                <button class="menu-primary-button" data-testid="hero-start" data-hero-action="start">${
                  this.nextMode === "campaign" ? "Begin Campaign" : "Continue To Setup"
                }</button>
                <button data-testid="hero-back" data-hero-action="back">Back</button>
              </div>
            </section>
          </div>
        </section>
      </main>
    `;
  }

  private renderClassOption(heroClass: (typeof HERO_CLASSES)[number]): string {
    const portraitId = heroPortraitAssetId(heroClass.id);
    const hasPortrait = AssetLoader.hasAsset(portraitId);
    const selected = heroClass.id === this.selectedClassId;
    return `
      <article class="creation-option-card ${selected ? "selected" : ""}">
        <button
          class="choice creation-choice ${selected ? "selected" : ""}"
          data-testid="hero-class-${heroClass.id}"
          data-option-kind="class"
          data-id="${heroClass.id}"
          aria-pressed="${selected ? "true" : "false"}"
        >
          <span class="choice-content">
            <span class="choice-portrait ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, this.toCssColor(heroClass.color))}></span>
            <span class="choice-copy">
              <strong>${escapeHtml(heroClass.name)}</strong>
              <span>${escapeHtml(heroClass.description)}</span>
            </span>
          </span>
        </button>
        <div class="creation-trait-grid" aria-label="${escapeHtml(heroClass.name)} traits">
          ${classTraitList(heroClass)
            .map((trait) => `<span>${escapeHtml(trait)}</span>`)
            .join("")}
        </div>
        <small class="creation-drawback">${escapeHtml(classDrawback(heroClass.id))}</small>
        <small data-testid="hero-class-${heroClass.id}-mechanics">${escapeHtml(classMechanicsSummary(heroClass))}</small>
        <details class="creation-more">
          <summary>More Details</summary>
          <p>${escapeHtml(classMechanicsDetail(heroClass))}</p>
        </details>
      </article>
    `;
  }

  private renderOriginOption(origin: (typeof ORIGINS)[number]): string {
    const selected = origin.id === this.selectedOriginId;
    return `
      <article class="creation-option-card ${selected ? "selected" : ""}">
        <button
          class="choice creation-choice ${selected ? "selected" : ""}"
          data-testid="hero-origin-${origin.id}"
          data-option-kind="origin"
          data-id="${origin.id}"
          aria-pressed="${selected ? "true" : "false"}"
        >
          <strong>${escapeHtml(origin.name)}</strong>
          <span>${escapeHtml(origin.description)}</span>
        </button>
        <div class="creation-trait-grid origin-traits" aria-label="${escapeHtml(origin.name)} traits">
          ${originTraitList(origin)
            .map((trait) => `<span>${escapeHtml(trait)}</span>`)
            .join("")}
        </div>
        <small class="creation-drawback">${escapeHtml(originDrawback(origin.id))}</small>
        <small data-testid="hero-origin-${origin.id}-mechanics">${escapeHtml(originMechanicsSummary(origin))}</small>
        <details class="creation-more">
          <summary>More Details</summary>
          <p>${escapeHtml(origin.description)} ${escapeHtml(originMechanicsSummary(origin))}</p>
        </details>
      </article>
    `;
  }

  private toCssColor(value: number): string {
    return `#${value.toString(16).padStart(6, "0")}`;
  }

  private cleanup(): void {
    if (this.root && this.handler) {
      this.root.removeEventListener("click", this.handler);
    }
    if (this.root && this.keyboardHandler) {
      this.root.removeEventListener("keydown", this.keyboardHandler, true);
      this.root.removeEventListener("keyup", this.keyboardHandler, true);
    }
  }
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function classMechanicsSummary(heroClass: (typeof HERO_CLASSES)[number]): string {
  const stats = heroClass.baseStats;
  const primary = ABILITY_BY_ID[heroClass.primaryAbilityId];
  const abilityText = primary ? primary.name : "Primary ability not available.";
  return [
    `HP ${stats.maxHp}`,
    `Mana ${stats.maxMana}`,
    `Damage ${stats.damage}`,
    `Armor ${stats.armor}`,
    `Range ${stats.range}`,
    abilityText,
    classTradeoffSummary(heroClass.id)
  ].join("; ");
}

function classMechanicsDetail(heroClass: (typeof HERO_CLASSES)[number]): string {
  const stats = heroClass.baseStats;
  const primary = ABILITY_BY_ID[heroClass.primaryAbilityId];
  const abilityText = primary ? `${primary.name}: ${primary.description}` : "Primary ability not available.";
  return [
    `Stats: HP ${stats.maxHp}, Mana ${stats.maxMana}, Damage ${stats.damage}, Armor ${stats.armor}, Range ${stats.range}.`,
    `Attributes: Might ${stats.might}, Command ${stats.command}, Arcana ${stats.arcana}, Faith ${stats.faith}.`,
    `Primary ability: ${abilityText}`,
    classTradeoffSummary(heroClass.id)
  ].join(" ");
}

function classTraitList(heroClass: (typeof HERO_CLASSES)[number]): string[] {
  const primary = ABILITY_BY_ID[heroClass.primaryAbilityId];
  if (heroClass.id === "warlord") {
    return [`Frontline HP ${heroClass.baseStats.maxHp}`, `Command ${heroClass.baseStats.command}`, primary?.name ?? "Rally Banner"];
  }
  if (heroClass.id === "arcanist") {
    return [`Mana ${heroClass.baseStats.maxMana}`, `Range ${heroClass.baseStats.range}`, primary?.name ?? "Firebolt"];
  }
  if (heroClass.id === "shepherd") {
    return [`Faith ${heroClass.baseStats.faith}`, `Support range ${heroClass.baseStats.range}`, primary?.name ?? "Heal"];
  }
  return [`HP ${heroClass.baseStats.maxHp}`, `Damage ${heroClass.baseStats.damage}`, primary?.name ?? "Primary ability"];
}

function classDrawback(classId: string): string {
  if (classId === "warlord") {
    return "Drawback: shortest range and less Mana than caster/support classes.";
  }
  if (classId === "arcanist") {
    return "Drawback: lowest HP and armor; needs careful positioning.";
  }
  if (classId === "shepherd") {
    return "Drawback: lower damage and armor than the Warlord.";
  }
  return "Drawback: compare stats before choosing.";
}

function classTradeoffSummary(classId: string): string {
  if (classId === "warlord") {
    return "Strength: toughest front-line commander. Tradeoff: shortest range and less mana than caster/support classes.";
  }
  if (classId === "arcanist") {
    return "Strength: long range and highest mana. Tradeoff: lowest HP and armor.";
  }
  if (classId === "shepherd") {
    return "Strength: healing and support range. Tradeoff: lower damage and armor than the Warlord.";
  }
  return "Compare stats and primary ability before choosing.";
}

function originMechanicsSummary(origin: (typeof ORIGINS)[number]): string {
  const bonuses = Object.entries(origin.statMods).map(([stat, value]) => `${formatSigned(value)} ${statLabel(stat)}`);
  return bonuses.length > 0 ? `Mechanical bonus: ${bonuses.join(", ")}.` : "Mechanical bonus: none.";
}

function originTraitList(origin: (typeof ORIGINS)[number]): string[] {
  const bonuses = Object.entries(origin.statMods).map(([stat, value]) => `${formatSigned(value)} ${statLabel(stat)}`);
  if (origin.id === "exiled_noble") {
    return ["Command background", "Tougher start", bonuses.join(" / ")];
  }
  if (origin.id === "temple_orphan") {
    return ["Faith training", "More Mana", bonuses.join(" / ")];
  }
  if (origin.id === "wildland_raider") {
    return ["Fast pressure", "More damage", bonuses.join(" / ")];
  }
  return bonuses.length > 0 ? bonuses.slice(0, 3) : ["No bonus", "Neutral start", "Flexible"];
}

function originDrawback(originId: string): string {
  if (originId === "exiled_noble") {
    return "Drawback: no direct damage or Mana boost.";
  }
  if (originId === "temple_orphan") {
    return "Drawback: no direct armor or speed boost.";
  }
  if (originId === "wildland_raider") {
    return "Drawback: no Faith, Command, or Mana support.";
  }
  return "Drawback: none defined.";
}

function statLabel(stat: string): string {
  return (
    {
      maxHp: "HP",
      maxMana: "Mana",
      damage: "Damage",
      armor: "Armor",
      speed: "Speed",
      range: "Range",
      might: "Might",
      command: "Command",
      arcana: "Arcana",
      faith: "Faith"
    }[stat] ?? stat
  );
}

function formatSigned(value: number): string {
  return value > 0 ? `+${value}` : `${value}`;
}
