import { spawn } from "node:child_process";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { runBounded } from "./runBounded.mjs";

const root = process.env.CODEX_LIVENESS_FIXTURE_ROOT || "D:\\CodexData\\runtime\\liveness-fixture";
const leaseDir = path.join(root, "leases");
await mkdir(leaseDir, { recursive: true });
const node = process.execPath;
const fixture = "const end=Date.now()+Number(process.env.FIXTURE_MS||100); setInterval(()=>console.log('FIXTURE_PROGRESS'),25); setTimeout(()=>process.exit(0),end-Date.now());";
const progressing = await runBounded({ command: node, args: ["-e", fixture], cwd: process.cwd(), env: { FIXTURE_MS: "120" }, hardTimeoutMs: 2_000, noProgressTimeoutMs: 500, label: "fixture-progress", leaseDir });
const hanging = await runBounded({ command: node, args: ["-e", "setInterval(()=>{},1000)"], cwd: process.cwd(), hardTimeoutMs: 2_000, noProgressTimeoutMs: 350, heartbeatMs: 100, label: "fixture-hang", leaseDir });

const watchdogPid = spawn(node, ["-e", "setInterval(()=>{},1000)"], { cwd: process.cwd(), windowsHide: false, stdio: "ignore" });
const unrelatedPid = spawn(node, ["-e", "setInterval(()=>{},1000)"], { cwd: process.cwd(), windowsHide: false, stdio: "ignore" });
const leasePath = path.join(leaseDir, `fixture-watchdog-${watchdogPid.pid}.json`);
await writeFile(leasePath, JSON.stringify({ schema: "ascendant-realms-bounded-process-lease-v1", label: "fixture-watchdog", command: node, cwd: process.cwd(), pid: watchdogPid.pid, parent_pid: process.pid, executable: node, started_at: new Date().toISOString(), hard_deadline: new Date(Date.now() - 1_000).toISOString(), progress_deadline: null, last_progress_at: new Date(Date.now() - 1_000).toISOString(), kill_allowed: true, status: "RUNNING" }, null, 2));
const watchdog = await runBounded({ command: "powershell.exe", args: ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", path.join(path.dirname(fileURLToPath(import.meta.url)), "studio_watchdog.ps1"), "-Once", "-LeaseDir", leaseDir], cwd: process.cwd(), hardTimeoutMs: 5_000, label: "fixture-watchdog-controller", leaseDir });
let watchdogResult = null;
try { watchdogResult = JSON.parse((await readFile(path.join(leaseDir, `fixture-watchdog-${watchdogPid.pid}.watchdog.json`), "utf8")).replace(/^\uFEFF/u, "")); } catch {}
const unrelatedUntouched = Boolean(GetProcessById(unrelatedPid.pid));
function GetProcessById(pid) {
  try { process.kill(pid, 0); return true; } catch { return false; }
}
const result = { schema: "ascendant-realms-liveness-fixture-v1", progressing, hanging, watchdog, watchdog_result: watchdogResult, pass: progressing.classification === "COMPLETED" && hanging.classification === "NO_PROGRESS_TIMEOUT" && watchdogResult?.status === "WATCHDOG_TERMINATED_STALLED_OWNED_PROCESS" && watchdogResult?.termination_succeeded === true };
try { watchdogPid.kill(); } catch {}
try { unrelatedPid.kill(); } catch {}
result.unrelated_process_untouched = unrelatedUntouched;
result.pass = result.pass && unrelatedUntouched;
if (result.pass) await rm(root, { recursive: true, force: true });
else result.debug_root = root;
console.log(JSON.stringify(result, null, 2));
process.exitCode = result.pass ? 0 : 1;
