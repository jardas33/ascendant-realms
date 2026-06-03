# v0.112 Parity Report

Gameplay semantics changed: false.
Saves changed: false.
Stable IDs changed: false.
Pathing outputs changed: false.
AI decision rules changed: false.
linked_ward damageTakenMultiplier: 0.92.

| Check | Status | Evidence |
| --- | --- | --- |
| positions-health-deaths-captures-resources-results | pass | Browser idle matrix keeps save snapshots unchanged before and after each private scenario. |
| ai-pathing-replay-posture | pass | v0.112 does not change AI decisions, path search outputs, replay state, or launch fixtures. |
| lume-linked-ward | pass | Unit test asserts linked_ward damageTakenMultiplier remains exactly 0.92. |
| saves-stable-ids | pass | No save schema, stable ID, content, art, or package metadata field is changed by runtime code. |
