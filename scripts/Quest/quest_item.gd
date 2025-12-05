class_name quest_item extends Pickupable

@onready var sprite : Sprite2D = $Sprite2D

@export_category("Sprites")
@export var item_to_sprite : Dictionary[String, Texture2D]
@export var characters_items_sprites : Array[Texture2D]
var _item_name : String = ""
var _is_on_screen : bool = false

##Initialize the item name and sprite
func init_item(item_name : String, rng : RandomNumberGenerator):
	if item_to_sprite.has(item_name):
		sprite.texture = item_to_sprite[item_name]
	else:
		sprite.texture = characters_items_sprites[rng.randi() % characters_items_sprites.size()]
	_item_name = item_name
	
##Check whether the item is the required item AND is on screen
func is_correct_item(item_name : String) -> bool:
	return _item_name == item_name && _is_on_screen

##Update that the item is present on screen
func _on_screen_entered() -> void:
	_is_on_screen = true

##Update that the item is NOT present on screen
func _on_screen_exited() -> void:
	_is_on_screen = false
