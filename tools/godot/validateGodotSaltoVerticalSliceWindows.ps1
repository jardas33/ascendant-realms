param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0130"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

foreach ($fileName in @(
  "player-slice-validation-runtime.json",
  "performance-smoke-runtime.json",
  "objective-flow-runtime.json",
  "validation.json",
  "player-slice-validation.json",
  "performance-smoke.json",
  "objective-flow.json",
  "acceptance-gate.json",
  "package-report.json",
  "scorecard-update.json",
  "capture-summary.json",
  "README.md"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForSaltoVerticalSliceValidationArtifacts {
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
  throw "Timed out waiting for v0.130 validation runtime artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--player-slice-validate", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForSaltoVerticalSliceValidationArtifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" player-slice-validate-v0130
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
