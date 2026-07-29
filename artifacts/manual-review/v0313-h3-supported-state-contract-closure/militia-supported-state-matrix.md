# Militia supported-state matrix

| State | Runtime binding | H3/fallback | Result |
|---|---|---|---|
| idle/selected/unselected | `friendly_00`, authoritative `runtime.units` | proxy/fallback follows same state | PASS |
| moving/stopped | `issue_move_order` and `_advance_movement` | proxy/fallback follows authoritative position/facing | PASS |
| Hold label | aliases existing move callback | no distinct ready visual expected | NOT APPLICABLE |
| save/load | capture save and restore | proxy rebuilt from restored state | PASS |
| fallback/H3 reconstruction | same authoritative runtime | presentation-only | PASS |
