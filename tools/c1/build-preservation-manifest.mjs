import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, normalize, relative, resolve } from "node:path";

const source = resolve(process.env.C1_SOURCE ?? "D:/CodexData/worktrees/ascendant-realms-human-playtest4-movement");
const output = resolve(process.env.C1_MANIFEST ?? join(process.cwd(), "docs/current/C1_SOURCE_PRESERVATION_MANIFEST.json"));

function git(...args) {
  return execFileSync("git", ["-C", source, ...args], { encoding: "utf8" }).trimEnd();
}

function fileRecord(path) {
  const absolute = join(source, path);
  const stat = statSync(absolute);
  const hash = createHash("sha256").update(readFileSync(absolute)).digest("hex");
  return { path, bytes: stat.size, sha256: hash };
}

const status = git("status", "--porcelain=v1", "-uall").split(/\r?\n/).filter(Boolean);
const trackedModified = git("diff", "--name-only").split(/\r?\n/).filter(Boolean);
const staged = git("diff", "--cached", "--name-only").split(/\r?\n/).filter(Boolean);
const untracked = status.filter((line) => line.startsWith("?? ")).map((line) => line.slice(3));
const relevant = [...new Set([...trackedModified, ...staged, ...untracked])]
  .filter((path) => path.startsWith("production/ascendant-realms-godot/"))
  .filter((path) => { try { return statSync(join(source, path)).isFile(); } catch { return false; } })
  .sort();
const project = join(source, "production/ascendant-realms-godot/project.godot");
const manifest = {
  schema: "ascendant-realms.c1-preservation-manifest.v1",
  generated_at_utc: new Date().toISOString(),
  source_root: source,
  source_head: git("rev-parse", "HEAD"),
  source_branch: git("branch", "--show-current"),
  source_status_entry_count: status.length,
  tracked_modified_paths: trackedModified,
  staged_paths: staged,
  untracked_paths: untracked,
  relevant_current_godot_files: relevant.map(fileRecord),
  project_identity: {
    path: "production/ascendant-realms-godot/project.godot",
    bytes: statSync(project).size,
    sha256: createHash("sha256").update(readFileSync(project)).digest("hex"),
    config_name: readFileSync(project, "utf8").match(/^config\/name="([^"]+)"/m)?.[1] ?? null,
    main_scene: readFileSync(project, "utf8").match(/^run\/main_scene="([^"]+)"/m)?.[1] ?? null,
  },
  partition: {
    ACCEPTED_CURRENT_GODOT_PRODUCTION: "to be classified before selective copy",
    QA_QUALIFICATION_TOOLING: "preserved in source snapshot; to be classified before selective copy",
    GENERATED_OR_EPHEMERAL: "preserved in source snapshot; excluded unless repository policy requires it",
    DOCUMENTATION: "classified separately",
    UNCERTAIN_OR_EXPERIMENTAL: "preserved in source snapshot; excluded until acceptance is established",
  },
};
mkdirSync(dirname(output), { recursive: true });
writeFileSync(output, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
console.log(JSON.stringify({ output, source_head: manifest.source_head, source_branch: manifest.source_branch, status_entries: status.length, tracked_modified: trackedModified.length, untracked: untracked.length, relevant_current_godot_files: relevant.length, project_identity: manifest.project_identity }));
