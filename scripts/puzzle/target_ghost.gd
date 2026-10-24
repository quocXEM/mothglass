extends Node2D
## Diegetic target — soft silhouette + dust dots. No dashed debug boxes / red ✕.


var outlines: Array = []
var samples: Array = []
var anti: Array = []
var covered: Array = []
var anti_hit: Array = []
var fill_alpha := 0.06
var pulse := 0.0
var hold_t := 0.0
var status := ""


func set_target(outline_list: Array, sample_pts: Array, anti_pts: Array = []) -> void:
	outlines = outline_list
	samples = sample_pts
	anti = anti_pts
	covered.clear()
	anti_hit.clear()
	for _i in samples.size():
		covered.append(false)
	for _i in anti.size():
		anti_hit.append(false)
	hold_t = 0.0
	status = ""
	queue_redraw()


func set_covered(sample_flags: Array, anti_flags: Array = []) -> void:
	covered = sample_flags
	anti_hit = anti_flags
	queue_redraw()


func set_progress(t: float) -> void:
	fill_alpha = lerpf(0.05, 0.22, t)
	queue_redraw()


func set_hold(t: float) -> void:
	hold_t = clampf(t, 0.0, 1.0)
	queue_redraw()


func set_status(text: String) -> void:
	status = text
	queue_redraw()


func _process(delta: float) -> void:
	pulse += delta * 1.1
	queue_redraw()


func _draw() -> void:
	for outline in outlines:
		if outline.size() < 3:
			continue
		# Soft moth-dust wash — reads as place, not UI
		draw_colored_polygon(outline, Color(0.92, 0.86, 0.72, fill_alpha * 0.7))
		draw_colored_polygon(outline, Color(0.08, 0.07, 0.06, fill_alpha * 0.85))
		var edge := Color(0.88, 0.8, 0.62, 0.22 + 0.08 * sin(pulse))
		if hold_t > 0.05:
			edge = Color(0.86, 0.92, 0.78, 0.25 + 0.4 * hold_t)
		_soft_border(outline, edge, 1.5)
		if hold_t > 0.02:
			var aabb := _aabb(outline)
			var c := aabb.get_center()
			var r := mini(aabb.size.x, aabb.size.y) * 0.32
			draw_arc(c, r, -PI * 0.5, -PI * 0.5 + TAU * hold_t, 40, Color(0.9, 0.94, 0.82, 0.55), 2.0, true)

	for i in samples.size():
		var p: Vector2 = samples[i]
		var ok: bool = i < covered.size() and covered[i]
		var breathe := 0.55 + 0.2 * absf(sin(pulse + float(i) * 0.4))
		if ok:
			draw_circle(p, 7.0, Color(0.88, 0.92, 0.78, 0.35))
			draw_circle(p, 3.5, Color(0.92, 0.95, 0.86, 0.95))
		else:
			draw_circle(p, 5.5, Color(0.95, 0.88, 0.65, 0.12 * breathe))
			draw_arc(p, 4.5, 0.0, TAU, 16, Color(0.95, 0.86, 0.6, 0.45 * breathe), 1.25, true)

	# Forbidden spots: quiet cold voids — never red debug ✕
	for i in anti.size():
		var p: Vector2 = anti[i]
		var hit: bool = i < anti_hit.size() and anti_hit[i]
		var a := 0.55 if hit else 0.22
		draw_circle(p, 8.0, Color(0.35, 0.28, 0.32, a * 0.35))
		draw_arc(p, 5.0, 0.0, TAU, 18, Color(0.72, 0.55, 0.58, a), 1.2, true)


func _aabb(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		r = r.expand(p)
	return r


func _soft_border(poly: PackedVector2Array, color: Color, width: float) -> void:
	for i in poly.size():
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % poly.size()]
		draw_line(a, b, color, width, true)
