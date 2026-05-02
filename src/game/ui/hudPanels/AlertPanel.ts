import { escapeHtml } from "./HudFormatting";

export function renderStatusLine(status: string, isPlacing: boolean): string {
  return `<div class="status-line ${isPlacing ? "active" : ""}" data-testid="battle-status">${escapeHtml(status)}</div>`;
}

export function renderHintLine(hint: string | undefined): string {
  return hint ? `<div class="hint-line">${escapeHtml(hint)}</div>` : "";
}
