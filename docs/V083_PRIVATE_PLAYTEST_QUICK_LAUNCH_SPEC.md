# v0.83 Private Playtest Quick Launch Spec

## Scope

v0.83 adds a package/local-development-only quick launch for the Aether Well Lume demo so Emmanuel can test the v0.82 Lume Network slice without clearing prerequisites.

## Tool Visibility

- Visible only in local development builds or private playtest packages.
- Hidden from ordinary production builds.
- Exposed from the Campaign Map, not from the public main menu.
- Clearly labeled as a private playtest tool.

## Demo Launch

The quick launch starts:

- campaign node: `aether_well_ruins`,
- map: `broken_ford`,
- Lume Network: `aether_well_ruins_lume_ward`,
- existing Aether Surge mission modifier when safe,
- no campaign prerequisite check.

## Isolation Rules

- `rewardsDisabled` must be true.
- No hero XP, campaign XP, relic, item, resource, reputation, rival, Retinue, objective-credit, unlock, or node-completion persistence.
- No save-version bump or save field.
- Tutorial remains protected and does not expose the tool.
- Normal Aether Well campaign launches keep normal prerequisites and reward rules.
- Generic no-reward campaign launches must not enable Lume; only the explicit private demo may do so.

## UI Copy

The Campaign Map tool must say:

- "Private playtest demo",
- "Aether Well Lume",
- "Rewards and campaign progress are disabled."

The battle HUD and Results should repeat the same isolation warning.

## Package Rules

- Private playtest packages inject an explicit runtime flag into packaged `game/index.html`.
- The package verifier must require the v0.83 docs and private playtest tool marker.
- Clean package naming still follows the final commit short hash with no `-dirty` suffix after closeout.

## Deferrals

- No broader playtest-tool menu.
- No Lume unlock migration.
- No new demo content.
- No public production shortcut.
- No gameplay changes outside the explicit private launch.
