import { chromium, type Browser, type BrowserContext, type Page } from "@playwright/test";
import { execFileSync, spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import os from "node:os";
import { join, resolve } from "node:path";
import process from "node:process";
import {
  V0111_ARTIFACT_DIR,
  V0111_BROWSER_CONTROL_BASELINES,
  V0111_CHECKPOINT,
  V0111_HOST_SNAPSHOT_ROOT,
  V0111_TITLE,
  classifyEnvironment,
  createCleanProfilePosture,
  renderArtifactReadme,
  renderBrowserControlBaselinesMarkdown,
  renderCleanProfileBenchmarkMarkdown,
  renderCleanProfileBenchmarkSpecMarkdown,
  renderHostSnapshotMarkdown,
  renderHostSnapshotSpecMarkdown,
  renderImplementationReportMarkdown,
  renderMachinePressureClassificationMarkdown,
  renderPostRestartRetestMarkdown,
  type BrowserControlBaselineId,
  type BrowserControlBaselineResult,
  type BrowserControlDefinition,
  type BrowserControlRunMode,
  type HostSnapshot
} from "../src/game/playtest/HostEnvironmentCalibration";
import {
  TRUSTED_DEFAULT_SAMPLE_MS,
  TRUSTED_DEFAULT_WARMUP_MS,
  summarizeTrustedFrameIntervals,
  type TrustedFrameInterval
} from "../src/game/playtest/TrustedBrowserBenchmark";
import {
  defaultPerformanceCounters,
  type PrivatePerformanceCounters,
  type PrivatePerformanceLongTask
} from "../src/game/playtest/PrivatePerformanceProfiler";

type ServerMode = "preview" | "dev";

interface BrowserSample {
  intervals: TrustedFrameInterval[];
  longTasks: PrivatePerformanceLongTask[];
  longTaskSupported: boolean;
  memoryUsedMb?: number;
}

interface BrowserSession {
  page: Page;
  browser?: Browser;
  context?: BrowserContext;
  browserVersion: string;
  tempProfileDir?: string;
}

const SAVE_KEY = "ascendant-realms-save-v1";
const OUTPUT_DIR = resolve(V0111_ARTIFACT_DIR);
const RAW_INTERVAL_DIR = resolve(OUTPUT_DIR, "raw-frame-intervals");
const DEFAULT_PREVIEW_PORT = 5220;
const DEFAULT_DEV_PORT = 5221;
const VIEWPORT = "1600x900";
const HARDWARE_ACCELERATION_POSTURE = "swiftshader-compatibility-flags";
const CHROMIUM_ARGS = ["--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"];
const CLEAN_PROFILE_ARGS = [...CHROMIUM_ARGS, "--disable-extensions", "--disable-component-extensions-with-background-pages"];

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  await mkdir(OUTPUT_DIR, { recursive: true });
  await mkdir(RAW_INTERVAL_DIR, { recursive: true });

  if (args.includes("--host-snapshot")) {
    const snapshot = await captureAndWriteHostSnapshot({
      headed: false,
      serverMode: "none",
      cleanProfile: false,
      extensionsDisabled: false
    });
    console.log(`v0.111 host snapshot captured: ${snapshot.artifactPath}`);
    return;
  }

  if (args.includes("--report-only")) {
    const results = await readAllResults();
    await writeStaticArtifacts(results);
    console.log(`v0.111 environment calibration report refreshed for ${results.length} row(s).`);
    return;
  }

  if (args.includes("--clean-profile")) {
    const results = await runControls({
      cleanProfile: true,
      headed: args.includes("--headed"),
      serverMode: parseServerMode(args),
      port: Number(argValue(args, "--port") ?? process.env.ASCENDANT_V0111_CLEAN_PROFILE_PORT ?? DEFAULT_PREVIEW_PORT + 2),
      controls: ["blank-page-raf", "phaser-empty-scene", "campaign-map", "tier-m-representative-battle"]
    });
    await writeCleanProfileArtifacts(results);
    console.log(`v0.111 clean-profile benchmark artifacts: ${V0111_ARTIFACT_DIR}`);
    return;
  }

  const results = await runControls({
    cleanProfile: false,
    headed: args.includes("--headed"),
    serverMode: parseServerMode(args),
    port: Number(argValue(args, "--port") ?? process.env.ASCENDANT_V0111_CONTROLS_PORT ?? defaultPort(parseServerMode(args))),
    controls: V0111_BROWSER_CONTROL_BASELINES.map((entry) => entry.id)
  });
  await writeControlArtifacts(results);
  console.log(`v0.111 browser control artifacts: ${V0111_ARTIFACT_DIR}`);
}

async function runControls(options: {
  cleanProfile: boolean;
  headed: boolean;
  serverMode: ServerMode;
  port: number;
  controls: BrowserControlBaselineId[];
}): Promise<BrowserControlBaselineResult[]> {
  const baseUrl = `http://127.0.0.1:${options.port}`;
  const runMode = runModeFor(options.cleanProfile, options.headed);
  const hostSnapshot = await captureAndWriteHostSnapshot({
    headed: options.headed,
    serverMode: options.serverMode,
    cleanProfile: options.cleanProfile,
    extensionsDisabled: options.cleanProfile
  });
  const server = await startServer(options.serverMode, options.port);
  let session: BrowserSession | undefined;
  try {
    await waitForServer(baseUrl);
    session = await createBrowserSession({ cleanProfile: options.cleanProfile, headed: options.headed });
    await session.page.addInitScript(() => {
      Reflect.set(window, "__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__", true);
    });
    session.page.setDefaultTimeout(60_000);
    session.page.setDefaultNavigationTimeout(120_000);

    const results: BrowserControlBaselineResult[] = [];
    for (const controlId of options.controls) {
      const definition = V0111_BROWSER_CONTROL_BASELINES.find((entry) => entry.id === controlId);
      if (!definition) {
        throw new Error(`Unknown v0.111 control baseline ${controlId}.`);
      }
      results.push(await runControlCase(session.page, baseUrl, definition, runMode, session.browserVersion, hostSnapshot.artifactPath));
      console.log(`v0.111 control complete: ${runMode} ${definition.id}`);
    }
    return results;
  } finally {
    await session?.context?.close();
    await session?.browser?.close();
    if (session?.tempProfileDir) {
      await removeTemporaryProfile(session.tempProfileDir);
    }
    server.kill();
  }
}

async function runControlCase(
  page: Page,
  baseUrl: string,
  definition: BrowserControlDefinition,
  runMode: BrowserControlRunMode,
  browserVersion: string,
  hostSnapshotArtifact: string
): Promise<BrowserControlBaselineResult> {
  await page.setViewportSize(viewportSize(VIEWPORT));
  const generatedAtUtc = new Date().toISOString();
  const saveBefore = definition.usesGameRuntime ? await readSaveSnapshotAtOrigin(page, baseUrl) : null;

  const launchTarget = definition.launchTarget;
  if (launchTarget.type === "blank-page") {
    await setupBlankPage(page);
  } else if (launchTarget.type === "simple-dom") {
    await setupSimpleDomPage(page);
  } else if (launchTarget.type === "simple-canvas") {
    await setupSimpleCanvasPage(page);
  } else if (launchTarget.type === "phaser-empty-scene") {
    await setupPhaserEmptyScene(page, baseUrl);
  } else {
    await launchPrivateScenario(page, baseUrl, launchTarget.scenarioId, launchTarget.sceneKind);
  }

  await page.waitForLoadState("networkidle", { timeout: 5_000 }).catch(() => undefined);
  await page.waitForTimeout(TRUSTED_DEFAULT_WARMUP_MS);
  const countersBefore = await getCounters(page, definition);
  const sample = await collectFrameIntervals(page, TRUSTED_DEFAULT_SAMPLE_MS);
  const countersAfter = await getCounters(page, definition, sample.memoryUsedMb);
  const steadyState = summarizeTrustedFrameIntervals({
    intervals: sample.intervals,
    sampleDurationMs: TRUSTED_DEFAULT_SAMPLE_MS,
    countersBefore,
    countersAfter,
    longTasks: sample.longTasks,
    longTaskSupported: sample.longTaskSupported
  });
  const rawFrameIntervalArtifact = await writeRawIntervals(definition, runMode, sample.intervals);
  const saveAfter = definition.usesGameRuntime ? await readSaveSnapshotAtOrigin(page, baseUrl) : null;
  const visibilityState = await page.evaluate(() => document.visibilityState).catch(() => "unknown" as const);
  const userAgent = await page.evaluate(() => navigator.userAgent).catch(() => "unknown");
  const domNodes = await page.evaluate(() => document.querySelectorAll("*").length).catch(() => 0);

  return {
    id: definition.id,
    title: definition.title,
    category: definition.category,
    runMode,
    generatedAtUtc,
    warmupMs: TRUSTED_DEFAULT_WARMUP_MS,
    sampleMs: TRUSTED_DEFAULT_SAMPLE_MS,
    viewport: VIEWPORT,
    browserVersion,
    userAgent,
    visibilityState,
    cleanProfile: runMode.startsWith("clean-profile"),
    extensionsDisabled: runMode.startsWith("clean-profile"),
    hardwareAccelerationPosture: HARDWARE_ACCELERATION_POSTURE,
    domNodes,
    hostSnapshotArtifact,
    rawFrameIntervalArtifact,
    steadyState,
    saveBefore,
    saveAfter,
    saveMutationDetected: saveBefore !== saveAfter
  };
}

async function captureAndWriteHostSnapshot(options: {
  headed: boolean;
  serverMode: "none" | ServerMode;
  cleanProfile: boolean;
  extensionsDisabled: boolean;
}): Promise<{ snapshot: HostSnapshot; artifactPath: string }> {
  let browser: Browser | undefined;
  let page: Page | undefined;
  try {
    browser = await chromium.launch({ headless: !options.headed, args: CHROMIUM_ARGS });
    page = await browser.newPage({ viewport: viewportSize(VIEWPORT) });
    await page.goto("about:blank");
    const snapshot = await buildHostSnapshot(page, browser.version(), options);
    const timestamp = snapshot.generatedAtUtc.replace(/[:.]/gu, "-");
    const dir = resolve(V0111_HOST_SNAPSHOT_ROOT, timestamp);
    await mkdir(dir, { recursive: true });
    await writeFile(join(dir, "host-snapshot.json"), `${JSON.stringify(snapshot, null, 2)}\n`, "utf8");
    await writeFile(join(dir, "host-snapshot.md"), renderHostSnapshotMarkdown(snapshot), "utf8");
    await writeFile(join(dir, "README.md"), renderHostSnapshotSpecMarkdown(), "utf8");
    return { snapshot, artifactPath: displayPath(join(dir, "host-snapshot.json")) };
  } finally {
    await page?.close().catch(() => undefined);
    await browser?.close().catch(() => undefined);
  }
}

async function buildHostSnapshot(
  page: Page,
  browserVersion: string,
  options: {
    headed: boolean;
    serverMode: "none" | ServerMode;
    cleanProfile: boolean;
    extensionsDisabled: boolean;
  }
): Promise<HostSnapshot> {
  const cpus = os.cpus();
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const memory = process.memoryUsage();
  const capabilities = await page.evaluate(() => {
    const supported = PerformanceObserver.supportedEntryTypes || [];
    const perf = performance as Performance & { memory?: unknown };
    return {
      requestAnimationFrame: typeof requestAnimationFrame === "function",
      longTaskObserver: supported.includes("longtask"),
      performanceMemory: Boolean(perf.memory)
    };
  });
  return {
    schemaVersion: 1,
    checkpoint: V0111_CHECKPOINT,
    title: V0111_TITLE,
    generatedAtUtc: new Date().toISOString(),
    platform: {
      platform: os.platform(),
      osRelease: os.release(),
      architecture: os.arch(),
      uptimeSeconds: Math.round(os.uptime())
    },
    cpu: {
      model: cpus[0]?.model ?? "unknown",
      logicalCores: cpus.length
    },
    memory: {
      totalMb: bytesToMb(totalMem),
      freeMb: bytesToMb(freeMem),
      usedPercent: roundMetric(((totalMem - freeMem) / Math.max(1, totalMem)) * 100)
    },
    nodeProcess: {
      nodeVersion: process.version,
      rssMb: bytesToMb(memory.rss),
      heapUsedMb: bytesToMb(memory.heapUsed)
    },
    loadAverage: os.platform() === "win32" ? "unsupported" : os.loadavg().map(roundMetric),
    git: {
      commit: gitOutput(["rev-parse", "HEAD"]),
      shortCommit: gitOutput(["rev-parse", "--short=7", "HEAD"]),
      workingTreeClean: gitOutput(["status", "--short"]).length === 0
    },
    browser: {
      browserName: "chromium",
      browserVersion,
      userAgent: await page.evaluate(() => navigator.userAgent).catch(() => "unknown"),
      viewport: VIEWPORT,
      headed: options.headed,
      headless: !options.headed,
      serverMode: options.serverMode,
      visibilityState: await page.evaluate(() => document.visibilityState).catch(() => "unknown" as const),
      cleanProfileMode: options.cleanProfile ? "temporary" : "none",
      extensionsDisabled: options.extensionsDisabled,
      hardwareAccelerationPosture: HARDWARE_ACCELERATION_POSTURE,
      recordingStatus: "unknown"
    },
    profilerCapabilities: capabilities,
    privacy: {
      browserHistoryCollected: false,
      openTabsCollected: false,
      profileContentsCollected: false,
      processCommandLinesCollected: false,
      personalFileNamesCollected: false
    }
  };
}

async function createBrowserSession(options: { cleanProfile: boolean; headed: boolean }): Promise<BrowserSession> {
  if (options.cleanProfile) {
    const tempProfileDir = await mkdtemp(join(tmpdir(), "ascendant-realms-v0111-clean-profile-"));
    const context = await chromium.launchPersistentContext(tempProfileDir, {
      headless: !options.headed,
      viewport: viewportSize(VIEWPORT),
      args: CLEAN_PROFILE_ARGS
    });
    const page = context.pages()[0] ?? (await context.newPage());
    return {
      page,
      context,
      browserVersion: context.browser()?.version() ?? "chromium-unknown",
      tempProfileDir
    };
  }

  const browser = await chromium.launch({ headless: !options.headed, args: CHROMIUM_ARGS });
  const page = await browser.newPage({ viewport: viewportSize(VIEWPORT) });
  return { page, browser, browserVersion: browser.version() };
}

async function setupBlankPage(page: Page): Promise<void> {
  await page.goto("about:blank");
  await page.setContent("<!doctype html><title>v0.111 blank control</title><body></body>");
}

async function setupSimpleDomPage(page: Page): Promise<void> {
  await page.goto("about:blank");
  await page.setContent(`<!doctype html>
    <title>v0.111 simple DOM control</title>
    <style>
      body { margin: 0; font-family: sans-serif; }
      .row { padding: 2px 4px; border-bottom: 1px solid #ddd; }
    </style>
    <main>${Array.from({ length: 120 }, (_, index) => `<div class="row">DOM baseline row ${index + 1}</div>`).join("")}</main>
    <script>window.__ASCENDANT_CONTROL_FRAME_HOOK__ = () => { document.body.dataset.tick = String((Number(document.body.dataset.tick || 0) + 1) % 1000); };</script>`);
}

async function setupSimpleCanvasPage(page: Page): Promise<void> {
  await page.goto("about:blank");
  await page.setContent(`<!doctype html>
    <title>v0.111 simple canvas control</title>
    <canvas id="control-canvas" width="960" height="540"></canvas>
    <script>
      const canvas = document.getElementById("control-canvas");
      const ctx = canvas.getContext("2d");
      let tick = 0;
      window.__ASCENDANT_CONTROL_FRAME_HOOK__ = () => {
        tick += 1;
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = "#1f2937";
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = "#38bdf8";
        for (let i = 0; i < 40; i += 1) {
          ctx.fillRect((i * 23 + tick) % canvas.width, (i * 17) % canvas.height, 12, 12);
        }
      };
    </script>`);
}

async function setupPhaserEmptyScene(page: Page, baseUrl: string): Promise<void> {
  await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  const vendorPath = await findPhaserVendorAsset();
  const vendorUrl = `${baseUrl}/${vendorPath}`;
  await page.setContent(`<!doctype html>
    <title>v0.111 Phaser empty-scene control</title>
    <div id="phaser-root"></div>
    <script type="module">
      import { P as Phaser } from ${JSON.stringify(vendorUrl)};
      window.__ASCENDANT_PHASER_EMPTY_READY__ = false;
      class EmptyScene extends Phaser.Scene {
        create() {
          window.__ASCENDANT_PHASER_EMPTY_READY__ = true;
        }
      }
      window.__ASCENDANT_EMPTY_PHASER_GAME__ = new Phaser.Game({
        type: Phaser.CANVAS,
        width: 960,
        height: 540,
        parent: "phaser-root",
        backgroundColor: "#111827",
        banner: false,
        audio: { noAudio: true },
        scene: EmptyScene
      });
    </script>`);
  await page.waitForFunction(() => Boolean((window as any).__ASCENDANT_PHASER_EMPTY_READY__), null, { timeout: 30_000 });
}

async function launchPrivateScenario(page: Page, baseUrl: string, scenarioId: string, kind: "campaign" | "battle"): Promise<void> {
  await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  await page.getByTestId("main-menu").waitFor({ timeout: 45_000 });
  await page.getByTestId("menu-playtest-hub").click();
  await page.getByTestId("playtest-hub").waitFor({ timeout: 30_000 });
  await page.getByTestId(`playtest-scenario-${scenarioId}`).scrollIntoViewIfNeeded();
  await page.getByTestId(`playtest-scenario-${scenarioId}`).click();
  if (kind === "campaign") {
    await page.getByTestId("campaign-map").waitFor({ timeout: 90_000 });
    return;
  }
  await expectBattleLoaded(page);
}

async function expectBattleLoaded(page: Page): Promise<void> {
  await page.getByTestId("battle-hud").waitFor({ timeout: 90_000 });
  await page.getByTestId("battle-minimap").waitFor({ timeout: 90_000 });
  await page.waitForFunction(
    () => {
      const scene = (window as any).ascendantRealmsGame?.scene.getScene("BattleScene");
      return Boolean(scene?.scene?.isActive?.() && scene.hero && scene.activeMap && scene.runtime && scene.game?.canvas);
    },
    null,
    { timeout: 90_000 }
  );
}

async function collectFrameIntervals(page: Page, sampleMs: number): Promise<BrowserSample> {
  return page.evaluate(`(async () => {
    const durationMs = ${JSON.stringify(sampleMs)};
    const intervals = [];
    const longTasks = [];
    const supportedEntryTypes = PerformanceObserver.supportedEntryTypes || [];
    const longTaskSupported = supportedEntryTypes.includes("longtask");
    let observer;
    if (longTaskSupported) {
      observer = new PerformanceObserver((list) => {
        list.getEntries().forEach((entry) => {
          longTasks.push({
            atMs: Number(entry.startTime.toFixed(2)),
            durationMs: Number(entry.duration.toFixed(2))
          });
        });
      });
      observer.observe({ type: "longtask", buffered: true });
    }

    const sampleStartedAt = performance.now();
    let previousFrame;
    await new Promise((resolveSample) => {
      const tick = (now) => {
        if (typeof window.__ASCENDANT_CONTROL_FRAME_HOOK__ === "function") {
          window.__ASCENDANT_CONTROL_FRAME_HOOK__();
        }
        if (previousFrame !== undefined) {
          intervals.push({
            index: intervals.length,
            atMs: Number((now - sampleStartedAt).toFixed(2)),
            frameMs: Number((now - previousFrame).toFixed(2))
          });
        }
        previousFrame = now;
        if (now - sampleStartedAt < durationMs) {
          requestAnimationFrame(tick);
        } else {
          resolveSample();
        }
      };
      requestAnimationFrame(tick);
    });
    if (observer) {
      observer.disconnect();
    }
    const memory = performance.memory;
    return {
      intervals,
      longTasks,
      longTaskSupported,
      memoryUsedMb: memory && memory.usedJSHeapSize !== undefined ? Number((memory.usedJSHeapSize / 1024 / 1024).toFixed(2)) : undefined
    };
  })()`) as Promise<BrowserSample>;
}

async function getCounters(
  page: Page,
  definition: BrowserControlDefinition,
  memoryUsedMb?: number
): Promise<PrivatePerformanceCounters> {
  if (definition.category === "battle") {
    const counters = await page.evaluate(() => (window as any).__ASCENDANT_TEST_HOOKS__?.getPrivatePerformanceCounters?.());
    if (counters) {
      return { ...defaultPerformanceCounters(), ...counters, memoryUsedMb };
    }
  }
  const domCounters = await page.evaluate(() => ({
    domNodes: document.querySelectorAll("*").length,
    memoryUsedMb: (performance as Performance & { memory?: { usedJSHeapSize?: number } }).memory?.usedJSHeapSize
      ? Number((((performance as Performance & { memory?: { usedJSHeapSize?: number } }).memory?.usedJSHeapSize ?? 0) / 1024 / 1024).toFixed(2))
      : undefined
  }));
  return { ...defaultPerformanceCounters(), ...domCounters, memoryUsedMb: memoryUsedMb ?? domCounters.memoryUsedMb };
}

async function writeRawIntervals(
  definition: BrowserControlDefinition,
  runMode: BrowserControlRunMode,
  intervals: TrustedFrameInterval[]
): Promise<string> {
  const path = resolve(RAW_INTERVAL_DIR, `${runMode}-${definition.id}.json`);
  await writeFile(path, `${JSON.stringify({ controlId: definition.id, runMode, intervals }, null, 2)}\n`, "utf8");
  return displayPath(path);
}

async function writeControlArtifacts(nextResults: BrowserControlBaselineResult[]): Promise<void> {
  const existing = (await readControlResults()).filter((result) => !nextResults.some((next) => keyFor(next) === keyFor(result)));
  const results = [...existing, ...nextResults];
  await writeFile(resolve(OUTPUT_DIR, "browser-control-baselines.json"), `${JSON.stringify({ results }, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "browser-control-baselines.md"), renderBrowserControlBaselinesMarkdown(results), "utf8");
  await writeStaticArtifacts(await readAllResults(results));
}

async function writeCleanProfileArtifacts(nextResults: BrowserControlBaselineResult[]): Promise<void> {
  const posture = createCleanProfilePosture("deleted");
  await writeFile(
    resolve(OUTPUT_DIR, "clean-profile-benchmark.json"),
    `${JSON.stringify({ posture, results: nextResults }, null, 2)}\n`,
    "utf8"
  );
  await writeFile(resolve(OUTPUT_DIR, "clean-profile-benchmark.md"), renderCleanProfileBenchmarkMarkdown(nextResults), "utf8");
  await writeStaticArtifacts(await readAllResults(undefined, nextResults));
}

async function writeStaticArtifacts(results: BrowserControlBaselineResult[]): Promise<void> {
  const report = classifyEnvironment(results);
  await writeFile(resolve(OUTPUT_DIR, "environment-comparison.json"), `${JSON.stringify(report, null, 2)}\n`, "utf8");
  await writeFile(resolve(OUTPUT_DIR, "environment-comparison.md"), renderMachinePressureClassificationMarkdown(report), "utf8");
  await writeFile(resolve(OUTPUT_DIR, "README.md"), renderArtifactReadme(results.length), "utf8");

  await writeFile(resolve("docs", "V0111_HOST_SNAPSHOT_SPEC.md"), renderHostSnapshotSpecMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0111_BROWSER_CONTROL_BASELINES.md"), renderBrowserControlBaselinesMarkdown(results), "utf8");
  await writeFile(resolve("docs", "V0111_CLEAN_PROFILE_BENCHMARK_SPEC.md"), renderCleanProfileBenchmarkSpecMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0111_MACHINE_PRESSURE_CLASSIFICATION.md"), renderMachinePressureClassificationMarkdown(report), "utf8");
  await writeFile(resolve("docs", "V0111_EMMANUEL_POST_RESTART_RETEST.md"), renderPostRestartRetestMarkdown(), "utf8");
  await writeFile(resolve("docs", "V0111_IMPLEMENTATION_REPORT.md"), renderImplementationReportMarkdown(results), "utf8");
}

async function readAllResults(
  controlsOverride?: BrowserControlBaselineResult[],
  cleanOverride?: BrowserControlBaselineResult[]
): Promise<BrowserControlBaselineResult[]> {
  const controls = controlsOverride ?? (await readControlResults());
  const clean = cleanOverride ?? (await readCleanProfileResults());
  const byKey = new Map<string, BrowserControlBaselineResult>();
  [...controls, ...clean].forEach((result) => byKey.set(keyFor(result), result));
  return [...byKey.values()];
}

async function readControlResults(): Promise<BrowserControlBaselineResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "browser-control-baselines.json"), "utf8")) as {
      results?: BrowserControlBaselineResult[];
    };
    return Array.isArray(parsed.results) ? parsed.results : [];
  } catch {
    return [];
  }
}

async function readCleanProfileResults(): Promise<BrowserControlBaselineResult[]> {
  try {
    const parsed = JSON.parse(await readFile(resolve(OUTPUT_DIR, "clean-profile-benchmark.json"), "utf8")) as {
      results?: BrowserControlBaselineResult[];
    };
    return Array.isArray(parsed.results) ? parsed.results : [];
  } catch {
    return [];
  }
}

async function readSaveSnapshotAtOrigin(page: Page, baseUrl: string): Promise<string | null> {
  if (!page.url().startsWith(baseUrl)) {
    await page.goto(baseUrl, { waitUntil: "domcontentloaded", timeout: 120_000 });
  }
  return page.evaluate((key) => localStorage.getItem(key), SAVE_KEY);
}

async function findPhaserVendorAsset(): Promise<string> {
  const html = await readFile(resolve("dist", "index.html"), "utf8");
  const match = html.match(/href="(?:\.\/|\/)?(assets\/vendor-phaser-[^"]+\.js)"/u);
  if (!match) {
    throw new Error("Could not find production vendor-phaser asset. Run npm run build before v0.111 controls.");
  }
  return match[1];
}

async function startServer(serverMode: ServerMode, port: number): Promise<ChildProcessWithoutNullStreams> {
  const viteArgs =
    serverMode === "dev"
      ? ["node_modules/vite/bin/vite.js", "--host", "127.0.0.1", "--port", String(port), "--strictPort"]
      : ["node_modules/vite/bin/vite.js", "preview", "--host", "127.0.0.1", "--port", String(port), "--strictPort"];
  const child = spawn(process.execPath, viteArgs, {
    cwd: process.cwd(),
    env: { ...process.env, ASCENDANT_TRUSTED_BROWSER_BENCHMARK: "1" },
    stdio: "pipe"
  });
  child.stdout.on("data", (chunk) => process.stdout.write(`[v0111-${serverMode}] ${chunk}`));
  child.stderr.on("data", (chunk) => process.stderr.write(`[v0111-${serverMode}] ${chunk}`));
  return child;
}

async function waitForServer(baseUrl: string): Promise<void> {
  const startedAt = Date.now();
  while (Date.now() - startedAt < 120_000) {
    try {
      const response = await fetch(baseUrl);
      if (response.ok) {
        return;
      }
    } catch {
      // Retry while Vite boots.
    }
    await new Promise((resolveRetry) => setTimeout(resolveRetry, 500));
  }
  throw new Error(`Timed out waiting for ${baseUrl}.`);
}

async function removeTemporaryProfile(tempProfileDir: string): Promise<void> {
  const normalized = resolve(tempProfileDir);
  if (!normalized.includes("ascendant-realms-v0111-clean-profile-")) {
    throw new Error(`Refusing to remove unexpected temporary profile directory: ${normalized}`);
  }
  await rm(normalized, { recursive: true, force: true });
}

function parseServerMode(args: string[]): ServerMode {
  const mode = argValue(args, "--mode") ?? "preview";
  if (mode === "preview" || mode === "dev") {
    return mode;
  }
  throw new Error(`Unknown v0.111 server mode ${mode}. Use preview or dev.`);
}

function runModeFor(cleanProfile: boolean, headed: boolean): BrowserControlRunMode {
  if (cleanProfile) {
    return headed ? "clean-profile-headed" : "clean-profile-headless";
  }
  return headed ? "preview-headed" : "preview-headless";
}

function defaultPort(serverMode: ServerMode): number {
  return serverMode === "dev" ? DEFAULT_DEV_PORT : DEFAULT_PREVIEW_PORT;
}

function argValue(args: string[], name: string): string | undefined {
  return args.find((arg) => arg.startsWith(`${name}=`))?.slice(name.length + 1);
}

function viewportSize(label: string): { width: number; height: number } {
  const [width, height] = label.split("x").map((value) => Number(value));
  return { width, height };
}

function bytesToMb(value: number): number {
  return roundMetric(value / 1024 / 1024);
}

function roundMetric(value: number): number {
  return Number((Number.isFinite(value) ? value : 0).toFixed(2));
}

function keyFor(result: BrowserControlBaselineResult): string {
  return `${result.runMode}:${result.id}`;
}

function gitOutput(args: string[]): string {
  return execFileSync("git", args, { cwd: process.cwd(), encoding: "utf8" }).trim();
}

function displayPath(path: string): string {
  return path.replace(resolve(process.cwd()), "").replace(/^[/\\]/u, "").replace(/\\/gu, "/");
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : String(error));
  process.exitCode = 1;
});
