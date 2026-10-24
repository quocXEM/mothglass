extends Control

@onready var play_btn: Button = %PlayBtn
@onready var quit_btn: Button = %QuitBtn
@onready var sub: Label = %Sub


func _ready() -> void:
	sub.text = "Phòng mở khóa: %d / %d" % [GameState.unlocked, GameState.TOTAL_ROOMS]
	play_btn.pressed.connect(func() -> void:
		AudioBus.play_soft()
		GameState.play_room(GameState.unlocked)
	)
	quit_btn.pressed.connect(func() -> void:
		AudioBus.play_soft()
		get_tree().quit()
	)
