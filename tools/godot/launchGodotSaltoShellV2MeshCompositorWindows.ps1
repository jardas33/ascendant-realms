param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Set-Location $RepoRoot

$MeshArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto shell v2 mesh compositor",
  "--salto-shell-v2-mesh-compositor"
)
if ($RemainingArgs) {
  $MeshArgs += $RemainingArgs
}

Write-Output "Launching v0.196 Salto shell v2 mesh compositor review."
Write-Output "Mesh compositor scope: visual-only terrain, route ribbons, river, banks, and bridge."
Write-Output "Legacy shell remains available as comparator/fallback; wet-granite remains unintegrated."

& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationShellV2Windows.ps1") -Wait:$Wait @MeshArgs
