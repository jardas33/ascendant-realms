import type { AbilityDefinition } from "../../core/GameTypes";
import { ABILITY_BY_ID } from "../../data/contentIndex";
import { Hero } from "../../entities/Hero";
import { selectionTitle } from "../SelectionPanel";
import { renderStatusLine, renderHintLine } from "./AlertPanel";
import { renderCommandActions } from "./CommandPanel";
import { renderHeroHudPanel, renderAbilities } from "./HeroHudPanel";
import { escapeHtml } from "./HudFormatting";
import type { HUDSnapshot } from "./HudTypes";
import { renderMinimapPanel } from "./MinimapPanel";
import { renderObjectives } from "./ObjectivePanel";
import { renderPlacementBanner } from "./PlacementPanel";
import { renderResources } from "./ResourceBar";
import { renderSelectionSummary } from "./SelectedEntityPanel";

export function renderHud(snapshot: HUDSnapshot): string {
  const selected = snapshot.selected.filter((entity) => entity.alive);
  const selectedOne = selected.length === 1 ? selected[0] : undefined;
  const abilities = snapshot.hero.unlockedAbilities
    .map((abilityId) => ABILITY_BY_ID[abilityId])
    .filter((ability): ability is AbilityDefinition => ability !== undefined)
    .slice(0, 3);
  const sidePanelClass = selectedOne instanceof Hero ? "side-panel hero-selected" : "side-panel";

  return `
    <div class="top-bar" data-testid="battle-hud">
      <div class="resource-row" data-testid="battle-resources">${renderResources(snapshot.resources)}</div>
      <button class="hud-button compact" data-action="menu">Menu</button>
    </div>
    ${renderHeroHudPanel(snapshot.hero)}
    <div class="${sidePanelClass}">
      <div class="panel-title">${escapeHtml(selectionTitle(selected))}</div>
      <div class="command-tray">${renderCommandActions(selectedOne, snapshot)}${renderAbilities(abilities, snapshot.hero)}</div>
      <div class="selection-summary">${renderSelectionSummary(selectedOne, selected)}</div>
    </div>
    ${renderMinimapPanel(snapshot.minimap)}
    ${renderObjectives(snapshot.objectives)}
    ${renderPlacementBanner(snapshot.isPlacing)}
    ${renderStatusLine(snapshot.status, snapshot.isPlacing)}
    ${renderHintLine(snapshot.hint)}
  `;
}
