import { renderHud } from "./hudPanels/HudRoot";
import { clamp } from "./hudPanels/HudFormatting";
import { isBehaviourMode } from "../systems/BehaviourModeSystem";
import type { HUDCallbacks, HUDObjectiveSnapshot, HUDSnapshot } from "./hudPanels/HudTypes";

export type { HUDCallbacks, HUDObjectiveSnapshot, HUDSnapshot };

export class HUD {
  private readonly root: HTMLElement;
  private readonly clickHandler: (event: MouseEvent) => void;
  private readonly pointerOverHandler: (event: PointerEvent) => void;
  private readonly pointerOutHandler: (event: PointerEvent) => void;
  private lastMarkup = "";
  private deferredMarkup = "";
  private pointerInsideStablePanel = false;
  private forceNextUpdate = false;

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
        clearInteractionFocus(target);
        this.markInteractionHandled();
        return;
      }

      const button = target?.closest<HTMLButtonElement>("button[data-action]");
      if (!button) {
        return;
      }
      const action = button.dataset.action;
      const id = button.dataset.id ?? "";
      let handled = false;
      if (action === "build") {
        callbacks.onBuild(id, button.dataset.sourceId ?? "");
        handled = true;
      }
      if (action === "train") {
        callbacks.onTrain(id, button.dataset.sourceId ?? "");
        handled = true;
      }
      if (action === "cancel-train") {
        callbacks.onCancelTrain(button.dataset.sourceId ?? "", Number(button.dataset.index ?? 0));
        handled = true;
      }
      if (action === "upgrade") {
        callbacks.onUpgrade(id, button.dataset.sourceId ?? "");
        handled = true;
      }
      if (action === "cancel-upgrade") {
        callbacks.onCancelUpgrade(button.dataset.sourceId ?? "", Number(button.dataset.index ?? 0));
        handled = true;
      }
      if (action === "ability") {
        callbacks.onAbility(id);
        handled = true;
      }
      if (action === "behaviour-mode" && isBehaviourMode(id)) {
        callbacks.onBehaviourMode(id);
        handled = true;
      }
      if (action === "tutorial-next") {
        callbacks.onTutorialNext();
        handled = true;
      }
      if (action === "menu") {
        callbacks.onMenu();
        handled = true;
      }
      if (action === "resume") {
        callbacks.onResume();
        handled = true;
      }
      if (action === "exit-menu") {
        callbacks.onExitToMainMenu();
        handled = true;
      }
      if (handled) {
        clearInteractionFocus(button);
        this.markInteractionHandled();
      }
    };
    this.pointerOverHandler = (event) => {
      if (isStableInteractionTarget(event.target)) {
        this.pointerInsideStablePanel = true;
      }
    };
    this.pointerOutHandler = (event) => {
      if (!isStableInteractionTarget(event.target)) {
        return;
      }

      const relatedTarget = event.relatedTarget;
      if (relatedTarget instanceof Element && this.root.contains(relatedTarget) && isStableInteractionTarget(relatedTarget)) {
        return;
      }

      this.pointerInsideStablePanel = false;
      this.flushDeferredMarkup();
    };
    this.root.addEventListener("click", this.clickHandler);
    this.root.addEventListener("pointerover", this.pointerOverHandler);
    this.root.addEventListener("pointerout", this.pointerOutHandler);
  }

  update(snapshot: HUDSnapshot, options: { force?: boolean } = {}): void {
    const markup = renderHud(snapshot);

    if (markup !== this.lastMarkup) {
      const force = Boolean(options.force || this.forceNextUpdate);
      if (!force && this.shouldDeferUpdate()) {
        this.deferMarkup(markup);
        return;
      }
      this.forceNextUpdate = false;
      this.applyMarkup(markup);
    } else if (options.force) {
      this.forceNextUpdate = false;
    }
  }

  destroy(): void {
    this.root.removeEventListener("click", this.clickHandler);
    this.root.removeEventListener("pointerover", this.pointerOverHandler);
    this.root.removeEventListener("pointerout", this.pointerOutHandler);
    this.root.className = "ui-root";
    this.root.innerHTML = "";
    this.lastMarkup = "";
    this.deferredMarkup = "";
    this.pointerInsideStablePanel = false;
    this.forceNextUpdate = false;
  }

  private shouldDeferUpdate(): boolean {
    if (this.pointerInsideStablePanel) {
      return true;
    }

    const activeElement = document.activeElement;
    return activeElement instanceof Element && isStableInteractionTarget(activeElement);
  }

  private flushDeferredMarkup(): void {
    if (!this.deferredMarkup) {
      return;
    }

    const markup = this.deferredMarkup;
    this.deferredMarkup = "";
    this.applyMarkup(markup);
  }

  private deferMarkup(markup: string): void {
    this.deferredMarkup = markup;
  }

  private applyMarkup(markup: string): void {
    const scrollState = captureScrollState(this.root);
    this.root.className = "ui-root battle-ui";
    this.root.innerHTML = markup;
    this.lastMarkup = markup;
    restoreScrollState(this.root, scrollState);
  }

  private markInteractionHandled(): void {
    this.deferredMarkup = "";
    this.pointerInsideStablePanel = false;
    this.forceNextUpdate = true;
  }
}

const STABLE_INTERACTION_SELECTOR = ".top-bar, .side-panel, .objectives-panel, .tutorial-panel, .minimap-shell, .pause-menu-panel";
const SCROLLABLE_HUD_SELECTORS = [".side-panel", ".objectives-panel", ".tutorial-panel"] as const;

function isStableInteractionTarget(target: EventTarget | null): boolean {
  return target instanceof Element && Boolean(target.closest(STABLE_INTERACTION_SELECTOR));
}

function clearInteractionFocus(target: Element | null): void {
  const focusTarget = target?.closest<HTMLElement>("button, [role='button']");
  focusTarget?.blur();
}

function captureScrollState(root: HTMLElement): Map<string, number> {
  const scrollState = new Map<string, number>();
  SCROLLABLE_HUD_SELECTORS.forEach((selector) => {
    const element = root.querySelector<HTMLElement>(selector);
    if (element && element.scrollTop > 0) {
      scrollState.set(selector, element.scrollTop);
    }
  });
  return scrollState;
}

function restoreScrollState(root: HTMLElement, scrollState: Map<string, number>): void {
  scrollState.forEach((scrollTop, selector) => {
    const element = root.querySelector<HTMLElement>(selector);
    if (element) {
      element.scrollTop = scrollTop;
    }
  });
}
