param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0236"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0236-barrosan-art-bible-production-slice"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0235-architecture-correction-beauty-pass\02_v0235_corrected_overview.png"
$Verdict = if ($env:V0236_VERDICT) { $env:V0236_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.235 architecture baseline overview." }
if (Test-Path -LiteralPath $ArtifactRoot) {
  $resolvedTarget = (Resolve-Path -LiteralPath $ArtifactRoot).Path
  $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
  if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove v0.236 artifact path outside artifacts: $resolvedTarget"
  }
  Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
}
if (Test-Path -LiteralPath $ManualRoot) {
  $resolvedTarget = (Resolve-Path -LiteralPath $ManualRoot).Path
  $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
  if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove v0.236 review path outside artifacts: $resolvedTarget"
  }
  Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null

& (Join-Path $RepoRoot "tools\blender\generateV0236BarrosanProductionSliceWindows.ps1")
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing exported Godot executable." }
$GodotArgs = "--salto-barrosan-production-slice `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $GodotArgs -Wait -PassThru -WindowStyle Hidden
if ($Process.ExitCode -ne 0) { throw "Godot v0.236 Barrosan production-slice capture failed." }
$Manifest = Join-Path $RuntimeRoot "v0236-barrosan-production-slice-runtime.json"
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.236 runtime manifest." }
Copy-Item -LiteralPath $Baseline -Destination (Join-Path $ManualRoot "01_v0235_baseline_overview.png")
Get-ChildItem -LiteralPath (Join-Path $RuntimeRoot "screenshots") -Filter "*.png" | Copy-Item -Destination $ManualRoot
node tools/godot/saltoV0236BarrosanProductionSliceTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.236 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0236BarrosanReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.236 contact-sheet assembly failed." }
Write-Output "PASS_V0236_BARROSAN_REVIEW_PACK_READY"
