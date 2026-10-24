extends Node

const SAVE_PATH := "user://mothglass_save.cfg"
const TOTAL_ROOMS := 5

var current_room: int = 1
var unlocked: int = 1
var completed: Dictionary = {}
var coach_seen: bool = false


func _ready() -> void:
	_load()


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	unlocked = int(cfg.get_value("p", "u", 1))
	current_room = int(cfg.get_value("p", "c", 1))
	coach_seen = bool(cfg.get_value("p", "coach", false))
	for i in range(1, TOTAL_ROOMS + 1):
		if cfg.get_value("done", str(i), false):
			completed[i] = true


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("p", "u", unlocked)
	cfg.set_value("p", "c", current_room)
	cfg.set_value("p", "coach", coach_seen)
	for i in completed.keys():
		cfg.set_value("done", str(i), true)
	cfg.save(SAVE_PATH)


func mark_coach_seen() -> void:
	coach_seen = true
	save()


func mark_done(room: int) -> void:
	completed[room] = true
	if room >= unlocked and room < TOTAL_ROOMS:
		unlocked = room + 1
	save()


func play_room(id: int) -> void:
	if id > unlocked:
		return
	current_room = id
	save()
	SceneRouter.go("res://scenes/room.tscn")


func goto_menu() -> void:
	SceneRouter.go("res://scenes/main_menu.tscn")


func goto_settings() -> void:
	SceneRouter.go("res://scenes/settings.tscn")


func goto_credits() -> void:
	SceneRouter.go("res://scenes/credits.tscn")


func goto_chambers() -> void:
	SceneRouter.go("res://scenes/chambers.tscn")


func is_done(id: int) -> bool:
	return completed.get(id, false) == true
