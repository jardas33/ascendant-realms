# v0.81 UI Readability And Teaching Spec

Status: docs-only UI and teaching plan. No runtime UI changed.

## UI Principles

The first Lume Network runtime prototype should be readable during normal RTS play without a new overlay. Use existing UI surfaces and short copy.

Priorities:

1. Tactical readability.
2. One clear player action.
3. One clear benefit.
4. One clear severing condition.
5. No final art dependency.
6. Screenshot QA stability.

## Future First-Time Teaching

First teaching sentence:

> Hold both linked sites to wake a Lume Ward. Enemy recapture severs the link.

Player action:

- Capture and hold the two endpoint sites.

Success confirmation:

- HUD row changes to "Active".
- Selected linked site shows the ward summary.
- A short status notification says the link is active.

Failure/severing explanation:

- HUD row changes to "Severed".
- Counterplay line says: "Recapture either endpoint to restore the ward."

Replay copy:

- "Lume objective is battle-local. First-clear rewards remain already claimed."

## Campaign Briefing Surface

File likely extended later: `src/game/campaign/CampaignNodePanel.ts`.

Use a compact `guidance-card` style already present in node details:

- Title: "Lume Network"
- Body: "Hold linked sites to wake a defensive ward."
- Tags: "Linked sites", "Enemy can sever", "Battle-local"

Only show this on the selected testbed mission.

## Battle HUD Surface

File likely extended later: `src/game/ui/hudPanels/ObjectivePanel.ts`.

Recommended row:

```text
Lume Link
Hold West Stone Cut and Ford Toll - Active / Inactive / Severed
Counterplay: Recapture either site to restore the ward.
```

Use the existing battlefield-event row pattern if possible. Do not add a large map graph panel.

## Selected Site Surface

File likely extended later: `src/game/ui/hudPanels/SelectedEntityPanel.ts`.

For linked sites only, add one or two rows:

- `Lume Link: Active with Ford Toll`
- `Ward: friendly units near linked sites are steadier while active`

For non-linked sites, do not add noise.

## Map-Line Representation

Do not require final map-line rendering in the first runtime prototype.

If a line is added later:

- Use a simple placeholder-safe line between endpoint positions.
- Show only when both endpoint sites are visible or explored.
- Keep it thin and subdued.
- Use active/inactive/severed state color sparingly.
- Do not obscure units, health bars, site rings, or enemy pressure indicators.

The first prototype can ship with HUD/selected-site status only if line rendering risks clutter.

## Minimap Posture

`src/game/ui/MinimapView.ts` already marks capture sites. Do not add minimap Lume lines first. Minimap line readability is a later visual QA problem and should wait for proof that the system is fun.

## Notifications

Use one short status message per state transition:

- "Lume Link active: Linked Ward online."
- "Lume Link severed: recapture a linked site."

Avoid repeated spam every tick. Use cooldown or transition-only messaging.

## Results Surface

File likely extended later: `src/game/results/ResultsObjectiveSummary.ts`.

Recommended compact block:

- Lume objective: completed/incomplete.
- Links activated: names or count.
- Links severed: names or count.
- Benefit: Linked Ward.
- Scope: battle-local, no save fields.

Do not mix Lume Results with relic choice, XP, Retinue, or finale debrief in a way that crowds them.

## Readability States

Minimum states:

| State | Meaning | UI text |
| --- | --- | --- |
| Inactive | Requirements not met | "Capture both linked sites" |
| Active | Both endpoints held | "Linked Ward active" |
| Contested | Endpoint capture in progress | "Hold the endpoint" |
| Severed | Was active, now broken | "Recapture to restore" |

## Accessibility And Copy

Keep text literal and short. Avoid lore-only phrasing in the HUD. Use "Lume" as the system term but pair it with plain action words: capture, hold, recapture, ward.

Do not rely on color alone. Include text state labels.

## Tutorial Protection

Tutorial / Proving Grounds should not show Lume briefing, HUD rows, Results rows, or no-reward complexity. If a future tutorial mentions Lume, that must be a separate onboarding goal.

## Visual Direction Compatibility

The future art direction can later make Lume links more beautiful. The first runtime prototype should prove the mechanic with placeholder-safe rendering and text-first clarity. Do not block the design on final VFX.
