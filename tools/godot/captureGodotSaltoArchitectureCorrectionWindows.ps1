param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0235"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0235-architecture-correction-beauty-pass"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0234-composed-blender-battlefield-slice\02_v0234_composed_overview.png"
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.234 composed battlefield baseline." }
if (Test-Path -LiteralPath $ArtifactRoot) { Remove-Item -LiteralPath $ArtifactRoot -Recurse -Force }
if (Test-Path -LiteralPath $ManualRoot) { Remove-Item -LiteralPath $ManualRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null

& (Join-Path $RepoRoot "tools\blender\generateV0235SaltoBarrosanArchitectureWindows.ps1")
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing exported Godot executable." }
$GodotArgs = "--salto-architecture-correction-beauty-pass `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $GodotArgs -Wait -PassThru -WindowStyle Hidden
if ($Process.ExitCode -ne 0) { throw "Godot v0.235 architecture capture failed." }
$Manifest = Join-Path $RuntimeRoot "v0235-architecture-correction-runtime.json"
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.235 runtime manifest." }
Copy-Item -LiteralPath $Baseline -Destination (Join-Path $ManualRoot "01_v0234_baseline_overview.png")
Get-ChildItem -LiteralPath (Join-Path $RuntimeRoot "screenshots") -Filter "*.png" | Copy-Item -Destination $ManualRoot
node tools/godot/saltoArchitectureCorrectionTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=PASS"
if ($LASTEXITCODE -ne 0) { throw "v0.235 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0235ArchitectureReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.235 contact-sheet assembly failed." }
Write-Output "PASS_V0235_ARCHITECTURE_REVIEW_PACK_READY"
