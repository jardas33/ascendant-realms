param(
  [switch]$DownloadOfficialInCi,
  [switch]$KeepTemp
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$OriginalAppData = $env:APPDATA
$CiAppData = Join-Path $RepoRoot ".tools\godot\ci-appdata"
$Bootstrap = Join-Path $PSScriptRoot "bootstrapGodotWindows.ps1"
$FreshCheckout = Join-Path $PSScriptRoot "validateGodotFreshCheckout.ps1"

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $CiAppData | Out-Null
$env:APPDATA = $CiAppData

function Test-GodotAvailable {
  if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) {
    return $true
  }
  return Test-Path -LiteralPath (Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe")
}

if (-not (Test-GodotAvailable)) {
  if (-not $DownloadOfficialInCi) {
    throw "BLOCKED_PENDING_LOCAL_GODOT_SETUP: Godot is missing. Re-run in CI with -DownloadOfficialInCi or bootstrap locally through the documented script."
  }
  if ($env:CI -ne "true") {
    throw "-DownloadOfficialInCi is allowed only when CI=true."
  }
  & $Bootstrap -DownloadOfficial -InstallExportTemplates
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

$GodotExe = if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) {
  (Resolve-Path -LiteralPath $env:GODOT_BIN).Path
} else {
  (Resolve-Path -LiteralPath (Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe")).Path
}

$versionOutput = (& $GodotExe --version 2>&1 | Out-String).Trim()
if (-not $versionOutput.Contains("4.6.3")) {
  throw "Detected Godot version is not 4.6.3: $versionOutput"
}

if ($KeepTemp) {
  & $FreshCheckout -KeepTemp
} else {
  & $FreshCheckout
}
$exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
$env:APPDATA = $OriginalAppData
if ($exitCode -ne 0) {
  exit $exitCode
}
