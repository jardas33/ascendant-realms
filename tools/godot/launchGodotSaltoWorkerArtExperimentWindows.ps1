param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$SourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.png"
$MetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0148\local-worker-slot\worker_billboard_static_v0147_trimmed_1024.metadata.json"
$ExpectedSha = "a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc"

Set-Location $RepoRoot

if (-not (Test-Path $ExePath)) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}

if (-not (Test-Path $ExePath)) {
  throw "Missing packaged Godot executable after export. Run GODOT_EXPORT_WINDOWS.bat and GODOT_PACKAGE_WINDOWS.bat first."
}
if (-not (Test-Path $SourcePath)) {
  throw "Missing selected Worker art source: $SourcePath"
}
if (-not (Test-Path $MetadataPath)) {
  throw "Missing selected Worker art metadata: $MetadataPath"
}

function ConvertTo-ProcessArgumentString {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)
  return ($Arguments | ForEach-Object {
    if ($_ -match '[\s"]') {
      '"' + ($_ -replace '"', '\"') + '"'
    } else {
      $_
    }
  }) -join " "
}

$ArgumentList = @(
  "--player-slice",
  "--worker-art-opt-in",
  "--worker-art-source=$($SourcePath.Replace('\', '/'))",
  "--worker-art-metadata=$($MetadataPath.Replace('\', '/'))",
  "--worker-art-expected-sha256=$ExpectedSha",
  "--worker-art-scale=1.00"
)
if ($RemainingArgs) {
  $ArgumentList += $RemainingArgs
}

if ($Wait) {
  & $ExePath @ArgumentList
  $GodotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($GodotExitCode -ne 0) {
    throw "Packaged Godot Worker art opt-in player slice exited with code $GodotExitCode."
  }
  return
}

Start-Process -FilePath $ExePath -ArgumentList (ConvertTo-ProcessArgumentString $ArgumentList) | Out-Null
