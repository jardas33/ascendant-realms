param()
$ErrorActionPreference = "Stop"

node tools/godot/saltoV0270BarrosanMilitiaContactFeedbackCooldownBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0270"

Write-Output "PASS_V0270_BARROSAN_MILITIA_CONTACT_FEEDBACK_COOLDOWN_BRIDGE_VALIDATION"
