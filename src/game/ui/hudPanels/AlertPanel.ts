import { escapeHtml } from "./HudFormatting";
import type { BattleStatusCategory } from "../../battle/BattleStatusPriority";

export function renderStatusLine(status: string, isPlacing: boolean, category: BattleStatusCategory = "routine"): string {
  return `<div class="status-line ${isPlacing ? "active" : ""} status-${category}" data-status-priority="${category}" data-testid="battle-status">${escapeHtml(status)}</div>`;
}

export function renderHintLine(hint: string | undefined): string {
  return hint ? `<div class="hint-line">${escapeHtml(hint)}</div>` : "";
}
