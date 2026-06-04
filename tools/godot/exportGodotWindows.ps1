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
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
if (Test-Path $ExePath) {
  $resolvedExe = Resolve-Path -LiteralPath $ExePath
  $resolvedBuilds = Resolve-Path -LiteralPath (Join-Path $RepoRoot "desktop-spikes\godot-salto\builds")
  if (-not ($resolvedExe.Path.StartsWith($resolvedBuilds.Path))) {
    throw "Refusing to remove export outside Godot builds folder: $($resolvedExe.Path)"
  }
  Remove-Item -LiteralPath $ExePath -Force
}
$ExportArgs = @(
  "--headless",
  "--path",
  "desktop-spikes/godot-salto",
  "--export-release",
  "Windows Desktop",
  "builds/AscendantRealmsGodotSalto.exe"
)
& $GodotExe @ExportArgs
$GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
$ExportDeadline = (Get-Date).AddSeconds(10)
while (-not (Test-Path $ExePath) -and (Get-Date) -lt $ExportDeadline) {
  Start-Sleep -Milliseconds 200
}
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" export
if (-not (Test-Path $ExePath)) {
  exit 1
}
if ($GodotExitCode -ne 0 -and -not (Test-Path "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe")) {
  exit $GodotExitCode
}
if ($GodotExitCode -ne 0) {
  Write-Host "Godot export returned exit code $GodotExitCode after producing the Windows executable; keeping the PASS export artifact."
}
