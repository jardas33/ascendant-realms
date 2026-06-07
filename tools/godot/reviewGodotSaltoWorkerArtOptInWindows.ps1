param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$SourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$MetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"

Set-Location $RepoRoot

if (-not (Test-Path -LiteralPath $SourcePath)) {
  throw "Missing selected Worker art source: $SourcePath"
}
if (-not (Test-Path -LiteralPath $MetadataPath)) {
  throw "Missing selected Worker art metadata: $MetadataPath"
}

Write-Output "Launching the v0.161 Worker-art opt-in review path."
Write-Output "Default procedural review remains GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat."
Write-Output "Opt-in slot: worker_billboard_static_v0147 / HYBRID_WORKER_TRIMMED_1024."

$LaunchArgs = @()
if ($Wait) {
  $LaunchArgs += "-Wait"
}
if ($RemainingArgs) {
  $LaunchArgs += $RemainingArgs
}

& (Join-Path $PSScriptRoot "launchGodotSaltoWorkerArtExperimentWindows.ps1") @LaunchArgs
