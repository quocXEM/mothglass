extends Control

@onready var title_l: Label = %Title
@onready var body_l: Label = %Body
@onready var back_btn: Button = %BackBtn
@onready var bg_photo: TextureRect = %BgPhoto


func _ready() -> void:
	if ResourceLoader.exists("res://assets/art/bg_dream.jpg"):
		bg_photo.texture = load("res://assets/art/bg_dream.jpg")
	_refresh()
	Loc.language_changed.connect(func(_c): _refresh())
	back_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		GameState.goto_menu()
	)


func _refresh() -> void:
	title_l.text = Loc.tr_key("credits.title")
	body_l.text = Loc.tr_key("credits.body")
	back_btn.text = Loc.tr_key("credits.back")
