# v0.86 Notification Priority Spec

## Goal

Battlefield notifications should communicate urgency without letting routine command chatter obscure critical alerts.

## Categories

- Critical: pressure, danger, or high-urgency events. These may replace lower-priority messages and receive the strongest styling.
- Important: objective and mission-relevant updates. These are visible but less aggressive than critical alerts.
- Routine: command confirmations and ordinary feedback. These are compact, short-lived, and deduplicated.
- Debug: private diagnostic messages. These stay hidden unless an explicit debug posture enables them.

## Rules

- Higher-priority messages replace lower-priority messages.
- Routine messages do not replace active important or critical messages.
- Repeated routine messages are deduplicated over a short window.
- Routine command confirmations are shortened where safe.
- No simulation state changes are driven by notification priority.

## Deferrals

- No persistent notification log.
- No new debug console.
- No audio or art treatment.
