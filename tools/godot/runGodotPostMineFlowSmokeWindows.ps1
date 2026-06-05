param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0133"
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
    throw "Refusing to remove screenshots outside v0.133 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

foreach ($fileName in @(
  "headed-post-mine-flow-smoke.json",
  "post-mine-trace.json",
  "post-mine-trace.md",
  "objective-prerequisite-report.json",
  "barracks-restoration-proof.json",
  "militia-recruit-proof.json",
  "pressure-countdown-proof.json",
  "wave-launch-proof.json",
  "combat-onset-proof.json",
  "wave-defeat-proof.json",
  "lume-restore-proof.json",
  "screenshot-manifest.json",
  "post-mine-flow-validation.json",
  "README.md"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForPostMineFlowArtifacts {
  param([int]$TimeoutSeconds = 220)
  $requiredFiles = @(
    (Join-Path $ArtifactRoot "headed-post-mine-flow-smoke.json"),
    (Join-Path $ArtifactRoot "post-mine-trace.json"),
    (Join-Path $ArtifactRoot "objective-prerequisite-report.json"),
    (Join-Path $ArtifactRoot "barracks-restoration-proof.json"),
    (Join-Path $ArtifactRoot "militia-recruit-proof.json"),
    (Join-Path $ArtifactRoot "pressure-countdown-proof.json"),
    (Join-Path $ArtifactRoot "wave-launch-proof.json"),
    (Join-Path $ArtifactRoot "combat-onset-proof.json"),
    (Join-Path $ArtifactRoot "wave-defeat-proof.json"),
    (Join-Path $ArtifactRoot "lume-restore-proof.json"),
    (Join-Path $ArtifactRoot "screenshot-manifest.json")
  )
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $pngCount = 0
    if (Test-Path $ScreenshotRoot) {
      $pngCount = @(Get-ChildItem -LiteralPath $ScreenshotRoot -Filter "*.png").Count
    }
    $missing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -eq 0 -and $pngCount -eq 21) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  $stillMissing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
  throw "Timed out waiting for v0.133 post-mine flow artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--post-mine-flow-smoke", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForPostMineFlowArtifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" post-mine-flow-v0133
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
