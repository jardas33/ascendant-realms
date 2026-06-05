param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0129"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

foreach ($fileName in @(
  "player-slice-validation-runtime.json",
  "performance-smoke-runtime.json",
  "objective-flow-runtime.json",
  "player-slice-validation.json",
  "performance-smoke.json",
  "objective-flow-report.json",
  "art-slot-report.json",
  "data-adapter-report.json",
  "performance-smoke-report.json",
  "microloop-report.json"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForPlayerSliceValidationArtifacts {
  param([int]$TimeoutSeconds = 90)
  $requiredFiles = @(
    (Join-Path $ArtifactRoot "player-slice-validation-runtime.json"),
    (Join-Path $ArtifactRoot "performance-smoke-runtime.json"),
    (Join-Path $ArtifactRoot "objective-flow-runtime.json")
  )
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $missing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -eq 0) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  $stillMissing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
  throw "Timed out waiting for player-slice validation runtime artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--player-slice-validate", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForPlayerSliceValidationArtifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" player-slice-validate-v0129
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
