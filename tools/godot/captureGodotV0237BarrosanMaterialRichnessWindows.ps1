param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0237"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0237-barrosan-material-richness-foliage"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0236-barrosan-art-bible-production-slice\02_v0236_overview.png"
$Verdict = if ($env:V0237_VERDICT) { $env:V0237_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.236 production-slice baseline overview." }
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) {
      throw "Refusing to remove v0.237 path outside artifacts: $resolvedTarget"
    }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}
New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null

& (Join-Path $RepoRoot "tools\blender\generateV0237BarrosanMaterialRichnessWindows.ps1")
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing exported Godot executable." }
$GodotArgs = "--salto-barrosan-material-richness `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $GodotArgs -Wait -PassThru -WindowStyle Hidden
if ($Process.ExitCode -ne 0) { throw "Godot v0.237 material-richness capture failed." }
$Manifest = Join-Path $RuntimeRoot "v0237-barrosan-material-richness-runtime.json"
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.237 runtime manifest." }
Copy-Item -LiteralPath $Baseline -Destination (Join-Path $ManualRoot "01_v0236_baseline_overview.png")
Get-ChildItem -LiteralPath (Join-Path $RuntimeRoot "screenshots") -Filter "*.png" | Copy-Item -Destination $ManualRoot
node tools/godot/saltoV0237BarrosanMaterialRichnessTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.237 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0237BarrosanReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.237 contact-sheet assembly failed." }
Write-Output "PASS_V0237_BARROSAN_MATERIAL_RICHNESS_REVIEW_PACK_READY"
