# v0.374 Barrosan RTS Art Bible

## Identity

Barrosans are a northern Portuguese/highland frontier culture: practical,
agricultural, weathered and defensible. Their settlement is warm and inhabited,
but it expects danger. Granite, dark slate, restrained timber, limewash, worked
earth and damp highland vegetation are the recurring grammar.

Avoid generic bright fantasy villages, showroom spacing, saturated orange roofs,
science-fiction infrastructure, glossy mobile-game materials and disconnected
catalogue pieces.

## Architecture

- Granite or fieldstone foundations visibly carry every major structure.
- Limewashed or muted plaster walls are broken by restrained repairs and shade.
- Timber framing, braces, lintels, eaves and practical work structures are
  visible but not decorative noise.
- Dark slate or weathered clay roofs have a real ridge, two planes, overhang,
  fascia and dark eave underside.
- Economic buildings are lower and broader; military buildings have practical
  yards; defensive buildings are vertical and compact; domestic buildings are
  low, warm and road-facing.
- The Keep owns the tallest civic mass. Barracks owns the military yard. Mine
  owns the extraction portal and controlled cyan Lume.

## Environment

The battlefield is one continuous, uneven landform. Broad grass, packed earth,
mud, stone and worked yards blend through irregular authored transitions. Roads
are worn routes embedded in terrain, not painted strips. Rivers sit below land,
with shaped banks, wet-dark material, reeds, moss and intermittent stone.

Settlement yards are composed around thresholds and work zones. Agricultural
edges, forest boundaries and highland rocks provide depth without noise. Hostile
territory uses crude defensive logic, darker material and functional barricades,
not market props and loose fence fragments.

## Resources

- Gold: warm ochre metal, compact mine/cart/store cluster, readable silhouette;
  never a random pile of yellow props.
- Stone: pale-to-dark granite outcrop with broken faces, extraction scars and
  cart access.
- Timber: stacked logs, rough frames and saw/work yard; warm brown with dark
  structural contrast.
- Food: raised granary/barn, sacks, hay, fields and broad loading threshold.
- Lume: scarce cyan crystal concentrated at an extraction site; no global glow.

Every resource must be readable at gameplay distance without relying on labels.

## Units

| Unit | Silhouette | Palette and role read | Animation need |
| --- | --- | --- | --- |
| Worker | Compact upright body, visible tool, lighter load | muted linen, brown leather, warm metal | idle, walk, work, carry, build |
| Militia | Broader guarded stance, shield/spear or polearm | iron, dark red, worn leather | idle, walk, brace, attack-ready, hit, death |
| Ashen Raider | Leaner irregular profile, harsh asymmetry, hooked weapon | charcoal, ash, rust, ember accent | idle, walk, raid, attack, hit, death |
| Commander/Hero | Taller readable crest or cloak, reserved accent | Barrosan civic color with strong face/weapon read | idle, walk, command, attack, hit, death |
| Ranged/Specialist | Clear bow/tool silhouette and lighter stance | faction palette plus one role accent | idle, walk, aim, attack, hit, death |

Units must have visible feet/contact, a consistent gameplay scale and a faction
silhouette that survives a grayscale overview. Temporary imported units may fill
the gameplay gap, but are not final Barrosan art.

## Camera and presentation

- Primary: stable orthographic oblique/isometric RTS camera.
- Target pitch: approximately 35-50 degrees from horizontal, with enough side
  face to read building volume and enough top plane for tactics.
- Preserve a useful overview and close role reads; no cinematic lens or free
  camera requirement.
- At normal gameplay zoom a worker should be roughly 18-32 screen pixels tall;
  a one-storey building should be roughly 70-150 pixels tall depending on role.
- No more than roughly one quarter of an overview should be low-information empty
  space.
- Important roles dominate secondary decoration through value, silhouette and
  controlled contrast.
- Warm directional key plus cool restrained fill; contact shadows are soft and
  consistent, never black zones.

## Material palette

| Family | Target colors | Use |
| --- | --- | --- |
| Limewash | #D9C89E, #E7D7B1, #9A7654 | walls and repaired plaster |
| Granite | #777267, #AAA18A, #303437, moss #59644B | foundations, bridge, outcrops |
| Timber | #6F4126, #8A6747, #392217 | frames, doors, yards, braces |
| Slate/roof | #3C4140, #59605B, dark #261D1A | roof planes and eaves |
| Dirt/grass | #735437, #8B6844, #647747, #465A39 | routes, yards and terrain |
| Water | #245866, deep #183D49, glint #4B8A91 | riverbed and water |
| Accent | iron red #8D3028, ochre #C89B48, cyan #4DD6C9 | banners, trade, Lume only |

Relative value matters more than exact color. Terrain remains quieter than
buildings and units; Lume occupies little screen area.

## Detail and noise limits

Every major building needs a foundation, dark threshold, two timber values,
roof ridge/fascia/eaves and three role-specific exterior detail groups. Props
cluster around entrances, work yards and damp edges. Repetition should vary in
scale and orientation. If a detail helps only a close-up but harms the overview,
remove it.

## Acceptance test

Review the connected settlement at actual RTS zoom in grayscale and in color.
The reviewer must identify the Keep, barracks, house, resource, bridge, river,
worker, militia and hostile territory before reading labels. A building that
only works as an isolated beauty render is not production-ready.
