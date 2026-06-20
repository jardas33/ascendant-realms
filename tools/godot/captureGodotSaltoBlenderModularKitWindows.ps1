param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0233"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0233-blender-modular-kit"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0232-visual-pipeline-reset\02_new_visual_spike_overview.png"
$GlbPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0233\salto_modular_environment_kit.glb"
Set-Location $RepoRoot
if (Test-Path -LiteralPath $ArtifactRoot) { Remove-Item -LiteralPath $ArtifactRoot -Recurse -Force }
if (Test-Path -LiteralPath $ManualRoot) { Remove-Item -LiteralPath $ManualRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ManualRoot | Out-Null

& (Join-Path $RepoRoot "tools\blender\generateV0233SaltoModularKitWindows.ps1")
if (-not (Test-Path -LiteralPath $GlbPath)) { throw "Blender did not produce the required v0.233 GLB." }
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ExeDeadline = (Get-Date).AddSeconds(15)
while (-not (Test-Path -LiteralPath $ExePath) -and (Get-Date) -lt $ExeDeadline) {
  Start-Sleep -Milliseconds 250
}
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing exported Godot executable: $ExePath" }
$ExePath = (Resolve-Path -LiteralPath $ExePath).Path
$GodotArgs = "--salto-blender-modular-kit-spike `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$Process = Start-Process -FilePath $ExePath -ArgumentList $GodotArgs -Wait -PassThru -WindowStyle Hidden
Write-Output "Godot v0.233R importer process exit code: $($Process.ExitCode)"
if ($Process.ExitCode -ne 0) { throw "Godot v0.233R importer failed." }
$Manifest = Join-Path $RuntimeRoot "v0233-blender-modular-kit-runtime.json"
if (-not (Test-Path -LiteralPath $Manifest)) { throw "Missing v0.233R importer manifest." }
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.232 baseline comparator." }
Copy-Item -LiteralPath $Baseline -Destination (Join-Path $ManualRoot "01_v0232_baseline.png")
Get-ChildItem -LiteralPath (Join-Path $RuntimeRoot "screenshots") -Filter "*.png" |
  Copy-Item -Destination $ManualRoot

node tools/godot/saltoBlenderModularKitTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=PARTIAL"
if ($LASTEXITCODE -ne 0) { throw "v0.233R review-pack assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0233ReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.233R contact-sheet assembly failed." }
Write-Output "PASS_V0233R_REAL_GLTF_REVIEW_PACK_READY"
