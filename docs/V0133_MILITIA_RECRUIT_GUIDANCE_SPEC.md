# v0.133 Militia Recruit Guidance Spec

Status: `PASS_MILITIA_RECRUIT_PROOF`

After Barracks restoration, the player-facing slice now:

- Advances to `Objective 6: Train one Militia`.
- Lets the player select the restored Barracks normally.
- Changes the command-row Work button to a Train action while the Barracks is selected.
- Accepts a normal click on Train.
- Shows recruit progress.
- Spawns one Militia through the runtime recruit queue.

Verified captures:

- `08_objective_train_militia`
- `09_train_militia_button`
- `10_queue_50`
- `11_militia_spawned`

The proof uses normal packaged mouse input and normal simulation. It does not use private-harness queue completion as evidence.
