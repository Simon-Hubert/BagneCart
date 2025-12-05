class_name Rail extends Area2D

@export var dir : Vector2
@export var size := 16.0
@export var is_turning : bool
@export var flip_normal: bool

func get_side_force(other_position: Vector2) -> Vector2:
	var center := position
	var normal := Vector2(-dir.y, dir.x)

	if (is_turning):
		center = position + size/4 * normal if (not flip_normal) else position - size/4 * normal

	var to_other := other_position - center
	return -to_other.dot(normal) * 0.1 *normal


func _ready():
	get_side_force(position)
