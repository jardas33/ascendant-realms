param(
  [string]$LeaseDir = $(if ($env:ASCENDANT_CODEX_LEASE_DIR) { $env:ASCENDANT_CODEX_LEASE_DIR } else { 'D:\CodexData\runtime\leases' }),
  [switch]$Once,
  [int]$IntervalMs = 500
)

function Write-Result($Lease, $Result) {
  $path = Join-Path $LeaseDir ("{0}.watchdog.json" -f [IO.Path]::GetFileNameWithoutExtension($Lease.Name))
  [IO.File]::WriteAllText($path, ($Result | ConvertTo-Json -Depth 8), [Text.UTF8Encoding]::new($false))
}

do {
  if (Test-Path -LiteralPath $LeaseDir) {
    foreach ($leaseFile in Get-ChildItem -LiteralPath $LeaseDir -Filter '*.json' -File -ErrorAction SilentlyContinue) {
      if ($leaseFile.Name -like '*.watchdog.json') { continue }
      try { $lease = Get-Content -LiteralPath $leaseFile.FullName -Raw | ConvertFrom-Json } catch { continue }
      if (-not $lease.kill_allowed -or $lease.status -notin @('RUNNING','TERMINATING')) { continue }
      $deadline = [DateTime]::Parse($lease.hard_deadline).ToUniversalTime()
      $progressDeadline = if ($lease.progress_deadline) { [DateTime]::Parse($lease.progress_deadline).ToUniversalTime() } else { $null }
      $now = [DateTime]::UtcNow
      $reason = if ($now -ge $deadline) { 'HARD_TIMEOUT' } elseif ($progressDeadline -and $now -ge $progressDeadline) { 'NO_PROGRESS_TIMEOUT' } else { $null }
      if (-not $reason) { continue }
      $process = Get-CimInstance Win32_Process -Filter ("ProcessId={0}" -f [int]$lease.pid) -ErrorAction SilentlyContinue
      $owned = $process -and ($process.ExecutablePath -eq $lease.executable) -and ($process.ParentProcessId -eq [int]$lease.parent_pid -or $process.CommandLine -like "*$($lease.label)*" -or $process.CommandLine -like "*$($lease.cwd)*")
      $result = [ordered]@{ schema='ascendant-codex-watchdog-result-v1'; status='WATCHDOG_SKIPPED_OWNERSHIP_MISMATCH'; lease=$leaseFile.FullName; pid=$lease.pid; reason=$reason; checked_at=$now.ToString('o'); termination_attempted=$false; termination_succeeded=$false }
      if ($owned) {
        $result.status='WATCHDOG_TERMINATED_STALLED_OWNED_PROCESS'; $result.termination_attempted=$true
        & taskkill.exe /PID ([int]$lease.pid) /T /F | Out-Null
        Start-Sleep -Milliseconds 300
        $result.termination_succeeded = -not (Get-Process -Id ([int]$lease.pid) -ErrorAction SilentlyContinue)
      }
      Write-Result $leaseFile $result
    }
  }
  if (-not $Once) { Start-Sleep -Milliseconds $IntervalMs }
} while (-not $Once)
