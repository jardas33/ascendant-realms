# v0.35 Emmanuel Retest Checklist

Date: 2026-05-27

Use the clean `v0.34-v0.35 relic reward choice and hero build identity` package after confirming `PLAYTEST_BUILD_INFO.md` names the final checkpoint commit and says the working tree was not dirty.

## Focus

- Start a campaign route that can defeat Captain Malrec at Ashen Outpost.
- Confirm Results show `Rival Defeated`, XP gained, and an inline `Relic Reward Choice`.
- Confirm `Outpost Command Signet` appears as a Commander choice and shows effect/build copy before selection.
- Choose the relic and confirm the final Relic Reward block says it was added to hero inventory.
- Use `Equip Relic` from Results and confirm the final equipped state updates.
- Open Hero Inventory and confirm the relic slot shows the equipped relic and Commander build identity.
- Start another battle and confirm the battle HUD shows the active equipped relic summary.
- Run Tutorial / Proving Grounds and confirm there is no relic choice, no relic grant, and the no-save/no-reward completion copy remains clear.
- With a save that already owns the source relic but not the full pool, confirm choices prefer unowned alternatives instead of duplicate conversion.
- With a save that owns every relic, confirm duplicate conversion appears once instead of adding another relic copy.

## What Not To Judge Yet

- No new maps, factions, units, runtime art, icons, portraits, VFX, shop, crafting, full build tree, full inventory sorting/filtering, relic upgrade/reroll/sell loop, or multiple relic slots were added.
- Relic effects are intentionally modest and active only while equipped.
- Existing Cinderfen route readability, full balance, and long-term economy pacing still need human feel review outside this checkpoint.
