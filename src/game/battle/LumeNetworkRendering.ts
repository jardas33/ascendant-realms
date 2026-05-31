import type { LumeNetworkCurrentLinkState, LumeNetworkVisibilityMode } from "../core/GameTypes";

export type LumeRenderPulseKind = "activated" | "restored" | "contested" | "severed";
export type LumeRenderLinkStyle = "guide" | "active" | "highlight" | "contested" | "severed";
export type LumeRenderEmphasis = "stable" | "teaching" | "selected" | "pulse" | "overlay";

export interface LumeRenderPulse {
  kind: LumeRenderPulseKind;
  startedAtSeconds: number;
  durationSeconds: number;
}

export interface LumeRenderLinkInput {
  id: string;
  state: LumeNetworkCurrentLinkState;
  fromSiteId: string;
  toSiteId: string;
}

export interface LumeRenderPresentationContext {
  visibilityMode: LumeNetworkVisibilityMode;
  privateDemo: boolean;
  objectiveCompleted: boolean;
  selectedSiteIds: string[];
  firstLinkId?: string;
  optionalLinkId?: string;
  pulse?: LumeRenderPulse;
  elapsedSeconds: number;
  pulsePhase: number;
}

export interface LumeRenderPresentation {
  visible: boolean;
  style: LumeRenderLinkStyle;
  emphasis: LumeRenderEmphasis;
  color: number;
  alpha: number;
  width: number;
  markerAlpha: number;
  pulseKind?: LumeRenderPulseKind;
}

export function resolveLumeLinkPresentation(
  link: LumeRenderLinkInput,
  context: LumeRenderPresentationContext
): LumeRenderPresentation {
  const pulse = activePulse(context.pulse, context.elapsedSeconds);
  if (pulse) {
    return pulsePresentation(pulse, context.pulsePhase);
  }

  const selectedEndpoint =
    context.selectedSiteIds.includes(link.fromSiteId) || context.selectedSiteIds.includes(link.toSiteId);
  if (context.visibilityMode === "hidden") {
    return hiddenPresentation();
  }

  const selectedRelevant =
    selectedEndpoint &&
    (link.state === "active" ||
      link.id === context.firstLinkId ||
      (context.objectiveCompleted && link.id === context.optionalLinkId));

  if (selectedRelevant) {
    return {
      visible: true,
      style: "highlight",
      emphasis: "selected",
      color: 0x8ff6e5,
      alpha: 0.58,
      width: 4,
      markerAlpha: 0.54
    };
  }

  if (context.visibilityMode === "always") {
    return alwaysPresentation(link.state);
  }

  if (link.state === "active") {
    return {
      visible: true,
      style: "active",
      emphasis: "stable",
      color: 0x74d3f2,
      alpha: 0.28,
      width: 2.5,
      markerAlpha: 0.22
    };
  }

  if (context.privateDemo && isTeachingGuide(link, context)) {
    return {
      visible: true,
      style: "guide",
      emphasis: "teaching",
      color: 0x74d3f2,
      alpha: 0.16,
      width: 2,
      markerAlpha: 0.14
    };
  }

  return hiddenPresentation();
}

export function activePulse(pulse: LumeRenderPulse | undefined, elapsedSeconds: number): LumeRenderPulse | undefined {
  if (!pulse) {
    return undefined;
  }
  return elapsedSeconds - pulse.startedAtSeconds <= pulse.durationSeconds ? pulse : undefined;
}

function pulsePresentation(pulse: LumeRenderPulse, pulsePhase: number): LumeRenderPresentation {
  if (pulse.kind === "contested") {
    return {
      visible: true,
      style: "contested",
      emphasis: "pulse",
      color: 0xf0d978,
      alpha: 0.42 + pulsePhase * 0.22,
      width: 4,
      markerAlpha: 0.42 + pulsePhase * 0.18,
      pulseKind: pulse.kind
    };
  }
  if (pulse.kind === "severed") {
    return {
      visible: true,
      style: "severed",
      emphasis: "pulse",
      color: 0xff6b6b,
      alpha: 0.36 + pulsePhase * 0.18,
      width: 4,
      markerAlpha: 0.36 + pulsePhase * 0.16,
      pulseKind: pulse.kind
    };
  }
  return {
    visible: true,
    style: "highlight",
    emphasis: "pulse",
    color: 0x8ff6e5,
    alpha: 0.56 + pulsePhase * 0.18,
    width: 4,
    markerAlpha: 0.5 + pulsePhase * 0.16,
    pulseKind: pulse.kind
  };
}

function alwaysPresentation(state: LumeNetworkCurrentLinkState): LumeRenderPresentation {
  if (state === "active") {
    return {
      visible: true,
      style: "active",
      emphasis: "overlay",
      color: 0x8ff6e5,
      alpha: 0.42,
      width: 3,
      markerAlpha: 0.36
    };
  }
  if (state === "contested") {
    return {
      visible: true,
      style: "contested",
      emphasis: "overlay",
      color: 0xf0d978,
      alpha: 0.3,
      width: 3,
      markerAlpha: 0.28
    };
  }
  if (state === "severed") {
    return {
      visible: true,
      style: "severed",
      emphasis: "overlay",
      color: 0xff6b6b,
      alpha: 0.24,
      width: 3,
      markerAlpha: 0.24
    };
  }
  return {
    visible: true,
    style: "guide",
    emphasis: "overlay",
    color: 0x74d3f2,
    alpha: 0.14,
    width: 2,
    markerAlpha: 0.12
  };
}

function isTeachingGuide(link: LumeRenderLinkInput, context: LumeRenderPresentationContext): boolean {
  if (!context.objectiveCompleted) {
    return link.id === context.firstLinkId;
  }
  return link.id === context.optionalLinkId;
}

function hiddenPresentation(): LumeRenderPresentation {
  return {
    visible: false,
    style: "guide",
    emphasis: "stable",
    color: 0x74d3f2,
    alpha: 0,
    width: 0,
    markerAlpha: 0
  };
}
