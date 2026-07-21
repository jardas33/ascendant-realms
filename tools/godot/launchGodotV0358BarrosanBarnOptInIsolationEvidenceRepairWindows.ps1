param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Godot = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
$Scene = 'res://scenes/review/V0358BarrosanBarnOptInIsolationEvidenceRepair.tscn'
if (-not (Test-Path -LiteralPath $Godot)) { throw 'v0.358 Godot executable not found' }
$args = @('--path', $Project, '--scene', $Scene)
if ($RemainingArgs) { $args += $RemainingArgs }
if ($Wait) {
  & $Godot @args
  if ($LASTEXITCODE -ne 0) { throw "v0.358 Godot fixture exited with code $LASTEXITCODE" }
  return
}
Start-Process -FilePath $Godot -ArgumentList $args | Out-Null
