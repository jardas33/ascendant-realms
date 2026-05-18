# v0.14.3 Emmanuel Retest Intake

Date: 2026-05-18  
Session: PT-20260518-EMMANUEL-BASELINE-01 retest  
Tester: Emmanuel  
Route: Baseline Cautious Route retest from the v0.14.x private playtest build  
Baseline commit inspected: 029a1c730d03ede1e126a8da5ffce3c88eccba93

## Guardrails

- Use only Emmanuel's stated retest notes and existing automated evidence.
- Do not invent additional tester feedback.
- Do not change gameplay numbers unless a tiny, localized value is proven necessary.
- Do not add maps, factions, units, runtime art, or save-format changes.
- Do not copy protected RTS UI, names, icons, layout, lore, art, or text.
- Prefer targeted combat, input, tutorial, and clarity fixes with regression tests.

## Confirmed Fixed

| Item | Retest Result | Classification | Action |
| --- | --- | --- | --- |
| Hero rename accepts W/A/S/D | Fixed | v0.14.1 control bug retest pass | Keep coverage. |
| Tutorial Next Objective advances | Fixed | v0.14.1 tutorial control retest pass | Keep smoke coverage. |
| Hover flicker | Fixed | UI hover polish retest pass | No further action in this pass. |
| Hero skill explanation exists | Fixed | Clarity retest pass | Preserve copy. |
| Menu/pause behavior | Fixed | Pause/menu retest pass | Preserve pause flow and assertions. |

## Still Broken Or Partially Broken

| Item | Evidence | Category | Severity | Priority | Planned Action | What Not To Do |
| --- | --- | --- | --- | --- | --- | --- |
| Marquee drag selection broken | Rectangle can be drawn, but units inside are not selected; direct clicks still work. | Actual bug / control regression | High | P1 | Fix drag-release handling so world selection completes even when release crosses HUD, while stuck marquee cleanup remains. | Do not switch to DOM fallback for canvas selection. |
| Melee units idle beside enemies | Hero, Stone Imp, and possibly melee troops can stand adjacent with no combat; ranged units seem to attack correctly. | Combat engagement bug | High | P1 | Audit melee range/contact math and stale move-order suppression; add tests that adjacent hostile melee units deal damage. | Do not do broad combat rebalance or rewrite. |
| Retreat command inconsistent | Hero/troops sometimes obey, sometimes stay stuck in combat. | Command/control issue | High | P1/P2 | Add a short explicit player move-away intent so normal move orders interrupt immediate reacquisition but do not make retreat invincible. | Do not make units immune or trivialize combat. |
| Unit teleport/snap-back loop | Not seen in retest, maybe fixed. | Regression guard | Medium | P2 | Keep or strengthen movement tests to guard against repeated command position reset. | Do not rewrite pathfinding without a reproduced bug. |
| Tutorial defeat dumps to main menu | Losing tutorial returns directly to menu without useful defeat/result feedback. | Results/guidance issue | Medium | P2 | Route tutorial defeat through a no-save/no-reward results screen with Retry Tutorial and Main Menu. | Do not create campaign saves or rewards. |
| Hero class/origin lacks mechanical explanation | Choices do not explain strengths, weaknesses, or what stats/abilities change. | Clarity/readability issue | Medium | P2 | Add concise mechanical descriptions from actual class/origin data. | Do not invent mechanics that do not exist. |
| Unit info panel weak | It works, but is visually/structurally weak. | UI readability debt | Low | P3 | Only add small order/status copy if touched by combat fix; defer larger layout pass. | Do not start visual overhaul. |
| Unit behaviour modes desired | Player wants hold/defensive/aggressive/patrol-style orders. | Future controls/system feature | Medium | Design only for now | Create original stance-mode design doc; implement only if very small and safe. | Do not copy protected games or expand scope. |

## Initial Priority

1. Restore marquee selection without reintroducing stuck rectangles.
2. Fix melee adjacent engagement and make retreat intent reliable.
3. Preserve the movement snap-back guard.
4. Improve tutorial defeat handling.
5. Add class/origin mechanical explanations.
6. Document original behaviour modes for a future pass.

