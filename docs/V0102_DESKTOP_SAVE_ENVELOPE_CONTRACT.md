# v0.102 Desktop Save Envelope Contract

Status: proposed contract proof only. This is not wired into browser runtime or desktop persistence.

## Proposed Envelope

Future desktop experiments may wrap normalized browser-compatible saves in this shape:

```text
profileSlot
createdAt
updatedAt
engineBuildVersion
contentVersion
saveVersion
checksum
sourceRuntime
migrationHistory
payload
quarantine
```

## Field Intent

- `profileSlot`: stable fixture/profile slot name, not a browser localStorage key.
- `createdAt` / `updatedAt`: normalized save timestamps.
- `engineBuildVersion`: future engine build identifier.
- `contentVersion`: stable content-export checkpoint, currently v0.101.
- `saveVersion`: browser save version after normalization, currently `2`.
- `checksum`: deterministic hash of the envelope proof payload before the checksum field is attached.
- `sourceRuntime`: current source runtime label, `browser-localStorage-prototype`.
- `migrationHistory`: records V1 to V2 migration or V2 normalization.
- `payload`: normalized current browser save payload.
- `quarantine`: unknown IDs, unsafe fields, or rejection reasons requiring human/engine review.

## Non-Goals

- No browser runtime import/export UI.
- No file-system save path.
- No profile-slot implementation.
- No desktop engine save implementation.
- No save-version bump.
- No migration of real user saves.

