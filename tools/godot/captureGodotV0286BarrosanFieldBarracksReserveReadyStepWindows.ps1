param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0286"
$TrueDefaultRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0286"
$OptInRuntimeRoot = Join-Path $ArtifactRoot "field-barracks-reserve-ready-step-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0286-barrosan-field-barracks-reserve-ready-step"
$Verdict = if ($env:v0286_VERDICT) { $env:v0286_VERDICT } else { "PASS" }

Set-Location $RepoRoot
foreach ($Target in @($ArtifactRoot, $TrueDefaultRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    [System.IO.Directory]::Delete("\\?\$resolvedTarget", $true)
  }
}
New-Item -ItemType Directory -Force -Path $ArtifactRoot, $TrueDefaultRoot, $OptInRuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:v0286_GODOT_PATH) { $env:v0286_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.286 capture Godot binary: $GodotPath" }

function Invoke-v0286RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [string] $ExpectedCheckpoint, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.286 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.286 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($ExpectedCheckpoint -and $manifestRaw -notmatch ('"checkpoint"\s*:\s*"' + [regex]::Escape($ExpectedCheckpoint) + '"')) { throw "Godot v0.286 $Label capture did not dispatch $ExpectedCheckpoint." }
  if (-not $ExpectedCheckpoint -and $manifestRaw -match '"checkpoint"\s*:\s*"v0\.286"') { throw "Godot v0.286 $Label true-default capture accidentally dispatched the v0.286 review fixture." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.286 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -match '"enabled"\s*:\s*true') { throw "Godot v0.286 $Label rendered capture leaked the opt-in Barrosan runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.286 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$TrueDefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0286"
$OptInRuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0286/field-barracks-reserve-ready-step-runtime"

Invoke-v0286RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$TrueDefaultArgRoot") -ManifestPath (Join-Path $TrueDefaultRoot "screenshot-runtime-manifest.json") -Label "true default" -ExpectedCheckpoint "" -ExpectSkinEnabled $false
Invoke-v0286RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$OptInRuntimeArgRoot") -ManifestPath (Join-Path $OptInRuntimeRoot "screenshot-runtime-manifest.json") -Label "opt-in runtime" -ExpectedCheckpoint "v0.286" -ExpectSkinEnabled $true

Copy-Item (Join-Path $TrueDefaultRoot "screenshots\03_battle_default.png") (Join-Path $ManualRoot "02_v0286_true_default_runtime_baseline_no_fixture_no_opt_in.png")

$RuntimeCopies = @(
  @{ Source = "01_v0286_manual_fixture_baseline_clean_hud_visible.png"; Target = "04_v0286_manual_fixture_baseline_clean_hud.png" },
  @{ Source = "02_v0286_engage_available_before_click_visible.png"; Target = "05_v0286_engage_available_before_click.png" },
  @{ Source = "03_v0286_engage_armed_visible.png"; Target = "06_v0286_engage_armed.png" },
  @{ Source = "04_v0286_commit_engage_clicked_visible.png"; Target = "07_v0286_commit_engage_clicked.png" },
  @{ Source = "05_v0286_post_commit_pressure_checked_ashen_braced_visible.png"; Target = "08_v0286_post_commit_pressure_checked_ashen_braced.png" },
  @{ Source = "06_v0286_hold_line_available_after_commit_locked_visible.png"; Target = "09_v0286_hold_line_available_after_commit_locked.png" },
  @{ Source = "07_v0286_hold_line_clicked_visible.png"; Target = "10_v0286_hold_line_clicked.png" },
  @{ Source = "08_v0286_line_held_exactly_once_visible.png"; Target = "11_v0286_line_held_exactly_once.png" },
  @{ Source = "09_v0286_ashen_contained_exactly_once_visible.png"; Target = "12_v0286_ashen_contained_exactly_once.png" },
  @{ Source = "10_v0286_select_field_barracks_after_hold_line_visible.png"; Target = "13_v0286_select_field_barracks_after_hold_line.png" },
  @{ Source = "11_v0286_field_barracks_train_available_reserve_slot_empty_visible.png"; Target = "14_v0286_field_barracks_train_available_reserve_slot_empty.png" },
  @{ Source = "12_v0286_train_militia_clicked_visible.png"; Target = "15_v0286_train_militia_clicked.png" },
  @{ Source = "13_v0286_reserve_ready_exactly_once_visible.png"; Target = "16_v0286_reserve_ready_exactly_once.png" },
  @{ Source = "14_v0286_barracks_card_reserve_militia_ready_visible.png"; Target = "17_v0286_barracks_card_reserve_militia_ready.png" },
  @{ Source = "15_v0286_repeat_train_no_duplicate_reserve_no_stack_visible.png"; Target = "18_v0286_repeat_train_no_duplicate_reserve_no_stack.png" },
  @{ Source = "16_v0286_resources_unchanged_after_reserve_ready_visible.png"; Target = "19_v0286_resources_unchanged_after_reserve_ready.png" },
  @{ Source = "17_v0286_reserve_marker_no_movement_pathing_attack_actions_visible.png"; Target = "20_v0286_reserve_marker_no_movement_pathing_attack_actions.png" },
  @{ Source = "18_v0286_watchpost_no_hold_line_engage_commit_ashen_reserve_visible.png"; Target = "21_v0286_watchpost_no_hold_line_engage_commit_ashen_reserve.png" },
  @{ Source = "19_v0286_clear_guard_settles_defender_contact_clean_visible.png"; Target = "22_v0286_clear_guard_settles_defender_contact_clean.png" },
  @{ Source = "20_v0286_reguard_clean_after_reserve_ready_visible.png"; Target = "23_v0286_reguard_clean_after_reserve_ready.png" },
  @{ Source = "21_v0286_no_projectile_damage_hp_loss_death_despawn_visible.png"; Target = "24_v0286_no_projectile_damage_hp_loss_death_despawn.png" }
)
foreach ($copy in $RuntimeCopies) {
  $sourcePath = Join-Path $OptInRuntimeRoot ("screenshots\" + $copy.Source)
  $targetPath = Join-Path $ManualRoot $copy.Target
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.286 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0286BarrosanFieldBarracksReserveReadyStepPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.286 visual evidence assembly failed." }

node tools/godot/saltoV0286BarrosanFieldBarracksReserveReadyStepTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--true-default-root=$($TrueDefaultRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.286 report assembly failed." }

Write-Output "PASS_V0286_BARROSAN_FIELD_BARRACKS_RESERVE_READY_STEP_PACK_READY"

