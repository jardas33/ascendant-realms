# v0.103 Battlefield Clutter Reduction Spec

## Purpose

v0.103 reduces battlefield visual noise without changing gameplay, rewards, saves, stable IDs, maps, units, pathing, AI, or Lume mechanics. The target is readable default play, not final art.

## Allowed Runtime Changes

- Capture-site labels become contextual by default: selected, contested, objective-relevant, or enemy-controlled sites keep labels visible; quiet friendly/neutral sites rely on rings and selection feedback.
- Capture-site rings use slightly lower steady-state alpha and stroke width while preserving contested/objective emphasis.
- Lume Auto mode hides stable active links after transition pulses unless the player selects a linked endpoint. Hidden and Always keep their explicit semantics.
- Lume HUD copy keeps core status visible and moves optional-link prose into Details.
- Private demo controls use shorter "Preview Tools", "Exit Preview", and "Finish Demo" copy.

## Preserved Behavior

- `linked_ward` damage multiplier remains `0.92`.
- Lume objective, benefit, telemetry, Results, and no-save/no-reward private demo behavior are unchanged.
- Tutorial, campaign locks, rewards, XP, Retinue, relics, save fields, and stable IDs are unchanged.

## Acceptance

- Auto Lume is quieter in stable states.
- Selected Lume endpoints still reveal links for intentional inspection.
- Hidden and Always remain clear manual modes.
- Capture sites remain readable when selected, contested, objective-relevant, or hostile.
- No visual reduction hides a critical command, reward, objective, or private-demo exit action.

## Deferrals

- Final art, proper terrain dressing, final capture-site illustrations, Lume race-specific visuals, Living Mines, audio, and desktop rendering are deferred.
