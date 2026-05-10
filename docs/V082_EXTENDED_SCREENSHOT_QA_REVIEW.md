# v0.8.2 Extended Screenshot QA Review

Date: 2026-05-10  
Scope: review of the expanded `npm run visual:qa` capture set after the v0.8.2 screenshot harness expansion.

## Purpose

This review records what the broader screenshot set shows about Ascendant Realms' current visual state. It is evidence for future art direction, UI/layout review, and source/license risk management. It is not a graphics overhaul and does not approve any current asset as final or production-safe.

No gameplay, map, unit, faction, reward, campaign progression, save schema, pressure behavior, renderer behavior, art asset, generated image, downloaded image, or external asset changed in this phase.

## Capture Run

Command:

```bash
npm run visual:qa
```

Result:

- PASS, 1 Playwright visual QA test.
- Runtime: about 3.5 minutes.
- 18 screenshots listed in `visual-qa/latest/index.md`.
- Browser console errors: none recorded.
- Screenshot output remains ignored by git under `visual-qa/`.

The folder can contain older ignored artifacts from prior manual preview smoke runs. The generated `index.md` is the authoritative list for this review.

## Screenshots Captured

| Screenshot | Viewport | Review Target |
| --- | --- | --- |
| `main-menu-desktop.png` | 1440x900 | Main menu desktop presentation |
| `asset-gallery-desktop.png` | 1440x900 | Asset Gallery and image-load status |
| `main-menu-tablet.png` | 1024x768 | Main menu tablet composition |
| `main-menu-mobile.png` | 390x844 | Main menu mobile crop/scroll |
| `hero-inventory-desktop.png` | 1440x900 | Hero Inventory, equipment, stats, item text |
| `tutorial-desktop.png` | 1440x900 | Tutorial / Proving Grounds launch |
| `tutorial-mobile.png` | 390x844 | Tutorial overlay plus mobile battle HUD density |
| `campaign-map-desktop.png` | 1440x900 | Post-Ashen Cinderfen route availability |
| `campaign-route-complete-desktop.png` | 1440x900 | Completed Cinderfen route state |
| `skirmish-setup-desktop.png` | 1440x900 | Skirmish setup |
| `cinderfen-crossing-desktop.png` | 1440x900 | Cinderfen Crossing launch |
| `cinderfen-crossing-tablet.png` | 1024x768 | Tablet battle HUD density |
| `cinderfen-crossing-shrine-desktop.png` | 1440x900 | Cinder Shrine after capture |
| `cinderfen-crossing-pressure-desktop.png` | 1440x900 | Crossing pressure-warning state |
| `results-victory-desktop.png` | 1440x900 | Cinderfen Crossing victory Results |
| `cinderfen-watch-desktop.png` | 1440x900 | Cinderfen Watch launch |
| `cinderfen-watch-pressure-desktop.png` | 1440x900 | Watch pressure-warning state |
| `results-defeat-desktop.png` | 1440x900 | Cinderfen Watch defeat Results and tips |

## Console Errors

None recorded by the visual QA harness.

## Main Menu Observations

Classification: `acceptable-for-prototype`, `needs-source-review`, `needs-art-pipeline`.

- Desktop, tablet, and mobile menu screenshots remain readable.
- The title screen communicates a fantasy prototype clearly enough for current QA.
- The background and frame style still carry more atmosphere than the battlefield visuals, increasing the visual mismatch between menu and gameplay.
- Mobile menu coverage remains useful; no obvious crop or first-screen navigation failure appeared.
- Source/license status remains conservative and must not be treated as production-safe until external/user evidence exists.

## Campaign Map Observations

Classification: `acceptable-for-prototype`, `needs-ui-style-direction`.

- The post-Ashen campaign map remains operationally readable: hero, resources, route, selected node, and Stronghold information are visible.
- The route-complete screenshot clearly shows `Cinderfen route secured.` and the selected `Cinderfen Aftermath` node state.
- Information density is high but coherent on desktop.
- This screen still reads as a data-rich prototype dashboard rather than a final campaign presentation.
- The campaign-map background and frame reuse helps consistency, but future UI art direction should decide whether the campaign map needs a more map-like visual identity.

## Tutorial Observations

Classification: `acceptable-for-prototype`, `needs-mobile-density-review`.

- Desktop tutorial launch remains readable; overlay, resources, objective, minimap, selected units, and command panel are visible.
- Mobile tutorial capture is now the most useful warning sign: the overlay fits, but the lower selected-unit/command panel consumes a large share of the screen.
- Resource chips wrap into two rows on mobile, which is functional but visually dense.
- The tutorial overlay does not visibly collide with the bottom command panel, and it still presents the next step clearly.
- Future tutorial/UI work should treat mobile as a readability pass, not as evidence for immediate mechanics changes.

## Battle HUD Observations

Classification: `acceptable-for-prototype`, `needs-readability-review`, `needs-art-pipeline`.

- Desktop and tablet Cinderfen battle screenshots remain playable and semantically clear.
- The tablet battle view is crowded: objectives at left, minimap at upper right, selected-unit panel at right, and hero panel at bottom all compete with the battlefield.
- The playfield is still visible, and the major HUD panels do not create an obvious blocking bug.
- Unit labels, health bars, selection rings, and objective text carry most readability.
- The current HUD is useful for QA and systems development, but it is too text-heavy to be a final visual target.

## Cinderfen Crossing Observations

Classification: `acceptable-for-prototype`, `needs-art-pipeline`, `needs-capture-site-identity`.

- Cinderfen Crossing launch, tablet battle, shrine capture, and pressure-warning states all captured successfully.
- The Cinder Shrine is readable because of the large ring, label, icon, and objective text.
- The Cinder Shrine still does not read as a memorable place or landmark; it is primarily a UI ring and icon.
- The delayed pressure warning is readable in the top status surface.
- The same pressure copy also appears as floating battlefield text near active combat, which reinforces noticeability but adds to mid-screen label clutter.
- Roads, marsh water, fog, and terrain material remain the largest visual debt: they are readable as lanes/zones but still look like placeholder paint.

## Cinderfen Watch Observations

Classification: `acceptable-for-prototype`, `needs-art-pipeline`.

- Cinderfen Watch launch and pressure-warning screenshots remain readable.
- Watch Road pressure is visible and does not disappear behind generic status text in the captured state.
- The current Watch Road still relies on ring/icon/label treatment more than environmental identity.
- The screenshot remains useful as a pressure-warning QA target and as evidence for future route/capture-site art.

## Results Observations

Classification: `acceptable-for-prototype`, `needs-scroll-and-density-review`.

- Victory Results are readable in the first viewport and show battle summary, XP, and notable veterans clearly.
- Defeat Results are readable and show practical retry guidance in the first viewport.
- The defeat screenshot successfully captures the tip surface and action chips, which were missing from v0.8.1 coverage.
- Results content is dense; lower rewards/action sections may sit below the first viewport depending on outcome and reward data.
- Future Results work should preserve the current clarity while reducing the sense of stacked report panels.

## Inventory / Asset Gallery Observations

Classification: `acceptable-for-prototype`, `needs-source-review`, `needs-ui-density-review`.

- Hero Inventory opens and shows stats, equipment, inventory item copy, and skill points without crashing.
- The inventory item card text is dense; its lower content can be below the first viewport, which is acceptable for now but not final.
- Asset Gallery loads and reports `62/62 assets found`; visible cards show image-loaded state.
- The gallery is a useful source/license review surface, but it currently only reviews visual availability and does not expose v0.8.2 manifest source-review metadata.
- Future gallery work could add manifest review status filters, but that would be a UI feature and should be scoped separately.

## Mobile / Tablet Observations

Classification: `acceptable-for-prototype`, `needs-mobile-ui-review`.

- Mobile menu remains usable.
- Mobile tutorial is playable-looking but dense; the bottom HUD takes much of the screen after selecting units.
- Tablet battle remains readable but crowded, especially with objective panel, minimap, selected units, and hero panel all visible.
- No immediate layout bug justifies a v0.8.2 CSS patch.
- Mobile battle should be a visual-risk register item before future art or HUD work.

## Highest-Priority Visual Problems

1. Cinderfen terrain material ambiguity: roads and water/swamp are readable but too placeholder.
2. Capture-site identity: Cinder Shrine and Watch Road depend on rings, icons, labels, and status text.
3. Text-heavy HUD identity: useful for tests, too dense for final visual feel.
4. Mobile battle HUD density: functional but crowded.
5. Source/license uncertainty: current images remain prototype-only unless proof is supplied.
6. Unit/building/terrain style mismatch: tactical readability exists, production coherence does not.

## Safe Prototype Issues

- Current labels, rings, health bars, and minimap markers are acceptable for systems QA.
- Results and inventory density is acceptable for a prototype as long as the screens remain scrollable and semantically tested.
- The visual QA harness remains optional and review-oriented.
- No pixel-perfect screenshot baseline should be created yet.

## Issues Requiring Real Art Or Assets

- Cinderfen terrain, road, marsh, and water identity.
- Cinder Shrine/capture-site landmark art.
- Watch Road place identity.
- Unit and building style normalization.
- Final menu/campaign background direction.
- UI frame/icon consistency after license/source review.

## Issues Requiring Future UI/Layout Work

- Mobile battle HUD density.
- Results panel information hierarchy and first-viewport action visibility.
- Inventory item-card density and compare/equip readability.
- Asset Gallery filtering or metadata surfacing if source/license review becomes a recurring manual task.

## Potential Blockers For Future Visual Sprint

- Unknown-source runtime assets cannot be promoted to production.
- Placeholder assets may be mistaken for final if docs and manifest metadata are ignored.
- Screenshot QA output can contain older ignored files; the generated index must remain the source of truth.
- A future art sprint should not replace runtime visuals without manifest updates, source/license notes, validation, and before/after screenshot review.

## Decision

No visual code, CSS, renderer, asset, gameplay, map, reward, pressure, save, or campaign change is justified by this review.

The expanded screenshot set is doing the right job: it broadens evidence, confirms zero console errors, and makes the future visual backlog sharper without pretending the current art is final.
