extends Control

@onready var play_btn: Button = %PlayBtn
@onready var quit_btn: Button = %QuitBtn
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

	sub.text = "%d / %d" % [GameState.unlocked, GameState.TOTAL_ROOMS]
	play_btn.pressed.connect(func() -> void:
		AudioBus.play_soft()
		GameState.play_room(GameState.unlocked)
	)
	quit_btn.pressed.connect(func() -> void:
		AudioBus.play_soft()
		get_tree().quit()
	)
	# Soft fade-in
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.7)
