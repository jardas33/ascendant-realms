param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"

Set-Location $RepoRoot

if (-not (Test-Path $ExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

if (-not (Test-Path $ExePath)) {
  throw "Missing packaged Godot executable after export. Run GODOT_EXPORT_WINDOWS.bat and GODOT_PACKAGE_WINDOWS.bat first."
}

$ArgumentList = @("--player-slice")
if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

if ($Wait) {
  & $ExePath @ArgumentList
  $GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot player slice exited with code $GodotExitCode."
  }
  return
}

Start-Process -FilePath $ExePath -ArgumentList $ArgumentList | Out-Null
