# V0363 BARROSAN BARN R0 / R1 / R2 EVIDENCE BOARD REPAIR

## Scope

Evidence-only repair after human review of v0.362. Board 07 was the sole rejected artifact. No Barn placement, canonical asset, runtime fixture, gameplay system, benchmark, or validation rule was changed.

## Authority and accepted placement

Branch: codex/v0215-v0226-recovery. Accepted base: faa240784fef1898e3710500275dae4f018bb169. The human-approved Barn root remains (4.000, 0.180, -1.000), with structural clearance 2.480, roof/eave clearance 2.510, and required worker clearance 1.875. Canonical source hash is 13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3. Frozen roof hash is 0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9.

## Defect and repair

The former Board 07 title promised DEFAULT, OPT-IN AND EXACT ROLLBACK but displayed DEFAULT, ROLLBACK R0 and ROLLBACK R2. This checkpoint regenerates the board from three actual non-headless Godot states using the existing v0.362 review scene and rollback sequence. The centre panel is now the actual R1 frame with exactly one canonical Barn.

## Capture truth

The three panels use one orthographic RTS camera, one viewport, one lighting setup and one unchanged world fixture. R0 contains zero Barns, R1 contains one Barn, and R2 contains zero Barns. Raw R0 and R2 hashes match; R1 differs from both. R0 and R2 state signatures match; R1 differs. The R1 root is visibly present at ordinary RTS distance and the board footer reports the machine truth.

## Retention and isolation

Boards 01-06 and 08 are retained byte-for-byte from v0.362. Only Board 07, the upload README, compact summary and this report are v0.363 documentary outputs. No performance benchmark was rerun. The v0.362 canonical scene, measurement, fail-closed cases, mutation ledger and accepted placement remain authoritative.

## Validation and delivery

Dedicated validator: npm run godot:validate:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair. Capture and pack commands are recorded in the upload README. The retained v0.362 validator, tests, build, content/art/runtime/artifact checks, Godot all pass and exact-SHA CI are recorded at closeout.

Review pack: artifacts/manual-review/v0363-barrosan-barn-r0-r1-r2-evidence-board-repair/UPLOAD_TO_CHAT/

<!-- V0363_R0_R1_R2_BEGIN -->
{
    "schemaVersion":  1,
    "checkpoint":  "v0.363",
    "sourceCheckpoint":  "v0.362",
    "scenePath":  "res://scenes/review/V0362BarrosanBarnContextualPlacementSeparation.tscn",
    "captureMode":  "non-headless Godot runtime rollback sequence",
    "genuineNonHeadlessCaptures":  true,
    "panelCount":  3,
    "r0":  {
               "barnRootCount":  0,
               "cameraPosition":  {
                                      "x":  -26.0,
                                      "y":  16.0,
                                      "z":  30.0
                                  },
               "cameraRotation":  {
                                      "x":  -20.9108734130859,
                                      "y":  -46.548152923584,
                                      "z":  0.0
                                  },
               "cameraTarget":  {
                                    "x":  2.5,
                                    "y":  1.0,
                                    "z":  3.0
                                },
               "frameNumberAfterCameraTransition":  7,
               "house02Count":  1,
               "orthographicSize":  36.0,
               "panelId":  "v0363-board07_r0",
               "projectionType":  "orthographic",
               "rawCapturePath":  "D:/Code for projects/WB game like/ascendant-realms-v0223-recovery/artifacts/runtime/v0363/board07/screenshots/r0.png",
               "rawCaptureSha256":  "dca0980d8a3f1e3e2c12a7db72bccf212df68986289f5ae6ac55ca5b72f2143d",
               "sceneStateSignature":  "9bcd99953af16716425b157cdfbfc9630ca0bfe60ed1bccea489f61639414af4",
               "semanticPurpose":  "R0 deterministic baseline; Barn count 0",
               "settleFrames":  8,
               "timestampSequence":  1,
               "viewportHeight":  1009,
               "viewportWidth":  1920
           },
    "r1":  {
               "barnRootCount":  1,
               "cameraPosition":  {
                                      "x":  -26.0,
                                      "y":  16.0,
                                      "z":  30.0
                                  },
               "cameraRotation":  {
                                      "x":  -20.9108734130859,
                                      "y":  -46.548152923584,
                                      "z":  0.0
                                  },
               "cameraTarget":  {
                                    "x":  2.5,
                                    "y":  1.0,
                                    "z":  3.0
                                },
               "frameNumberAfterCameraTransition":  15,
               "house02Count":  1,
               "orthographicSize":  36.0,
               "panelId":  "v0363-board07_r1",
               "projectionType":  "orthographic",
               "rawCapturePath":  "D:/Code for projects/WB game like/ascendant-realms-v0223-recovery/artifacts/runtime/v0363/board07/screenshots/r1.png",
               "rawCaptureSha256":  "159b260b5f784340bc3c8b88e14a3bcea19fa13736617a157d68e1ec78e295ad",
               "sceneStateSignature":  "b8d27628fea08d307300490685546f348ec4394f819490dcd094a5d6090b24f7",
               "semanticPurpose":  "R1 canonical Barn loaded once; Barn count 1",
               "settleFrames":  8,
               "timestampSequence":  2,
               "viewportHeight":  1009,
               "viewportWidth":  1920
           },
    "r2":  {
               "barnRootCount":  0,
               "cameraPosition":  {
                                      "x":  -26.0,
                                      "y":  16.0,
                                      "z":  30.0
                                  },
               "cameraRotation":  {
                                      "x":  -20.9108734130859,
                                      "y":  -46.548152923584,
                                      "z":  0.0
                                  },
               "cameraTarget":  {
                                    "x":  2.5,
                                    "y":  1.0,
                                    "z":  3.0
                                },
               "frameNumberAfterCameraTransition":  24,
               "house02Count":  1,
               "orthographicSize":  36.0,
               "panelId":  "v0363-board07_r2",
               "projectionType":  "orthographic",
               "rawCapturePath":  "D:/Code for projects/WB game like/ascendant-realms-v0223-recovery/artifacts/runtime/v0363/board07/screenshots/r2.png",
               "rawCaptureSha256":  "dca0980d8a3f1e3e2c12a7db72bccf212df68986289f5ae6ac55ca5b72f2143d",
               "sceneStateSignature":  "9bcd99953af16716425b157cdfbfc9630ca0bfe60ed1bccea489f61639414af4",
               "semanticPurpose":  "R2 Barn removed; rollback complete",
               "settleFrames":  8,
               "timestampSequence":  3,
               "viewportHeight":  1009,
               "viewportWidth":  1920
           },
    "r0BarnRootCount":  0,
    "r1BarnRootCount":  1,
    "r2BarnRootCount":  0,
    "r0RawCaptureHash":  "dca0980d8a3f1e3e2c12a7db72bccf212df68986289f5ae6ac55ca5b72f2143d",
    "r1RawCaptureHash":  "159b260b5f784340bc3c8b88e14a3bcea19fa13736617a157d68e1ec78e295ad",
    "r2RawCaptureHash":  "dca0980d8a3f1e3e2c12a7db72bccf212df68986289f5ae6ac55ca5b72f2143d",
    "r0R2RawCaptureMatch":  true,
    "r0R1RawCaptureDistinct":  true,
    "r1R2RawCaptureDistinct":  true,
    "r0StateSignature":  "9bcd99953af16716425b157cdfbfc9630ca0bfe60ed1bccea489f61639414af4",
    "r1StateSignature":  "b8d27628fea08d307300490685546f348ec4394f819490dcd094a5d6090b24f7",
    "r2StateSignature":  "9bcd99953af16716425b157cdfbfc9630ca0bfe60ed1bccea489f61639414af4",
    "r0R2StateSignatureMatch":  true,
    "r0R1StateSignatureDistinct":  true,
    "cameraMatch":  true,
    "benchmarkRerunCount":  0,
    "placementMutationCountThisCheckpoint":  0,
    "canonicalAssetMutationCountThisCheckpoint":  0
}
<!-- V0363_R0_R1_R2_END -->

READY FOR HUMAN V0363 BARROSAN BARN R0-R1-R2 EVIDENCE BOARD REVIEW