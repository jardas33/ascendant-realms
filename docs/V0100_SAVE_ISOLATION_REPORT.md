# v0.100 Save Isolation Report

## Summary

The Private Playtest Hub is isolated from persistent progression. It is a manual QA launcher for private packages and dev builds only.

## Mechanism

- `beginPrivatePlaytestHubSession()` captures the raw save string from the existing save key before preview scenarios.
- `restorePrivatePlaytestHubSave()` writes that raw value back, or removes the key if no save existed.
- `resetPrivatePlaytestHubSession()` restores the snapshot and clears the in-memory hub snapshot.
- Campaign, Hero Progression, Results, and Battle scenes receive `privatePlaytestHub` or `privatePlaytestHubScenarioId` and route back to the hub after restoring the snapshot.

## Runtime Write Boundaries

- Campaign previews call `saveGameIfAllowed()` and `saveCampaignIfAllowed()`, which skip writes during hub previews.
- Hero Creation skips the campaign-start save when launched by the hub.
- Hero Progression skips progression saves when launched by the hub.
- Results skips hero/campaign/Retinue saves when launched by the hub.
- Battle launches from the hub set `rewardsDisabled` and do not run as normal reward acquisition paths.

## Protected State

- Hero XP and level.
- Campaign completion and unlocks.
- Node reward claim state.
- Relic inventory and equipment.
- Retinue deployment, reserve, recovery, loss, and reinforcement state.
- Reputation.
- Save version and stable IDs.

## Replay And Tutorial

- Tutorial launches remain `mode: tutorial`.
- Tutorial hub previews do not become reward-eligible.
- Replay previews are display fixtures only and do not claim first-clear or optional-objective rewards.

## Evidence

- Unit tests cover private-only posture and isolated launch fixtures.
- E2E smoke opens representative hub scenarios and compares the raw save string after each return to the hub.
- Package validation requires the v0.100 docs and private tools flag in packaged builds.
