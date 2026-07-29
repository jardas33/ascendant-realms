# Militia authoritative state contract

Existing fields are `position`, `destination`, `hasDestination`, `commandState`, `activityState`, `facing`, `health`, and `readyState`. `readyState` is `unsupported`; there is no distinct authoritative ready/hold state. Move sets `commandState=move_ordered` and `activityState=travelling`; arrival sets `commandState=stopped`, `activityState=idle`, and clears `hasDestination`.

MILITIA READY VISUAL STATE: NOT APPLICABLE — NO AUTHORITATIVE GAMEPLAY STATE EXISTS
