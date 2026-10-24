extends Control


func _ready() -> void:
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.6)
	tw.tween_interval(0.55)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	await tw.finished
	SceneRouter.go("res://scenes/main_menu.tscn")
