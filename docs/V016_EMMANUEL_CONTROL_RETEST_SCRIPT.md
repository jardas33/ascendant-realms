# v0.16 Emmanuel Control Retest Script

Date: 2026-05-19
Build focus: v0.15 behaviour modes plus v0.16 automated confidence hardening
Expected build: private package generated from `Checkpoint v0.16 behaviour mode gauntlet and playtest diagnostics`

## Purpose

Use this script to retest the RTS control layer after v0.15/v0.16. This is a manual feel and regression check. Automated labs can show repeatable control contracts, but they cannot prove readability, feel, or fun.

## 10-Minute Quick Retest

1. Start Tutorial / Proving Grounds or a simple First Claim skirmish.
2. Select the hero or one controllable unit.
3. Confirm the side panel shows `Guard Area` by default.
4. Switch to `Hold Ground` and confirm the side panel/order copy updates.
5. Hover a visible enemy and confirm attack intent appears.
6. Left-click the enemy and confirm the selected unit receives an attack order.
7. Right-click away from combat and confirm the unit visibly retreats or repositions.
8. Switch to `Press Attack` and confirm the copy changes.
9. Drag-select across the side HUD/minimap, then press `H` and confirm the hero panel is not stale.
10. Complete Tutorial once, then lose or retry Tutorial once if time allows.

Record any snap-back loop, idle melee contact, stale HUD, unclear mode copy, or attack cursor mismatch.

## 30-45 Minute Deeper Retest

Follow the Baseline Cautious route from the private playtest packet.

1. Run one normal skirmish/control check with the hero and at least one group of units.
2. Confirm `Guard Area` is the default for newly selected units.
3. Test `Hold Ground` with a distant enemy and an enemy already in contact.
4. Test `Guard Area` against a nearby threat.
5. Test `Press Attack` against a target that is close enough to pursue but not across the whole map.
6. Issue explicit attack orders in each mode and confirm they still override the mode.
7. Issue repeated move-away/retreat commands from combat and watch for snap-back.
8. Stress attack intent by moving the pointer on and off enemies before clicking.
9. Stress HUD/minimap by using mode buttons, minimap movement, drag-select over HUD/minimap, and `H` hero select.
10. Complete Tutorial and lose/retry Tutorial to confirm the no-save/no-reward Results flow still works.

## High-Priority Watch Items

- Repeated snap-back after move-away.
- Melee unit idling beside a hostile target without a clear Hold Ground reason.
- Attack cursor missing on a valid visible enemy with a controllable unit selected.
- Left-click enemy selecting/doing nothing when it should attack.
- HUD stuck at `No Selection` after minimap/HUD interaction or `H`.
- Tutorial win/loss leaving the no-save/no-reward Results route.

## Notes To Capture

- Session id.
- Build commit.
- Route.
- Mode selected.
- Selected unit or group.
- Enemy type.
- Exact command used.
- Expected result.
- Actual result.
- Whether the issue reproduced.
- Screenshot or video if possible.
