# Gameplay invariants

- Only authored secondary scenery placement changed, in one composition script.
- No building, unit, resource, spawn, commander, save, stable-ID, economy, combat, victory, fog, camera-control, or minimap code changed.
- The settlement remains 14 existing Astra instances; no new GLB, texture, material, Blender export, or import setting was added.
- Presentation instances continue through the existing presentation-only path and do not become collision, navigation, resource, or gameplay objects.
- The capture used the same Hollowspan production scene and the same Barrosan-vs-Lioraen Easy standard setup for baseline and candidate.
