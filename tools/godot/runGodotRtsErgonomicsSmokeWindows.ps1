param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0135"
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
    throw "Refusing to remove screenshots outside v0.135 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

foreach ($fileName in @(
  "headed-rts-ergonomics-smoke.json",
  "rts-ergonomics-smoke.json",
  "rts-input-contract.json",
  "order-feedback-report.json",
  "camera-control-report.json",
  "compact-help-report.json",
  "rts-ergonomics-trace.json",
  "rts-ergonomics-trace.md",
  "screenshot-manifest.json",
  "rts-ergonomics-validation.json",
  "README.md"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForV0135Artifacts {
  param([int]$TimeoutSeconds = 360)
  $requiredFiles = @(
    (Join-Path $ArtifactRoot "headed-rts-ergonomics-smoke.json"),
    (Join-Path $ArtifactRoot "rts-ergonomics-smoke.json"),
    (Join-Path $ArtifactRoot "rts-input-contract.json"),
    (Join-Path $ArtifactRoot "order-feedback-report.json"),
    (Join-Path $ArtifactRoot "camera-control-report.json"),
    (Join-Path $ArtifactRoot "compact-help-report.json"),
    (Join-Path $ArtifactRoot "rts-ergonomics-trace.json"),
    (Join-Path $ArtifactRoot "screenshot-manifest.json")
  )
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $pngCount = 0
    if (Test-Path $ScreenshotRoot) {
      $pngCount = @(Get-ChildItem -LiteralPath $ScreenshotRoot -Filter "*.png").Count
    }
    $missing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -eq 0 -and $pngCount -ge 14) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  $stillMissing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
  throw "Timed out waiting for v0.135 RTS ergonomics artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--rts-ergonomics-smoke", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForV0135Artifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" rts-ergonomics-v0135
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
