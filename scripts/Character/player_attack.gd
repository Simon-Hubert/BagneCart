class_name PlayerAttack extends Area2D

@export var damages : int = 1
@export var lifetime : float = 0.3
var direction : Vector2

func _process(delta: float) -> void:		
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body:Node2D) -> void:
	if body is enemy:
		body.hit(direction)
		queue_free()