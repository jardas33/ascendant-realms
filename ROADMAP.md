# Ascendant Realms Roadmap

## Product Pillars

Every phase should protect these long-term pillars:

1. Persistent hero fantasy: race, class, origin, items, scars, titles, retinue, reputation, and choices should make the hero feel personal.
2. Faction asymmetry: factions need different economies, rhythms, combat identities, and strategic weaknesses.
3. Living campaign map: the world should react with alliances, betrayals, invasions, shops, temples, ruins, contracts, holy orders, cursed lands, and ancient threats.
4. Data-driven and mod-friendly content: future expansion should mostly mean adding data and assets, not rewriting engine code.

## Current Recommended Next Phase

The current checkpoint is **v0.221 Lighting Camera Selection And Composition Pass** on 2026-06-11. It keeps the v0.215 presentation-reboot path isolated while adding visual-only composition, lighting, camera, value and selection-scale refinements on top of the selected v0.216-v0.220 material/shell/dressing context. It preserves the default procedural launcher, all prior launchers and comparators, and gameplay/pathing/collision/objective/AI/economy/save/stable-ID/balance boundaries.

The queued next milestone is **v0.222**. Continue only from a clean, synced, pushed and CI-green v0.221 state, and only inside that prompt's stated boundaries.

New v0.221 docs:

- `docs/V0221_BATTLEFIELD_COMPOSITION_REPORT.md`
- `docs/V0221_SELECTION_INDICATOR_REPORT.md`
- `docs/V0221_IMPLEMENTATION_REPORT.md`

Previous v0.220 docs:

- `docs/V0220_ENVIRONMENT_PROP_ATLAS_INTAKE_REPORT.md`
- `docs/V0220_ENVIRONMENT_DRESSING_REPORT.md`
- `docs/V0220_IMPLEMENTATION_REPORT.md`

Previous v0.219 docs:

- `docs/V0219_STRUCTURE_SHELL_PRODUCTION_REPORT.md`
- `docs/V0219_IMPLEMENTATION_REPORT.md`

Previous v0.218 docs:

- `docs/V0218_BRIDGE_SHELL_REPORT.md`
- `docs/V0218_IMPLEMENTATION_REPORT.md`

Previous v0.217 docs:

- `docs/V0217_ROAD_RIVERBANK_WATER_INTAKE_REPORT.md`
- `docs/V0217_ROAD_RIVERBANK_WATER_COMPOSITOR_REPORT.md`
- `docs/V0217_IMPLEMENTATION_REPORT.md`

Previous v0.216 docs:

- `docs/V0216_TERRAIN_MATERIAL_INTAKE_REPORT.md`
- `docs/V0216_TERRAIN_COMPOSITOR_REPORT.md`
- `docs/V0216_IMPLEMENTATION_REPORT.md`

Previous v0.215 docs:

- `docs/V0215_PRESENTATION_REBOOT_BASELINE.md`
- `docs/V0215_UI_DECLUTTER_REPORT.md`
- `docs/V0215_IMPLEMENTATION_REPORT.md`

Previous v0.214 docs:

- `docs/V0214_UI_FREEZE_DECISION.md`
- `docs/V0214_NEXT_PHASE_SCORECARD.md`
- `docs/V0214_IMPLEMENTATION_REPORT.md`
- `docs/art-prompts/V0215_01_RECOMMENDED_NEXT_PHASE.md`

The current checkpoint now includes the **continued post-v0.195 Godot Shell-V2 Value And Framing Hardening Review** on 2026-06-10. This ad hoc pass responds to the continued Godot visual-quality concern without beginning v0.196: it keeps the work inside the isolated opt-in shell-v2 scoped-material recovery path, rebalances shell-v2 terrain/road/river/bank/bridge values, adds small terrain-value, road-middle, bridge-shoulder, bridge-landing, and river-glint cues, shrinks the coherent base slightly, and recenters only shell-v2 review/focus camera presets within safe zoom bounds. It generates zero images, adds zero art slots, keeps the v0.189 wet-granite material comparator-only, preserves the default procedural launcher and all prior launchers, keeps browser runtime untouched, keeps character-slot integrations frozen, and changes no gameplay/pathing/collisions/objectives/AI/saves/stable IDs.

The recommended next step is human review of the refreshed post-v0.195 Godot capture screenshots, especially `03_tactical_overview.png`, `10_road_to_bridge_transition.png`, and `12_bridge_close_view.png`. Do not execute v0.196 or the older wet-granite bridge-riverbank integration recommendation without a new explicit prompt from a clean, synced, pushed, remote-green state.

The current checkpoint now includes the **continued post-v0.195 Godot Shell-V2 Visual Hardening Review** on 2026-06-09. This ad hoc pass responds to the visual-quality concern without beginning v0.196: it keeps the work inside the isolated opt-in shell-v2 scoped-material recovery path, lowers only the shell-v2 review camera angle, strengthens route/bridge readability, reduces the rectangular field read, shrinks the largest shell-v2 material slabs, strengthens crossing-local abutment/bank detail, and replaces duplicate full-height shell-v2 structure bases with low foundations. It generates zero images, adds zero art slots, keeps the v0.189 wet-granite material comparator-only, preserves the default procedural launcher and all prior launchers, keeps browser runtime untouched, keeps character-slot integrations frozen, and changes no gameplay/pathing/collisions/objectives/AI/saves/stable IDs.

The recommended next step is human review of the refreshed post-v0.195 Godot capture screenshots, especially `03_tactical_overview.png`, `08_connected_road_network.png`, `10_road_to_bridge_transition.png`, and `12_bridge_close_view.png`. Do not execute v0.196 or the older wet-granite bridge-riverbank integration recommendation without a new explicit prompt from a clean, synced, pushed, remote-green state.

New post-v0.195 doc:

- `docs/POST_V0195_GODOT_SHELL_V2_VISUAL_HARDENING_REVIEW.md`

The current checkpoint is **v0.195 Salto Shell-V2 Scoped Material Recovery Tactical-Route Readability And Human-Review Stop** on 2026-06-09. It preserves the v0.194 clean shell-v2 topology while restoring restrained scoped terrain and road hierarchy at review distance. It keeps detached terrain islands and floating diagonal road fragments at zero, strengthens connected route readability into and across the bridge, avoids broad material masks, preserves the legacy shell as comparator/fallback, keeps the v0.189 wet-granite material comparator-only, keeps the default launcher procedural, preserves all prior opt-in launchers, keeps the browser runtime untouched, adds zero art slots, generates zero images, and leaves gameplay/pathing/collisions/objectives/AI/saves/stable IDs unchanged.

The recommended next step is human review of the v0.195 shell-v2 scoped-material captures, especially the connected road network, road intersections, road-to-bridge transition, and bridge close-up. Do not execute the older wet-granite bridge-riverbank material integration recommendation directly. Any future v0.196 must start from a clean, synced, pushed, remote-green v0.195 state and must explicitly choose its bounded next step.

New v0.195 docs:

- `docs/V0195_SCOPED_MATERIAL_RECOVERY_QA_BENCHMARK.md`
- `docs/V0195_SCOPED_MATERIAL_BOUNDARY_ROLLBACK.md`
- `docs/V0195_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.194 Salto Shell-V2 Topology Repair And Human-Review Stop.

New v0.194 docs:

- `docs/V0194_SHELL_V2_TOPOLOGY_REPAIR_QA_BENCHMARK.md`
- `docs/V0194_SHELL_V2_TOPOLOGY_BOUNDARY_ROLLBACK.md`
- `docs/V0194_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.193 Isolated Salto Presentation-Shell V2 Prototype Implementation And Human-Review Stop.

New v0.193 docs:

- `docs/V0193_SHELL_V2_PROTOTYPE_QA_BENCHMARK.md`
- `docs/V0193_SHELL_V2_BOUNDARY_ROLLBACK.md`
- `docs/V0193_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.192 Human-Review Override Presentation-Shell V2 Architecture Audit And Contract Stop.

New v0.192 docs:

- `docs/V0192_PRESENTATION_SHELL_V2_ARCHITECTURE_AUDIT.md`
- `docs/V0192_PRESENTATION_SHELL_V2_CONTRACT_AND_ROLLBACK.md`
- `docs/art-prompts/V0193_01_PRESENTATION_SHELL_V2_IMPLEMENTATION.md`
- `docs/V0192_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.191 Post-Shell-Freeze Next-Phase Scorecard And v0.192 Preparation Only.

New v0.191 docs:

- `docs/V0191_POST_SHELL_FREEZE_SCORECARD.md`
- `docs/V0191_CLEANUP_EXECUTION_DECISION.md`
- `docs/art-prompts/V0192_01_RECOMMENDED_NEXT_PHASE.md`
- `docs/V0191_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.190 Bridge-Riverbank Material Opt-In Integration Readiness Packet Only.

New v0.190 docs:

- `docs/V0190_BRIDGE_RIVERBANK_MATERIAL_READINESS_PACKET.md`
- `docs/V0190_BRIDGE_RIVERBANK_RISK_ROLLBACK.md`
- `docs/art-prompts/V0191_01_BRIDGE_RIVERBANK_MATERIAL_OPT_IN.md`
- `docs/V0190_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.189 Barrosan Wet-Granite Bridge-Riverbank Material Private Comparator Intake And Human-Review Stop.

New v0.189 docs:

- `docs/V0189_BRIDGE_RIVERBANK_MATERIAL_COMPARATOR_QA_BENCHMARK.md`
- `docs/V0189_PRIVATE_COMPARATOR_BOUNDARY_ROLLBACK.md`
- `docs/V0189_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.188 Salto Environment-Shell Full Cohesion QA Cleanup Packet And Shell-Freeze Stop.

New v0.188 docs:

- `docs/V0188_ENVIRONMENT_SHELL_FULL_COHESION_QA.md`
- `docs/V0188_SAFE_CLEANUP_SHELL_FREEZE_PACKET.md`
- `docs/V0188_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.187 Salto Riverbank Bridge-Crossing Approach-Lane Procedural Visual Hardening And Human-Review Stop.

New v0.187 docs:

- `docs/V0187_RIVERBANK_BRIDGE_APPROACH_QA_BENCHMARK.md`
- `docs/V0187_RIVERBANK_BRIDGE_BOUNDARY_ROLLBACK.md`
- `docs/V0187_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.186 Salto Barrosan Foothold Procedural Structure-Shell Hierarchy Hardening And Human-Review Stop.

New v0.186 docs:

- `docs/V0186_STRUCTURE_SHELL_HIERARCHY_QA_BENCHMARK.md`
- `docs/V0186_STRUCTURE_SHELL_BOUNDARY_ROLLBACK.md`
- `docs/V0186_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.185 Salto Environment-Shell Live QA Residual-Overlay Pruning And Human-Review Stop.

New v0.185 docs:

- `docs/V0185_ENVIRONMENT_SHELL_LIVE_QA_AND_BENCHMARK.md`
- `docs/V0185_ENVIRONMENT_SHELL_BOUNDARY_ROLLBACK.md`
- `docs/V0185_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.184 Salto Opt-In Environment-Shell Geometry Convergence And Human-Review Stop.

New v0.184 docs:

- `docs/V0184_ENVIRONMENT_GEOMETRY_CONVERGENCE_QA_BENCHMARK.md`
- `docs/V0184_ENVIRONMENT_GEOMETRY_BOUNDARY_ROLLBACK.md`
- `docs/V0184_IMPLEMENTATION_REPORT.md`
- `docs/SALTO_EXPERIMENTAL_ARTIFACT_INDEX.md`

Previous checkpoint reference: Post-v0.183 Godot Opt-In Visual Hardening Review.

The previous review repaired the existing explicit Godot Salto ground + road material opt-in presentation after v0.183. It was not v0.184, generated zero images, added zero slots, changed no launcher, and kept the default launcher procedural.

Previous checkpoint reference: v0.178 Ground-Material Visual QA, UV-Scale Hardening, And Terrain-Noise Control Stop.

The earlier v0.178 checkpoint hardened only the existing Barrosan foothold ground-material opt-in path using UV `0.56`, alpha `0.48`, mipmapped filtering, and a procedural value underlay. It preserved the default procedural launcher, all prior opt-in launchers, the browser runtime boundary, and the frozen five-character-slot posture.

New v0.178 docs:

- `docs/V0178_GROUND_MATERIAL_VISUAL_QA_UV_HARDENING.md`
- `docs/V0178_GROUND_MATERIAL_BENCHMARK_BOUNDARY.md`
- `docs/V0178_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.177 Barrosan Foothold Ground-Material First Opt-In Player-Slice Integration Experiment.

The previous checkpoint was **v0.177 Barrosan Foothold Ground-Material First Opt-In Player-Slice Integration Experiment** on 2026-06-08. It integrated exactly one environment-material opt-in slot using the selected v0.175 ground derivative and preserved the default procedural launcher, all prior opt-in launchers, browser runtime boundary, and five-character-slot freeze.

New v0.177 docs:

- `docs/V0177_GROUND_MATERIAL_OPT_IN_QA_BENCHMARK.md`
- `docs/V0177_GROUND_MATERIAL_BOUNDARY_ROLLBACK.md`
- `docs/V0177_IMPLEMENTATION_REPORT.md`

The previous checkpoint was **v0.176 Terrain-Material Opt-In Player-Slice Integration Readiness Packet** on 2026-06-08. It prepared documentation only for exactly one future terrain-material opt-in player-slice slot and did not integrate terrain material.

New v0.176 docs:

- `docs/V0176_TERRAIN_MATERIAL_OPT_IN_READINESS_PACKET.md`
- `docs/V0176_TERRAIN_MATERIAL_RISK_AND_ROLLBACK.md`
- `docs/art-prompts/V0177_01_TERRAIN_MATERIAL_OPT_IN_INTEGRATION.md`
- `docs/V0176_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.175 Barrosan Foothold Terrain-Material Single-Slot Private Comparator Intake And Human-Review Stop.

The previous checkpoint was **v0.175 Barrosan Foothold Terrain-Material Single-Slot Private Comparator Intake And Human-Review Stop** on 2026-06-08. It generated exactly one private-comparator terrain-material source, selected `GROUND_MATERIAL_LOCAL_1024`, and did not integrate terrain material into the player-facing slice.

New v0.175 docs:

- `docs/V0175_GROUND_MATERIAL_COMPARATOR_QA_AND_BENCHMARK.md`
- `docs/V0175_PRIVATE_COMPARATOR_BOUNDARY_AND_ROLLBACK.md`
- `docs/V0175_IMPLEMENTATION_REPORT.md`

The previous checkpoint was **v0.174 Salto Road-River-Bridge Site-Marker Readability Hardening And Human-Review Stop** on 2026-06-08. It added an opt-in E2 environment-readability Godot review path after the v0.173 world-shell foundation, hardened only road/river/bridge/site-marker tactical readability, and preserved default procedural launchers plus all prior opt-in launchers.

New v0.174 docs:

- `docs/V0174_TACTICAL_ENVIRONMENT_READABILITY_QA_AND_BENCHMARK.md`
- `docs/V0174_ENVIRONMENT_BOUNDARY_AND_ROLLBACK.md`
- `docs/V0174_IMPLEMENTATION_REPORT.md`

The previous checkpoint was **v0.173 Salto Procedural World-Shell Hierarchy Hardening Experiment And Human-Review Stop** on 2026-06-08. It added the opt-in environment-foundation Godot review path after the five-slot character freeze, hardened procedural world-shell hierarchy, and preserved default procedural launchers plus all prior opt-in launchers.

New v0.173 docs:

- `docs/V0173_ENVIRONMENT_SHELL_HARDENING_QA_AND_BENCHMARK.md`
- `docs/V0173_ENVIRONMENT_SHELL_BOUNDARY_AND_ROLLBACK.md`
- `docs/V0173_IMPLEMENTATION_REPORT.md`

The previous checkpoint was **v0.172 Safe Cleanup Execution Documentation-Budget Enforcement And Environment-Phase Decision Packet** on 2026-06-08. It performed bounded cleanup execution, left archive candidates untouched, created a documentation-budget policy, and prepared the environment-foundation roadmap after the five-slot character freeze.

New v0.172 docs:

- `docs/V0172_SAFE_CLEANUP_EXECUTION_REPORT.md`
- `docs/V0172_DOCUMENTATION_BUDGET_POLICY.md`
- `docs/V0172_ENVIRONMENT_PHASE_SCORECARD.md`
- `docs/V0172_ENVIRONMENT_PHASE_ROADMAP.md`
- `docs/V0172_IMPLEMENTATION_REPORT.md`

The previous checkpoint was **v0.171 Salto Five-Slot Visual-Cohesion QA Cleanup Packet And Character-Integration Freeze Stop** on 2026-06-08. It reviewed the five selected opt-in slots, hardened artifact retention for all five derivatives and metadata records, safely removed only known Godot sidecars, and froze character-slot expansion.

Earlier checkpoint reference: v0.170 Godot Salto Restrained Ashen Raider Fifth Opt-In Integration Experiment And Follow-Up Hardening.

The earlier v0.170 checkpoint added only the selected restrained Ashen Raider derivative behind the five-slot opt-in launcher, preserved the default procedural launchers and all prior opt-in launchers, proved Ashen missing-art/hash-mismatch fallback while prior slots stayed active, benchmarked M0/M4/M5/fallback modes, and hardened the opening battle view so unrecruited friendly military billboards stayed hidden until progression.

The next recommended step is human review and explicit approval only unless a separately queued prompt is already being executed after v0.166 gates pass. Emmanuel should review the v0.166 review launcher screenshots, scale measurements, Barracks visibility notes, benchmark scorecard, cleanup before/after manifests, and boundary report. Do not add a fourth art slot, import Aster or Ashen art into the player slice, wire assets into the browser runtime, mutate production manifests or art slots, change saves or stable IDs, choose Godot finally, start a full desktop port, start Unity/Unreal/Electron work, perform broad cleanup, or begin any unqueued future milestone.

New v0.166 docs:

- `docs/V0166_THREE_SLOT_VISUAL_COHERENCE_CORRECTION_SPEC.md`
- `docs/V0166_SCREENSHOT_MODE_AND_SCALE_REVIEW.md`
- `docs/V0166_THREE_SLOT_VISUAL_QA_REPORT.md`
- `docs/V0166_SAFE_ARTIFACT_CLEANUP_EXECUTION_REPORT.md`
- `docs/V0166_EXPERIMENTAL_REVIEW_LAUNCHER_GUIDE.md`
- `docs/V0166_PLAYER_SLICE_THREE_SLOT_BOUNDARY.md`
- `docs/V0166_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.165 Godot Salto Three-Slot Visual Hardening And Artifact Hygiene Inventory Stop.

New v0.165 docs:

- `docs/V0165_THREE_SLOT_VISUAL_SCALE_HARDENING_SPEC.md`
- `docs/V0165_HUMAN_SCREENSHOT_REPRODUCTION_REPORT.md`
- `docs/V0165_BILLBOARD_SCALE_ASPECT_PIVOT_AUDIT.md`
- `docs/V0165_DUPLICATE_RENDER_AUDIT.md`
- `docs/V0165_BARRACKS_MATERIAL_BINDING_REVIEW.md`
- `docs/V0165_THREE_SLOT_VISUAL_QA_REPORT.md`
- `docs/V0165_THREE_SLOT_BENCHMARK_REPORT.md`
- `docs/V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_INVENTORY.md`
- `docs/V0165_EXPERIMENTAL_ARTIFACT_RETENTION_POLICY.md`
- `docs/V0165_PLAYER_SLICE_THREE_SLOT_BOUNDARY.md`
- `docs/V0165_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.164 Godot Salto Militia Third Opt-In Player-Slice Integration And Human Review Stop.

New v0.164 docs:

- `docs/V0164_GODOT_PLAYER_SLICE_MILITIA_OPT_IN_SPEC.md`
- `docs/V0164_MILITIA_OPT_IN_SLOT_CONTRACT.md`
- `docs/V0164_MILITIA_OPT_IN_FUNCTIONAL_REPORT.md`
- `docs/V0164_MILITIA_OPT_IN_VISUAL_REVIEW_GUIDE.md`
- `docs/V0164_MILITIA_OPT_IN_BENCHMARK_REPORT.md`
- `docs/V0164_MILITIA_OPT_IN_ROLLBACK_REPORT.md`
- `docs/V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY.md`
- `docs/V0164_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.163 Godot Salto Barracks-Material Opt-In Visual QA Hardening And Human Review Stop.

New v0.163 docs:

- `docs/V0163_BARRACKS_MATERIAL_OPT_IN_PLAYER_SLICE_VISUAL_QA_SPEC.md`
- `docs/V0163_BARRACKS_MATERIAL_OPT_IN_COMPUTER_USE_REVIEW.md`
- `docs/V0163_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT_REPORT.md`
- `docs/V0163_BARRACKS_MATERIAL_OPT_IN_HARDENING_REPORT.md`
- `docs/V0163_BARRACKS_MATERIAL_OPT_IN_VISUAL_REVIEW_GUIDE.md`
- `docs/V0163_BARRACKS_MATERIAL_OPT_IN_ROLLBACK_CONFIRMATION.md`
- `docs/V0163_PLAYER_SLICE_TWO_SLOT_BOUNDARY.md`
- `docs/V0163_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.162 Godot Salto Worker + Barracks Art Opt-In Human Review Stop.

New v0.162 docs:

- `docs/V0162_GODOT_PLAYER_SLICE_BARRACKS_MATERIAL_OPT_IN_SPEC.md`
- `docs/V0162_BARRACKS_MATERIAL_OPT_IN_SLOT_CONTRACT.md`
- `docs/V0162_BARRACKS_MATERIAL_OPT_IN_FUNCTIONAL_REPORT.md`
- `docs/V0162_BARRACKS_MATERIAL_OPT_IN_VISUAL_REVIEW_GUIDE.md`
- `docs/V0162_BARRACKS_MATERIAL_OPT_IN_BENCHMARK_REPORT.md`
- `docs/V0162_BARRACKS_MATERIAL_OPT_IN_ROLLBACK_REPORT.md`
- `docs/V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY.md`
- `docs/V0162_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.161 Worker-Art Opt-In Visual QA Hardening And Human Review Stop.

New v0.161 docs:

- `docs/V0161_WORKER_ART_OPT_IN_PLAYER_SLICE_VISUAL_QA_SPEC.md`
- `docs/V0161_WORKER_ART_OPT_IN_COMPUTER_USE_REVIEW.md`
- `docs/V0161_WORKER_ART_OPT_IN_REAL_INPUT_REPORT.md`
- `docs/V0161_WORKER_ART_OPT_IN_HARDENING_REPORT.md`
- `docs/V0161_WORKER_ART_OPT_IN_VISUAL_REVIEW_GUIDE.md`
- `docs/V0161_WORKER_ART_OPT_IN_ROLLBACK_CONFIRMATION.md`
- `docs/V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY.md`
- `docs/V0161_IMPLEMENTATION_REPORT.md`

New v0.160 docs:

- `docs/V0160_GODOT_PLAYER_SLICE_WORKER_ART_OPT_IN_SPEC.md`
- `docs/V0160_WORKER_ART_OPT_IN_SLOT_CONTRACT.md`
- `docs/V0160_WORKER_ART_OPT_IN_FUNCTIONAL_REPORT.md`
- `docs/V0160_WORKER_ART_OPT_IN_VISUAL_REVIEW_GUIDE.md`
- `docs/V0160_WORKER_ART_OPT_IN_BENCHMARK_REPORT.md`
- `docs/V0160_WORKER_ART_OPT_IN_ROLLBACK_REPORT.md`
- `docs/V0160_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY.md`
- `docs/V0160_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.159 First Player-Facing Hybrid-Art Integration Readiness Packet And V0.160 Worker Contract.

New v0.159 docs:

- `docs/V0159_FIRST_PLAYER_FACING_HYBRID_ART_INTEGRATION_READINESS.md`
- `docs/V0159_FIRST_SLOT_DECISION_SCORECARD.md`
- `docs/V0159_V0160_WORKER_OPT_IN_INTEGRATION_CONTRACT.md`
- `docs/V0159_PLAYER_SLICE_INTEGRATION_RISK_REGISTER.md`
- `docs/V0159_PLAYER_SLICE_INTEGRATION_ROLLBACK_PLAN.md`
- `docs/V0159_EMMANUEL_INTEGRATION_READINESS_REVIEW_GUIDE.md`
- `docs/V0159_PRIVATE_COMPARATOR_TO_PLAYER_SLICE_BOUNDARY.md`
- `docs/V0159_IMPLEMENTATION_REPORT.md`
- `docs/art-prompts/V0160_01_GODOT_PLAYER_SLICE_WORKER_BILLBOARD_OPT_IN_INTEGRATION.md`

Previous checkpoint reference: v0.158 Hybrid Mixed Friendly-Versus-Hostile Combat-Readability Stress Gate And Human Review Stop.

New v0.158 docs:

- `docs/V0158_HYBRID_MIXED_COMBAT_STRESS_SPEC.md`
- `docs/V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT.md`
- `docs/V0158_HYBRID_MIXED_COMBAT_BENCHMARK_REPORT.md`
- `docs/V0158_HYBRID_MIXED_COMBAT_VISUAL_REVIEW_GUIDE.md`
- `docs/V0158_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0158_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.157 Ashen Raider Visual-Restraint Replacement Private Comparator And Human Review Stop.

New v0.157 docs:

- `docs/V0157_ASHEN_RAIDER_VISUAL_RESTRAINT_REPLACEMENT_SPEC.md`
- `docs/V0157_ASHEN_RAIDER_REPLACEMENT_SLOT_CONTRACT.md`
- `docs/V0157_ASHEN_RAIDER_DERIVATIVE_MATRIX.md`
- `docs/V0157_ASHEN_RAIDER_FAIR_PATH_AUDIT.md`
- `docs/V0157_ASHEN_RAIDER_PAIRED_BENCHMARK_REPORT.md`
- `docs/V0157_ASHEN_RAIDER_VISUAL_REVIEW_GUIDE.md`
- `docs/V0157_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0157_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.156 Hybrid Ashen Raider Static Billboard Single Hostile-Slot Intake Experiment And Human Review Stop.

New v0.156 docs:

- `docs/V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md`
- `docs/V0156_ASHEN_RAIDER_BILLBOARD_SLOT_CONTRACT.md`
- `docs/V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION_REPORT.md`
- `docs/V0156_ASHEN_RAIDER_BILLBOARD_BENCHMARK_REPORT.md`
- `docs/V0156_ASHEN_RAIDER_BILLBOARD_SCORECARD.md`
- `docs/V0156_ASHEN_RAIDER_BILLBOARD_VISUAL_REVIEW_GUIDE.md`
- `docs/V0156_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0156_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.155 Hybrid Militia Billboard Repair Mass-Overlap Combat-Readability Benchmark And Human Review Stop.

New v0.155 docs:

- `docs/V0155_MILITIA_BILLBOARD_REPAIR_SPEC.md`
- `docs/V0155_MILITIA_BILLBOARD_DERIVATIVE_MATRIX.md`
- `docs/V0155_MILITIA_BILLBOARD_SCORECARD.md`
- `docs/V0155_MILITIA_BILLBOARD_FAIR_PATH_AUDIT.md`
- `docs/V0155_MILITIA_BILLBOARD_VISUAL_REVIEW_GUIDE.md`
- `docs/V0155_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0155_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.154 Hybrid Militia Static Billboard Single-Slot Intake Experiment And Human Review Stop.

New v0.154 docs:

- `docs/V0154_MILITIA_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md`
- `docs/V0154_MILITIA_BILLBOARD_SLOT_CONTRACT.md`
- `docs/V0154_MILITIA_BILLBOARD_VALIDATION_REPORT.md`
- `docs/V0154_MILITIA_BILLBOARD_SCORECARD.md`
- `docs/V0154_MILITIA_BILLBOARD_VISUAL_REVIEW_GUIDE.md`
- `docs/V0154_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0154_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.153 Hybrid Three-Slot Private Composition Stress Gate And Human Review Stop.

New v0.153 docs:

- `docs/V0153_HYBRID_THREE_SLOT_COMPOSITION_STRESS_SPEC.md`
- `docs/V0153_HYBRID_THREE_SLOT_SCORECARD.md`
- `docs/V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT.md`
- `docs/V0153_HYBRID_THREE_SLOT_VISUAL_REVIEW_GUIDE.md`
- `docs/V0153_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0153_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.152 Hybrid Aster Billboard Fair-Path Repair Derivative Selection And Human Review Stop.

New v0.152 docs:

- `docs/V0152_ASTER_BILLBOARD_REPAIR_SPEC.md`
- `docs/V0152_ASTER_BILLBOARD_DERIVATIVE_MATRIX.md`
- `docs/V0152_ASTER_BILLBOARD_PAIRED_BENCHMARK_REPORT.md`
- `docs/V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT.md`
- `docs/V0152_ASTER_BILLBOARD_VISUAL_REVIEW_GUIDE.md`
- `docs/V0152_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0152_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.151 Hybrid Aster Static Billboard Single-Slot Intake Experiment And Human Review Stop.

New v0.151 docs:

- `docs/V0151_ASTER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md`
- `docs/V0151_ASTER_BILLBOARD_SLOT_CONTRACT.md`
- `docs/V0151_ASTER_BILLBOARD_VALIDATION_REPORT.md`
- `docs/V0151_ASTER_BILLBOARD_SCORECARD.md`
- `docs/V0151_ASTER_BILLBOARD_VISUAL_REVIEW_GUIDE.md`
- `docs/V0151_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0151_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.150 Hybrid Barracks Material UV Seam Repair Lighting Review And Human Review Stop.

New v0.150 docs:

- `docs/V0150_BARRACKS_MATERIAL_UV_SEAM_REPAIR_SPEC.md`
- `docs/V0150_BARRACKS_MATERIAL_SEAM_DERIVATIVE_MATRIX.md`
- `docs/V0150_BARRACKS_MATERIAL_FAIR_PATH_AUDIT.md`
- `docs/V0150_BARRACKS_MATERIAL_PAIRED_BENCHMARK_REPORT.md`
- `docs/V0150_BARRACKS_MATERIAL_VISUAL_REVIEW_GUIDE.md`
- `docs/V0150_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0150_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.149 Hybrid Barrosan Barracks Material Single-Slot Intake Experiment And Human Review Stop.

New v0.149 docs:

- `docs/V0149_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_INTAKE_SPEC.md`
- `docs/V0149_BARROSAN_BARRACKS_MATERIAL_SLOT_CONTRACT.md`
- `docs/V0149_BARROSAN_BARRACKS_MATERIAL_FAIR_PATH_AUDIT.md`
- `docs/V0149_BARROSAN_BARRACKS_MATERIAL_DERIVATIVE_MATRIX.md`
- `docs/V0149_BARROSAN_BARRACKS_MATERIAL_PAIRED_BENCHMARK_REPORT.md`
- `docs/V0149_BARROSAN_BARRACKS_MATERIAL_VISUAL_REVIEW_GUIDE.md`
- `docs/V0149_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0149_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.148 Hybrid Worker Billboard Single-Slot Repair Fair Benchmark And Human Review Stop.

New v0.148 docs:

- `docs/V0148_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_SPEC.md`
- `docs/V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT.md`
- `docs/V0148_WORKER_BILLBOARD_DERIVATIVE_MATRIX.md`
- `docs/V0148_WORKER_BILLBOARD_PAIRED_BENCHMARK_REPORT.md`
- `docs/V0148_WORKER_BILLBOARD_ALPHA_PIVOT_REVIEW_GUIDE.md`
- `docs/V0148_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0148_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.147 Hybrid Worker Billboard Single-Slot Runtime-Art Intake Experiment And Human Review Stop.

New v0.147 docs:

- `docs/V0147_WORKER_BILLBOARD_SINGLE_SLOT_INTAKE_SPEC.md`
- `docs/V0147_WORKER_BILLBOARD_SLOT_CONTRACT.md`
- `docs/V0147_WORKER_BILLBOARD_VALIDATION_REPORT.md`
- `docs/V0147_WORKER_BILLBOARD_BENCHMARK_REPORT.md`
- `docs/V0147_WORKER_BILLBOARD_VISUAL_REVIEW_GUIDE.md`
- `docs/V0147_PRIVATE_COMPARATOR_ONLY_BOUNDARY.md`
- `docs/V0147_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.146 Godot Runtime-Art Pipeline Comparator Spike And Human Decision Stop.

New v0.146 docs:

- `docs/V0146_RUNTIME_ART_PIPELINE_COMPARATOR_SPEC.md`
- `docs/V0146_RUNTIME_ART_PIPELINE_BENCHMARK_REPORT.md`
- `docs/V0146_RUNTIME_ART_PIPELINE_SCORECARD.md`
- `docs/V0146_RUNTIME_ART_PIPELINE_RECOMMENDATION.md`
- `docs/V0146_EMMANUEL_RUNTIME_ART_PIPELINE_REVIEW_GUIDE.md`
- `docs/V0146_REFERENCE_ONLY_AND_COMPARATOR_BOUNDARY.md`
- `docs/V0146_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.145 Salto HUD Reference-Style Exploration And Human Review Stop.

New v0.145 docs:

- `docs/V0145_SALTO_HUD_REFERENCE_STYLE_GENERATION_REPORT.md`
- `docs/V0145_HUD_REFERENCE_STYLE_REVIEW_GUIDE.md`
- `docs/V0145_REFERENCE_ONLY_BOUNDARY.md`
- `docs/V0145_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.144 Aster / Worker Silhouette-Scale Convergence Revisions And Human Review Stop.

New v0.144 docs:

- `docs/V0144_ASTER_WORKER_SILHOUETTE_CONVERGENCE_REPORT.md`
- `docs/V0144_SILHOUETTE_CONVERGENCE_REVIEW_GUIDE.md`
- `docs/V0144_REFERENCE_ONLY_BOUNDARY.md`
- `docs/V0144_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.143 Aster / Worker Silhouette-Scale Reference Boards And Human Review Stop.

New v0.143 docs:

- `docs/V0143_ASTER_WORKER_SILHOUETTE_SCALE_GENERATION_REPORT.md`
- `docs/V0143_SILHOUETTE_SCALE_REVIEW_GUIDE.md`
- `docs/V0143_REFERENCE_ONLY_BOUNDARY.md`
- `docs/V0143_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.142 Salto Environment Reference-Only Style Lock Ratification And Silhouette Brief Preparation.

New v0.142 docs:

- `docs/V0142_SALTO_ENVIRONMENT_REFERENCE_STYLE_LOCK.md`
- `docs/V0142_ASTER_WORKER_SILHOUETTE_BRIEF_PREPARATION.md`
- `docs/V0142_REFERENCE_ONLY_BOUNDARY.md`
- `docs/V0142_IMPLEMENTATION_REPORT.md`
- `docs/art-prompts/V0143_01_ASTER_WORKER_SILHOUETTE_SCALE_BOARD.md`

Previous checkpoint reference: v0.141 Salto Environment Style-Lock Revision Round And Human Approval Stop.

New v0.141 docs:

- `docs/V0141_SALTO_ENVIRONMENT_REVISION_REPORT.md`
- `docs/V0141_STYLE_LOCK_REVIEW_GUIDE.md`
- `docs/V0141_REFERENCE_ONLY_BOUNDARY.md`
- `docs/V0141_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.140 Salto Environment Reference-Art Canary Generation And Human Style-Lock Stop.

New v0.140 docs:

- `docs/V0140_SALTO_ENVIRONMENT_CANARY_GENERATION_REPORT.md`
- `docs/V0140_REFERENCE_ONLY_BOUNDARY.md`
- `docs/V0140_EMMANUEL_ART_REVIEW_GUIDE.md`
- `docs/V0140_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.139 Godot Salto Slice Stabilization Gate, Human Review Package, And Next-Phase Roadmap.

New v0.139 docs:

- `docs/V0139_SALTO_SLICE_STABILIZATION_GATE.md`
- `docs/V0139_FINAL_REVIEW_BUILD_REPORT.md`
- `docs/V0139_EMMANUEL_STABILIZED_SLICE_REVIEW_GUIDE.md`
- `docs/V0139_NEXT_PHASE_OPTIONS.md`
- `docs/V0139_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.138 Reference-Art Workspace, Source Metadata Pipeline, Contact-Sheet Tooling, And First Four Generation Briefs.

New v0.138 docs:

- `docs/V0138_REFERENCE_ART_WORKFLOW.md`
- `docs/V0138_REFERENCE_METADATA_SCHEMA.md`
- `docs/V0138_CONTACT_SHEET_TOOLING.md`
- `docs/V0138_FIRST_FOUR_REFERENCE_BRIEFS.md`
- `docs/V0138_IMPLEMENTATION_REPORT.md`
- `docs/V0138_EMMANUEL_REFERENCE_ART_GUIDE.md`
- `docs/art-prompts/V0138_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md`
- `docs/art-prompts/V0138_02_HUD_STYLE_FRAME.md`
- `docs/art-prompts/V0138_03_ASTER_HERO_SILHOUETTE_SHEET.md`
- `docs/art-prompts/V0138_04_WORKER_SILHOUETTE_SHEET.md`

Previous checkpoint reference: v0.137 Godot Procedural Visual Composition, Terrain Readability, And Blockout-Quality Upgrade.

New v0.137 docs:

- `docs/V0137_PROCEDURAL_COMPOSITION_SPEC.md`
- `docs/V0137_SILHOUETTE_REFINEMENT_SPEC.md`
- `docs/V0137_LIGHTING_VFX_SPEC.md`
- `docs/V0137_PERFORMANCE_SAFETY_REPORT.md`
- `docs/V0137_BLOCKOUT_QUALITY_GATE.md`
- `docs/V0137_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.136 Godot HUD, Minimap, Onboarding, And Microloop-Pacing Cleanup.

New v0.136 docs:

- `docs/V0136_HUD_HIERARCHY_SPEC.md`
- `docs/V0136_MINIMAP_REFINEMENT_SPEC.md`
- `docs/V0136_ONBOARDING_COPY_LEDGER.md`
- `docs/V0136_MICROLOOP_PACING_REPORT.md`
- `docs/V0136_USABILITY_PRESENTATION_GATE.md`
- `docs/V0136_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.135 Godot RTS Input Ergonomics, Recoverable Feedback, and Camera-Control Pass.

New v0.135 docs:

- `docs/V0135_RTS_INPUT_CONTRACT.md`
- `docs/V0135_ORDER_FEEDBACK_SPEC.md`
- `docs/V0135_CAMERA_CONTROL_SPEC.md`
- `docs/V0135_COMPACT_HELP_SPEC.md`
- `docs/V0135_RTS_ERGONOMICS_GATE.md`
- `docs/V0135_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.134 Godot Repeatable Natural Playthrough and Soft-Lock Resilience Gate.

New v0.134 docs:

- `docs/V0134_REPEATABLE_NATURAL_PLAYTHROUGH_SPEC.md`
- `docs/V0134_RECOVERY_CASE_LEDGER.md`
- `docs/V0134_RESTART_INTEGRITY_REPORT.md`
- `docs/V0134_REPEATABLE_PLAYTHROUGH_GATE.md`
- `docs/V0134_IMPLEMENTATION_REPORT.md`
- `docs/V0134_EMMANUEL_RETEST_GUIDE.md`

Previous checkpoint reference: v0.133.1 Godot Test11 Combat Readability Repair.

New v0.133 docs:

- `docs/V0133_POST_MINE_OBJECTIVE_STATE_MACHINE_AUDIT.md`
- `docs/V0133_OBJECTIVE_PREREQUISITE_LEDGER.md`
- `docs/V0133_BARRACKS_RESTORATION_GUIDANCE_SPEC.md`
- `docs/V0133_MILITIA_RECRUIT_GUIDANCE_SPEC.md`
- `docs/V0133_ASHEN_PRESSURE_COUNTDOWN_SPEC.md`
- `docs/V0133_COMBAT_ONSET_SPEC.md`
- `docs/V0133_LUME_RESTORE_GUIDANCE_SPEC.md`
- `docs/V0133_HEADED_POST_MINE_FLOW_PROOF.md`
- `docs/V0133_POST_MINE_FLOW_GATE.md`
- `docs/V0133_IMPLEMENTATION_REPORT.md`
- `docs/V0133_EMMANUEL_RETEST_GUIDE.md`
- `docs/V0133_TEST11_RECORDING_COMBAT_READABILITY_REPAIR.md`

Previous checkpoint reference: v0.132 Godot Site Semantics and Worker Guidance Repair.

New v0.132 docs:

- `docs/V0132_SITE_SEMANTICS_AUDIT.md`
- `docs/V0132_CANONICAL_SITE_COPY_LEDGER.md`
- `docs/V0132_OBJECTIVE_STATE_MONOTONICITY_AUDIT.md`
- `docs/V0132_MINE_CONVERSION_GUIDANCE_SPEC.md`
- `docs/V0132_WORKER_ASSIGNMENT_GUIDANCE_SPEC.md`
- `docs/V0132_MINIMAP_SITE_SEMANTICS_SPEC.md`
- `docs/V0132_HEADED_SITE_SEMANTICS_PROOF.md`
- `docs/V0132_SITE_GUIDANCE_GATE.md`
- `docs/V0132_IMPLEMENTATION_REPORT.md`
- `docs/V0132_EMMANUEL_RETEST_GUIDE.md`

Previous checkpoint reference: v0.131 Godot Player-Control Emergency Repair, Real-Input Proof, and Human-Playability Gate.

New v0.131 docs:

- `docs/V0131_REAL_INPUT_CONTRACT_AUDIT.md`
- `docs/V0131_FIRST_MINUTE_ONBOARDING_SPEC.md`
- `docs/V0131_HEADED_REAL_INPUT_PROOF.md`
- `docs/V0131_HUMAN_PLAYABILITY_GATE.md`
- `docs/V0131_IMPLEMENTATION_REPORT.md`
- `docs/V0131_EMMANUEL_RETEST_GUIDE.md`

Previous checkpoint reference: v0.130 Godot Salto Vertical-Slice Acceptance Pack, Human Review Build, and First Reference-Art Generation Session.

New v0.130 docs:

- `docs/V0130_SALTO_VERTICAL_SLICE_ACCEPTANCE_GATE.md`
- `docs/V0130_FINAL_HUMAN_REVIEW_BUILD_REPORT.md`
- `docs/V0130_FIRST_REFERENCE_ART_GENERATION_SESSION.md`
- `docs/V0130_REFERENCE_ART_REVIEW_WORKFLOW.md`
- `docs/V0130_EMMANUEL_DECISION_PACKET.md`
- `docs/V0130_IMPLEMENTATION_REPORT.md`

Previous checkpoint reference: v0.129 Godot Bounded Hero-Worker-Mine-Build-Recruit Microloop and Vertical-Slice Gameplay Proof.

New v0.129 docs:

- `docs/V0129_VERTICAL_SLICE_MICROLOOP_SPEC.md`
- `docs/V0129_HERO_WORKER_MINE_BUILD_RECRUIT_REPORT.md`
- `docs/V0129_DATA_ADAPTER_REPORT.md`
- `docs/V0129_PERFORMANCE_SMOKE_REPORT.md`
- `docs/V0129_VISUAL_CAPTURE_REPORT.md`
- `docs/V0129_IMPLEMENTATION_REPORT.md`
- `docs/V0129_EMMANUEL_REVIEW_GUIDE.md`

New v0.128 docs:

Previous checkpoint reference: v0.128 Godot Player-Facing HUD Minimap Objective Feedback and Micro-Onboarding Pass.

- `docs/V0128_HUD_SPEC.md`
- `docs/V0128_MINIMAP_SPEC.md`
- `docs/V0128_MICRO_ONBOARDING_SPEC.md`
- `docs/V0128_OBJECTIVE_FEEDBACK_REPORT.md`
- `docs/V0128_VISUAL_CAPTURE_REPORT.md`
- `docs/V0128_IMPLEMENTATION_REPORT.md`

New v0.127 docs:

Previous checkpoint reference: v0.127 Godot Procedural Silhouette Library, Selection Feedback, and Combat-Readability Pass.

- `docs/V0127_PROCEDURAL_SILHOUETTE_LIBRARY.md`
- `docs/V0127_SELECTION_FEEDBACK_SPEC.md`
- `docs/V0127_COMBAT_READABILITY_REPORT.md`
- `docs/V0127_VISUAL_CAPTURE_REPORT.md`
- `docs/V0127_IMPLEMENTATION_REPORT.md`

New v0.126 docs:

Previous checkpoint reference: v0.126 Godot Procedural Salto Environment Authorship, Camera Framing, and Tactical-Lane Readability Pass.

- `docs/V0126_SALTO_ENVIRONMENT_AUTHORSHIP_SPEC.md`
- `docs/V0126_CAMERA_FRAMING_SPEC.md`
- `docs/V0126_TACTICAL_LANE_READABILITY_REPORT.md`
- `docs/V0126_PERFORMANCE_SAFETY_REPORT.md`
- `docs/V0126_VISUAL_CAPTURE_REPORT.md`
- `docs/V0126_IMPLEMENTATION_REPORT.md`

New v0.125 docs:

- `docs/V0125_PLAYER_SLICE_VISUAL_QA_SPEC.md`
- `docs/V0125_PLAYER_SLICE_ISSUE_LEDGER.md`
- `docs/V0125_PLAYER_SLICE_REVIEW_READINESS_GATE.md`
- `docs/V0125_IMPLEMENTATION_REPORT.md`
- `docs/V0125_EMMANUEL_REVIEW_GUIDE.md`

New v0.124 docs:

- `docs/V0124_PLAYER_FACING_SLICE_SPEC.md`
- `docs/V0124_PRIVATE_HARNESS_SEPARATION_REPORT.md`
- `docs/V0124_PROCEDURAL_SALTO_BLOCKOUT_SPEC.md`
- `docs/V0124_PROCEDURAL_SILHOUETTE_SPEC.md`
- `docs/V0124_HUD_MINIMAP_PLACEHOLDER_SPEC.md`
- `docs/V0124_LUME_PRESENTATION_SPEC.md`
- `docs/V0124_ART_READY_SLOT_REPORT.md`
- `docs/V0124_PERFORMANCE_SMOKE_REPORT.md`
- `docs/V0124_VISUAL_CAPTURE_REPORT.md`
- `docs/V0124_IMPLEMENTATION_REPORT.md`
- `docs/V0124_EMMANUEL_PLAYER_SLICE_REVIEW_GUIDE.md`

New v0.123 docs:

- `docs/V0123_GODOT_CONTINUATION_GATE.md`
- `docs/V0123_GODOT_SCORECARD_UPDATE.md`
- `docs/V0123_UNITY_COMPARATOR_BOUNDARY.md`
- `docs/V0123_EMMANUEL_GODOT_REVIEW_GUIDE.md`
- `docs/V0123_REFERENCE_ART_REVIEW_BOUNDARY.md`
- `docs/V0123_IMPLEMENTATION_REPORT.md`
- `docs/art-prompts/V0123_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md`
- `docs/art-prompts/V0123_02_BARROSAN_HERO_SILHOUETTE_SHEET.md`
- `docs/art-prompts/V0123_03_BARROSAN_WORKER_SILHOUETTE_SHEET.md`
- `docs/art-prompts/V0123_04_BARROSAN_MILITIA_RANGER_SILHOUETTE_SHEET.md`
- `docs/art-prompts/V0123_05_COMMAND_HALL_BARRACKS_STYLE_SHEET.md`
- `docs/art-prompts/V0123_06_LUME_VFX_STYLE_FRAME.md`
- `docs/art-prompts/V0123_07_CAMPAIGN_MAP_STYLE_FRAME.md`
- `docs/art-prompts/V0123_08_HUD_STYLE_FRAME.md`

New v0.122 docs:

- `docs/V0122_GODOT_CONTENT_SUBSET_ADAPTER_SPEC.md`
- `docs/V0122_GODOT_RULES_PARITY_HARNESS.md`
- `docs/V0122_GODOT_STABLE_ID_REPORT.md`
- `docs/V0122_GODOT_MIGRATION_READINESS_MATRIX.md`
- `docs/V0122_GODOT_PARITY_REPORT.md`
- `docs/V0122_IMPLEMENTATION_REPORT.md`
- `docs/V0122_EMMANUEL_REVIEW_GUIDE.md`

New v0.121 docs:

- `docs/V0121_GODOT_2_5D_VISUAL_FOUNDATION_SPEC.md`
- `docs/V0121_GODOT_2D_CONTROL_POSTURE.md`
- `docs/V0121_GODOT_PROCEDURAL_PRESET_SPEC.md`
- `docs/V0121_GODOT_VISUAL_CAPTURE_REPORT.md`
- `docs/V0121_GODOT_PERFORMANCE_COMPARISON.md`
- `docs/V0121_GODOT_IMPLEMENTATION_REPORT.md`
- `docs/V0121_EMMANUEL_VISUAL_REVIEW_GUIDE.md`

New v0.120 docs:

- `docs/V0120_GODOT_FRESH_CHECKOUT_SPEC.md`
- `docs/V0120_GODOT_CI_STYLE_WORKFLOW.md`
- `docs/V0120_ZERO_EDITOR_AUTOMATION_CONTRACT.md`
- `docs/V0120_GODOT_REPRODUCIBILITY_REPORT.md`
- `docs/V0120_EMMANUEL_ONE_CLICK_GUIDE.md`
- `docs/V0120_IMPLEMENTATION_REPORT.md`

New v0.119 docs:

- `docs/V0119_GODOT_REPRESENTATIVE_RTS_LOAD_SPEC.md`
- `docs/V0119_GODOT_NAVIGATION_AND_AI_PRESSURE_SPEC.md`
- `docs/V0119_GODOT_SCALABILITY_BENCHMARK_REPORT.md`
- `docs/V0119_GODOT_PARITY_REPORT.md`
- `docs/V0119_GODOT_SCORECARD_UPDATE.md`
- `docs/V0119_IMPLEMENTATION_REPORT.md`
- `docs/V0119_EMMANUEL_REVIEW_GUIDE.md`

New v0.118 docs:

- `docs/V0118_EMMANUEL_HEADLESS_AND_HEADED_REVIEW_GUIDE.md`
- `docs/V0118_GODOT_HEADED_SMOKE_SPEC.md`
- `docs/V0118_GODOT_SCREENSHOT_CAPTURE_SPEC.md`
- `docs/V0118_GODOT_PACKAGE_VALIDATION_REPORT.md`
- `docs/V0118_GODOT_HEADED_BENCHMARK_REPORT.md`
- `docs/V0118_GODOT_VISUAL_CONTACT_SHEET_REPORT.md`
- `docs/V0118_IMPLEMENTATION_REPORT.md`

New v0.117 docs:

- `docs/V0117_GODOT_SPIKE_SCOPE.md`
- `docs/V0117_GODOT_SETUP_AND_BOOTSTRAP_SPEC.md`
- `docs/V0117_GODOT_FIXTURE_IMPORT_REPORT.md`
- `docs/V0117_GODOT_AI_FIRST_WORKFLOW_REPORT.md`
- `docs/V0117_GODOT_VISUAL_DIRECTION_COMPARISON.md`
- `docs/V0117_GODOT_BENCHMARK_REPORT.md`
- `docs/V0117_GODOT_WINDOWS_EXPORT_REPORT.md`
- `docs/V0117_EMMANUEL_ONE_CLICK_GUIDE.md`
- `docs/V0117_IMPLEMENTATION_REPORT.md`
- `docs/V0117_DEFERRED_GODOT_FINDINGS.md`

New v0.116 docs:

- `docs/V0116_ARCHITECTURE_DECISION_RECORD.md`
- `docs/V0116_ENGINE_CANDIDATE_MATRIX.md`
- `docs/V0116_RECOMMENDED_ENGINE_SPIKE_ORDER.md`
- `docs/V0116_DESKTOP_SPIKE_ACCEPTANCE_CONTRACT.md`
- `docs/V0116_DESKTOP_SPIKE_FIXTURE_EXPORT_SPEC.md`
- `docs/V0116_ENGINE_SPIKE_SCORECARD_TEMPLATE.json`
- `docs/V0116_EMMANUEL_ARCHITECTURE_REVIEW_PACKET.md`
- `docs/V0116_REFERENCE_ART_CONTINUATION_BOUNDARY.md`
- `docs/V0116_IMPLEMENTATION_REPORT.md`

Recent v0.115 docs:

- `docs/V0115_BROWSER_PERFORMANCE_GATE.md`
- `docs/V0115_CONSOLIDATED_PERFORMANCE_REPORT.md`
- `docs/V0115_EMMANUEL_CLEAN_RESTART_RETEST.md`
- `docs/V0115_EMMANUEL_PERFORMANCE_DECISION_PACKET.md`
- `docs/V0115_IMPLEMENTATION_REPORT.md`

Recent v0.111 docs:

- `docs/V0111_HOST_SNAPSHOT_SPEC.md`
- `docs/V0111_BROWSER_CONTROL_BASELINES.md`
- `docs/V0111_CLEAN_PROFILE_BENCHMARK_SPEC.md`
- `docs/V0111_MACHINE_PRESSURE_CLASSIFICATION.md`
- `docs/V0111_EMMANUEL_POST_RESTART_RETEST.md`
- `docs/V0111_IMPLEMENTATION_REPORT.md`

New v0.110 docs:

- `docs/V0110_BATTLE_LOOP_PHASE_PROFILER_SPEC.md`
- `docs/V0110_SUBSYSTEM_ISOLATION_MATRIX_SPEC.md`
- `docs/V0110_DENSITY_SCALING_REPORT.md`
- `docs/V0110_ROOT_CAUSE_CLASSIFICATION.md`
- `docs/V0110_CONTROLLED_OPTIMIZATION_REPORT.md`
- `docs/V0110_BROWSER_PERFORMANCE_GATE.md`
- `docs/V0110_VISUAL_QA_REPORT.md`
- `docs/V0110_IMPLEMENTATION_REPORT.md`
- `docs/V0110_EMMANUEL_PHASE_PROFILE_RETEST.md`
- `docs/V0110_DEFERRED_ARCHITECTURE_FINDINGS.md`

Recent v0.109 docs:

- `docs/V0109_PROFILER_METHOD_AUDIT.md`
- `docs/V0109_TRUSTED_BROWSER_BENCHMARK_PROTOCOL.md`
- `docs/V0109_EXECUTION_MODE_COMPARISON.md`
- `docs/V0109_ROOT_CAUSE_MATRIX_REPORT.md`
- `docs/V0109_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`
- `docs/V0109_MANUAL_BENCHMARK_GUIDE.md`
- `docs/V0109_VISUAL_QA_REPORT.md`
- `docs/V0109_IMPLEMENTATION_REPORT.md`
- `docs/V0109_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V0109_DEFERRED_ENGINE_SPIKE_PREPARATION.md`

New v0.108 docs:

- `docs/V0108_REPRESENTATIVE_BATTLE_PROFILE.md`
- `docs/V0108_BENCHMARK_SCENARIO_MANIFEST.json`
- `docs/V0108_BROWSER_BATTLE_BENCHMARK_REPORT.md`
- `docs/V0108_DESKTOP_ACCEPTANCE_PROFILE.md`
- `docs/V0108_PERFORMANCE_DELTA_REPORT.md`
- `docs/V0108_VISUAL_QA_REPORT.md`
- `docs/V0108_IMPLEMENTATION_REPORT.md`
- `docs/V0108_EMMANUEL_BENCHMARK_GUIDE.md`

Recent v0.107 docs:

- `docs/V0107_SALTO_VERTICAL_SLICE_COMPOSITION_SPEC.md`
- `docs/V0107_ASSET_DIMENSION_CONTRACTS.md`
- `docs/V0107_SALTO_VERTICAL_SLICE_MANIFEST.json`
- `docs/V0107_GENERATION_DEPENDENCY_ORDER.md`
- `docs/V0107_FIRST_SLICE_REVIEW_GATE.md`
- `docs/V0107_IMPLEMENTATION_REPORT.md`
- `docs/V0107_EMMANUEL_ART_GENERATION_CHECKLIST.md`

Recent v0.106 docs:

- `docs/V0106_RUNTIME_ART_SLOT_CONTRACT.md`
- `docs/V0106_PLACEHOLDER_FALLBACK_MATRIX.md`
- `docs/V0106_ART_SLOT_VALIDATION_REPORT.md`
- `docs/V0106_VISUAL_QA_REPORT.md`
- `docs/V0106_IMPLEMENTATION_REPORT.md`
- `docs/V0106_EMMANUEL_RUNTIME_ART_SLOT_GUIDE.md`

Recent v0.105 docs:

- `docs/V0105_VISUAL_ASSET_REGISTRY_SPEC.md`
- `docs/V0105_CANDIDATE_REVIEW_WORKSPACE_SPEC.md`
- `docs/V0105_ART_REVIEW_STATE_MACHINE.md`
- `docs/V0105_FIRST_ART_GENERATION_PACKET.md`
- `docs/V0105_IMPLEMENTATION_REPORT.md`
- `docs/V0105_EMMANUEL_ART_REVIEW_GUIDE.md`

Recent v0.104 docs:

- `docs/V0104_PROFILER_TRIAGE_REPORT.md`
- `docs/V0104_PUBLIC_BATTLE_HUD_MINIMAL_MODE_SPEC.md`
- `docs/V0104_PRIVATE_HUD_DENSITY_TOGGLE_SPEC.md`
- `docs/V0104_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`
- `docs/V0104_PERFORMANCE_DELTA_REPORT.md`
- `docs/V0104_VISUAL_QA_REPORT.md`
- `docs/V0104_IMPLEMENTATION_REPORT.md`
- `docs/V0104_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.103 docs:

- `docs/V0103_BATTLEFIELD_CLUTTER_REDUCTION_SPEC.md`
- `docs/V0103_PRIVATE_PERFORMANCE_PROFILER_SPEC.md`
- `docs/V0103_PERFORMANCE_LAB_SCENARIO_MANIFEST.json`
- `docs/V0103_PERFORMANCE_BASELINE_REPORT.md`
- `docs/V0103_EVIDENCE_BACKED_OPTIMIZATION_REPORT.md`
- `docs/V0103_VISUAL_QA_REPORT.md`
- `docs/V0103_IMPLEMENTATION_REPORT.md`
- `docs/V0103_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V0103_DEFERRED_ART_AND_RENDERING_FINDINGS.md`

Recent v0.102 docs:

- `docs/V0102_SAVE_FIXTURE_LIBRARY_SPEC.md`
- `docs/V0102_DESKTOP_SAVE_ENVELOPE_CONTRACT.md`
- `docs/V0102_SAVE_TRANSLATION_PROOF_REPORT.md`
- `docs/V0102_UNKNOWN_ID_AND_CORRUPTION_POLICY.md`
- `docs/V0102_IMPLEMENTATION_REPORT.md`

Recent v0.101 docs:

- `docs/V0101_PORTABLE_CONTENT_EXPORT_CONTRACT.md`
- `docs/V0101_STABLE_ID_FREEZE_POLICY.md`
- `docs/V0101_EXPORT_SCHEMA_REFERENCE.md`
- `docs/V0101_CONTENT_REUSE_ROUNDTRIP_PLAN.md`
- `docs/V0101_IMPLEMENTATION_REPORT.md`

Recent v0.100 docs:

- `docs/V0100_PRIVATE_PLAYTEST_HUB_SPEC.md`
- `docs/V0100_SCENARIO_GALLERY_MANIFEST.json`
- `docs/V0100_SAVE_ISOLATION_REPORT.md`
- `docs/V0100_EMMANUEL_FAST_REVIEW_GUIDE.md`
- `docs/V0100_VISUAL_QA_REPORT.md`
- `docs/V0100_IMPLEMENTATION_REPORT.md`

Recent v0.99 docs:

- `docs/V099_ACT1_PRESENTATION_AUDIT.md`
- `docs/V099_MISSION_CARD_AND_OBJECTIVE_SPEC.md`
- `docs/V099_WORLD_COPY_APPLIED_LEDGER.md`
- `docs/V099_ACT1_RESULTS_AND_NEXT_STEP_REPORT.md`
- `docs/V099_VISUAL_QA_REPORT.md`
- `docs/V099_IMPLEMENTATION_REPORT.md`
- `docs/V099_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.98 docs:

- `docs/V098_HERO_OVERVIEW_UX_SPEC.md`
- `docs/V098_SKILLS_AND_EQUIPMENT_UX_SPEC.md`
- `docs/V098_RETINUE_UX_RESCUE_SPEC.md`
- `docs/V098_STRONGHOLD_UX_RESCUE_SPEC.md`
- `docs/V098_RESULTS_TO_META_FLOW_REPORT.md`
- `docs/V098_VISUAL_QA_REPORT.md`
- `docs/V098_IMPLEMENTATION_REPORT.md`
- `docs/V098_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.97 docs:

- `docs/V097_SELECTION_FEEDBACK_SPEC.md`
- `docs/V097_COMMAND_MARKER_SPEC.md`
- `docs/V097_CAMERA_USABILITY_REPORT.md`
- `docs/V097_COMMAND_PANEL_FOLLOWUP_REPORT.md`
- `docs/V097_VISUAL_QA_REPORT.md`
- `docs/V097_IMPLEMENTATION_REPORT.md`
- `docs/V097_EMMANUEL_RETEST_CHECKLIST.md`

New v0.95 docs:

- `docs/V095_PROCEDURAL_BATTLEFIELD_READABILITY_SPEC.md`
- `docs/V095_FOG_AND_TERRAIN_PLACEHOLDER_RESCUE_REPORT.md`
- `docs/V095_ENTITY_SILHOUETTE_PLACEHOLDER_SPEC.md`
- `docs/V095_CAPTURE_SITE_AND_LABEL_DENSITY_REPORT.md`
- `docs/V095_VISUAL_QA_REPORT.md`
- `docs/V095_IMPLEMENTATION_REPORT.md`
- `docs/V095_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V095_DEFERRED_FINAL_ART_REQUIREMENTS.md`

Recent v0.94 docs:

- `docs/V094_MAIN_MENU_RESCUE_SPEC.md`
- `docs/V094_ASCENDANT_CREATION_UX_SPEC.md`
- `docs/V094_CAMPAIGN_DENSITY_RESCUE_SPEC.md`
- `docs/V094_RESULTS_DETAILS_COMPACTION_REPORT.md`
- `docs/V094_VISUAL_QA_REPORT.md`
- `docs/V094_IMPLEMENTATION_REPORT.md`
- `docs/V094_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.93 docs:

- `docs/V093_RUNTIME_UI_TOKEN_IMPLEMENTATION_SPEC.md`
- `docs/V093_SALTO_MISSION_PANEL_STATE_RESET_REPORT.md`
- `docs/V093_DESKTOP_TYPOGRAPHY_READABILITY_REPORT.md`
- `docs/V093_VISUAL_QA_REPORT.md`
- `docs/V093_IMPLEMENTATION_REPORT.md`
- `docs/V093_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.92 docs:

- `docs/V092_VISUAL_REVIEW_PACK_SPEC.md`
- `docs/V092_CONTACT_SHEET_INDEX.md`
- `docs/V092_EMMANUEL_UNIFIED_RETEST_PACKET.md`
- `docs/V092_IMPLEMENTATION_REPORT.md`

Recent v0.91 docs:

- `docs/V091_CURRENT_ARCHITECTURE_REUSE_MATRIX.md`
- `docs/V091_DESKTOP_ENGINE_DECISION_CRITERIA.md`
- `docs/V091_DESKTOP_VERTICAL_SLICE_SCOPE.md`
- `docs/V091_STAGED_TRANSITION_EXPERIMENTS.md`
- `docs/V091_SAVE_CONTENT_AND_TEST_REUSE_PLAN.md`
- `docs/V091_MULTIPLAYER_AND_COOP_DEFERRED_REQUIREMENTS.md`
- `docs/V091_EMMANUEL_DESKTOP_TRANSITION_REVIEW_PACKET.md`
- `docs/V091_IMPLEMENTATION_REPORT.md`

Recent v0.90 docs:

- `docs/V090_VISUAL_REGRESSION_MATRIX.json`
- `docs/V090_DESKTOP_VIEWPORT_ACCEPTANCE_SPEC.md`
- `docs/V090_LAYOUT_ASSERTION_COVERAGE.md`
- `docs/V090_LIGHTWEIGHT_PERFORMANCE_BASELINE.md`
- `docs/V090_VISUAL_QA_REVIEW_RULES.md`
- `docs/V090_IMPLEMENTATION_REPORT.md`

Recent v0.89 docs:

- `docs/V089_APPLIED_COPY_MIGRATION_LEDGER.md`
- `docs/V089_DEFERRED_AMBIGUOUS_TERMS.md`
- `docs/V089_COPY_ONLY_TEST_AND_ROLLBACK_REPORT.md`
- `docs/V089_VISUAL_QA_REPORT.md`
- `docs/V089_IMPLEMENTATION_REPORT.md`
- `docs/V089_EMMANUEL_RETEST_CHECKLIST.md`

Recent v0.88 docs:

- `docs/V088_SCREEN_BY_SCREEN_VISUAL_FOUNDATION.md`
- `docs/V088_UI_DESIGN_TOKEN_PROPOSAL.md`
- `docs/V088_BARROSAN_STYLE_FRAME_BRIEF.md`
- `docs/V088_ASHEN_STYLE_FRAME_BRIEF.md`
- `docs/V088_WOLFVEIL_SILHOUETTE_BRIEF.md`
- `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md`
- `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`
- `docs/V088_ART_INTAKE_AND_REVIEW_GATE.md`
- `docs/V088_EMMANUEL_VISUAL_REVIEW_PACKET.md`
- `docs/V088_IMPLEMENTATION_REPORT.md`

Recent v0.87 docs:

- `docs/V087_CAMPAIGN_SHELL_SECOND_POLISH_SPEC.md`
- `docs/V087_RESULTS_INFORMATION_ARCHITECTURE_SPEC.md`
- `docs/V087_VISUAL_QA_REPORT.md`
- `docs/V087_IMPLEMENTATION_REPORT.md`
- `docs/V087_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V087_DEFERRED_CAMPAIGN_AND_RESULTS_FINDINGS.md`

New v0.82 docs:

- `docs/V082_LUME_NETWORK_RUNTIME_PROTOTYPE_SPEC.md`
- `docs/V082_LINKED_WARD_BALANCE_AND_READABILITY_REPORT.md`
- `docs/V082_LUME_NETWORK_TEST_AND_SAFETY_REPORT.md`
- `docs/V082_EMMANUEL_RETEST_CHECKLIST.md`
- `docs/V082_IMPLEMENTATION_REPORT.md`

New v0.81 docs:

- `docs/V081_EXISTING_SITE_SYSTEM_AUDIT.md`
- `docs/V081_LUME_NETWORK_DESIGN_PRINCIPLES.md`
- `docs/V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md`
- `docs/V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md`
- `docs/V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md`
- `docs/V081_DATA_MODEL_AND_INTEGRATION_PLAN.md`
- `docs/V081_UI_READABILITY_AND_TEACHING_SPEC.md`
- `docs/V081_RACE_EXTENSIBILITY_MATRIX.md`
- `docs/V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md`
- `docs/V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md`
- `docs/V081_FUTURE_IMPLEMENTATION_SEQUENCE.md`
- `docs/V081_EMMANUEL_REVIEW_PACKET.md`
- `docs/V081_IMPLEMENTATION_REPORT.md`

New v0.80 docs:

- `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`
- `docs/V080_TERMINOLOGY_TAXONOMY.md`
- `docs/V080_DISPLAY_COPY_MIGRATION_MAP.md`
- `docs/V080_SAFE_COPY_BATCHES.md`
- `docs/V080_TEST_AND_ROLLBACK_PLAN.md`
- `docs/V080_EMMANUEL_REVIEW_PACKET.md`
- `docs/V080_IMPLEMENTATION_REPORT.md`

New v0.79 docs:

- `docs/V079_EMMANUEL_APPROVAL_LEDGER.md`
- `docs/V079_DIRECTION_LOCK_SUMMARY.md`
- `docs/V079_VERTICAL_SLICE_PRIORITY_LOCK.md`
- `docs/V079_FIRST_SIGNATURE_SYSTEM_PRIORITY.md`
- `docs/V079_DEFERRED_DECISIONS_REGISTER.md`
- `docs/V079_SAFE_NEXT_MILESTONE_SEQUENCE.md`
- `docs/V079_IMPLEMENTATION_REPORT.md`

New v0.78 docs:

- `docs/V078_CREATIVE_IDENTITY_LOCK_PLAN.md`
- `docs/V078_PUBLIC_TITLE_AND_BRAND_OPTIONS.md`
- `docs/V078_WORLD_AND_LORE_BIBLE_DRAFT.md`
- `docs/V078_RACE_AND_FACTION_MASTER_MATRIX.md`
- `docs/V078_HERO_RACE_CLASS_ORIGIN_OATH_ARCHITECTURE.md`
- `docs/V078_SIGNATURE_GAMEPLAY_PILLARS.md`
- `docs/V078_LONG_CAMPAIGN_MASTER_OUTLINE.md`
- `docs/V078_BROWSER_TO_DESKTOP_TRANSITION_GATE.md`
- `docs/V078_VISUAL_DIRECTION_AND_AI_ART_GOVERNANCE.md`
- `docs/V078_VISUAL_VERTICAL_SLICE_BRIEF.md`
- `docs/V078_DISPLAY_NAME_MIGRATION_MAP.md`
- `docs/V078_ORIGINAL_IP_SEPARATION_LEDGER.md`
- `docs/V078_FUTURE_IMPLEMENTATION_SEQUENCE.md`
- `docs/V078_EMMANUEL_REVIEW_PACKET.md`
- `docs/V078_IMPLEMENTATION_REPORT.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `LLM_GAME_HANDOFF.md`

New v0.17 Tutorial/Ranger docs and outputs:

- `docs/V017_SOLO_PLAYTEST_INTAKE.md`
- `docs/V017_WORKER_ECONOMY_DESIGN_SPEC.md`
- `docs/V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md`
- `docs/V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `LLM_GAME_HANDOFF.md`

New v0.18 Worker construction docs:

- `docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md`
- `docs/V018_IMPLEMENTATION_REPORT.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `LLM_GAME_HANDOFF.md`

New v0.16 control behaviour docs and outputs:

- `docs/V016_BASELINE_AND_CI_AUDIT.md`
- `docs/V016_BEHAVIOUR_MODE_AUDIT.md`
- `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`
- `docs/V016_EMMANUEL_CONTROL_RETEST_SCRIPT.md`
- `docs/V016_PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md`
- `docs/V016_BEHAVIOUR_MODE_TESTER_CHECKLIST.md`
- `docs/V016_CONTROL_FEEDBACK_INTAKE_TEMPLATE.md`
- `docs/V016_CONTROL_REGRESSION_TRIAGE_GUIDE.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_LAB.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_LAB.json`
- `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json`
- `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json`

New v0.15 control behaviour docs:

- `docs/V015_CONTROL_COMBAT_BASELINE_AUDIT.md`
- `docs/V015_BEHAVIOUR_MODES_SPEC.md`
- `docs/V015_CONTROL_COMBAT_BEHAVIOUR_FIX_REPORT.md`

New v0.14.4 Emmanuel retest docs:

- `docs/V0144_COMBAT_CONTROL_RETEST_FIX_REPORT.md`

New v0.14.3 Emmanuel retest docs:

- `docs/V0143_EMMANUEL_RETEST_INTAKE.md`
- `docs/V0143_REPRODUCTION_PLAN.md`
- `docs/V0143_COMBAT_SELECTION_RETEST_FIX_REPORT.md`
- `docs/V0143_UNIT_BEHAVIOUR_MODES_DESIGN.md`

New v0.14.1 Emmanuel quick playtest docs:

- `docs/V0141_EMMANUEL_QUICK_PLAYTEST_INTAKE.md`
- `docs/V0141_REPRODUCTION_PLAN.md`
- `docs/V0141_QUICK_PLAYTEST_FIX_REPORT.md`

New v0.14 private playtest package docs and commands:

- `npm run build:playtest`
- `npm run package:playtest`
- `npm run verify:playtest-package`
- `docs/V014_PLAYTEST_BUILD_DISTRIBUTION_AUDIT.md`
- `docs/V014_PRIVATE_PLAYTEST_TESTER_README.md`
- `docs/V014_PLAYTEST_PACKAGE_COORDINATOR_GUIDE.md`
- `docs/V014_READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md`

New v0.13.1 extended automated scenario-lab docs and outputs:

- `docs/V0131A_EXTENDED_LAB_INTEGRITY_AUDIT.md`
- `docs/V0131A_SCRIPT_AND_OUTPUT_VERIFICATION.md`
- `docs/V0131A_STATISTICAL_USEFULNESS_REVIEW.md`
- `docs/V0131A_EXTENDED_SCENARIO_LAB_AUDIT_REPORT.md`
- `docs/V0131_SCENARIO_LAB_LIMITATIONS_AUDIT.md`
- `docs/V0131_NODE_RISK_DASHBOARD_SPEC.md`
- `docs/V0131_BALANCE_REGRESSION_THRESHOLDS.md`
- `docs/V0131_EXTENDED_AUTOMATED_EVIDENCE_REVIEW.md`
- `docs/V0131_TUNING_AND_ACTION_DECISION.md`
- `docs/V0131_EXTENDED_SCENARIO_LAB_REPORT.md`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.md`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.json`
- `PLAYTEST_PROFILE_COMPARISON.md`
- `PLAYTEST_PROFILE_COMPARISON.csv`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`
- `PLAYTEST_WATCHPOINTS_EXTENDED.md`

New v0.13 automated scenario-lab docs and outputs:

- `docs/V013_AUTOMATED_PLAYTEST_ARCHITECTURE_AUDIT.md`
- `docs/V013_AUTOMATED_SCENARIO_PROFILE_SPEC.md`
- `docs/V013_TELEMETRY_METRICS_SPEC.md`
- `docs/V013_WATCHPOINT_CLASSIFIER_RULES.md`
- `docs/V013_AUTOMATED_EVIDENCE_DECISION.md`
- `docs/V013_AUTOMATED_PLAYTEST_SCENARIO_LAB_REPORT.md`
- `PLAYTEST_SCENARIO_LAB.md`
- `PLAYTEST_SCENARIO_LAB.json`
- `PLAYTEST_WATCHPOINT_SUMMARY.md`
- `PLAYTEST_SCENARIO_PROFILES.md`
- `PLAYTEST_SCENARIO_PROFILES.json`

New v0.12.6 tester distribution docs:

- `docs/V0126_TESTER_QUICK_START.md`
- `docs/V0126_PLAYTEST_COORDINATOR_GUIDE.md`
- `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`
- `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`
- `docs/V0126_FEEDBACK_STORAGE_PLAN.md`
- `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`

New v0.12.5 manual playtest intake docs:

- `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md`
- `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md`
- `docs/V0125_WATCHPOINT_AGGREGATION_SHEET.md`
- `docs/V0125_TRIAGE_DECISION_TREE.md`
- `docs/V0125_SEVERITY_PRIORITY_RUBRIC.md`
- `docs/V0125_FEEDBACK_TO_ACTION_MATRIX.md`
- `docs/V0125_ISSUE_READY_TEMPLATES.md`
- `docs/V0125_SAMPLE_FEEDBACK_TRIAGE.md`

New v0.12.4 manual human playtest packet docs:

- `docs/V0124_MANUAL_HUMAN_PLAYTEST_PACKET.md`
- `docs/V0124_PLAYTEST_ROUTE_CARDS.md`
- `docs/V0124_MISSION_CHECKLISTS.md`
- `docs/V0124_WATCHPOINT_RATING_SHEET.md`
- `docs/V0124_BUG_AND_FRICTION_REPORT_TEMPLATE.md`
- `docs/V0124_PLAYTEST_SUMMARY_FORM.md`
- `docs/V0124_DESIGNER_INTERPRETATION_GUIDE.md`
- `docs/V0124_PLAYTEST_PACKET_INDEX.md`

New v0.12.3 human campaign balance docs:

- `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_PROTOCOL.md`
- `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_NOTES.md`
- `docs/V0123_CAMPAIGN_BALANCE_EVIDENCE_TABLE.md`
- `docs/V0123_BALANCE_PLAY_SESSION_DECISION.md`
- `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`

New v0.12.2 balance watchpoint docs:

- `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`
- `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`
- `docs/V0122_HUMAN_BALANCE_NOTES.md`
- `docs/V0122_TUNING_DECISION.md`
- `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`

New v0.12.1 human-paced playtest docs:

- `docs/V0121_HUMAN_PACED_PLAYTEST_PROTOCOL.md`
- `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`
- `docs/V0121_PLAYTEST_POLISH_PLAN.md`
- `docs/V0121_TUNING_DECISION.md`
- `docs/V0121_VISUAL_QA_REVIEW.md`
- `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`

New v0.12 core feel docs:

- `docs/V012_CORE_GAME_FEEL_AUDIT.md`
- `docs/V012_BATTLE_READABILITY_AUDIT.md`
- `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`
- `docs/V012_VISUAL_READABILITY_NOTES.md`
- `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`

New v0.11.2 remote CI observation docs:

- `docs/V112_REMOTE_CI_OBSERVATION_CAPABILITY.md`
- `docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md`
- `docs/V112_WORKFLOW_STATIC_REVIEW.md`
- `docs/V112_CI_TIMEOUT_TUNING_REVIEW.md`
- `docs/V112_PREVIEW_HELPER_REMOTE_PORTABILITY_REVIEW.md`
- `docs/V112_CI_ARTIFACT_REMOTE_REVIEW.md`
- `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md`
- `docs/V112_CI_NO_FIX_DECISION.md`
- `docs/V112_REMOTE_CI_OBSERVATION_REPORT.md`

New v0.11.1 CI release matrix docs and workflow:

- `.github/workflows/ci.yml`
- `docs/V111_CI_MATRIX_AUDIT.md`
- `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`
- `docs/V111_CI_RELEASE_MATRIX_PLAN.md`
- `docs/V111_CI_ARTIFACT_STRATEGY.md`
- `docs/V111_CI_LOCAL_PARITY_CHECK.md`
- `docs/V111_CI_RELEASE_MATRIX_REPORT.md`
- `tools/smokePreview.ts`

New v0.11 technical reliability docs and tooling:

- `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`
- `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`
- `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`
- `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`
- `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`
- `docs/DEVELOPER_COMMAND_GUIDE.md`
- `docs/V11_TECHNICAL_RELIABILITY_REPORT.md`
- `tools/smokePreview.ts`

New v0.10 tutorial onboarding docs:

- `docs/V10_TUTORIAL_V2_AUDIT.md`
- `docs/V10_TUTORIAL_V2_PACING_PLAN.md`
- `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`
- `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`
- `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`
- `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`

New v0.9.1 controlled intake docs and folders:

- `art-review/README.md`
- `art-review/cinderfen-style-frames/README.md`
- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`
- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`
- `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`
- `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`
- `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md`
- `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`
- `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`
- `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`
- `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`
- `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`
- `tools/art-intake/StyleFrameReviewManifestTypes.ts`
- `tools/art-intake/validateArtIntake.ts`
- `tools/art-intake/validateArtIntake.test.ts`

New v0.9 controlled style-frame docs:

- `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`
- `docs/V09_CINDERFEN_VISUAL_PILLARS.md`
- `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`
- `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`
- `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`
- `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`
- `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`
- `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`
- `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`
- `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`
- `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`

New v0.8.2 source/license and screenshot coverage docs:

- `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`
- `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`
- `docs/V082_MANIFEST_METADATA_REFINEMENT.md`
- `docs/V082_MANIFEST_VALIDATION_HARDENING.md`
- `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`
- `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`
- `docs/VISUAL_RISK_REGISTER.md`
- `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`
- `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`

New v0.8.1 visual asset and screenshot QA docs:

- `docs/V081_EXISTING_ASSET_INVENTORY_AUDIT.md`
- `docs/V081_VISUAL_ASSET_MANIFEST_SCHEMA.md`
- `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`
- `docs/V081_RUNTIME_ASSET_USAGE_CROSSCHECK.md`
- `docs/V081_SCREENSHOT_QA_PLAN.md`
- `docs/V081_SCREENSHOT_QA_REVIEW.md`
- `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`
- `docs/ASSET_PROMPT_TEMPLATES.md`
- `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`

New v0.8 technical/visual foundation docs:

- `docs/V08_PERFORMANCE_AUDIT.md`
- `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`
- `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md`
- `docs/V08_VISUAL_DEBT_AUDIT.md`
- `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`
- `docs/V08_PROTOTYPE_VISUAL_READABILITY_DECISION.md`
- `docs/ART_DIRECTION_2026_BIBLE.md`
- `docs/ASSET_PIPELINE_PLAN.md`
- `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`
- `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`

New v0.7/v0.7.1/v0.7.2/v0.7.3 pressure docs:

- `docs/V07_ENEMY_PRESSURE_RESEARCH_AUDIT.md`
- `docs/V07_ENEMY_STRATEGIC_PRESSURE_SPEC.md`
- `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`
- `docs/V071_ENEMY_PRESSURE_FEEL_AUDIT.md`
- `docs/V071_PRESSURE_WARNING_VISIBILITY_AUDIT.md`
- `docs/V071_PRESSURE_ACTION_PROMOTION_GATE.md`
- `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`
- `docs/V072_PRESSURE_PLAY_REVIEW_PLAN.md`
- `docs/V072_PRESSURE_BROWSER_REVIEW_NOTES.md`
- `docs/V072_CINDERFEN_CROSSING_PRESSURE_REVIEW.md`
- `docs/V072_CINDERFEN_WATCH_PRESSURE_REVIEW.md`
- `docs/V072_PRESSURE_READABILITY_POLISH_DECISION.md`
- `docs/V072_RETINUE_TRAINING_YARD_PRESSURE_REVIEW.md`
- `docs/V072_GREEDY_FAST_PRESSURE_REVIEW.md`
- `docs/V072_PRESSURE_NEXT_ACTION_DECISION.md`
- `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`
- `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_PROTOCOL.md`
- `docs/V073_PRESSURE_REVIEW_SETUP.md`
- `docs/V073_CINDERFEN_CROSSING_REAL_INPUT_REVIEW.md`
- `docs/V073_CINDERFEN_WATCH_REAL_INPUT_REVIEW.md`
- `docs/V073_STRATEGY_PROFILE_PRESSURE_REVIEW.md`
- `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`
- `docs/V073_EVIDENCE_BACKED_PRESSURE_POLISH_DECISION.md`
- `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`
- `docs/V08_DIRECTION_DECISION_BRIEF.md`

Recent tutorial shell docs:

- `docs/TUTORIAL_PLAYABLE_SHELL_PLAN.md`
- `docs/TUTORIAL_SAVE_PERSISTENCE_AUDIT.md`
- `docs/TUTORIAL_CONTENT_VALIDATION_GATE.md`
- `docs/TUTORIAL_READABILITY_SURROGATE_REVIEW.md`
- `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`
- `docs/V06_TUTORIAL_FEEL_AUDIT.md`
- `docs/TUTORIAL_E2E_RUNTIME_REVIEW.md`
- `docs/COMMAND_LOG_V1_TEST_ONLY_PLAN.md`
- `docs/COMMAND_LOG_V1_REPORT.md`
- `docs/DESKTOP_2026_VISUAL_DIRECTION.md`
- `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`
- `docs/V10_TUTORIAL_V2_AUDIT.md`
- `docs/V10_TUTORIAL_V2_PACING_PLAN.md`
- `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`
- `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`
- `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`
- `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`
- `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`

The prior safety checkpoint is the **v0.5 save/content-validation gate** on 2026-05-08. It preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, and v0.4 technical groundwork while adding save fixtures, stronger content validation, a standalone content validation script, campaign graph/reward checks, command-log feasibility planning, simulator determinism checks, and one approved future vertical-slice candidate.

New v0.5 gate docs:

- `docs/SAVE_COMPATIBILITY_AUDIT.md`
- `docs/V05_SAVE_FIXTURE_PLAN.md`
- `docs/V05_SAVE_FIXTURE_REPORT.md`
- `docs/V05_CONTENT_VALIDATION_AUDIT.md`
- `docs/CAMPAIGN_GRAPH_REWARD_GATE.md`
- `docs/COMMAND_LOG_REPLAY_FEASIBILITY.md`
- `docs/SIMULATOR_DETERMINISM_GATE.md`
- `docs/V05_VERTICAL_SLICE_CANDIDATE.md`
- `docs/TUTORIAL_PROVING_GROUNDS_BRIEF.md`
- `docs/V05_SAVE_CONTENT_VALIDATION_GATE_REPORT.md`

Latest final v0.5 verification: `npm test` 298 tests, `npm run build`, `npm run validate:content`, `npm run test:e2e:smoke` 10 tests in 4.5m, `npm run test:e2e:release` 59 tests in 28.4m, `npm run test:e2e:release:shard1` 49 tests in 23.9m, `npm run test:e2e:release:shard2` 10 tests in 4.4m, `npm run playtest:sim` 255 deterministic runs, `git diff --check`, and production preview smoke passed. The current build output is app JS about 445.42 kB / 119.69 kB gzip, `vendor-phaser` about 1,481.79 kB / 339.86 kB gzip, and CSS about 42.04 kB / 8.74 kB gzip. The known Vite warning remains isolated to the Phaser vendor chunk.

Recommended visual follow-up after v0.9.1: **v0.9.2 controlled Cinderfen style-frame candidate review**, only after source/license-documented candidates are provided. Keep runtime gameplay unchanged and avoid workers, construction, new units, new maps, rewards, save changes, stronger pressure actions, desktop packaging, engine switching, runtime art replacement, large binaries, and broad systems.

The current release baseline is still **v0.3.1 Polish Release - frozen** for content, with v0.10 as the latest player-facing onboarding refinement on top of the existing Tutorial / Proving Grounds shell. v0.3 remains the frozen Cinderfen Route Baseline content release; v0.3.1 is the polish/readability/performance-audit/test-maintenance release on top of that content baseline. The v0.5 gate is the active post-freeze safety/planning baseline, and the Tutorial / Proving Grounds shell is the first safe onboarding vertical slice on top of it.

Latest checkpoint verification: 2026-05-11 v0.10 tutorial onboarding final gate. Final gates passed `npm test` with 46 files / 351 tests, `npm run build` with the known Phaser vendor warning, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke`, `npm run test:e2e:release`, both 2-way release shards, all three 3-way release shards, `npm run visual:qa` with 18 indexed review screenshots and zero recorded browser console errors, `npm run playtest:sim`, `git diff --check`, and production preview smoke at `http://127.0.0.1:4173/`. No workers, real enemy construction, new maps, new units, new factions, rewards, save-version changes, tutorial completion persistence, campaign progression, diplomacy, procedural generation, crafting, monetization code, multiplayer, desktop packaging, engine switch, external assets, generated art, imported art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, graphics overhaul, full UI redesign, or broad systems were added.

The current playable v0.3 Chapter 2 slice ends at Cinderfen Aftermath. Any later Cinderfen nodes should stay clearly marked as upcoming and must not launch missing maps or unimplemented content.

The current visible product baseline remains `Prototype v0.3` with the menu subtitle `Cinderfen Route Baseline`. v0.2 remains the previous systems baseline; v0.3 is the frozen Cinderfen route baseline; v0.3.1 is the frozen polish and verification layer for that route.

Completed v0.2.1 stabilization remains part of the baseline:

- Rival/Nemesis Persistence V1: completed.
- Rival Rewards and Trophies V1: completed.
- CampaignRules split into focused pure-rule modules behind a compatibility facade: completed.
- HUD/fog polish for command hover stability, side-panel scroll preservation, and captured resource-site visibility: completed.
- Permanent Playwright regression coverage for the HUD/fog polish: completed.

Completed v0.3 Cinderfen route:

- [x] Cinderfen Overlook: `cinderfen_overlook` is a playable Chapter 2 preparation event after `ashen_outpost`, with three baseline choices plus the optional Malrec trophy consequence.
- [x] Cinderfen Waystation: `cinderfen_waystation` is a compact town/service node after `cinderfen_overlook`, with Marsh Guides, Ash Filters, Refugee Scouts, and Shrine Attunement using existing campaign choice/modifier/save rules.
- [x] Cinderfen Crossing: `cinderfen_crossing` is playable after `cinderfen_overlook` and launches the authored `cinderfen_causeway` / **Cinderfen Crossing** battle map.
- [x] Cinderfen Watch: `cinderfen_watch` is playable after `cinderfen_crossing` and launches the compact `cinderfen_watchpost` / **Cinderfen Watch** battle map.
- [x] Cinderfen Aftermath: `cinderfen_aftermath` is a compact non-battle event after `cinderfen_watch`, with three modest baseline once-only choices plus a tiny optional Malrec trophy reputation choice using existing resource, reward, reputation, modifier, save, and duplicate-prevention rules. It is the end of the current playable Cinderfen route.
- Implemented Cinderfen identity hook: the Cinder Shrine first-capture Aether surge exists as a small battle-local tactical feature.
- Baseline document: `docs/V03_CINDERFEN_ROUTE_BASELINE.md`.
- Slice report: `docs/CHAPTER_2_CINDERFEN_SLICE_REPORT.md`.
- Automated review: `docs/CINDERFEN_AUTOMATED_REVIEW.md`.
- Working proposal: The Cinderfen Road remains a small ash-glass wetland/causeway route that reuses the current campaign, rival, trophy, Stronghold, retinue, reputation, enemy hero, and affixed-loot systems.
- Default implementation stance: use existing Free Marches and Ashen Covenant content first; do not start a full new faction.
- Current slice result: `cinderfen_overlook`, `cinderfen_waystation`, `cinderfen_crossing`, `cinderfen_watch`, and `cinderfen_aftermath` are implemented. Cinderfen Crossing and Cinderfen Watch have map/objective/reward validation, Cinderfen appears in e2e coverage, both Cinderfen battles are included in the Chapter 2 simulator profile with one eligible Waystation Shrine Attunement service profile, and the aftermath is event-only. No new faction, worker, enemy construction, diplomacy, procedural generation, crafting, or broad army management has been added.

Completed Tutorial / Proving Grounds shell and v0.6 onboarding foundation:

- [x] Main-menu Tutorial launch surface.
- [x] Validated playable tutorial metadata for `proving_grounds_basics`.
- [x] Existing-content tutorial launch on `first_claim` with transient Warlord Aster data.
- [x] Lightweight tutorial overlay and linear twelve-step objective model.
- [x] No-reward, non-persistent completion and exit back to main menu.
- [x] Smoke, layout, content-validation, unit, and save-persistence coverage.
- [x] Tutorial report: `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`.
- [x] v0.6 copy/layout/no-reward clarity polish.
- [x] Test-only semantic command-log V1 for one tutorial completion smoke path.
- [x] Tutorial accessibility checks for live-region semantics and explicit button labels.
- [x] Desktop/2026 visual direction plan, planning only.
- [x] v0.6 onboarding/testing report: `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`.

Completed v0.7 Enemy Strategic Pressure V1:

- [x] Research audit of current enemy AI, waves, personalities, maps, and simulator telemetry.
- [x] Tight design spec for data-driven pressure plans, allowed triggers/actions, forbidden actions, tests, simulator, e2e, and rollback.
- [x] Data model and two V1 plans: `causeway_contest_pressure` and `ashen_watch_captain_pressure`.
- [x] Content validation for plan references and forbidden worker/construction/economy fields.
- [x] Campaign-only runtime tracker, battle warning copy, pressure telemetry, and one safe next-wave timing nudge.
- [x] Pressure-aware defeat advice only after a triggered pressure stage.
- [x] Simulator telemetry and generated pressure balance gate.
- [x] Targeted e2e release coverage for Cinderfen Watch pressure and Tutorial/skirmish no-pressure guards.
- [x] v0.7 report: `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`.

Completed v0.7.1 Enemy Pressure Feel Review:

- [x] Pressure feel audit for current telemetry, Cinderfen identity, Fast Army, Greedy Economy, retinue/Stronghold, tutorial, and skirmish protections.
- [x] Clearer pressure warning and defeat-tip copy that avoids implying live construction, reinforcement, or route-contest AI.
- [x] Pressure status priority with a longer read window, plus objective priority above pressure to preserve `Cinder Shrine Surge` and capture feedback.
- [x] Focused pressure e2e hardening for warning visibility and Tutorial/skirmish no-pressure guards.
- [x] Clearer simulator report wording and readable pressure plan/stage labels.
- [x] No-tuning pressure balance review.
- [x] Action promotion gate keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- [x] v0.7.1 report: `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`.

Completed v0.7.2 Human-Paced Cinderfen Pressure Review:

- [x] Pressure play review protocol and browser review notes.
- [x] Seeded browser/Playwright Cinderfen Crossing warning review with screenshot evidence and no-change decision.
- [x] Seeded browser/Playwright Cinderfen Watch warning review with screenshot evidence and no-change decision.
- [x] Explicit pressure readability no-change decision.
- [x] Retinue + Training Yard II pressure review, documented as a saved-progress power watchpoint rather than pressure bug.
- [x] Greedy Economy and Fast Army pressure review, with no timing/copy/mechanics tuning.
- [x] Pressure next-action decision gate keeping `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- [x] v0.7.2 report: `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`.

Completed v0.7.3 Real-Input Cinderfen Pressure Playtest:

- [x] Controlled browser-input Crossing and Watch pressure reviews.
- [x] Manual pressure checklist for Emmanuel.
- [x] Strategy-profile no-change review.
- [x] v0.8 direction brief.
- [x] v0.7.3 report: `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`.

Completed v0.8 Technical Performance And Visual Foundation:

- [x] Performance/bundle audit refresh.
- [x] E2E runtime/shard audit and optional 3-shard release scripts.
- [x] Visual debt and visual scale/readability audits.
- [x] No-code visual readability decision.
- [x] 2026 art direction bible.
- [x] Asset pipeline plan.
- [x] Cinderfen visual rework spec.
- [x] v0.8 report: `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`.

Completed v0.8.1 Visual Asset Manifest And Screenshot QA Gate:

- [x] Existing asset inventory audit.
- [x] Typed visual asset manifest schema and initial 89-entry manifest.
- [x] Visual asset metadata validation inside `npm run validate:content`.
- [x] Runtime asset usage cross-check.
- [x] Optional `npm run visual:qa` screenshot capture harness.
- [x] Screenshot QA review.
- [x] Cinderfen visual asset replacement backlog.
- [x] Future-safe asset prompt/spec templates.
- [x] v0.8.1 report: `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`.

Completed v0.8.2 Visual Source/License Review And Screenshot Coverage Expansion:

- [x] Source/license review plan and audit.
- [x] Manifest `reviewStatus` and `sourceReviewNotes` metadata.
- [x] Hardened source/license production-safety validation.
- [x] Expanded optional `npm run visual:qa` coverage to 18 indexed screenshots.
- [x] Extended screenshot QA review.
- [x] Visual risk register.
- [x] v0.9 controlled visual sprint brief.
- [x] v0.8.2 report: `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`.

Completed v0.9 Controlled Cinderfen Style-Frame Sprint:

- [x] Cinderfen style-frame research packet.
- [x] Cinderfen visual pillars and style rules.
- [x] Terrain material sheet spec.
- [x] Cinder Shrine/capture-site landmark spec.
- [x] Ashen outpost architecture spec.
- [x] Unit/building scale reference.
- [x] Safe future prompt pack.
- [x] Future Cinderfen manifest templates.
- [x] Screenshot acceptance criteria.
- [x] Future-only visual replacement implementation plan.
- [x] v0.9 report: `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`.

Reference docs:

- v0.3.1 plan: `docs/V031_POLISH_PLAN.md`.
- v0.3.1 release report: `docs/V031_POLISH_RELEASE_REPORT.md`.
- v0.4 direction brief: `docs/V04_DIRECTION_BRIEF.md`.
- v0.4 performance plan: `docs/V04_PERFORMANCE_IMPLEMENTATION_PLAN.md`.
- Route-complete guidance after Cinderfen Aftermath should remain clear: Cinderfen route secured, Chapter 2 slice complete, and more Cinderfen content coming later.

Completed v0.3.1 polish release:

- [x] v0.3.1 polish release is frozen.
- [x] Mobile/readability audit completed for Cinderfen menu, campaign, battle HUD, and Results surfaces.
- [x] Existing Cinderfen copy/hierarchy polished for Overlook, Waystation, Crossing, Watch, Aftermath, route-complete guidance, and Results.
- [x] Performance bundle audit completed for the known Vite large-chunk warning; no risky optimization implemented.
- [x] E2E runtime audit completed; safe shared setup/helper cleanup applied without deleting meaningful coverage.
- [x] Final automated verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, `git diff --check`, and production preview smoke.

Completed v0.4 technical groundwork:

- [x] Direction brief created comparing performance optimization, e2e lane split, human readability/accessibility polish, and small content continuation.
- [x] Explicit Playwright lanes added: `test:e2e:smoke`, `test:e2e:layout`, `test:e2e:deep`, and `test:e2e:release`.
- [x] Full release-gate e2e coverage preserved at 59 tests; smoke lane is available for frequent iteration but does not replace the release gate.
- [x] Performance implementation plan created for measured bundle optimization.
- [x] First approved optimization implemented: Phaser is split into a `vendor-phaser` chunk through Vite/Rollup `manualChunks`.
- [x] Bundle analyzer script and report added for the v0.4 technical baseline.
- [x] Test/dev hook audit completed; no accidental large production leak was found.
- [x] Analyzer-backed second optimization decision recorded as no additional code optimization.
- [x] Minimal 2-shard Playwright release-gate scripts added for CI: `test:e2e:release:shard1` and `test:e2e:release:shard2`.
- [x] Bundle result documented: app JS is about 435.50 kB / 116.99 kB gzip; Phaser vendor JS is about 1,481.79 kB / 339.86 kB gzip; the known Vite warning remains on the vendor chunk.
- [x] Checkpoint verification passed: `npm test`, `npm run build`, `npm run test:e2e:smoke`, final `npm run test:e2e:release` rerun, `npm run playtest:sim`, and `git diff --check`.
- [x] Clean verification refresh passed on 2026-05-07: `npm test` 270 tests, `npm run build`, `npm run test:e2e:smoke` 10 tests, `npm run test:e2e:release` 59 tests in 28.1m, `npm run playtest:sim` 255 deterministic runs, and `git diff --check`.
- [x] v0.4 performance/e2e sharding checkpoint passed on 2026-05-07: `npm test` 270 tests, `npm run build`, `npm run test:e2e:smoke` 10 tests, `npm run test:e2e:release` 59 tests in 28.8m, both release shards, `npm run playtest:sim` 255 deterministic runs, `git diff --check`, and production preview smoke.
- [x] v0.4 accessibility/readability polish completed for Settings labels, setting hints, UI Scale explanation, Fog of War Override labels, and keyboard/control reference without gameplay or save changes.
- [x] v0.4 save compatibility audit completed; current save version stays at 2 and a test now preserves valid Chapter 2 selected chapter/node state.
- [x] v0.4 route-feel surrogate review completed with `watch, not blocked` status and no balance change.
- [x] Full-game roadmap architecture docs updated for future workers/economy, enemy construction, faction expansion, campaign chapters, diplomacy/reputation, tutorial/onboarding, crafting/affix rerolling, asset pipeline, performance, AI personality expansion, procedural/skirmish maps, modding/data-driven content, monetization/packaging, multiplayer feasibility, and save/content-validation gates.
- [x] v0.4 tiny polish backlog created with safe, medium-risk, high-risk, and blocked triage.

Must remain stable after the v0.3 freeze:

- v0.3 automated baseline should stay green: `npm test`, `npm run build`, full Playwright e2e, and `npm run playtest:sim`.
- Rival/retinue readability review remains current, including capacity, death/removal, deployed retinue identity, rival preview, duplicate reward prevention, trophies, and defeat/readiness copy.
- HUD command hover stability, side-panel scroll preservation, and captured-site fog visibility remain covered by permanent e2e regression tests.
- Ashen Outpost, mixed retinue, Training Yard II, Quartermaster II, rival rewards, and first-defeat trophy clarity remain under human-review watch before numeric tuning.

Explicitly postponed after the v0.3 freeze:

- Workers.
- Enemy construction or rebuilding.
- Full new faction.
- Diplomacy or alliance simulation.
- Procedural campaign or procedural maps.
- Crafting, durability, affix rerolling, or broader loot complexity.
- Full trophy room.
- Broad army-management or retinue replacement systems.

Recommended focus after the v0.3.1 freeze:

- Keep v0.3 and v0.3.1 frozen, compact, and data-driven.
- Use the v0.4 technical groundwork checkpoint as the new technical baseline.
- Choose between CI workflow wiring for the shard scripts, human readability/accessibility review, and a separate test-harness/content-validation hardening plan.
- If planning v0.4, start from the frozen route's human-readability findings rather than adding broad systems immediately.
- If optimizing technically, change only one measured optimization at a time and keep release-gate e2e green.
- Play Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost with no retinue, one Veteran Militia, one Veteran Ranger, and mixed retinue.
- Specifically watch Gorak Emberhand, Veyra of the Cinders, and Captain Malrec for scout readability, nameplate clarity, ability readability, XP/objective payoff, first-defeat trophy clarity, late-attack fairness, and whether +5% rematch modifiers are noticeable without feeling mandatory.
- Confirm Retinue feels helpful without becoming mandatory, especially on Ashen Outpost.
- Review whether permanent retinue death feels clear enough before adding wounded timers or replacement UI.
- Recheck command hover stability, side-panel scroll preservation, and captured-site fog readability with human mouse movement even though automated regression tests now cover the core cases.
- Keep bonuses modest, visible in UI, and represented in telemetry.
- Human-paced campaign QA should still review Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, Ashen Outpost, rival commanders, the two-tier Stronghold paths, reputation hooks, and affixed reward readability before larger balance changes.
- Keep technical risk work scoped around `HUD`, `contentValidation`, `BattleScene`, `src/game/core/progression/ItemRewardRules.ts`, `RetinueRules`, `RivalRules`, and `CampaignRules`.
- Do not move into workers, enemy construction, new factions, new maps, diplomacy, procedural campaign, procedural maps, crafting, durability, broad loot complexity, full trophy rooms, or broad army-management systems as an immediate post-freeze step.
- Treat the remaining Vite large-chunk warning as a known Phaser vendor warning, not a failing roadmap item, unless a second focused bundle optimization becomes the explicit task.

## Phase 0: Project Foundation

- Phaser/Vite/TypeScript setup.
- Scene management.
- Data architecture.
- Save system shell.

## Phase 1: Playable Skirmish Prototype

- Hero.
- Units.
- Movement.
- Selection.
- Combat.
- Capture resources.
- Basic buildings.
- Enemy AI.
- Win/loss.
- Five authored battlefields now prove the map pipeline: First Claim, Broken Ford, Ashen Outpost, Chapter 2 Cinderfen Crossing, and Chapter 2 Cinderfen Watch.
- Ashen Outpost serves as the first campaign milestone/boss-style fortress assault, with secondary objective tracking for map-specific goals.

## Phase 2: Hero RPG Depth

- Full stats.
- Multiple abilities.
- Skill trees.
- Items.
- Equipment.
- Hero portraits.
- Level-up choices.
- Scars and titles.
- Reputation hooks.
- Unit Veterancy V1 is implemented as battle-local XP/ranks/results summaries. Retinue Camp V1 selectively saves a small number of campaign veterans. Enemy Hero / Rival Commander V1 gives important Ashen battles named commanders without adding enemy construction. Rival/Nemesis Persistence V1 now persists commander outcomes and small rematch modifiers, while Rival Rewards and Trophies V1 adds one-time first-defeat rewards and save-backed trophies.

## Phase 3: Faction Expansion

- 3 complete factions:
- Free Marches.
- Ashen Covenant.
- Sylvan Concord.
- Unique units.
- Unique buildings.
- Unique economy twist.
- Unique faction spell/technology.
- Explicit faction identity documents covering economy, combat rhythm, strengths, and weaknesses.

## Phase 4: Campaign Map

- Node-based overworld. Skeleton implemented with eight Border Marches nodes.
- Locations. First pass includes battle, shrine, and event node handling.
- Ashen Outpost now uses a dedicated fortress map as the current mini-campaign finale.
- Simple data-driven event choices with requirements, costs, rewards, reputation changes, and node unlocks.
- Reputation ranks and small data-driven effects for Marcher Camp discounts, Stronghold Crown discounts, Chapel Aether bonuses, and Ashen hostile pressure.
- Stronghold Development with five Tier I upgrades, five matching Tier II upgrades, prerequisite locks, campaign-resource spending, save-backed ranks, and battle-launch effects.
- Battle-local Unit Veterancy V1 with Notable Veterans in Results, plus Retinue Camp V1 for a capped set of saved campaign veterans.
- Enemy Hero / Rival Commander V1 with three named Ashen commanders, campaign node assignments, scout/battle/results feedback, modest abilities, and playtest telemetry.
- Rival/Nemesis Persistence V1 with campaign-save rival records, Rival Intel, node previews, Results outcome copy, escaped/triumphant rematch modifiers, and playtest telemetry fields.
- Rival Rewards and Trophies V1 with data-driven first-defeat XP/resource/reputation/item rewards, duplicate prevention, save-backed trophy records, Campaign Map trophy display, Results reward/trophy copy, and playtest telemetry fields.
- Save-backed node completion, unlocks, selected node, one-time node rewards, and once-only choice claims.
- Campaign battle launches through the shared `BattleLaunchRequest` path.
- Chapter 2 has a compact playable Cinderfen slice: `cinderfen_overlook` is the implemented event gate after Ashen Outpost, `cinderfen_crossing` unlocks after that event to launch `Cinderfen Crossing`, `cinderfen_watch` unlocks after Cinderfen Crossing to launch `Cinderfen Watch`, and `cinderfen_aftermath` unlocks after Cinderfen Watch as a non-battle consequence node.
- `cinderfen_waystation` is the implemented Chapter 2 support/town node after Cinderfen Overlook. It spends campaign resources on modest Cinderfen-only preparation without adding a broad shop, new faction, workers, enemy construction, diplomacy, procedural generation, or crafting.
- Cinderfen Crossing uses the Cinder Shrine first-capture Aether surge as its compact battle-local tactical identity feature.
- The only returning-rival consequence in Chapter 2 is the optional Malrec trophy event choice; there is no new Chapter 2 rival system.
- Quests.
- Shops.
- Temples.
- Ruins.
- Mercenary contracts.
- Holy orders.
- Cursed lands.
- Ancient threat encounters.
- Broader faction reputation arcs beyond the current rank/effect hooks.
- Alliances and betrayals.
- Invasions.
- Deeper random events and multi-step dialogue.
- Persistent consequences.

## Phase 5: Procedural Maps

- Random map generator.
- Biomes.
- Resource placement.
- Neutral camps.
- Enemy start positions.
- Difficulty scaling.

## Phase 6: Advanced AI

- AI personalities.
- Rush/economy/turtle/magic styles.
- Scouting.
- Counter-unit logic.
- Retreat logic.
- Hero build logic.

## Phase 7: Content Tools

- Map editor.
- Faction editor.
- Unit editor.
- Scenario editor.
- Mod loading.
- Data validation for mod packs.
- Non-coder content templates.

## Phase 8: Presentation

- Real art.
- Animation.
- Sound effects.
- Music.
- Better UI.
- Dedicated UI art kit with panel frames, button states, resource frames, dividers, tooltip frames, minimap frame, ability slots, inventory slots, victory panel, and defeat panel.
- Better UX.
- Tutorial.

## Phase 9: Steam-Ready Single-Player

- Achievements.
- Settings.
- Save slots.
- Campaign polish.
- Balance pass.
- Performance optimization.
- Packaging.

## Phase 10: Multiplayer Exploration

- Local network prototype.
- Deterministic simulation research.
- Lockstep or server-authoritative decision.
- Multiplayer only after single-player is strong.
