import { spawn, type ChildProcess } from "node:child_process";
import { once } from "node:events";
import { fileURLToPath } from "node:url";
import process from "node:process";
import { chromium, type Browser, type Page } from "@playwright/test";

const PREVIEW_HOST = process.env.ASCENDANT_PREVIEW_HOST ?? "127.0.0.1";
const PREVIEW_PORT = Number(process.env.ASCENDANT_PREVIEW_PORT ?? "4173");
const PREVIEW_URL = `http://${PREVIEW_HOST}:${PREVIEW_PORT}/`;
const SERVER_TIMEOUT_MS = 60_000;
const ACTION_TIMEOUT_MS = 30_000;
const SAVE_KEY = "ascendant-realms-save-v1";

type PreviewProcess = {
  child: ChildProcess;
  exited: boolean;
  exitCode: number | null;
};

async function main(): Promise<void> {
  const preview = startPreviewServer();
  let browser: Browser | undefined;
  const consoleErrors: string[] = [];

  try {
    await waitForPreviewServer(preview);

    browser = await chromium.launch({
      headless: true,
      args: ["--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"]
    });

    const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
    captureConsoleErrors(page, consoleErrors);

    await runPreviewSmoke(page);

    if (consoleErrors.length > 0) {
      throw new Error(`Preview smoke recorded ${consoleErrors.length} browser console error(s):\n${consoleErrors.join("\n")}`);
    }

    console.log(
      [
        "Production preview smoke passed.",
        `URL: ${PREVIEW_URL}`,
        "Verified: title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup.",
        "Browser console errors: 0."
      ].join("\n")
    );
  } finally {
    await browser?.close();
    await stopPreviewServer(preview);
  }
}

function startPreviewServer(): PreviewProcess {
  const viteCliPath = fileURLToPath(new URL("../node_modules/vite/bin/vite.js", import.meta.url));
  const child = spawn(
    process.execPath,
    [viteCliPath, "preview", "--host", PREVIEW_HOST, "--port", String(PREVIEW_PORT), "--strictPort"],
    {
      cwd: process.cwd(),
      env: process.env,
      stdio: ["ignore", "pipe", "pipe"],
      windowsHide: true
    }
  );

  const preview: PreviewProcess = {
    child,
    exited: false,
    exitCode: null
  };

  child.stdout?.on("data", (chunk: Buffer) => {
    process.stdout.write(prefixOutput("preview", chunk));
  });

  child.stderr?.on("data", (chunk: Buffer) => {
    process.stderr.write(prefixOutput("preview", chunk));
  });

  child.on("exit", (code) => {
    preview.exited = true;
    preview.exitCode = code;
  });

  return preview;
}

async function waitForPreviewServer(preview: PreviewProcess): Promise<void> {
  const start = Date.now();
  let lastError = "";

  while (Date.now() - start < SERVER_TIMEOUT_MS) {
    if (preview.exited) {
      throw new Error(`Preview server exited before smoke checks started. Exit code: ${preview.exitCode ?? "unknown"}.`);
    }

    try {
      const response = await fetch(PREVIEW_URL);
      if (response.ok) {
        return;
      }
      lastError = `HTTP ${response.status}`;
    } catch (error) {
      lastError = error instanceof Error ? error.message : String(error);
    }

    await sleep(500);
  }

  throw new Error(`Timed out waiting ${SERVER_TIMEOUT_MS}ms for ${PREVIEW_URL}. Last error: ${lastError}`);
}

function captureConsoleErrors(page: Page, consoleErrors: string[]): void {
  page.on("console", (message) => {
    if (message.type() === "error") {
      consoleErrors.push(`[console.error] ${message.text()}`);
    }
  });

  page.on("pageerror", (error) => {
    consoleErrors.push(`[pageerror] ${error.message}`);
  });
}

async function runPreviewSmoke(page: Page): Promise<void> {
  await page.goto(PREVIEW_URL, { waitUntil: "domcontentloaded", timeout: ACTION_TIMEOUT_MS });
  await page.evaluate(() => localStorage.clear());
  await page.reload({ waitUntil: "domcontentloaded", timeout: ACTION_TIMEOUT_MS });

  await expectVisible(page, "main-menu", "main menu");
  await expectText(page, "Prototype v0.3");
  await expectText(page, "Cinderfen Route Baseline");

  const title = await page.title();
  if (title !== "Ascendant Realms") {
    throw new Error(`Expected document title "Ascendant Realms", received "${title}".`);
  }

  await page.getByTestId("menu-tutorial").click();
  await expectVisible(page, "battle-hud", "tutorial battle HUD");
  await expectVisible(page, "tutorial-overlay", "tutorial overlay");
  await page.getByTestId("tutorial-exit").click();
  await expectVisible(page, "main-menu", "main menu after tutorial exit");

  await page.getByTestId("menu-new-campaign").click();
  await expectVisible(page, "hero-creation", "hero creation");
  await page.getByTestId("hero-name-input").fill("Preview Smoke");
  await page.getByTestId("hero-start").click();
  await expectVisible(page, "campaign-map", "campaign map after New Campaign");

  await page.goto(PREVIEW_URL, { waitUntil: "domcontentloaded", timeout: ACTION_TIMEOUT_MS });
  await expectVisible(page, "main-menu", "main menu before Continue Campaign");
  await page.getByTestId("menu-continue-campaign").click();
  await expectVisible(page, "campaign-map", "campaign map after Continue Campaign");

  await page.goto(PREVIEW_URL, { waitUntil: "domcontentloaded", timeout: ACTION_TIMEOUT_MS });
  await expectVisible(page, "main-menu", "main menu before Skirmish Setup");
  await page.getByTestId("menu-skirmish").click();
  await expectVisible(page, "skirmish-setup", "skirmish setup");

  const saved = await page.evaluate((key) => localStorage.getItem(key), SAVE_KEY);
  if (!saved) {
    throw new Error("Expected New Campaign to create a save that Continue Campaign can open.");
  }
}

async function expectVisible(page: Page, testId: string, label: string): Promise<void> {
  await page.getByTestId(testId).waitFor({ state: "visible", timeout: ACTION_TIMEOUT_MS });
  console.log(`PASS: ${label}`);
}

async function expectText(page: Page, text: string): Promise<void> {
  await page.getByText(text, { exact: true }).waitFor({ state: "visible", timeout: ACTION_TIMEOUT_MS });
  console.log(`PASS: visible text "${text}"`);
}

async function stopPreviewServer(preview: PreviewProcess): Promise<void> {
  if (preview.exited || preview.child.pid === undefined) {
    return;
  }

  if (process.platform === "win32") {
    const killer = spawn("taskkill", ["/PID", String(preview.child.pid), "/T", "/F"], {
      stdio: "ignore",
      windowsHide: true
    });
    await once(killer, "exit");
    return;
  }

  preview.child.kill("SIGTERM");
  await Promise.race([once(preview.child, "exit"), sleep(5_000)]);
  if (!preview.exited) {
    preview.child.kill("SIGKILL");
  }
}

function prefixOutput(prefix: string, chunk: Buffer): string {
  return chunk
    .toString()
    .split(/\r?\n/)
    .filter((line) => line.length > 0)
    .map((line) => `[${prefix}] ${line}\n`)
    .join("");
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : error);
  process.exitCode = 1;
});
