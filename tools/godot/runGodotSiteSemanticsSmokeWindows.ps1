param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0132"
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
    throw "Refusing to remove screenshots outside v0.132 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

foreach ($fileName in @(
  "headed-site-semantics-smoke.json",
  "site-semantics-trace.json",
  "site-semantics-trace.md",
  "mine-conversion-proof.json",
  "worker-assignment-proof.json",
  "objective-monotonicity.json",
  "screenshot-manifest.json",
  "site-semantics-validation.json",
  "README.md"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForSiteSemanticsArtifacts {
  param([int]$TimeoutSeconds = 160)
  $requiredFiles = @(
    (Join-Path $ArtifactRoot "headed-site-semantics-smoke.json"),
    (Join-Path $ArtifactRoot "site-semantics-trace.json"),
    (Join-Path $ArtifactRoot "mine-conversion-proof.json"),
    (Join-Path $ArtifactRoot "worker-assignment-proof.json"),
    (Join-Path $ArtifactRoot "objective-monotonicity.json"),
    (Join-Path $ArtifactRoot "screenshot-manifest.json")
  )
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $pngCount = 0
    if (Test-Path $ScreenshotRoot) {
      $pngCount = @(Get-ChildItem -LiteralPath $ScreenshotRoot -Filter "*.png").Count
    }
    $missing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -eq 0 -and $pngCount -eq 15) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  $stillMissing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
  throw "Timed out waiting for v0.132 site-semantics artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--site-semantics-smoke", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForSiteSemanticsArtifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" site-semantics-v0132
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
