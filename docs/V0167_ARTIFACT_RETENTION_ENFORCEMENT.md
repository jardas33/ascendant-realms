# v0.167 Artifact Retention Enforcement

Status: `PASS_V0167_ARTIFACT_RETENTION`

Added:

- `docs/SALTO_EXPERIMENTAL_ARTIFACT_INDEX.md`
- `scripts/validateSaltoExperimentalArtifactRetention.mjs`
- `GODOT_VALIDATE_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION_WINDOWS.bat`
- `npm run godot:validate:salto-experimental-artifact-retention`

Rules enforced:

- Selected active Worker, Barracks, and Militia derivatives must exist and match their approved hashes.
- Selected future Aster and Ashen derivatives must remain preserved but are not integrated by v0.167.
- Required metadata beside selected derivatives must exist.
- Tracked fallbacks must exist and remain tracked.
- Latest v0.166/v0.167 evidence is retained.
- Known Godot-generated sidecars are safe-delete candidates only through explicit safe-only cleanup.
- Unknown cleanup-scope files fail closed.

Documentation budget:

- one implementation report;
- one review/QA report;
- one benchmark/audit report;
- one boundary report;
- extra artifact-index doc because it protects cleanup decisions.
