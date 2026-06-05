# v0.133 Barracks Restoration Guidance Spec

Status: `PASS_BARRACKS_RESTORATION_PROOF`

After Worker assignment, the player-facing slice now:

- Keeps the objective at `Objective 5: Restore the Barracks`.
- Highlights the Barracks frame.
- Tells the player: `With the Worker selected, right-click the highlighted Barracks frame.`
- Accepts a normal Worker right-click on the Barracks.
- Shows construction progress.
- Advances to Militia training only after the Barracks is restored.

Verified captures:

- `02_objective_restore_barracks`
- `03_barracks_highlighted`
- `04_build_order_accepted`
- `05_construction_25`
- `06_construction_75`
- `07_barracks_restored`

No editor work, art import, save change, stable-ID change, or browser runtime change is required.
