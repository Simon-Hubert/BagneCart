class_name quest_item extends Node2D

@export_category("References")
@export var sprite : Sprite2D

@export_category("Sprites")
@export var item_to_sprite : Dictionary[String, Texture2D]
@export var characters_items_sprites : Array[Texture2D]
var _item_name : String = ""

func init_item(item_name : String, rng : RandomNumberGenerator):
	if item_to_sprite.has(item_name):
		sprite.texture = item_to_sprite[item_name]
	else:
		sprite.texture = characters_items_sprites[rng.randi() % characters_items_sprites.size()]
	_item_name = item_name
	
func is_correct_item(item_name : String) -> bool:
	return _item_name == item_name
