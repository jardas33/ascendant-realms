param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0136"
$ScreenshotRoot = Join-Path $ArtifactRoot "screenshots"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
if (Test-Path $ScreenshotRoot) {
  $resolvedScreenshots = Resolve-Path -LiteralPath $ScreenshotRoot
  $resolvedArtifact = Resolve-Path -LiteralPath $ArtifactRoot
  if (-not ($resolvedScreenshots.Path.StartsWith($resolvedArtifact.Path))) {
    throw "Refusing to remove screenshots outside v0.136 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

foreach ($fileName in @(
  "headed-usability-presentation-smoke.json",
  "usability-presentation-smoke.json",
  "hud-hierarchy-report.json",
  "minimap-refinement-report.json",
  "onboarding-copy-report.json",
  "microloop-pacing-report.json",
  "usability-presentation-trace.json",
  "usability-presentation-trace.md",
  "screenshot-manifest.json",
  "usability-presentation-validation.json",
  "README.md"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForV0136Artifacts {
  param([int]$TimeoutSeconds = 420)
  $requiredFiles = @(
    (Join-Path $ArtifactRoot "headed-usability-presentation-smoke.json"),
    (Join-Path $ArtifactRoot "usability-presentation-smoke.json"),
    (Join-Path $ArtifactRoot "hud-hierarchy-report.json"),
    (Join-Path $ArtifactRoot "minimap-refinement-report.json"),
    (Join-Path $ArtifactRoot "onboarding-copy-report.json"),
    (Join-Path $ArtifactRoot "microloop-pacing-report.json"),
    (Join-Path $ArtifactRoot "usability-presentation-trace.json"),
    (Join-Path $ArtifactRoot "screenshot-manifest.json")
  )
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $pngCount = 0
    if (Test-Path $ScreenshotRoot) {
      $pngCount = @(Get-ChildItem -LiteralPath $ScreenshotRoot -Filter "*.png").Count
    }
    $missing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -eq 0 -and $pngCount -ge 12) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  $stillMissing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
  throw "Timed out waiting for v0.136 usability presentation artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--usability-presentation-smoke", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForV0136Artifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" usability-presentation-v0136
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
