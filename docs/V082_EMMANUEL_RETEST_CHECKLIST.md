# v0.82 Emmanuel Retest Checklist

Status: manual retest checklist for the mission-local Lume Network prototype.

## Build

- Use package `ascendant-realms-private-playtest-<final commit>`.
- Start with `START_GAME_WINDOWS.bat` or `node start-playtest-server.mjs`.
- Do not judge final art, final VFX, desktop packaging, multiplayer, race-specific Lume variants, Jardas binding, or runtime display renames.

## Mission Gate

1. Start or load a campaign that has Aether Well Ruins unlocked.
2. Select `Aether Well Ruins`.
3. Expected:
   - display name remains `Aether Well Ruins`;
   - briefing includes `Linked Ward`;
   - briefing says `Hold two linked sites to wake a Lume Ward. Enemy recapture severs the link.`
4. Select another Broken Ford mission, such as Bandit Hillfort.
5. Expected:
   - no Lume Network briefing line appears.

## Runtime

1. Launch Aether Well Ruins.
2. Expected:
   - HUD objective surface shows a compact `Lume` row;
   - status starts inactive;
   - benefit says friendly units/buildings near active linked sites take 8% less incoming damage.
3. Capture `west_stone_cut`.
4. Capture `ford_toll`.
5. Expected:
   - `Linked Ward` becomes active;
   - HUD shows `West Stone Cut + Ford Toll`;
   - selected `west_stone_cut` or `ford_toll` shows a Lume link summary.
6. Let or force enemy control of one endpoint.
7. Expected:
   - HUD shows severed or contested/severed state;
   - copy explains enemy recapture severs the link.
8. Recapture both endpoints.
9. Expected:
   - the link can reactivate.

## Results

1. Complete Aether Well Ruins.
2. Expected Results block:
   - `Lume Network`;
   - `Linked Ward`;
   - activated link count;
   - severed link count if one occurred;
   - objective completed/incomplete;
   - battle-local copy.

## Safety

Confirm:

- Tutorial / Proving Grounds shows no Lume complexity.
- Skirmish launches show no Lume row.
- Replay can show the battle-local Lume row but does not duplicate campaign rewards.
- No save migration prompt appears.
- No new art or runtime rename appears.
