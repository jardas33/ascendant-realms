param(
  [switch]$ScorecardOnly
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotProjectPath = Join-Path $RepoRoot "desktop-spikes\godot-salto"
$Benchmark2dReportPath = Join-Path $GodotProjectPath "reports\godot-benchmark-2d.json"
$Benchmark25dReportPath = Join-Path $GodotProjectPath "reports\godot-benchmark-2_5d.json"
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

function Wait-ForBenchmarkReports {
  $deadline = (Get-Date).AddSeconds(10)
  while (
    ((-not (Test-Path -LiteralPath $Benchmark2dReportPath)) -or (-not (Test-Path -LiteralPath $Benchmark25dReportPath))) -and
    (Get-Date) -lt $deadline
  ) {
    Start-Sleep -Milliseconds 200
  }
  return (Test-Path -LiteralPath $Benchmark2dReportPath) -and (Test-Path -LiteralPath $Benchmark25dReportPath)
}

if ($ScorecardOnly) {
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" scorecard
  exit 0
}

node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" validate
if ($GodotExe) {
  foreach ($reportPath in @($Benchmark2dReportPath, $Benchmark25dReportPath)) {
    if (Test-Path -LiteralPath $reportPath) {
      Remove-Item -LiteralPath $reportPath -Force
    }
  }
  $GodotExitCode = Invoke-GodotAndWait @("--headless", "--quit-after", "60", "--path", $GodotProjectPath, "--", "--run-benchmark")
  $BenchmarkReportsWritten = Wait-ForBenchmarkReports
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" benchmark
  $ToolExitCode = $LASTEXITCODE
  if ($ToolExitCode -ne 0) {
    exit $ToolExitCode
  }
  if (-not $BenchmarkReportsWritten) {
    Write-Error "Godot benchmark runtime reports were not written."
    exit 1
  }
  if ($GodotExitCode -ne 0) {
    exit $GodotExitCode
  }
}
else {
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" benchmark
}
