param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotProjectPath = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0154\evidence"
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
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null

function ConvertTo-ProcessArgumentString {
  param([string[]]$Values)
  ($Values | ForEach-Object {
    if ($_ -match '[\s"]') {
      '"' + ($_ -replace '"', '\"') + '"'
    } else {
      $_
    }
  }) -join " "
}

node "tools/godot/militiaBillboardSingleSlotTool.mjs" metadata "--artifact-root=$ArtifactArg"
node "tools/godot/militiaBillboardSingleSlotTool.mjs" fallback:check "--artifact-root=$ArtifactArg"
node "tools/godot/militiaBillboardSingleSlotTool.mjs" validate "--artifact-root=$ArtifactArg"
$Arguments = @("--path", $GodotProjectPath, "--disable-vsync", "--max-fps", "0", "--resolution", "1600x900", "--", "--militia-billboard-single-slot", "--militia-billboard-single-slot-validate-only", "--artifact-root=$ArtifactArg")
$Process = Start-Process -FilePath $GodotExe -ArgumentList (ConvertTo-ProcessArgumentString $Arguments) -Wait -PassThru -WindowStyle Hidden
$GodotExitCode = $Process.ExitCode
$RuntimeValidationPath = Join-Path $ArtifactRoot "militia-billboard-single-slot-validation-runtime.json"
$RuntimeValidation = if (Test-Path -LiteralPath $RuntimeValidationPath) {
  Get-Content -Raw -LiteralPath $RuntimeValidationPath | ConvertFrom-Json
} else {
  $null
}
if ($GodotExitCode -ne 0 -or $RuntimeValidation.status -ne "PASS_V0154_MILITIA_BILLBOARD_RUNTIME_VALIDATION") {
  throw "Godot Militia billboard validation exited with code $GodotExitCode."
}
