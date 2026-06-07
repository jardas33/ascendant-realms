# V0159 Player-Slice Integration Risk Register

Status: risk register for the future v0.160 Worker-only opt-in experiment. v0.159 does not integrate art.

| Risk | Likelihood | Severity | Mitigation | Future v0.160 validation | Rollback |
| --- | --- | --- | --- | --- | --- |
| Local candidate missing on reviewer machine | Medium | Medium | Hash-gated opt-in loader must fall back procedurally | Missing-file opt-in capture and diagnostic evidence | Remove or ignore opt-in launcher; default launcher already procedural |
| Candidate hash mismatch | Medium | High | Require exact SHA-256 before use | Hash-mismatch diagnostic and fallback proof | Remove local candidate or disable opt-in flag |
| Alpha edge or matte halo visible in player slice | Medium | Medium | Start with Worker only, capture dark/light terrain edges | Edge captures at normal and zoomed distances | Revert to procedural Worker fallback |
| Pivot or scale drift | Medium | High | Use fixed metadata and compare against procedural anchor | Selection ring, assignment, mine-work, and group captures | Remove opt-in Worker adapter |
| Worker crowd overlap reduces readability | Medium | Medium | Test repeated Worker groups before any second slot | Crowd and task-state captures | Keep procedural Worker default |
| Default launcher accidentally changes | Low | High | Keep v0.160 behind a separate launcher and test default launchers | Default launcher text scan plus default capture | Delete opt-in launcher/flag changes |
| Browser runtime receives Godot-only art path | Low | High | Keep integration in Godot path only | Browser source scans and package scans | Revert any browser path mutation |
| Production manifests or packages include ignored local art | Low | High | Keep local art ignored and hash-loaded only by opt-in path | Manifest/package scans | Remove manifest/package references |
| Save or stable-ID mutation slips in | Low | High | Treat art loading as visual-only and session-only | Save/stable-ID scans and tests | Revert save/stable-ID changes |
| Gameplay behavior changes while testing visual art | Low | High | Do not touch objectives, commands, AI, balance, or units | Functional smoke focused on existing Worker flow | Revert gameplay files |
| Performance regression from texture loading | Medium | Medium | Load once, cache once, compare fallback and opt-in | FPS/p95 capture and cache/fair-path evidence | Disable opt-in path |
| Human review mistakes private-comparator approval for production approval | Medium | Medium | Keep docs explicit: opt-in proof is not final art approval | Emmanuel review guide decision checklist | Stop after review packet |
| Final engine decision appears implied | Medium | High | State that Godot remains a spike/review path, not final engine choice | Handoff and release-checklist wording | Correct docs and stop |

## Current Risk Posture

The Worker slot is the safest first proof, but it still crosses the private-comparator-to-player-slice boundary. v0.160 should therefore use an opt-in launcher, diagnostic proof, and explicit rollback before any second slot is considered.
