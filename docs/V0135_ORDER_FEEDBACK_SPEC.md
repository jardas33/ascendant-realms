# v0.135 Order Feedback Spec

Status: `PASS_V0135_ORDER_FEEDBACK` after the headed RTS ergonomics proof.

The slice now provides restrained, recoverable command feedback:

- Move marker after a valid right-click terrain order.
- Attack marker after a valid right-click hostile order.
- Context-action marker for Worker-to-mine, Worker-to-Barracks, and Lume restore interactions.
- Invalid-order marker for no-selection or invalid-ground orders.
- Hover response and short tooltip for visible world targets.
- Selected-unit marker for normal selection.
- Selected-squad count when box-selecting defenders.

The feedback is intentionally compact. It avoids giant labels, developer jargon, and extra top-of-screen obstruction while preserving the existing placeholder-only visual boundary.
