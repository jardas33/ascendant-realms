# v0.138 Reference Metadata Schema

Status: reference-only metadata schema. Runtime integration is forbidden.

## Metadata Location

Candidate metadata lives in the ignored workspace:

`artifacts/art-review/v0138/metadata/<candidateId>.json`

The tracked validator is:

`tools/art-reference/validateReferenceArt.ts`

The tracked JSON schema reference is:

`tools/art-reference/referenceCandidate.schema.json`

## Required Fields

| Field | Requirement |
| --- | --- |
| `schemaVersion` | Must be `1`. |
| `candidateId` | Stable local candidate ID. |
| `briefId` | One of the four v0.138 brief IDs. |
| `purpose` | Why the candidate exists. |
| `generator` | Tool or provider used externally. |
| `model` | Model name or version. |
| `date` | YYYY-MM-DD generation or intake date. |
| `source` | Source type, prompt document, optional candidate image path, and notes. |
| `licencePosture` | Licence status, terms, runtime-use posture, and notes. |
| `protectedIpReview` | Protected-IP status, lookalike risk, and notes. |
| `visualNotes` | Non-empty list of visual review notes. |
| `humanStatus` | Human review state. |
| `runtimeIntegrationStatus` | Must be exactly `forbidden`. |
| `hash` | SHA-256 hash of the candidate file when present. |
| `dimensions` | Pixel width and height. |
| `aspect` | Intended or verified aspect ratio. |
| `revisionLineage` | Parent candidate, revision number, and notes. |

## JSON Template

```json
{
  "schemaVersion": 1,
  "candidateId": "v0138-env-a",
  "briefId": "V0138_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME",
  "purpose": "Reference-only Salto 2.5D environment style review.",
  "generator": "external-gpt-image-generation",
  "model": "record exact model name",
  "date": "2026-06-06",
  "source": {
    "type": "generated-reference",
    "promptDocument": "docs/art-prompts/V0138_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md",
    "candidateImagePath": "artifacts/art-review/v0138/candidates/v0138-env-a.png",
    "notes": "Generated from the v0.138 prompt without external source images."
  },
  "licencePosture": {
    "status": "user-controlled-reference",
    "terms": "Reference review only.",
    "runtimeUse": "forbidden",
    "notes": "No runtime rights are granted in v0.138."
  },
  "protectedIpReview": {
    "status": "pending",
    "protectedLookalikeRisk": "unknown",
    "notes": "Human review required before shortlisting."
  },
  "visualNotes": [
    "Describe readability, originality, landmarks, silhouettes, and concerns."
  ],
  "humanStatus": "pending-review",
  "runtimeIntegrationStatus": "forbidden",
  "hash": {
    "algorithm": "sha256",
    "value": "replace with file hash"
  },
  "dimensions": {
    "width": 1920,
    "height": 1080,
    "unit": "px"
  },
  "aspect": "16:9",
  "revisionLineage": {
    "parentCandidateId": null,
    "revision": 1,
    "notes": "First candidate from this brief."
  }
}
```

## Validation Behavior

- Empty `candidates/` and `metadata/` folders produce `PENDING_V0138_REFERENCE_ART_CANDIDATES`.
- Candidate images without metadata fail validation.
- Metadata with `runtimeIntegrationStatus` other than `forbidden` fails validation.
- If `source.candidateImagePath` is present, the validator checks file presence, SHA-256 hash, and readable PNG/JPEG dimensions.
- WebP candidates are accepted for contact sheets, but dimensions may require manual metadata review.

## Runtime Boundary

This metadata is not a runtime registry. It must not be read by Godot, browser runtime, save systems, asset manifests, stable-ID registries, or build packaging as production art.
