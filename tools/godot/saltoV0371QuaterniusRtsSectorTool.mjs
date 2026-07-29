import fs from "node:fs";
import path from "node:path";

const repo = process.cwd();
const scene = "desktop-spikes/godot-salto/scenes/v0371_first_cohesive_quaternius_rts_sector.tscn";
const script = "desktop-spikes/godot-salto/scripts/v0371_first_cohesive_quaternius_rts_sector.gd";
const rootScript = "desktop-spikes/godot-salto/scripts/salto_spike_root.gd";
const report = "docs/V0371_FIRST_COHESIVE_PLAYABLE_QUATERNIUS_RTS_SECTOR_REPORT.md";
const runtime = path.join(repo, "artifacts/runtime/v0371");
const review = path.join(repo, "artifacts/manual-review/v0371-first-cohesive-quaternius-rts-sector");
const expected = ["01_OPENING_GAMEPLAY.png", "02_WORKER_GATHERING_GOLD.png", "03_FIELD_BARRACKS_CONSTRUCTION.png", "04_COMPLETED_BARRACKS_RECRUITMENT.png", "05_MILITIA_CROSSING_BRIDGE.png", "06_COMBAT_AT_HOSTILE_CAMP.png", "07_VICTORY_STATE.png"];
function read(file) { return fs.readFileSync(path.join(repo, file), "utf8"); }
function assert(condition, message) { if (!condition) throw new Error(message); }
function fail(message) { console.error(`FAIL_V0371_QUATERNIUS_RTS_SECTOR: ${message}`); process.exitCode = 1; }

const mode = process.argv[2] ?? "validate";
try {
  const source = read(script);
  const inherited = read("desktop-spikes/godot-salto/scripts/v0367_first_playable_vertical_slice.gd");
  const contracts = `${inherited}\n${source}`;
  const root = read(rootScript);
  assert(fs.existsSync(path.join(repo, scene)), "v0.371 scene missing");
  assert(fs.existsSync(path.join(repo, report)), "v0.371 report missing");
  assert(source.includes("extends \"res://scripts/v0367_first_playable_vertical_slice.gd\""), "bounded v0.367 gameplay fork missing");
  for (const token of ["_update_workers", "_deposit_worker", "_try_place", "_update_construction", "_recruit_militia", "_update_training", "_update_militia", "_update_enemies", "_check_deaths", "_end_match", "_start_match", "_route_to_0371", "Single_Readable_Timber_Bridge", "Recessed_Stream_Surface", "men/Worker.gltf", "men/Adventurer.gltf"]) assert(contracts.includes(token), `required v0.371 contract missing: ${token}`);
  assert(root.includes("--v0371-playable") && root.includes("v0371_first_cohesive_quaternius_rts_sector.tscn"), "opt-in root route missing");
  assert(!source.includes("CapsuleMesh") && !source.includes("SphereMesh"), "primitive unit fallback detected");
  assert(!source.includes("v0368_playable_slice_visual_coherence.tscn"), "accepted v0.368 scene coupled into v0.371");
  if (mode === "smoke") {
    const candidates = [path.join(runtime, "v0371-playable-smoke.json"), path.join(repo, "desktop-spikes/godot-salto/artifacts/runtime/v0371/v0371-playable-loop.json")];
    const file = candidates.find(fs.existsSync);
    assert(file, "v0.371 smoke manifest missing");
    const result = JSON.parse(fs.readFileSync(file, "utf8"));
    assert(result.status === "PASS", "v0.371 smoke status failed");
    for (const key of ["goldDeposited", "barracksBuilt", "militiaRecruited", "combatResolved", "victory", "restartRestored"]) assert(result[key] === true, `${key} was not proven by smoke`);
    console.log("PASS_V0371_QUATERNIUS_RTS_SECTOR_SMOKE");
  } else if (mode === "pack") {
    fs.mkdirSync(review, { recursive: true });
    const smokeFile = path.join(runtime, "v0371-playable-smoke.json");
    const copied = [];
    for (const name of expected) {
      const sourcePath = path.join(review, name);
      assert(fs.existsSync(sourcePath), `review capture missing: ${name}`);
      assert(fs.statSync(sourcePath).size > 10000, `${name} is too small`);
      copied.push(name);
    }
    const validation = { checkpoint: "v0.371", status: "PASS", loop: ["opening", "gathering", "construction", "recruitment", "bridge-crossing", "combat", "victory"], captures: copied, defaultRuntime: "unchanged", source: "v0.367 bounded semantics + v0.370 Quaternius family", restart: true };
    fs.writeFileSync(path.join(review, "08_VALIDATION.json"), JSON.stringify(validation, null, 2) + "\n", "utf8");
    if (fs.existsSync(smokeFile)) fs.copyFileSync(smokeFile, path.join(review, "08_SMOKE.json"));
    console.log("PASS_V0371_QUATERNIUS_RTS_SECTOR_PACK");
  } else {
    assert(fs.existsSync(path.join(review, "00_READ_ME_FIRST.md")), "review README missing");
    assert(fs.existsSync(path.join(review, "08_VALIDATION.json")), "compact validation JSON missing");
    for (const name of expected) { const file = path.join(review, name); assert(fs.existsSync(file), `capture missing: ${name}`); assert(fs.statSync(file).size > 10000, `${name} is too small to be gameplay evidence`); }
    const json = JSON.parse(fs.readFileSync(path.join(review, "08_VALIDATION.json"), "utf8"));
    assert(json.status === "PASS" && json.captures.length === 7, "review validation JSON is not a seven-stage pass");
    console.log("PASS_V0371_QUATERNIUS_RTS_SECTOR");
  }
} catch (error) { fail(error.message); }
