extends Control

@onready var play_btn: Button = %PlayBtn
@onready var chambers_btn: Button = %ChambersBtn
@onready var settings_btn: Button = %SettingsBtn
@onready var credits_btn: Button = %CreditsBtn
@onready var quit_btn: Button = %QuitBtn
@onready var title_l: Label = %Title
@onready var tag_l: Label = %Tag
@onready var sub: Label = %Sub
@onready var bg_photo: TextureRect = %BgPhoto
@onready var vignette: TextureRect = %Vignette


func _ready() -> void:
	if ResourceLoader.exists("res://assets/art/bg_dream.jpg"):
		bg_photo.texture = load("res://assets/art/bg_dream.jpg")
	elif ResourceLoader.exists("res://assets/art/bg_room.png"):
		bg_photo.texture = load("res://assets/art/bg_room.png")
	if ResourceLoader.exists("res://assets/art/vignette.png"):
		vignette.texture = load("res://assets/art/vignette.png")

	_refresh()
	Loc.language_changed.connect(func(_c): _refresh())

	play_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		GameState.play_room(maxi(1, GameState.unlocked))
	)
	chambers_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		GameState.goto_chambers()
	)
	settings_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		GameState.goto_settings()
	)
	credits_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		GameState.goto_credits()
	)
	quit_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		get_tree().quit()
	)

	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.7)


func _refresh() -> void:
	title_l.text = Loc.tr_key("game.title")
	tag_l.text = Loc.tr_key("game.tagline")
	sub.text = "%d / %d" % [GameState.unlocked, GameState.TOTAL_ROOMS]
	play_btn.text = Loc.tr_key("menu.enter")
	chambers_btn.text = Loc.tr_key("menu.chambers")
	settings_btn.text = Loc.tr_key("menu.settings")
	credits_btn.text = Loc.tr_key("menu.credits")
	quit_btn.text = Loc.tr_key("menu.leave")
