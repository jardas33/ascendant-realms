import { resolveRuntimeArtSlots } from "../art/RuntimeArtSlotAdapter";
import { RUNTIME_ART_SLOT_GROUPS } from "../art/RuntimeArtSlotTypes";

declare global {
  interface Window {
    __ASCENDANT_RUNTIME_ART_SLOTS__?: RuntimeArtSlotDiagnosticsApi;
  }
}

export interface RuntimeArtSlotDiagnosticsApi {
  showDiagnostics: () => boolean;
  hideDiagnostics: () => boolean;
  toggleDiagnostics: () => boolean;
  enableMockMode: () => boolean;
  disableMockMode: () => boolean;
  snapshot: () => {
    visible: boolean;
    mockMode: boolean;
    fallbackCount: number;
    mockCount: number;
    runtimeAssetCount: number;
    slotCount: number;
  };
}

interface InstallRuntimeArtSlotDiagnosticsOptions {
  enabled: boolean;
}

let installedRoot: HTMLElement | undefined;
let diagnosticsVisible = false;
let mockMode = false;

export function isRuntimeArtSlotDiagnosticsEnabledForPosture(dev: boolean, privateFlag?: boolean): boolean {
  void dev;
  return privateFlag === true;
}

export function isRuntimeArtSlotDiagnosticsEnabled(): boolean {
  return isRuntimeArtSlotDiagnosticsEnabledForPosture(import.meta.env.DEV, globalThis.window?.__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__);
}

export function isRuntimeArtSlotMockModeEnabledForPosture(dev: boolean, privateFlag?: boolean, requested = false): boolean {
  return requested && isRuntimeArtSlotDiagnosticsEnabledForPosture(dev, privateFlag);
}

export function installPrivateRuntimeArtSlotDiagnostics(options: InstallRuntimeArtSlotDiagnosticsOptions): void {
  if (typeof document === "undefined" || typeof window === "undefined") {
    return;
  }

  if (!options.enabled) {
    removeDiagnostics();
    delete window.__ASCENDANT_RUNTIME_ART_SLOTS__;
    return;
  }

  const api: RuntimeArtSlotDiagnosticsApi = {
    showDiagnostics: () => setDiagnosticsVisible(true),
    hideDiagnostics: () => setDiagnosticsVisible(false),
    toggleDiagnostics: () => setDiagnosticsVisible(!diagnosticsVisible),
    enableMockMode: () => setMockMode(true),
    disableMockMode: () => setMockMode(false),
    snapshot: () => {
      const resolutions = resolveRuntimeArtSlots({ privateToolsEnabled: true, privateMockMode: mockMode });
      return {
        visible: diagnosticsVisible,
        mockMode,
        fallbackCount: resolutions.filter((resolution) => resolution.source === "fallback").length,
        mockCount: resolutions.filter((resolution) => resolution.source === "mock").length,
        runtimeAssetCount: resolutions.filter((resolution) => resolution.source === "runtime-asset").length,
        slotCount: resolutions.length
      };
    }
  };

  window.__ASCENDANT_RUNTIME_ART_SLOTS__ = api;

  if (!installedRoot) {
    installedRoot = document.createElement("aside");
    installedRoot.className = "runtime-art-slot-diagnostics";
    installedRoot.dataset.testid = "art-slot-diagnostics";
    installedRoot.setAttribute("aria-label", "Runtime art slot diagnostics");
    document.body.append(installedRoot);
  }

  renderDiagnostics();
}

function setDiagnosticsVisible(nextVisible: boolean): boolean {
  diagnosticsVisible = nextVisible;
  renderDiagnostics();
  return diagnosticsVisible;
}

function setMockMode(nextMockMode: boolean): boolean {
  mockMode = nextMockMode;
  if (typeof document !== "undefined") {
    if (mockMode) {
      document.documentElement.dataset.runtimeArtMock = "true";
    } else {
      delete document.documentElement.dataset.runtimeArtMock;
    }
  }
  renderDiagnostics();
  return mockMode;
}

function removeDiagnostics(): void {
  installedRoot?.remove();
  installedRoot = undefined;
  diagnosticsVisible = false;
  mockMode = false;
  if (typeof document !== "undefined") {
    delete document.documentElement.dataset.runtimeArtMock;
  }
}

function renderDiagnostics(): void {
  if (!installedRoot) {
    return;
  }
  const resolutions = resolveRuntimeArtSlots({ privateToolsEnabled: true, privateMockMode: mockMode });
  const fallbackCount = resolutions.filter((resolution) => resolution.source === "fallback").length;
  const mockCount = resolutions.filter((resolution) => resolution.source === "mock").length;
  const runtimeAssetCount = resolutions.filter((resolution) => resolution.source === "runtime-asset").length;
  installedRoot.dataset.runtimeArtDiagnosticsVisible = String(diagnosticsVisible);
  installedRoot.dataset.runtimeArtMock = String(mockMode);
  installedRoot.innerHTML = `
    <button class="runtime-art-slot-toggle" data-testid="art-slot-diagnostics-toggle" type="button" aria-expanded="${diagnosticsVisible}">
      Art Slots
    </button>
    <section class="runtime-art-slot-panel" data-testid="art-slot-diagnostics-panel" ${diagnosticsVisible ? "" : "hidden"}>
      <header>
        <strong>Runtime Art Slots</strong>
        <span>${resolutions.length} slots</span>
      </header>
      <div class="runtime-art-slot-summary">
        <span data-testid="art-slot-diagnostics-fallback-count">Fallback ${fallbackCount}</span>
        <span data-testid="art-slot-diagnostics-mock-count">Mock ${mockCount}</span>
        <span data-testid="art-slot-diagnostics-runtime-count">Runtime ${runtimeAssetCount}</span>
      </div>
      <div class="runtime-art-slot-actions">
        <button data-testid="art-slot-mock-toggle" type="button">${mockMode ? "Mock On" : "Mock Off"}</button>
      </div>
      <div class="runtime-art-slot-groups">
        ${RUNTIME_ART_SLOT_GROUPS.map((group) => {
          const groupResolutions = resolutions.filter((resolution) => resolution.group === group);
          return `
            <section class="runtime-art-slot-group">
              <h3>${escapeHtml(group)}</h3>
              <ol>
                ${groupResolutions
                  .map(
                    (resolution) => `
                      <li data-testid="art-slot-row-${escapeAttribute(resolution.slotId)}" data-runtime-art-source="${resolution.source}">
                        <code>${escapeHtml(resolution.slotId)}</code>
                        <span>${escapeHtml(resolution.source)}</span>
                      </li>
                    `
                  )
                  .join("")}
              </ol>
            </section>
          `;
        }).join("")}
      </div>
    </section>
  `;

  installedRoot.querySelector<HTMLElement>("[data-testid='art-slot-diagnostics-toggle']")?.addEventListener("click", () => {
    setDiagnosticsVisible(!diagnosticsVisible);
  });
  installedRoot.querySelector<HTMLElement>("[data-testid='art-slot-mock-toggle']")?.addEventListener("click", () => {
    setMockMode(!mockMode);
  });
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/gu, "&amp;")
    .replace(/</gu, "&lt;")
    .replace(/>/gu, "&gt;")
    .replace(/"/gu, "&quot;");
}

function escapeAttribute(value: string): string {
  return escapeHtml(value);
}
