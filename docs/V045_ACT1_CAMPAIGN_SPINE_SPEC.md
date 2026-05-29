# v0.45 Act 1 Campaign Spine Spec

Date: 2026-05-29

## Goal

Turn the existing Chapter 1 campaign nodes into a clearer Act 1 progression spine. The player should move from Tutorial / Proving Grounds into first-clear battles, resource capture, base development, rival champion pressure, relic reward choice, skill spending, and replayable optional objectives without new maps, factions, art, or a large quest system.

## Act 1 Order

Recommended spine:

1. Training / Proving Grounds: basic controls, no-save, no-reward.
2. Border Village: first campaign battle with basic combat and resource capture.
3. Old Stone Road: base development, Worker production, and early building reminders.
4. Aether Well Ruins: resource control, site assignment, upgrades, and Seer-friendly pacing.
5. Bandit Hillfort: tougher army pressure and rival champion preparation.
6. Ashen Outpost: champion confrontation, relic reward choice, skill reminders, and replay objectives.
7. Replay / optional objective loop: completed battle nodes stay replayable with safe repeat rewards.

This order is guidance and unlock readability layered over the existing campaign graph. Side nodes such as Marcher Camp, Refugee Caravan, and Chapel of the Marches remain support stops and do not require a new route system.

## Unlock Progression

- Tutorial remains outside persistent campaign progression.
- Border Village starts unlocked for a fresh campaign.
- Old Stone Road unlocks after Border Village first clear.
- Existing branch unlocks after Old Stone Road remain intact so current saves and tests keep their route shape.
- Ashen Outpost stays gated by the existing Bandit Hillfort and Chapel of the Marches prerequisites.
- Completed battle nodes are clearly marked replayable.
- Locked nodes show the missing prerequisite or placeholder reason in existing campaign UI.

## Reward Integration

The Act 1 spine does not create a new reward store. It clarifies existing first-clear and replay rules:

- first-clear rewards can include hero XP, resources, relic eligibility, and skill-point reminders through existing systems;
- replay rewards remain conservative and cannot duplicate unique relics or one-time optional objective credit;
- rival champion missions remain the strongest source of relic reward choice;
- Results should point the player toward equip relic, spend skill point, replay objective, or next mission actions when those are relevant.

## Save Compatibility

Act 1 spine data is content metadata. It is not stored in saves and does not require a save-version bump. Existing campaign completion, reward-claim, optional-objective, hero XP, relic inventory, and skill-tree save fields remain authoritative. Old saves default through the existing campaign normalization path and unknown future node/objective ids remain ignored by current guards.

## Deferrals

- New Act 1 maps or factions.
- Branching story consequences.
- Cinematics, dialog scenes, or a journal.
- Mission scoring ranks or medals.
- Large quest or campaign rewrite.
