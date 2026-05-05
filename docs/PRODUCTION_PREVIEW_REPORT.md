# Production Preview Report

Date: 2026-05-04 20:41 -04:00

Scope: v0.3 Cinderfen route baseline candidate production-preview smoke and lightweight bundle report. This pass did not add gameplay, change balance, add content, or refactor runtime code.

## Preview Build

Command:

```bash
npm run build
```

Result: PASS.

Vite output:

```text
dist/index.html                 0.45 kB | gzip:   0.29 kB
dist/assets/index-D049wy4w.css 41.47 kB | gzip:   8.66 kB
dist/assets/index-MCPD5UO4.js   1,914.22 kB | gzip: 456.45 kB
```

Preview command:

```bash
npm run preview -- --host 127.0.0.1 --port 4186
```

Preview URL used: `http://127.0.0.1:4186/`

## Browser Smoke

Browser Use checked the production preview in the in-app browser at `http://127.0.0.1:4186/`.

Console status: PASS. `tab.dev.logs({ levels: ["error"] })` returned no errors after the smoke flow.

Smoke flow results:

| Area | Result | Notes |
| --- | --- | --- |
| Main menu loads | PASS | Title was `Ascendant Realms`; main menu rendered `Prototype v0.2` and the current v0.2 subtitle. |
| New Campaign works | PASS | `New Campaign` opened hero creation, `Begin Campaign` created a Warlord save, and the campaign map loaded. |
| Continue Campaign does not crash | PASS | Reloaded to main menu after creating a save; `Continue Campaign` reopened the campaign map. |
| Skirmish setup opens | PASS | `Skirmish` opened setup with current maps, including Cinderfen Causeway and Cinderfen Watchpost. |
| Campaign map opens | PASS | Campaign map rendered hero, campaign bank, Stronghold, Retinue, reputation, chapters, and node cards. |
| Chapter 2 cards after seeded progress | PASS | A production-preview Playwright smoke used the same localStorage post-Ashen seed shape as `tests/e2e/chapter2-helpers.ts`; Chapter 2 rendered unlocked with Cinderfen Overlook available and Waystation, Crossing, Watch, and Aftermath present and locked as expected. Console/page errors were 0 with the Playwright config's SwiftShader launch args. |

No production-only crash was found.

## Bundle Warning

Status: WATCH, not blocked.

The production build still emits the expected Vite warning:

```text
Some chunks are larger than 500 kB after minification.
```

Current main JavaScript bundle:

- File: `dist/assets/index-MCPD5UO4.js`
- Minified size reported by Vite: `1,914.22 kB`
- Gzip size reported by Vite: `456.45 kB`

Assessment: acceptable for the current prototype baseline. The app is still a compact Phaser/Vite prototype with one main runtime bundle, and the warning is already documented in `RELEASE_CHECKLIST.md` as non-blocking unless bundle optimization becomes the explicit goal.

Future optimization ideas, not implemented in this pass:

- Add a bundle analyzer before changing chunking.
- Consider dynamic imports for rarely used scenes such as Asset Gallery, Settings, Hero Inventory, and Credits.
- Consider a deliberate Phaser/vendor chunk via `build.rollupOptions.output.manualChunks`.
- Review large data and scene modules before raising `chunkSizeWarningLimit`.
- Keep any optimization work separate from gameplay, balance, or route-readiness changes.

## Rerun Note

For the current production-preview smoke:

```bash
npm run build
npm run preview -- --host 127.0.0.1 --port 4186
```

Then open the printed local URL and verify main menu, New Campaign, Continue Campaign, Skirmish Setup, Campaign Map, and seeded Chapter 2 card rendering using the maintained e2e seed shape when a route-state seed is needed.
