class_name NPC_quest_indicator extends Sprite2D

enum QUEST_STATE
{
	HAS_QUEST,
	QUEST_ACCEPTED,
	QUEST_FINISHED
}

@onready var sprite : Sprite2D = $"."

@export_category("Sprites")
@export var new_quest_sprite : Texture2D
@export var validate_quest_sprite : Texture2D

##Set the quest indicator sprite based on the quest state
func set_quest_sprite(current_quest_state : QUEST_STATE):
	match(current_quest_state):
		QUEST_STATE.HAS_QUEST:
			sprite.texture = new_quest_sprite
		QUEST_STATE.QUEST_ACCEPTED:
			sprite.texture = validate_quest_sprite
		QUEST_STATE.QUEST_FINISHED:
			sprite.texture = null #Hide the sprite by setting to null
