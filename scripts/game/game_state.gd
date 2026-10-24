extends Node

const SAVE_PATH := "user://mothglass_save.cfg"
const TOTAL_ROOMS := 5

var current_room: int = 1
var unlocked: int = 1
var completed: Dictionary = {}


func _ready() -> void:
	_load()


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	unlocked = int(cfg.get_value("p", "u", 1))
	current_room = int(cfg.get_value("p", "c", 1))
	for i in range(1, TOTAL_ROOMS + 1):
		if cfg.get_value("done", str(i), false):
			completed[i] = true


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("p", "u", unlocked)
	cfg.set_value("p", "c", current_room)
	for i in completed.keys():
		cfg.set_value("done", str(i), true)
	cfg.save(SAVE_PATH)


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
	get_tree().change_scene_to_file("res://scenes/room.tscn")


func goto_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
