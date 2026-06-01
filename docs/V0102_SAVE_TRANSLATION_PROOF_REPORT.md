# v0.102 Save Translation Proof Report

Status: implemented and passing in the focused proof command.

## Command

```bash
npm run test:save-translation-contract
```

The command:

- loads `tests/fixtures/saves/v0102/manifest.json`;
- reads each fictional fixture;
- normalizes accepted saves with existing migration rules;
- wraps accepted saves in the proposed envelope for proof only;
- validates save content IDs against `src/game/portable/stable-id-snapshot.json`;
- reports unknown IDs and unsafe fields into quarantine records;
- rejects corrupt JSON, missing required save objects, and unsupported future versions;
- runs twice and compares deterministic report output;
- writes ignored review artifacts under `artifacts/save-translation-contract/latest/`.

## Latest Focused Result

```text
PASS
Fixtures: 16
Translated: 11
Translated with quarantine: 2
Rejected: 3
Unknown content ids reported: 17
Unsafe fields quarantined: 4
Output: artifacts/save-translation-contract/latest
```

## Runtime Safety

The proof command imports pure migration/normalization helpers and does not use `SaveSystem`, `SAVE_KEY`, or localStorage. It does not overwrite browser saves, create a desktop save path, or add persistence behavior.

## Determinism

The proof command builds two in-process reports from the same fixture inputs and stable-ID snapshot. The command fails if the serialized reports differ byte-for-byte.

