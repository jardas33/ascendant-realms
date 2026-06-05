# v0.133 Objective Prerequisite Ledger

Status: `PASS_OBJECTIVE_PREREQUISITE_REPORT`

| Objective | Required proof before advance |
| --- | --- |
| Select Aster | Player clicks Aster in the packaged player slice. |
| Move to West Stone Cut Mine | Aster is selected and a normal right-click move order is accepted. |
| Convert West Stone Cut Mine | Aster enters the capture radius and conversion progress reaches controlled state. |
| Assign Worker to mine | Worker is selected and right-clicks the controlled West Stone Cut Mine. |
| Restore Barracks | Worker assignment is complete and the Worker right-clicks the highlighted Barracks frame. |
| Train Militia | Barracks restoration reaches complete state, the Barracks is selected, and Train is clicked. |
| Prepare Ashen pressure | Militia recruitment reaches spawn through queue progress. |
| Defeat Ashen wave | Countdown launches the wave, enemies move, squad attack input is accepted, and combat ticks begin. |
| Restore Lume link | The Ashen wave is defeated by normal simulation. |
| Review Results | The highlighted Lume link is clicked and results state is reached. |

Box-select repair:

- A pre-Barracks box-select is recorded as a normal selection probe.
- It does not advance to `prepare_ashen_pressure`.
- `boxSelectNoObjectiveSkipProven` is true in the v0.133 smoke.

Forbidden proof sources remain disallowed: private-harness shortcuts, debug triggers, direct objective skipping, direct state injection, fixture-only completion helpers, and screenshot-only assertions.
