class_name health_pickup extends Sprite2D

##Check if player walked on health, then give it one health point
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player : Player = body as Player
		player.restore_health()
		queue_free()
