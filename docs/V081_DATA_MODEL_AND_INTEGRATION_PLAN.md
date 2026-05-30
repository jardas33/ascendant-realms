# v0.81 Data Model And Integration Plan

Status: docs-only future data model. No runtime TypeScript files were added.

## Design Goal

The first Lume Site Network prototype should be content-driven and battle-local. It should reuse existing map capture sites and derive active link state from ownership. It should not add save fields, a global graph, a second economy, dynamic pathfinding, or persistent network state.

## Proposed Future Interfaces

Pseudocode only:

```ts
export interface LumeNetworkScenarioDefinition {
  id: string;
  campaignNodeId: string;
  mapId: string;
  enabled: boolean;
  eligibleSiteIds: string[];
  links: LumeNetworkLinkDefinition[];
  activation: LumeNetworkActivationDefinition;
  benefit: LumeNetworkBenefitDefinition;
  tutorialExcluded: true;
  rewardsDisabledExcluded: true;
}

export interface LumeNetworkLinkDefinition {
  id: string;
  fromSiteId: string;
  toSiteId: string;
  displayName: string;
  maxActiveLinks?: number;
}

export interface LumeNetworkActivationDefinition {
  mode: "capture_only" | "hero_binding";
  requiredOwner: "player";
  bindingSeconds?: number;
}

export interface LumeNetworkBenefitDefinition {
  id: "linked_ward";
  name: string;
  summary: string;
  radiusPadding: number;
  nonStacking: true;
}

export interface LumeNetworkBattleState {
  activeLinkIds: string[];
  inactiveLinkIds: string[];
  severedLinkIds: string[];
  completedObjectiveIds: string[];
  lastChangedAtSeconds?: number;
}

export interface LumeNetworkHudViewModel {
  title: string;
  status: "inactive" | "active" | "contested" | "severed";
  objective: string;
  benefitSummary: string;
  counterplay: string;
  endpointNames: string[];
}

export interface LumeNetworkResultsSummary {
  networkId: string;
  activatedLinkIds: string[];
  severedLinkIds: string[];
  objectiveCompleted: boolean;
  afterActionSummary: string;
}
```

## Ownership Rules

Future resolver:

- Find eligible capture sites from live `CaptureSite[]`.
- Ignore unknown site ids safely.
- A link is active only when both endpoint sites exist, are alive, and are player-owned.
- A link is inactive when either endpoint is neutral.
- A link is severed when a previously active endpoint becomes enemy-owned or neutral.
- A severed link can reactivate if both endpoints return to player ownership, unless the mission objective explicitly says "hold once."

## Activation Rules

First prototype:

- `mode: "capture_only"`.
- No hero binding.
- No Worker binding.
- No new action command.

Deferred:

- `mode: "hero_binding"` can be added after review if Emmanuel wants the Jardas action to be explicit.

## Benefit Rules

First benefit:

- `linked_ward`.
- Non-stacking.
- Applies only while a link is active.
- Applies only near active endpoint sites.
- Ends immediately if the link is severed.
- Does not alter resource income by default.

Possible implementation later:

- Add a small combat readiness marker during damage calculation or status derivation.
- If combat hooks are too risky, convert the first prototype to a battle-local objective bonus while preserving the same UI/Results flow.

## UI View Model

Future HUD can use the same style as `HUDBattlefieldEventSnapshot` in `src/game/ui/hudPanels/HudTypes.ts` and `renderObjectives` in `src/game/ui/hudPanels/ObjectivePanel.ts`.

Minimum state:

- title: "Lume Link"
- objective: "Hold West Stone Cut and Ford Toll"
- progress: "Active", "Inactive", "Severed", or "Contested"
- counterplay: "Recapture either site to restore the ward."
- plan support: not needed first.

## Results Telemetry

Use battle-local stats only. Future stats can mirror the existing battlefield-event arrays in `BattleStats`.

Pseudocode:

```ts
interface BattleStats {
  lumeNetworkId?: string;
  lumeLinkActivatedIds?: string[];
  lumeLinkSeveredIds?: string[];
  lumeObjectiveCompleted?: boolean;
  lumeTelemetryLabels?: string[];
}
```

This is not a save migration because `BattleStats` is Results/session data, not persisted campaign save format. If those stats are serialized anywhere later, the runtime prototype must document that explicitly.

## Content Validation

Future validation should check:

- network id is unique;
- `campaignNodeId` exists and is a battle node;
- `mapId` matches the node map;
- eligible site ids exist on that map;
- link endpoint ids are eligible and distinct;
- no duplicate links;
- max three eligible sites for the first prototype;
- max two links for the first prototype;
- benefit id is known;
- Tutorial/no-reward exclusion is explicit;
- no legacy internal IDs are renamed.

Likely file: `src/game/data/validation/validateContent.ts` with a focused validator similar to `validateBattlefieldEvents.ts`.

## Likely Future Files To Extend

Content/data:

- `src/game/data/lumeNetworks.ts` for definitions.
- `src/game/data/contentIndex.ts` for indexes.
- `src/game/data/validation/validateLumeNetworks.ts` for validation.
- `src/game/data/borderMarchesNodes.ts` only if future briefing copy is approved.

Runtime:

- `src/game/battle/LumeNetworkDirector.ts` or equivalent small resolver.
- `src/game/scenes/BattleScene.ts` to own director lifecycle.
- `src/game/battle/BattleRuntime.ts` to record battle-only telemetry.
- `src/game/ui/hudPanels/ObjectivePanel.ts` for one row.
- `src/game/ui/hudPanels/SelectedEntityPanel.ts` for selected-site state.
- `src/game/results/ResultsObjectiveSummary.ts` for one summary block.

Tests:

- pure resolver tests;
- content validation tests;
- ResourceSystem ownership/severing test;
- HUD row render test;
- Results summary test;
- hosted proxy for the chosen mission.

## Files That Must Remain Untouched In The First Prototype

Unless a later goal explicitly opens them:

- save version and save migrations;
- repository/package name;
- runtime title;
- internal resource id `aether`;
- `maxMana`;
- `mission_aether_surge`;
- `aether_surge`;
- `aether_lens`;
- faction IDs;
- map IDs;
- campaign node IDs.

## Tutorial And No-Reward Guard

Future director enable check:

```ts
function isLumeNetworkEnabled(request: BattleLaunchRequest): boolean {
  return request.mode === "campaign_node" &&
    request.rewardsDisabled !== true &&
    request.campaignNodeId === "aether_well_ruins";
}
```

This keeps Tutorial, skirmish, scenario mission, and no-reward routes clean.
