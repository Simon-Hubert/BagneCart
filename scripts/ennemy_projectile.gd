class_name ennemy_projectile extends RigidBody2D

@export var speed : float = 100.0

##Destroy projectile when time ends
func _on_lifetime_ended() -> void:
	queue_free()

##Destroy on collision (and give damage to player)
func _on_body_entered(body: Node) -> void:
	print(body.name)
	if body is Player:
		body.hit(linear_velocity.normalized())
		
	queue_free()

##Set the projectile velocity based on a direction
func set_velocity(dir : Vector2):
	linear_velocity = dir.normalized() * speed
