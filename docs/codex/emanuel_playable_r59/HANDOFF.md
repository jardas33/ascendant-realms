# R59 — one ordinary playable Claude + Codex review build

**Partial qualification; remaining live checks are held.** This is an isolated
human-review branch, not a production merge or an AAA-quality claim.
`QUALIFIED_R59_EMANUEL_PLAYABLE_CONVERGENCE_BUILD_FOR_HUMAN_PLAYTEST` has not yet
been achieved. Desktop control stopped on the human's physical Escape key;
the human then explicitly asked to keep it stopped. File work and headless
checks continue; no alternate desktop-control route is used.

## Foundation and surviving work

Worktree: `D:/ar-emanuel-playable-r59`. Branch:
`codex/emanuel-playable-convergence-r59`. The parent is the exact newest Claude
source at the start, Plan390 `ec1097818ba18b5107e761c094c729198f92cc76`, verified
against both tracked-clean `D:/ClaudeWork/ar-lane` and GitHub. Historical August
governance documents are not current branch facts. Claude Review23 was read.

This ports qualified presentation intentions onto that source rather than
merging experimental history: R43 combines R28 and R37–R42 (command panel
cleanup, readable objective/bounty, opening framing, hover, research and HQ
workspaces); R44 adds ability illustrations; R54/R55 add the Granitborn painted
construction gallery and bronze chassis. Five final UI/controller files remain
byte-exact to those sealed outputs.

R56 Castro Hold, R57 Roundhouse and R58 Castro Forge now load through their
normal building definitions. Construction, placement previews, portrait
selection, native model hull generation and gameplay all use the real models.
There is no review.gd swap, diagnostic scene, resource injection or fixture in
the public launch route. Authored scale/materials are exempt from the generic
borrowed-model widening/tint. All other building-definition bytes stay exact:
IDs, HP, costs, times, troop lists, research and population are unchanged.

The Forge owns two existing native particle systems at its authored anchors,
with no added point lights. They start at actual completion, stay off during
construction, and stop at native destruction. Four cold surfaces retain native
snow; the coal surface stays hot. New hull namespaces generate collision from
the candidate geometry, replacing the old review recipe's retained old hulls.
The three editable packed Blender sources are backed up outside the runtime in
`art_sources/granitborn_r59`; normal play needs no Blender installation.

Rejected characters (including R51/R53), older R45/R46 Hold variants and unused
R47–R53 worker dependencies are absent. The separate Reliquary battle HUD is an
alternative design, not a compatible additive patch over R55; it is not overlaid
here. Claude's existing menus, world, AI, balance and runtime fixes remain the
foundation. No main, protected canonical or Claude working-branch changes.

## Launch

Portable checkout launcher: double-click `PLAY_EMANUEL_REVIEW.bat` at this
worktree's root. The installed convenience launcher is
`D:/CodexData/review/AscendantRealms/RUN_ULTIMATE_CURRENT_BUILD.bat`, with its exact
branch/SHA/path pinned by `CURRENT_BUILD.json`. Install/update it from a committed
review using `tools/review/install_current_review.ps1`.

The launcher verifies the actual branch/HEAD, certified Godot4.6.3 SHA256,
ordinary main scene and private review profile, authored source cleanliness,
all pinned runtime bytes and critical thatch import settings. A cold checkout
receives a headless editor import before normal play. It checks required cache
outputs, rejects importer errors, and rechecks source integrity. A running game
from the same directory prevents a second writer to that profile. It never
silently labels a pre-existing process as the pinned SHA.

It prints its real branch/SHA and the incomplete qualification status before
launching. Main Menu → Skirmish → choose setup → Begin Battle. Select
**Granitborn** to see the new building family. On a fresh profile, Skirmish first
opens hero creation, then continues directly to setup. The review uses
`AscendantRealms_Emanuel_Playable_R59`, separately from ordinary player saves.

Direct normal launch (the convenience launcher adds identity safeguards):

```powershell
& "D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe" --path "D:\ar-emanuel-playable-r59\production\ascendant-realms-godot"
```

## Verified and not verified

Real public-route Computer Use captures at 1366×768 content, inside the native
window, show first-run hero creation, Standard/Easy Hollowspan setup, actual
loading progress, roof selection of the Hold, HQ worker training/completion,
occupied-site rejection with no spend, a valid ground click and real worker
construction of both new buildings. Roundhouse spends55timber/20stone and raises
capacity12→20 at natural completion. Forge spends145timber/50stone, completes
naturally and trains a real warrior. It is selected and produces normally.
The first warrior completes; a second was queued after a real rally order.
Its complete traversal was not observed before desktop control stopped.
Resources and time were never injected or accelerated; native passive food
income means food differs across screenshots taken at different wall times.

The independent QA copy and profile reproduce all39 focused integration checks:
normal definition binding, height/footprint/HP/population, actual new hulls
inside gameplay bounds, centre/side physics rays, architectural snow, mipmapped
thatch, native construction material restoration and particle lifecycle. Its
completion/destruction operations are deliberate fixtures, distinct from the
public route. The live game/profile is not touched by these headless jobs.
Native reload of a byte-preserved real UI-created profile passes13 checks,
retaining hero identity/progression, save version2 and Skirmish setup. This is
headless reload evidence, not a public GUI relaunch. Compile-all, economy,
combat and navigation-source tests pass; navigation source checks are not a
full routing rehearsal.

The historical `claude_sagacheck.gd` remains unchanged and reports12 BAD-map
lines. Its whitelist comes from `MapDefs.list_infos()`, which intentionally
excludes saga-only return fields. The underlying definitions and validator are
byte-exact to Claude's source. Dedicated R59 resolution checks all44 chapters
through the real `get_map` API, including an unknown-ID fallback control:
44resolve correctly, including all12hidden chapter entries. This preserves the
historical red result and documents its scope; it does not claim a campaign
playthrough or weaken its assertions.

Fresh import of the exact staged Git runtime tree also passes with no reused
cache: exit0, empty stderr,152.59seconds. All704pinned runtime files and23baseline
extracted image payloads remain exact; all455required cache outputs exist, and
the thatch preset survives. `COLD_IMPORT_VERDICT.json` records the runtime tree.
This headless import uses a separate COLD_QA profile and no desktop action.

Source audit: 863 original files exact, eight intentionally changed runtime
sources,212generated import-metadata changes excluded from authored staging,
14native HUD callbacks exact, all non-setup RTS methods exact and a single
qualified opening-focus helper added. Twenty-three untracked extracted
baseline textures are proven byte-exact to committed GLB image payloads and
remain generated dependencies. The ordinary player's primary/backup saves,
Claude's source and the prior dirty Codex lane stay unchanged.

Still required: full1920×1080 public route; a public snow match; complete rally
exit/traversal; public pause/settings and save/relaunch; human playtest. No full
match, performance, all-faction, audio or shipping qualification. Do not reduce
these requirements because desktop control is stopped.

## Critique and failures

The buildings now have distinct civic, housing and industrial roles in actual
play, and the construction paintings connect better to the settlement. The
battlefield still trails the reference strongly: repeating low grass, sparse
composition, coarse resource piles, modest lighting and weak small characters.
The thatch reads too simple from this distance; masonry/slate repeat, and the
Forge rear and details need better material work. The production header is
generic, several troop portraits repeat, training copy can truncate, and notices
can overlap hovered tooltips. This build makes those combined weaknesses
reviewable; it does not excuse them or call them AAA.

Retained failures include Windows autocrlf hash mismatches during porting; one
indentation error in the new snow binding; eager SceneTree class loading and
disabled-physics fixture mistakes; first-import missing thatch caused by an
import descriptor referring to an absent generated PNG. Repairs preserve
assertions: per-command LF application, corrected binding, deferred native loads,
callbacks disabled without removing physical bodies, exact embedded PNG
extraction and a fresh owned Roundhouse import. The final normal source includes
that PNG so a fresh checkout does not repeat the missing-source condition.
ObjectDB shutdown and portrait-camera interpolation warnings are retained.

All original/failed logs and21native window captures live at
`D:/CodexData/evidence/ar-playable-convergence-r59-20261021`. Selected images here
are byte-exact originals. Recovery pushes are authorized for this dedicated
review branch only. Human visual approval and canonical promotion remain held.
