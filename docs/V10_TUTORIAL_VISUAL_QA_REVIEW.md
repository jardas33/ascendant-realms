# v0.10 Tutorial Visual QA Review

Date: 2026-05-11

Scope: review of Tutorial / Proving Grounds screenshots after v0.10 copy, overlay hierarchy, and completion clarity work.

This review uses `npm run visual:qa` output as human-review evidence. It is not a pixel-perfect regression baseline. It does not add art, replace runtime assets, change gameplay, change tutorial steps, add rewards, add persistence, or redesign the HUD.

## Visual QA Run

Command:

```bash
npm run visual:qa
```

Result:

- PASS, 1 Playwright visual QA capture test.
- 18 screenshots listed in `visual-qa/latest/index.md`.
- 0 browser console errors recorded.
- Tutorial desktop screenshot: `visual-qa/latest/tutorial-desktop.png`.
- Tutorial mobile screenshot: `visual-qa/latest/tutorial-mobile.png`.

## 1. Tutorial Desktop Observations

- The first objective now reads `Find Your Army`, which is clearer and more player-centered than the previous control-label framing.
- The overlay remains compact near the top-center and does not cover Aster, the Command Hall, the Crown Shrine, the hero panel, the selected-unit panel, resources, minimap, or core command buttons.
- The Next Objective button now reads as the primary action, while Exit Tutorial is still visible and reachable.
- The battlefield remains prototype-level visually, but tutorial instruction readability is adequate for v0.10.

## 2. Tutorial Mobile Observations

- The mobile screenshot remains dense, as expected: resources, Menu, overlay, minimap/objectives area, selected-unit panel, and hero panel all share a narrow viewport.
- The overlay is still visible, width-safe, and readable.
- The lower command/selected-unit panel consumes a large portion of the viewport, but it does not cover the tutorial overlay.
- The minimap/objectives area remains the main visual-density risk behind/near the tutorial overlay. This is a known mobile HUD density issue, not a new v0.10 regression.

## 3. Overlay Readability

- The slightly stronger panel opacity helps the instruction text stand off from the battlefield.
- The title, instruction, hint, condition, and buttons remain scannable.
- The overlay still uses one compact surface and avoids adding extra tutorial banners or modal panels.

## 4. Button Clarity

- Next Objective / Complete Tutorial is now the primary tutorial action.
- Exit Tutorial remains visible as an escape action without competing as strongly with forward progress.
- The responsive layout test still verifies both buttons are reachable on desktop, tablet-short, mobile-tall, and mobile-short.

## 5. Command-Panel Overlap Risk

- Desktop: no visible command-panel overlap.
- Mobile: command/selected-unit panel is large, but the tutorial overlay sits above it and remains readable.
- Existing layout coverage checks the battle command panel remains within viewport width after tutorial launch.

## 6. Battle-Feedback Overlap Risk

- The tutorial overlay still renders above battle-status feedback.
- Existing layout coverage checks the overlay z-index is explicit and higher than battle status feedback.
- No screenshot evidence suggests a renewed battle-feedback collision.

## 7. No-Reward Completion Visibility

The visual QA harness captures tutorial launch, not the final completion state. No-reward completion visibility is covered by smoke e2e and documentation rather than screenshot QA in v0.10.

Future screenshot QA may add a completion-state capture if the tutorial gains a dedicated completion panel. For the current session-only main-menu notice, smoke e2e is the right coverage.

## 8. Remaining Visual Issues

- Mobile battle HUD density remains the largest tutorial visual issue.
- The selected-unit panel and hero panel are still prototype-heavy and text-heavy.
- The battlefield still depends on labels, health bars, rings, and UI overlays for readability.
- No runtime art has been replaced; visuals remain prototype-level until a later source/license-safe art phase.

## 9. Further Visual Change Decision

No further visual change is justified in v0.10.

The copy and hierarchy work is visible, tests pass, and screenshots show no new overlap problem. Further mobile HUD changes would become a broader UI pass and should wait for a separate scoped goal with full responsive design review.

