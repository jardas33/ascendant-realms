# v0.20.1 Tech Tree Closeout And Polish

Date: 2026-05-24
Status: closeout verification and package metadata polish

## Baseline

- Starting commit: `ae3d80d`, `Checkpoint v0.20 upgrade and tech tree foundation`.
- Starting package: `artifacts/playtest/ascendant-realms-private-playtest-ae3d80d`, verified locally with 53 checks.
- Branch state before push: clean `main`, ahead of `origin/main` by 1 commit.
- Push result: `ae3d80d` pushed to `origin/main`; branch returned to clean/synced.

## GitHub Actions

- Push run: CI Release Matrix Dry Run `26372137063`, `main` / `ae3d80d`.
- Fast confidence: passed.
- Optional visual QA: skipped by push workflow rules.
- Release simulator: skipped by push workflow rules.
- Hosted release groups: skipped by push workflow rules.
- Full release e2e: skipped by push workflow rules.
- Manual release-matrix note: exact `ae3d80d` workflow_dispatch release matrix should be run from GitHub with `run_release_matrix=true` if remote hosted/simulator evidence is required. This environment did not have `gh` or a GitHub token available to trigger workflow_dispatch directly.

## Tech Tree Audit

Command Hall:

- Trains Worker only.
- Owns only `Camp Foundations I`.
- `Camp Foundations I` is category `core`, requires completed Command Hall, and grants Command Hall +1 armor.

Barracks:

- Trains Militia and Ranger.
- Owns `Infantry Weapons I`, `Reinforced Armor I`, and `Ranger Training I`.
- Each Barracks upgrade requires a completed Barracks and keeps its existing effect.

Mystic Lodge:

- Trains Acolyte.
- Owns `Aether Study I`.
- `Aether Study I` requires a completed Mystic Lodge and keeps its existing Acolyte/hero-mana effect.

Watchtower:

- Trains no units.
- Owns only `Sentry Bracing I`.
- `Sentry Bracing I` requires completed Watchtower plus `Camp Foundations I`.
- Incomplete Watchtower remains inert; completed Watchtower remains defensive.

## Polish

- No runtime tech-tree balance, upgrade roster, pathing, AI, save, art, map, faction, or production behavior changed in v0.20.1.
- Package metadata now names the closeout checkpoint as `v0.20.1 tech tree closeout and polish`.
- The private playtest package now includes this closeout note alongside the v0.20 spec and implementation report.

## Verification

```text
npm test PASS, 63 files / 465 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
```

Package verification is recorded after the final v0.20.1 commit so the package name does not end in `-dirty`.

## Emmanuel Retest Focus

1. Command Hall remains Worker-only and owns only core/base research.
2. Worker-built Barracks still completes and exposes Militia/Ranger plus existing basic troop upgrades.
3. Mystic Lodge still exposes Acolyte and Aether Study I.
4. Watchtower remains defense-only and exposes Sentry Bracing I only after completion and Camp Foundations I.
5. Incomplete buildings remain inactive and cannot research/train/attack.
6. Upgrade buttons show owner, requirements, cost, effect, locked/researching/researched state.
7. Tutorial remains beginner-friendly and does not require complex tech-tree use.
8. v0.18.3 Worker pause/resume and base-cluster pathing remain stable.
