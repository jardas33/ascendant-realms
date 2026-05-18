import type { HUDPauseMenuSnapshot } from "./HudTypes";
import { escapeHtml } from "./HudFormatting";

export function renderPauseMenu(menu: HUDPauseMenuSnapshot | undefined): string {
  if (!menu?.visible) {
    return "";
  }
  return `
    <section class="pause-menu-panel" data-testid="battle-pause-menu" aria-label="Battle menu" aria-live="polite">
      <strong>${escapeHtml(menu.title)}</strong>
      <p>${escapeHtml(menu.description)}</p>
      <div class="pause-menu-actions">
        <button class="hud-button compact" data-testid="battle-resume" data-action="resume">Resume</button>
        <button class="hud-button compact" data-testid="battle-exit-menu" data-action="exit-menu">Exit to Main Menu</button>
      </div>
    </section>
  `;
}
