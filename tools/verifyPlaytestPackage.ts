import { constants } from "node:fs";
import { access, readdir, readFile, stat } from "node:fs/promises";
import { join, relative, resolve } from "node:path";
import { assertPlaytestPackageSnapshot, type PlaytestPackageFileSnapshot } from "../src/game/playtest/PlaytestPackageValidation";

const PACKAGE_ROOT = resolve("artifacts", "playtest");

async function main(): Promise<void> {
  const packageDir = await resolvePackageDir();
  const files = await collectFiles(packageDir);
  const result = assertPlaytestPackageSnapshot({
    packageName: packageDir.split(/[\\/]/u).at(-1) ?? packageDir,
    files
  });

  console.log(`Playtest package verification passed (${result.checks.length} checks).`);
  console.log(`Package: ${packageDir}`);
  result.checks.forEach((check) => console.log(`- ${check}`));
}

async function resolvePackageDir(): Promise<string> {
  const explicitPath = stringOption(process.argv.slice(2), "--package");
  if (explicitPath) {
    await access(resolve(explicitPath), constants.R_OK);
    return resolve(explicitPath);
  }

  const entries = await readdir(PACKAGE_ROOT, { withFileTypes: true });
  const candidates = await Promise.all(
    entries
      .filter((entry) => entry.isDirectory() && entry.name.startsWith("ascendant-realms-private-playtest-"))
      .map(async (entry) => {
        const path = join(PACKAGE_ROOT, entry.name);
        const stats = await stat(path);
        return { path, mtimeMs: stats.mtimeMs };
      })
  );

  const latest = candidates.sort((left, right) => right.mtimeMs - left.mtimeMs)[0];
  if (!latest) {
    throw new Error(`No private playtest package found under ${PACKAGE_ROOT}. Run npm run package:playtest first.`);
  }
  return latest.path;
}

async function collectFiles(root: string): Promise<PlaytestPackageFileSnapshot[]> {
  const files: PlaytestPackageFileSnapshot[] = [];

  async function visit(directory: string): Promise<void> {
    const entries = await readdir(directory, { withFileTypes: true });
    for (const entry of entries) {
      const path = join(directory, entry.name);
      if (entry.isDirectory()) {
        await visit(path);
        continue;
      }

      if (!entry.isFile()) {
        continue;
      }

      const stats = await stat(path);
      const snapshot: PlaytestPackageFileSnapshot = {
        path: relative(root, path),
        sizeBytes: stats.size
      };
      if (stats.size <= 2_000_000 && isTextLike(path)) {
        snapshot.textContent = await readFile(path, "utf-8");
      }
      files.push(snapshot);
    }
  }

  await visit(root);
  return files;
}

function isTextLike(path: string): boolean {
  return /\.(?:bat|css|html|js|json|md|mjs|sh|txt)$/iu.test(path);
}

function stringOption(args: string[], name: string): string | undefined {
  const prefix = `${name}=`;
  const match = args.find((arg) => arg.startsWith(prefix));
  return match?.slice(prefix.length);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.stack ?? error.message : error);
  process.exitCode = 1;
});
