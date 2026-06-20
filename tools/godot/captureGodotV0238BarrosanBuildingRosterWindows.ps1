param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0238"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0238-barrosan-building-roster"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0237-barrosan-material-richness-foliage\02_v0237_overview.png"
$Verdict = if ($env:V0238_VERDICT) { $env:V0238_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.237 baseline overview." }
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
& (Join-Path $RepoRoot "tools\blender\generateV0238BarrosanBuildingRosterWindows.ps1")
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
if (-not (Test-Path $ExePath)) { throw "Missing exported Godot executable." }
$Args = "--salto-barrosan-building-roster `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $Args -Wait -PassThru -WindowStyle Hidden
if ($Process.ExitCode -ne 0) { throw "Godot v0.238 capture failed." }
if (-not (Test-Path (Join-Path $RuntimeRoot "v0238-barrosan-building-roster-runtime.json"))) { throw "Missing v0.238 runtime manifest." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0237_baseline_overview.png")
Get-ChildItem (Join-Path $RuntimeRoot "screenshots") -Filter "*.png" | Copy-Item -Destination $ManualRoot
node tools/godot/saltoV0238BarrosanBuildingRosterTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.238 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0238BarrosanReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.238 contact sheet failed." }
Write-Output "PASS_V0238_BARROSAN_BUILDING_ROSTER_REVIEW_PACK_READY"
