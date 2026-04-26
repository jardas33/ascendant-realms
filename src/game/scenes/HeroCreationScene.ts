import Phaser from "phaser";
import { ASSET_IDS, heroPortraitAssetId } from "../assets/AssetKeys";
import { AssetLoader } from "../assets/AssetLoader";
import { createStartedCampaignSave } from "../core/CampaignRules";
import { SaveSystem } from "../core/SaveSystem";
import { SCENE_KEYS } from "../core/SceneKeys";
import { createNewHeroSave } from "../data/heroes";
import { HERO_CLASSES } from "../data/heroClasses";
import { ORIGINS } from "../data/origins";

interface HeroCreationData {
  nextMode?: "campaign" | "skirmish";
}

export class HeroCreationScene extends Phaser.Scene {
  private root?: HTMLElement;
  private handler?: (event: MouseEvent) => void;
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
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, this.cleanup, this);
    this.render();
  }

  private render(): void {
    if (!this.root) {
      return;
    }
    this.root.className = "ui-root menu-ui";
    this.root.innerHTML = `
      <main class="menu-shell creation asset-screen-bg" ${AssetLoader.screenStyle({ backgroundAssetId: ASSET_IDS.ui.mainMenuBackground })}>
        <section class="menu-panel wide">
          <p class="eyebrow">${this.nextMode === "campaign" ? "New Campaign" : "Hero Creation"}</p>
          <h1>Choose Your Ascendant</h1>
          <div class="guidance-card compact">
            <strong>${this.nextMode === "campaign" ? "Campaign Begins At Border Village" : "Build A Persistent Hero"}</strong>
            <p>${
              this.nextMode === "campaign"
                ? "Choose a hero style you like. The first battle teaches the RTS loop, then rewards feed into inventory and skill progression."
                : "Your hero keeps XP, items, equipment, and skill choices between battles."
            }</p>
          </div>
          <label class="field-label" for="hero-name">Hero Name</label>
          <input id="hero-name" value="${escapeHtml(this.heroName)}" maxlength="24" />
          <div class="choice-columns">
            <div>
              <h2>Class</h2>
              ${HERO_CLASSES.map(
                (heroClass) => {
                  const portraitId = heroPortraitAssetId(heroClass.id);
                  const hasPortrait = AssetLoader.hasAsset(portraitId);
                  return `
                  <button class="choice ${heroClass.id === this.selectedClassId ? "selected" : ""}" data-option-kind="class" data-id="${heroClass.id}">
                    <span class="choice-content">
                      <span class="choice-portrait ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, this.toCssColor(heroClass.color))}></span>
                      <span class="choice-copy">
                        <strong>${heroClass.name}</strong>
                        <span>${heroClass.description}</span>
                      </span>
                    </span>
                  </button>
                `;
                }
              ).join("")}
            </div>
            <div>
              <h2>Origin</h2>
              ${ORIGINS.map(
                (origin) => `
                  <button class="choice ${origin.id === this.selectedOriginId ? "selected" : ""}" data-option-kind="origin" data-id="${origin.id}">
                    <strong>${origin.name}</strong>
                    <span>${origin.description}</span>
                  </button>
                `
              ).join("")}
            </div>
          </div>
          <div class="menu-actions row">
            <button data-hero-action="start">${this.nextMode === "campaign" ? "Begin Campaign" : "Continue To Setup"}</button>
            <button data-hero-action="back">Back</button>
          </div>
        </section>
      </main>
    `;
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

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
