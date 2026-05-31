# v0.88 Screen-By-Screen Visual Foundation

Status: planning-only visual foundation. This document does not approve image generation, runtime art import, gameplay redesign, save changes, stable ID changes, or engine decisions.

## Purpose

v0.88 prepares the visual pipeline for future controlled style-frame work. The goal is to make every major screen legible as a desktop RTS/RPG surface before any AI-assisted art pass begins.

The current runtime should remain placeholder-safe: procedural terrain, current UI CSS, current manifest slots, current package flow, and existing validation stay intact.

## Global Screen Rules

- Primary information must be visible without scrolling on the default desktop viewport.
- Secondary information should sit in compact cards, summary rows, or details disclosures.
- Expandable information may include telemetry, lore, extended tactical rationale, build hints, and full reward explanation.
- Desktop-quality presentation means strong hierarchy, dense but readable panels, precise alignment, stable spacing, and no phone-app composition.
- Mobile-like patterns are prohibited for this visual lane: bottom-tab app bars, oversized rounded pill navigation, one-column infinite card feeds, swipe-first controls, huge touch-only buttons, full-screen modal stacks for routine RTS actions, and gamified shop-style cards.
- Placeholder-safe approach means procedural shapes, CSS hierarchy, text labels, existing icons, and existing asset fallbacks are acceptable until human-approved final art exists.

## Main Menu

Essential information:

- Game title direction: `JARDAS: Oath of the Barrosan Marches` when public copy migration is explicitly approved; until then preserve current runtime name.
- Primary action: continue, campaign, or private playtest launch depending on current build.
- Build/package status and tester guidance when in private package mode.

Secondary information:

- Settings, accessibility, visual QA caveats, and tester notes.
- Current checkpoint and package identity.

Expandable information:

- Known placeholder-art caveats.
- Full tester instructions.

Visual priority:

- Title/action block first, then current playtest route, then settings/supporting notes.

Placeholder-safe approach:

- Keep current CSS panels and textual package guidance.
- Use restrained background treatment, not generated illustration.

Eventual final-art needs:

- Title background style frame, Barrosan hearth/granite identity pass, logo lockup, menu ambience.

Desktop-quality expectations:

- Centered but not mobile-splash-like; enough negative space for a PC game launcher feel.

Mobile-like patterns prohibited:

- Full-screen vertical button stack with huge rounded buttons and no campaign context.

## Campaign Map

Essential information:

- Map region visible immediately.
- Selected mission title, type, state, short description, primary objective, reward preview, pacing, lock reason, and primary action.
- Border Village remains selected for a fresh campaign.
- Locked Aether Well Ruins remains previewable.

Secondary information:

- Chapter lanes, route prerequisites, completion/replay markers, optional objective state.

Expandable information:

- Extended build hints, doctrine details, modifiers, rival notes, telemetry-style explanations, and longer rewards.

Visual priority:

- Map first, selected mission second, tabs third.

Placeholder-safe approach:

- Continue using CSS lanes, route lines, node chips, and current state classes.

Eventual final-art needs:

- Salto campaign map style frame, terrain landmark vocabulary, route-line motif, chapter framing.

Desktop-quality expectations:

- Wide readable map, no undifferentiated pile of cards, no default page scrolling in the Map tab.

Mobile-like patterns prohibited:

- Single-column mission feed as the default campaign presentation.

## Battle HUD

Essential information:

- Resources, selected unit/building/site state, active objective, event/doctrine warnings, hero health/mana/abilities, retinue/reinforcement readiness, and pause/menu access.

Secondary information:

- Detailed effect summaries, skill/relic synergy, patrol/control-group/order state, battlefield event explanation.

Expandable information:

- Full doctrine details, modifier explanation, Retinue recovery/reserve context, long ability text.

Visual priority:

- Playfield visibility first, command certainty second, tactical context third.

Placeholder-safe approach:

- Current CSS panels, existing icons, text chips, status rows, and procedural overlays remain acceptable.

Eventual final-art needs:

- HUD frame style frame, icon family, resource pips, commander/event plaques, selection frame treatment.

Desktop-quality expectations:

- Dense, sharp, readable, mouse-first. Panels should feel anchored to an RTS battlefield, not floating mobile widgets.

Mobile-like patterns prohibited:

- Oversized bottom sheet command tray, thumb-reach layout, or carousel action selection.

## Command Panel

Essential information:

- Current selection name/type/state, primary commands, costs, hotkeys, enabled/disabled status, and short disabled reasons.

Secondary information:

- Role tag, veterancy, ability effects, repair/build/site assignment detail, current order.

Expandable information:

- Long command descriptions, full upgrade explanation, future build lore.

Visual priority:

- Actionability first; explanation only after the player can see what can be done.

Placeholder-safe approach:

- Existing command buttons, details rows, disabled copy, and tooltips.

Eventual final-art needs:

- Command-button frame, icon-size hierarchy, ability cooldown material, disabled-state material.

Desktop-quality expectations:

- Compact enough to protect the playfield; precise labels and stable button sizes.

Mobile-like patterns prohibited:

- Giant icon grid that hides command reasons or requires horizontal swipe.

## Minimap

Essential information:

- Player/enemy presence, mission-critical locations, capture sites, selected viewport, attack/event pings.

Secondary information:

- Lume link context, doctrine pressure, objective site priority.

Expandable information:

- None by default; minimap should stay scannable.

Visual priority:

- Spatial orientation first, tactical warning second.

Placeholder-safe approach:

- Current SVG/marker minimap and existing color/state distinctions.

Eventual final-art needs:

- Frame treatment, marker icon family, objective ping states.

Desktop-quality expectations:

- Small but crisp; no blurred decorative map texture that obscures markers.

Mobile-like patterns prohibited:

- Full-screen map replacement for routine RTS awareness.

## Capture Sites

Essential information:

- Owner, capture progress, resource type, worker slot/status, upgrade state, objective/event relevance.

Secondary information:

- Lume link contribution, enemy pressure, upgrade benefits.

Expandable information:

- Detailed production math, extended lore.

Visual priority:

- Owner and capture status first, then resource/workers, then special context.

Placeholder-safe approach:

- Existing rings, labels, progress arcs, resource icons/fallback circles.

Eventual final-art needs:

- Site props, mine/shrine/spring silhouettes, faction claim markers, readable capture effects.

Desktop-quality expectations:

- Readable at RTS zoom; labels must not bury units or health bars.

Mobile-like patterns prohibited:

- Large tap cards hovering over the battlefield as the primary site UI.

## Lume Links

Essential information:

- Active/restored/contested/severed state, linked endpoints, objective relevance, current benefit.

Secondary information:

- Auto/Always/Hidden visibility mode, counterplay hint.

Expandable information:

- Full Lume rule explanation, future lore, telemetry.

Visual priority:

- Only relevant links during play, all links only when intentionally shown.

Placeholder-safe approach:

- Current procedural teal link lines, opacity states, and labels.

Eventual final-art needs:

- Lume energy style frame, endpoint glyphs, non-noisy activation effect.

Desktop-quality expectations:

- Atmospheric but never confusing; the battlefield remains readable.

Mobile-like patterns prohibited:

- Bright full-screen path overlays that behave like a puzzle-game hint layer.

## Results

Essential information:

- Victory/defeat, mission name, time, primary objective result, key rewards, hero XP, important veterans, Retinue highlights, and return/replay actions.

Secondary information:

- Relic choice/equip state, skill reminder, optional objectives, first-clear/replay status.

Expandable information:

- Full battle telemetry, unit stats, resources, modifiers, Retinue details, doctrine/event history.

Visual priority:

- Outcome and next action first, detailed analysis second.

Placeholder-safe approach:

- Current overview/full-details split and private-demo Results branch.

Eventual final-art needs:

- Debrief frame, victory/defeat typographic lockup, reward/veteran icon treatment.

Desktop-quality expectations:

- Primary actions visible without scrolling; longer reports read like a PC strategy debrief.

Mobile-like patterns prohibited:

- Endless reward-card cascade or loot-box-style reveal flow.

## Hero Screen

Essential information:

- Hero level/XP, skill points, equipped relic/build identity, active skill branch, major stat changes.

Secondary information:

- Ability upgrade summaries, relic synergy, detailed skill descriptions.

Expandable information:

- Full skill tree explanation, future class/origin lore, long ability math.

Visual priority:

- Build identity and next meaningful choice first.

Placeholder-safe approach:

- Existing hero/inventory surfaces and textual summaries.

Eventual final-art needs:

- Hero portrait style, class/build emblems, relic frame, skill icon family.

Desktop-quality expectations:

- Character-sheet clarity without a full paper-doll system.

Mobile-like patterns prohibited:

- Gacha-character card styling or full-screen portrait-first layout that hides build choices.

## Inventory

Essential information:

- Equipped relic, owned relics/items, available equipment actions, effect summaries.

Secondary information:

- Build archetype tags, duplicate/owned status, inventory categories.

Expandable information:

- Long relic lore, future acquisition history, deferred crafting/shop notes.

Visual priority:

- Equipped state first, then actionable owned inventory.

Placeholder-safe approach:

- Current item slots, text summaries, existing details disclosures.

Eventual final-art needs:

- Relic icon set, inventory material frame, rarity/acquisition markers.

Desktop-quality expectations:

- Compact RPG loadout support, not a broad loot game.

Mobile-like patterns prohibited:

- Huge item cards, rarity confetti, shop-like inventory browsing.

## Stronghold

Essential information:

- Core base status, available production/building guidance, resource role reminders, next campaign utility.

Secondary information:

- Building roles, upgrade reminders, defensive posture notes.

Expandable information:

- Long economy explanation, future stronghold upgrades, lore.

Visual priority:

- Current actionable state first, explanation second.

Placeholder-safe approach:

- Existing card hierarchy and details disclosures.

Eventual final-art needs:

- Barrosan settlement frame, building vignette style, hearth/granite material.

Desktop-quality expectations:

- Management surface should feel like a PC strategy command screen, not a settlement mobile idle game.

Mobile-like patterns prohibited:

- Timers, collect buttons, city-builder monetization rhythm, decorative building cards with no action hierarchy.

## Intel

Essential information:

- Enemy doctrine, elite risk, mission modifiers, recommended counterplay, tactical plan reminder.

Secondary information:

- Doctrine history, rival commander notes, event possibilities.

Expandable information:

- Full doctrine explanations, telemetry-style pressure analysis, lore.

Visual priority:

- Threat and response first.

Placeholder-safe approach:

- Existing tabs/cards, text warnings, badges.

Eventual final-art needs:

- Enemy-doctrine insignia, parchment/stone report treatment, elite threat badges.

Desktop-quality expectations:

- Reads as actionable reconnaissance, not a lore wall.

Mobile-like patterns prohibited:

- Long stacked article cards with no summary or response line.

## Reputation

Essential information:

- Current reputation standing, faction relationship hints, Act/chapter status, future-facing lock state.

Secondary information:

- Deferred faction consequences, milestone notes.

Expandable information:

- Long faction lore, future diplomacy/contract design notes.

Visual priority:

- Current standing and what it means for the next playtest first.

Placeholder-safe approach:

- Existing card hierarchy and compact rows.

Eventual final-art needs:

- Faction crests, reputation meters, chapter banner art after approval.

Desktop-quality expectations:

- Strategic ledger feel, not a social-feed screen.

Mobile-like patterns prohibited:

- Badge collection wall or infinite faction card feed.

## Validation Gate

Before any future art generation:

- Emmanuel approves the relevant style-frame brief.
- Prompt template version is recorded.
- Asset manifest entry exists before generation.
- Source, license, tool, prompt version, and review status are recorded after generation.
- Art-intake validation remains green.
- Runtime integration remains separately gated.
