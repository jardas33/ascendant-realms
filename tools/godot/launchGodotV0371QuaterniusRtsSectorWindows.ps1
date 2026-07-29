param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)] [string[]]$RemainingArgs
)
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotExe = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path $GodotExe)) { throw "Missing Godot executable: $GodotExe" }
Set-Location $RepoRoot
$ArgumentList = @("--path", "desktop-spikes/godot-salto", "--", "--v0371-playable")
if ($RemainingArgs) { $ArgumentList += $RemainingArgs }
if ($Wait) { & $GodotExe @ArgumentList; exit $LASTEXITCODE }
Start-Process -FilePath $GodotExe -ArgumentList $ArgumentList | Out-Null
