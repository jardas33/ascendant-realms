param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

$RebootArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto presentation reboot compact HUD",
  "--salto-ui-shell-experiment",
  "--salto-selection-command-panel",
  "--salto-production-objectives-log",
  "--salto-minimap-tooltip-accessibility",
  "--salto-presentation-reboot"
)
if ($RemainingArgs) {
  $RebootArgs += $RemainingArgs
}

Write-Output "Launching v0.215 Salto presentation reboot experiment."
Write-Output "Scope: isolated opt-in shell-v2 review path; compact contextual HUD; no generated images, no new art slots, no browser wiring."
Write-Output "Default launcher, prior UI launchers and v0.214 full-HUD comparator remain preserved."

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait:$Wait @RebootArgs
