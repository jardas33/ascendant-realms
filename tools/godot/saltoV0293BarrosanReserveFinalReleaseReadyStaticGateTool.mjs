import { readFileSync, writeFileSync } from "node:fs";
const root="artifacts/desktop-spikes/godot-salto/v0293/reserve-final-release-ready-static-gate-runtime";
const m=JSON.parse(readFileSync(`${root}/screenshot-runtime-manifest.json`,`utf8`));
const required=["v0293_release_ready_available","v0293_release_ready_clicked","v0293_final_release_ready_top_strip","v0293_release_ready_marker_exactly_once","v0293_defender_after_final_release_ready","v0293_barracks_after_final_release_ready","v0293_repeat_release_ready_idempotent","v0293_no_global_prompt_inside_selected_card","v0293_no_selected_card_button_overlap","v0293_no_deployment_movement_pathing_route_preview"];
const missing=required.filter(x=>!m.captures.some(c=>c.action===x)); const status=missing.length?"FAIL_v0293_VALIDATION":"PASS_v0293_BARROSAN_RESERVE_FINAL_RELEASE_READY_STATIC_GATE_VALIDATION";
writeFileSync(`${root}/v0293-validation-report.json`,JSON.stringify({status,missing,captureCount:m.captureCount,scope:"static gate only"},null,2)+"\n");
console.log(status); if(missing.length)process.exit(1);
