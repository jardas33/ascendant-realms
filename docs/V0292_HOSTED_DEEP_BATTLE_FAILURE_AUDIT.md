# v0.29.2 Hosted Deep-Battle Failure Audit

Date: 2026-05-27
Scope: audit the remaining red hosted `deep-battle` release-matrix lane after v0.29.1 remote-CI recovery.

## Baseline

- Latest pushed baseline entering the audit: `9411dea`, `Document v0.29.1 remote CI recovery status`.
- Local branch baseline: clean `main`, synced with `origin/main`.
- GitHub checkout/account blocker: resolved before this audit.
- Push run `26485815688` on `9411dea`: Fast confidence passed.
- Manual release matrix `26484817685`: checkout/build/test execution succeeded, but hosted `deep-battle` failed.

## Remote Run

- Workflow run: `26484817685`.
- Failing job: `Release matrix (deep-battle)`.
- Job id: `77989895354`.
- Tested commit in that job: `6124d716ddb6bdc4c8104d7d791f38cfae94d337`.
- Artifact reviewed: `playwright-release-deep-battle` / artifact id `7230128210`.
- Job summary: 3 failed, 1 flaky, 23 passed.
- Other release matrix groups passed: Fast confidence, Release simulator, `deep-meta`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`.

## Failing Tests

1. `battle HUD supports minimap movement, fog toggle, and move commands @hosted-deep-battle`
   - Remote error: `unit-order-summary` expected `/Moving|Repositioning/`, but the HUD showed guarding/defending copy.
   - Classification: hosted timing plus test-harness setup issue. Nearby hostile/site pressure could consume or replace transient movement state before the assertion.

2. `battle HUD keeps hovered command buttons stable across routine refreshes @hosted-deep-battle`
   - Remote error: expected the same DOM node to remain under hover after HUD refresh.
   - Classification: stale assertion. The user-facing button remained visible/enabled and under the pointer, but the HUD can legitimately replace DOM nodes during refresh.

3. `behaviour mode control gauntlet preserves attack, retreat, marquee, and minimap intent @hosted-deep-battle`
   - Remote error: timeout around the retreat/move path.
   - Local repro narrowed this to absolute-page right-click delivery and transient status text. In bad local soaks, the world point mapped correctly to the canvas but `page.mouse.click` sometimes produced no native pointer/mouse events before the scene assertion.
   - Classification: hosted Playwright actionability/input-delivery issue plus stale transient status assertion in an overloaded deep-battle test.

4. `Worker assignment and site upgrade boost a captured resource site @hosted-deep-battle`
   - Remote result: failed once and passed on retry.
   - Remote context showed the Crown Shrine being enemy-controlled/contested during a player Worker/site regression.
   - Classification: hosted timing plus enemy strategy interference with deterministic setup, not a Worker-slot runtime regression.

## Not Classified As

- Not the old GitHub account suspension / checkout failure.
- Not a hero progression or ability runtime regression.
- Not an enemy strategy runtime regression.
- Not a save/package/art/content issue.
- Not evidence that gameplay balance should change.

## Fix Direction

Use narrow test-harness stabilization only:

- Keep real canvas/world clicks.
- Do not use `force`.
- Do not add DOM fallback for canvas/world clicks.
- Preserve coverage by asserting durable scene state instead of transient HUD copy.
- Isolate deterministic setup from unrelated enemy-site pressure only inside hosted proxy tests.

