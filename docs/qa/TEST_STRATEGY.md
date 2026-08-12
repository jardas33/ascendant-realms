# Test strategy

## Order of confidence

1. pure unit tests for rules, view models, serialization, and deterministic simulation;
2. focused scenario tests for the changed system;
3. build/typecheck;
4. content, art-intake, and runtime-slot validation when relevant;
5. layout and visual QA at supported resolutions;
6. one normal headed rehearsal without debug overlays controlling play;
7. full e2e/release or Godot validation only when the changed lane requires it.

## Common commands

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run validate:runtime-art-slots
npm run visual:qa
git diff --check
```

Godot commands are opt-in and named under `package.json`; use the narrowest relevant validator before `npm run godot:all`. Do not run a broad expensive lane merely to create activity.

## Failure policy

Record the command, exit code, first meaningful error, affected files, and whether the failure is code, environment, evidence, or scope. Never turn a failed headed run into a passing title card.
