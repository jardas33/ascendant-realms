import { renderHud } from "./hudPanels/HudRoot";
import { clamp } from "./hudPanels/HudFormatting";
import { isHudDensityMode } from "./hudPanels/HudDensity";
import { isBehaviourMode } from "../systems/BehaviourModeSystem";
import type { HUDCallbacks, HUDObjectiveSnapshot, HUDSnapshot } from "./hudPanels/HudTypes";
import type { RenderLifecycleMetricsRecorder } from "../systems/RenderLifecycleMetrics";

export type { HUDCallbacks, HUDObjectiveSnapshot, HUDSnapshot };

interface TutorialPanelOffset {
  x: number;
  y: number;
}

interface TutorialPanelDragState {
  pointerId: number;
  startClientX: number;
  startClientY: number;
  startOffset: TutorialPanelOffset;
}

const STABLE_PANEL_DEFER_LIMIT_MS = 350;

interface HUDOptions {
  recordRenderLifecycleMetrics?: RenderLifecycleMetricsRecorder;
}

export class HUD {
  private readonly root: HTMLElement;
  private readonly recordRenderLifecycleMetrics?: RenderLifecycleMetricsRecorder;
  private readonly clickHandler: (event: MouseEvent) => void;
  private readonly pointerDownHandler: (event: PointerEvent) => void;
  private readonly pointerMoveHandler: (event: PointerEvent) => void;
  private readonly pointerUpHandler: (event: PointerEvent) => void;
  private readonly pointerOverHandler: (event: PointerEvent) => void;
  private readonly pointerOutHandler: (event: PointerEvent) => void;
  private lastMarkup = "";
  private lastStableMarkup = "";
  private deferredMarkup = "";
  private deferredMarkupAtMs = 0;
  private pointerInsideStablePanel = false;
  private forceNextUpdate = false;
  private tutorialPanelOffset: TutorialPanelOffset = { x: 0, y: 0 };
  private tutorialPanelMinimized = false;
  private sidePanelMinimized = false;
  private tutorialPanelDrag?: TutorialPanelDragState;

  constructor(callbacks: HUDCallbacks, options: HUDOptions = {}) {
    const root = document.getElementById("ui-root");
    if (!root) {
      throw new Error("Missing #ui-root element");
    }
    this.root = root;
    this.recordRenderLifecycleMetrics = options.recordRenderLifecycleMetrics;
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
      let localPanelOnly = false;
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
      if (action === "repair") {
        callbacks.onRepair(id, button.dataset.sourceId ?? "");
        handled = true;
      }
      if (action === "assign-resource-site") {
        callbacks.onAssignResourceSite(id, button.dataset.sourceId ?? "");
        handled = true;
      }
      if (action === "upgrade-resource-site") {
        callbacks.onUpgradeResourceSite(id);
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
      if (action === "stop") {
        callbacks.onStopCommand();
        handled = true;
      }
      if (action === "patrol") {
        callbacks.onPatrolCommand();
        handled = true;
      }
      if (action === "retinue-reinforcement") {
        callbacks.onRetinueReinforcement();
        handled = true;
      }
      if (action === "lume-focus") {
        callbacks.onLumeFocus(id);
        handled = true;
      }
      if (action === "lume-visibility" && (id === "auto" || id === "always" || id === "hidden")) {
        callbacks.onLumeVisibilityMode(id);
        handled = true;
      }
      if (action === "hud-density" && isHudDensityMode(id)) {
        callbacks.onHudDensityMode(id);
        handled = true;
      }
      if (action === "private-demo-exit") {
        callbacks.onPrivateDemoExit();
        handled = true;
      }
      if (action === "private-demo-finish") {
        callbacks.onPrivateDemoFinish();
        handled = true;
      }
      if (action === "tutorial-next") {
        callbacks.onTutorialNext();
        handled = true;
      }
      if (action === "tutorial-dismiss") {
        callbacks.onTutorialDismiss();
        handled = true;
      }
      if (action === "tutorial-reopen") {
        callbacks.onTutorialReopen();
        handled = true;
      }
      if (action === "tutorial-focus") {
        callbacks.onTutorialFocus();
        handled = true;
      }
      if (action === "tutorial-minimize") {
        this.tutorialPanelMinimized = !this.tutorialPanelMinimized;
        this.applyTutorialPanelState();
        handled = true;
        localPanelOnly = true;
      }
      if (action === "tutorial-reset") {
        this.resetTutorialPanelState();
        handled = true;
        localPanelOnly = true;
      }
      if (action === "side-panel-minimize") {
        this.sidePanelMinimized = !this.sidePanelMinimized;
        this.applySidePanelState();
        handled = true;
        localPanelOnly = true;
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
        if (localPanelOnly) {
          this.pointerInsideStablePanel = false;
        } else {
          this.markInteractionHandled();
        }
      }
    };
    this.pointerDownHandler = (event) => {
      const target = event.target as Element | null;
      const panel = target?.closest<HTMLElement>("[data-testid='tutorial-overlay']");
      if (!panel || !this.root.contains(panel)) {
        return;
      }
      if (target?.closest(TUTORIAL_PANEL_NON_DRAG_SELECTOR)) {
        return;
      }

      event.preventDefault();
      event.stopPropagation();
      this.pointerInsideStablePanel = true;
      this.tutorialPanelDrag = {
        pointerId: event.pointerId,
        startClientX: event.clientX,
        startClientY: event.clientY,
        startOffset: { ...this.tutorialPanelOffset }
      };
      panel.setPointerCapture?.(event.pointerId);
    };
    this.pointerMoveHandler = (event) => {
      if (!this.tutorialPanelDrag || event.pointerId !== this.tutorialPanelDrag.pointerId) {
        return;
      }
      const nextOffset = {
        x: this.tutorialPanelDrag.startOffset.x + event.clientX - this.tutorialPanelDrag.startClientX,
        y: this.tutorialPanelDrag.startOffset.y + event.clientY - this.tutorialPanelDrag.startClientY
      };
      this.tutorialPanelOffset = this.clampTutorialPanelOffset(nextOffset);
      this.applyTutorialPanelState();
      event.preventDefault();
      event.stopPropagation();
    };
    this.pointerUpHandler = (event) => {
      if (!this.tutorialPanelDrag || event.pointerId !== this.tutorialPanelDrag.pointerId) {
        return;
      }
      this.tutorialPanelDrag = undefined;
      this.pointerInsideStablePanel = false;
      event.preventDefault();
      event.stopPropagation();
      this.flushDeferredMarkup();
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
    this.root.addEventListener("pointerdown", this.pointerDownHandler);
    window.addEventListener("pointermove", this.pointerMoveHandler);
    window.addEventListener("pointerup", this.pointerUpHandler);
    window.addEventListener("pointercancel", this.pointerUpHandler);
    this.root.addEventListener("pointerover", this.pointerOverHandler);
    this.root.addEventListener("pointerout", this.pointerOutHandler);
  }

  update(snapshot: HUDSnapshot, options: { force?: boolean } = {}): void {
    const markup = renderHud(snapshot);

    if (markup !== this.lastMarkup) {
      const force = Boolean(options.force || this.forceNextUpdate);
      const stableMarkup = createStableMarkupSignature(markup);
      if (!force && stableMarkup === this.lastStableMarkup && this.patchVolatileRegions(markup, stableMarkup)) {
        return;
      }
      if (!force && this.shouldDeferUpdate()) {
        if (this.shouldFlushDeferredMarkupNow()) {
          this.deferredMarkup = "";
          this.deferredMarkupAtMs = 0;
        } else {
          this.deferMarkup(markup);
          return;
        }
      }
      this.forceNextUpdate = false;
      this.applyMarkup(markup);
    } else if (options.force) {
      this.forceNextUpdate = false;
    }
  }

  destroy(): void {
    const destroyedNodes = countElementTreeNodes(this.root);
    this.root.removeEventListener("click", this.clickHandler);
    this.root.removeEventListener("pointerdown", this.pointerDownHandler);
    window.removeEventListener("pointermove", this.pointerMoveHandler);
    window.removeEventListener("pointerup", this.pointerUpHandler);
    window.removeEventListener("pointercancel", this.pointerUpHandler);
    this.root.removeEventListener("pointerover", this.pointerOverHandler);
    this.root.removeEventListener("pointerout", this.pointerOutHandler);
    this.root.className = "ui-root";
    this.root.innerHTML = "";
    if (destroyedNodes > 1) {
      this.recordRenderLifecycleMetrics?.({ domNodesDestroyed: destroyedNodes - 1, domPatches: 1 });
    }
    this.lastMarkup = "";
    this.lastStableMarkup = "";
    this.deferredMarkup = "";
    this.deferredMarkupAtMs = 0;
    this.pointerInsideStablePanel = false;
    this.forceNextUpdate = false;
    this.tutorialPanelDrag = undefined;
    this.tutorialPanelOffset = { x: 0, y: 0 };
    this.tutorialPanelMinimized = false;
    this.sidePanelMinimized = false;
  }

  private shouldDeferUpdate(): boolean {
    if (this.tutorialPanelDrag) {
      return true;
    }

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
    this.deferredMarkupAtMs = 0;
    this.applyMarkup(markup);
  }

  private deferMarkup(markup: string): void {
    if (!this.deferredMarkup) {
      this.deferredMarkupAtMs = performance.now();
    }
    this.deferredMarkup = markup;
  }

  private shouldFlushDeferredMarkupNow(): boolean {
    return Boolean(this.deferredMarkup && performance.now() - this.deferredMarkupAtMs >= STABLE_PANEL_DEFER_LIMIT_MS);
  }

  private applyMarkup(markup: string): void {
    const scrollState = captureScrollState(this.root);
    const previousNodeCount = countElementTreeNodes(this.root);
    this.root.className = "ui-root battle-ui";
    this.root.innerHTML = markup;
    const nextNodeCount = countElementTreeNodes(this.root);
    this.recordRenderLifecycleMetrics?.({
      domPatches: 1,
      domNodesCreated: Math.max(0, nextNodeCount - 1),
      domNodesDestroyed: Math.max(0, previousNodeCount - 1),
      detachedDomNodes: this.root.isConnected ? 0 : 1
    });
    this.lastMarkup = markup;
    this.lastStableMarkup = createStableMarkupSignature(markup);
    restoreScrollState(this.root, scrollState);
    this.applyTutorialPanelState();
    this.applySidePanelState();
  }

  private patchVolatileRegions(markup: string, stableMarkup: string): boolean {
    const template = document.createElement("template");
    template.innerHTML = markup;
    const nextRegions = [...template.content.querySelectorAll<HTMLElement>("[data-hud-volatile]")];
    if (nextRegions.length === 0) {
      return false;
    }
    const nextRegionIds = new Set(nextRegions.map((region) => region.dataset.hudVolatile).filter((regionId): regionId is string => Boolean(regionId)));
    let patchedRegionCount = 0;
    let domNodesCreated = 0;
    let domNodesDestroyed = 0;

    this.root.querySelectorAll<HTMLElement>("[data-hud-volatile]").forEach((currentRegion) => {
      const regionId = currentRegion.dataset.hudVolatile;
      if (regionId && !nextRegionIds.has(regionId)) {
        domNodesDestroyed += countElementTreeNodes(currentRegion);
        currentRegion.remove();
        patchedRegionCount += 1;
      }
    });

    for (const nextRegion of nextRegions) {
      const regionId = nextRegion.dataset.hudVolatile;
      if (!regionId) {
        return false;
      }
      const currentRegion = this.root.querySelector<HTMLElement>(`[data-hud-volatile="${regionId}"]`);
      if (!currentRegion && !insertVolatileRegion(this.root, nextRegion)) {
        return false;
      }
      const patchedRegion = this.root.querySelector<HTMLElement>(`[data-hud-volatile="${regionId}"]`);
      if (!patchedRegion || patchedRegion.tagName !== nextRegion.tagName) {
        return false;
      }
      if (elementAttributesEqual(patchedRegion, nextRegion) && patchedRegion.innerHTML === nextRegion.innerHTML) {
        continue;
      }
      if (patchedRegion === currentRegion) {
        domNodesDestroyed += countElementTreeNodes(patchedRegion);
        domNodesCreated += countElementTreeNodes(nextRegion);
      } else {
        domNodesCreated += countElementTreeNodes(nextRegion);
      }
      replaceElementAttributes(patchedRegion, nextRegion);
      patchedRegion.innerHTML = nextRegion.innerHTML;
      patchedRegionCount += 1;
    }

    this.lastMarkup = markup;
    this.lastStableMarkup = stableMarkup;
    if (patchedRegionCount > 0) {
      this.recordRenderLifecycleMetrics?.({
        domPatches: patchedRegionCount,
        domNodesCreated,
        domNodesDestroyed,
        detachedDomNodes: this.root.isConnected ? 0 : 1
      });
    }
    this.applyTutorialPanelState();
    this.applySidePanelState();
    return true;
  }

  private markInteractionHandled(): void {
    this.deferredMarkup = "";
    this.deferredMarkupAtMs = 0;
    this.pointerInsideStablePanel = false;
    this.forceNextUpdate = true;
  }

  private resetTutorialPanelState(): void {
    this.tutorialPanelOffset = { x: 0, y: 0 };
    this.tutorialPanelMinimized = false;
    this.applyTutorialPanelState();
  }

  private applyTutorialPanelState(): void {
    const panel = this.root.querySelector<HTMLElement>("[data-testid='tutorial-overlay']");
    if (!panel) {
      return;
    }
    const x = Math.round(this.tutorialPanelOffset.x);
    const y = Math.round(this.tutorialPanelOffset.y);
    setStylePropertyIfChanged(panel, "--tutorial-panel-offset-x", `${x}px`);
    setStylePropertyIfChanged(panel, "--tutorial-panel-offset-y", `${y}px`);
    setDatasetValueIfChanged(panel, "tutorialMoved", x !== 0 || y !== 0 ? "true" : "false");
    setDatasetValueIfChanged(panel, "tutorialMinimized", this.tutorialPanelMinimized ? "true" : "false");
    toggleClassIfChanged(panel, "minimized", this.tutorialPanelMinimized);

    const body = panel.querySelector<HTMLElement>("[data-testid='tutorial-panel-body']");
    setAttributeIfChanged(body, "aria-hidden", this.tutorialPanelMinimized ? "true" : "false");

    const minimizeButton = panel.querySelector<HTMLButtonElement>("[data-testid='tutorial-minimize']");
    setAttributeIfChanged(minimizeButton, "aria-expanded", this.tutorialPanelMinimized ? "false" : "true");
  }

  private applySidePanelState(): void {
    const panel = this.root.querySelector<HTMLElement>("[data-testid='selection-side-panel']");
    if (!panel) {
      return;
    }
    setDatasetValueIfChanged(panel, "sidePanelMinimized", this.sidePanelMinimized ? "true" : "false");
    toggleClassIfChanged(panel, "minimized", this.sidePanelMinimized);

    const body = panel.querySelector<HTMLElement>("[data-testid='side-panel-body']");
    setAttributeIfChanged(body, "aria-hidden", this.sidePanelMinimized ? "true" : "false");

    const minimizeButton = panel.querySelector<HTMLButtonElement>("[data-testid='side-panel-minimize']");
    setAttributeIfChanged(minimizeButton, "aria-expanded", this.sidePanelMinimized ? "false" : "true");
  }

  private clampTutorialPanelOffset(offset: TutorialPanelOffset): TutorialPanelOffset {
    const panel = this.root.querySelector<HTMLElement>("[data-testid='tutorial-overlay']");
    if (!panel) {
      return offset;
    }

    const margin = 8;
    const current = this.tutorialPanelOffset;
    const rect = panel.getBoundingClientRect();
    let x = offset.x;
    let y = offset.y;
    const deltaX = x - current.x;
    const deltaY = y - current.y;
    const proposedLeft = rect.left + deltaX;
    const proposedRight = rect.right + deltaX;
    const proposedTop = rect.top + deltaY;
    const proposedBottom = rect.bottom + deltaY;

    if (proposedLeft < margin) {
      x += margin - proposedLeft;
    }
    if (proposedRight > window.innerWidth - margin) {
      x -= proposedRight - (window.innerWidth - margin);
    }
    if (proposedTop < margin) {
      y += margin - proposedTop;
    }
    if (proposedBottom > window.innerHeight - margin) {
      y -= proposedBottom - (window.innerHeight - margin);
    }

    return {
      x: Math.round(x),
      y: Math.round(y)
    };
  }
}

const STABLE_INTERACTION_SELECTOR = ".top-bar, .side-panel, .objectives-panel, .tutorial-panel, .minimap-shell, .pause-menu-panel";
const SCROLLABLE_HUD_SELECTORS = [".side-panel", ".objectives-panel", ".tutorial-panel"] as const;
const TUTORIAL_PANEL_NON_DRAG_SELECTOR = "button, a, input, select, textarea, summary, details, [role='button'], [data-action]";

function isStableInteractionTarget(target: EventTarget | null): boolean {
  return target instanceof Element && Boolean(target.closest(STABLE_INTERACTION_SELECTOR));
}

function clearInteractionFocus(target: Element | null): void {
  const focusTarget = target?.closest<HTMLElement>("button, [role='button']");
  focusTarget?.blur();
}

function createStableMarkupSignature(markup: string): string {
  const template = document.createElement("template");
  template.innerHTML = markup;
  template.content.querySelectorAll<HTMLElement>("[data-hud-volatile]").forEach((element) => {
    element.remove();
  });
  return template.innerHTML;
}

function insertVolatileRegion(root: HTMLElement, source: HTMLElement): boolean {
  if (source.dataset.hudVolatile === "hint") {
    const status = root.querySelector<HTMLElement>('[data-hud-volatile="status"]');
    if (!status) {
      return false;
    }
    status.insertAdjacentHTML("afterend", source.outerHTML);
    return true;
  }
  return false;
}

function replaceElementAttributes(target: HTMLElement, source: HTMLElement): void {
  [...target.attributes].forEach((attribute) => {
    if (!source.hasAttribute(attribute.name)) {
      target.removeAttribute(attribute.name);
    }
  });
  [...source.attributes].forEach((attribute) => {
    target.setAttribute(attribute.name, attribute.value);
  });
}

function elementAttributesEqual(target: HTMLElement, source: HTMLElement): boolean {
  if (target.attributes.length !== source.attributes.length) {
    return false;
  }
  return [...source.attributes].every((attribute) => target.getAttribute(attribute.name) === attribute.value);
}

function countElementTreeNodes(element: HTMLElement): number {
  return element.querySelectorAll("*").length + 1;
}

function setStylePropertyIfChanged(element: HTMLElement, property: string, value: string): void {
  if (element.style.getPropertyValue(property) !== value) {
    element.style.setProperty(property, value);
  }
}

function setDatasetValueIfChanged(element: HTMLElement, key: string, value: string): void {
  if (element.dataset[key] !== value) {
    element.dataset[key] = value;
  }
}

function setAttributeIfChanged(element: HTMLElement | undefined | null, name: string, value: string): void {
  if (element && element.getAttribute(name) !== value) {
    element.setAttribute(name, value);
  }
}

function toggleClassIfChanged(element: HTMLElement, className: string, force: boolean): void {
  if (element.classList.contains(className) !== force) {
    element.classList.toggle(className, force);
  }
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
