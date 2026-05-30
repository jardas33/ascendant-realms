# v0.80 Test And Rollback Plan

Status: docs-only test plan for v0.80 and future copy batches.

## v0.80 Required Verification

Run from the repository root:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts
node -e "JSON.parse(require('fs').readFileSync('docs/V080_RUNTIME_FACING_STRING_INVENTORY.json','utf8')); console.log('v0.80 inventory JSON valid')"
npm run package:playtest
npm run verify:playtest-package
git diff --check
```

The JSON parser command is required because the inventory is machine-readable and should fail fast if it is malformed.

## Future Runtime Copy Batch Tests

Minimum for any future display-copy migration:

- `npm test`.
- `npm run build`.
- `npm run validate:content`.
- `npm run validate:art-intake`.
- old-save/load tests for any affected save-adjacent labels.
- focused package validation if package docs or build info changes.
- package generation and package verification.
- `git diff --check`.

Add browser or hosted coverage only when visible runtime UI changes are actually made:

- title/menu copy: fast smoke or focused main-menu browser test;
- campaign node copy: campaign map UI test;
- resource/site copy: battle HUD or campaign node test;
- Results copy: focused Results test;
- Tutorial copy: Tutorial smoke if no-reward copy changes.

## Rollback Rule

Each future copy migration should be one small commit or one clearly isolated patch. Rollback should be:

```text
git revert <copy-migration-commit>
```

Do not require save repair if the batch followed the v0.80 rule: display strings only, stable IDs unchanged.

## Non-Rollbackable Work To Avoid

Do not bundle any of the following into a display-copy batch:

- internal ID rename;
- save field rename;
- localStorage key rename;
- package/repo rename;
- new runtime systems;
- Lume Network behavior;
- gameplay tuning;
- asset import;
- generated art;
- desktop/engine work.

If any of those are required later, they need a separate migration and rollback plan.

## Specific Save Safety Checks

Future tests should prove:

- old saves with `free_marches`, `ashen_covenant`, `aether`, current class IDs, item IDs, node IDs, and relic IDs still load;
- missing/unknown display aliases do not corrupt saves;
- package build info reports the final commit and `workingTreeDirty: false` for clean packages;
- Tutorial/no-reward routes remain no-save/no-reward after copy changes.
