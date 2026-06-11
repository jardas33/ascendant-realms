param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

$FullQaArgs = @()
if ($RemainingArgs) {
  $FullQaArgs += $RemainingArgs
}

Write-Output "Launching v0.206 Salto shell v2 full QA review using the existing v0.205 final opt-in posture."
Write-Output "QA scope: isolated shell-v2 review path only; no new images, slots, browser wiring, gameplay, pathing, collision, save, or stable-ID changes."
Write-Output "Default launcher and every prior opt-in launcher remain preserved."

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait:$Wait @FullQaArgs
