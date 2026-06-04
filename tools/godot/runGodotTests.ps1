param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotProjectPath = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$RuntimeReportPath = Join-Path $GodotProjectPath "reports\godot-runtime-test-report.json"
$GodotExe = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) {
  $env:GODOT_BIN
} elseif (Test-Path (Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe")) {
  Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
} else {
  $null
}
Set-Location $RepoRoot

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

function Invoke-GodotAndWait {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)
  $process = Start-Process `
    -FilePath $GodotExe `
    -ArgumentList (ConvertTo-ProcessArgumentString $Arguments) `
    -Wait `
    -PassThru `
    -WindowStyle Hidden
  return $process.ExitCode
}

function Wait-ForRuntimeReport {
  param([Parameter(Mandatory = $true)][string]$Path)
  $deadline = (Get-Date).AddSeconds(10)
  while (-not (Test-Path -LiteralPath $Path) -and (Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 200
  }
  return Test-Path -LiteralPath $Path
}

node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" validate
if ($GodotExe) {
  if (Test-Path -LiteralPath $RuntimeReportPath) {
    Remove-Item -LiteralPath $RuntimeReportPath -Force
  }
  $GodotExitCode = Invoke-GodotAndWait @("--headless", "--quit-after", "60", "--path", $GodotProjectPath, "--", "--run-tests")
  $RuntimeReportWritten = Wait-ForRuntimeReport $RuntimeReportPath
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" test
  $ToolExitCode = $LASTEXITCODE
  if ($ToolExitCode -ne 0) {
    exit $ToolExitCode
  }
  if (-not $RuntimeReportWritten) {
    Write-Error "Godot headless test runtime report was not written: $RuntimeReportPath"
    exit 1
  }
  if ($GodotExitCode -ne 0) {
    exit $GodotExitCode
  }
}
else {
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" test
}
