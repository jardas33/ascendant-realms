param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Set-Location $RepoRoot

$MeshArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto shell v2 mesh QA repair",
  "--salto-shell-v2-mesh-compositor"
)
if ($RemainingArgs) {
  $MeshArgs += $RemainingArgs
}

Write-Output "Launching v0.197 Salto shell v2 mesh-compositor Windows QA repair review."
Write-Output "QA scope: visual-only topology, route transition, river, bank, bridge, z-order, and camera repair."
Write-Output "Legacy shell remains available as comparator/fallback; wet-granite remains unintegrated."

& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationShellV2Windows.ps1") -Wait:$Wait @MeshArgs
