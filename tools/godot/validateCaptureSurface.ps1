param(
  [Parameter(Mandatory = $true)][string]$ProjectPath,
  [string]$GodotPath = "D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe",
  [string]$CaptureEnvironment = "ASCENDANT_V0431_CAPTURE"
)

$ErrorActionPreference = "Stop"
$checks = [ordered]@{
  project_exists = Test-Path -LiteralPath $ProjectPath
  godot_exists = Test-Path -LiteralPath $GodotPath
  project_file_exists = Test-Path -LiteralPath (Join-Path $ProjectPath "project.godot")
  capture_bootstrap_exists = Test-Path -LiteralPath (Join-Path $ProjectPath "tests\capture_bootstrap.gd")
  capture_environment = $CaptureEnvironment
}

if (-not $checks.project_exists -or -not $checks.godot_exists -or -not $checks.project_file_exists -or -not $checks.capture_bootstrap_exists) {
  $checks.result = "FAIL_PRELIGHT"
  $checks | ConvertTo-Json -Compress
  exit 2
}

$checks.result = "READY_TO_LAUNCH"
$checks | ConvertTo-Json -Compress
exit 0
