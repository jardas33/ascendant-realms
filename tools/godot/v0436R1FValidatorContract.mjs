export const ACCEPTED_R1F_IMPLEMENTATION_SHA = '1111f306929665b40dab998de7e2aaad7f4f43ae';
export const REQUIRED_R1F_BRANCH = 'codex/v0436-first-complete-conquest-victory';

export const R1F_DOCUMENTATION_DESCENDANT_ALLOWLIST = Object.freeze([
  'docs/V0436_R1F_BOUNDARY_RECOVERY_PHYSICS_TRUTH_REPORT.md',
  'docs/V0436_R1F_V1_RETAINED_VALIDATOR_DESCENDANT_COMPATIBILITY_REPORT.md',
  'docs/V0436_R1H_NATURAL_PLAYER_ASSAULT_VIABILITY_REPORT.md',
  'docs/V0436_R1G_NATURAL_CONQUEST_PREDICATE_TRUTH_AND_RESULT_REPLAY_REPORT.md',
  'docs/ASCENDANT_REALMS_MASTER_PLAYER_EXPERIENCE_BACKLOG.md',
  'production/ascendant-realms-godot/project.godot',
  'production/ascendant-realms-godot/scripts/main_menu.gd',
  'production/ascendant-realms-godot/scripts/world/game_root.gd',
  'production/ascendant-realms-godot/tests/v0436_r1h_capture.gd',
  'tools/godot/v0436R1HNaturalAssaultViabilityTool.mjs',
  'tools/godot/v0436R1HValidatorContract.mjs',
  'tools/godot/v0436R1HValidatorContract.test.ts',
  'tools/godot/v0436R1FValidatorContract.mjs',
  'package.json',
]);

export const R1F_DOCUMENTATION_DESCENDANT_PREFIX =
  'artifacts/manual-review/v0436-r1f-v1-retained-validator-descendant-compatibility/';

export const R1H_DESCENDANT_PREFIX =
  'artifacts/manual-review/v0436-r1h-natural-player-assault-viability/';

export function normalizeGitPath(value) {
  return String(value || '').replaceAll('\\', '/').replace(/^\.\//, '');
}

export function isAllowedR1FDocumentationDescendantPath(value) {
  const normalized = normalizeGitPath(value);
  return R1F_DOCUMENTATION_DESCENDANT_ALLOWLIST.includes(normalized)
    || normalized.startsWith(R1F_DOCUMENTATION_DESCENDANT_PREFIX)
    || normalized.startsWith(R1H_DESCENDANT_PREFIX);
}

export function evaluateR1FValidatorContract({
  branch,
  validatedHead,
  acceptedImplementationSha = ACCEPTED_R1F_IMPLEMENTATION_SHA,
  acceptedImplementationIsAncestor,
  runs,
  evidenceSourceIsAncestor = false,
  acceptedImplementationIsAncestorOfEvidence = false,
  descendantChangedPaths = [],
}) {
  const failures = [];
  const normalizedRuns = Array.isArray(runs) ? runs : [];
  const expectedRunIndexes = ['01', '02', '03'];

  if (branch !== REQUIRED_R1F_BRANCH) failures.push(`branch ${branch}`);
  if (!validatedHead) failures.push('validated HEAD missing');
  if (!acceptedImplementationIsAncestor) {
    failures.push(`accepted implementation ${acceptedImplementationSha} is not an ancestor of ${validatedHead}`);
  }
  if (normalizedRuns.length !== 3) failures.push(`expected three R1F runs, got ${normalizedRuns.length}`);

  const observedIndexes = normalizedRuns.map(run => String(run?.run_index || ''));
  for (const expectedIndex of expectedRunIndexes) {
    if (observedIndexes.filter(index => index === expectedIndex).length !== 1) {
      failures.push(`run index ${expectedIndex} missing or duplicated`);
    }
  }

  const sources = normalizedRuns.map(run => String(run?.source_sha || '')).filter(Boolean);
  const branches = normalizedRuns.map(run => String(run?.branch || '')).filter(Boolean);
  if (sources.length !== normalizedRuns.length) failures.push('one or more runs are missing source_sha');
  if (branches.length !== normalizedRuns.length) failures.push('one or more runs are missing branch');
  if (branches.some(runBranch => runBranch !== REQUIRED_R1F_BRANCH)) failures.push('one or more runs use the wrong branch');

  const uniqueSources = [...new Set(sources)];
  if (uniqueSources.length > 1) failures.push(`mixed evidence source SHAs: ${uniqueSources.join(', ')}`);
  const evidenceSourceSha = uniqueSources.length === 1 ? uniqueSources[0] : null;
  const evidenceSourceIsCurrentHead = Boolean(evidenceSourceSha && evidenceSourceSha === validatedHead);
  const normalizedChangedPaths = descendantChangedPaths.map(normalizeGitPath).filter(Boolean);
  let descendantPathsAllowed = evidenceSourceIsCurrentHead;

  if (evidenceSourceSha && !evidenceSourceIsCurrentHead) {
    if (!evidenceSourceIsAncestor) {
      failures.push(`evidence source ${evidenceSourceSha} is not an ancestor of ${validatedHead}`);
    }
    if (!acceptedImplementationIsAncestorOfEvidence) {
      failures.push(`accepted implementation ${acceptedImplementationSha} is not an ancestor of evidence ${evidenceSourceSha}`);
    }
    const rejectedPaths = normalizedChangedPaths.filter(path => !isAllowedR1FDocumentationDescendantPath(path));
    descendantPathsAllowed = rejectedPaths.length === 0;
    for (const rejectedPath of rejectedPaths) failures.push(`descendant path not allowed: ${rejectedPath}`);
  }

  if (!evidenceSourceSha) descendantPathsAllowed = false;

  return {
    branch,
    validatedHead,
    acceptedImplementationSha,
    evidenceSourceSha,
    acceptedImplementationIsAncestor: Boolean(acceptedImplementationIsAncestor),
    evidenceSourceIsCurrentHead,
    evidenceSourceIsAncestor: evidenceSourceIsCurrentHead || Boolean(evidenceSourceIsAncestor),
    acceptedImplementationIsAncestorOfEvidence:
      evidenceSourceIsCurrentHead
        ? Boolean(acceptedImplementationIsAncestor)
        : Boolean(acceptedImplementationIsAncestorOfEvidence),
    descendantChangedPaths: normalizedChangedPaths,
    descendantPathsAllowed,
    runIndexes: observedIndexes,
    failures,
    passed: failures.length === 0,
  };
}
