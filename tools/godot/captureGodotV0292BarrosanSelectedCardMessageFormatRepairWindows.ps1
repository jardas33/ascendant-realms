param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0292"
$TrueDefaultRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0292"
$RuntimeRoot = Join-Path $ArtifactRoot "selected-card-message-format-repair-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0292-barrosan-selected-card-message-format-repair"
Set-Location $RepoRoot
foreach ($target in @($ArtifactRoot, $TrueDefaultRoot, $ManualRoot)) {
  if (Test-Path $target) {
    $resolved = (Resolve-Path -LiteralPath $target).Path
    $artifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolved.StartsWith($artifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to clear path outside artifacts: $resolved" }
    [System.IO.Directory]::Delete("\\?\$resolved", $true)
  }
}
New-Item -ItemType Directory -Force -Path $RuntimeRoot, $TrueDefaultRoot, $ManualRoot | Out-Null
$GodotPath = Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
if (-not (Test-Path $GodotPath)) { throw "Missing Godot binary: $GodotPath" }
function Invoke-v0292Capture {
  param([string[]]$Arguments, [string]$Manifest, [string]$Label)
  & $GodotPath @Arguments
  $exitCode = $LASTEXITCODE
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $Manifest) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $Manifest)) { throw "v0.292 $Label capture did not write a manifest" }
  $raw = Get-Content -Raw -LiteralPath $Manifest
  if ($raw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "v0.292 $Label capture manifest did not pass" }
  if ($exitCode -ne 0) { Write-Warning "Godot returned $exitCode after v0.292 $Label wrote a passing manifest." }
}
Invoke-v0292Capture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=../../artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0292") -Manifest (Join-Path $TrueDefaultRoot "screenshot-runtime-manifest.json") -Label "default runtime"
Invoke-v0292Capture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=../../artifacts/desktop-spikes/godot-salto/v0292/selected-card-message-format-repair-runtime") -Manifest (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") -Label "opt-in runtime"
Copy-Item (Join-Path $TrueDefaultRoot "screenshots\03_battle_default.png") (Join-Path $ManualRoot "02_v0292_true_default_runtime_baseline_unchanged.png")
$shotRoot = Join-Path $RuntimeRoot "screenshots"
$shotDeadline = (Get-Date).AddSeconds(30)
do {
  $shots = Get-ChildItem $shotRoot -Filter "*_v0291_*_visible.png" | Sort-Object Name
  if ($shots.Count -eq 49) { Start-Sleep -Milliseconds 800; break }
  Start-Sleep -Milliseconds 200
} while ((Get-Date) -lt $shotDeadline)
if ($shots.Count -ne 49) { throw "Expected 49 retained v0.291 capture actions for v0.292, saw $($shots.Count)" }
$index = 4
foreach ($shot in $shots) {
  $target = Join-Path $ManualRoot ("{0:D2}_v0292_{1}" -f $index, $shot.Name.Substring(9))
  [System.IO.File]::Copy("\\?\$($shot.FullName)", "\\?\$target", $true)
  $index++
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"; if (-not (Test-Path $Python)) { $Python = "python" }
& $Python tools/godot/buildV0292BarrosanSelectedCardMessageFormatRepairPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.292 review pack assembly failed" }
node tools/godot/saltoV0292BarrosanSelectedCardMessageFormatRepairTool.mjs "--artifact-root=$ArtifactRoot"
if ($LASTEXITCODE -ne 0) { throw "v0.292 validator failed" }
Write-Output "PASS_v0292_BARROSAN_SELECTED_CARD_MESSAGE_FORMAT_REPAIR_PACK_READY"
