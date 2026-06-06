param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

$forwardedArgs = @()
if ($RemainingArgs) {
  $forwardedArgs += $RemainingArgs
}

if ($Wait) {
  & (Join-Path $PSScriptRoot "launchGodotPlayerSliceWindows.ps1") -Wait @forwardedArgs
} else {
  & (Join-Path $PSScriptRoot "launchGodotPlayerSliceWindows.ps1") @forwardedArgs
}
