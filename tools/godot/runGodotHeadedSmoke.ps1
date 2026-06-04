param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0118"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

function Wait-ForArtifactFiles {
  param(
    [string[]]$Paths,
    [int]$TimeoutSeconds = 90
  )
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $missing = @($Paths | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -eq 0) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  $stillMissing = @($Paths | Where-Object { -not (Test-Path $_) })
  throw "Timed out waiting for Godot runtime artifacts: $($stillMissing -join ', ')"
}

$SmokeRuntime = Join-Path $ArtifactRoot "headed-smoke-runtime.json"
Remove-Item -LiteralPath $SmokeRuntime -Force -ErrorAction SilentlyContinue
$SmokeArgs = @("--review-smoke", "--artifact-root=$ArtifactArg")
& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs $SmokeArgs
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
Wait-ForArtifactFiles -Paths @($SmokeRuntime)
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" headed-smoke

$BenchmarkRuntime2d = Join-Path $ArtifactRoot "headed-benchmark-runtime-2d.json"
$BenchmarkRuntime25d = Join-Path $ArtifactRoot "headed-benchmark-runtime-2_5d.json"
$BenchmarkSummary = Join-Path $ArtifactRoot "headed-benchmark-runtime-summary.json"
Remove-Item -LiteralPath $BenchmarkRuntime2d -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $BenchmarkRuntime25d -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $BenchmarkSummary -Force -ErrorAction SilentlyContinue
$BenchmarkArgs = @("--headed-benchmark", "--artifact-root=$ArtifactArg")
& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs $BenchmarkArgs
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
Wait-ForArtifactFiles -Paths @($BenchmarkRuntime2d, $BenchmarkRuntime25d, $BenchmarkSummary)
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" headed-benchmark
