# Ascendant Realms — Playtest 3 Continuation K2
## Original Easy first-wave and real-combat qualification

## Classification

**BLOCKED_K2_H1_BUILDING_PENETRATION_REPRODUCED**

K2 is an observation-only qualification result. It does not authorize a combat repair. A secondary symptom was also present in all three runs: units entered attack/contact telemetry but no authoritative damage event was recorded after first contact. This is recorded as `BLOCKED_K2_H1_GROUP_SETTLING_NO_DAMAGE_AFTER_CONTACT`; it is not treated as a pass or as permission to change combat code.

## Scope and protection

- Worktree: `D:\CodexData\worktrees\ascendant-realms-playtest3-continuation-k`
- Branch: `codex/local-playtest3-continuation-k`
- K1 base: `a67792e49adeadcd8f14e10625a9befefd6d8ae5`
- Production baseline remains unchanged after K1. K2 changes are limited to the qualification harness, validator, package commands, and this report.
- Protected checkout `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery` remains untouched at `ad4ef9f895a60748af3ac0be8def9028adaa9f6c`.
- Remote mutation: **NO**. No push, PR update, merge, promotion, rebase, R1K, v0.437, or destructive Git action occurred.

## Certified runtime

- Godot: `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`
- SHA-256: `ef90e929ba1a6a4322860285d97f40f4aa349c90329a91b0e8b55b8df0f4cb00`
- Match: Barrosan versus Lioraen, Easy, Hollowspan, Rich, Conquest, 2.0x.
- No state injection and no player offense before the first wave. The K1 beginner-economy driver was reused for the normal opening.
- Easy source configuration is unchanged and authoritative: think interval 2.0 seconds, seven-worker target, six-unit attack threshold, economy efficiency 0.7, technology aggression 0.6, brutal income 0.0. Normal source values remain 1.3 / 10 / 9 / 1.0 / 1.0 / 0.0.

## Execution and evidence

Three independent headed executions were completed. The first parse-failed attempt is excluded from qualification and is not counted as a final run. The final launcher completed runs 1–3 using the same certified runtime and wrote read-only precombat ledgers, first-wave snapshots, 10 Hz telemetry, route/building probes, and real gameplay captures.

Evidence root:

`D:\CodexData\evidence\ascendant-realms-playtest3-continuation-k\K2\`

Final evidence:

`D:\CodexData\evidence\ascendant-realms-playtest3-continuation-k\K2\FINAL\`

Representative rendered proof:

- `run-1\01_K2_BASE_OPENING.png` — real 1920x1080 gameplay opening.
- `run-1\05_K2_ACTIVE_COMBAT.png` — real 1920x1080 gameplay combat view.
- `run-3\12_K2_1366_FIRST_WAVE.png` — real 1366x768 first-wave view.
- `FINAL\07_MELEE_SETTLED.png`, `08_GROUP_SETTLED.png`, `09_RANGED_SETTLED.png`, `10_COMBAT_BESIDE_BUILDING.png`, `11_ROUTE_AROUND_BUILDING.png`, and `12_1366_FIRST_WAVE.png` — final evidence aliases.

The representative PNGs are nonblank rendered gameplay frames, not title cards or black placeholders. The visual evidence proves that the normal opening and first-wave scene were reached; it does not falsely claim that combat resolution passed.

## Run results

| Run | First wave/contact | First damage | Resolution | Enemy combat alive | Player combat alive | Player workers alive | Primary observation |
|---|---:|---:|---:|---:|---:|---:|---|
| 1 | 220.000 | -1 | 229.233 | 7 | 7 | 0 | strict building-footprint overlap reproduced |
| 2 | 220.700 | -1 | 229.800 | 7 | 7 | 0 | strict building-footprint overlap reproduced |
| 3 | 222.233 | -1 | 231.367 | 7 | 7 | 0 | strict building-footprint overlap reproduced |

Each run reached a qualified first wave. Each run recorded attack/contact telemetry but `first_damage = -1`; no authoritative post-contact damage event, casualty, or destruction was observed. Resources remained readable in the run ledgers and were not modified by the harness.

## H1 findings

- **Orbiting:** not reproduced from capture.
- **Building penetration:** reproduced in all three runs under the strict footprint test (`center_distance < footprint`). Repeated overlap samples were recorded: 162, 123, and 146 respectively.
- **Ranged overclosing:** not qualified as reproduced.
- **Group settling:** attack telemetry was observed, but stable combat resolution was not proven because no damage followed contact.
- **Combat correctness:** not qualified. The run reached contact but never produced authoritative damage.
- **Housing:** not a K2 blocker. One housing structure completed, the opening reached the required worker/force state, and no second housing was required by the tested production path.

The harness also records a wider clearance field for diagnosis; the authoritative validator classification uses the strict footprint criterion, so the result is not dependent on the wider diagnostic clearance.

## Validation

Passed or already completed for this closeout:

- `npm run godot:test:v0436-k2-combat-qualification`
- `npm run godot:validate:v0436-k2-combat-qualification`
- `npm run godot:test:v0436-k1-beginner-economy`
- `npm run godot:validate:v0436-k1-beginner-economy`
- `npm test`
- `npm run build`
- `git diff --check`
- explicit three-run headed K2 capture command: `npm run godot:capture:v0436-k2-combat-qualification`

The K2 validator returned exit 0 because the evidence contract is structurally valid; its truthful classification is the blocked H1 result above. The legacy Godot aggregate doctor still reports `GODOT_DOCTOR_AUTO_DISCOVERY_TOOLING_DEBT` / `BLOCKED_PENDING_LOCAL_GODOT_SETUP`; this remains tooling discovery debt, not a K2 gameplay pass.

The historical `FAIL_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION` diagnostic remains unchanged and is not repaired in K2.

## Change manifest

K2 source changes are limited to:

- `package.json` — K2 focused-test, capture, and validator commands.
- `production/ascendant-realms-godot/tests/v0436_r1h_capture.gd` — read-only K2 capture/telemetry path.
- `tools/godot/v0436K2CombatQualificationTool.mjs` — three-run orchestration and report/manifest writer.
- `tools/godot/v0436K2CombatQualificationTool.test.ts` — focused contract test.
- `tools/godot/v0436K2CombatQualificationValidatorContract.mjs` — evidence and H1 classification contract.
- `docs/V0436_PLAYTEST3_CONTINUATION_K2_REPORT.md` — this truthful qualification report.

No production gameplay file was changed. Generated Godot import/UID noise and two pre-existing artifact marker modifications remain unstaged and are not part of the K2 commit.

## Next safe priority

K2 should close as blocked. The next safe step is a separately authorized K3 combat-repair investigation focused on authoritative damage resolution and building-clearance/settling behavior. Do not begin that repair, alter Easy tuning, or change combat semantics until ChatGPT issues an explicit bounded authorization.
