class_name ShadowMath
extends RefCounted

## Đổ bóng 2D giả lập + chấm phủ / chấm phạt.


static func cast_shadow(poly_global: PackedVector2Array, lamp: Vector2, length := 320.0) -> PackedVector2Array:
	if poly_global.is_empty():
		return PackedVector2Array()
	var near_pts := PackedVector2Array()
	var far_pts := PackedVector2Array()
	for p in poly_global:
		var dir := p - lamp
		var d := dir.length()
		if d < 0.001:
			dir = Vector2(0, 1)
			d = 1.0
		else:
			dir /= d
		near_pts.append(p)
		far_pts.append(p + dir * length)
	var out := PackedVector2Array()
	for p in near_pts:
		out.append(p)
	for i in range(far_pts.size() - 1, -1, -1):
		out.append(far_pts[i])
	return out


static func point_in_poly(point: Vector2, poly: PackedVector2Array) -> bool:
	var inside := false
	var j := poly.size() - 1
	for i in poly.size():
		var pi: Vector2 = poly[i]
		var pj: Vector2 = poly[j]
		if ((pi.y > point.y) != (pj.y > point.y)) \
			and (point.x < (pj.x - pi.x) * (point.y - pi.y) / maxf(pj.y - pi.y, 0.0001) + pi.x):
			inside = not inside
		j = i
	return inside


static func coverage(samples: Array, shadows: Array) -> float:
	if samples.is_empty():
		return 0.0
	var hit := 0
	for s in samples:
		var sp: Vector2 = s
		for sh in shadows:
			if point_in_poly(sp, sh):
				hit += 1
				break
	return float(hit) / float(samples.size())


## Điểm = phủ mẫu − phạt vùng cấm. Cần ~0.9 và ít bóng lạc.
static func solve_score(samples: Array, anti: Array, shadows: Array) -> Dictionary:
	var good := coverage(samples, shadows)
	var bad := coverage(anti, shadows) if not anti.is_empty() else 0.0
	var score := clampf(good - 0.65 * bad, 0.0, 1.0)
	return {"score": score, "good": good, "bad": bad}
