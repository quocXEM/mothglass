extends Control

@onready var title_l: Label = %Title
@onready var list: VBoxContainer = %List
@onready var back_btn: Button = %BackBtn
@onready var bg_photo: TextureRect = %BgPhoto


func _ready() -> void:
	if ResourceLoader.exists("res://assets/art/bg_dream.jpg"):
		bg_photo.texture = load("res://assets/art/bg_dream.jpg")
	_rebuild()
	Loc.language_changed.connect(func(_c): _rebuild())
	back_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		GameState.goto_menu()
	)


func _rebuild() -> void:
	title_l.text = Loc.tr_key("chambers.title")
	back_btn.text = Loc.tr_key("chambers.back")
	for c in list.get_children():
		c.queue_free()
	for i in range(1, GameState.TOTAL_ROOMS + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(280, 42)
		var roman := ["I", "II", "III", "IV", "V"][i - 1]
		var done := "  ·" if GameState.is_done(i) else ""
		if i <= GameState.unlocked:
			btn.text = "%s  —  %s%s" % [roman, Loc.room_title(i), done]
			var room_id := i
			btn.pressed.connect(func() -> void:
				AudioBus.play_ui()
				GameState.play_room(room_id)
			)
		else:
			btn.text = "%s  —  %s" % [roman, Loc.tr_key("chambers.locked")]
			btn.disabled = true
		list.add_child(btn)
