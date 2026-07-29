import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
const repo = process.cwd();
const root = resolve(process.argv.find((value) => value.startsWith("--artifact-root="))?.slice(16) || join(repo, "artifacts/desktop-spikes/godot-salto/v0292"));
const manual = join(repo, "artifacts/manual-review/v0292-barrosan-selected-card-message-format-repair");
const readJson = (path) => existsSync(path) ? JSON.parse(readFileSync(path, "utf8")) : {};
const runtime = readJson(join(root, "selected-card-message-format-repair-runtime/screenshot-runtime-manifest.json"));
const proof = runtime?.barrosanPlayableRuntimeSkin?.barrosanSelectedCardMessageFormatRepair || runtime?.sceneStatus?.barrosanSelectedCardMessageFormatRepair || {};
const snapshots = proof.proofSnapshots || {};
const errors = [];
if (runtime.checkpoint !== "v0.292") errors.push("opt-in runtime did not dispatch v0.292");
if (runtime.captureCount !== 49) errors.push(`expected 49 retained-state captures, saw ${runtime.captureCount}`);
if (proof.status !== "PASS") errors.push(`v0.292 proof status is ${proof.status || "missing"}`);
for (const [mode, snapshot] of Object.entries(snapshots)) {
  if (!snapshot.selectedCardOnlyText || !snapshot.globalInstructionOutsideSelectedCard || snapshot.staleSelectAsterOverCard) errors.push(`${mode} leaked global instruction into selected card`);
  if (!snapshot.selectedCardTextInsideBounds || !snapshot.buttonRowBelowText || snapshot.selectedCardTextOverlap) errors.push(`${mode} failed selected-card layout bounds`);
  if (!snapshot.rawValidatorParagraphAbsent || !snapshot.longDiagnosticParagraphAbsent) errors.push(`${mode} leaked diagnostics into HUD`);
  if (!snapshot.noGameplayStateChangeFromV0291 || !snapshot.noNewLabelsOrMarkers || !snapshot.noCombatMovementPathingEconomyMutation || !snapshot.v0291StateLabelsRetainedExactlyOnce || !snapshot.repeatStageRemainsIdempotent || !snapshot.resourcesUnchanged) errors.push(`${mode} did not retain v0.291 behavior`);
}
const expected = ["v0291_manual_fixture_baseline_clean_hud", "v0291_engage_available_before_click", "v0291_stage_available", "v0291_launch_order_staged_exactly_once", "v0291_clear_guard_settles_defender_contact_clean_after_stage", "v0291_reguard_clean_after_stage_no_auto_launch_deploy"];
for (const mode of expected) if (!snapshots[mode]) errors.push(`missing required v0.292 capture ${mode}`);
if (snapshots.v0291_manual_fixture_baseline_clean_hud?.hudTextLines?.tacticalFacts !== "No active progress") errors.push("Aster selected card did not replace stale Select Aster prompt");
const report = { status: errors.length ? "FAIL_v0292_VALIDATION" : "PASS_v0292_BARROSAN_SELECTED_CARD_MESSAGE_FORMAT_REPAIR_VALIDATION", errors, runtimeCaptureCount: runtime.captureCount ?? 0, proofStatus: proof.status ?? "missing" };
writeFileSync(join(root, "v0292-validation-report.json"), JSON.stringify(report, null, 2) + "\n");
writeFileSync(join(repo, "docs/V0292_BARROSAN_SELECTED_CARD_MESSAGE_FORMAT_REPAIR_REPORT.md"), `# v0.292 Barrosan Selected Card Message Format Repair\n\n- Status: ${errors.length ? "FAIL" : "PASS"}\n- Scope: HUD/layout-only repair; no gameplay or state-machine behavior changed.\n- Aster selected-card facts: \`No active progress\`; global instruction text is excluded from the card.\n- Retained v0.291 chain: Commit, Hold Line, Train, Assign, Signal, Prepare, Approve, and Stage.\n- Review pack: \`artifacts/manual-review/v0292-barrosan-selected-card-message-format-repair/\`.\n- Captures: ${runtime.captureCount ?? 0}.\n\n## Validation\n\n${errors.length ? errors.map((error) => `- ${error}`).join("\n") : "- PASS: selected-card text is bounded, separated, and free of global prompts/diagnostic paragraphs."}\n`);
console.log(report.status);
if (errors.length) process.exit(1);
