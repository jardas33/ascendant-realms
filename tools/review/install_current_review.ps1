# Ascendant Realms R59 current-review pointer installer. Never launches a game.
[CmdletBinding()]
param([string]$OutputDirectory = 'D:\CodexData\review\AscendantRealms')
$ErrorActionPreference = 'Stop'
$reviewRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$ownerThread = '01a073a7-7453-7061-ad0e-33954b8b69ee'
$sha = (& git -C $reviewRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Cannot read review HEAD.' }
$branch = (& git -C $reviewRoot branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $branch -ne 'codex/emanuel-playable-convergence-r59') { throw 'Install only from the isolated R59 review branch.' }
$launcher = Join-Path $PSScriptRoot 'run_playable_review.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $launcher -ExpectedSha $sha -ExpectedBranch $branch -ValidateOnly
if ($LASTEXITCODE -ne 0) { throw 'Review source validation failed; current pointer was not changed.' }
$pointer = Join-Path $OutputDirectory 'CURRENT_BUILD.json'
$currentScript = Join-Path $OutputDirectory 'LaunchCurrentReview.ps1'
$batch = Join-Path $OutputDirectory 'RUN_ULTIMATE_CURRENT_BUILD.bat'
if (Test-Path -LiteralPath $pointer) {
    $previous = Get-Content -LiteralPath $pointer -Raw | ConvertFrom-Json
    if ($previous.owner_thread -ne $ownerThread) { throw 'Another chat owns CURRENT_BUILD.json; nothing was overwritten.' }
}
foreach ($file in @($currentScript, $batch)) {
    if (Test-Path -LiteralPath $file) {
        if (-not ([IO.File]::ReadAllText($file)).Contains('Ascendant Realms owned review launcher')) { throw ('A foreign launcher already exists: ' + $file) }
    }
}
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$scriptText = @'
# Ascendant Realms owned review launcher
[CmdletBinding()]
param([switch]$ValidateOnly)
$ErrorActionPreference = 'Stop'
try {
    $current = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'CURRENT_BUILD.json') -Raw | ConvertFrom-Json
    $launcher = Join-Path $current.worktree 'tools/review/run_playable_review.ps1'
    if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) { throw ('Review worktree is unavailable: ' + $current.worktree) }
    & $launcher -ExpectedSha $current.sha -ExpectedBranch $current.branch -ValidateOnly:$ValidateOnly
    exit $LASTEXITCODE
} catch {
    Write-Host ('CURRENT REVIEW STOPPED: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
'@
$batchText = @'
@echo off
rem Ascendant Realms owned review launcher
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0LaunchCurrentReview.ps1"
if errorlevel 1 pause
endlocal
'@
$status = Get-Content -LiteralPath (Join-Path $reviewRoot 'docs/codex/emanuel_playable_r59/BUILD_STATUS.json') -Raw | ConvertFrom-Json
$current = [ordered]@{owner_thread=$ownerThread; worktree=$reviewRoot; branch=$branch; sha=$sha; classification=$status.classification; installed_utc=[DateTime]::UtcNow.ToString('o')}
$encoding = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($currentScript, $scriptText.Replace("`r`n", "`n") + "`n", $encoding)
[IO.File]::WriteAllText($batch, $batchText.Replace("`r`n", "`n").Replace("`n", "`r`n") + "`r`n", $encoding)
[IO.File]::WriteAllText($pointer, ($current | ConvertTo-Json) + "`n", $encoding)
Write-Host ('Installed current review launcher: ' + $batch)
Write-Host ('Pinned SHA: ' + $sha)
Write-Host 'No game launched and no desktop control performed.'
