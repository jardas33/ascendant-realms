# v0.111 Machine Pressure Classification

Host classification: HOST_PRESSURE_UNLIKELY
Game-cost classification: BATTLE_CODE_DOMINANT
Confidence: high

## Evidence

| Control | Mode | FPS avg | p95 | max | long tasks |
| --- | --- | ---: | ---: | ---: | ---: |
| blank-page-raf | clean-profile-headless | 60.1 | 16.7 | 16.8 | 0 |
| phaser-empty-scene | clean-profile-headless | 60 | 16.8 | 16.8 | 2 |
| campaign-map | clean-profile-headless | 9.4 | 216.7 | 433.4 | 3 |
| tier-m-representative-battle | clean-profile-headless | 2.5 | 516.7 | 533.3 | 50 |
| blank-page-raf | preview-headless | 60.1 | 16.7 | 16.8 | 0 |
| simple-dom | preview-headless | 60.1 | 16.7 | 16.8 | 0 |
| simple-canvas | preview-headless | 60.1 | 16.7 | 16.8 | 0 |
| phaser-empty-scene | preview-headless | 60 | 16.7 | 16.8 | 4 |
| campaign-map | preview-headless | 9.9 | 200 | 300 | 5 |
| tier-m-representative-battle | preview-headless | 2.4 | 566.6 | 650 | 47 |

## Notes

- Host pressure result: HOST_PRESSURE_UNLIKELY.
- Game-cost result: BATTLE_CODE_DOMINANT.
- Classification is local browser QA evidence only, not desktop hardware certification.
- No v0.112 work may start automatically from this gate.

If the evidence is mixed or incomplete, keep the classification unresolved rather than blaming only the computer or only the game.
