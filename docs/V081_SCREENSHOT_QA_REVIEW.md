# v0.8.1 Screenshot QA Review

Date: 2026-05-10  
Scope: review of the first generated visual QA capture set from `npm run visual:qa`.

## Purpose

This review documents what the optional screenshot QA harness captured and what the images show about the current visual state of Ascendant Realms. It is evidence for future art and readability work, not a graphics overhaul.

No gameplay, map, unit, faction, reward, save, campaign progression, enemy pressure behavior, renderer behavior, UI redesign, art asset, generated image, or external asset changed in this phase.

## Capture Run

Command:

```bash
npm run visual:qa
```

Result:

- PASS, 1 Playwright visual QA test.
- 10 screenshots captured.
- Generated index: `visual-qa/latest/index.md`.
- Browser console errors: none recorded.
- Screenshot output is ignored by git via `/visual-qa/`.

The screenshots are review artifacts only. They are not pixel-perfect baselines and should not be treated as approval for final art quality.

## Screenshots Captured

| Screenshot | Viewport | Review Target |
| --- | --- | --- |
| `main-menu-desktop.png` | 1440x900 | Main menu desktop presentation |
| `main-menu-tablet.png` | 1024x768 | Main menu tablet composition |
| `main-menu-mobile.png` | 390x844 | Main menu mobile crop/scroll |
| `tutorial-desktop.png` | 1440x900 | Tutorial / Proving Grounds launch |
| `campaign-map-desktop.png` | 1440x900 | Post-Ashen campaign map |
| `skirmish-setup-desktop.png` | 1440x900 | Skirmish setup |
| `cinderfen-crossing-desktop.png` | 1440x900 | Cinderfen Crossing launch |
| `cinderfen-crossing-shrine-desktop.png` | 1440x900 | Cinder Shrine after capture-site hook |
| `cinderfen-watch-desktop.png` | 1440x900 | Cinderfen Watch launch |
| `cinderfen-watch-pressure-desktop.png` | 1440x900 | Watch pressure warning visible |

## Main Menu Findings

Classification: `acceptable-for-prototype`, `needs-manifest-review`, `needs-art-pipeline`.

Observed:

- The main menu is readable and visually coherent enough for the current prototype.
- The large background gives stronger atmosphere than the battlefields, but it also heightens the style mismatch with current battlefield art.
- The old-metal frame and button stack are functional, but they do not yet form a final original UI language.
- Disabled actions are visually obvious.
- The mobile menu capture is useful because it confirms the title/menu stack remains reviewable in a narrow viewport.

Asset linkage:

- Background and UI frame assets are manifest-tracked and should remain source/license review items before any production claim.
- This finding links to `main_menu_background`, UI-kit frame entries, and the future UI style targets in `docs/ART_DIRECTION_2026_BIBLE.md`.

## Campaign Map Findings

Classification: `acceptable-for-prototype`, `needs-art-pipeline`.

Observed:

- The campaign map is clear as an operational screen.
- The post-Ashen seeded state shows Cinderfen route guidance, hero summary, campaign bank, Stronghold panel, and selected node details.
- Information density is high but manageable on desktop.
- The screen is function-first and not visually final. It reads more like a structured prototype dashboard than a premium campaign map.
- The background and UI frame are consistent with the main menu, which helps, but the panel stack still lacks a distinctive final campaign-map identity.

Asset linkage:

- Campaign UI uses manifest-tracked screen/UI assets plus DOM/CSS layout.
- Future work should use screenshot QA to protect readability before replacing UI frames or backgrounds.

## Tutorial Findings

Classification: `acceptable-for-prototype`, `needs-art-pipeline`.

Observed:

- Tutorial overlay is readable and does not hide the core base area.
- Resource bar, objective instruction, minimap, hero panel, and command panel are all visible.
- The Crown Shrine is extremely readable because of the large ring and icon, but the object itself is symbolic rather than environmental.
- Unit and building labels carry most of the identity load.
- The scene still looks like a prototype battlefield with useful overlays rather than a cohesive world.

Asset linkage:

- `procedural_battle_terrain` remains the critical visual debt entry.
- Capture-site icon/ring style should be reviewed against `crown_shrine_icon` and future capture-site landmark standards.

## Cinderfen Crossing Findings

Classification: `acceptable-for-prototype`, `needs-readability-review`, `needs-art-pipeline`.

Observed:

- Roads, water/swamp, capture rings, minimap, and objectives are readable.
- The Cinder Shrine capture view confirms the shrine route is understandable in screenshot form.
- The Cinder Shrine Surge status is visible, and the player can see that the capture objective completed.
- Status text, unit labels, capture-site labels, and combat labels cluster heavily around the shrine moment.
- The most serious issue is visual language, not one broken constant: roads still look like painted lanes, water looks blob-like, and capture sites are mostly UI rings.
- Cinder Shrine salience is currently carried by ring/icon/status text instead of landmark art.

Decision:

- No visual code change is justified in v0.8.1.
- The clustered shrine moment should become a future review target after Cinderfen terrain and capture-site art direction exists.

Asset linkage:

- `procedural_battle_terrain`: critical replacement priority.
- `crown_shrine_icon`: high replacement priority.
- Player unit sprites, enemy raider/brute/hexer sprites, and `enemy_stronghold_building_sprite` remain scale/style watchpoints.
- Findings link directly to `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`.

## Cinderfen Watch Findings

Classification: `acceptable-for-prototype`, `needs-readability-review`, `needs-art-pipeline`.

Observed:

- The Watch launch view is readable: player base, road, capture site, nearby resource site, neutral camp, minimap, objectives, and HUD are visible.
- The Watch pressure-warning capture confirms the top battle-status warning is visually readable.
- Objective feedback remains visible and the pressure warning is not hidden by HUD panels.
- Like Crossing, mid-screen status/label text can visually stack around the active capture-site moment.
- The current Watch Road identity is understandable as a lane/capture objective, but the location itself lacks a strong environmental visual identity.

Decision:

- No pressure warning UI or visual code change is justified in this phase.
- The current status priority work remains sufficient for prototype review.

Asset linkage:

- The Watch Road and Cinderfen capture-site treatment should be part of the future capture-site landmark asset sprint.
- The screenshot should be used with `docs/V071_PRESSURE_WARNING_VISIBILITY_AUDIT.md` and `docs/V08_VISUAL_DEBT_AUDIT.md` when reviewing pressure readability.

## Unit And Building Scale Findings

Classification: `needs-art-pipeline`, `needs-manifest-review`.

Observed:

- Heroes, militia, rangers, raiders, brutes, and buildings are tactically readable.
- Scale is understandable in gameplay terms but not production-coherent.
- The Command Hall is visible and important, but it still looks like a placed sprite on procedural terrain.
- Smaller units rely heavily on labels, health bars, and selection rings.
- Sprite detail level and terrain style remain mismatched.

Asset linkage:

- This matches the scale metadata in `src/game/assets/visualAssetManifest.ts`.
- The future scale standard in `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md` should be used before replacing sprites.

## UI And HUD Findings

Classification: `acceptable-for-prototype`, `needs-art-pipeline`.

Observed:

- Top resource bar, objective panel, minimap, hero panel, and side command panel are readable.
- The HUD protects playability better than the current terrain art does.
- The UI remains text-heavy, which is useful for tests and development but not final.
- No obvious viewport-overlap bug appeared in the captured desktop views.
- The screenshot set should be expanded later for results and more mobile battle views.

Decision:

- No CSS/layout change is justified by this capture set.

## Capture-Site Salience

Classification: `needs-art-pipeline`.

Observed:

- Capture sites are clear because rings, labels, and icons are large.
- They are not memorable as places yet.
- Cinder Shrine and Watch Road should eventually be readable from landmark silhouette, terrain dressing, glow, ownership treatment, and minimap marker hierarchy.

Asset linkage:

- `crown_shrine_icon`
- `procedural_battle_terrain`
- Future capture-site entries in `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`

## Minimap Readability

Classification: `acceptable-for-prototype`.

Observed:

- Minimap is visible in battle screenshots.
- Markers are functional and readable enough for current QA.
- The minimap is diagrammatic rather than visually integrated with final art direction.

Decision:

- No minimap change is justified in this phase.

## What Needs Human Or Art Review

Human/art review should focus on:

- Whether the main menu background and UI frame are acceptable as temporary prototype identity.
- Whether Cinderfen roads read too much like painted strokes during actual play.
- Whether water/swamp blobs reduce the sense of place.
- Whether Cinder Shrine and Watch Road can be understood without giant labels/rings after future art arrives.
- Whether unit/building scale should be normalized before any sprite replacements.
- Whether labels should remain always-on or become optional/contextual in a future visual pass.

## Screenshot QA Gaps

Not captured yet:

- Results screen screenshot.
- Asset Gallery screenshot.
- Inventory screenshot.
- Mobile/tablet battle screenshots.
- Cinderfen Crossing/Watch screenshots after longer human-paced play.
- Defeat screen/defeat-tip screenshot.

These are useful future additions, but they are not required for the first v0.8.1 harness.

## Review Decision

No visual code, CSS, renderer, scale, terrain, UI, or asset change is justified by this screenshot review.

The capture set is doing its job: it proves the current prototype is playable and readable while documenting that the visual debt is structural. Future work should proceed through manifest-backed asset replacement and screenshot QA, not one-off art tweaks.

## Next Step

Phase 9 should convert these findings into a practical Cinderfen visual asset replacement backlog. The backlog should prioritize terrain/road material, Cinder Shrine/capture-site identity, enemy stronghold identity, unit scale consistency, and UI style consistency without implementing any replacements now.
