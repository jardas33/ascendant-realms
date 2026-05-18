import { abilityIconAssetId, heroPortraitAssetId } from "../../assets/AssetKeys";
import { AssetLoader } from "../../assets/AssetLoader";
import type { AbilityDefinition } from "../../core/GameTypes";
import type { Hero } from "../../entities/Hero";
import { abilityLabel } from "../AbilityBar";
import { healthPercent } from "../HealthBar";
import { escapeHtml, heroXpPercent, toCssColor } from "./HudFormatting";

export function renderHeroHudPanel(hero: Hero): string {
  const portraitId = heroPortraitAssetId(hero.classId);
  const hasPortrait = AssetLoader.hasAsset(portraitId);
  return `
    <div class="hero-panel" data-testid="battle-hero-panel">
      <div class="portrait ${hasPortrait ? "has-asset" : ""}" ${AssetLoader.portraitStyle(portraitId, toCssColor(hero.definition.color))}></div>
      <div class="hero-lines">
        <strong>${escapeHtml(hero.heroName)} L${hero.level}</strong>
        <span>HP ${Math.ceil(hero.hp)}/${hero.maxHp} - Mana ${Math.floor(hero.mana)}/${hero.maxMana}</span>
        <div class="meter"><span style="width:${healthPercent({ current: hero.hp, max: hero.maxHp })}%"></span></div>
        <div class="xp-meter"><span style="width:${heroXpPercent(hero)}%"></span></div>
        <small>XP ${hero.xp} - Skill ${hero.skillPoints}</small>
      </div>
    </div>
  `;
}

export function renderAbilities(abilities: AbilityDefinition[], hero: Hero): string {
  if (abilities.length === 0) {
    return "";
  }
  return `
    <div class="action-group ability-group">
      <strong>Hero</strong>
      ${abilities
        .map((ability) => {
          const cooldownRemaining = hero.abilityCooldowns[ability.id] ?? 0;
          const label = abilityLabel(ability, cooldownRemaining);
          const description = `${ability.description} Cost: ${ability.manaCost} Mana.`;
          return `
            <button class="hud-button ability" data-action="ability" data-id="${ability.id}" title="${escapeHtml(
              `${ability.name}: ${description}`
            )}" aria-label="${escapeHtml(`${label}. ${description}`)}">
              <span class="ability-button-content">
                ${AssetLoader.imageHtml(abilityIconAssetId(ability.id), `${ability.name} icon`, "ability-icon")}
                <span>${escapeHtml(label)}</span>
              </span>
              <small>${escapeHtml(description)}</small>
            </button>
          `;
        })
        .join("")}
    </div>
  `;
}
