extends RefCounted

## A heraldic charge for each faction, drawn as vector shapes so it stays
## crisp at any size: the Barrosan bull's horns, the Lioraen spring leaf,
## the Vorthak violet flame, the Ironmaw broken chain, the Moura fountain,
## the Granitborn castro tower, the Dominion sun, the Wolfveil moon, the
## Compaña candle and the Careto bell. Used on crests wherever a faction
## has no painted crest art.

static func draw(ci: CanvasItem, race: String, c: Vector2, r: float, col: Color) -> void:
	var dark := Color(0.04, 0.03, 0.02, 0.9)
	match race:
		"barrosan":
			# Bull's head: a broad brow and two sweeping horns.
			ci.draw_arc(c + Vector2(0, r * 0.35), r * 0.85, PI * 1.12, PI * 1.88, 20, col, r * 0.2, true)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.35, -r * 0.05), c + Vector2(r * 0.35, -r * 0.05), c + Vector2(r * 0.22, r * 0.7), c + Vector2(-r * 0.22, r * 0.7)]), col)
			ci.draw_circle(c + Vector2(-r * 0.12, r * 0.18), r * 0.07, dark)
			ci.draw_circle(c + Vector2(r * 0.12, r * 0.18), r * 0.07, dark)
		"lioraen":
			# A spring leaf with its vein.
			var leaf := PackedVector2Array()
			for k in 17:
				var t := float(k) / 16.0
				leaf.append(c + Vector2(sin(t * PI) * r * 0.55, -r * 0.85 + t * r * 1.6))
			for k in 17:
				var t2 := 1.0 - float(k) / 16.0
				leaf.append(c + Vector2(-sin(t2 * PI) * r * 0.55, -r * 0.85 + t2 * r * 1.6))
			ci.draw_colored_polygon(leaf, col)
			ci.draw_line(c + Vector2(0, -r * 0.7), c + Vector2(0, r * 0.9), dark, 1.6, true)
		"vorthak":
			# A violet flame: three tongues.
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 0.95), c + Vector2(r * 0.35, -r * 0.2), c + Vector2(r * 0.6, -r * 0.45), c + Vector2(r * 0.55, r * 0.35),
				c + Vector2(0, r * 0.85), c + Vector2(-r * 0.55, r * 0.35), c + Vector2(-r * 0.6, -r * 0.45), c + Vector2(-r * 0.35, -r * 0.2)]), col)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 0.3), c + Vector2(r * 0.22, r * 0.25), c + Vector2(0, r * 0.6), c + Vector2(-r * 0.22, r * 0.25)]), dark)
		"grimtusk":
			# A broken chain: two links, one snapped open.
			ci.draw_arc(c + Vector2(-r * 0.3, 0), r * 0.36, 0.0, TAU, 20, col, r * 0.15, true)
			ci.draw_arc(c + Vector2(r * 0.34, 0), r * 0.36, PI * 0.25, PI * 1.75, 20, col, r * 0.15, true)
		"sylvan":
			# The Moura fountain: a basin and a rising, falling jet.
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.75, r * 0.35), c + Vector2(r * 0.75, r * 0.35), c + Vector2(r * 0.45, r * 0.75), c + Vector2(-r * 0.45, r * 0.75)]), col)
			ci.draw_line(c + Vector2(0, r * 0.35), c + Vector2(0, -r * 0.75), col, r * 0.14, true)
			ci.draw_arc(c + Vector2(-r * 0.3, -r * 0.45), r * 0.3, PI * 1.5, TAU + 0.6, 12, col, r * 0.1, true)
			ci.draw_arc(c + Vector2(r * 0.3, -r * 0.45), r * 0.3, PI * 0.4, PI * 1.5, 12, col, r * 0.1, true)
		"karak":
			# A castro tower with crenels.
			ci.draw_rect(Rect2(c + Vector2(-r * 0.45, -r * 0.4), Vector2(r * 0.9, r * 1.25)), col)
			for k in 3:
				ci.draw_rect(Rect2(c + Vector2(-r * 0.45 + k * r * 0.35, -r * 0.7), Vector2(r * 0.2, r * 0.32)), col)
			ci.draw_rect(Rect2(c + Vector2(-r * 0.13, r * 0.35), Vector2(r * 0.26, r * 0.5)), dark)
		"sunspear":
			# The Dominion sun.
			ci.draw_circle(c, r * 0.38, col)
			for k in 12:
				var a := k * TAU / 12.0
				ci.draw_line(c + Vector2(cos(a), sin(a)) * r * 0.5, c + Vector2(cos(a), sin(a)) * r * (0.9 if k % 2 == 0 else 0.72), col, 2.2, true)
		"wyldkin":
			# The full moon and a crescent of the wolf's night.
			ci.draw_circle(c, r * 0.7, col)
			ci.draw_circle(c + Vector2(r * 0.3, -r * 0.15), r * 0.58, dark)
		"hollow":
			# A procession candle and its flame.
			ci.draw_rect(Rect2(c + Vector2(-r * 0.2, -r * 0.2), Vector2(r * 0.4, r * 1.05)), col)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 0.9), c + Vector2(r * 0.2, -r * 0.45), c + Vector2(0, -r * 0.28), c + Vector2(-r * 0.2, -r * 0.45)]), col.lightened(0.3))
		"frostborn":
			# A Careto cowbell.
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.3, -r * 0.6), c + Vector2(r * 0.3, -r * 0.6), c + Vector2(r * 0.6, r * 0.55), c + Vector2(-r * 0.6, r * 0.55)]), col)
			ci.draw_arc(c + Vector2(0, -r * 0.7), r * 0.2, PI, TAU, 10, col, 2.0, true)
			ci.draw_circle(c + Vector2(0, r * 0.72), r * 0.14, col)
		_:
			ci.draw_circle(c, r * 0.5, col)
