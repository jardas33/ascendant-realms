param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"

Set-Location $RepoRoot

if (-not (Test-Path -LiteralPath $ExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

if (-not (Test-Path -LiteralPath $ExePath)) {
  throw "Missing packaged Godot executable after export. Run GODOT_EXPORT_WINDOWS.bat and GODOT_PACKAGE_WINDOWS.bat first."
}

$ArgumentList = @(
  "--player-slice",
  "--salto-ui-shell-experiment",
  "--experimental-review-mode-label=Experimental opt-in UI shell"
)

if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

$ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
$ProcessStartInfo.FileName = $ExePath
$ProcessStartInfo.WorkingDirectory = $RepoRoot
$ProcessStartInfo.UseShellExecute = $false
$ProcessStartInfo.Arguments = ($ArgumentList | ForEach-Object {
  $escaped = $_.Replace('"', '\"')
  if ($escaped -match '\s') { '"' + $escaped + '"' } else { $escaped }
}) -join " "

if ($Wait) {
  $GodotProcess = [System.Diagnostics.Process]::Start($ProcessStartInfo)
  $GodotProcess.WaitForExit()
  $GodotExitCode = if ($null -eq $GodotProcess.ExitCode) { 0 } else { $GodotProcess.ExitCode }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot Salto UI shell opt-in exited with code $GodotExitCode."
  }
  return
}

[void][System.Diagnostics.Process]::Start($ProcessStartInfo)
