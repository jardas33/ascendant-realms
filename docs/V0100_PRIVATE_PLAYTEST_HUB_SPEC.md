# v0.100 Private Playtest Hub Spec

Scope: private-package QA convenience only. The hub is visible only when private playtest tools are enabled by dev posture or package injection. It does not alter normal campaign progression, rewards, saves, balance, stable IDs, maps, factions, art, or runtime title.

## Entry Surface

- Main Menu shows `Playtest Hub` only in private/dev posture.
- Public production posture hides the hub through the same private-tools gate used by the Aether Well Lume demo.
- Returning to Main Menu from the hub resets the private preview session and restores the pre-hub local save snapshot.

## Hub Copy

The hub must lead with:

```text
PLAYTEST HUB
Private testing only
Rewards, XP, campaign progress, Retinue state, and reputation are not saved.
```

The same no-save message appears on scenario previews and ordinary Results fixtures launched from the hub.

## Scenario Groups

- Campaign Shell: campaign map, Salto selected, locked mission, Stronghold, Hero, Inventory, Intel, and Reputation tabs.
- First Session: Ascendant creation, Tutorial / Proving Grounds, and Salto Outskirts battle start.
- Battle Shell: ordinary battle start, selected hero, selected Worker, selected squad, selected building, contested site, fog/minimap sample, and notification-priority sample.
- Lume: existing Aether Well Lume demo, first-link activation sample, Hidden / Auto / Always overlay samples, and private-demo Results.
- Meta: Hero overview, Skills, Equipment, Relics, Retinue Ready, Retinue Recovering, Stronghold preview, ordinary Results, and defeat Results.

## Guided Tour

`Run 8-Minute Visual Tour` is an ordered review helper. It is not autoplay gameplay. The tour supports `Next`, `Back`, `Open Step`, and `Exit Tour`.

Tour order:

1. Main menu.
2. Ascendant creation.
3. Campaign map.
4. Salto mission.
5. Battle selected hero.
6. Battle selected Worker.
7. Lume activation.
8. Private-demo Results.
9. Hero / Retinue.
10. Return to hub.

## Isolation Rules

- Every hub battle launch sets `rewardsDisabled`.
- Every hub battle launch carries `privatePlaytestHubScenarioId`.
- Private campaign, hero, and Results previews skip persistent writes.
- The hub stores a raw localStorage snapshot before previews and restores it when returning to hub, resetting, or exiting.
- Tutorial remains Tutorial mode and no-reward.
- Locked mission previews do not enable start actions or mutate unlocks.

## Deferrals

- No persistent scenario bookmarks.
- No saved tour progress.
- No public-package exposure.
- No autoplay battle automation.
- No runtime art or new fixtures outside existing content and procedural preview state.
