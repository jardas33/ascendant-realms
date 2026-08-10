import fs from "node:fs/promises";
import path from "node:path";

const root = process.env.ASCENDANT_K3R_RICH_EVIDENCE || "D:/CodexData/evidence/ascendant-realms-playtest3-k3r-rich";
const output = path.join(root, "K3_OFFLINE_QUALIFICATION");

const readJson = async file => JSON.parse(await fs.readFile(file, "utf8"));
const writeJson = async (file, value) => {
  await fs.mkdir(path.dirname(file), { recursive: true });
  await fs.writeFile(file, `${JSON.stringify(value, null, 2)}\n`, "utf8");
};

function vector(value) {
  if (value && typeof value === "object" && Number.isFinite(value.x) && Number.isFinite(value.z)) return value;
  const match = String(value ?? "").match(/x=([\-\d.eE]+).*?z=([\-\d.eE]+)/);
  if (match) return { x: Number(match[1]), y: 0, z: Number(match[2]) };
  const tuple = String(value ?? "").match(/\(([-\d.eE]+),\s*[-\d.eE]+,\s*([-\d.eE]+)\)/);
  return tuple ? { x: Number(tuple[1]), y: 0, z: Number(tuple[2]) } : null;
}

function boxCollider(building) {
  return (building.colliders || []).find(c => c.shape_type === "BoxShape3D" && c.shape_size && Number.isFinite(c.shape_size.x));
}

function boxContains(point, building) {
  const center = vector(building.position);
  const collider = boxCollider(building);
  if (!point || !center || !collider) return null;
  return Math.abs(point.x - center.x) <= collider.shape_size.x / 2 && Math.abs(point.z - center.z) <= collider.shape_size.z / 2;
}

function navigationUnits(run) {
  return (run.samples || []).flatMap(sample => (sample.navigation?.units || []).map(unit => ({
    timestamp_seconds: Number(sample.simulation_time_seconds),
    ...unit,
    position: vector(unit.source),
  })));
}

function combatUnits(run) {
  return (run.samples || []).flatMap(sample => (sample.combat?.units || []).map(unit => ({
    timestamp_seconds: Number(sample.simulation_time_seconds),
    sample_label: sample.label,
    ...unit,
  })));
}

function targetPosition(unit) {
  return vector(unit.current_target?.position) || vector(unit.agent_target) || null;
}

function settlingSummary(units) {
  const byRuntime = new Map();
  for (const unit of units) {
    const id = String(unit.runtime_id ?? "");
    if (!id) continue;
    if (!byRuntime.has(id)) byRuntime.set(id, []);
    byRuntime.get(id).push(unit);
  }
  const settled = [];
  for (const [runtime_id, records] of byRuntime) {
    const attackSettled = records.filter(record => record.attack_settled === true);
    if (!attackSettled.length) continue;
    const targetIds = [...new Set(attackSettled.map(record => String(record.current_target?.runtime_id ?? "")).filter(Boolean))];
    const positions = attackSettled.map(record => vector(record.position)).filter(Boolean);
    settled.push({
      runtime_id,
      unit_id: records[0].unit_id,
      role: records[0].role,
      target_ids: targetIds,
      settled_samples: attackSettled.length,
      target_position_available: attackSettled.some(record => Boolean(vector(record.current_target?.position))),
      position_span_x: positions.length ? Math.max(...positions.map(position => position.x)) - Math.min(...positions.map(position => position.x)) : null,
      position_span_z: positions.length ? Math.max(...positions.map(position => position.z)) - Math.min(...positions.map(position => position.z)) : null,
    });
  }
  return settled;
}

function summarize(runName, run) {
  const units = navigationUnits(run);
  const combat = combatUnits(run);
  const buildings = run.controlled_building_geometry || [];
  const boxChecks = [];
  for (const unit of units) {
    for (const building of buildings) {
      const inside = boxContains(unit.position, building);
      if (inside === true) boxChecks.push({
        timestamp_seconds: unit.timestamp_seconds,
        unit_id: unit.unit_id,
        building_id: building.building_id,
        position: unit.position,
        formula: "axis-aligned runtime BoxShape3D half-extents; retained transform has no rotation field",
      });
    }
  }
  const finalWorkers = (run.final?.workers || []).filter(worker => worker.team === 0);
  const aliveWorkers = finalWorkers.filter(worker => worker.dead === false && worker.in_tree === true);
  const playerCommander = (run.final?.commanders || []).find(commander => commander.team === 0);
  const reportedWorkers = Array.isArray(playerCommander?.live_workers) ? playerCommander.live_workers.length : NaN;
  const workerLedger = Number.isFinite(reportedWorkers) && reportedWorkers === aliveWorkers.length;
  const authoritativeQueryRecords = combat.filter(unit => unit.authoritative_overlap?.query_available === true);
  const centerViolations = combat.flatMap(unit => (unit.authoritative_overlap?.center_penetration || []).map(overlap => ({
    timestamp_seconds: unit.timestamp_seconds,
    unit_id: unit.unit_id,
    runtime_id: String(unit.runtime_id),
    role: unit.role,
    team: unit.team,
    state_name: unit.state_name,
    building_id: overlap.building_id,
    position: unit.position,
  })));
  const bodyViolations = combat.flatMap(unit => (unit.authoritative_overlap?.body_clearance || []).map(overlap => ({
    timestamp_seconds: unit.timestamp_seconds,
    unit_id: unit.unit_id,
    runtime_id: String(unit.runtime_id),
    role: unit.role,
    team: unit.team,
    state_name: unit.state_name,
    building_id: overlap.building_id,
    position: unit.position,
  })));
  const settled = settlingSummary(combat);
  const ranged = combat.filter(unit => unit.role === "ranged");
  const rangedTargetPositions = ranged.filter(unit => Boolean(vector(unit.current_target?.position)));
  const run4 = runName === "RICH_RUN4";
  const result = {
    schema: "v0436-k3r-rich-offline-clearance-v1",
    run: runName,
    source_status: run.status,
    sample_count: run.samples?.length || 0,
    navigation_unit_sample_count: units.length,
    authoritative_buildings: buildings.map(building => ({
      building_id: building.building_id,
      position: building.position,
      colliders: building.colliders,
      footprint: building.footprint,
      formula: "retained runtime collider metadata; polygon vertices and transform rotation are not present in this ledger",
    })),
    center_penetration_authoritative: {
      status: run4 ? (centerViolations.length ? "VIOLATIONS_OBSERVED" : "NO_VIOLATIONS_OBSERVED") : "NOT_DETERMINABLE_FROM_RETAINED_TELEMETRY",
      reason: run4 ? "RICH_RUN4 retained direct-space authoritative center queries for every captured live unit." : "The retained natural ledger has runtime collider class/box size but no polygon vertices or collider transform rotation.",
      query_records: authoritativeQueryRecords.length,
      violation_count: run4 ? centerViolations.length : null,
      violations: run4 ? centerViolations : [],
      box_only_observed_count: boxChecks.length,
      box_only_observed: boxChecks,
    },
    body_clearance: {
      status: run4 ? (bodyViolations.length ? "VIOLATIONS_OBSERVED" : "NO_VIOLATIONS_OBSERVED") : "NOT_DETERMINABLE_FROM_RETAINED_TELEMETRY",
      reason: run4 ? "RICH_RUN4 retained direct-space authoritative body-shape overlap queries for every captured live unit." : "Natural navigation samples do not retain unit collision shape/radius or per-frame physics overlap results.",
      violation_count: run4 ? bodyViolations.length : null,
      violations: run4 ? bodyViolations : [],
    },
    visible_clearance: {
      status: "NO_MAJOR_TRAVERSAL_OBSERVED_IN_INSPECTED_FRAMES",
      inspected_frames: ["09_RICH_COMBAT_BESIDE_BUILDING.png", "14_RICH_1366_COMBAT.png"],
      caveat: "This is a visual review result, not a physics query.",
    },
    orbiting: {
      status: settled.length ? "SETTLED_RECORDS_OBSERVED" : "NOT_DETERMINABLE_FROM_RETAINED_TELEMETRY",
      reason: settled.length ? "RICH_RUN4 retained persistent runtime IDs and attack-settled samples; target-center/angular telemetry is still unavailable." : "Natural samples contain no attack-settled records for an offline orbit test.",
      settled_records: settled,
    },
    ranged_overclosing: {
      status: rangedTargetPositions.length ? "TARGET_POSITIONS_AVAILABLE" : "NOT_DETERMINABLE_FROM_RETAINED_TELEMETRY",
      reason: rangedTargetPositions.length ? "RICH_RUN4 retained ranged attack records with target positions." : "RICH_RUN4 retained ranged attack ranges and target IDs, but target positions were unavailable in the runtime target record.",
      ranged_records: ranged.length,
      target_position_records: rangedTargetPositions.length,
    },
    group_settling: {
      status: settled.length ? "PARTIALLY_OBSERVED" : "NOT_DETERMINABLE_FROM_RETAINED_TELEMETRY",
      reason: "Persistent combatant identity is retained, but repath/re-slot counters are not present in the runtime snapshot.",
      unique_runtime_ids: new Set(combat.map(unit => String(unit.runtime_id))).size,
      settled_records: settled,
    },
    damage: {
      first_damage_seconds: run.first_damage_time_seconds,
      damage_events: run.damage_events_delta,
      deaths: run.death_events_delta,
      building_damage_events: run.building_damage_events_delta,
    },
    worker_lifecycle: {
      reported_alive_workers: Number.isFinite(reportedWorkers) ? reportedWorkers : null,
      authoritative_alive_workers: aliveWorkers.length,
      consistent: workerLedger,
      status: workerLedger ? "CONSISTENT" : "INCONSISTENT_OR_UNAVAILABLE",
    },
  };
  return result;
}

const run2 = await readJson(path.join(root, "RICH_RUN2", "k3r-natural-run.json"));
const run3 = await readJson(path.join(root, "RICH_RUN3", "k3r-natural-run.json"));
const run4 = await readJson(path.join(root, "RICH_RUN4", "k3r-natural-run.json"));
const analyses = { RICH_RUN2: summarize("RICH_RUN2", run2), RICH_RUN3: summarize("RICH_RUN3", run3), RICH_RUN4: summarize("RICH_RUN4", run4) };
for (const [runName, analysis] of Object.entries(analyses)) {
  await writeJson(path.join(output, `${runName.toLowerCase().replace("_", "-")}-authoritative-clearance.json`), analysis);
  await writeJson(path.join(output, `${runName.toLowerCase().replace("_", "-")}-settling-analysis.json`), {
    schema: "v0436-k3r-rich-offline-settling-v1",
    run: runName,
    orbiting: analysis.orbiting,
    ranged_overclosing: analysis.ranged_overclosing,
    group_settling: analysis.group_settling,
  });
  await writeJson(path.join(output, `${runName.toLowerCase().replace("_", "-")}-worker-lifecycle-analysis.json`), {
    schema: "v0436-k3r-rich-offline-worker-lifecycle-v1",
    run: runName,
    ...analysis.worker_lifecycle,
  });
}

const qualification = {
  schema: "v0436-k3r-rich-offline-qualification-v1",
  status: "K3_NATURAL_COMBAT_DAMAGE_PROVEN_POSITIONING_QUALIFICATION_INCOMPLETE",
  retained_runs: Object.keys(analyses),
  runs: analyses,
  conclusion: "RUN2 and RUN3 retain valid Rich damage/death/building-damage evidence and genuine headed frames. RICH_RUN4 is valid and retains authoritative physics queries, persistent runtime IDs, attack-settled flags, target IDs, ranged ranges, and worker lifecycle. The authoritative RICH_RUN4 queries observed center and body overlaps against building colliders, so K3 cannot be promoted to a clean positioning pass. Target-center/angular orbit proof and repath/re-slot proof remain unavailable.",
  required_next: "Freeze RICH_RUN2/RICH_RUN3/RICH_RUN4 as the truthful qualification set. Any repair of the observed building-overlap behavior requires a separately authorized production gameplay/navigation scope; do not silently change production code in this evidence task.",
};
await writeJson(path.join(output, "k3-offline-qualification.json"), qualification);
await fs.writeFile(path.join(output, "k3-offline-qualification.md"), `# K3R Rich Offline Qualification\n\nStatus: **${qualification.status}**\n\nRUN2 and RUN3 prove valid Rich configuration, real damage/deaths, building damage, and genuine headed frames. RICH_RUN4 is also a valid Rich run with first-wave, damage, casualty, and headed-frame evidence.\n\nThe minimum harness-only telemetry is now present. RICH_RUN4 direct-space queries observed ${analyses.RICH_RUN4.center_penetration_authoritative.violation_count} center-penetration records and ${analyses.RICH_RUN4.body_clearance.violation_count} body-clearance records against building colliders. This is a truthful K3 positioning blocker, not a reason to discard the runs. Persistent identities and attack-settled records are retained, while target-center/angular orbit proof and repath/re-slot proof remain unavailable.\n\nVisual inspection of the inspected combat frames found no major model traversal, but visual clearance cannot override authoritative overlap records. Any production repair requires a new explicit gameplay/navigation scope.\n`, "utf8");
console.log(JSON.stringify(qualification, null, 2));
