param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2StructureMaterialWindows.ps1") -Wait @RemainingArgs
