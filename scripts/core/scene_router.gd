extends CanvasLayer
## Cross-fade scene changes — expected in shipped titles.

var _rect: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	_rect = ColorRect.new()
	_rect.color = Color(0.08, 0.07, 0.06, 0.0)
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 1.0, 0.35)
	await tw.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(_rect, "color:a", 0.0, 0.45)
	await tw2.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


func flash_white(dur := 0.35) -> void:
	_rect.color = Color(0.96, 0.93, 0.88, 0.0)
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 0.55, dur * 0.35)
	tw.tween_property(_rect, "color:a", 0.0, dur * 0.65)
