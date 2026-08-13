import { spawn } from "node:child_process";
import { mkdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const TAIL_LIMIT = 12_000;
const DEFAULT_LEASE_DIR = process.env.ASCENDANT_CODEX_LEASE_DIR || "D:\\CodexData\\runtime\\leases";

const now = () => new Date();
const iso = (date) => date.toISOString();
const tail = (value, limit = TAIL_LIMIT) => value.length <= limit ? value : value.slice(-limit);
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const safeName = (value) => String(value || "bounded-command").replace(/[^a-zA-Z0-9_.-]+/gu, "-");

async function writeJson(file, value) {
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file, JSON.stringify(value, null, 2) + "\n", "utf8");
}

async function fileProgress(sources) {
  const result = [];
  for (const source of sources || []) {
    try {
      const info = await stat(source);
      result.push({ path: source, size: info.size, mtime_ms: info.mtimeMs });
    } catch {
      result.push({ path: source, missing: true });
    }
  }
  return result;
}

async function terminateProcessTree(child, record) {
  if (!child?.pid) return { attempted: false, succeeded: false, remaining: true };
  record.termination_attempted = true;
  try { child.kill("SIGTERM"); } catch { /* the tree kill below is authoritative on Windows */ }
  if (process.platform === "win32") {
    await new Promise((resolve) => {
      const killer = spawn("taskkill.exe", ["/PID", String(child.pid), "/T", "/F"], { windowsHide: true, stdio: "ignore" });
      const timer = setTimeout(() => { try { killer.kill(); } catch {} resolve(); }, 5000);
      killer.once("close", () => { clearTimeout(timer); resolve(); });
      killer.once("error", () => { clearTimeout(timer); resolve(); });
    });
  }
  const deadline = Date.now() + 1500;
  while (Date.now() < deadline) {
    if (child.exitCode !== null || child.signalCode) return { attempted: true, succeeded: true, remaining: false };
    await sleep(100);
  }
  return { attempted: true, succeeded: child.exitCode !== null || Boolean(child.signalCode), remaining: child.exitCode === null && !child.signalCode };
}

export async function runBounded({
  command,
  args = [],
  cwd,
  env = {},
  hardTimeoutMs = 300_000,
  noProgressTimeoutMs = 0,
  progressSources = [],
  label = command,
  leaseDir = DEFAULT_LEASE_DIR,
  killTree = true,
  heartbeatMs = 1_000,
} = {}) {
  if (!command) throw new Error("runBounded requires command");
  const started = now();
  const child = spawn(command, args, { cwd, env: { ...process.env, ...env }, windowsHide: false, stdio: ["ignore", "pipe", "pipe"] });
  const record = {
    schema: "ascendant-realms-bounded-process-lease-v1",
    label, command, args, cwd, pid: child.pid, executable: command,
    parent_pid: process.pid, started_at: iso(started), hard_deadline: iso(new Date(started.getTime() + hardTimeoutMs)),
    progress_deadline: noProgressTimeoutMs > 0 ? iso(new Date(started.getTime() + noProgressTimeoutMs)) : null,
    last_progress_at: iso(started), kill_allowed: killTree,
    log_or_evidence_paths: progressSources, status: "RUNNING",
  };
  const leaseFile = path.join(leaseDir, `${safeName(label)}-${child.pid}.json`);
  await writeJson(leaseFile, record);
  let stdout = ""; let stderr = ""; let lastProgressAt = Date.now(); let lastProgressSignature = "";
  const progressEvents = [];
  const onOutput = (stream, data) => {
    const value = data.toString();
    if (stream === "stdout") stdout = tail(stdout + value); else stderr = tail(stderr + value);
    lastProgressAt = Date.now();
    progressEvents.push({ at: iso(now()), source: stream, bytes: Buffer.byteLength(value) });
  };
  child.stdout.on("data", (data) => onOutput("stdout", data));
  child.stderr.on("data", (data) => onOutput("stderr", data));
  let timer; let monitor; let settled = false; let timedOut = false; let noProgressTimeout = false; let termination = { attempted: false, succeeded: false, remaining: false }; let terminationPromise = null;
  const result = await new Promise((resolve, reject) => {
    const finish = async (classification, code = child.exitCode, signal = child.signalCode) => {
      if (settled) return; settled = true; clearTimeout(timer); clearInterval(monitor); if (terminationPromise) termination = await terminationPromise;
      const ended = now();
      const output = { started_at: iso(started), ended_at: iso(ended), elapsed_ms: ended - started, pid: child.pid, exit_code: code, signal, timed_out: timedOut, no_progress_timeout: noProgressTimeout, stdout_tail: stdout, stderr_tail: stderr, progress_events: progressEvents, termination_attempted: termination.attempted, termination_succeeded: termination.succeeded, process_tree_remaining: termination.remaining, classification };
      await writeJson(leaseFile, { ...record, ...output, status: "DONE" });
      await rm(leaseFile, { force: true });
      resolve(output);
    };
    child.once("error", (error) => { stderr = tail(`${stderr}${error.stack || error.message}`); finish("SPAWN_ERROR", null, null); });
    child.once("close", (code, signal) => finish(timedOut ? (noProgressTimeout ? "NO_PROGRESS_TIMEOUT" : "HARD_TIMEOUT") : (code === 0 ? "COMPLETED" : "EXIT_NONZERO"), code, signal));
    timer = setTimeout(() => { timedOut = true; if (killTree) terminationPromise = terminateProcessTree(child, record); }, hardTimeoutMs);
    monitor = setInterval(async () => {
      const files = await fileProgress(progressSources);
      const signature = JSON.stringify(files);
      if (signature !== lastProgressSignature) { lastProgressSignature = signature; lastProgressAt = Date.now(); progressEvents.push({ at: iso(now()), source: "progress_file", files }); }
      if (noProgressTimeoutMs > 0 && Date.now() - lastProgressAt >= noProgressTimeoutMs && !timedOut) { timedOut = true; noProgressTimeout = true; if (killTree) terminationPromise = terminateProcessTree(child, record); }
      await writeJson(leaseFile, { ...record, last_progress_at: iso(new Date(lastProgressAt)), progress_events: progressEvents.slice(-40), status: timedOut ? "TERMINATING" : "RUNNING" });
    }, Math.max(250, heartbeatMs));
  });
  return result;
}

if (process.argv[1] && path.resolve(fileURLToPath(import.meta.url)) === path.resolve(process.argv[1])) {
  const result = await runBounded({ command: process.argv[2], args: process.argv.slice(3), hardTimeoutMs: Number(process.env.CODEX_HARD_TIMEOUT_MS || 5_000), noProgressTimeoutMs: Number(process.env.CODEX_NO_PROGRESS_TIMEOUT_MS || 0), label: process.env.CODEX_LABEL || "cli-bounded-command" });
  console.log(JSON.stringify(result, null, 2));
  process.exitCode = result.classification === "COMPLETED" ? 0 : 1;
}
