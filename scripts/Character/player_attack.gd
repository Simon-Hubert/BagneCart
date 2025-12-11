class_name PlayerAttack extends Area2D

@export var damages : int = 1
@export var lifetime : float = 0.3
var direction : Vector2

func _process(delta: float) -> void:		
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body:Node2D) -> void:
	print(body.name)
	if body is enemy:
		body.hit(direction)
		queue_free()
	elif body is ennemy_projectile:
		body.queue_free()
		queue_free()

func _on_area_entered(area : Area2D) -> void:
	var proj = area.get_parent()
	if proj is ennemy_projectile:
		proj.queue_free()
		

