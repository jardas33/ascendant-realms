import fs from "node:fs";
import path from "node:path";

const repo = process.cwd();
const scene = "desktop-spikes/godot-salto/scenes/v0367_first_playable_vertical_slice.tscn";
const script = "desktop-spikes/godot-salto/scripts/v0367_first_playable_vertical_slice.gd";
const rootScript = "desktop-spikes/godot-salto/scripts/salto_spike_root.gd";
const report = "docs/V0367_ASCENDANT_REALMS_FIRST_PLAYABLE_VERTICAL_SLICE_REPORT.md";
const review = path.join(repo, "artifacts/manual-review/v0367-first-playable-vertical-slice");
const upload = path.join(review, "UPLOAD_TO_CHAT");
const smoke = path.join(repo, "artifacts/runtime/v0367/v0367-playable-smoke.json");

function fail(message) { console.error(`FAIL_V0367_FIRST_PLAYABLE_VERTICAL_SLICE: ${message}`); process.exitCode = 1; }
function read(file) { return fs.readFileSync(path.join(repo, file), "utf8"); }
function assert(condition, message) { if (!condition) throw new Error(message); }
function pngs(dir) { return fs.existsSync(dir) ? fs.readdirSync(dir).filter((name) => name.toLowerCase().endsWith(".png")) : []; }

const mode = process.argv[2] ?? "validate";
try {
  const source = read(script);
  const launcher = read(rootScript);
  assert(fs.existsSync(path.join(repo, scene)), "playable scene missing");
  assert(fs.existsSync(path.join(repo, report)), "report missing");
  assert(source.includes("_update_workers") && source.includes("_deposit_worker"), "worker gather/deposit loop missing");
  assert(source.includes("_try_place") && source.includes("_update_construction"), "construction loop missing");
  assert(source.includes("_recruit_militia") && source.includes("_update_training"), "recruitment loop missing");
  assert(source.includes("_update_militia") && source.includes("_update_enemies") && source.includes("_check_deaths"), "combat/death loop missing");
  assert(source.includes("_end_match") && source.includes("VICTORY") && source.includes("DEFEAT"), "result state missing");
  assert(source.includes("_start_match") && source.includes("KEY_R"), "restart path missing");
  assert(launcher.includes("play_v0367") && launcher.includes("--v0367-playable"), "launcher route missing");
  assert(source.includes("barrosan_house_02_material_gold_candidate.glb") && source.includes("BarrosanBarnGold.tscn"), "accepted clean asset sources missing");
  assert(!source.includes("get_tree().change_scene") && !source.includes("set_meta(\"fake\""), "scripted route shortcut detected");
  if (mode === "smoke") {
    assert(fs.existsSync(smoke), "smoke manifest missing");
    const result = JSON.parse(fs.readFileSync(smoke, "utf8"));
    assert(result.status === "PASS", "smoke manifest failed");
    for (const key of ["goldDeposited", "barracksBuilt", "militiaRecruited", "combatResolved", "victory", "restartRestored"]) assert(result[key] === true, `${key} was not proven by smoke`);
    console.log("PASS_V0367_FIRST_PLAYABLE_VERTICAL_SLICE_SMOKE");
  } else if (mode === "pack") {
    fs.mkdirSync(upload, { recursive: true });
    const expected = ["00_READ_ME_FIRST.md", "01_SLICE_START_PLAYER_VIEW.png", "02_ECONOMY_AND_CONSTRUCTION.png", "03_COMBAT_AND_RESULT.png", "04_RESTARTED_MATCH_PLAYER_VIEW.png"];
    for (const name of expected) {
      const sourcePath = path.join(review, name);
      assert(fs.existsSync(sourcePath), `capture missing: ${name}`);
      fs.copyFileSync(sourcePath, path.join(upload, name));
    }
    fs.writeFileSync(path.join(upload, "00_READ_ME_FIRST.md"), read(path.relative(repo, path.join(review, "00_READ_ME_FIRST.md")), "utf8"), "utf8");
    console.log("PASS_V0367_FIRST_PLAYABLE_VERTICAL_SLICE_PACK");
  } else {
    assert(fs.existsSync(path.join(repo, "artifacts/manual-review/v0367-first-playable-vertical-slice/00_READ_ME_FIRST.md")), "review README missing");
    assert(pngs(review).length === 4, "expected four raw review captures");
    for (const file of pngs(review)) assert(fs.statSync(path.join(review, file)).size > 10000, `${file} is too small to be gameplay evidence`);
    console.log("PASS_V0367_FIRST_PLAYABLE_VERTICAL_SLICE");
  }
} catch (error) { fail(error.message); }
