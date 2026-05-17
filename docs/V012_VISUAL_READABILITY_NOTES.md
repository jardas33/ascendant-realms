# v0.12 Visual Readability Notes

Date: 2026-05-16

Scope: Phase 6 note for the v0.12 Core Game Feel and Battle Readability Pass. This is visual QA awareness for HUD/readability changes, not an art overhaul.

## What Got Better

- Objective tracker now marks the first unfinished objective as `Next`, with a warmer left rail and row treatment so the player can scan the immediate action faster.
- Selected group state now starts with a compact selected-count block and the phrase `Commands apply to this group.`
- Multi-unit order summaries now use `Current Orders`, making movement/attack/guarding state easier to identify in the side panel.
- Order summaries gained slightly stronger color, weight, and spacing without changing panel structure or selectors.
- Command acknowledgement messages now survive routine income ticks longer, so accepted commands are easier to catch in the existing status line.
- Pressure warnings now include counterplay verbs such as hold, regroup, break the next wave, and push, without adding new warning art or mechanics.

## Still Ugly / Prototype-Level

- Selection rings are still the existing simple ground ellipse. They are clearer through side-panel/status support, not new art.
- Destination markers and attack lines remain minimal; there is no new command-marker art.
- Floating damage text still uses the existing threshold and can stack in dense fights.
- Fog, raised-road, shrine, tower, marsh, and fortress landmarks still depend heavily on map layout and labels.
- Minimap marker families remain small and textless visually, with labels mainly available through existing accessibility/DOM structure.
- Results screens still rely on current UI panels and background assets.

## Must Wait For The Future 2026 Art Overhaul

- Runtime terrain replacement, Cinderfen marsh/road/water art, shrine landmark art, tower silhouettes, and fortress material language.
- New generated/imported art, icon sets, minimap art, destination markers, animated selection rings, projectile VFX, hit flashes, status icons, and portraits.
- Any runtime art replacement pipeline work. v0.12 intentionally does not start the Cinderfen visual overhaul.

## Visual QA Status

Final `npm run visual:qa` passed: 5 tests, 18 screenshots across menu/gallery/inventory, tutorial, campaign/skirmish, Cinderfen Crossing, and Cinderfen Watch, with 0 browser console errors and 0 screenshot retries. If screenshots show future layout regressions, fix spacing/hierarchy with existing CSS and keep runtime art unchanged.
