param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotProjectPath = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0146"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")
$GodotExe = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) {
  $env:GODOT_BIN
} elseif (Test-Path (Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe")) {
  Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
} else {
  $null
}

Set-Location $RepoRoot
if (-not $GodotExe) {
  throw "Missing Godot executable. Run npm run godot:doctor or GODOT_BOOTSTRAP_WINDOWS.bat."
}

if (Test-Path -LiteralPath $ArtifactRoot) {
  $resolvedArtifact = Resolve-Path -LiteralPath $ArtifactRoot
  $expectedRoot = Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto")
  if (-not ($resolvedArtifact.Path.StartsWith($expectedRoot.Path))) {
    throw "Refusing to remove comparator artifacts outside expected root: $($resolvedArtifact.Path)"
  }
  Remove-Item -LiteralPath $ArtifactRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

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

node "tools/godot/runtimeArtComparatorTool.mjs" validate "--artifact-root=$ArtifactArg"
$Arguments = @("--path", $GodotProjectPath, "--disable-vsync", "--max-fps", "0", "--resolution", "1600x900", "--", "--runtime-art-comparator", "--capture-only", "--artifact-root=$ArtifactArg")
$Process = Start-Process -FilePath $GodotExe -ArgumentList (ConvertTo-ProcessArgumentString $Arguments) -Wait -PassThru -WindowStyle Hidden
$GodotExitCode = if ($null -eq $Process.ExitCode) { 0 } else { $Process.ExitCode }
if ($GodotExitCode -ne 0) {
  throw "Godot runtime-art comparator capture exited with code $GodotExitCode."
}
node "tools/godot/runtimeArtComparatorTool.mjs" report "--artifact-root=$ArtifactArg"
