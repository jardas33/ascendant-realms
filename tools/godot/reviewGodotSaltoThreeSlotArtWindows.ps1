param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ReviewExeName = "AscendantRealmsGodotSalto-v0166.exe"
$ReviewExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\$ReviewExeName"

Set-Location $RepoRoot

$env:GODOT_EXPORT_EXE_NAME = $ReviewExeName
$env:GODOT_PACKAGE_EXE_PATH = $ReviewExePath
if (-not (Test-Path -LiteralPath $ReviewExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

if (-not (Test-Path -LiteralPath $ReviewExePath)) {
  throw "Missing v0.166 review executable: $ReviewExePath"
}

$ReviewArgs = @(
  "--experimental-review-mode-label=Experimental opt-in art: Worker + Barracks + Militia",
  "--salto-three-slot-review-framing",
  "--worker-art-scale=1.15",
  "--militia-art-scale=1.12"
)
if ($RemainingArgs) {
  $ReviewArgs += $RemainingArgs
}

Write-Output "Launching v0.166 three-slot experimental opt-in art review."
Write-Output "Executable: $ReviewExePath"
Write-Output "Review mode label: Experimental opt-in art: Worker + Barracks + Militia"
Write-Output "Review camera: v0166_three_slot_art_review / SAFE_ZOOM_MIN"
Write-Output "Worker: worker_billboard_static_v0147 / HYBRID_WORKER_TRIMMED_1024 / a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"
Write-Output "Barracks: barrosan_barracks_material_v0149 / HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND / 58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f"
Write-Output "Militia: militia_billboard_static_v0154 / HYBRID_MILITIA_TRIMMED_1024 / c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb"

$PreviousGodotSaltoExePath = $env:GODOT_SALTO_EXE_PATH
$env:GODOT_SALTO_EXE_PATH = $ReviewExePath
if ($Wait) {
  try {
    & (Join-Path $PSScriptRoot "launchGodotSaltoWorkerBarracksMilitiaArtExperimentWindows.ps1") -Wait @ReviewArgs
  } finally {
    $env:GODOT_SALTO_EXE_PATH = $PreviousGodotSaltoExePath
  }
  return
}

try {
  & (Join-Path $PSScriptRoot "launchGodotSaltoWorkerBarracksMilitiaArtExperimentWindows.ps1") @ReviewArgs
} finally {
  $env:GODOT_SALTO_EXE_PATH = $PreviousGodotSaltoExePath
}
