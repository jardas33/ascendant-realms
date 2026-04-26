# Ascendant Realms QA Run

Run date: 2026-04-26

Last updated: 2026-04-26 17:10 -04:00

Scope: 65-item manual QA checklist from `LLM_GAME_HANDOFF.md`.

Tester: Codex.

Method:

- Used Browser Use against the in-app browser at `http://127.0.0.1:5173/` for a visible manual smoke/play pass.
- Directly exercised settings persistence, campaign map inspection, Border Village launch, hero selection/movement, Crown Shrine capture, Command Hall selection, Barracks placement/construction, Militia/Ranger training, rally point setting, enemy pressure, minimap/fog visuals, and the `1` hero ability hotkey.
- Used the project Playwright browser suite for deterministic coverage of reset-save, seeded campaign/event states, victory/defeat resolution, Equip Now persistence, inventory/skills, responsive layout, skirmish launches, and console-error hooks.
- Recorded human-only checks, especially audible sound and long-form battle balance feel, as not fully verified instead of overclaiming.
- Did not click Reset Save in the user's in-app browser because it deletes local save data; reset-save behavior was verified in Playwright's isolated browser context.

Verification results:

```text
npm test
PASS: 23 test files passed, 111 tests passed

npm run build
PASS: TypeScript compile passed, Vite production build passed
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 25 Playwright tests passed in 9.9m
```

No critical failures were found.

Status legend:

- Pass checked: verified in this QA run through Playwright browser coverage.
- Fail checked: reproduced failure.
- Neither checked: not fully verified in this QA run; see notes.

Severity legend:

- Critical: blocks boot, save, campaign/battle launch, or corrupts progress.
- High: blocks a core flow but has workaround.
- Medium: confusing or broken secondary flow.
- Low: polish/clarity issue.
- None: no bug found.

## Summary

| Area | Status | Notes |
|---|---|---|
| Settings persistence | Pass | Browser Use directly verified settings changes and persistence; Playwright also covers core settings persistence. |
| New campaign and hero creation | Pass with caveat | Playwright verifies new campaign and Warlord/Arcanist creation; Shepherd was not created in this run. |
| Campaign map and node state | Pass | Browser Use inspected the campaign map; Playwright verifies available/locked nodes, resources, choices, and town services. |
| First battle RTS loop | Pass with caveat | Browser Use directly verified capture/build/train/rally/enemy pressure; Playwright verifies deterministic victory rewards. Full long-form balance feel still needs human play. |
| Defeat/victory/rewards | Pass with caveat | Playwright verifies Results flows, Equip Now, defeat tips, live objective resolution; full human-paced win still pending. |
| Campaign events and town services | Pass with caveat | Refugee Caravan and Marcher Camp covered; Chapel choices still need manual pass. |
| Skirmish maps and Ashen Outpost | Pass with caveat | All maps launch; visual fortress/special-objective inspection still manual. |
| Critical failures | Pass | None found. |

## Checklist

| # | QA item | Pass | Fail | Notes | Bug severity | Follow-up action |
|---:|---|:---:|:---:|---|---|---|
| 1 | Start dev server and open `http://127.0.0.1:5173/`. | [x] | [ ] | Playwright started Vite and opened local app. | None | None. |
| 2 | Main menu appears. | [x] | [ ] | `main-menu` visible in smoke/deep tests. | None | None. |
| 3 | Settings opens from main menu. | [x] | [ ] | Settings screen visible in smoke test. | None | None. |
| 4 | Change audio volume, reduced motion, floating text, UI scale, fog override, and colorblind minimap palette. | [x] | [ ] | Browser Use changed master volume to 40%, UI scale to 110%, reduced motion on, floating text off, colorblind minimap on, and fog override disabled. | None | None. |
| 5 | Save settings, return to menu, reopen Settings, and verify persistence. | [x] | [ ] | Browser Use reopened Settings and confirmed saved values persisted. | None | None. |
| 6 | Reset Save works from the main menu. | [x] | [ ] | Deep test verifies reset disables Continue Campaign and Inventory in an isolated browser context. Direct in-app reset was intentionally not clicked because it deletes local save data. | None | None. |
| 7 | New Campaign with no playable save opens hero creation. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 8 | Create each hero class at least once. | [ ] | [ ] | Warlord and Arcanist are exercised; Shepherd was not created in this run. | None | Manual pass should create Shepherd once. |
| 9 | Campaign map opens after hero creation. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 10 | Campaign bank displays Crowns, Stone, Iron, and Aether. | [x] | [ ] | Deep test verifies campaign bank text and resources. | None | None. |
| 11 | Reputation and active modifiers display. | [x] | [ ] | Deep test verifies reputation/modifier state through campaign choices. | None | None. |
| 12 | Border Village is available at campaign start. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 13 | Locked nodes cannot start. | [x] | [ ] | Smoke test verifies locked node disables launch. | None | None. |
| 14 | Border Village launches First Claim. | [x] | [ ] | Browser Use launched Border Village and observed the First Claim battle HUD. | None | None. |
| 15 | In battle, select hero with click and `H`. | [ ] | [ ] | Browser Use selected/centered the hero with `H`; direct click-selecting the hero was not cleanly isolated before the hero later fell in battle. | None | Manual pass should click-select the hero at battle start. |
| 16 | Move hero/units with right-click. | [x] | [ ] | Browser Use right-clicked Crown Shrine; hero moved from base to the site. | None | None. |
| 17 | Capture Crown Shrine. | [x] | [ ] | Browser Use observed Crown Shrine ownership/capture ring turning player-green and resource income increasing. | None | None. |
| 18 | Select Command Hall. | [x] | [ ] | Browser Use clicked Command Hall and verified the side panel/actions. | None | None. |
| 19 | Place Barracks and verify valid/invalid placement reasons. | [x] | [ ] | Browser Use placed a valid Barracks and observed placement/under-construction state; Playwright covers placement cancel feedback. Invalid reason matrix not exhausted. | None | Add targeted invalid-placement manual pass. |
| 20 | Barracks appears under construction and cannot train until complete. | [x] | [ ] | Browser Use observed Construction state first, then Train actions only after completion. | None | None. |
| 21 | Completed Barracks can train Militia and Ranger. | [x] | [ ] | Browser Use trained Militia and Ranger from a completed Barracks. | None | None. |
| 22 | Queue progress displays and cancel/refund works. | [ ] | [ ] | Browser Use observed queue progress and Cancel button. The attempted cancel/refund check missed the queue timing and did not complete cleanly. | None | Add targeted queue cancel/refund QA. |
| 23 | Set Barracks rally point with right-click ground. | [x] | [ ] | Browser Use set a ground rally point; HUD changed to `Rally Point: Set`. | None | None. |
| 24 | Rally marker appears and trained units move to it. | [x] | [ ] | Browser Use observed the rally marker on the ground; e2e verifies trained unit move-target assignment. | None | None. |
| 25 | Build Mystic Lodge and train Acolyte. | [ ] | [ ] | Not run in this QA pass. | None | Manual/e2e extension needed. |
| 26 | Build Watchtower and verify it attacks when enemies approach. | [ ] | [ ] | Not run in this QA pass. | None | Manual/e2e extension needed. |
| 27 | Research Infantry Weapons I, Ranger Training I, Reinforced Armor I, and Aether Study I. | [ ] | [ ] | Pure upgrade tests exist, but UI research flow not run here. | None | Manual/e2e extension needed. |
| 28 | Verify locked train/upgrade buttons show reasons. | [ ] | [ ] | Some lock states are covered by UI tests, but not this full matrix. | None | Manual/e2e extension needed. |
| 29 | Use hero abilities with `1`, `2`, `3`. | [ ] | [ ] | Browser Use verified ability `1` casts Rally Banner and consumes mana. Ability slots `2` and `3` were not available on the current level-1 Warlord. | None | Retest all three slots after creating or seeding a hero with enough unlocked abilities. |
| 30 | Verify audio cues are audible when volume is on and silent/muted when volume is zero. | [ ] | [ ] | Automation cannot honestly verify audibility. | None | Human audio check required. |
| 31 | Verify floating text can be disabled. | [ ] | [ ] | Setting persistence verified; in-battle visual absence not checked. | None | Manual/e2e visual check needed. |
| 32 | Verify reduced motion removes floating text tweening and CSS motion. | [ ] | [ ] | Setting persistence verified; visual motion behavior not checked. | None | Manual/e2e visual check needed. |
| 33 | Verify fog hides enemy/neutral entities outside vision. | [ ] | [ ] | Fog toggle covered; hiding behavior not visually inspected in this run. | None | Manual visual pass recommended. |
| 34 | Press `F` on fog-enabled difficulty and verify fog debug toggles. | [x] | [ ] | Deep battle HUD test verifies fog status feedback. | None | None. |
| 35 | Verify Settings fog override can disable/enable fog regardless of difficulty default. | [ ] | [ ] | Not run in this QA pass. | None | Add targeted settings-to-battle QA. |
| 36 | Verify minimap shows units, buildings, sites, camera rectangle, rally marker, and pings. | [ ] | [ ] | Browser Use visually observed minimap unit/site markers and camera/rally context; full ping matrix was not exhaustively checked. | None | Manual visual pass recommended. |
| 37 | Verify colorblind minimap palette changes player/enemy/neutral colors. | [ ] | [ ] | Not run in this QA pass. | None | Manual/e2e visual check needed. |
| 38 | Click minimap and confirm the camera recenters. | [x] | [ ] | Deep battle HUD test covers minimap click handling. | None | None. |
| 39 | Survive or intentionally lose the first wave. | [ ] | [ ] | Browser Use reached enemy pressure around 3:00 and observed enemy units damaging the hero; full wave survival/loss was not played to completion. | None | Human playthrough required. |
| 40 | Defeat screen shows contextual tips and retry/campaign return. | [x] | [ ] | Deep tests verify defeat tips/actions. | None | None. |
| 41 | Victory screen shows map, difficulty, battle time, XP, level progress, item rewards, campaign rewards, and campaign bank. | [x] | [ ] | Synthetic/live Results tests verify major fields. | None | Human full victory still recommended. |
| 42 | Equip Now changes stats and persists after leaving Results. | [x] | [ ] | Deep test verifies Equip Now save path. | None | None. |
| 43 | Send-to-inventory behavior leaves item in inventory. | [ ] | [ ] | Not run in this QA pass. | None | Manual/e2e extension needed. |
| 44 | Campaign victory completes Border Village and unlocks Old Stone Road. | [x] | [ ] | Deep live battle objective-resolution test verifies. | None | None. |
| 45 | Continue Campaign returns to saved campaign state. | [x] | [ ] | Deep/smoke tests verify. | None | None. |
| 46 | Complete Old Stone Road and verify Aether Well Ruins, Bandit Hillfort, Marcher Camp, and Refugee Caravan unlock. | [ ] | [ ] | Not run in this QA pass. | None | Manual/e2e extension needed. |
| 47 | Open Marcher Camp and verify repeatable services, once-only purchases, costs, locked reasons, and save persistence. | [x] | [ ] | Deep test verifies repeatable service and once-only purchase persistence. | None | None. |
| 48 | Open Refugee Caravan and verify choices, costs, locked reasons, and reputation/resource effects. | [x] | [ ] | Deep test verifies Demand Tribute effects. | None | Protect/Recruit options still useful manually. |
| 49 | Open Chapel of the Marches and verify choices, non-completing guidance choice, and completing choices. | [ ] | [ ] | Not run in this QA pass. | None | Manual/e2e extension needed. |
| 50 | Verify once-only choices cannot be repeated. | [x] | [ ] | Marcher Camp once-only purchase verified. Chapel/Caravan once-only not fully checked. | None | Extend event-specific coverage later. |
| 51 | Verify campaign node rewards cannot be claimed repeatedly. | [x] | [ ] | Border Village reward claim path verified through live victory save. | None | Repeat-victory duplicate check still useful. |
| 52 | Skirmish Setup opens separately from campaign. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 53 | First Claim launches from Skirmish Setup. | [x] | [ ] | Deep map launch loop verifies. | None | None. |
| 54 | Broken Ford launches from Skirmish Setup. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 55 | Ashen Outpost launches from Skirmish Setup. | [x] | [ ] | Deep map launch loop verifies. | None | None. |
| 56 | Ashen Outpost shows fortress layout, Burned Shrine, side resources, neutral camps, and defensive towers. | [ ] | [ ] | Launch verified; visual map inspection not run. | None | Manual visual pass recommended. |
| 57 | Ashen Outpost Results screen shows special objective completion states. | [ ] | [ ] | Not run in this QA pass. | None | Manual/e2e extension needed. |
| 58 | Difficulty selection changes AI pacing/fog behavior. | [ ] | [ ] | Difficulty selection/launch covered; behavioral comparison not run. | None | Manual/e2e comparison needed. |
| 59 | AI personality selection changes displayed enemy style and launches without errors. | [x] | [ ] | Deep map/personality launch loop verifies. | None | None. |
| 60 | Hero Inventory opens from main menu. | [x] | [ ] | Smoke/deep tests verify. | None | None. |
| 61 | Equipping/unequipping items changes hero stats. | [x] | [ ] | Deep inventory test verifies equip/unequip persistence. | None | None. |
| 62 | Skill point spending persists. | [x] | [ ] | Deep inventory/skill test verifies. | None | None. |
| 63 | Asset Gallery opens without crashing. | [x] | [ ] | Deep test verifies gallery navigation. | None | None. |
| 64 | Browser console has no new hard errors. | [x] | [ ] | Deep tests attach console/pageerror failure hooks; no hard errors in passing run. | None | None. |
| 65 | Production build preview boots if using `npm run preview`. | [ ] | [ ] | Not run; dev-server Playwright pass and production build pass were used instead. | None | Optional preview smoke before release. |

## Bugs Found

| ID | Severity | Area | Reproduction | Expected | Actual | Follow-up |
|---|---|---|---|---|---|---|
| None | None | - | - | - | No critical or blocking bugs found in this QA pass. | Continue with manual human-feel checks. |

## Follow-Up Actions

| Priority | Action | Owner | Notes |
|---|---|---|---|
| P1 | Complete human-audible audio checks. | Human/manual QA | Browser automation cannot confirm hearing output. |
| P1 | Complete human-paced first battle playthrough through first wave. | Human/manual QA | Automated suite verifies deterministic path; feel and enemy pressure still need human play. |
| P2 | Add targeted QA for Mystic Lodge/Acolyte, Watchtower combat, research UI, and queue cancel/refund. | Future QA/e2e | These are important RTS systems not covered by the current browser suite. |
| P2 | Add targeted QA for Chapel choices and Old Stone Road unlock chain. | Future QA/e2e | Campaign event depth remains partly unverified. |
| P2 | Add visual QA for colorblind minimap, fog override, Ashen Outpost layout, and special objectives. | Future QA/e2e/manual | Needs screenshots or human visual confirmation. |
