extends RefCounted
## Find the nearest clear slot for a command annotation. All rectangles use
## HUD canvas coordinates, after the panel's readability scale is applied.

static func place(measured: Vector2, preferred: Vector2, viewport: Vector2, obstacles: Array[Rect2]) -> Vector2:
	const MARGIN := 8.0
	const GAP := 10.0
	var last := (viewport - measured - Vector2.ONE * MARGIN).max(Vector2.ONE * MARGIN)
	var origin := preferred.clamp(Vector2.ONE * MARGIN, last)
	var xs: Array[float] = [origin.x, MARGIN, last.x]
	var ys: Array[float] = [origin.y, MARGIN, last.y]
	var protected: Array[Rect2] = []
	for obstacle in obstacles:
		var padded := obstacle.grow(GAP)
		protected.append(padded)
		xs.append(clampf(padded.position.x - measured.x, MARGIN, last.x))
		xs.append(clampf(padded.end.x, MARGIN, last.x))
		ys.append(clampf(padded.position.y - measured.y, MARGIN, last.y))
		ys.append(clampf(padded.end.y, MARGIN, last.y))
	# Instruments share many edges. Avoid searching the same slot repeatedly.
	var unique_xs: Array[float] = []
	var unique_ys: Array[float] = []
	for x in xs:
		if not unique_xs.has(x):
			unique_xs.append(x)
	for y in ys:
		if not unique_ys.has(y):
			unique_ys.append(y)
	# Combining obstacle edges finds slots bounded by different panels. Testing
	# only four corners misses these gaps on the denser production workspace.
	var best := origin
	var best_overlap := INF
	var best_distance := INF
	for x in unique_xs:
		for y in unique_ys:
			var position := Vector2(x, y)
			var rect := Rect2(position, measured)
			var overlap := 0.0
			for obstacle in protected:
				if rect.intersects(obstacle):
					overlap += rect.intersection(obstacle).get_area()
			var distance := position.distance_squared_to(origin)
			if is_zero_approx(overlap) and is_zero_approx(distance):
				return position
			if overlap < best_overlap or (is_equal_approx(overlap, best_overlap) and distance < best_distance):
				best = position
				best_overlap = overlap
				best_distance = distance
	return best
