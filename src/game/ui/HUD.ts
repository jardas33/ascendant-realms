import { renderHud } from "./hudPanels/HudRoot";
import { clamp } from "./hudPanels/HudFormatting";
import type { HUDCallbacks, HUDObjectiveSnapshot, HUDSnapshot } from "./hudPanels/HudTypes";

export type { HUDCallbacks, HUDObjectiveSnapshot, HUDSnapshot };

export class HUD {
  private readonly root: HTMLElement;
  private readonly clickHandler: (event: MouseEvent) => void;
  private lastMarkup = "";

  constructor(callbacks: HUDCallbacks) {
    const root = document.getElementById("ui-root");
    if (!root) {
      throw new Error("Missing #ui-root element");
    }
    this.root = root;
    this.clickHandler = (event) => {
      const target = event.target as Element | null;
      const minimap = target?.closest<HTMLElement>("[data-minimap]");
      if (minimap) {
        const bounds = minimap.getBoundingClientRect();
        if (bounds.width > 0 && bounds.height > 0) {
          callbacks.onMinimapMove(
            clamp((event.clientX - bounds.left) / bounds.width, 0, 1),
            clamp((event.clientY - bounds.top) / bounds.height, 0, 1)
          );
        }
        return;
      }

      const button = target?.closest<HTMLButtonElement>("button[data-action]");
      if (!button) {
        return;
      }
      const action = button.dataset.action;
      const id = button.dataset.id ?? "";
      if (action === "build") {
        callbacks.onBuild(id, button.dataset.sourceId ?? "");
      }
      if (action === "train") {
        callbacks.onTrain(id, button.dataset.sourceId ?? "");
      }
      if (action === "cancel-train") {
        callbacks.onCancelTrain(button.dataset.sourceId ?? "", Number(button.dataset.index ?? 0));
      }
      if (action === "upgrade") {
        callbacks.onUpgrade(id, button.dataset.sourceId ?? "");
      }
      if (action === "cancel-upgrade") {
        callbacks.onCancelUpgrade(button.dataset.sourceId ?? "", Number(button.dataset.index ?? 0));
      }
      if (action === "ability") {
        callbacks.onAbility(id);
      }
      if (action === "menu") {
        callbacks.onMenu();
      }
    };
    this.root.addEventListener("click", this.clickHandler);
  }

  update(snapshot: HUDSnapshot): void {
    const markup = renderHud(snapshot);

    if (markup !== this.lastMarkup) {
      this.root.className = "ui-root battle-ui";
      this.root.innerHTML = markup;
      this.lastMarkup = markup;
    }
  }

  destroy(): void {
    this.root.removeEventListener("click", this.clickHandler);
    this.root.className = "ui-root";
    this.root.innerHTML = "";
    this.lastMarkup = "";
  }
}
