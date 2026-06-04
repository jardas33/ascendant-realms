# v0.123 Emmanuel Godot Review Guide

Status: simple review guide for the existing Godot package and decision packet. This does not authorize a final engine choice or a port.

## One-Click Review

1. Double-click `GODOT_LAUNCH_REVIEW_WINDOWS.bat`.
2. Test 2D.
3. Test 2.5D clean.
4. Test 2.5D atmospheric.
5. Test Tier M.
6. Test Tier L stress briefly.
7. Record a short video.
8. Answer the review questions below.

## Review Questions

- Which mode looks more promising: 2D, 2.5D clean, or 2.5D atmospheric?
- Did controls feel immediate?
- Did Tier M feel smooth?
- Did Tier L remain usable during a brief stress look?
- Does the workflow feel easy enough for you, with Codex and scripts doing the heavy work?

## What To Ignore

- Do not judge final art quality. The current visuals are placeholders and procedural primitives.
- Do not treat the package as a full game port.
- Do not approve runtime art integration from this review.
- Do not choose Godot finally from this packet alone.

## What To Watch

- Unit and hero readability.
- Terrain and road readability.
- Lume endpoint and link readability.
- HUD and minimap posture.
- Camera comfort.
- Command feedback.
- Whether the 2.5D depth helps or hurts tactical clarity.

## Evidence Packet

Read these docs before giving the next direction:

- `docs/V0123_GODOT_CONTINUATION_GATE.md`
- `docs/V0123_GODOT_SCORECARD_UPDATE.md`
- `docs/V0123_UNITY_COMPARATOR_BOUNDARY.md`
- `docs/V0123_REFERENCE_ART_REVIEW_BOUNDARY.md`

Reference-art prompts live under:

```text
docs/art-prompts/
```

They are copy-ready prompts for external image generation, but they are reference-only and must not be imported into runtime.
