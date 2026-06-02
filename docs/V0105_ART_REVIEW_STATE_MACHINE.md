# v0.105 Art Review State Machine

Status: validation contract for candidate review. It does not approve runtime integration.

## States

| State | Meaning |
| --- | --- |
| `not-created` | Registry entry or workspace template exists, but no candidate image exists. |
| `candidate-ready` | Candidate image and required source/license/prompt/protected-IP metadata exist for human review. |
| `style-approved` | Human reviewer approves the candidate as reference-only visual direction. |
| `revision-requested` | Human reviewer requests a revised candidate or prompt adjustment. |
| `rejected` | Candidate must not be used. Rejection reason is required. |
| `runtime-candidate-approved` | Candidate may enter a future runtime integration milestone, but is still not integrated. |
| `runtime-integrated` | Only valid after a separate future runtime integration proof and approval exist. |

## Progression Rules

- `not-created` may have template metadata with empty source/tool/model fields.
- `candidate-ready` and later states require candidate files, source tool, model, generated-by, source type, clear license terms, prompt version, and protected-IP assessment.
- `style-approved` still requires `reference-only:not-runtime` posture.
- `revision-requested` keeps the candidate non-runtime until a revision returns to review.
- `rejected` requires `rejectionReason`.
- `runtime-candidate-approved` requires `future-runtime-candidate:not-integrated` posture and `ready-for-future-runtime-integration-gate`.
- `runtime-integrated` requires future integration proof, future integration approver, and `integrated-by-future-runtime-gate`.

## Hard Blocks

Validation rejects:

- missing asset ID;
- unknown asset ID;
- duplicate registry asset ID;
- missing prompt version;
- unclear, unknown, or TBD license terms after candidate creation;
- missing protected-IP assessment after candidate creation;
- high or unknown protected-IP risk after candidate creation;
- `style-approved` with runtime-ready posture;
- `runtime-integrated` without future integration proof.

## Reference-Only Boundary

The state machine deliberately separates style approval from runtime integration. A good-looking candidate can be `style-approved` and still remain non-runtime until a later milestone handles cropping, scaling, runtime asset paths, source/license proof, visual QA, build validation, and package posture.
