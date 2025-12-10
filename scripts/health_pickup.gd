class_name health_pickup extends Sprite2D

var _can_be_taken : bool = false

func on_end_animation():
	_can_be_taken = true

##Check if player walked on health, then give it one health point
func _on_body_entered(body: Node2D) -> void:
	if !_can_be_taken:
		return	
	if body is Player:
		var player : Player = body as Player
		player.restore_health()
		queue_free()
