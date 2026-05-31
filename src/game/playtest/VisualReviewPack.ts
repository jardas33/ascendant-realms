import { copyFile, mkdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";

export const REQUIRED_REVIEW_SCREEN_GROUPS = [
  "Main Menu",
  "Campaign Map",
  "Campaign Tabs",
  "Battle HUD",
  "Selected Units",
  "Selected Buildings",
  "Capture Sites",
  "Fog And Minimap",
  "Lume States",
  "Private Demo Results",
  "Normal Results",
  "Tutorial"
] as const;

export const REVIEW_TARGET_VIEWPORTS = ["1920x1080", "1600x900", "1366x768"] as const;

type ReviewScreenFamily = (typeof REQUIRED_REVIEW_SCREEN_GROUPS)[number];

const FOCUSED_CONTACT_SHEETS: readonly { id: string; title: string; groups: readonly ReviewScreenFamily[] }[] = [
  { id: "campaign-shell", title: "Campaign shell", groups: ["Campaign Map", "Campaign Tabs"] },
  {
    id: "battle-shell",
    title: "Battle shell",
    groups: ["Battle HUD", "Selected Units", "Selected Buildings", "Capture Sites", "Fog And Minimap"]
  },
  { id: "lume-flow", title: "Lume flow", groups: ["Lume States", "Private Demo Results"] },
  { id: "results-flow", title: "Results flow", groups: ["Private Demo Results", "Normal Results"] }
] as const;

export interface VisualRegressionEntry {
  screenshotId: string;
  route: string;
  viewport: string;
  state: string;
  expectedVisibleControls: string[];
  expectedAbsentControls: string[];
  reviewNotes: string;
  updateRules: string;
  owner: string;
  lastReviewedCheckpoint: string;
}

export interface VisualRegressionMatrix {
  schemaVersion: number;
  checkpoint: string;
  title: string;
  updatePolicy: string;
  entries: VisualRegressionEntry[];
}

export interface VisualQaCapture {
  title: string;
  sourceGroup: string;
  fileName: string;
  viewport: string;
  retryUsed: boolean;
  durationMs: number;
  note: string;
}

export interface ReviewScreenshotEntry {
  screenshotId: string;
  screenFamily: ReviewScreenFamily;
  title: string;
  sourceGroup: string;
  fileName: string;
  sourceFile: string;
  reviewFile: string;
  viewport: string;
  viewportSize: string;
  route: string;
  state: string;
  expectedVisibleControls: string[];
  expectedAbsentControls: string[];
  reviewNotes: string;
  updateRules: string;
  owner: string;
  lastReviewedCheckpoint: string;
  matrixMatched: boolean;
  retryUsed: boolean;
  durationMs: number;
  sizeBytes: number;
}

export interface ReviewContactSheet {
  id: string;
  title: string;
  file: string;
  kind: "viewport" | "focused";
  screenshotCount: number;
}

export interface VisualReviewManifest {
  schemaVersion: 1;
  checkpoint: string;
  title: string;
  generatedAtUtc: string;
  source: {
    visualQaIndex: string;
    visualRegressionMatrix: string;
    screenshotDirectory: string;
  };
  screenshotCount: number;
  matrixEntryCount: number;
  contactSheetCount: number;
  screenGroups: string[];
  targetViewports: string[];
  screenshots: ReviewScreenshotEntry[];
  contactSheets: ReviewContactSheet[];
}

export interface GenerateVisualReviewPackOptions {
  visualQaIndexPath?: string;
  visualRegressionMatrixPath?: string;
  screenshotDirectory?: string;
  outputDirectory?: string;
}

export interface GenerateVisualReviewPackResult {
  outputDirectory: string;
  manifestPath: string;
  indexPath: string;
  readmePath: string;
  screenshotCount: number;
  contactSheetCount: number;
  screenGroups: string[];
  targetViewports: string[];
}

interface BuildModelOptions {
  visualQaIndexPath: string;
  visualRegressionMatrixPath: string;
  screenshotDirectory: string;
}

interface ParsedVisualQaIndex {
  generatedAtUtc: string;
  captures: VisualQaCapture[];
}

interface ReviewPackModel {
  generatedAtUtc: string;
  matrix: VisualRegressionMatrix;
  screenshots: ReviewScreenshotEntry[];
  contactSheets: ReviewContactSheet[];
}

const DEFAULT_VISUAL_QA_INDEX = path.resolve("visual-qa", "latest", "index.md");
const DEFAULT_VISUAL_REGRESSION_MATRIX = path.resolve("docs", "V090_VISUAL_REGRESSION_MATRIX.json");
const DEFAULT_SCREENSHOT_DIRECTORY = path.resolve("visual-qa", "latest");
const DEFAULT_OUTPUT_DIRECTORY = path.resolve("artifacts", "visual-review", "latest");

export async function generateVisualReviewPack(
  options: GenerateVisualReviewPackOptions = {}
): Promise<GenerateVisualReviewPackResult> {
  const visualQaIndexPath = path.resolve(options.visualQaIndexPath ?? DEFAULT_VISUAL_QA_INDEX);
  const visualRegressionMatrixPath = path.resolve(options.visualRegressionMatrixPath ?? DEFAULT_VISUAL_REGRESSION_MATRIX);
  const screenshotDirectory = path.resolve(options.screenshotDirectory ?? DEFAULT_SCREENSHOT_DIRECTORY);
  const outputDirectory = path.resolve(options.outputDirectory ?? DEFAULT_OUTPUT_DIRECTORY);
  const model = await buildReviewPackModel({
    visualQaIndexPath,
    visualRegressionMatrixPath,
    screenshotDirectory
  });

  await rm(outputDirectory, { recursive: true, force: true });
  await mkdir(path.join(outputDirectory, "screenshots"), { recursive: true });
  await mkdir(path.join(outputDirectory, "contact-sheets"), { recursive: true });

  for (const screenshot of model.screenshots) {
    await copyFile(path.join(screenshotDirectory, screenshot.fileName), path.join(outputDirectory, screenshot.reviewFile));
  }

  const manifest: VisualReviewManifest = {
    schemaVersion: 1,
    checkpoint: "v0.92",
    title: "Visual Review Pack Generator and Unified Emmanuel Retest Packet",
    generatedAtUtc: model.generatedAtUtc,
    source: {
      visualQaIndex: displayPath(visualQaIndexPath),
      visualRegressionMatrix: displayPath(visualRegressionMatrixPath),
      screenshotDirectory: displayPath(screenshotDirectory)
    },
    screenshotCount: model.screenshots.length,
    matrixEntryCount: model.matrix.entries.length,
    contactSheetCount: model.contactSheets.length,
    screenGroups: [...REQUIRED_REVIEW_SCREEN_GROUPS],
    targetViewports: [...REVIEW_TARGET_VIEWPORTS],
    screenshots: model.screenshots,
    contactSheets: model.contactSheets
  };

  await writeFile(path.join(outputDirectory, "review-manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
  await writeFile(path.join(outputDirectory, "README.md"), renderReadme(manifest), "utf8");
  await writeFile(path.join(outputDirectory, "index.html"), renderIndexHtml(manifest), "utf8");

  for (const sheet of model.contactSheets) {
    const screenshots = selectContactSheetScreenshots(sheet, model.screenshots);
    await writeFile(path.join(outputDirectory, sheet.file), renderContactSheetHtml(sheet, screenshots), "utf8");
  }

  return {
    outputDirectory,
    manifestPath: path.join(outputDirectory, "review-manifest.json"),
    indexPath: path.join(outputDirectory, "index.html"),
    readmePath: path.join(outputDirectory, "README.md"),
    screenshotCount: model.screenshots.length,
    contactSheetCount: model.contactSheets.length,
    screenGroups: [...REQUIRED_REVIEW_SCREEN_GROUPS],
    targetViewports: [...REVIEW_TARGET_VIEWPORTS]
  };
}

export async function buildReviewPackModel(options: BuildModelOptions): Promise<ReviewPackModel> {
  const indexMarkdown = await readFile(options.visualQaIndexPath, "utf8");
  const parsedIndex = parseVisualQaIndex(indexMarkdown);
  const matrix = JSON.parse(await readFile(options.visualRegressionMatrixPath, "utf8")) as VisualRegressionMatrix;
  validateMatrix(matrix);

  const matrixById = new Map(matrix.entries.map((entry) => [entry.screenshotId, entry]));
  const seenIds = new Set<string>();
  const screenshots: ReviewScreenshotEntry[] = [];

  for (const capture of parsedIndex.captures) {
    const screenshotId = screenshotIdForFile(capture.fileName);
    if (seenIds.has(screenshotId)) {
      throw new Error(`Duplicate screenshot ID in visual QA output: ${screenshotId}`);
    }
    seenIds.add(screenshotId);
    const sourcePath = path.join(options.screenshotDirectory, capture.fileName);
    if (!existsSync(sourcePath)) {
      throw new Error(`Missing screenshot file for ${screenshotId}: ${sourcePath}`);
    }
    const matrixEntry = matrixById.get(screenshotId);
    const stats = await stat(sourcePath);
    const viewportSize = viewportSizeFromLabel(matrixEntry?.viewport ?? capture.viewport);
    screenshots.push({
      screenshotId,
      screenFamily: screenFamilyForCapture(capture, matrixEntry),
      title: capture.title,
      sourceGroup: capture.sourceGroup,
      fileName: capture.fileName,
      sourceFile: `visual-qa/latest/${capture.fileName}`,
      reviewFile: `screenshots/${capture.fileName}`,
      viewport: capture.viewport,
      viewportSize,
      route: matrixEntry?.route ?? capture.sourceGroup,
      state: matrixEntry?.state ?? capture.title,
      expectedVisibleControls: matrixEntry?.expectedVisibleControls ?? [],
      expectedAbsentControls: matrixEntry?.expectedAbsentControls ?? [],
      reviewNotes: matrixEntry?.reviewNotes ?? capture.note,
      updateRules: matrixEntry?.updateRules ?? "Update only when this capture is intentionally changed in the visual QA harness.",
      owner: matrixEntry?.owner ?? "QA",
      lastReviewedCheckpoint: matrixEntry?.lastReviewedCheckpoint ?? inferLastReviewedCheckpoint(screenshotId, capture),
      matrixMatched: matrixEntry !== undefined,
      retryUsed: capture.retryUsed,
      durationMs: capture.durationMs,
      sizeBytes: stats.size
    });
  }

  for (const entry of matrix.entries) {
    if (!seenIds.has(entry.screenshotId)) {
      throw new Error(`Visual regression matrix entry ${entry.screenshotId} was not found in visual QA output.`);
    }
  }

  const missingGroups = REQUIRED_REVIEW_SCREEN_GROUPS.filter(
    (group) => !screenshots.some((screenshot) => screenshot.screenFamily === group)
  );
  if (missingGroups.length > 0) {
    throw new Error(`Visual review pack is missing required screen group(s): ${missingGroups.join(", ")}`);
  }

  const contactSheets = buildContactSheets(screenshots);
  return {
    generatedAtUtc: parsedIndex.generatedAtUtc,
    matrix,
    screenshots,
    contactSheets
  };
}

export function parseVisualQaIndex(markdown: string): ParsedVisualQaIndex {
  const generatedAtUtc = markdown.match(/^Generated:\s+(.+)$/mu)?.[1]?.trim() ?? "unknown";
  const capturesStart = markdown.indexOf("## Captures");
  const capturesEnd = markdown.indexOf("## Console Errors");
  if (capturesStart < 0 || capturesEnd < capturesStart) {
    throw new Error("Visual QA index is missing the Captures or Console Errors section.");
  }

  const lines = markdown.slice(capturesStart, capturesEnd).split(/\r?\n/u);
  const captures: VisualQaCapture[] = [];
  let current: Partial<VisualQaCapture> | undefined;

  const finishCurrent = () => {
    if (!current) {
      return;
    }
    if (!current.title || !current.sourceGroup || !current.fileName || !current.viewport || current.retryUsed === undefined) {
      throw new Error(`Incomplete visual QA capture entry near ${current.title ?? current.fileName ?? "unknown capture"}.`);
    }
    captures.push({
      title: current.title,
      sourceGroup: current.sourceGroup,
      fileName: current.fileName,
      viewport: current.viewport,
      retryUsed: current.retryUsed,
      durationMs: current.durationMs ?? 0,
      note: current.note ?? ""
    });
  };

  for (const line of lines) {
    const titleMatch = line.match(/^- (.+)$/u);
    if (titleMatch && !line.startsWith("  ")) {
      finishCurrent();
      current = { title: titleMatch[1].trim() };
      continue;
    }
    if (!current) {
      continue;
    }
    const fieldMatch = line.match(/^\s+- ([^:]+):\s*(.*)$/u);
    if (!fieldMatch) {
      continue;
    }
    const field = fieldMatch[1].trim();
    const rawValue = stripMarkdownCode(fieldMatch[2].trim());
    if (field === "Group") {
      current.sourceGroup = rawValue;
    }
    if (field === "File") {
      current.fileName = rawValue;
    }
    if (field === "Viewport") {
      current.viewport = rawValue;
    }
    if (field === "Retry used") {
      current.retryUsed = rawValue === "yes";
    }
    if (field === "Screenshot duration") {
      current.durationMs = Number(rawValue.replace(/\s*ms$/u, "")) || 0;
    }
    if (field === "Note") {
      current.note = rawValue;
    }
  }
  finishCurrent();

  if (captures.length === 0) {
    throw new Error("Visual QA index did not contain any captures.");
  }
  return { generatedAtUtc, captures };
}

function validateMatrix(matrix: VisualRegressionMatrix): void {
  if (matrix.schemaVersion !== 1 || !Array.isArray(matrix.entries)) {
    throw new Error("Visual regression matrix schema is not recognized.");
  }
  const ids = matrix.entries.map((entry) => entry.screenshotId);
  const duplicates = ids.filter((id, index) => ids.indexOf(id) !== index);
  if (duplicates.length > 0) {
    throw new Error(`Duplicate screenshot ID in visual regression matrix: ${[...new Set(duplicates)].join(", ")}`);
  }
}

function buildContactSheets(screenshots: ReviewScreenshotEntry[]): ReviewContactSheet[] {
  const viewportSheets = REVIEW_TARGET_VIEWPORTS.map((viewport) => ({
    id: `viewport-${viewport}`,
    title: viewport,
    file: `contact-sheets/viewport-${viewport}.html`,
    kind: "viewport" as const,
    screenshotCount: screenshots.filter((screenshot) => screenshot.viewportSize === viewport).length
  }));
  const focusedSheets = FOCUSED_CONTACT_SHEETS.map((sheet) => ({
    id: sheet.id,
    title: sheet.title,
    file: `contact-sheets/${sheet.id}.html`,
    kind: "focused" as const,
    screenshotCount: screenshots.filter((screenshot) => sheet.groups.includes(screenshot.screenFamily)).length
  }));
  return [...viewportSheets, ...focusedSheets];
}

function selectContactSheetScreenshots(sheet: ReviewContactSheet, screenshots: ReviewScreenshotEntry[]): ReviewScreenshotEntry[] {
  if (sheet.kind === "viewport") {
    const viewport = sheet.title;
    return screenshots.filter((screenshot) => screenshot.viewportSize === viewport);
  }
  const focused = FOCUSED_CONTACT_SHEETS.find((entry) => entry.id === sheet.id);
  return screenshots.filter((screenshot) => focused?.groups.includes(screenshot.screenFamily));
}

function renderReadme(manifest: VisualReviewManifest): string {
  return [
    "# v0.92 Visual Review Pack",
    "",
    "Open `index.html` directly in a browser. No local server or external dependency is required.",
    "",
    `Generated from: \`${manifest.source.visualQaIndex}\` and \`${manifest.source.visualRegressionMatrix}\`.`,
    `Screenshot count: ${manifest.screenshotCount}.`,
    `Contact sheet count: ${manifest.contactSheetCount}.`,
    "",
    "## Contact Sheets",
    "",
    ...manifest.contactSheets.map((sheet) => `- [${sheet.title}](${sheet.file}) - ${sheet.screenshotCount} screenshots.`),
    "",
    "## Review Boundary",
    "",
    "- These images are current prototype screenshots, not generated art.",
    "- The pack copies existing visual-QA screenshots; it does not modify the source screenshots.",
    "- It is ignored by git and can be regenerated with `npm run visual:review-pack` after `npm run visual:qa`.",
    ""
  ].join("\n");
}

function renderIndexHtml(manifest: VisualReviewManifest): string {
  return renderHtmlPage({
    title: "v0.92 Visual Review Pack",
    body: [
      `<header class="hero"><p class="eyebrow">Ascendant Realms visual QA</p><h1>v0.92 Visual Review Pack</h1><p>${manifest.screenshotCount} screenshots grouped for fast human review. Built from the existing visual-QA output and v0.90 regression manifest.</p></header>`,
      renderSummary(manifest),
      `<section class="panel"><h2>Contact Sheets</h2><div class="sheet-grid">${manifest.contactSheets
        .map(
          (sheet) =>
            `<a class="sheet-link" href="${escapeAttribute(sheet.file)}"><span>${escapeHtml(sheet.title)}</span><strong>${sheet.screenshotCount}</strong></a>`
        )
        .join("")}</div></section>`,
      ...manifest.screenGroups.map((group) => renderScreenGroup(group, manifest.screenshots))
    ].join("\n")
  });
}

function renderContactSheetHtml(sheet: ReviewContactSheet, screenshots: ReviewScreenshotEntry[]): string {
  return renderHtmlPage({
    title: `v0.92 Contact Sheet - ${sheet.title}`,
    body: [
      `<header class="hero"><p class="eyebrow">Contact sheet</p><h1>${escapeHtml(sheet.title)}</h1><p>${screenshots.length} screenshots. <a href="../index.html">Back to review pack</a></p></header>`,
      `<main class="contact-sheet">${screenshots.map((screenshot) => renderContactCard(screenshot, "../")).join("")}</main>`
    ].join("\n")
  });
}

function renderSummary(manifest: VisualReviewManifest): string {
  return `<section class="panel summary-grid">
    <div><span>Generated</span><strong>${escapeHtml(manifest.generatedAtUtc)}</strong></div>
    <div><span>Screenshots</span><strong>${manifest.screenshotCount}</strong></div>
    <div><span>Matrix entries</span><strong>${manifest.matrixEntryCount}</strong></div>
    <div><span>Contact sheets</span><strong>${manifest.contactSheetCount}</strong></div>
  </section>`;
}

function renderScreenGroup(group: string, screenshots: ReviewScreenshotEntry[]): string {
  const groupScreenshots = screenshots.filter((screenshot) => screenshot.screenFamily === group);
  const byViewport = [...new Set(groupScreenshots.map((screenshot) => screenshot.viewportSize))].sort(viewportSort);
  return `<section class="panel group-panel" id="${escapeAttribute(slug(group))}">
    <h2>${escapeHtml(group)}</h2>
    ${byViewport
      .map((viewport) => {
        const entries = groupScreenshots.filter((screenshot) => screenshot.viewportSize === viewport);
        return `<section class="viewport-block"><h3>${escapeHtml(viewport)}</h3><div class="review-grid">${entries
          .map((screenshot) => renderReviewCard(screenshot))
          .join("")}</div></section>`;
      })
      .join("")}
  </section>`;
}

function renderReviewCard(screenshot: ReviewScreenshotEntry): string {
  return `<article class="review-card">
    <a href="${escapeAttribute(screenshot.reviewFile)}"><img src="${escapeAttribute(screenshot.reviewFile)}" alt="${escapeAttribute(screenshot.title)}" loading="lazy"></a>
    <div class="card-body">
      <p class="eyebrow">${escapeHtml(screenshot.screenFamily)} / ${escapeHtml(screenshot.viewportSize)}</p>
      <h4>${escapeHtml(screenshot.title)}</h4>
      <dl>
        <dt>ID</dt><dd><code>${escapeHtml(screenshot.screenshotId)}</code></dd>
        <dt>Route/state</dt><dd>${escapeHtml(screenshot.route)} / ${escapeHtml(screenshot.state)}</dd>
        <dt>Visible</dt><dd>${formatControls(screenshot.expectedVisibleControls)}</dd>
        <dt>Absent</dt><dd>${formatControls(screenshot.expectedAbsentControls)}</dd>
        <dt>Review notes</dt><dd>${escapeHtml(screenshot.reviewNotes)}</dd>
        <dt>Last reviewed</dt><dd>${escapeHtml(screenshot.lastReviewedCheckpoint)}</dd>
      </dl>
    </div>
  </article>`;
}

function renderContactCard(screenshot: ReviewScreenshotEntry, prefix: string): string {
  return `<article class="contact-card">
    <img src="${escapeAttribute(prefix + screenshot.reviewFile)}" alt="${escapeAttribute(screenshot.title)}" loading="lazy">
    <div><strong>${escapeHtml(screenshot.title)}</strong><span>${escapeHtml(screenshot.screenshotId)} / ${escapeHtml(
      screenshot.viewportSize
    )}</span></div>
  </article>`;
}

function renderHtmlPage(options: { title: string; body: string }): string {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(options.title)}</title>
  <style>
    :root { color-scheme: dark; --bg: #101419; --panel: #18212a; --panel-2: #202b35; --text: #edf3f6; --muted: #aebbc3; --line: #344553; --lume: #65d5cf; }
    body { margin: 0; font-family: Inter, Segoe UI, Arial, sans-serif; background: var(--bg); color: var(--text); }
    a { color: var(--lume); }
    .hero { padding: 28px 32px 16px; border-bottom: 1px solid var(--line); background: linear-gradient(180deg, #17202a, #101419); }
    .hero h1 { margin: 0 0 8px; font-size: 32px; letter-spacing: 0; }
    .hero p { max-width: 920px; color: var(--muted); }
    .eyebrow { margin: 0 0 6px; color: var(--lume); font-size: 12px; text-transform: uppercase; letter-spacing: .08em; }
    .panel { margin: 20px 32px; padding: 18px; background: var(--panel); border: 1px solid var(--line); border-radius: 8px; }
    .summary-grid, .sheet-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
    .summary-grid div, .sheet-link { display: flex; justify-content: space-between; gap: 12px; padding: 12px; background: var(--panel-2); border: 1px solid var(--line); border-radius: 6px; text-decoration: none; }
    .summary-grid span, .contact-card span { color: var(--muted); }
    .viewport-block h3 { color: var(--muted); font-size: 16px; margin: 18px 0 10px; }
    .review-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 16px; align-items: start; }
    .review-card, .contact-card { background: var(--panel-2); border: 1px solid var(--line); border-radius: 8px; overflow: hidden; }
    .review-card img { width: 100%; display: block; background: #05080b; }
    .card-body { padding: 14px; }
    .card-body h4 { margin: 0 0 10px; font-size: 18px; }
    dl { display: grid; grid-template-columns: 96px 1fr; gap: 8px 10px; margin: 0; font-size: 13px; }
    dt { color: var(--muted); }
    dd { margin: 0; }
    code { color: #f2d18b; }
    .contact-sheet { padding: 24px 32px; display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 14px; }
    .contact-card img { width: 100%; aspect-ratio: 16 / 9; object-fit: cover; display: block; background: #05080b; }
    .contact-card div { padding: 10px; display: grid; gap: 4px; }
  </style>
</head>
<body>
${options.body}
</body>
</html>
`;
}

function formatControls(controls: string[]): string {
  return controls.length > 0 ? controls.map((control) => `<code>${escapeHtml(control)}</code>`).join(", ") : "None listed";
}

function screenFamilyForCapture(
  capture: VisualQaCapture,
  matrixEntry?: VisualRegressionEntry
): (typeof REQUIRED_REVIEW_SCREEN_GROUPS)[number] {
  const haystack = `${capture.title} ${capture.fileName} ${capture.note} ${matrixEntry?.route ?? ""} ${matrixEntry?.state ?? ""}`.toLowerCase();
  if (haystack.includes("private") && haystack.includes("result")) {
    return "Private Demo Results";
  }
  if (haystack.includes("result")) {
    return "Normal Results";
  }
  if (haystack.includes("tutorial")) {
    return "Tutorial";
  }
  if (haystack.includes("lume") || haystack.includes("linked ward")) {
    return "Lume States";
  }
  if (haystack.includes("campaign tab") || haystack.includes("stronghold") || haystack.includes("hero inventory") || haystack.includes("reputation") || haystack.includes("intel")) {
    return "Campaign Tabs";
  }
  if (haystack.includes("campaign") || haystack.includes("mission") || haystack.includes("aether well") || haystack.includes("skirmish")) {
    return "Campaign Map";
  }
  if (haystack.includes("selected units") || haystack.includes("army group")) {
    return "Selected Units";
  }
  if (haystack.includes("selected building") || haystack.includes("command hall")) {
    return "Selected Buildings";
  }
  if (haystack.includes("capture site") || haystack.includes("shrine captured") || haystack.includes("resource-site")) {
    return "Capture Sites";
  }
  if (haystack.includes("fog") || haystack.includes("minimap") || haystack.includes("battlefield shell")) {
    return "Fog And Minimap";
  }
  if (haystack.includes("battle") || haystack.includes("pressure")) {
    return "Battle HUD";
  }
  return "Main Menu";
}

function screenshotIdForFile(fileName: string): string {
  return fileName.replace(/\.[^.]+$/u, "");
}

function viewportSizeFromLabel(label: string): string {
  return label.match(/\d+x\d+/u)?.[0] ?? label;
}

function inferLastReviewedCheckpoint(screenshotId: string, capture: VisualQaCapture): string {
  const explicit = screenshotId.match(/^v(\d{3})-/u)?.[1];
  if (explicit) {
    return `v0.${Number(explicit)}`;
  }
  const titleMatch = `${capture.title} ${capture.note}`.match(/v0\.(\d+)/iu);
  return titleMatch ? `v0.${titleMatch[1]}` : "visual-qa latest";
}

function stripMarkdownCode(value: string): string {
  return value.replace(/^`/u, "").replace(/`$/u, "");
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/gu, "&amp;")
    .replace(/</gu, "&lt;")
    .replace(/>/gu, "&gt;")
    .replace(/"/gu, "&quot;");
}

function escapeAttribute(value: string): string {
  return escapeHtml(value);
}

function slug(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/gu, "-").replace(/^-|-$/gu, "");
}

function displayPath(filePath: string): string {
  return path.relative(process.cwd(), filePath).replace(/\\/gu, "/");
}

function viewportSort(left: string, right: string): number {
  const leftWidth = Number(left.split("x")[0]) || 0;
  const rightWidth = Number(right.split("x")[0]) || 0;
  return rightWidth - leftWidth || left.localeCompare(right);
}
