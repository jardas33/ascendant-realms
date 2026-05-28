# v0.40 Mission Reward Structure Implementation Report

Date: 2026-05-28

## Scope

v0.40 makes mission rewards more explicit without changing the broad reward economy. First-clear campaign node rewards remain one-time, replay battles use the existing reduced repeat-clear battle reward path, and Results now labels first-clear, replay, already-claimed, champion, relic choice, XP, and skill-point reminder states more clearly.

## Runtime Changes

- `completeCampaignNodeWithRewards` now reports first-clear/replay and node reward claim state.
- Results campaign reward blocks show first-clear versus replay reward state and whether the campaign node reward was claimed now or already claimed.
- Battle reward copy treats campaign replays as reduced repeat rewards.
- Rival champion relic choice remains the special relic source and still uses the existing unique relic duplicate protection.

## Save Format

No save-version bump is used. Existing saves missing newer campaign progression fields normalize safely.

## Tutorial Impact

Tutorial / Proving Grounds remains no-save and no-reward. The new campaign reward state is only produced for campaign node victories.

## Verification

Final verification is recorded in `docs/V041_IMPLEMENTATION_REPORT.md`.
