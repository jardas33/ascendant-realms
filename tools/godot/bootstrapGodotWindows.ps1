param(
  [switch]$DownloadOfficial,
  [switch]$InstallExportTemplates
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ToolRoot = Join-Path $RepoRoot ".tools\godot"
$CacheRoot = Join-Path $ToolRoot "cache"
$GodotZip = Join-Path $CacheRoot "Godot_v4.6.3-stable_win64.exe.zip"
$TemplatesTpz = Join-Path $CacheRoot "Godot_v4.6.3-stable_export_templates.tpz"
$EditorUrl = "https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_win64.exe.zip"
$TemplatesUrl = "https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz"
$GodotExe = Join-Path $ToolRoot "Godot_v4.6.3-stable_win64.exe"
$TemplatesTarget = Join-Path $env:APPDATA "Godot\export_templates\4.6.3.stable"

Set-Location $RepoRoot

Write-Host "v0.117 Godot bootstrap for Ascendant Realms"
Write-Host "Official standard editor URL: $EditorUrl"
Write-Host "Official standard export templates URL: $TemplatesUrl"
Write-Host "Repository-local Godot path: $GodotExe"
Write-Host "Export templates target: $TemplatesTarget"
Write-Host ""

if (-not $DownloadOfficial) {
  Write-Host "Instruction-only mode. No downloads were attempted."
  Write-Host "Run this script with -DownloadOfficial to download the official standard Godot 4.6.3 Windows x86_64 editor and export templates."
  Write-Host "Add -InstallExportTemplates to also place templates under the Godot export_templates folder."
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" doctor
  exit 0
}

New-Item -ItemType Directory -Force -Path $ToolRoot, $CacheRoot | Out-Null

if (-not (Test-Path $GodotZip)) {
  Write-Host "Downloading official Godot editor archive..."
  Invoke-WebRequest -Uri $EditorUrl -OutFile $GodotZip
}

if (-not (Test-Path $TemplatesTpz)) {
  Write-Host "Downloading official Godot export templates..."
  Invoke-WebRequest -Uri $TemplatesUrl -OutFile $TemplatesTpz
}

if (-not (Test-Path $GodotExe)) {
  Write-Host "Extracting Godot editor to .tools/godot..."
  Expand-Archive -LiteralPath $GodotZip -DestinationPath $ToolRoot -Force
}

if (-not (Test-Path $GodotExe)) {
  throw "Godot executable was not found after extraction: $GodotExe"
}

Write-Host "Verifying Godot executable..."
try {
  & $GodotExe --version
} catch {
  Write-Host "Godot version command returned through stderr/nonzero status; continuing to doctor verification."
}

if ($InstallExportTemplates) {
  Write-Host "Installing export templates to $TemplatesTarget..."
  $ExtractedTemplates = Join-Path $CacheRoot "templates-extracted"
  if (Test-Path $ExtractedTemplates) {
    $resolved = Resolve-Path -LiteralPath $ExtractedTemplates
    if (-not ($resolved.Path.StartsWith((Resolve-Path -LiteralPath $CacheRoot).Path))) {
      throw "Refusing to clear unexpected template extraction path: $($resolved.Path)"
    }
    Remove-Item -LiteralPath $ExtractedTemplates -Recurse -Force
  }
  New-Item -ItemType Directory -Force -Path $ExtractedTemplates, $TemplatesTarget | Out-Null
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($TemplatesTpz, $ExtractedTemplates)
  $TemplateSource = Join-Path $ExtractedTemplates "templates"
  if (-not (Test-Path (Join-Path $TemplateSource "windows_release_x86_64.exe"))) {
    throw "Export template archive did not contain windows_release_x86_64.exe."
  }
  Copy-Item -Path (Join-Path $TemplateSource "*") -Destination $TemplatesTarget -Recurse -Force
}
else {
  Write-Host "Templates were downloaded but not installed. To install them automatically, rerun with -DownloadOfficial -InstallExportTemplates."
}

node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" doctor
