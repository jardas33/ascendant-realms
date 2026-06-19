param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0233"
$ReportPath = Join-Path $ArtifactRoot "blender-tooling-report.json"
$OutputPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0233\salto_modular_environment_kit.glb"
Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

$Candidates = [System.Collections.Generic.List[string]]::new()
$Command = Get-Command blender -ErrorAction SilentlyContinue
if ($Command) { $Candidates.Add($Command.Source) }
@(
  "C:\Program Files\Blender Foundation\Blender 4.4\blender.exe",
  "C:\Program Files\Blender Foundation\Blender 4.3\blender.exe",
  "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe",
  "C:\Program Files\Blender Foundation\Blender 4.1\blender.exe",
  "C:\Program Files\Blender Foundation\Blender 4.0\blender.exe",
  "C:\Program Files\Blender Foundation\Blender 3.6\blender.exe"
) | ForEach-Object { $Candidates.Add($_) }

$RegistryRoots = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
foreach ($RegistryRoot in $RegistryRoots) {
  Get-ItemProperty $RegistryRoot -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Blender*" } |
    ForEach-Object {
      if ($_.InstallLocation) {
        $Candidates.Add((Join-Path $_.InstallLocation "blender.exe"))
      }
      if ($_.DisplayIcon) {
        $Candidates.Add(($_.DisplayIcon -replace ',\d+$', '').Trim('"'))
      }
    }
}

@(
  (Join-Path $env:LOCALAPPDATA "Programs\Blender Foundation\Blender\blender.exe"),
  (Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps\blender.exe"),
  (Join-Path $env:USERPROFILE "scoop\apps\blender\current\blender.exe"),
  "C:\ProgramData\chocolatey\bin\blender.exe",
  "C:\ProgramData\chocolatey\lib\blender\tools\blender.exe",
  "C:\Program Files (x86)\Steam\steamapps\common\Blender\blender.exe",
  "D:\SteamLibrary\steamapps\common\Blender\blender.exe",
  "E:\SteamLibrary\steamapps\common\Blender\blender.exe"
) | ForEach-Object { if ($_){ $Candidates.Add($_) } }

$SteamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
if ($SteamPath) {
  $Candidates.Add((Join-Path $SteamPath "steamapps\common\Blender\blender.exe"))
}

$Blender = $Candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1

if (-not $Blender) {
  @{
    schemaVersion = 1
    checkpoint = "v0.233"
    status = "BLOCKED_FOR_LOCAL_BLENDER_EXPORT"
    blenderAvailable = $false
    blenderPath = $null
    sourceScript = "tools/blender/generate_v0233_salto_modular_kit.py"
    expectedGlbPath = "desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb"
    actualGlbProduced = $false
    searched = @("PATH", "Blender Foundation 3.6-4.4", "registry", "user-local programs", "Scoop", "Chocolatey", "Steam libraries")
    downloadedAssets = 0
    generatedAiImages = 0
  } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
  Write-Output "BLOCKED_FOR_LOCAL_BLENDER_EXPORT"
  exit 0
}

& $Blender --background --factory-startup --python tools/blender/generate_v0233_salto_modular_kit.py -- "--output=$($OutputPath.Replace('\','/'))"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath)) {
  throw "Blender did not produce the expected GLB."
}
@{
  schemaVersion = 1
  checkpoint = "v0.233"
  status = "PASS_BLENDER_GLTF_EXPORT"
  blenderAvailable = $true
  blenderPath = $Blender
  actualGlbProduced = $true
  glbPath = $OutputPath
  downloadedAssets = 0
  generatedAiImages = 0
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Output "PASS_V0233_BLENDER_GLTF_EXPORT_READY"
