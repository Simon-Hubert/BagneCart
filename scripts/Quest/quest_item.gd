class_name quest_item extends Pickupable

@onready var sprite : Sprite2D = $Sprite2D
@onready var name_tag : Label = $NameTag

@export_category("Sprites")
@export var item_to_sprite : Dictionary[String, Texture2D]
@export var characters_items_sprites : Array[Texture2D]
var _item_name : String = ""
var _is_on_screen : bool = false

#Used to determine if the item is a person
#(player is MORE slower when carring a person)
var is_person : bool = false

static var used_quest_persons : Array[int] #Store the indexes of the array

##Initialize the item name and sprite
func init_item(item_name : String, rng : RandomNumberGenerator):
	#Set item sprite
	is_person = !item_to_sprite.has(item_name)
	sprite.texture = _get_unique_texture(item_name, rng)
	#Set item name
	name_tag.visible = is_person
	name_tag.text = item_name
	_item_name = item_name
	
##Check whether the item is the required item AND is on screen
func is_correct_item(item_name : String) -> bool:
	return is_correct_item_name(item_name) && _is_on_screen

##Check if the item name is correct
func is_correct_item_name(item_name : String) -> bool:
	return _item_name == item_name

##Update that the item is present on screen
func _on_screen_entered() -> void:
	_is_on_screen = true

##Update that the item is NOT present on screen
func _on_screen_exited() -> void:
	_is_on_screen = false

##Returns an unique texture (wasn't previously used)
##Only works for character as object are linked to the item name
func _get_unique_texture(item_name : String, rng : RandomNumberGenerator):
	if item_to_sprite.has(item_name):
		return item_to_sprite[item_name]
	else:
		var random_index : int = rng.randi() % characters_items_sprites.size()
		while used_quest_persons.has(random_index):
			random_index = rng.randi() % characters_items_sprites.size()
		
		#Add and reset array if every sprites were used
		used_quest_persons.append(random_index)
		if used_quest_persons.size() >= characters_items_sprites.size():
			used_quest_persons.clear()
			used_quest_persons.append(random_index)
			
		return characters_items_sprites[random_index]
