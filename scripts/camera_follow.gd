class_name CameraFollow extends Camera2D

@export var _target : Node2D
@export var _decay : float

func _process(delta: float) -> void:
	position = math.exponential_decay(position, _target.position, _decay, delta)
