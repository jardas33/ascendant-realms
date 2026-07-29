# v0.377 Reference Implementation Rules

## 1. Reference status

The PNGs in this directory are binding visual-direction references, not runtime
assets. They must not be imported into the playable world as textures, traced
into billboard scenery or presented as evidence of implementation.

Codex must open and inspect the images directly before authoring geometry.

## 2. What must be matched

### Match strongly

- large-scale shape language;
- role silhouettes;
- relative height and footprint;
- terrain depth and natural transitions;
- bridge-to-bank contact;
- road-to-ground integration;
- resource and hostile-territory readability;
- palette hierarchy;
- environmental density and clustering;
- overview readability.

### Simplify freely

- tiny surface ornaments;
- exact stone counts;
- exact plank counts;
- close-up weathering;
- minor props that do not affect the RTS view;
- smoke, particles and ambient animation;
- fine foliage density.

### Do not imitate literally

- the concept-sheet background;
- visible floating diorama edges;
- labels and panel borders;
- impossible micro-detail at gameplay distance;
- painterly artifacts that do not correspond to buildable geometry.

## 3. Required authored quality

Geometry may be low-poly, but it must be deliberately authored. Large forms
must not look like untouched cubes, strips or primitive planes.

A technically valid low-poly result fails when:

- the terrain is visually flat;
- the road is a thin overlay;
- the river is a colored strip;
- the bridge floats or lands abruptly;
- materials have no value hierarchy;
- structures lack role-specific masses;
- random props are used to simulate authored identity.

## 4. Comparison method

Every visual checkpoint must include:

- reference image beside the render at comparable scale;
- a clean render without annotations;
- a grayscale render;
- a silhouette or height/section view where relevant;
- an honest defect ledger.

Do not award similarity based on the scene tree or written intent. Score only
what is visible.

## 5. Camera discipline

Use a stable orthographic-oblique RTS camera approximately 35–50 degrees above
horizontal. Normal proof framing must keep infrastructure readable and must hide
terrain boundaries.

Asset-isolation renders may use a neutral background and visible asset edges,
but the connected in-world render must not read as a floating test board.

## 6. Materials

Use a compact family of coherent materials:

- granite: multiple grey values with darker contact and restrained moss;
- slate: dark blue-grey with readable ridge/eave breakup;
- limewash: muted warm plaster with subtle repair variation;
- timber: medium and dark structural values;
- dirt: compacted earth with stones and edge encroachment;
- wet bank: darker, cooler and more desaturated than ordinary dirt;
- water: subdued blue-green, never bright cyan;
- gold: limited warm ochre highlights embedded in rock;
- Ashen materials: charcoal, ash, rust and restrained ember accents.

## 7. Fail-closed rule

Green CI, successful exports and valid images never override a visual failure.
A blocked result is correct when the visible target has not been reached.
