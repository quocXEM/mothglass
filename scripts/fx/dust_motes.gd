extends Node2D
## Floating dust in the light shafts — quiet juice.


func _ready() -> void:
	var p := CPUParticles2D.new()
	p.amount = 28
	p.lifetime = 9.0
	p.preprocess = 4.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(640, 360)
	p.direction = Vector2(0.15, -0.2)
	p.spread = 40.0
	p.gravity = Vector2(0, 4)
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 14.0
	p.scale_amount_min = 0.4
	p.scale_amount_max = 1.4
	p.color = Color(0.95, 0.9, 0.82, 0.22)
	p.position = Vector2(640, 360)
	p.z_index = 6
	add_child(p)
