param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Set-Location $RepoRoot

$TopologyArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto shell v2 topology repair"
)
if ($RemainingArgs) {
  $TopologyArgs += $RemainingArgs
}

Write-Output "Launching v0.194 Salto shell v2 topology repair review."
Write-Output "Topology scope: visual-only shell v2 terrain, roads, river, banks, bridge."
Write-Output "Wet-granite bridge-riverbank material remains unintegrated."

& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationShellV2Windows.ps1") -Wait:$Wait @TopologyArgs
