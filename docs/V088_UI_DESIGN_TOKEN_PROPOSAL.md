# v0.88 UI Design Token Proposal

Status: proposal-only. No runtime CSS variables or game code are changed by this checkpoint.

## Purpose

This document defines a future token vocabulary for a professional desktop RTS/RPG interface. It is meant to guide later visual implementation, style frames, and art-intake review without changing current runtime styling.

## Token Principles

- Readability beats atmosphere when they conflict.
- RTS density is allowed; visual noise is not.
- State color must never be the only signal.
- Lume teal is magical/systemic and should stay special.
- Ashen fire is hostile/overcharge/rival pressure and should not become the default accent.
- Barrosan granite and hearth tones carry the player-facing foundation.
- Tokens should map to semantic intent, not just color names.

## Typography Hierarchy

Proposed future token names:

- `type.display.title`: main title, major act/finale headings.
- `type.display.section`: campaign chapter, Results outcome, hero build header.
- `type.heading.panel`: panel titles and selected mission headers.
- `type.heading.card`: card titles, tab subsection labels.
- `type.body.primary`: normal readable copy.
- `type.body.compact`: command rows, status rows, resource labels.
- `type.body.caption`: metadata, timestamps, lock reasons, tooltips.
- `type.numeric.hud`: resources, timers, cooldowns, population-like counters.

Rules:

- Avoid viewport-width font scaling.
- Avoid negative letter spacing.
- Use uppercase sparingly for labels, not paragraphs.
- Long prose belongs behind disclosure.

## Spacing Scale

Proposed future token names:

- `space.0`: 0.
- `space.1`: 4px, tiny internal offsets.
- `space.2`: 8px, compact row gap.
- `space.3`: 12px, card internal gap.
- `space.4`: 16px, panel padding.
- `space.5`: 24px, section gap.
- `space.6`: 32px, major surface gap.
- `space.7`: 48px, map/lane spacing.

Rules:

- Command panels should favor `space.2` and `space.3`.
- Campaign and Results shell surfaces can use `space.4` to `space.6`.
- Map nodes need stable spacing independent of label length.

## Panel Hierarchy

Proposed future token names:

- `panel.shell`: main screen background layer.
- `panel.primary`: selected mission, command panel, Results overview.
- `panel.secondary`: tabs, cards, support panels.
- `panel.tertiary`: details disclosures, telemetry, extended notes.
- `panel.overlay`: tooltips, event hints, hover details.
- `panel.alert`: critical warnings and modal-level interruption only.

Rules:

- Do not nest cards inside cards unless the inner element is a repeated item.
- Avoid giant vertical dashboards.
- Keep primary actions near the content they affect.

## Border Hierarchy

Proposed future token names:

- `border.none`: no outline.
- `border.hairline`: subtle panel separator.
- `border.panel`: default framed surface.
- `border.selected`: selected/active object.
- `border.available`: can act now.
- `border.locked`: unavailable with reason.
- `border.hostile`: enemy/attack/threat.
- `border.objective`: mission-critical.

Rules:

- Selection must have shape, brightness, or label support in addition to color.
- Locked state uses lower contrast plus lock copy, not hidden content.

## Corner Treatment

Proposed future token names:

- `radius.none`: hard tactical edges.
- `radius.small`: 4px, compact chips and buttons.
- `radius.medium`: 6px, panels and cards.
- `radius.large`: 8px maximum for most UI.

Rules:

- Avoid soft mobile-card rounding.
- Cards should stay at 8px radius or less unless a future style frame explicitly proves otherwise.

## Icon-Size Hierarchy

Proposed future token names:

- `icon.micro`: 12px, inline status.
- `icon.small`: 16px, command metadata.
- `icon.medium`: 20px, buttons and tab labels.
- `icon.large`: 28px, selected object or reward.
- `icon.hero`: 40px, rare hero/relic/faction focus.

Rules:

- Use familiar symbols when available.
- Tooltips must name unfamiliar icons.
- Final icons require manifest entries and review.

## State Tokens

Selected:

- Strong border, focused elevation, concise selected label.

Available:

- Clear action affordance, readable cost, enabled cursor/hover state.

Locked:

- Muted but readable, prerequisite/lock reason shown.

Hostile:

- Ashen fire family, threat language, attack intent.

Friendly:

- Barrosan hearth/granite support with green or blue-green accents only when readable.

Neutral:

- Stone/iron baseline, no implied ownership.

Completed:

- Stable check/completion marker plus subdued route state.

Replayable:

- Completed marker plus replay label, not a fresh-reward signal.

## Notification Tiers

Critical:

- Immediate threat, defeat risk, commander/finale phase. Requires strong contrast and short copy.

Important:

- Objective/event/reward/progression change. Visible but not alarming.

Routine:

- Command confirmation and normal status updates. Compact and deduplicated.

Debug:

- Private playtest or developer-only evidence. Hidden or de-emphasized in normal play.

## Tooltip Rules

- Tooltips should answer "what is this" and "why can/can't I act" in one or two short lines.
- Avoid replacing panel hierarchy with tooltip-only information.
- Tooltip copy should not contain long lore or telemetry.
- Disabled actions need an inline reason first; tooltip can add detail.

## Overlay Opacity Rules

Proposed ranges:

- Passive battlefield support: 0.16 to 0.28.
- Active objective overlay: 0.34 to 0.52.
- Critical alert overlay: 0.58 to 0.72, temporary only.
- Disabled/muted state: 0.42 to 0.62 on non-text layers, text remains readable.

Rules:

- Text contrast remains independently checked.
- Lume links should not obscure units or health bars.

## Lume Teal Usage

Role:

- Living land-power, linked sites, restoration, network effects, safe mystical opportunity.

Rules:

- Use sparingly.
- Do not use Lume teal as generic UI blue.
- Pair with dark stone or muted earth, not neon gradients.
- Lume teal must remain distinct from friendly selection and normal resource states.

## Ashen Fire Usage

Role:

- Rival doctrine, overcharge, hostile elite pressure, danger, burned terrain/finale emphasis.

Rules:

- Keep disciplined and controlled; avoid generic lava everywhere.
- Use for threat and transformation, not every button hover.
- Pair with blackened iron, smoke, ember, and harsh silhouette.

## Barrosan Granite And Hearth Usage

Role:

- Player-facing foundation, villages, defensive stewardship, craft, shelter, human resilience.

Rules:

- Granite anchors panels and buildings.
- Hearth light marks safety, action, and humane warmth.
- Wet roads/timber accents support the Salto/highland identity.
- Avoid beige parchment overload.

## Contrast And Accessibility Rules

- Body text should target WCAG AA contrast where practical.
- State color must have label, icon, border, pattern, or copy support.
- Avoid red/green-only ownership distinctions.
- Timers and cooldowns require numeric or progress support.
- Small text should not sit over noisy art.
- Future art must reserve safe negative-space zones for HUD labels.

## Future Runtime Token Gate

A later implementation may promote these names into CSS variables or TypeScript design-token registries only after:

- v0.88 docs are reviewed.
- At least one HUD/campaign style frame is approved.
- Visual QA coverage confirms no screen regresses.
- Existing runtime IDs and save data remain untouched.
