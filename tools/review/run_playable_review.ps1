# Ascendant Realms R59 human-review launcher. No diagnostic scene or fixture.
[CmdletBinding()]
param(
    [string]$ExpectedSha = '',
    [string]$ExpectedBranch = 'codex/emanuel-playable-convergence-r59',
    [string]$EnginePath = 'D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe',
    [switch]$ValidateOnly
)
$ErrorActionPreference = 'Stop'
$reviewRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$runtimeRel = 'production/ascendant-realms-godot'
$gamePath = Join-Path $reviewRoot $runtimeRel
$reviewDocs = Join-Path $reviewRoot 'docs/codex/emanuel_playable_r59'
$certifiedHash = 'ef90e929ba1a6a4322860285d97f40f4aa349c90329a91b0e8b55b8df0f4cb00'

function Invoke-ReviewGit {
    param([string[]]$GitArguments)
    $lines = @(& git -c core.quotepath=false -c core.safecrlf=false -C $reviewRoot @GitArguments 2>$null)
    if ($LASTEXITCODE -ne 0) { throw ('Git failed: ' + ($GitArguments -join ' ')) }
    return $lines
}

function Get-ReviewHash {
    param([string]$Path, [bool]$CanonicalText)
    if (-not $CanonicalText) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
    $copy = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n")
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($algorithm.ComputeHash($encoding.GetBytes($copy)))).Replace('-', '').ToLowerInvariant() }
    finally { $algorithm.Dispose() }
}

function Assert-ReviewIntegrity {
    param($Manifest)
    foreach ($entry in $Manifest.files.PSObject.Properties) {
        $file = Join-Path $gamePath $entry.Name
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw ('Missing runtime source: ' + $entry.Name) }
        if ((Get-ReviewHash -Path $file -CanonicalText ([bool]$entry.Value.text)) -ne $entry.Value.sha256) {
            throw ('Runtime source differs from this reviewed build: ' + $entry.Name)
        }
    }
    foreach ($descriptor in $Manifest.critical_import_settings.PSObject.Properties) {
        $content = [IO.File]::ReadAllText((Join-Path $gamePath $descriptor.Name))
        foreach ($setting in $descriptor.Value.PSObject.Properties) {
            $pattern = '(?im)^' + [Regex]::Escape($setting.Name) + '=' + [Regex]::Escape([string]$setting.Value) + '\r?$'
            if ($content -notmatch $pattern) { throw ('Critical asset import setting changed: ' + $descriptor.Name + ' / ' + $setting.Name) }
        }
    }
    $extras = @(Invoke-ReviewGit -GitArguments @('ls-files', '--others', '--exclude-standard', '--', $runtimeRel))
    foreach ($extra in $extras) {
        if ($extra -match '\.(import|uid)$') { continue }
        $relative = $extra.Substring($runtimeRel.Length + 1)
        $allowed = $Manifest.generated_dependencies.PSObject.Properties[$relative]
        if ($null -eq $allowed) { throw ('Uncommitted runtime source is outside this review: ' + $extra) }
        if ((Get-ReviewHash -Path (Join-Path $gamePath $relative) -CanonicalText $false) -ne $allowed.Value.sha256) {
            throw ('Generated texture differs from its committed GLB payload: ' + $relative)
        }
    }
}

try {
    Get-Command git -ErrorAction Stop | Out-Null
    $actualRoot = (@(Invoke-ReviewGit -GitArguments @('rev-parse', '--show-toplevel')))[0]
    if ([IO.Path]::GetFullPath($actualRoot) -ne [IO.Path]::GetFullPath($reviewRoot)) { throw 'Wrong Git project root.' }
    $actualSha = (@(Invoke-ReviewGit -GitArguments @('rev-parse', 'HEAD')))[0]
    $actualBranch = (@(Invoke-ReviewGit -GitArguments @('branch', '--show-current')))[0]
    if ($actualBranch -ne $ExpectedBranch -or $actualBranch -notlike 'codex/emanuel-playable-*') { throw ('Wrong review branch: ' + $actualBranch) }
    if ($ExpectedSha -and $actualSha -ne $ExpectedSha) { throw ('The current-build pointer expects ' + $ExpectedSha + ', but checkout HEAD is ' + $actualSha) }
    if (-not (Test-Path -LiteralPath $EnginePath -PathType Leaf)) { throw ('Certified Godot is missing: ' + $EnginePath) }
    if ((Get-FileHash -LiteralPath $EnginePath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $certifiedHash) { throw 'Godot executable does not match the certified 4.6.3 build.' }
    if (Test-Path -LiteralPath (Join-Path $gamePath 'override.cfg')) { throw 'A local override.cfg would change this review. Preserve it separately before launching.' }
    $project = [IO.File]::ReadAllText((Join-Path $gamePath 'project.godot'))
    if (-not $project.Contains('config/name="Ascendant Realms"') -or -not $project.Contains('run/main_scene="res://scenes/main.tscn"') -or -not $project.Contains('config/custom_user_dir_name="AscendantRealms_Emanuel_Playable_R59"')) { throw 'Runtime identity or private review profile does not match R59.' }
    $changes = @(Invoke-ReviewGit -GitArguments @('diff', '--name-only', 'HEAD', '--', $runtimeRel, 'tools/review', 'docs/codex/emanuel_playable_r59', '.gitattributes', 'PLAY_EMANUEL_REVIEW.bat'))
    $sourceChanges = @($changes | Where-Object { $_ -notmatch '\.(import|uid)$' })
    if ($sourceChanges.Count) { throw ('Uncommitted runtime changes: ' + ($sourceChanges -join ', ')) }
    $manifest = Get-Content -LiteralPath (Join-Path $reviewDocs 'INTEGRITY.json') -Raw | ConvertFrom-Json
    $status = Get-Content -LiteralPath (Join-Path $reviewDocs 'BUILD_STATUS.json') -Raw | ConvertFrom-Json
    Assert-ReviewIntegrity -Manifest $manifest
    Write-Host ''
    Write-Host 'ASCENDANT REALMS - EMANUEL HUMAN REVIEW' -ForegroundColor Yellow
    Write-Host ('Branch: ' + $actualBranch)
    Write-Host ('SHA:    ' + $actualSha)
    Write-Host ('Path:   ' + $gamePath)
    Write-Host ('Status: ' + $status.classification)
    Write-Host ('Profile: AscendantRealms_Emanuel_Playable_R59 (separate from ordinary saves)')
    if ($status.pending_live_checks.Count) { Write-Host ('Pending checks: ' + ($status.pending_live_checks -join '; ')) -ForegroundColor Yellow }
    if ($ValidateOnly) { Write-Host 'VALIDATE_ONLY PASS - no game or desktop action performed.'; exit 0 }

    # Do not start two writers against one review profile or silently label an
    # already running, previously uncommitted process as this exact SHA.
    $normalizedGamePath = $gamePath.Replace('\', '/')
    $existing = @(Get-CimInstance Win32_Process -Filter "Name = 'Godot_v4.6.3-stable_win64.exe'" | Where-Object {
        $_.CommandLine -and $_.CommandLine.Replace('\', '/').IndexOf($normalizedGamePath, [StringComparison]::OrdinalIgnoreCase) -ge 0 -and $_.CommandLine -notmatch '--headless|--editor'
    })
    if ($existing.Count) { throw ('A game from this review directory is already running (PID ' + (($existing | ForEach-Object { $_.ProcessId }) -join ', ') + '). Close it normally before launching the pinned SHA. No second game was opened.') }

    # A fresh Git checkout has no import cache. Prepare it before normal play.
    $needsImport = $false
    foreach ($rel in $manifest.required_cache_outputs) {
        if (-not (Test-Path -LiteralPath (Join-Path $gamePath $rel))) { $needsImport = $true }
    }
    if ($needsImport) {
        $logDir = Join-Path $env:LOCALAPPDATA 'AscendantRealmsReview/launcher'
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $stdout = Join-Path $logDir ($stamp + '-import.stdout.log')
        $stderr = Join-Path $logDir ($stamp + '-import.stderr.log')
        Write-Host ('First-launch asset import; logs: ' + $logDir)
        $importArgs = @('--path', ('"{0}"' -f $gamePath), '--headless', '--editor', '--import', '--quit')
        $importer = Start-Process -FilePath $EnginePath -ArgumentList $importArgs -WindowStyle Hidden -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru
        $importer.WaitForExit()
        $importer.Refresh()
        if ($importer.ExitCode -ne 0) { throw ('Asset import failed; inspect ' + $stderr) }
        $errors = @(Get-Content -LiteralPath $stderr | Where-Object { $_ -match '^(SCRIPT ERROR|ERROR):' })
        if ($errors.Count) { throw ('Asset import logged errors; inspect ' + $stderr) }
        Assert-ReviewIntegrity -Manifest $manifest
    }
    Write-Host 'Launching the ordinary main scene. Main Menu > Skirmish > Begin Battle.'
    Write-Host 'Choose Granitborn to review the new Hold, Roundhouse and Forge.'
    $game = Start-Process -FilePath $EnginePath -ArgumentList @('--path', ('"{0}"' -f $gamePath)) -WindowStyle Normal -PassThru
    $game.WaitForExit()
    exit 0
} catch {
    Write-Host ('REVIEW LAUNCH STOPPED: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
