import type {
  LumeNetworkCurrentLinkState,
  LumeNetworkDefinition,
  LumeNetworkHudSummary,
  LumeNetworkResolvedState,
  LumeNetworkSiteSummary,
  LumeSiteSnapshot,
  LumeTargetSnapshot
} from "../core/GameTypes";
import { distance } from "../core/MathUtils";
import type { BaseEntity } from "../entities/BaseEntity";
import type { CaptureSite } from "../entities/CaptureSite";

export interface LumeNetworkDirectorOptions {
  definition: LumeNetworkDefinition;
  getCaptureSites: () => CaptureSite[];
  recordNetworkStarted: (networkId: string) => void;
  recordLinkActivated: (linkId: string, telemetryLabel: string) => void;
  recordLinkSevered: (linkId: string, telemetryLabel: string) => void;
  recordObjectiveCompleted: (telemetryLabel: string) => void;
  showMessage?: (message: string, point?: { x: number; y: number }) => void;
}

interface LumeNetworkHudOptions {
  privateDemo?: boolean;
}

export class LumeNetworkDirector {
  private state: LumeNetworkResolvedState;
  private objectiveCompletionRecorded = false;

  constructor(private readonly options: LumeNetworkDirectorOptions) {
    this.state = resolveLumeNetworkState(options.definition, this.siteSnapshots());
    this.options.recordNetworkStarted(options.definition.id);
  }

  update(): void {
    const previous = this.state;
    this.state = resolveLumeNetworkState(this.options.definition, this.siteSnapshots(), previous);
    this.recordTransitions(previous, this.state);
  }

  adjustIncomingDamage(amount: number, target: BaseEntity): number {
    if (!isLinkedWardTarget(this.options.definition, this.state, this.siteSnapshots(), target)) {
      return amount;
    }
    return amount * this.options.definition.benefit.damageTakenMultiplier;
  }

  hudSummary(options: LumeNetworkHudOptions = {}): LumeNetworkHudSummary {
    const sites = this.siteSnapshots();
    const active = this.state.activeLinkIds.length;
    const progressLabel = `LUME LINKS ${active}/${this.options.definition.maxActiveLinks}`;
    const firstLink = this.state.links[0];
    const optionalLink = this.state.links[1];
    const firstLinkHeld = firstLink ? playerHeldRequiredSiteCount(firstLink, sites) : 0;
    const severedLink = this.state.links.find((link) => this.state.currentSeveredLinkIds.includes(link.id));
    const severedSiteName = severedLink ? linkRecoverySiteName(severedLink, sites) : undefined;
    const activeLinks = this.state.links.filter((link) => link.active);
    const activeLinkName = activeLinks[0] ? linkDisplayName(activeLinks[0]) : undefined;
    let title = "LUME WARD";
    let objective = firstLink ? `Capture ${firstLink.fromSiteName}` : this.options.definition.hudObjective;
    let status = progressLabel;

    if (active >= this.options.definition.maxActiveLinks) {
      title = `LUME NETWORK ACTIVE - ${active}/${this.options.definition.maxActiveLinks}`;
      objective = "All known Lume links are active.";
      status = "Nearby allies take 8% less damage";
    } else if (severedLink && active === 0) {
      title = "LUME LINK SEVERED";
      objective = `Recapture ${severedSiteName ?? severedLink.displayName}`;
      status = progressLabel;
    } else if (active > 0) {
      const restored = activeLinks.some((link) => this.state.lifetimeSeveredLinkIds.includes(link.id));
      title = restored ? "LUME WARD RESTORED" : "LUME WARD ACTIVE";
      objective = activeLinkName ?? "Linked Ward active";
      status = "Nearby allies take 8% less damage";
    } else if (firstLink && firstLinkHeld > 0) {
      const missingSiteName = missingRequiredSiteName(firstLink, sites);
      objective = `Capture ${missingSiteName ?? firstLink.toSiteName}`;
      status = `${firstLinkHeld} of 2 sites held`;
    }

    return {
      title,
      objective,
      status,
      benefit: this.options.definition.benefit.summary,
      counterplay: this.options.definition.counterplay,
      activeLinkCount: active,
      maxActiveLinks: this.options.definition.maxActiveLinks,
      progressLabel,
      detailsLabel: this.options.definition.battleLocalCopy,
      heldRequiredSiteCount: firstLinkHeld,
      requiredSiteCount: firstLink ? 2 : 0,
      primaryLinkName: activeLinkName,
      optionalLinkName: optionalLink && this.state.objectiveCompleted ? linkDisplayName(optionalLink) : undefined,
      optionalSiteName: optionalLink && this.state.objectiveCompleted ? optionalLink.toSiteName : undefined,
      severedSiteName,
      focusControls: options.privateDemo ? this.focusControls() : undefined,
      privateDemo: options.privateDemo,
      finishDemoAvailable: Boolean(options.privateDemo && this.state.objectiveCompleted)
    };
  }

  siteSummary(site: CaptureSite): LumeNetworkSiteSummary | undefined {
    if (!this.options.definition.eligibleSiteIds.includes(site.definition.id)) {
      return undefined;
    }
    const touchingLinks = this.state.links.filter(
      (link) => link.fromSiteId === site.definition.id || link.toSiteId === site.definition.id
    );
    const state = siteLinkState(touchingLinks.map((link) => link.state));
    const linkedSites = touchingLinks
      .map((link) => (link.fromSiteId === site.definition.id ? link.toSiteName : link.fromSiteName))
      .filter((name, index, names) => names.indexOf(name) === index)
      .join(", ");
    return {
      title: "Lume Link",
      state,
      linkedSites: linkedSites || "None",
      benefit: this.options.definition.benefit.summary,
      counterplay: this.options.definition.counterplay
    };
  }

  currentState(): LumeNetworkResolvedState {
    return {
      ...this.state,
      activeLinkIds: [...this.state.activeLinkIds],
      inactiveLinkIds: [...this.state.inactiveLinkIds],
      contestedLinkIds: [...this.state.contestedLinkIds],
      currentSeveredLinkIds: [...this.state.currentSeveredLinkIds],
      lifetimeActivatedLinkIds: [...this.state.lifetimeActivatedLinkIds],
      lifetimeSeveredLinkIds: [...this.state.lifetimeSeveredLinkIds],
      links: this.state.links.map((link) => ({ ...link }))
    };
  }

  private siteSnapshots(): LumeSiteSnapshot[] {
    return this.options.getCaptureSites().map((site) => ({
      id: site.definition.id,
      name: site.definition.name,
      owner: site.owner,
      alive: site.alive,
      position: { ...site.position },
      radius: site.definition.radius,
      captureProgress: site.captureProgress,
      capturingTeam: site.capturingTeam
    }));
  }

  private recordTransitions(previous: LumeNetworkResolvedState, current: LumeNetworkResolvedState): void {
    const sites = this.siteSnapshots();
    const networkFullyAwakened =
      previous.activeLinkIds.length < this.options.definition.maxActiveLinks &&
      current.activeLinkIds.length >= this.options.definition.maxActiveLinks;
    current.activeLinkIds
      .filter((linkId) => !previous.activeLinkIds.includes(linkId))
      .forEach((linkId) => {
        const link = current.links.find((entry) => entry.id === linkId);
        const point = this.messagePoint(link, sites);
        const restored = Boolean(
          link && (previous.currentSeveredLinkIds.includes(link.id) || previous.lifetimeSeveredLinkIds.includes(link.id))
        );
        this.options.recordLinkActivated(
          linkId,
          restored ? `${link?.displayName ?? linkId} restored Linked Ward.` : `${link?.displayName ?? linkId} activated Linked Ward.`
        );
        if (networkFullyAwakened) {
          this.options.showMessage?.(`Lume Network fully awakened: ${current.activeLinkIds.length}/${this.options.definition.maxActiveLinks} links active`, point);
          return;
        }
        this.options.showMessage?.(restored ? "Lume Ward restored" : "Lume Ward awakened", point);
      });
    current.currentSeveredLinkIds
      .filter((linkId) => !previous.currentSeveredLinkIds.includes(linkId))
      .forEach((linkId) => {
        const link = current.links.find((entry) => entry.id === linkId);
        const point = this.messagePoint(link, sites);
        const lostSiteName = link ? linkRecoverySiteName(link, sites) : undefined;
        this.options.recordLinkSevered(linkId, `${link?.displayName ?? linkId} severed by site control loss.`);
        this.options.showMessage?.(`Lume Link severed: ${lostSiteName ?? link?.displayName ?? linkId} lost`, point);
      });
    if (current.objectiveCompleted && !this.objectiveCompletionRecorded) {
      this.objectiveCompletionRecorded = true;
      this.options.recordObjectiveCompleted("Linked Ward objective completed.");
    }
  }

  private messagePoint(
    link: LumeNetworkResolvedState["links"][number] | undefined,
    sites: LumeSiteSnapshot[]
  ): { x: number; y: number } | undefined {
    if (!link) {
      return undefined;
    }
    const from = sites.find((site) => site.id === link.fromSiteId);
    const to = sites.find((site) => site.id === link.toSiteId);
    if (!from || !to) {
      return from?.position ?? to?.position;
    }
    return {
      x: (from.position.x + to.position.x) / 2,
      y: (from.position.y + to.position.y) / 2
    };
  }

  private focusControls(): LumeNetworkHudSummary["focusControls"] {
    const firstLink = this.state.links[0];
    if (!firstLink) {
      return [];
    }
    const controls = [
      { siteId: firstLink.fromSiteId, siteName: firstLink.fromSiteName },
      { siteId: firstLink.toSiteId, siteName: firstLink.toSiteName }
    ];
    const optionalLink = this.state.links[1];
    if (optionalLink && this.state.objectiveCompleted) {
      controls.push({ siteId: optionalLink.toSiteId, siteName: optionalLink.toSiteName });
    }
    return controls
      .filter((control, index, entries) => entries.findIndex((entry) => entry.siteId === control.siteId) === index)
      .map((control) => ({
        ...control,
        label: `Focus ${control.siteName}`
      }));
  }
}

export function resolveLumeNetworkState(
  definition: LumeNetworkDefinition,
  sites: LumeSiteSnapshot[],
  previous?: LumeNetworkResolvedState
): LumeNetworkResolvedState {
  const siteById = new Map(sites.map((site) => [site.id, site]));
  const previousActive = new Set(previous?.activeLinkIds ?? []);
  const lifetimeActivated = new Set(previous?.lifetimeActivatedLinkIds ?? []);
  const lifetimeSevered = new Set(previous?.lifetimeSeveredLinkIds ?? []);
  const activeLinkIds: string[] = [];
  const inactiveLinkIds: string[] = [];
  const contestedLinkIds: string[] = [];
  const currentSeveredLinkIds: string[] = [];
  const links = definition.links.map((link) => {
    const fromSite = siteById.get(link.fromSiteId);
    const toSite = siteById.get(link.toSiteId);
    const active = Boolean(
      fromSite?.alive &&
        toSite?.alive &&
        fromSite.owner === "player" &&
        toSite.owner === "player" &&
        activeLinkIds.length < definition.maxActiveLinks
    );
    const contested = !active && Boolean(isSiteContested(fromSite) || isSiteContested(toSite));
    const severed = !active && (previousActive.has(link.id) || lifetimeSevered.has(link.id));
    const state: LumeNetworkCurrentLinkState = active ? "active" : contested ? "contested" : severed ? "severed" : "inactive";
    if (active) {
      activeLinkIds.push(link.id);
      lifetimeActivated.add(link.id);
    } else {
      inactiveLinkIds.push(link.id);
    }
    if (contested) {
      contestedLinkIds.push(link.id);
    }
    if (state === "severed") {
      currentSeveredLinkIds.push(link.id);
      lifetimeSevered.add(link.id);
    }
    return {
      id: link.id,
      displayName: link.displayName,
      fromSiteId: link.fromSiteId,
      toSiteId: link.toSiteId,
      fromSiteName: fromSite?.name ?? link.fromSiteId,
      toSiteName: toSite?.name ?? link.toSiteId,
      state,
      active,
      contested
    };
  });
  return {
    networkId: definition.id,
    activeLinkIds,
    inactiveLinkIds,
    contestedLinkIds,
    currentSeveredLinkIds,
    lifetimeActivatedLinkIds: [...lifetimeActivated],
    lifetimeSeveredLinkIds: [...lifetimeSevered],
    objectiveCompleted: previous?.objectiveCompleted || lifetimeActivated.size > 0,
    links
  };
}

export function isLinkedWardTarget(
  definition: LumeNetworkDefinition,
  state: LumeNetworkResolvedState,
  sites: LumeSiteSnapshot[],
  target: LumeTargetSnapshot
): boolean {
  if (!target.alive || target.team !== "player" || state.activeLinkIds.length === 0) {
    return false;
  }
  const siteById = new Map(sites.map((site) => [site.id, site]));
  return definition.links.some((link) => {
    if (!state.activeLinkIds.includes(link.id)) {
      return false;
    }
    return [link.fromSiteId, link.toSiteId].some((siteId) => {
      const site = siteById.get(siteId);
      return Boolean(
        site?.alive &&
          site.owner === "player" &&
          distance(site.position, target.position) <= site.radius + definition.benefit.endpointRadiusBonus
      );
    });
  });
}

function isSiteContested(site: LumeSiteSnapshot | undefined): boolean {
  return Boolean(site?.alive && site.captureProgress && site.captureProgress > 0 && site.capturingTeam !== "neutral");
}

function siteLinkState(states: LumeNetworkCurrentLinkState[]): LumeNetworkCurrentLinkState {
  if (states.includes("active")) {
    return "active";
  }
  if (states.includes("contested")) {
    return "contested";
  }
  if (states.includes("severed")) {
    return "severed";
  }
  return "inactive";
}

function linkDisplayName(link: LumeNetworkResolvedState["links"][number]): string {
  return `${link.fromSiteName} ↔ ${link.toSiteName}`;
}

function playerHeldRequiredSiteCount(link: LumeNetworkResolvedState["links"][number], sites: LumeSiteSnapshot[]): number {
  return [link.fromSiteId, link.toSiteId].filter((siteId) => sites.find((site) => site.id === siteId)?.owner === "player").length;
}

function missingRequiredSiteName(link: LumeNetworkResolvedState["links"][number], sites: LumeSiteSnapshot[]): string | undefined {
  const from = sites.find((site) => site.id === link.fromSiteId);
  const to = sites.find((site) => site.id === link.toSiteId);
  if (from?.owner !== "player") {
    return from?.name ?? link.fromSiteName;
  }
  if (to?.owner !== "player") {
    return to?.name ?? link.toSiteName;
  }
  return undefined;
}

function linkRecoverySiteName(link: LumeNetworkResolvedState["links"][number], sites: LumeSiteSnapshot[]): string | undefined {
  return missingRequiredSiteName(link, sites) ?? link.toSiteName;
}
