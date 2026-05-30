# v0.79 Direction Lock Summary

Status: docs-only direction lock.

v0.79 converts Emmanuel's review decisions into an explicit strategic lock. The lock is directional, not executable. It should guide later milestones, but it does not change the current browser prototype.

## Locked Now

1. Public identity direction
   - Lead direction: `JARDAS: Oath of the Barrosan Marches`.
   - Logo hierarchy: `JARDAS` dominant, subtitle secondary.
   - `Ascendant Realms` remains the internal repository codename.

2. World identity
   - Salto is the opening village and emotional home.
   - The Barrosan Marches are the wider frontier region.
   - Lume is the ancient living power beneath the land.
   - The world is dark heroic fantasy rooted in Barrosan highland inspiration, not a literal copy of Portugal.

3. Jardas identity
   - A Jardas is an oath-bound hero who can awaken, bind, defend, and guide Lume sites.
   - The role is stewardship and responsibility, not consequence-free resource ownership.

4. Rival direction
   - Captain Malrec remains the Act 1 rival.
   - He should read as intelligent, charismatic, dangerous, disciplined, and partially understandable.

5. Race-roster structure
   - One human civilization.
   - One mixed altered civilization.
   - Six strongly non-human civilizations.
   - Public names remain strong working names until later final-name lock.

6. Hero architecture
   - Future heroes are planned around Race, Class, Origin, Oath, skill allocation, equipment, relics, and unlimited soft-scaled levelling.
   - Class working roster: Marshal, Warden, Seer, Binder, Hunter, Artificer, Shepherd.

7. First signature system priority
   - Lume Network is the first future major signature gameplay pillar to receive a dedicated design gate.

8. Campaign spine
   - Five-act direction is approved as the leading structure.

9. Visual direction
   - Modern dark heroic-fantasy RTS/RPG.
   - Tactical readability first.
   - Strong silhouettes, tactile UI, dramatic lighting, fog, rain, wet terrain, granite, hearth fire, shrines, springs, mines, old roads, winter masks, and distinctive non-human races.

10. Browser-to-desktop strategy
   - Browser prototype remains the correct current development vehicle.
   - Future desktop transition requires a separate engine and packaging gate.
   - The final desktop game must not feel like a browser game merely wrapped inside an executable.

## Explicitly Not Locked

- Formal trademark clearance.
- Formal legal review.
- Final commercial-title lock.
- Final race-name lock.
- Exact race rosters.
- Exact unit and building rosters.
- Runtime display-copy migration.
- Runtime internal-ID migration.
- Runtime save migration.
- Desktop engine selection.
- Art-generation approval.
- Runtime-art approval.
- Multiplayer architecture.

## Runtime Boundary

No runtime behavior changes are included in v0.79.

No stable internal IDs are renamed. Existing IDs such as `free_marches`, `ashen_covenant`, `ashen_outpost`, current class IDs, unit IDs, item IDs, map IDs, node IDs, ability IDs, and save fields remain untouched.

No save-version bump or save field change is included.

No art or asset files are generated, imported, downloaded, or wired.

## Practical Use

Future milestone proposals should use this lock as the top-level product compass:

- If a proposed change strengthens Jardas, Salto, Lume, the Barrosan Marches, tactical readability, or distinct non-human race identity, it may fit the direction.
- If a proposed change requires runtime rebranding, ID migration, save migration, art generation, new race implementation, desktop porting, or Lume Network runtime work, it needs a later explicit goal.
- If a proposed change starts v0.80, v0.81, or v0.82 during v0.79, it is out of scope.
