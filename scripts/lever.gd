class_name lever extends Sprite2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var is_interacted : bool = false

signal on_interacted

func _on_interactable_player_interact() -> void:
	on_interacted.emit()
	#Play corresponding animation
	is_interacted = !is_interacted
	if is_interacted:
		animation_player.play("Switch")
	else:
		animation_player.play_backwards("Switch")
