export interface PlaytestPackageFileSnapshot {
  path: string;
  sizeBytes: number;
  textContent?: string;
}

export interface PlaytestPackageSnapshot {
  packageName: string;
  files: PlaytestPackageFileSnapshot[];
}

export interface PlaytestPackageValidationResult {
  ok: boolean;
  checks: string[];
  errors: string[];
}

export const REQUIRED_PLAYTEST_PACKAGE_FILES = [
  "game/index.html",
  "README_FOR_TESTERS.md",
  "PLAYTEST_BUILD_INFO.md",
  "playtest-build-info.json",
  "FEEDBACK_SUBMISSION_PACKET.md",
  "TESTER_QUICK_START.md",
  "ROUTE_ASSIGNMENT_PLAN.md",
  "CONTROL_RETEST_SCRIPT.md",
  "PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md",
  "BEHAVIOUR_MODE_TESTER_CHECKLIST.md",
  "CONTROL_FEEDBACK_INTAKE_TEMPLATE.md",
  "CONTROL_REGRESSION_TRIAGE_GUIDE.md",
  "start-playtest-server.mjs",
  "START_GAME_WINDOWS.bat",
  "START_GAME_MAC_LINUX.sh"
] as const;

const FORBIDDEN_PATH_PARTS = [
  "node_modules",
  ".git",
  "docs/playtest-feedback",
  "playtest-feedback/raw",
  "private-feedback",
  "raw-private-feedback",
  "tester-private-feedback"
];

const FORBIDDEN_FILE_NAMES = [".env", ".env.local", ".env.production", "id_rsa", "id_ed25519"];

const SECRET_PATTERNS: Array<{ label: string; pattern: RegExp }> = [
  { label: "private key block", pattern: /-----BEGIN [A-Z ]*PRIVATE KEY-----/u },
  { label: "OpenAI API key assignment", pattern: /OPENAI_API_KEY\s*=/iu },
  { label: "GitHub token assignment", pattern: /GITHUB_TOKEN\s*=/iu },
  { label: "AWS secret assignment", pattern: /AWS_SECRET_ACCESS_KEY\s*=/iu },
  { label: "service role key assignment", pattern: /SERVICE_ROLE_KEY\s*=/iu },
  { label: "Vite secret assignment", pattern: /VITE_[A-Z0-9_]*SECRET\s*=/iu }
];

export function validatePlaytestPackageSnapshot(snapshot: PlaytestPackageSnapshot): PlaytestPackageValidationResult {
  const checks: string[] = [];
  const errors: string[] = [];
  const files = snapshot.files.map((file) => ({ ...file, path: normalizePackagePath(file.path) }));
  const fileSet = new Set(files.map((file) => file.path.toLowerCase()));

  REQUIRED_PLAYTEST_PACKAGE_FILES.forEach((requiredPath) => {
    if (fileSet.has(requiredPath.toLowerCase())) {
      checks.push(`required file present: ${requiredPath}`);
    } else {
      errors.push(`Missing required package file: ${requiredPath}.`);
    }
  });

  if (files.some((file) => file.path.startsWith("game/assets/") && file.sizeBytes > 0)) {
    checks.push("built game assets present");
  } else {
    errors.push("Missing built game assets under game/assets/.");
  }

  files.forEach((file) => {
    const lowerPath = file.path.toLowerCase();
    FORBIDDEN_PATH_PARTS.forEach((part) => {
      if (lowerPath === part || lowerPath.includes(`/${part}/`) || lowerPath.startsWith(`${part}/`)) {
        errors.push(`Forbidden package path included: ${file.path}.`);
      }
    });

    const fileName = lowerPath.split("/").at(-1) ?? lowerPath;
    if (FORBIDDEN_FILE_NAMES.includes(fileName)) {
      errors.push(`Forbidden secret-like file included: ${file.path}.`);
    }

    if (file.textContent !== undefined) {
      SECRET_PATTERNS.forEach(({ label, pattern }) => {
        if (pattern.test(file.textContent ?? "")) {
          errors.push(`Possible secret detected in ${file.path}: ${label}.`);
        }
      });
    }
  });

  if (errors.length === 0) {
    checks.push("no forbidden paths or obvious secrets detected");
  }

  const indexHtml = files.find((file) => file.path.toLowerCase() === "game/index.html")?.textContent ?? "";
  if (indexHtml.includes('src="/assets/') || indexHtml.includes('href="/assets/')) {
    errors.push("game/index.html uses absolute /assets/ URLs; playtest builds should use relative assets.");
  } else if (indexHtml.length > 0) {
    checks.push("game/index.html uses package-safe relative asset URLs");
  }

  const buildInfoText = files.find((file) => file.path.toLowerCase() === "playtest-build-info.json")?.textContent;
  if (buildInfoText) {
    validateBuildInfo(buildInfoText, checks, errors);
  }

  return { ok: errors.length === 0, checks, errors };
}

export function assertPlaytestPackageSnapshot(snapshot: PlaytestPackageSnapshot): PlaytestPackageValidationResult {
  const result = validatePlaytestPackageSnapshot(snapshot);
  if (!result.ok) {
    throw new Error(`Playtest package validation failed:\n${result.errors.map((error) => `- ${error}`).join("\n")}`);
  }
  return result;
}

function validateBuildInfo(buildInfoText: string, checks: string[], errors: string[]): void {
  try {
    const parsed = JSON.parse(buildInfoText) as Record<string, unknown>;
    expectString(parsed.commit, "build info commit", checks, errors);
    expectString(parsed.shortCommit, "build info shortCommit", checks, errors);
    expectString(parsed.generatedAtUtc, "build info generatedAtUtc", checks, errors);
    expectEqual(
      parsed.checkpoint,
      "v0.16.9 autonomous manual-retest proxy and tester readiness",
      "build info checkpoint",
      checks,
      errors
    );
    expectEqual(parsed.packagePurpose, "private human playtest distribution", "build info package purpose", checks, errors);
    expectEqual(parsed.requiresLocalServer, true, "build info local server requirement", checks, errors);
  } catch (error) {
    errors.push(`playtest-build-info.json is not valid JSON: ${String(error)}.`);
  }
}

function expectString(value: unknown, label: string, checks: string[], errors: string[]): void {
  if (typeof value === "string" && value.trim().length > 0) {
    checks.push(label);
  } else {
    errors.push(`${label} is missing or empty.`);
  }
}

function expectEqual(actual: unknown, expected: unknown, label: string, checks: string[], errors: string[]): void {
  if (Object.is(actual, expected)) {
    checks.push(label);
  } else {
    errors.push(`${label} mismatch: expected ${String(expected)}, got ${String(actual)}.`);
  }
}

function normalizePackagePath(path: string): string {
  return path.replaceAll("\\", "/").replace(/^\.?\//u, "");
}
