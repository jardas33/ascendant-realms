import { execFileSync } from "node:child_process";
import { cp, mkdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import { dirname, join, relative, resolve, sep } from "node:path";
import process from "node:process";

const PACKAGE_ROOT = resolve("artifacts", "playtest");
const DIST_DIR = resolve("dist");
const CHECKPOINT = "v0.30-v0.31 rival champion and relic reward foundation";
const PACKAGE_PURPOSE = "private human playtest distribution";

interface PlaytestBuildInfo {
  packageName: string;
  checkpoint: string;
  packagePurpose: string;
  commit: string;
  shortCommit: string;
  workingTreeDirty: boolean;
  generatedAtUtc: string;
  gameDirectory: string;
  startCommand: string;
  requiresLocalServer: boolean;
  feedbackFile: string;
  knownWarnings: string[];
  notForJudging: string[];
}

async function main(): Promise<void> {
  await assertDirectoryExists(DIST_DIR, "dist");

  const commit = gitOutput(["rev-parse", "HEAD"]);
  const shortCommit = gitOutput(["rev-parse", "--short=7", "HEAD"]);
  const dirty = gitOutput(["status", "--short"]).trim().length > 0;
  const packageName = `ascendant-realms-private-playtest-${shortCommit}${dirty ? "-dirty" : ""}`;
  const packageDir = resolve(PACKAGE_ROOT, packageName);
  assertInside(PACKAGE_ROOT, packageDir);

  await rm(packageDir, { recursive: true, force: true });
  await mkdir(packageDir, { recursive: true });
  await cp(DIST_DIR, join(packageDir, "game"), { recursive: true });

  await copyMarkdown("docs/V014_PRIVATE_PLAYTEST_TESTER_README.md", join(packageDir, "README_FOR_TESTERS.md"));
  await copyMarkdown("docs/V0126_TESTER_QUICK_START.md", join(packageDir, "TESTER_QUICK_START.md"));
  await copyMarkdown("docs/V0126_FEEDBACK_SUBMISSION_PACKET.md", join(packageDir, "FEEDBACK_SUBMISSION_PACKET.md"));
  await copyMarkdown("docs/V0126_ROUTE_ASSIGNMENT_PLAN.md", join(packageDir, "ROUTE_ASSIGNMENT_PLAN.md"));
  await copyMarkdown("docs/V014_READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md", join(packageDir, "READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md"));
  await copyMarkdown("docs/V016_EMMANUEL_CONTROL_RETEST_SCRIPT.md", join(packageDir, "CONTROL_RETEST_SCRIPT.md"));
  await copyMarkdown("docs/V016_PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md", join(packageDir, "PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md"));
  await copyMarkdown("docs/V016_BEHAVIOUR_MODE_TESTER_CHECKLIST.md", join(packageDir, "BEHAVIOUR_MODE_TESTER_CHECKLIST.md"));
  await copyMarkdown("docs/V016_CONTROL_FEEDBACK_INTAKE_TEMPLATE.md", join(packageDir, "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md"));
  await copyMarkdown("docs/V016_CONTROL_REGRESSION_TRIAGE_GUIDE.md", join(packageDir, "CONTROL_REGRESSION_TRIAGE_GUIDE.md"));
  await copyMarkdown("docs/V01610_RELEASE_CANDIDATE_DECISION.md", join(packageDir, "RELEASE_CANDIDATE_NOTES.md"));
  await copyMarkdown("docs/V01610_EMMANUEL_MANUAL_RETEST_CHECKLIST.md", join(packageDir, "EMMANUEL_MANUAL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V01610_TESTER_MESSAGE_SHORT.md", join(packageDir, "FIRST_TESTER_MESSAGE.md"));
  await copyMarkdown("docs/V01610_TESTER_FEEDBACK_FORM_SHORT.md", join(packageDir, "TESTER_FEEDBACK_FORM_SHORT.md"));
  await copyMarkdown("docs/V01610_ROUTE_ASSIGNMENTS_SMALL_BATCH.md", join(packageDir, "ROUTE_ASSIGNMENTS_SMALL_BATCH.md"));
  await copyMarkdown("docs/V01611_TESTER_LAUNCH_PACKET_INDEX.md", join(packageDir, "TESTER_LAUNCH_PACKET_INDEX.md"));
  await copyMarkdown("docs/V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md", join(packageDir, "V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V01613_BD26DE3_RETEST_INTAKE.md", join(packageDir, "V01613_BD26DE3_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md", join(packageDir, "V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md"));
  await copyMarkdown("docs/V017_SOLO_PLAYTEST_INTAKE.md", join(packageDir, "V017_SOLO_PLAYTEST_INTAKE.md"));
  await copyMarkdown("docs/V017_WORKER_ECONOMY_DESIGN_SPEC.md", join(packageDir, "V017_WORKER_ECONOMY_DESIGN_SPEC.md"));
  await copyMarkdown("docs/V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md", join(packageDir, "V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md", join(packageDir, "V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V018_IMPLEMENTATION_REPORT.md", join(packageDir, "V018_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md", join(packageDir, "V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md"));
  await copyMarkdown("docs/V0182_IMPLEMENTATION_REPORT.md", join(packageDir, "V0182_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md", join(packageDir, "V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md", join(packageDir, "V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md"));
  await copyMarkdown("docs/V019_PRODUCTION_ARCHITECTURE_SPEC.md", join(packageDir, "V019_PRODUCTION_ARCHITECTURE_SPEC.md"));
  await copyMarkdown("docs/V019_IMPLEMENTATION_REPORT.md", join(packageDir, "V019_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md", join(packageDir, "V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md"));
  await copyMarkdown("docs/V0191_REMOTE_CI_STATUS.md", join(packageDir, "V0191_REMOTE_CI_STATUS.md"));
  await copyMarkdown("docs/V0191_PRODUCTION_ROLE_POLISH_REPORT.md", join(packageDir, "V0191_PRODUCTION_ROLE_POLISH_REPORT.md"));
  await copyMarkdown("docs/V020_TECH_TREE_FOUNDATION_SPEC.md", join(packageDir, "V020_TECH_TREE_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V020_IMPLEMENTATION_REPORT.md", join(packageDir, "V020_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md", join(packageDir, "V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md"));
  await copyMarkdown("docs/V021_WORKER_REPAIR_FOUNDATION_SPEC.md", join(packageDir, "V021_WORKER_REPAIR_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V021_IMPLEMENTATION_REPORT.md", join(packageDir, "V021_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V0211_WORKER_REPAIR_CLOSEOUT.md", join(packageDir, "V0211_WORKER_REPAIR_CLOSEOUT.md"));
  await copyMarkdown("docs/V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md", join(packageDir, "V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md", join(packageDir, "V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md"));
  await copyMarkdown("docs/V0213_WORKER_INTENT_CLOSEOUT.md", join(packageDir, "V0213_WORKER_INTENT_CLOSEOUT.md"));
  await copyMarkdown("docs/V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md", join(packageDir, "V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md"));
  await copyMarkdown("docs/V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md", join(packageDir, "V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md"));
  await copyMarkdown("docs/V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md", join(packageDir, "V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md"));
  await copyMarkdown("docs/V022_IMPLEMENTATION_REPORT.md", join(packageDir, "V022_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V022_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V022_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V023_RESOURCE_SITE_UPGRADES_SPEC.md", join(packageDir, "V023_RESOURCE_SITE_UPGRADES_SPEC.md"));
  await copyMarkdown("docs/V023_IMPLEMENTATION_REPORT.md", join(packageDir, "V023_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V023_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V023_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md", join(packageDir, "V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md"));
  await copyMarkdown("docs/V024_IMPLEMENTATION_REPORT.md", join(packageDir, "V024_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md", join(packageDir, "V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md"));
  await copyMarkdown("docs/V025_IMPLEMENTATION_REPORT.md", join(packageDir, "V025_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V025_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V025_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V026_ENEMY_BASE_DEVELOPMENT_SPEC.md", join(packageDir, "V026_ENEMY_BASE_DEVELOPMENT_SPEC.md"));
  await copyMarkdown("docs/V026_IMPLEMENTATION_REPORT.md", join(packageDir, "V026_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V027_ENEMY_TECH_ESCALATION_SPEC.md", join(packageDir, "V027_ENEMY_TECH_ESCALATION_SPEC.md"));
  await copyMarkdown("docs/V027_IMPLEMENTATION_REPORT.md", join(packageDir, "V027_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V027_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V027_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V028_HERO_PROGRESSION_SPEC.md", join(packageDir, "V028_HERO_PROGRESSION_SPEC.md"));
  await copyMarkdown("docs/V028_IMPLEMENTATION_REPORT.md", join(packageDir, "V028_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V029_HERO_ABILITIES_AND_REWARDS_SPEC.md", join(packageDir, "V029_HERO_ABILITIES_AND_REWARDS_SPEC.md"));
  await copyMarkdown("docs/V029_IMPLEMENTATION_REPORT.md", join(packageDir, "V029_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V029_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V029_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V0291_BLOCKED_REMOTE_CI_STATUS.md", join(packageDir, "V0291_BLOCKED_REMOTE_CI_STATUS.md"));
  await copyMarkdown(
    "docs/V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md",
    join(packageDir, "V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md")
  );
  await copyMarkdown("docs/V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md", join(packageDir, "V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md"));
  await copyMarkdown("docs/V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md", join(packageDir, "V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md"));
  await copyMarkdown("docs/V0292_RELEASE_MATRIX_CLOSEOUT.md", join(packageDir, "V0292_RELEASE_MATRIX_CLOSEOUT.md"));
  await copyMarkdown("docs/V0292_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V0292_EMMANUEL_RETEST_CHECKLIST.md"));
  await copyMarkdown("docs/V0292_LONG_SOAK_REPORT.md", join(packageDir, "V0292_LONG_SOAK_REPORT.md"));
  await copyMarkdown("docs/V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md", join(packageDir, "V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V031_RELIC_REWARD_FOUNDATION_SPEC.md", join(packageDir, "V031_RELIC_REWARD_FOUNDATION_SPEC.md"));
  await copyMarkdown("docs/V030_IMPLEMENTATION_REPORT.md", join(packageDir, "V030_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V031_IMPLEMENTATION_REPORT.md", join(packageDir, "V031_IMPLEMENTATION_REPORT.md"));
  await copyMarkdown("docs/V031_EMMANUEL_RETEST_CHECKLIST.md", join(packageDir, "V031_EMMANUEL_RETEST_CHECKLIST.md"));

  const buildInfo = createBuildInfo(packageName, commit, shortCommit, dirty);
  await writeFile(join(packageDir, "playtest-build-info.json"), `${JSON.stringify(buildInfo, null, 2)}\n`, "utf-8");
  await writeFile(join(packageDir, "PLAYTEST_BUILD_INFO.md"), renderBuildInfoMarkdown(buildInfo), "utf-8");
  await writeFile(join(packageDir, "start-playtest-server.mjs"), renderStaticServerScript(), "utf-8");
  await writeFile(join(packageDir, "START_GAME_WINDOWS.bat"), renderWindowsLauncher(), "utf-8");
  await writeFile(join(packageDir, "START_GAME_MAC_LINUX.sh"), renderShellLauncher(), "utf-8");

  console.log(`Created private playtest package: ${packageDir}`);
  console.log("Run npm run verify:playtest-package before sending it.");
}

function createBuildInfo(packageName: string, commit: string, shortCommit: string, dirty: boolean): PlaytestBuildInfo {
  return {
    packageName,
    checkpoint: CHECKPOINT,
    packagePurpose: PACKAGE_PURPOSE,
    commit,
    shortCommit,
    workingTreeDirty: dirty,
    generatedAtUtc: new Date().toISOString(),
    gameDirectory: "game/",
    startCommand: "node start-playtest-server.mjs",
    requiresLocalServer: true,
    feedbackFile: "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md",
    knownWarnings: ["Vite may warn that the Phaser vendor chunk is larger than 500 kB; this is expected for the current prototype."],
    notForJudging: [
      "final art quality",
      "placeholder unit scale",
      "unfinished animations",
      "missing final VFX",
      "future 2026 visual overhaul work"
    ]
  };
}

async function copyMarkdown(sourcePath: string, targetPath: string): Promise<void> {
  const content = await readFile(resolve(sourcePath), "utf-8");
  await mkdir(dirname(targetPath), { recursive: true });
  await writeFile(targetPath, content, "utf-8");
}

async function assertDirectoryExists(path: string, label: string): Promise<void> {
  try {
    const stats = await stat(path);
    if (!stats.isDirectory()) {
      throw new Error(`${label} exists but is not a directory: ${path}`);
    }
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      throw new Error(`Missing ${label} directory at ${path}. Run npm run build:playtest first.`);
    }
    throw error;
  }
}

function assertInside(parent: string, child: string): void {
  const relativePath = relative(resolve(parent), resolve(child));
  if (relativePath.startsWith("..") || relativePath === "" || relativePath.includes(`..${sep}`)) {
    throw new Error(`Refusing to write package outside ${parent}: ${child}`);
  }
}

function gitOutput(args: string[]): string {
  return execFileSync("git", args, { cwd: process.cwd(), encoding: "utf-8" }).trim();
}

function renderBuildInfoMarkdown(info: PlaytestBuildInfo): string {
  return `# Ascendant Realms Private Playtest Build Info

Package: ${info.packageName}
Checkpoint: ${info.checkpoint}
Purpose: ${info.packagePurpose}
Generated: ${info.generatedAtUtc}
Commit: ${info.commit}
Working tree dirty when packaged: ${info.workingTreeDirty ? "yes" : "no"}

## How To Start

Use ${info.startCommand}, or double-click START_GAME_WINDOWS.bat on Windows.

This build should be served from the included local server helper. Do not judge problems caused by opening game/index.html directly from the file system.

For the v0.30-v0.31 rival champion and relic reward foundation retest, start with V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md, V031_RELIC_REWARD_FOUNDATION_SPEC.md, V030_IMPLEMENTATION_REPORT.md, V031_IMPLEMENTATION_REPORT.md, and V031_EMMANUEL_RETEST_CHECKLIST.md. Also keep the v0.28-v0.29 hero progression docs and v0.29.2 hosted deep-battle closeout docs nearby as regression context. Focus on: named enemy commander readability, commander defeat XP/reward summaries, conservative commander AI that defends before joining only late coordinated attacks, the results-screen relic reward preview, and regressions for hero XP, ability cooldowns, resource-site/Worker economy, enemy economy pressure, world move/retreat clicks, minimap movement, and command-button hover stability. Tutorial remains no-save/no-reward and should not show relic reward complexity. This build does not add new art, new maps, new factions, save migration, inventory overhaul, complex loot, classic harvesting, visible enemy Workers, cargo, drop-off buildings, Patrol, formations, or final VFX.

## Known Warning

${info.knownWarnings.map((warning) => `- ${warning}`).join("\n")}

## What Not To Judge Yet

${info.notForJudging.map((item) => `- ${item}`).join("\n")}

## Feedback

Use ${info.feedbackFile} and send the completed form back to Emmanuel.
`;
}

function renderStaticServerScript(): string {
  return `import { createReadStream } from "node:fs";
import { stat } from "node:fs/promises";
import { createServer } from "node:http";
import { extname, join, relative, resolve, sep } from "node:path";
import { execFile } from "node:child_process";
import { fileURLToPath } from "node:url";

const packageRoot = resolve(fileURLToPath(new URL(".", import.meta.url)));
const gameRoot = resolve(packageRoot, "game");
const port = Number(process.env.ASCENDANT_PLAYTEST_PORT ?? "4174");
const host = "127.0.0.1";
const url = \`http://\${host}:\${port}/\`;

const mimeTypes = new Map([
  [".html", "text/html; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".mjs", "text/javascript; charset=utf-8"],
  [".css", "text/css; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".png", "image/png"],
  [".jpg", "image/jpeg"],
  [".jpeg", "image/jpeg"],
  [".svg", "image/svg+xml"],
  [".webp", "image/webp"],
  [".ico", "image/x-icon"]
]);

const server = createServer(async (request, response) => {
  try {
    const requestUrl = new URL(request.url ?? "/", url);
    const pathname = decodeURIComponent(requestUrl.pathname);
    const target = resolve(gameRoot, pathname === "/" ? "index.html" : pathname.slice(1));
    const relativePath = relative(gameRoot, target);

    if (relativePath.startsWith("..") || relativePath.includes(\`..\${sep}\`)) {
      response.writeHead(403);
      response.end("Forbidden");
      return;
    }

    const stats = await stat(target);
    const filePath = stats.isDirectory() ? join(target, "index.html") : target;
    response.writeHead(200, { "Content-Type": mimeTypes.get(extname(filePath).toLowerCase()) ?? "application/octet-stream" });
    createReadStream(filePath).pipe(response);
  } catch {
    response.writeHead(404);
    response.end("Not found");
  }
});

server.listen(port, host, () => {
  console.log("Ascendant Realms private playtest server is running.");
  console.log(\`Open: \${url}\`);
  if (process.env.ASCENDANT_PLAYTEST_NO_OPEN !== "1") {
    openBrowser(url);
  }
});

process.on("SIGINT", () => {
  server.close(() => process.exit(0));
});

function openBrowser(targetUrl) {
  const command =
    process.platform === "win32"
      ? ["cmd", ["/c", "start", "", targetUrl]]
      : process.platform === "darwin"
        ? ["open", [targetUrl]]
        : ["xdg-open", [targetUrl]];
  execFile(command[0], command[1], () => {});
}
`;
}

function renderWindowsLauncher(): string {
  return `@echo off
setlocal
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is required to run this private playtest package.
  echo Install Node.js LTS from https://nodejs.org/ or ask Emmanuel for a hosted link.
  pause
  exit /b 1
)
node "%~dp0start-playtest-server.mjs"
pause
`;
}

function renderShellLauncher(): string {
  return `#!/usr/bin/env sh
set -eu
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
node "$DIR/start-playtest-server.mjs"
`;
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : error);
  process.exitCode = 1;
});
