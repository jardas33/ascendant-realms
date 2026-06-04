param(
  [switch]$Wait,
  [string[]]$ReviewArgs = @(),
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"

Set-Location $RepoRoot

if (-not (Test-Path $ExePath)) {
  throw "Missing packaged Godot executable. Run GODOT_EXPORT_WINDOWS.bat or npm run godot:export:windows first."
}

$ArgumentList = @()
if ($ReviewArgs) {
  $ArgumentList += $ReviewArgs
}
if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

if ($Wait) {
  & $ExePath @ArgumentList
  $GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot review executable exited with code $GodotExitCode."
  }
  return
}

Start-Process -FilePath $ExePath -ArgumentList $ArgumentList | Out-Null
