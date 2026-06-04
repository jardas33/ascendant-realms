param(
  [switch]$KeepTemp
)

$ErrorActionPreference = "Stop"
$SourceRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$OriginalLocation = Get-Location
$TempRoot = $null
$Report = [ordered]@{
  schemaVersion = 1
  checkpoint = "v0.120"
  status = "RUNNING_GODOT_FRESH_CHECKOUT_VALIDATION"
  generatedAtUtc = "deterministic-v0120"
  sourceRoot = $SourceRoot.Path
  sourceCommit = $null
  temporaryCheckoutPath = $null
  temporaryCheckoutGenerated = $false
  exportedFileCount = 0
  ignoredGeneratedPathsOmittedBeforeRun = @{}
  godotBinary = $null
  godotVersionOutput = $null
  npmInstallMode = "npm ci --no-audit --no-fund"
  steps = @()
  checks = [ordered]@{}
  package = [ordered]@{}
  cleanup = [ordered]@{
    safeTempPath = $false
    tempDeleted = $false
    keepTempRequested = [bool]$KeepTemp
  }
  routineEditorUseRequired = $false
  browserRuntimeChanged = $false
  artImported = $false
  finalEngineChoiceMade = $false
  blocker = $null
}

function Convert-ToRepoRelativePath {
  param([Parameter(Mandatory = $true)][string]$Path)
  $full = [System.IO.Path]::GetFullPath($Path)
  $root = [System.IO.Path]::GetFullPath($SourceRoot.Path)
  if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $full.Substring($root.Length).TrimStart("\", "/").Replace("\", "/")
  }
  return $full
}

function Find-RepositoryGodot {
  if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) {
    return (Resolve-Path -LiteralPath $env:GODOT_BIN).Path
  }
  $repoLocal = Join-Path $SourceRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
  if (Test-Path -LiteralPath $repoLocal) {
    return (Resolve-Path -LiteralPath $repoLocal).Path
  }
  throw "BLOCKED_PENDING_LOCAL_GODOT_SETUP: expected Godot 4.6.3 standard x86_64 at .tools/godot/ or GODOT_BIN."
}

function Test-SafeTempRoot {
  param([Parameter(Mandatory = $true)][string]$Path)
  $fullPath = [System.IO.Path]::GetFullPath($Path)
  $tempPath = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
  $leaf = Split-Path -Leaf $fullPath
  return $fullPath.StartsWith($tempPath, [System.StringComparison]::OrdinalIgnoreCase) -and
    $leaf.StartsWith("ascendant-realms-godot-fresh-", [System.StringComparison]::OrdinalIgnoreCase)
}

function Convert-ToExtendedWindowsPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  $fullPath = [System.IO.Path]::GetFullPath($Path)
  if ($fullPath.StartsWith("\\?\")) {
    return $fullPath
  }
  if ($fullPath.StartsWith("\\")) {
    return "\\?\UNC\" + $fullPath.Substring(2)
  }
  return "\\?\" + $fullPath
}

function Remove-SafeTempRoot {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-SafeTempRoot $Path)) {
    throw "Refusing to delete unsafe temporary checkout path: $Path"
  }
  $lastError = $null
  for ($attempt = 1; $attempt -le 6; $attempt += 1) {
    try {
      Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
      return
    }
    catch {
      $lastError = $_.Exception.Message
      try {
        $extendedPath = Convert-ToExtendedWindowsPath $Path
        [System.IO.Directory]::Delete($extendedPath, $true)
        return
      }
      catch {
        $lastError = $_.Exception.Message
        Start-Sleep -Milliseconds (250 * $attempt)
      }
    }
  }
  throw $lastError
}

function Read-JsonFile {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing required report: $Path"
  }
  return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
}

function Invoke-FreshStep {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Command,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )
  $started = Get-Date
  Write-Host "[$Name] $Command $($Arguments -join ' ')"
  & $Command @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $ended = Get-Date
  $entry = [ordered]@{
    name = $Name
    command = "$Command $($Arguments -join ' ')"
    exitCode = $exitCode
    durationSeconds = [Math]::Round(($ended - $started).TotalSeconds, 3)
  }
  $script:Report.steps += $entry
  if ($exitCode -ne 0) {
    throw "Fresh checkout step failed: $Name exited with code $exitCode."
  }
}

function Copy-RepositoryFiles {
  param([Parameter(Mandatory = $true)][string]$DestinationRoot)
  Set-Location $SourceRoot
  $rawPaths = git ls-files --cached --modified --others --exclude-standard
  $paths = $rawPaths |
    Where-Object { $_ -and -not $_.StartsWith("artifacts/") } |
    Sort-Object -Unique
  foreach ($relativePath in $paths) {
    $sourcePath = Join-Path $SourceRoot ($relativePath -replace "/", "\")
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
      continue
    }
    $targetPath = Join-Path $DestinationRoot ($relativePath -replace "/", "\")
    $targetDir = Split-Path -Parent $targetPath
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
  }
  return @($paths).Count
}

function Test-OnlyGitkeep {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    return $true
  }
  $extra = Get-ChildItem -LiteralPath $Path -Force | Where-Object { $_.Name -ne ".gitkeep" }
  return @($extra).Count -eq 0
}

function Assert-Check {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][bool]$Condition,
    [Parameter(Mandatory = $true)][string]$Message
  )
  $script:Report.checks[$Name] = $Condition
  if (-not $Condition) {
    throw $Message
  }
}

function Write-FreshReport {
  param([Parameter(Mandatory = $true)]$Value)
  $reportRoot = Join-Path $SourceRoot "artifacts\desktop-spikes\godot-salto\v0120"
  $latestRoot = Join-Path $SourceRoot "artifacts\desktop-spikes\godot-salto\latest"
  New-Item -ItemType Directory -Force -Path $reportRoot, $latestRoot | Out-Null
  $json = $Value | ConvertTo-Json -Depth 24
  $reportPath = Join-Path $reportRoot "fresh-checkout-validation.json"
  $latestPath = Join-Path $latestRoot "fresh-checkout-validation-v0120.json"
  Set-Content -Path $reportPath -Value $json -Encoding ASCII
  Set-Content -Path $latestPath -Value $json -Encoding ASCII
  Write-Host "Fresh checkout report: $(Convert-ToRepoRelativePath $reportPath)"
}

$ErrorMessage = $null

try {
  Set-Location $SourceRoot
  $Report.sourceCommit = (git rev-parse HEAD).Trim()
  $GodotExe = Find-RepositoryGodot
  $Report.godotBinary = Convert-ToRepoRelativePath $GodotExe
  $env:GODOT_BIN = $GodotExe

  $GodotVersionOutput = (& $GodotExe --version 2>&1 | Out-String).Trim()
  $Report.godotVersionOutput = $GodotVersionOutput
  if (-not $GodotVersionOutput.Contains("4.6.3")) {
    throw "Detected Godot version is not 4.6.3: $GodotVersionOutput"
  }

  $TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ascendant-realms-godot-fresh-" + [Guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
  $Report.temporaryCheckoutPath = $TempRoot
  $Report.cleanup.safeTempPath = Test-SafeTempRoot $TempRoot
  if (-not $Report.cleanup.safeTempPath) {
    throw "Refusing to use unsafe temporary checkout path: $TempRoot"
  }

  $Report.exportedFileCount = Copy-RepositoryFiles -DestinationRoot $TempRoot
  $Report.temporaryCheckoutGenerated = $true

  $buildsRoot = Join-Path $TempRoot "desktop-spikes\godot-salto\builds"
  $reportsRoot = Join-Path $TempRoot "desktop-spikes\godot-salto\reports"
  $Report.ignoredGeneratedPathsOmittedBeforeRun = [ordered]@{
    localGodotTools = -not (Test-Path -LiteralPath (Join-Path $TempRoot ".tools\godot"))
    desktopSpikeArtifacts = -not (Test-Path -LiteralPath (Join-Path $TempRoot "artifacts\desktop-spikes"))
    desktopFixtureArtifacts = -not (Test-Path -LiteralPath (Join-Path $TempRoot "artifacts\desktop-spike-fixture"))
    godotEditorCache = -not (Test-Path -LiteralPath (Join-Path $TempRoot "desktop-spikes\godot-salto\.godot"))
    generatedBuilds = Test-OnlyGitkeep $buildsRoot
    generatedReports = Test-OnlyGitkeep $reportsRoot
  }
  foreach ($entry in $Report.ignoredGeneratedPathsOmittedBeforeRun.GetEnumerator()) {
    Assert-Check "ignored-$($entry.Key)-absent-before-run" ([bool]$entry.Value) "Ignored generated path was copied into the fresh checkout before validation: $($entry.Key)"
  }

  Set-Location $TempRoot
  Invoke-FreshStep "install dependencies" "npm" @("ci", "--no-audit", "--no-fund")
  Invoke-FreshStep "regenerate desktop spike fixture" "npm" @("run", "export:desktop-spike-fixture")
  Invoke-FreshStep "validate desktop spike fixture" "npm" @("run", "validate:desktop-spike-fixture")
  Invoke-FreshStep "generate Godot Salto scene" "npm" @("run", "godot:scene:generate")
  Invoke-FreshStep "validate repository-driven Godot project" "npm" @("run", "godot:validate")
  Invoke-FreshStep "run headless Godot tests" "npm" @("run", "godot:test")
  Invoke-FreshStep "run Godot benchmark smoke" "npm" @("run", "godot:benchmark")
  Invoke-FreshStep "export Windows Godot build" "npm" @("run", "godot:export:windows")
  Invoke-FreshStep "package Windows Godot build" "npm" @("run", "godot:package:windows")

  $fixtureHashReport = Read-JsonFile (Join-Path $TempRoot "artifacts\desktop-spike-fixture\latest\fixture-hashes.json")
  $testReport = Read-JsonFile (Join-Path $TempRoot "artifacts\desktop-spikes\godot-salto\latest\test-report.json")
  $benchmark2d = Read-JsonFile (Join-Path $TempRoot "artifacts\desktop-spikes\godot-salto\latest\benchmark-2d.json")
  $benchmark25d = Read-JsonFile (Join-Path $TempRoot "artifacts\desktop-spikes\godot-salto\latest\benchmark-2_5d.json")
  $exportReport = Read-JsonFile (Join-Path $TempRoot "artifacts\desktop-spikes\godot-salto\latest\Windows-export-report.json")
  $packageReport = Read-JsonFile (Join-Path $TempRoot "artifacts\desktop-spikes\godot-salto\latest\package-report.json")

  $packagePath = Join-Path $TempRoot ($packageReport.packagePath -replace "/", "\")
  $actualPackageHash = if (Test-Path -LiteralPath $packagePath) { (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant() } else { $null }

  Assert-Check "fixture-recreated" ([bool]$fixtureHashReport.fixtureHash) "Fresh checkout did not recreate fixture hashes."
  Assert-Check "godot-headless-tests-pass" ($testReport.status -eq "PASS_GODOT_HEADLESS_TESTS") "Fresh checkout Godot tests did not pass."
  Assert-Check "2d-benchmark-pass" ($benchmark2d.status -eq "PASS_GODOT_REPRESENTATIVE_RTS_BENCHMARK") "Fresh checkout 2D benchmark did not pass."
  Assert-Check "2_5d-benchmark-pass" ($benchmark25d.status -eq "PASS_GODOT_REPRESENTATIVE_RTS_BENCHMARK") "Fresh checkout 2.5D benchmark did not pass."
  Assert-Check "2d-tier-m-executed" (@($benchmark2d.workloadTiersExecuted) -contains "M") "Fresh checkout 2D benchmark did not execute Tier M."
  Assert-Check "2_5d-tier-m-executed" (@($benchmark25d.workloadTiersExecuted) -contains "M") "Fresh checkout 2.5D benchmark did not execute Tier M."
  Assert-Check "windows-export-pass" ($exportReport.status -eq "PASS_WINDOWS_EXPORT") "Fresh checkout Windows export did not pass."
  Assert-Check "windows-package-pass" ($packageReport.status -eq "PASS_WINDOWS_PACKAGE") "Fresh checkout Windows package did not pass."
  Assert-Check "package-hash-present" ([bool]$packageReport.packageSha256) "Fresh checkout package report is missing packageSha256."
  Assert-Check "package-hash-matches-file" ($actualPackageHash -eq $packageReport.packageSha256) "Fresh checkout package SHA-256 does not match the ZIP file."
  Assert-Check "routine-editor-not-required" (($testReport.runtimeReport.routineEditorUseRequired -eq $false) -or ($benchmark2d.routineEditorUseRequired -eq $false -and $benchmark25d.routineEditorUseRequired -eq $false)) "Fresh checkout reported routine editor use as required."

  $Report.package = [ordered]@{
    packagePath = $packageReport.packagePath
    packageSha256 = $packageReport.packageSha256
    packageSizeMb = $packageReport.packageSizeMb
    actualPackageSha256 = $actualPackageHash
    exportStatus = $exportReport.status
  }
  $Report.fixtureHash = $fixtureHashReport.fixtureHash
  $Report.status = "PASS_GODOT_FRESH_CHECKOUT_VALIDATION"
}
catch {
  $ErrorMessage = $_.Exception.Message
  $Report.status = "FAIL_GODOT_FRESH_CHECKOUT_VALIDATION"
  $Report.blocker = $ErrorMessage
}

Set-Location $OriginalLocation

if ($TempRoot -and (Test-Path -LiteralPath $TempRoot) -and -not $KeepTemp) {
  if (Test-SafeTempRoot $TempRoot) {
    try {
      Remove-SafeTempRoot $TempRoot
      $Report.cleanup.tempDeleted = -not (Test-Path -LiteralPath $TempRoot)
    }
    catch {
      $Report.cleanup.tempDeleted = $false
      $Report.cleanup.error = $_.Exception.Message
      if (-not $ErrorMessage) {
        $ErrorMessage = "Fresh checkout temporary directory cleanup failed: $($_.Exception.Message)"
        $Report.status = "FAIL_GODOT_FRESH_CHECKOUT_VALIDATION"
        $Report.blocker = $ErrorMessage
      }
    }
  } else {
    $Report.cleanup.tempDeleted = $false
    if (-not $ErrorMessage) {
      $ErrorMessage = "Refusing to delete unsafe temporary checkout path: $TempRoot"
      $Report.status = "FAIL_GODOT_FRESH_CHECKOUT_VALIDATION"
      $Report.blocker = $ErrorMessage
    }
  }
}
elseif ($KeepTemp) {
  $Report.cleanup.tempDeleted = $false
}

$Report.checks["cleanup-safe"] = [bool]$Report.cleanup.safeTempPath
$Report.checks["temp-deleted"] = [bool]$Report.cleanup.tempDeleted
if (-not $KeepTemp -and -not $Report.cleanup.tempDeleted -and -not $ErrorMessage) {
  $ErrorMessage = "Fresh checkout temporary directory was not deleted."
  $Report.status = "FAIL_GODOT_FRESH_CHECKOUT_VALIDATION"
  $Report.blocker = $ErrorMessage
}

Write-FreshReport -Value $Report

if ($ErrorMessage) {
  throw $ErrorMessage
}
