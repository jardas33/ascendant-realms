# v0.33 Emmanuel Retest Checklist

Date: 2026-05-27

Use the clean `v0.32-v0.33 persistent relic inventory and hero loadout foundation` package after confirming `PLAYTEST_BUILD_INFO.md` names the final checkpoint and says the working tree was not dirty.

## Main Retest Route

1. Start from a fresh disposable save.
2. Create or continue a campaign hero.
3. Progress or seed to Ashen Outpost.
4. Defeat Captain Malrec and complete the battle.
5. On Results, confirm the `Relic Reward` block appears.
6. Confirm `Outpost Command Signet` says it was added to inventory.
7. Confirm the copy says `Relic effects are active when equipped.`
8. Click `Equip Relic`.
9. Confirm the status says `Outpost Command Signet equipped.`
10. Open Hero Inventory from Results.
11. Confirm the Equipment panel shows a Relic row with Outpost Command Signet.
12. Confirm Hero Stats include the relic stat effect.
13. Unequip the relic.
14. Confirm the Relic slot returns to Empty and the stat effect is removed.

## Additional Champion Checks

On disposable saves or seeded routes:

- Defeat Gorak Emberhand and confirm `Emberbrand Shard` can enter inventory.
- Defeat Veyra of the Cinders and confirm `Cinder-Seer Focus` can enter inventory.
- Repeat a rival already defeated and already owning the relic; confirm the battle does not repeatedly farm relic duplicates.
- If a seeded save already owns the matching relic before a first eligible grant, confirm the duplicate converts to resources instead of adding a second relic.

## Tutorial Protection

1. Launch Tutorial / Proving Grounds from the main menu.
2. Complete or exit the tutorial.
3. Confirm the Results screen says no-save and no-reward.
4. Confirm no `Relic Reward` block appears.
5. Confirm no save is written by the Tutorial route.

## Regression Watch

- Results still show XP, battle rewards, campaign node rewards, Retinue, and rival consequence copy.
- Existing weapons/armor/trinkets can still equip and unequip.
- Hero ability cooldown and mana UI still behaves normally.
- World movement, retreat clicks, minimap movement, and command-button hover stability still feel normal.
- No new art, maps, factions, shop, crafting, or broad inventory UI should appear.

## Report Back

For each issue, include:

- package name and commit from `PLAYTEST_BUILD_INFO.md`;
- route and champion tested;
- whether the relic was new, already owned, or duplicate-converted;
- whether the relic was equipped or unequipped;
- screenshots of Results and Hero Inventory if the issue is visual/copy related.

