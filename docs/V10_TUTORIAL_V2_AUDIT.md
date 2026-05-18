# v0.10 Tutorial v2 Audit

Date: 2026-05-11

Scope: Tutorial / Proving Grounds onboarding review before v0.10 changes.

This audit evaluates the current playable tutorial as a player-facing onboarding surface. It does not add maps, units, factions, rewards, save persistence, campaign progression, runtime art, generated art, or new gameplay systems.

## Current State

- Tutorial id: `proving_grounds_basics`.
- Launch: main-menu `Tutorial` button into battle mode on the existing `first_claim` map.
- Reward policy: `noReward: true`; tutorial launch requests disable rewards.
- Persistence policy: no localStorage save, no campaign node completion, no tutorial-completed save flag.
- Step count: 12 linear steps.
- Coverage: unit tests for metadata/view-model/panel rendering, smoke e2e for full completion plus exit/no-save behavior, layout e2e for first-overlay viewport safety, visual QA desktop/mobile tutorial screenshots.

## Step Inventory

1. Camera Controls.
2. Select Hero.
3. Move Hero.
4. Capture Crown Shrine.
5. Gather Resources.
6. Select Command Hall.
7. Build Barracks.
8. Train Militia.
9. Set Rally Point.
10. Use Hero Ability.
11. Hold Safe Pressure.
12. Finish Training.

The order teaches the intended RTS/RPG loop: orient, select, move, capture, gather, build, train, rally, use hero power, survive pressure, and leave without rewards.

## Findings

### 1. Tutorial Length

The tutorial is twelve steps long. That is acceptable for a complete first playable shell, but it is near the upper bound for a first-contact tutorial because capture income, construction, training, and pressure all include waiting or setup time.

v0.10 should avoid adding steps. Copy tightening is safer than expanding the sequence.

### 2. Number Of Steps

All twelve steps map to meaningful existing verbs. None should be removed before human play because the current smoke path also protects no-save/no-reward behavior across the full loop.

No step split is required. A split would make the tutorial longer. A merge is possible only if future human play proves building/training/rally are too slow, but v0.10 should preserve the current step IDs and order.

### 3. First 30 Seconds

The first step is safe: it teaches camera controls, H for hero selection, Space to recenter, and does not block battle controls. It is automatically complete, so the player can proceed quickly.

Risk: the player may not immediately understand why camera and selection matter before combat. A slightly more purposeful first-step instruction can frame the tutorial as "keep Aster in view, then issue orders" without changing mechanics.

### 4. Camera, Selection, And Movement Instructions

Current instructions are understandable and short. Selection and movement are separated, which is good for new RTS players.

Risk: "road ahead" depends on the player's camera context. v0.10 copy can say "near the road" and remind that right-click orders only affect selected units.

### 5. Capture-Site Teaching

Capture-site teaching is clear enough: move hero and soldiers into the Crown Shrine ring until it turns green. It uses the safest existing First Claim opening and references the existing `crown_shrine`.

Risk: the strategic reason for capturing is mostly implied. v0.10 can explicitly connect the shrine to temporary battle income before the resource step.

### 6. Resource Explanation

The resource step correctly says Crowns are battle resources, not campaign-bank rewards. This is important because the tutorial is no-reward and non-persistent.

Risk: "battle resources" may still be abstract. v0.10 can use one short "spend them during this battle" phrase while keeping no-reward policy explicit later.

### 7. Building, Training, And Rally Density

These three steps are dense because they teach Command Hall selection, Barracks placement, completed construction, Militia training, and rally behavior in sequence.

The split is still justified: each step has a distinct verb and a distinct test/completion signal. v0.10 should keep the split but sharpen hints so players know what to select and what to expect after timers finish.

### 8. Hero Ability Safety And Usefulness

The Rally Banner step is safe because it uses an existing Warlord ability and does not add a class, unit, item, or reward. It is useful because it introduces mana/cooldown language before pressure.

Risk: "cast Rally Banner, or press 1" does not explain that hotkeys depend on Aster being selected. v0.10 copy can make that dependency explicit.

### 9. Enemy Pressure And Defeat Risk

The safe-pressure step is intentionally small. It teaches that grouped forces are safer than rushing alone, and smoke coverage verifies it grants no XP in tutorial mode.

Risk: if a human player is slow, pressure can feel like a sudden exam after several UI steps. v0.10 should keep the pressure behavior unchanged and make the instruction calmer: group up, let Aster and Militia fight together, and do not chase alone.

### 10. No-Reward Completion Satisfaction

The current final line is clear but plain: "Training complete. No rewards: no XP, items, resources, or campaign progress were granted." The main menu notice repeats that nothing was saved.

Risk: the end may feel administrative instead of satisfying. v0.10 can make it warmer while preserving the exact no-XP/no-items/no-resources/no-campaign-progress/no-save clarity.

### 11. Exit Tutorial Clarity

Exit Tutorial is always visible and has an explicit accessible label: "Exit Tutorial and return to main menu." Smoke coverage verifies exit returns to menu without saving and does not show the completion notice.

This should remain unchanged except for possible visual hierarchy polish.

### 12. Mobile And Tablet Overlay Readability

The overlay is width-safe on desktop, tablet-short, mobile-tall, and mobile-short viewports. It is intentionally above battle status feedback. Visual QA captures desktop and mobile tutorial launch.

Known risk remains mobile density: the lower selected-unit/command panel and resource rows consume a large share of the screen. v0.10 may justify a small overlay hierarchy/spacing pass, but it should not redesign the HUD.

### 13. E2E Lane Placement

Smoke currently includes full tutorial completion because it protects the first onboarding vertical slice and no-save/no-reward behavior. Release and shard lanes inherit that coverage.

This remains useful while smoke stays inside the current watch band. Phase 6 should review runtime after copy/layout changes, but should not remove coverage. If smoke later grows beyond the 6-7 minute watch band, keep launch/exit in smoke and move full completion deeper.

### 14. What Still Requires Human Play

Automated tests prove launch, layout bounds, step progression, no-save behavior, no-XP behavior, and screenshot capture. They do not prove:

- whether twelve steps feel too long at human speed;
- whether a first-time player understands capture income before building;
- whether Barracks placement and training are obvious without test hooks;
- whether mobile input feels comfortable;
- whether the no-reward ending feels acceptable;
- whether the safe-pressure step feels fair when the player is reading slowly.

## v0.10 Audit Decision

Proceed with a conservative Tutorial v2 refinement:

- Keep the existing map, units, factions, systems, step order, save policy, and no-reward policy.
- Prefer copy/hint refinement over step restructuring.
- Consider a tiny overlay readability pass only if it preserves current layout tests and visual QA.
- Keep full tutorial completion covered unless Phase 6 shows a real runtime problem.
