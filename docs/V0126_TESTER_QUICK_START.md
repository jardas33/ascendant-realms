# v0.12.6 Tester Quick Start

Date: 2026-05-18

Use this short guide if Emmanuel asked you to play the current Ascendant Realms browser prototype and send back feedback.

## What This Game Is

Ascendant Realms is a small fantasy RTS/RPG browser prototype.

You make a hero, play short campaign battles, build a small army, capture objectives, and carry some progress between battles.

This test is about whether the current slice is understandable, fair, responsive, and fun enough for real human players.

## Ignore For Now

Please do not spend most of your feedback on:

- ugly prototype art
- placeholder unit scale
- rough map visuals
- unfinished animations
- missing final VFX
- general lack of 2026-quality graphics

Mention visuals only when they block gameplay understanding, such as "I could not tell which object was the shrine" or "I missed the warning because the screen was too visually busy."

## Judge Now

While playing, focus on:

- clarity: did you know what to do next?
- commands: did selecting, moving, attacking, behaviour modes, building, and retreating feel responsive?
- objectives: did the tracker tell you what mattered?
- pressure warnings: did you notice enemy pressure during combat?
- fairness: did defeat feel caused by readable mistakes?
- victory: did wins feel earned?
- results: did the result screen tell you useful next steps?
- fun: did you want to keep playing or retry?

## How To Open The Game

Preferred:

1. Open the link Emmanuel sends you.
2. Use the current build only.
3. Start from a clean save if the route asks for one.
4. Write down the route/profile you played and how long you played.

If Emmanuel sends a private playtest package:

1. Open `README_FOR_TESTERS.md` in the package.
2. Start the included local server with `START_GAME_WINDOWS.bat` on Windows or `START_GAME_MAC_LINUX.sh` on Mac/Linux.
3. Open the local URL shown by the package, usually `http://127.0.0.1:4174/`.
4. Fill the included `FEEDBACK_SUBMISSION_PACKET.md` when done.

If Emmanuel asks you to run the source repo locally:

1. Install Node.js if it is not already installed.
2. Open a terminal in the project folder.
3. Run `npm install`.
4. Run `npm run dev`.
5. Open the local URL shown in the terminal, usually `http://localhost:5173`.

Do not edit game files, saves, data, difficulty values, or source code for this test.

## How Long To Play

Quick 30-minute run:

- Play Tutorial / Proving Grounds or Border Village first.
- Continue into one campaign battle if time allows.
- Use the Baseline Cautious route unless Emmanuel assigned a different route.
- Send back the feedback submission packet plus any bug/friction notes.

Full 2-hour run:

- Warm up with Tutorial / Proving Grounds or Border Village.
- Play the assigned route through as many of Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch as available.
- Fill the feedback submission packet after the session.
- Add separate notes for bugs, confusion, pressure-warning misses, or balance concerns.

## Which Route To Choose First

If you were not assigned a route, choose Baseline Cautious:

- do not optimize heavily
- read objectives
- react to warnings
- preserve units
- retreat if badly hurt

## Current Battle Controls To Notice

- Select a unit, then hover an enemy. The cursor should clearly show attack intent.
- Left-click a hovered enemy to issue an attack order, or right-click an enemy to attack.
- Right-click ground to move. If you are leaving combat, the selected unit should visibly reposition briefly before target reacquisition resumes.
- Use `Shift+A`, then right-click ground for attack-move.
- Selected units now have three behaviour buttons: `Hold`, `Guard`, and `Press`.
- `Hold Ground` avoids chasing distant enemies but still fights immediate threats.
- `Guard Area` is the balanced default.
- `Press Attack` pursues more assertively inside a local leash, not across the whole map.

Use `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md` only if Emmanuel asks you to choose from the broader route set.

## What To Send Back

Send Emmanuel:

- your route/profile
- time played
- missions played
- wins, losses, or timeouts
- ratings from 1 to 5
- top three confusing moments
- top three satisfying moments
- whether pressure warnings were noticed
- whether victory or defeat felt fair
- one thing to fix first
- one thing not to change
- screenshots or video links if useful

The fastest copy-paste form is `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`.

## How To Describe Bugs Or Friction

Use this shape:

```text
I expected:
The game showed:
Mission/node:
Route/profile:
What I had built/unlocked:
What I tried:
What happened:
Did it repeat:
Screenshot/video:
```

For balance concerns, include what route you used, your army state, hero danger, resources, whether you saw warnings, and whether the same issue happened more than once.
