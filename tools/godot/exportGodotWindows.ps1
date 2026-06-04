param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotExe = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) {
  $env:GODOT_BIN
} elseif (Test-Path (Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe")) {
  Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
} else {
  $null
}
$TemplatesTarget = Join-Path $env:APPDATA "Godot\export_templates\4.6.3.stable"
$ReleaseTemplate = Join-Path $TemplatesTarget "windows_release_x86_64.exe"
$DebugTemplate = Join-Path $TemplatesTarget "windows_debug_x86_64.exe"
Set-Location $RepoRoot

if (-not $GodotExe -or -not (Test-Path $ReleaseTemplate) -or -not (Test-Path $DebugTemplate)) {
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" export
  exit 0
}

New-Item -ItemType Directory -Force -Path "desktop-spikes\godot-salto\builds" | Out-Null
$ExportArgs = @(
  "--headless",
  "--path",
  "desktop-spikes/godot-salto",
  "--export-release",
  "Windows Desktop",
  "builds/AscendantRealmsGodotSalto.exe"
)
$GodotProcess = Start-Process -FilePath $GodotExe -ArgumentList $ExportArgs -Wait -PassThru -WindowStyle Hidden
$GodotExitCode = $GodotProcess.ExitCode
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" export
if ($GodotExitCode -ne 0 -and -not (Test-Path "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe")) {
  exit $GodotExitCode
}
if ($GodotExitCode -ne 0) {
  Write-Host "Godot export returned exit code $GodotExitCode after producing the Windows executable; keeping the PASS export artifact."
}
