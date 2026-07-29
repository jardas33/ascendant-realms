param([string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path)
$root = Join-Path $Repo 'desktop-spikes\godot-salto\artifacts\runtime\v0426'
$pack = Join-Path $Repo 'artifacts\manual-review\v0426-secondary-barn-contact-shadow-restraint-hierarchy'
& (Join-Path $PSScriptRoot 'runGodotV0426SecondaryBarnContactShadowRestraintHierarchySmokeWindows.ps1') -Repo $Repo
$godot = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $Repo '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $godot)) { throw "Missing Godot executable: $godot" }
$process = Start-Process -FilePath $godot -ArgumentList @('--path','desktop-spikes/godot-salto','--v0426-secondary-barn-contact-shadow-capture','--artifact-root=artifacts/runtime/v0426') -WorkingDirectory $Repo -PassThru -Wait
if ($process.ExitCode -ne 0) { throw "Godot v0.426 capture exited $($process.ExitCode)" }
New-Item -ItemType Directory -Force -Path $pack | Out-Null
foreach ($capture in @('01_PRIMARY_RTS_COLOUR.png','02_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_GRAYSCALE.png','05_TEMPORARY_BARN_CONTACT_SHADOW_NODE_ID.png','06_V0425_V0426_WIDE_COMPARISON.png','07_V0425_V0426_CONTACT_SHADOW_CLOSE_COMPARISON.png','v0426-preservation-audit.json')) {
  $source = Join-Path $root $capture
  if (-not (Test-Path -LiteralPath $source)) { throw "Missing v0.426 capture: $capture" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pack $capture) -Force
}
Write-Output 'PASS_V0426_RENDERED_SECONDARY_BARN_CONTACT_SHADOW_RESTRAINT'
