# v0.102 Unknown ID And Corruption Policy

Status: active for fixture validation and the translation-contract proof.

## Unknown Content IDs

Unknown content IDs are not silently renamed. The proof reports them with:

- path;
- id;
- expected stable-ID categories.

Examples include future class IDs, future item IDs, future node IDs, future modifier IDs, and future enemy hero IDs.

Accepted browser saves can still be translated with quarantine when the current runtime normalization accepts them. A future desktop import gate should require human review before treating quarantined IDs as usable content.

## Unsafe Extra Fields

Fields outside the browser save contract are quarantined as dropped-by-normalization fields. Examples include unknown top-level objects, unknown hero fields, unknown campaign fields, or unknown resource keys.

The current browser runtime already ignores these fields through normalization. v0.102 documents that future desktop translation must not treat them as trusted persisted data without an explicit schema decision.

## Corrupt Or Unsupported Saves

The contract rejects:

- corrupt JSON;
- missing required save objects;
- unsupported future save versions.

Rejected fixtures do not produce a desktop envelope.

## Prohibited Behavior

- Do not auto-map display copy to stable IDs.
- Do not invent fallback desktop content for unknown IDs.
- Do not mutate real saves during translation testing.
- Do not bump `CURRENT_SAVE_VERSION` for this proof.
- Do not preserve unsafe fields except inside quarantine review records.

