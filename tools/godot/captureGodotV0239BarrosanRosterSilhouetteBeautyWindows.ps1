param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0239"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0239-barrosan-roster-silhouette-beauty"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0238-barrosan-building-roster\02_v0238_roster_overview.png"
$Verdict = if ($env:V0239_VERDICT) { $env:V0239_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.238 baseline overview." }
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}
New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null
& (Join-Path $RepoRoot "tools\blender\generateV0239BarrosanRosterSilhouetteBeautyWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$Args = "--salto-barrosan-roster-silhouette-beauty `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $Args -Wait -PassThru -WindowStyle Hidden
if ($Process.ExitCode -ne 0) { throw "Godot v0.239 capture failed." }
if (-not (Test-Path (Join-Path $RuntimeRoot "v0239-barrosan-roster-silhouette-beauty-runtime.json"))) { throw "Missing v0.239 runtime manifest." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0238_roster_baseline.png")
Get-ChildItem (Join-Path $RuntimeRoot "screenshots") -Filter "*.png" | Copy-Item -Destination $ManualRoot
node tools/godot/saltoV0239BarrosanRosterSilhouetteBeautyTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.239 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0239BarrosanRosterSilhouetteBeautyReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.239 contact sheet failed." }
Write-Output "PASS_V0239_BARROSAN_ROSTER_SILHOUETTE_BEAUTY_REVIEW_PACK_READY"
