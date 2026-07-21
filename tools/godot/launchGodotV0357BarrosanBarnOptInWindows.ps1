$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Project = Join-Path $RepoRoot 'desktop-spikes\godot-salto'
$Godot = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot '.tools\godot\Godot_v4.6.3-stable_win64.exe' }
if (-not (Test-Path -LiteralPath $Godot)) { throw 'v0.357 Godot executable not found' }
$env:V0357_REPO_ROOT = $RepoRoot.Replace('\','/')
$args = @('--path',$Project,'--rendering-method','gl_compatibility','--rendering-driver','opengl3','--scene','res://scenes/review/V0357BarrosanBarnFirstOptInIntegration.tscn','--v0357-barrosan-barn-opt-in')
& $Godot @args
Remove-Item Env:V0357_REPO_ROOT -ErrorAction SilentlyContinue
