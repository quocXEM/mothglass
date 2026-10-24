extends Control

@onready var title_l: Label = %Title
@onready var lang_l: Label = %LangLabel
@onready var vol_l: Label = %VolLabel
@onready var lang_btn: OptionButton = %LangBtn
@onready var vol_slider: HSlider = %VolSlider
@onready var mute_btn: CheckButton = %MuteBtn
@onready var back_btn: Button = %BackBtn
@onready var bg_photo: TextureRect = %BgPhoto


func _ready() -> void:
	if ResourceLoader.exists("res://assets/art/bg_dream.jpg"):
		bg_photo.texture = load("res://assets/art/bg_dream.jpg")
	lang_btn.clear()
	lang_btn.add_item("English", 0)
	lang_btn.add_item("Tiếng Việt", 1)
	lang_btn.select(0 if Settings.language == "en" else 1)
	vol_slider.min_value = 0.0
	vol_slider.max_value = 1.0
	vol_slider.step = 0.01
	vol_slider.value = Settings.master_volume
	mute_btn.button_pressed = Settings.muted
	_refresh()
	Loc.language_changed.connect(func(_c): _refresh())

	lang_btn.item_selected.connect(func(idx: int) -> void:
		Settings.language = "en" if idx == 0 else "vi"
		Settings.apply()
		AudioBus.play_ui()
	)
	vol_slider.value_changed.connect(func(v: float) -> void:
		Settings.master_volume = v
		Settings.apply()
	)
	mute_btn.toggled.connect(func(on: bool) -> void:
		Settings.muted = on
		Settings.apply()
		AudioBus.play_ui()
	)
	back_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		GameState.goto_menu()
	)


func _refresh() -> void:
	title_l.text = Loc.tr_key("settings.title")
	lang_l.text = Loc.tr_key("settings.language")
	vol_l.text = Loc.tr_key("settings.volume")
	mute_btn.text = Loc.tr_key("settings.mute")
	back_btn.text = Loc.tr_key("settings.back")
