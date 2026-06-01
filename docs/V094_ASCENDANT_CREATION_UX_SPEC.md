# v0.94 Ascendant Creation UX Spec

## Purpose

Make hero creation scannable within seconds while preserving all hero rules, class ids, origin ids, save fields, and campaign launch behavior.

## Staged Layout

Default layout:

```text
Step 1 - Choose Class
Step 2 - Choose Origin
Step 3 - Review Hero
[ Begin Campaign ]
```

## Class Cards

Each class should show:

- name;
- one-line fantasy from the existing description;
- three compact gameplay traits;
- one concise drawback;
- selected state;
- More Details disclosure for longer stat and ability prose.

## Origin Cards

Each origin should show:

- name;
- one-line fantasy from the existing description;
- three compact gameplay traits;
- one concise drawback where useful;
- selected state;
- More Details disclosure for longer origin prose.

## Review Panel

The review panel should show:

- current class;
- current origin;
- hero name field;
- compact trait reminder;
- obvious Begin Campaign action.

## Non-Goals

- No hero rule changes.
- No class id or origin id changes.
- No race additions.
- No save migration.
- No new art.

## Acceptance

- Selected class and selected origin are visually obvious.
- Comparison is possible without reading a prose wall.
- Begin Campaign remains visible at 1366x768.
- Existing creation tests and campaign start behavior continue to pass.
