# v0.16.13 Stone Imp Visible-Contact Reacquisition Fix

Date: 2026-05-23

## Problem

Emmanuel's manual retest of `ascendant-realms-private-playtest-bd26de3` showed that the core Hold Ground contact bug still reproduced in Tutorial with a stationary hero beside two Stone Imps. The v0.16.12 regression used a 54px center distance, but the shipped package could still idle at the visible Stone Imp contact boundary.

## Reproduction Evidence

A browser/manual proxy against the clean bd26de3 package started the real Tutorial BattleScene and swept Hold Ground Warlord-versus-Stone-Imp center distances:

```text
54px: combat started
57px: combat started
58px+: hero and Stone Imp idled with no move target
```

The same proxy reproduced the post-kill failure:

```text
first Stone Imp at 32px: killed
second Stone Imp at 58px+: not reacquired without moving the hero
```

## Root Cause

The v0.16.12 fix used `MELEE_VISUAL_CONTACT_MARGIN = 24`, which gives a Warlord hero versus Stone Imp visible-contact range of 57px:

```text
hero radius 19 + Stone Imp radius 14 + margin 24 = 57
```

That was one pixel short of the first reproducible idle threshold and too narrow for the actual player-visible Stone Imp setup. The tests passed because they encoded a 54px follow-up target instead of the bd26de3 failure boundary.

## Fix

The melee visible-contact margin is now 32px:

```text
hero radius 19 + Stone Imp radius 14 + margin 32 = 65
```

This keeps the behavior local-contact-only. Hold Ground still refuses distant idle enemies and does not become chase mode.

## Test Coverage

- Combat unit tests now place the second Stone Imp at 64px for both initial stationary contact and post-kill reacquisition.
- The deterministic control-lab manual proxy now uses the same 64px follow-up boundary.
- The hosted browser/manual combat regression now uses two real Tutorial Stone Imps instead of the first two generic hostile units.
- The browser/manual proxy reproduced bd26de3 failing at 58px+ before the fix.
- Production-preview Playwright passed the exact Stone Imp regression after rebuilding from the patched source.

## Deferred

No Tutorial overlay movement, art, building feedback, pathing rewrite, AI rewrite, balance tuning, or new gameplay content is included in this fix.

