# v0.125 Player-Slice Issue Ledger

The v0.125 audit first captured the existing v0.124 screenshot reports as the before state, then refreshed the player-slice capture after safe presentation fixes.

Resolved issues:

- Title copy used the engineering phrase `Private visual-review slice`.
- Title lacked deterministic proof that battle HUD/minimap chrome was hidden.
- Briefing lacked deterministic proof that battle HUD/minimap chrome was hidden.
- Battle lacked deterministic proof that compact player HUD visibility was correct.
- Battle lacked deterministic proof of useful terrain viewport coverage.
- Battle lacked deterministic proof that player selection feedback avoided fixture IDs.
- Results lacked deterministic proof that battle HUD/minimap chrome was hidden.

Open issues: none.

Deferred issues: none.

The machine-readable ledger is generated at:

```text
artifacts/desktop-spikes/godot-salto/v0125/issue-ledger.json
```

All corrections stayed inside player-facing presentation shell scope.
