param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$PackageExe = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ReviewExe = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto-v0185.exe"

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

Copy-Item -LiteralPath $PackageExe -Destination $ReviewExe -Force
$env:GODOT_SALTO_EXE_PATH = $ReviewExe
try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoEnvironmentShellLiveQaWindows.ps1") -Wait:$Wait @RemainingArgs
} finally {
  Remove-Item Env:\GODOT_SALTO_EXE_PATH -ErrorAction SilentlyContinue
}
