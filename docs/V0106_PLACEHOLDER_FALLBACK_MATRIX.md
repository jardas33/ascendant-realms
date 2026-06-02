# v0.106 Placeholder Fallback Matrix

Status: all 52 runtime art slots have current fallback owners and no required source asset.

| Group | Slots | Current fallback owner |
| --- | --- | --- |
| Main menu | `menu-background`, `logo-lockup`, `primary-button-frame` | `MainMenuScene`, `main-menu.css` |
| Campaign | `campaign-background`, `route-frame`, `chapter-banner`, `mission-node-frame`, `selected-node-frame`, `locked-node-frame` | `CampaignMapScene`, `campaign.css` |
| Battlefield terrain | `terrain-ground`, `terrain-road`, `terrain-water`, `terrain-ford`, `terrain-bridge`, `terrain-quarry`, `terrain-shrine`, `terrain-ruin` | `BattleSceneMapRenderer`, `CaptureSite` |
| Battlefield overlays | `fog-treatment`, `selection-ring`, `capture-ring-neutral`, `capture-ring-friendly`, `capture-ring-hostile`, `capture-ring-contested`, `objective-marker` | `FogPresentation`, `SelectionPresentation`, `CaptureSitePresentation`, `CaptureSite` |
| Minimap and Lume | `minimap-frame`, `minimap-marker-family`, `lume-endpoint`, `lume-link`, `lume-transition` | `MinimapView`, `minimap.css`, `LumeNetworkRendering` |
| Units | `barrosan-hero`, `barrosan-worker`, `barrosan-militia`, `barrosan-ranger`, `barrosan-acolyte`, `ashen-raider`, `ashen-brute`, `ashen-hexer`, `ashen-commander` | `Unit`, `PlaceholderBattlefieldPresentation` |
| Buildings | `barrosan-command-hall`, `barrosan-barracks`, `barrosan-shrine`, `barrosan-watchtower`, `barrosan-mine`, `construction-state` | `Building`, `PlaceholderBattlefieldPresentation` |
| UI frames | `hud-frame`, `command-panel-frame`, `results-frame`, `hero-frame`, `relic-frame`, `stronghold-frame`, `intel-frame`, `reputation-frame` | `HUD`, `ResultsScene`, `HeroProgressionScene`, `CampaignMapScene`, CSS frame styles |

## Review Mapping

Slots with relevant v0.105 reference IDs map to `src/game/art/visual-asset-registry.json` for future review context only. That mapping is not runtime approval.

Slots without a direct v0.105 reference remain `deferred-final-art-requirement` and fallback-only until a future review packet creates a source entry.

## Failure Posture

If an asset is missing, not reviewed, `runtime-candidate-approved`, in a candidate workspace, in `public/assets/final`, or not under `public/assets/runtime-art`, the adapter returns the current fallback and the validator reports the unsafe assignment.
