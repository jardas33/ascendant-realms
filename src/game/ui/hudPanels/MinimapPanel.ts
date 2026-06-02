import { renderMinimap } from "../MinimapView";
import type { MinimapSnapshot } from "../MinimapView";

export function renderMinimapPanel(minimap: MinimapSnapshot): string {
  return `
    <div class="minimap-shell" data-testid="battle-minimap" data-hud-volatile="minimap">
      ${renderMinimap(minimap)}
    </div>
  `;
}
