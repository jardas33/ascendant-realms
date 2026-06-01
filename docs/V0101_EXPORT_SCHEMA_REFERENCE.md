# v0.101 Export Schema Reference

The portable export schema version is `1`.

## `content-export.json`

Top-level fields:

| Field | Meaning |
| --- | --- |
| `schemaVersion` | Portable export schema version. |
| `checkpoint` | Checkpoint that owns the contract. |
| `authority` | Always `typescript-source`. |
| `runtimeBehavior` | Always `unchanged-downstream-export`. |
| `ordering` | Deterministic ordering guarantee. |
| `categories` | Category map containing stable entries. |

Each category entry contains:

| Field | Meaning |
| --- | --- |
| `id` | Stable exported id. |
| `displayName` | Human-readable source label. |
| `sourceFile` | Repository-relative TypeScript source file. |
| `serializedPosture` | `stable-id`, `derived-reference`, or `rules-reference`. |
| `data` | Sorted JSON-safe source data. |

## `stable-id-manifest.json`

The stable manifest is optimized for audit and future engine spikes:

| Field | Meaning |
| --- | --- |
| `id` | Stable exported id. |
| `category` | Export category. |
| `sourceFile` | Repository-relative source file. |
| `displayName` | Player-facing or editor-facing label. |
| `serializedPosture` | Stability posture for the id. |
| `referenceCount` | Count of matching string references inside the export. |
| `exportHash` | SHA-256 hash of the stable serialized entry data. |

## `content-export-hashes.json`

Records SHA-256 hashes for each generated file and each category payload. It allows later scripts to detect accidental nondeterminism or changed export shape without treating generated artifacts as source.

## `content-export-summary.md`

Human-readable count and hash summary for quick review.

## Compatibility Notes

- Source paths are repository-relative, never absolute.
- No timestamps are emitted.
- Object keys are sorted.
- Category entries are sorted by id.
- Arrays preserve authored order unless the exporter explicitly derives a category sorted by id.
