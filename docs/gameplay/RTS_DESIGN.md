# RTS design contract

## Core loop

Orient on the map, select a hero/unit/building, issue an order, read the response, manage resources and queues, respond to pressure, and convert the result into campaign progress. Commands must be understandable at the moment of issue and after resolution.

## Interaction contracts

- selection is visibly scoped to the intended entity;
- movement and attack-move use conventional RTS input and show an order marker or equivalent feedback;
- a disabled action explains its reason;
- production and construction expose progress and completion;
- rally points are visible and do not silently redirect units;
- minimap clicks and camera movement respect world bounds;
- results and replay actions do not leave stale battle identity.

## Scope discipline

Balance, content, saves, stable IDs, AI, and art are separate concerns. A presentation repair must not silently change rules. A gameplay repair must include focused behavioral proof before visual polish.
