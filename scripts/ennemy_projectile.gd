class_name ennemy_projectile extends RigidBody2D

var projectile_owner : Node

##Destroy projectile when time ends
func _on_lifetime_ended() -> void:
	queue_free()

##Destroy on collision (and give damage to player)
func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.hit(linear_velocity.normalized())
		
	#Check if not colliding with the enemy who launches it
	#for exemple, when it spawns
	if body != projectile_owner:
		queue_free()
