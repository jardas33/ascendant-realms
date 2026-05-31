# v0.89 Visual QA Report

Checkpoint: v0.89 Controlled Display-Copy Migration Batch A

## QA Focus

- Confirm the campaign Map tab uses Salto Outskirts for the first node while preserving the `border_village` test hook.
- Confirm Chapter 1 displays as The Barrosan Marches.
- Confirm Aether Well Ruins remains unchanged and remains previewable when locked.
- Confirm ordinary Results use Salto Outskirts for the first campaign completion.
- Confirm Lume Surge appears only for the approved modifier/event label path.
- Confirm Mana, Aether resources, Aether Well, and Aether Lens copy remain readable and unchanged where intentionally deferred.

## Screenshot Evidence

`npm run visual:qa` remains the source of screenshot evidence. Expected relevant captures include:

- fresh campaign map at 1920x1080,
- locked Aether Well preview,
- private Lume demo HUD/results preservation,
- normal Results information architecture screenshots.

## Result

PASS on 2026-05-31.

Command:

```text
npm run visual:qa
```

Result:

```text
6 tests passed.
36 screenshots captured.
Browser console errors: 0.
Screenshot retries: 0.
Output directory: visual-qa/latest.
```

No visual QA capture showed a save, reward, gameplay, or art-pipeline change. v0.89 remains copy-only.
