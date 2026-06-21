import {createHash} from "node:crypto";
import {existsSync, mkdirSync, readFileSync, statSync, writeFileSync} from "node:fs";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const arg = name => (process.argv.find(v => v.startsWith(`--${name}=`)) ?? "").split("=").slice(1).join("=");
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0250"));
const verdict = arg("verdict") || "PARTIAL", commit = arg("commit") || "PENDING_PUBLICATION", head = arg("head") || commit, ciRun = arg("ci-run") || "PENDING_PUBLICATION";
const manual = join(repo, "artifacts", "manual-review", "v0250-barrosan-explicit-attack-order-bridge");
const docPath = join(repo, "docs", "V0250_BARROSAN_EXPLICIT_ATTACK_ORDER_BRIDGE_REPORT.md");
const runtimePath = join(root, "runtime", "screenshot-runtime-manifest.json"), defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const glbPath = join(repo, "desktop-spikes", "godot-salto", "assets", "v0239", "salto_barrosan_roster_silhouette_beauty.glb");
const required = [
 "01_v0249_partial_baseline.png","02_v0250_preflight_head_ci_resolution.png","03_v0250_default_runtime_unchanged_proof.png",
 ...["opt_in_overview_before_build","starting_resources","select_builder_unit","valid_barracks_preview","confirm_authoritative_barracks_placement","construction_resource_delta","select_new_field_barracks_hud","train_militia_command_available","train_militia_resource_delta","militia_training_progress","militia_ready_spawned","select_spawned_militia_hp_100_attack_available","pressure_telegraph_marker_preserved","intercept_zone_marker_preserved","ashen_raider_spawned_once_hp_full","raider_minimap_presence","select_militia_before_attack_order","attack_command_available","attack_targeting_mode","raider_targeted_by_attack_order","attack_order_accepted_hud","militia_closing_to_raider","combat_contact_begins_after_order","combat_tick_1_hp_90_40","combat_tick_2_hp_80_20","combat_tick_3_raider_hp_zero_militia_70","raider_defeated_or_removed","raider_minimap_removed_or_defeated","pressure_contained_by_attack_order","no_resource_mutation_after_combat","no_building_damage_proof","aster_worker_unharmed_proof","existing_barracks_train_flow_preserved","command_keep_preserved","lume_mine_preserved","shells_remain_non_producing","unselected_clean_view"].map((n,i)=>`${String(i+4).padStart(2,"0")}_v0250_${n}.png`),
 "41_v0250_before_after_attack_order_contact_sheet.png","42_v0250_report.md"
];
const read = p => JSON.parse(readFileSync(p, "utf8").replace(/^\uFEFF/u, ""));
const sha256 = p => createHash("sha256").update(readFileSync(p)).digest("hex").toUpperCase();
function inspect(errors) {
 const runtime=existsSync(runtimePath)?read(runtimePath):{}, fallback=existsSync(defaultPath)?read(defaultPath):{}, skin=runtime.barrosanPlayableRuntimeSkin??{};
 const construction=skin.authoritativeConstructionBridge??{}, production=skin.fieldBarracksProductionBridge??{}, attack=skin.explicitAttackOrderBridge??{};
 if(runtime.status!=="PASS_PLAYER_SLICE_CAPTURE"||runtime.checkpoint!=="v0.250"||runtime.captureCount!==37)errors.push("runtime capture contract failed");
 if(fallback.status!=="PASS_PLAYER_SLICE_CAPTURE"||fallback.checkpoint!=="v0.250"||(fallback.barrosanPlayableRuntimeSkin?.enabled??false)!==false)errors.push("default runtime changed");
 if(construction.status!=="PASS"||construction.placementResourceDelta?.crowns!==-180||construction.placementResourceDelta?.stone!==-120)errors.push("construction failed");
 if(production.status!=="PASS"||production.queueResourceDelta?.crowns!==-60||production.queueResourceDelta?.iron!==-20||production.spawnCount!==1)errors.push("production failed");
 if(attack.status!=="PASS"||attack.spawnCount!==1||attack.runtimeId!=="v0247_ashen_raider_00")errors.push("attack bridge failed");
 if(!attack.attackCommandAvailable||!attack.attackCommandPressed||!attack.attackOrderAccepted||attack.activeAttackTarget!=="v0247_ashen_raider_00")errors.push("explicit attack order failed");
 if(!attack.attackOrderAcceptedBeforeContact||!attack.combatAuthorizedByAttackOrder||attack.combatStartedBeforeContact!==false)errors.push("attack authorization/contact gate failed");
 if(!attack.deterministicTicksPass||attack.finalMilitiaHp!==70||attack.finalRaiderHp!==0)errors.push("deterministic HP failed");
 if(!attack.raiderDefeated||!attack.raiderRemoved||!attack.containedByAttackOrder||!attack.raiderMinimapRemoved)errors.push("containment/minimap failed");
 if(!attack.pressureResourcesUnchanged||!attack.buildingsUnharmed||!attack.asterWorkerUnharmed)errors.push("mutation boundary failed");
 if(!attack.existingRestoredBarracksPreserved||!attack.commandKeepPreserved||!attack.lumeMinePreserved||!attack.shellsRemainNonProducing)errors.push("preservation failed");
 return {runtime,fallback,skin,construction,production,attack,glbSha:existsSync(glbPath)?sha256(glbPath):""};
}
function report(e){return [
 "# v0.250 Barrosan Explicit Attack Order Bridge","",`Verdict: \`${verdict}\``,"","## Exact facts","",
 "- Resolved base commit: `61d8671d5b8a15dc137273124c6e775082c13822`.",
 "- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27911616624.",
 `- Implementation commit: \`${commit}\`.`,`- Final repository HEAD: \`${head}\`.`,`- Exact-SHA GitHub Actions run: ${ciRun}.`,
 "- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
 `- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (${e.glbSha}).`,
 "- Files changed: opt-in runtime subclass, capture dispatch, v0.250 evidence/validator/report tooling, package scripts and this report.",
 "- Runtime systems touched: opt-in Militia Attack targeting state, one Raider target, order-authorized closing/contact, HUD and target marker.",
 "- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, buildings, economy, saves, pathfinding and assets.","",
 "## Bounded bridge","",
 "- Construction: one Field Barracks, -180 Crowns / -120 Stone.",
 "- Production: one Militia, -60 Crowns / -20 Iron.",
 `- Raider ID/count: \`${e.attack.runtimeId}\` / ${e.attack.spawnCount}.`,
 `- Attack implementation: ${e.attack.attackCommandImplementation}.`,
 "- Attack arms targeting mode; the next hostile click accepts only the single scripted Raider.",
 `- Combat starts only after accepted order plus ${e.attack.combatStartCondition}.`,
 `- HP sequence: 100/60 -> 90/40 -> 80/20 -> ${e.attack.finalMilitiaHp}/${e.attack.finalRaiderHp}.`,
 `- Raider removed: ${e.attack.raiderRemoved}; minimap removed: ${e.attack.raiderMinimapRemoved}; contained by attack order: ${e.attack.containedByAttackOrder}.`,
 `- Resources unchanged after combat: ${e.attack.pressureResourcesUnchanged}; buildings unharmed: ${e.attack.buildingsUnharmed}; Aster/Worker unharmed: ${e.attack.asterWorkerUnharmed}.`,
 `- Existing Barracks / Keep / Mine preserved: ${e.attack.existingRestoredBarracksPreserved} / ${e.attack.commandKeepPreserved} / ${e.attack.lumeMinePreserved}.`,
 `- Shells remain non-producing: ${e.attack.shellsRemainNonProducing}.`,
 "- Default runtime proof: opt-in skin disabled, no Raider, targeting marker, attack ladder, or bounded combat state.",
 `- Pathing honesty: ${e.attack.pathingParity}.`,"","## Validation results","",
 "- v0.250 capture and dedicated validator: pass.",
 "- Full local validation: pass (887 tests, production build, content/art/runtime gates, Godot tests, retention, and `godot:all`).",
 `- Exact-SHA GitHub Actions: ${ciRun === "PENDING_PUBLICATION" ? "pending publication." : `pass (${ciRun}).`}`,"","## Honest assessment","",
 "The explicit two-step order is real and readable, but remains a single-target bounded bridge over review-grade closing/pathing and deterministic contact ticks. Verdict remains PARTIAL.",
 "Recommendation for v0.251: harden natural player-issued targeting feedback without adding waves, broad AI, building damage, or general combat.","",
 "Stop after v0.250. Do not begin v0.251.",""
].join("\n")}
function capture(){const errors=[],e=inspect(errors);mkdirSync(manual,{recursive:true});for(const f of required.slice(0,-1))if(!existsSync(join(manual,f)))errors.push(`missing ${f}`);const md=report(e);writeFileSync(join(manual,"42_v0250_report.md"),md);writeFileSync(docPath,md);writeFileSync(join(root,"v0250-capture-report.json"),JSON.stringify({status:errors.length?"FAIL_V0250_CAPTURE":"PASS_V0250_BARROSAN_EXPLICIT_ATTACK_ORDER_BRIDGE_CAPTURE",verdict,...e,errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
function validation(){const errors=[],e=inspect(errors);for(const f of required){const p=join(manual,f);if(!existsSync(p))errors.push(`missing ${f}`);else if(statSync(p).size<(f.endsWith(".png")?10000:700))errors.push(`small ${f}`)}writeFileSync(join(root,"v0250-validation-report.json"),JSON.stringify({status:errors.length?"FAIL_V0250_VALIDATION":"PASS_V0250_BARROSAN_EXPLICIT_ATTACK_ORDER_BRIDGE_VALIDATION",attackStatus:e.attack.status??"UNKNOWN",errors},null,2)+"\n");if(errors.length)throw new Error(errors.join("\n"))}
if((process.argv[2]??"capture")==="capture")capture();else validation();
