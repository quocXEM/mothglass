extends Node2D
## Mục tiêu tinh tế — không HUD debug, không chữ to.

var outlines: Array = []
var samples: Array = []
var anti: Array = []
var covered: Array = []
var anti_hit: Array = []
var fill_alpha := 0.05
var pulse := 0.0
var show_guides := true


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
	queue_redraw()


func set_covered(sample_flags: Array, anti_flags: Array = []) -> void:
	covered = sample_flags
	anti_hit = anti_flags
	queue_redraw()


func set_progress(t: float) -> void:
	fill_alpha = lerpf(0.04, 0.18, t)
	queue_redraw()


func _process(delta: float) -> void:
	pulse += delta * 1.4
	queue_redraw()


func _draw() -> void:
	for outline in outlines:
		if outline.size() < 3:
			continue
		# Soft ink wash
		draw_colored_polygon(outline, Color(0.12, 0.1, 0.09, fill_alpha))
		# Hairline dashed — parchment ink, not alert red
		var col := Color(0.25, 0.2, 0.16, 0.35 + 0.12 * sin(pulse))
		_dashed(outline, col, 1.25)

	for i in samples.size():
		var p: Vector2 = samples[i]
		var ok: bool = i < covered.size() and covered[i]
		if ok:
			draw_circle(p, 3.5, Color(0.92, 0.88, 0.8, 0.85))
		else:
			var a := 0.25 + 0.15 * absf(sin(pulse + float(i) * 0.5))
			draw_arc(p, 4.0, 0.0, TAU, 16, Color(0.2, 0.16, 0.12, a), 1.1, true)

	# Anti zones: barely visible until hit
	for i in anti.size():
		var p: Vector2 = anti[i]
		var hit: bool = i < anti_hit.size() and anti_hit[i]
		if hit:
			draw_circle(p, 3.0, Color(0.45, 0.12, 0.1, 0.55))
		elif show_guides:
			draw_circle(p, 2.0, Color(0.15, 0.12, 0.1, 0.12))


func _dashed(poly: PackedVector2Array, color: Color, width: float) -> void:
	for i in poly.size():
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % poly.size()]
		var dir := b - a
		var length := dir.length()
		if length < 0.01:
			continue
		dir /= length
		var t := 0.0
		var on := true
		while t < length:
			var seg := 7.0 if on else 5.0
			var t2 := minf(t + seg, length)
			if on:
				draw_line(a + dir * t, a + dir * t2, color, width, true)
			on = not on
			t = t2
