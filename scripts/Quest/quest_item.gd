class_name quest_item extends Node2D

@export_category("References")
@export var sprite : Sprite2D

@export_category("Sprites")
@export var item_to_sprite : Dictionary[String, Texture2D]
@export var characters_items_sprites : Array[Texture2D]
var _item_name : String = ""

func init_item(itemName : String, rng : RandomNumberGenerator):
	if item_to_sprite.has(itemName):
		sprite.texture = item_to_sprite[itemName]
	else:
		sprite.texture = characters_items_sprites[rng.randi() % characters_items_sprites.size()]
	_item_name = itemName
	
