param(
  [string]$Godot = $(if ($env:GODOT_BIN) { $env:GODOT_BIN } else { 'D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe' }),
  [string]$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\\..')).Path,
  [string[]]$Resolution = @('1920x1080', '1366x768'),
  [int]$ReadyTimeoutSeconds = 360
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Add-Type @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public static class AscendantWin32 {
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X; public int Y; }
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
  [StructLayout(LayoutKind.Sequential)] public struct MONITORINFO { public int cbSize; public RECT rcMonitor; public RECT rcWork; public uint dwFlags; }
  public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll", SetLastError=true)] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int maxCount);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
  [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT rect);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT point);
  [DllImport("user32.dll")] public static extern bool ScreenToClient(IntPtr hWnd, ref POINT point);
  [DllImport("user32.dll")] public static extern IntPtr WindowFromPoint(POINT point);
  [DllImport("user32.dll")] public static extern IntPtr GetAncestor(IntPtr hWnd, uint flags);
  [DllImport("user32.dll")] public static extern IntPtr MonitorFromWindow(IntPtr hWnd, uint flags);
  [DllImport("user32.dll", SetLastError=true)] public static extern bool GetMonitorInfo(IntPtr hMonitor, ref MONITORINFO info);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int command);
  [DllImport("user32.dll", SetLastError=true)] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr insertAfter, int x, int y, int cx, int cy, uint flags);
  [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extraInfo);
  [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr hWnd);
  public const uint GA_ROOT = 2;
  public const uint MONITOR_DEFAULTTONEAREST = 2;
  public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
  public const uint MOUSEEVENTF_LEFTUP = 0x0004;
  public const int SW_RESTORE = 9;
  public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
  public const uint SWP_NOSIZE = 0x0001;
  public const uint SWP_NOMOVE = 0x0002;
  public const uint SWP_SHOWWINDOW = 0x0040;
  public static void Activate(IntPtr hWnd) { ShowWindow(hWnd, SW_RESTORE); SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW); BringWindowToTop(hWnd); SetForegroundWindow(hWnd); }
  public static IntPtr FindMainWindow(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p); if (p == pid && IsWindowVisible(h) && GetAncestor(h, GA_ROOT) == h) { found = h; return false; } return true; }, IntPtr.Zero);
    return found;
  }
  public static string Title(IntPtr h) { var s = new StringBuilder(512); GetWindowText(h, s, s.Capacity); return s.ToString(); }
  public static Dictionary<string,int> Rect(RECT r) { return new Dictionary<string,int>{{"left",r.Left},{"top",r.Top},{"right",r.Right},{"bottom",r.Bottom},{"width",r.Right-r.Left},{"height",r.Bottom-r.Top}}; }
  public static Dictionary<string,int> PointValue(POINT p) { return new Dictionary<string,int>{{"x",p.X},{"y",p.Y}}; }
  public static bool RootMatches(IntPtr candidate, IntPtr root) { return candidate == root || GetAncestor(candidate, GA_ROOT) == root; }
  public static void Click(int x, int y) { if (!SetCursorPos(x,y)) throw new InvalidOperationException("SetCursorPos failed"); System.Threading.Thread.Sleep(500); mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,UIntPtr.Zero); System.Threading.Thread.Sleep(120); mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,UIntPtr.Zero); }
}
"@

Add-Type -AssemblyName System.Drawing

$project = Join-Path $Repo 'production\\ascendant-realms-godot'
$root = 'D:\\CodexData\\evidence\\ascendant-realms-core-playability-e\\F0_NATIVE_TUTORIAL_COMPLETION\\FINAL'
$allRecords = New-Object System.Collections.Generic.List[object]
$sourceSha = (& git -C $Repo rev-parse HEAD).Trim()
$branch = (& git -C $Repo branch --show-current).Trim()

function Save-Screen([string]$path, [hashtable]$clientRect) {
  $w = [int]$clientRect.width; $h = [int]$clientRect.height
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen([int]$clientRect.left, [int]$clientRect.top, 0, 0, [System.Drawing.Size]::new($w, $h))
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

function Get-WindowSnapshot([System.Diagnostics.Process]$Process, [object]$Ui) {
  $hwnd = [IntPtr]::Zero
  $deadline = (Get-Date).AddSeconds(30)
  while ($hwnd -eq [IntPtr]::Zero -and (Get-Date) -lt $deadline) {
    $hwnd = [AscendantWin32]::FindMainWindow([uint32]$Process.Id)
    if ($hwnd -eq [IntPtr]::Zero) { Start-Sleep -Milliseconds 100 }
  }
  if ($hwnd -eq [IntPtr]::Zero) { throw "Godot window not found for PID $($Process.Id)" }
  $outer = [AscendantWin32+RECT]::new(); $client = [AscendantWin32+RECT]::new()
  [AscendantWin32]::GetWindowRect($hwnd, [ref]$outer) | Out-Null
  [AscendantWin32]::GetClientRect($hwnd, [ref]$client) | Out-Null
  $origin = [AscendantWin32+POINT]::new(); $origin.X=0; $origin.Y=0
  if (-not [AscendantWin32]::ClientToScreen($hwnd, [ref]$origin)) { throw 'ClientToScreen failed' }
  $monitor = [AscendantWin32]::MonitorFromWindow($hwnd, [AscendantWin32]::MONITOR_DEFAULTTONEAREST)
  $mi = [AscendantWin32+MONITORINFO]::new(); $mi.cbSize=[Runtime.InteropServices.Marshal]::SizeOf($mi)
  [AscendantWin32]::GetMonitorInfo($monitor, [ref]$mi) | Out-Null
  $viewportW=[double]$Ui.ui.viewport_rect.w; $viewportH=[double]$Ui.ui.viewport_rect.h
  $clientW=$client.Right-$client.Left; $clientH=$client.Bottom-$client.Top
  $scaleX=$clientW/$viewportW; $scaleY=$clientH/$viewportH
  $buttonX=[double]$Ui.ui.button_rect.x + ([double]$Ui.ui.button_rect.w/2.0)
  $buttonY=[double]$Ui.ui.button_rect.y + ([double]$Ui.ui.button_rect.h/2.0)
  $clientPoint=[AscendantWin32+POINT]::new(); $clientPoint.X=[int][Math]::Round($buttonX*$scaleX); $clientPoint.Y=[int][Math]::Round($buttonY*$scaleY)
  $screenPoint=[AscendantWin32+POINT]::new(); $screenPoint.X=$origin.X+$clientPoint.X; $screenPoint.Y=$origin.Y+$clientPoint.Y
  $roundtrip=[AscendantWin32+POINT]::new(); $roundtrip.X=$screenPoint.X; $roundtrip.Y=$screenPoint.Y
  [AscendantWin32]::ScreenToClient($hwnd, [ref]$roundtrip) | Out-Null
  $hit=[AscendantWin32]::WindowFromPoint($screenPoint)
  $rootHit=[AscendantWin32]::GetAncestor($hit,[AscendantWin32]::GA_ROOT)
  $roundTripError=[Math]::Max([Math]::Abs($roundtrip.X-$clientPoint.X),[Math]::Abs($roundtrip.Y-$clientPoint.Y))
  $clientAbs=@{left=$origin.X;top=$origin.Y;right=$origin.X+$clientW;bottom=$origin.Y+$clientH;width=$clientW;height=$clientH}
  $result=[ordered]@{pid=$Process.Id;hwnd=('0x{0:X}' -f $hwnd.ToInt64());window_title=[AscendantWin32]::Title($hwnd);outer_rect=[AscendantWin32]::Rect($outer);client_rect=[AscendantWin32]::Rect($client);client_desktop_rect=$clientAbs;client_to_screen_origin=[AscendantWin32]::PointValue($origin);monitor_id=('0x{0:X}' -f $monitor.ToInt64());monitor_rect=[AscendantWin32]::Rect($mi.rcMonitor);monitor_work_rect=[AscendantWin32]::Rect($mi.rcWork);dpi=[AscendantWin32]::GetDpiForWindow($hwnd);viewport=$Ui.ui.viewport_rect;button_rect=$Ui.ui.button_rect;scale_x=$scaleX;scale_y=$scaleY;content_offset_x=0;content_offset_y=0;viewport_target=@{x=$buttonX;y=$buttonY};client_target=[AscendantWin32]::PointValue($clientPoint);screen_target=[AscendantWin32]::PointValue($screenPoint);round_trip_client=[AscendantWin32]::PointValue($roundtrip);round_trip_error_px=$roundTripError;window_from_point=('0x{0:X}' -f $hit.ToInt64());window_from_point_root=('0x{0:X}' -f $rootHit.ToInt64());window_from_point_matches=[AscendantWin32]::RootMatches($hit,$hwnd);hwnd_matches=[AscendantWin32]::RootMatches($hwnd,$hwnd)}
  return @{ hwnd=$hwnd; client=$clientAbs; mapper=$result }
}

foreach ($res in $Resolution) {
  if ($res -notmatch '^(1920x1080|1366x768)$') { throw "unsupported resolution $res" }
  $sessionRoot=Join-Path $root $res; if (Test-Path $sessionRoot) { Remove-Item -LiteralPath $sessionRoot -Recurse -Force }; New-Item -ItemType Directory -Path $sessionRoot -Force | Out-Null
  $psi=New-Object System.Diagnostics.ProcessStartInfo; $psi.FileName=$Godot; $psi.WorkingDirectory=$sessionRoot; $psi.UseShellExecute=$false; $psi.Arguments="--path `"$project`" --resolution $res --verbose"
  foreach($kv in (@{ASCENDANT_V0436_E3R_CAPTURE='1';ASCENDANT_V0436_R1H_CAPTURE='1';ASCENDANT_E3R_COMPLETION_DIAGNOSTIC='1';ASCENDANT_E3R_COMPLETION_RESOLUTION=$res;ASCENDANT_E3R_STEP8_OUT=($sessionRoot+'\\');ASCENDANT_V0436_R1H_SOURCE_SHA=$sourceSha;ASCENDANT_V0436_R1H_BRANCH=$branch;ASCENDANT_V0436_R1H_SESSION='A'}).GetEnumerator()) { $psi.Environment[$kv.Key]=[string]$kv.Value }
  $proc=[System.Diagnostics.Process]::Start($psi); $ready=Join-Path $sessionRoot 'e3r-completion-native-click-ready.json'; $deadline=(Get-Date).AddSeconds($ReadyTimeoutSeconds)
  while(-not (Test-Path $ready) -and -not $proc.HasExited -and (Get-Date) -lt $deadline){Start-Sleep -Milliseconds 250}
  if(-not (Test-Path $ready)){ if(-not $proc.HasExited){$proc.Kill()}; throw "completion ready not reached at $res" }
  $ui=Get-Content -LiteralPath $ready -Raw | ConvertFrom-Json; $snap=Get-WindowSnapshot $proc $ui
  [AscendantWin32]::Activate($snap.hwnd); Start-Sleep -Milliseconds 600
  $snap=Get-WindowSnapshot $proc $ui
  if([double]$snap.mapper.round_trip_error_px -gt 2 -or -not $snap.mapper.window_from_point_matches){ $snap.mapper.status='MAPPER_REFUSED_CLICK'; $snap.mapper | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $sessionRoot 'f0-mapper-refused.json') -Encoding UTF8; if(-not $proc.HasExited){$proc.Kill()}; throw "mapper refused click at $res" }
  $snap.mapper.status='MAPPER_VALIDATED'; $snap.mapper | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $sessionRoot 'f0-mapper.json') -Encoding UTF8
  Save-Screen (Join-Path $sessionRoot 'F0_01_COMPLETION.png') $snap.client
  [AscendantWin32]::SetCursorPos([int]$snap.mapper.screen_target.x,[int]$snap.mapper.screen_target.y) | Out-Null; Start-Sleep -Milliseconds 600
  Save-Screen (Join-Path $sessionRoot 'F0_02_NATIVE_HOVER.png') $snap.client
  [AscendantWin32]::Click([int]$snap.mapper.screen_target.x,[int]$snap.mapper.screen_target.y)
  Save-Screen (Join-Path $sessionRoot 'F0_03_NATIVE_CLICK.png') $snap.client
  $proc.WaitForExit(30000) | Out-Null
  $success=Join-Path $sessionRoot 'e3r-completion-success.json'; if(-not (Test-Path $success)){ throw "native completion success ledger missing at $res; exit=$($proc.ExitCode)" }
  Copy-Item (Join-Path $sessionRoot '16_RETURN_TO_MAIN_MENU.png') (Join-Path $sessionRoot ('04_MAIN_MENU_'+$res+'.png')) -Force
  $record=[ordered]@{resolution=$res;process_exit=$proc.ExitCode;mapper=(Get-Content (Join-Path $sessionRoot 'f0-mapper.json') -Raw | ConvertFrom-Json);success=(Get-Content $success -Raw | ConvertFrom-Json);ready=(Get-Content $ready -Raw | ConvertFrom-Json)}
  $record | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $sessionRoot 'f0-result.json') -Encoding UTF8
  $allRecords.Add($record)
  if ($res -eq '1920x1080') {
    $flatNames = @('01_TUTORIAL_COMPLETE.png','02_NATIVE_HOVER_1920.png','03_NATIVE_CLICK_1920.png','04_MAIN_MENU_1920.png')
  } else {
    $flatNames = @('05_TUTORIAL_COMPLETE_1366.png','06_NATIVE_HOVER_1366.png','07_NATIVE_CLICK_1366.png','08_MAIN_MENU_1366.png')
  }
  Copy-Item (Join-Path $sessionRoot 'F0_01_COMPLETION.png') (Join-Path $root $flatNames[0]) -Force
  Copy-Item (Join-Path $sessionRoot 'F0_02_NATIVE_HOVER.png') (Join-Path $root $flatNames[1]) -Force
  Copy-Item (Join-Path $sessionRoot 'F0_03_NATIVE_CLICK.png') (Join-Path $root $flatNames[2]) -Force
  Copy-Item (Join-Path $sessionRoot ('04_MAIN_MENU_'+$res+'.png')) (Join-Path $root $flatNames[3]) -Force
  Write-Output ("F0_PASS $res hwnd="+$record.mapper.hwnd+" screen="+$record.mapper.screen_target.x+','+$record.mapper.screen_target.y+" pressed="+$record.success.completion_pressed_count+" scene="+$record.success.scene_after)
}

$manifest=[ordered]@{schema='ascendant-realms-e3r-f0-native-tutorial-manifest-v1';status='PASS_NATIVE_COMPLETION_BOTH_RESOLUTIONS';source_sha=$sourceSha;branch=$branch;direct_signal_fallback_used=$false;resolutions=$allRecords;required_files=@('01_TUTORIAL_COMPLETE.png','02_NATIVE_HOVER_1920.png','03_NATIVE_CLICK_1920.png','04_MAIN_MENU_1920.png','05_TUTORIAL_COMPLETE_1366.png','06_NATIVE_HOVER_1366.png','07_NATIVE_CLICK_1366.png','08_MAIN_MENU_1366.png')}
$manifest | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $root 'f0-native-tutorial-manifest.json') -Encoding UTF8
