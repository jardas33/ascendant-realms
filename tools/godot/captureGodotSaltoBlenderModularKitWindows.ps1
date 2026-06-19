param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0233"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0233-blender-modular-kit"
Set-Location $RepoRoot
if (Test-Path -LiteralPath $ArtifactRoot) { Remove-Item -LiteralPath $ArtifactRoot -Recurse -Force }
if (Test-Path -LiteralPath $ManualRoot) { Remove-Item -LiteralPath $ManualRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null

& (Join-Path $RepoRoot "tools\blender\generateV0233SaltoModularKitWindows.ps1")
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$GodotArgs = "--salto-blender-modular-kit-spike `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $GodotArgs -Wait -PassThru -WindowStyle Hidden
Write-Output "Godot v0.233 importer process exit code: $($Process.ExitCode)"
$Manifest = Join-Path $RuntimeRoot "v0233-blender-modular-kit-runtime.json"
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.233 importer manifest." }
node tools/godot/saltoBlenderModularKitTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))"
if ($LASTEXITCODE -ne 0) { throw "v0.233 review-pack assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0233BlockedReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.233 blocked review cards failed." }
Write-Output "BLOCKED_V0233_REVIEW_PACK_READY"
