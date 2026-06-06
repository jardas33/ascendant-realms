@echo off
setlocal
cd /d "%~dp0"
echo Ascendant Realms v0.146 private Godot runtime-art pipeline comparator.
echo Approaches: ORTHO_3D_MESH, BILLBOARD_2D_ATLAS, HYBRID_3D_WORLD_BILLBOARD_UNITS.
echo This wrapper does not replace the stabilized Salto review launcher and does not import reference art.
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\runGodotRuntimeArtComparatorBenchmarkWindows.ps1" %*
