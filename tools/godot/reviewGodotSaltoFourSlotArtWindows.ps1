param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$PackageExe = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ReviewExe = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto-v0169.exe"

Set-Location $RepoRoot

if (-not (Test-Path $PackageExe)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

Copy-Item -LiteralPath $PackageExe -Destination $ReviewExe -Force
$env:GODOT_SALTO_EXE_PATH = $ReviewExe
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoWorkerBarracksMilitiaAsterArtExperimentWindows.ps1") -Wait:$Wait @RemainingArgs
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}
