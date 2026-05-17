# v0.12.2 Balance Watchpoint Protocol

Date: 2026-05-17

Scope: v0.12.2 Human Balance Watchpoint Review. This protocol reviews repeated balance evidence after v0.12.1 without expanding systems, content, AI, economy, art, or save format. It exists to decide whether the current watchpoints need no change, copy/readability clarification, tiny numeric tuning, or deferral.

## Phase 0 Baseline

- Branch: `main`.
- Current commit at Phase 0: `1b28678` (`Checkpoint v0.12.1 human-paced core feel review`).
- Sync state after `git fetch origin main`: clean and synced with `origin/main`.
- User-provided remote truth: GitHub Actions `CI Release Matrix Dry Run #44` is green on commit `1b28678`; Fast confidence, Release simulator, and all hosted release matrix groups passed.
- Local GitHub limitation: the GitHub connector's commit workflow-run wrapper returned no runs for `1b28678` because it filters to PR-triggered runs, and `gh` is not installed in this environment. Treat the user-provided run #44 result as remote truth and keep local verification strict.

Green-state constraints to preserve:

- Hosted release groups stay on `playwright.hosted-release.config.ts` and `npm run preview:hosted`.
- Local full release lanes remain separate from hosted release groups.
- Do not replace `clickReady` with force clicks.
- Do not use DOM fallback for canvas/world clicks.
- Do not weaken `Moving`, minimap, no-save/no-reward tutorial, battle command, side-panel reachability, settings runtime-application, or hosted-release assertions.
- Do not turn tutorial smoke semantic advancement back into raw `tutorial-next` click chains.
- Do not add maps, factions, units, art/assets, runtime art replacements, save migrations, multiplayer, procedural generation, monetization, broad AI/economy rewrites, or CI plumbing.

## Shared Metrics To Inspect

- Win, defeat, and timeout counts.
- Clear speed, contact timing, and first-wave survival.
- Barracks completion before pressure.
- Objective completion order and objective timing when available.
- Pressure warning trigger timing, warning count, and losses after pressure.
- Player resource surplus or shortage at key moments.
- Hero survival and army survival.
- Retinue losses, retinue contribution, and active retinue capacity.
- Stronghold purchases and Training Yard II capacity effect.
- Whether a player-facing failure would be understandable from HUD/objective/result copy.

## Profile: Normal Baseline

Starting assumptions:

- No retinue beyond normal campaign state.
- No special Stronghold rush.
- Player follows objectives, captures nearby economy, builds Barracks, trains a modest army, and pushes after regrouping.

Expected player behavior:

- Wins early Easy nodes consistently.
- Can beat Ashen Outpost and Cinderfen nodes with staged objectives and moderate patience.
- May time out or lose if ignoring production, but not before seeing useful guidance.

Too easy:

- Safe baseline wins every reviewed Normal node quickly with low losses, large resources, and no need to respect objectives or pressure.

Too punishing:

- Safe baseline loses before Barracks or first wave counterplay is available.
- Defeats occur despite following objectives and building production.

Unclear rather than unbalanced:

- Player loses after skipping side income, shrine, Barracks completion, or regroup timing, and existing guidance does not explain that sequence.

Metrics:

- Safe Beginner script records.
- First wave survived.
- Barracks before pressure.
- Results tips and objective guidance.

## Profile: Retinue-Heavy

Starting assumptions:

- Player brings one or two Veteran retinue units into campaign battles.
- No extra Training Yard II capacity unless explicitly reviewing that profile.

Expected player behavior:

- Early fights should feel easier and satisfying.
- Veterans should help stabilize rough fights without erasing map objectives or pressure.

Too easy:

- Retinue profiles turn Ashen/Cinderfen battles into low-loss rushes regardless of economy or objective routing.
- Retinue survival is automatic and pressure losses drop to zero across harder nodes.

Too punishing:

- Veteran retinue dies too often during ordinary baseline play despite careful grouping.

Unclear rather than unbalanced:

- Player overextends veterans into towers/fortresses and loses them without understanding permanent-death risk.

Metrics:

- Retinue profile win/defeat/timeout records.
- Retinue loss counts and losses after pressure.
- Clear-speed differences versus no-retinue baseline.
- Human readability of retinue danger and reward.

## Profile: Training Yard II Rush

Starting assumptions:

- Player prioritizes Training Yard I and Training Yard II to increase active retinue capacity.
- Review Training Yard II alone where telemetry supports it, and Retinue + Training Yard II as the key watchpoint.

Expected player behavior:

- More active veterans should feel like a meaningful long-term reward.
- The profile may be strong, but should not make the player ignore core economy/production.

Too easy:

- Retinue + Training Yard II clears all reviewed Chapter 2 battles with no pressure losses, little production, and very fast clears.
- It meaningfully outperforms every other profile while removing failure risk.

Too punishing:

- The upgrade cost delays the army so much that the player is worse off than normal baseline despite using intended progression.

Unclear rather than unbalanced:

- Player does not understand that Training Yard II affects active retinue capacity rather than raw unit stats.

Metrics:

- Retinue + Training Yard II record.
- Improved-runs count versus no-retinue and mixed-retinue profiles.
- Active capacity behavior.
- Cinderfen Crossing/Watch outcome and losses after pressure.

## Profile: Greedy Economy

Starting assumptions:

- Player captures extra economy, delays attack timing, and may under-invest in early army.
- This profile intentionally takes risks for later resource strength.

Expected player behavior:

- Greedy Economy should be risky.
- Timeouts may be acceptable if caused by late army buildup or failure to convert income into pressure.

Too easy:

- Greedy Economy wins reliably while delaying army and still avoids meaningful pressure.

Too punishing:

- Greedy Economy gets defeated before its risk/reward tradeoff is legible, especially if first wave timing gives no room to recover.

Unclear rather than unbalanced:

- Greedy Economy survives first waves but times out because it fails to push, and results/objective guidance does not explain conversion from economy to army.

Metrics:

- Greedy Economy wins/defeats/timeouts.
- First wave survived.
- Resource surplus at timeout if available.
- Pressure warnings and losses after pressure.
- Results tips around building production and pushing.

## Profile: Fast Army

Starting assumptions:

- Player prioritizes early army and attacks quickly, sometimes before full objective preparation.

Expected player behavior:

- Fast Army can be a legitimate speed profile if it accepts higher losses and misses safer staging rewards.
- It should not reliably farm repeat rewards or skip the map's identity mechanic for free.

Too easy:

- Fast Army clears Cinderfen/Ashen quickly with low losses, no objective prep, and no meaningful pressure triggers.

Too punishing:

- Fast Army is always crushed despite building units promptly and attacking a plausible first target.

Unclear rather than unbalanced:

- Fast Army succeeds but takes heavy losses; player cannot tell whether that was expected risk or poor play.

Metrics:

- Fast Army wins/defeats/timeouts.
- First wave survived or skipped.
- Objective/shrine/tower interactions.
- Repeat-clear value and reward pressure.
- Unit losses and hero survival where available.

## Profile: Cautious / Slow Player

Starting assumptions:

- Player reads the HUD, builds production, waits for a larger army, and reacts to warnings slowly.

Expected player behavior:

- Cautious play should survive early pressure but may time out or feel slow if it never attacks.

Too easy:

- Waiting safely always wins because enemy pressure cannot force action.

Too punishing:

- Cautious play loses to hidden or sudden pressure despite responding to warnings.

Unclear rather than unbalanced:

- Player survives but does not know when the army is large enough to attack.

Metrics:

- Timeout reasons.
- First-wave survival.
- Warning read windows.
- Result tips and objective prompts.

## Profile: Objective-Rush Player

Starting assumptions:

- Player moves quickly toward the first listed objective or special site, sometimes before full army setup.

Expected player behavior:

- Objective rush can be rewarded when the objective is designed as a staging advantage.
- It should punish reckless overextension into enemy fortress zones.

Too easy:

- Objective rush captures all map-defining objectives without needing production, scouting, or regrouping.

Too punishing:

- Objective rush dies before the player can understand why the objective was marked `Next`.

Unclear rather than unbalanced:

- Objective order is technically correct but does not explain side income, hold timing, or regrouping.

Metrics:

- Objective completion timing.
- Losses before/after objective capture.
- Shrine and Watch Road pressure triggers.
- Result guidance specificity.

## Profile: Pressure-Ignoring Player

Starting assumptions:

- Player sees pressure warnings but continues previous plan without regrouping, producing units, or defending.

Expected player behavior:

- Ignoring warnings should be risky and sometimes punished.
- The warning should make the consequence feel earned.

Too easy:

- Ignoring pressure still wins cleanly with low losses and no base threat.

Too punishing:

- Pressure warnings trigger too late for response, or consequences feel unrelated to the warning.

Unclear rather than unbalanced:

- The warning names danger but not what practical response helps.

Metrics:

- First pressure timing.
- Warning count.
- Losses after pressure.
- First wave survived.
- Whether copy points to hold/regroup/side income/production.

## Decision Rule

Prefer no numeric tuning unless at least two evidence channels agree:

- simulator/telemetry shows repeated structural outlier behavior,
- human-style review reproduces the same player-facing issue,
- the issue is not primarily wording, HUD readability, or visual debt,
- the smallest numeric change has a clear player-facing reason and limited blast radius.

If evidence is inconclusive, defer and document the exact evidence still needed.
