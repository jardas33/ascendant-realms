# v0.101 Content Reuse Roundtrip Plan

This plan keeps the current browser prototype as the authoritative development environment while preparing later engine experiments.

## Stage 1: Export From TypeScript

Use `npm run export:portable-content` to generate deterministic JSON under `artifacts/portable-content/latest/`. Treat the output as read-only evidence for engine experiments.

## Stage 2: Validate Stability

Use `npm run validate:portable-content` before any engine spike consumes the export. Validation confirms current TypeScript content, stable ids, references, hashes, and byte-for-byte determinism.

## Stage 3: Prototype Import Experiment

A future experiment may load `content-export.json` into a separate engine sandbox. The sandbox must record unsupported fields instead of deleting them. It must not write changes back into TypeScript.

## Stage 4: Roundtrip Audit

After an import experiment, compare:

- category counts;
- stable id lists;
- display labels;
- references;
- reward and mission metadata;
- map/site ids;
- Lume network ids;
- Retinue rule references.

Any mismatch is an experiment finding, not a reason to change the source schema automatically.

## Stage 5: Translation Design

Only after a proven import experiment should the project consider a translation layer for an engine-native format. That future layer should be generated from TypeScript and covered by snapshot tests.

## Deferred

- Save translation.
- Runtime data loading from JSON.
- Engine-native authored data.
- Desktop packaging.
- Multiplayer/content sync.
