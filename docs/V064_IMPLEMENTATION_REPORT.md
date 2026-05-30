# v0.64 Reserve Management Implementation Report

## Summary

v0.64 clarifies Ready, Deployed, Recovering, and reserve Retinue states through the existing Campaign Map Retinue Camp. It avoids a new roster screen and keeps launch safe with zero selected Retinue units.

## Runtime Changes

- Added roster helpers that distinguish Ready, Recovering, deployed, and reserve Retinue units.
- Updated capacity breakdowns to show roster count, selected deployment count, Ready reserves, and Recovering count.
- Blocked Recovering units from deployment with readable copy.
- Preserved optional deploy/reserve toggles for Ready units only.
- Kept Retinue roster capacity separate from deployment capacity.

## UI Scope

- Existing Retinue Camp cards now show `Ready`, `Deployed`, or `Recovering (1 mission)`.
- Recovering cards show why deployment and reinforcement are blocked.
- Results recruitment still uses the same Retinue panel and shows roster/deployment counts.
- No giant roster UI, no paper-doll screen, no permanent control groups, and no deployment positioning editor were added.

## Verification Notes

- Campaign presentation tests cover recovering reserve readability and blocked deployment copy.
- Existing deploy/reserve hosted coverage remains in the deep-flow lane.
- Control groups, Patrol, Worker commands, hero progression, relics, and Act 1 telemetry remain in the required verification matrix.
