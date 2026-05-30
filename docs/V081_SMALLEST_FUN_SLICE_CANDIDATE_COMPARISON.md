# v0.81 Smallest Fun Slice Candidate Comparison

Status: docs-only comparison. No Lume Network runtime prototype was started.

## Evaluation Criteria

Each candidate is evaluated for fun, clarity, uniqueness, player agency, tactical counterplay, architecture fit, implementation complexity, UI cost, test cost, AI cost, map dependency, save safety, replay safety, Tutorial safety, economy risk, tedium risk, race-extensibility value, and suitability for the first browser prototype.

## Candidate A: Linked Control

Concept:

- One existing campaign battle has predefined eligible sites.
- Controlling two connected sites activates one visible Lume link.
- The linked pair grants one modest battle-local benefit.
- Enemy recapture severs the link.
- No persistence, new map, new resource, Living Mines, or broad AI rewrite.

Strengths:

- Best architecture fit. Existing `CaptureSite.owner` and `ResourceSystem` capture updates already define activation and severing.
- Easy to teach: "Hold both linked sites to wake the Lume."
- Good player agency: choose whether to defend the link or push elsewhere.
- Natural counterplay: enemy recapture breaks it.
- Low save risk: derived from battle-local ownership.
- Low UI cost: one HUD row plus selected-site summary.
- Low test cost: pure link resolver plus ResourceSystem ownership tests.

Weaknesses:

- Less explicit about the Jardas role.
- If the benefit is resource income, it can become hidden math or economy snowball.
- Needs careful map choice so site pairing is tactically visible.

Verdict: strongest base candidate.

## Candidate B: Jardas Binding

Concept:

- Capturing a site is not enough.
- The hero/Jardas must bind an eligible captured site through a short interaction.
- Bound sites activate links.

Strengths:

- Strongest identity fit. The player feels the hero awaken the land.
- Clear future bridge to hero race/class/oath identity.
- Stronger fantasy than capture-only.

Weaknesses:

- Adds a second interaction on top of capture, Worker assignment, site upgrade, mission objectives, enemy pressure, tactical plans, Retinue, hero abilities, and relics.
- Harder UI: needs binding command, binding progress, disabled reasons, interruption rules, and selection feedback.
- Higher pathing/control risk because the hero must be sent to sites for a non-combat action.
- Higher test cost.
- Can become tedious if every site needs binding.

Verdict: excellent future option, too much friction for the first proof-of-fun unless Emmanuel explicitly prioritizes hero identity over simplicity.

## Candidate C: Mission-Local Lume Objective

Concept:

- One existing campaign mission gains a tightly scoped Lume objective.
- Link two or three eligible sites.
- Protect the link briefly or use it to support one mission-local tactical goal.
- Introduce Lume through mission briefing, HUD objective, and Results.

Strengths:

- Strong teaching frame: one mission tells the player why links matter.
- Best replay and rollout safety because the rule is mission-local.
- Keeps the system out of Tutorial, skirmish, and finale until proven.
- Can use one objective row rather than a broad new UI.
- Supports a more flavorful benefit without global economy changes.

Weaknesses:

- Slightly more content-specific than pure Linked Control.
- If too scripted, it may feel like a mission gimmick instead of a foundational system.
- Needs careful copy so players understand this is a prototype for a future general system.

Verdict: safest introduction shell, especially when combined with Candidate A rules.

## Candidate Comparison Table

| Criterion | Candidate A: Linked Control | Candidate B: Jardas Binding | Candidate C: Mission-Local Objective |
| --- | --- | --- | --- |
| Fun | Medium-high | Medium if friction is low | High if objective is clear |
| Clarity | High | Medium | High |
| Uniqueness | Medium | High | High |
| Player agency | High | Medium | Medium-high |
| Tactical counterplay | High | Medium-high | High |
| Architecture fit | High | Medium | High |
| Implementation complexity | Low | Medium-high | Medium |
| UI cost | Low | Medium-high | Low-medium |
| Test cost | Low | Medium-high | Medium |
| AI cost | Low | Low-medium | Low |
| Map dependency | Medium | Medium | Medium-high |
| Save safety | High | High if battle-local | High |
| Replay safety | High | High if battle-local | High |
| Tutorial safety | High | Medium | High |
| Economy risk | Low if non-income benefit | Low | Low if non-income benefit |
| Tedium risk | Low | Medium-high | Low |
| Race extensibility | Medium-high | High | High |
| Browser prototype fit | High | Medium | High |

## Recommendation

Recommend a small hybrid:

> Candidate C shell with Candidate A rules: a mission-local Linked Control prototype.

The future runtime prototype should apply to one existing mission, use capture-only activation, predefined eligible sites, maximum three eligible nodes, maximum two active links, one primary benefit, one HUD row, one Results row, and no persistent Lume state.

Hero/Jardas binding should remain an explicit Emmanuel approval decision after the first link prototype is reviewed.

## Non-Recommendation

Do not start with a universal network system. Do not start with Living Mines. Do not start with hero binding unless Emmanuel rejects capture-only. Do not start with race-specific variants. Do not start in the Act 1 finale.
