# v0.380 Design Notes

The v0.379 Godot captures exposed two source defects rather than presentation-only defects:

1. the dense terrain mesh rendered with a strong repeated triangular/corrugated pattern;
2. road grading raised the river bed at the crossing, visually splitting the water into disconnected pieces.

v0.380 fixes those defects in the authored source. It does not add buildings, units or gameplay.

## Human visual checks

- terrain must read as broad low-poly landform, not ribbed fabric;
- water must remain a single continuous course through the bridge crossing;
- no terrain plug may block the river beneath the bridge;
- road must approach both landings but stop influencing the river bed;
- bridge and road alignment must read clearly at RTS distance;
- pale wash, visible map boundary or overly distant camera remain presentation failures.
