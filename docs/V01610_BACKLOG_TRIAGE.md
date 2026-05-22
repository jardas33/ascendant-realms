# v0.16.10 Backlog Triage

Date: 2026-05-22

## Must Test Manually Before v0.17

- Guard Area remains default.
- Hold Ground does not chase distant idle enemies.
- Hold Ground engages the second adjacent melee enemy after the first dies.
- Melee enemies beside the Command Hall attack locally.
- Retreat near multiple enemies starts and is not instantly canceled.
- Combat can resume after move-away suppression expires.
- Attack cursor appears over enemy body and edge.
- Empty nearby terrain does not show attack intent.
- Left-click enemy attack remains intentional.
- Drag-select over HUD/minimap still works.
- Minimap click plus `H` does not leave stale `No Selection`.
- Tutorial defeat Results still works.

## v0.16.x Bugfix Only If Retest Fails

- Any deterministic repro of adjacent melee idle after first kill.
- Any deterministic repro of melee enemies idling beside the Command Hall with no better target.
- Any deterministic repro of explicit retreat being immediately canceled by opportunistic reacquisition.
- Any deterministic attack-hover regression where enemy body or edge fails but empty nearby terrain still must not attack.
- Any stale side-panel selection regression after minimap/HUD interaction.

## v0.17 Likely First Human Playtest Intake

- Aggregate Emmanuel's retest and first 2-5 tester notes.
- Classify feedback as blocker, repeated friction, one-off confusion, or future feature request.
- Separate mechanical bugs from readability, onboarding, and preference notes.
- Preserve raw private feedback outside the public repo.

## Future Worker Construction Design

- Decide whether builders are dedicated workers, existing villagers, Command Hall remote construction, or a hybrid.
- Answer worker vulnerability, repair, build-speed, worker count, and AI-use questions before implementation.
- Treat as a design spike with tests, not a v0.16.x patch.

## Future Combat Readability / VFX

- Improve attack intent visibility only after repeated human evidence.
- Consider existing-asset hover outlines, order-summary clarity, or approved cursor/CSS options before new art.
- Defer new cursor art, decals, combat VFX, and target markers until an art-approved pass.

## Future Tutorial / Onboarding Polish

- Use tester notes to identify the first confusing objective or command.
- Keep Tutorial optional, no-reward, and non-persistent unless a future goal explicitly changes that.
- Avoid adding new gameplay content as a tutorial shortcut.

## Future Visual Overhaul

- Keep production asset approval gated by source/license proof.
- Preserve the existing art-intake workflow.
- Do not replace runtime art during combat/control stabilization.

## Explicitly Deferred / Not Now

- Worker construction implementation.
- New units, buildings, maps, factions.
- Patrol runtime.
- Formations.
- Broad AI/pathing rewrite.
- Balance/stat/wave tuning without human evidence.
- Save migration.
- Runtime art/assets.
- Protected-IP-inspired names, assets, lore, UI, or music.
