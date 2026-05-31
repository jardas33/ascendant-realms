# v0.93 Runtime UI Token Implementation Spec

Checkpoint: v0.93 Runtime UI Foundation Tokens and Mission-Panel State Reset

## Intent

Promote the v0.88 UI design-token proposal into a small runtime token layer that improves consistency without redesigning the game. This milestone is presentation-only: no gameplay systems, campaign progression, rewards, saves, stable ids, runtime title, art assets, imported images, desktop port, or balance values change.

## Token Layer

Runtime tokens live in `src/game/styles/tokens.css` and are imported before the rest of the UI stylesheet stack.

The initial layer covers:

- Typography: display title, section heading, panel heading, card heading, primary body, compact body, caption, and HUD numeric text.
- Spacing: `4`, `8`, `12`, `16`, `24`, `32`, and `48` pixel steps.
- Panels: shell, primary, secondary, tertiary, overlay, and alert treatments.
- Borders: hairline, panel, selected, available, locked, hostile, and objective.
- States: selected, available, locked, hostile, friendly, neutral, completed, and replayable.
- Radius and shadow tokens for panel/card hierarchy.
- Controlled identity colors for Lume teal, Ashen fire, Barrosan granite, and hearth accents.

## Runtime Adoption

The first runtime adoption pass touches only existing CSS surfaces:

- Base shell and text defaults.
- Main menu panel shell.
- Hero creation and selection forms.
- Hero inventory/progression surfaces.
- Campaign map, selected mission panel, campaign tabs, and node states.
- Results overview/details typography.
- Battle HUD objective tracker, command panel, and selected-unit summaries.

## Typography Rules

- No viewport-width font scaling was added.
- Body copy uses readable fixed token sizes at `1366x768`.
- Uppercase is reserved for short labels, not paragraphs.
- Long campaign and Results prose remains behind existing disclosure controls.
- RTS density is preserved through compact body and caption tokens instead of shrinking prose to unreadable sizes.

## Panel Hierarchy Rules

- Campaign and Results panels use quieter tokenized panel borders and backgrounds.
- Nested card effects are avoided for selected mission and tab content.
- Lume teal remains a sparse signal color for availability, links, and objective affordance; it is not used as a dominant wash.

## Non-Goals

- No token-driven redesign of every selector.
- No visual assets, image generation, icon import, or new art pipeline.
- No gameplay, reward, campaign, save, or stable-ID change.
- No public title or runtime rebrand.
- No desktop implementation.
