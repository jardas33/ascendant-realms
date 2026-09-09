# Ascendant Realms — Pale perimeter visual remediation R3

Status: `CANDIDATE_PALE_PERIMETER_R3_HUMAN_REVIEW_REQUIRED`

This packet records a quarantined visual experiment only. No candidate was
committed, promoted, pushed, merged, rebased, or integrated.

## Frozen state

- Authoritative baseline: `8bd0f417ae5d30174b67881c495d17fe3f3b2172`
- Frozen animation candidate: `195b4b2a6443dabebfbd557ea64d4f8a29ed7a17`
- Protected canonical: `b9812797bba626a3b51e0b79739bc6e2cdf0bca4`
- Capture: Godot 4.6.3 Forward+, 1920x1080, default zoom 40, pitch -55.

## Target and diagnosis

The target is the settlement-adjacent `highland_dry_stone_wall_module.glb`
placement owned by `hollowspan_environment_composition.gd`, resolving from
the first Hollowspan start to `(-70, 0, -92)`, yaw `-0.18`, normalized height
`4.2`. The asset is presentation-only and has no collision, navigation,
camera-bound, spawn, save, or stable-ID responsibility.

Baseline visual inspection: the target reads as an authored dry-stone asset
but presents as a conspicuous pale prototype slab; its exposed surface and
4.2 m height dominate the settlement edge and compete with the Clanhold,
War Hall, and nearby units. The independent material trace identifies the
embedded `Barrosan Slate Stone` response as a secondary value mismatch.

## Candidate results

1. Candidate A, transform-only: retain the target placement and lower its
   normalized display height to `2.8`. This reduced dominance, but the wall
   remained a detached pale slab at the right frame edge.
2. Candidate B, one material response: retain Candidate A and apply an
   instance-local darker slate response. This corrected the value mismatch,
   but the remaining clipped wall silhouette was still not commercially
   convincing.
3. Selected remediation direction: remove only the offending placement from
   the composition list. The asset file and the separate outer-band wall
   placement remain untouched. The target instance disappears in the matched
   render and the settlement gains clear negative space.

The removal is the strongest visual result, but a separate outer-band wall is
still visible at the far frame edge. Therefore the scene-wide Emanuel complaint
is classified `PARTIALLY_RESOLVED`, not falsely marked fully resolved. Human
visual classification is required before any promotion decision.

## Result and boundary

- Target offending instance visible after removal: `false`.
- Separate outer-band wall remains: `true`.
- Target placement removed in experiment: `true`.
- Asset deleted or re-exported: `false`.
- Gameplay semantics changed: `false`.
- Production source restored byte-for-byte after capture: `true`.
- Final worktree production diff: `none`.

Evidence PNGs are the four matched-context renders in this directory; no video
or new capture subsystem was created.

Terminal: `CANDIDATE_PALE_PERIMETER_R3_HUMAN_REVIEW_REQUIRED`
