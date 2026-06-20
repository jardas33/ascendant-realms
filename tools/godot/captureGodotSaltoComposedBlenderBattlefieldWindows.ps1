param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0234"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0234-composed-blender-battlefield-slice"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0233-blender-modular-kit\02_v0233_overview.png"
Set-Location $RepoRoot
if (Test-Path -LiteralPath $ArtifactRoot) { Remove-Item -LiteralPath $ArtifactRoot -Recurse -Force }
if (Test-Path -LiteralPath $ManualRoot) { Remove-Item -LiteralPath $ManualRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ExeDeadline = (Get-Date).AddSeconds(15)
while (-not (Test-Path -LiteralPath $ExePath) -and (Get-Date) -lt $ExeDeadline) { Start-Sleep -Milliseconds 250 }
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing exported Godot executable." }
$ExePath = (Resolve-Path -LiteralPath $ExePath).Path
$GodotArgs = "--salto-composed-blender-battlefield-slice `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $GodotArgs -Wait -PassThru -WindowStyle Hidden
if ($Process.ExitCode -ne 0) { throw "Godot v0.234 composed battlefield capture failed." }
$Manifest = Join-Path $RuntimeRoot "v0234-composed-blender-battlefield-runtime.json"
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.234 runtime manifest." }
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.233R baseline." }
Copy-Item -LiteralPath $Baseline -Destination (Join-Path $ManualRoot "01_v0233R_kit_baseline.png")
Get-ChildItem -LiteralPath (Join-Path $RuntimeRoot "screenshots") -Filter "*.png" | Copy-Item -Destination $ManualRoot
node tools/godot/saltoComposedBlenderBattlefieldTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=PASS"
if ($LASTEXITCODE -ne 0) { throw "v0.234 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0234ComposedBattlefieldReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.234 contact-sheet assembly failed." }
Write-Output "PASS_V0234_COMPOSED_BLENDER_BATTLEFIELD_REVIEW_PACK_READY"
