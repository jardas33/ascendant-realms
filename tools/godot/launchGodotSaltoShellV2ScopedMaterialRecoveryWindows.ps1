param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Set-Location $RepoRoot

$RecoveryArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto shell v2 scoped material recovery"
)
if ($RemainingArgs) {
  $RecoveryArgs += $RemainingArgs
}

Write-Output "Launching v0.195 Salto shell v2 scoped material recovery review."
Write-Output "Recovery scope: visual-only shell v2 terrain hierarchy and connected route material readability."
Write-Output "Wet-granite bridge-riverbank material remains unintegrated."

& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationShellV2Windows.ps1") -Wait:$Wait @RecoveryArgs
