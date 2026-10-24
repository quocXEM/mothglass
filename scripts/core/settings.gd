extends Node
## Player prefs — language, volume (studio ship standard).

const PATH := "user://mothglass_settings.cfg"

var language: String = "vi"
var master_volume: float = 0.85
var muted: bool = false


func _ready() -> void:
	load_settings()
	call_deferred("apply")


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	language = str(cfg.get_value("a", "lang", "en"))
	master_volume = float(cfg.get_value("a", "vol", 0.85))
	muted = bool(cfg.get_value("a", "mute", false))


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("a", "lang", language)
	cfg.set_value("a", "vol", master_volume)
	cfg.set_value("a", "mute", muted)
	cfg.save(PATH)


func apply() -> void:
	if Loc:
		Loc.set_language(language)
	if AudioBus:
		AudioBus.set_master(master_volume, muted)
	save_settings()
