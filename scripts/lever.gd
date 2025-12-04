class_name lever extends Sprite2D

@onready var sprite : Sprite2D = $"."

@export_category("Sprites")
@export var open_sprite : Texture2D
@export var closed_sprite : Texture2D

var is_interacted : bool = false

signal on_interacted(bool)

func _on_interactable_player_interact() -> void:
	is_interacted = !is_interacted
	on_interacted.emit(is_interacted)
	sprite.texture = closed_sprite if is_interacted else open_sprite
