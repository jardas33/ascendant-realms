# Ascendant Realms Private Playtest

Thanks for trying this rough prototype.

This package is meant for private feedback. You do not need the source repo, Codex, Vite, Playwright, or any development setup.

## Start The Game

On Windows:

1. Open this package folder.
2. Double-click `START_GAME_WINDOWS.bat`.
3. Your browser should open automatically.
4. If it does not, open the URL shown in the terminal window. It is usually `http://127.0.0.1:4174/`.

On Mac or Linux:

1. Open a terminal in this package folder.
2. Run `sh START_GAME_MAC_LINUX.sh`.
3. Open the URL shown in the terminal. It is usually `http://127.0.0.1:4174/`.

If Node.js is missing, install Node.js LTS from `https://nodejs.org/` or ask Emmanuel for a hosted link.

Do not open `game/index.html` directly. Use the included launcher or local server helper.

## What This Game Is

Ascendant Realms is a small fantasy RTS/RPG browser prototype.

You make a hero, play short campaign battles, build a small army, capture objectives, and carry some progress between battles.

## Judge Now

Focus your feedback on:

- whether you knew what to do
- whether commands felt responsive
- whether attack-hover, left-click attack, and retreat/move-away intent felt clear
- whether Hold / Guard / Press behaviour buttons were understandable
- whether objectives were readable
- whether pressure warnings were noticed
- whether defeat felt fair
- whether victory felt earned
- whether the Results screen helped you understand what happened
- whether it was fun enough to keep playing or retry

## Do Not Judge Yet

Please do not spend most of your feedback on:

- ugly prototype art
- placeholder scale
- rough map visuals
- unfinished animations
- missing final VFX
- lack of 2026-quality graphics

Mention visuals only if they blocked gameplay understanding.

## Quick 30-Minute Route

1. Start with Tutorial / Proving Grounds or Border Village.
2. Continue into one campaign battle if you have time.
3. Use the route Emmanuel assigned.
4. If no route was assigned, use Baseline Cautious: read objectives, avoid heavy optimization, react to warnings, preserve units, and retreat if badly hurt.
5. Fill `FEEDBACK_SUBMISSION_PACKET.md`.

## Battle Controls To Try

- Select a unit and hover an enemy. The cursor should show attack intent.
- Left-click a hovered enemy, or right-click an enemy, to order an attack.
- Right-click ground to move or retreat. Retreating units can still be chased, but they should not instantly snap back to the same target.
- Selected units have `Hold`, `Guard`, and `Press` behaviour buttons.
- `Hold` avoids distant chase, `Guard` is the default, and `Press` pursues nearby enemies more assertively.

## Full 2-Hour Route

1. Warm up with Tutorial / Proving Grounds or Border Village.
2. Play your assigned route through as much of Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch as you can reach.
3. Record wins, losses, timeouts, and confusing moments.
4. Fill `FEEDBACK_SUBMISSION_PACKET.md`.
5. Send the completed form back to Emmanuel.

## What To Send Back

Send Emmanuel:

- your route/profile
- how long you played
- missions played
- wins, losses, or timeouts
- ratings from 1 to 5
- top confusing moments
- top satisfying moments
- whether pressure warnings were noticed
- one thing to fix first
- one thing not to change
- screenshots or videos if useful

The copy-paste form is `FEEDBACK_SUBMISSION_PACKET.md`.

## Troubleshooting

If the page does not open:

1. Check that the server window says `Ascendant Realms private playtest server is running`.
2. Open `http://127.0.0.1:4174/` manually.
3. If port `4174` is busy, close other local server windows and try again.
4. If Node.js is missing, install Node.js LTS or ask Emmanuel for a hosted link.

If the game feels stuck:

1. Refresh the browser.
2. Use Reset Save from the main menu if Emmanuel asked for a clean run.
3. Write down what happened in the feedback form.

If you find a bug:

Use this shape:

```text
I expected:
The game showed:
Mission/node:
Route/profile:
What I tried:
What happened:
Did it repeat:
Screenshot/video:
```
