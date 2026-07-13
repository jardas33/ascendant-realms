# Worker supported-state matrix

| State | Runtime binding | H3/fallback | Result |
|---|---|---|---|
| idle/selected/unselected | `worker_00`, authoritative `runtime.units` | proxy/fallback follows same position | PASS |
| moving/stopped | `issue_move_order` and `_advance_movement` | proxy/fallback follows authoritative position/facing | PASS |
| working | `assign_worker_to_mine`, `activityState=working` | presentation reconstructed from runtime | PASS |
| save/load | capture save and restore | proxy rebuilt from restored state | PASS |
| rollback | same runtime, H3 off/on | presentation-only | PASS |
