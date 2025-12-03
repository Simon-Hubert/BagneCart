class_name NPC extends Node

@export_category("Reference & Data")
@export var sprite : Sprite2D
@export var data : NPC_data

@export_category("Graphics")
@export var sprite_list : Array[Texture2D]

##Init the data and sprite
func init_NPC() -> void:
	if !quest_manager.Instance:
		push_warning("quest_manager instance is null")
		return
	data = quest_manager.Instance.create_NPC_data()
	sprite.texture = sprite_list[quest_manager.Instance.get_rng().randi() % sprite_list.size()]

##Event when player interact with NPC
func _on_trigger_area_player_interact() -> void:
	#Give new quest
	if !quest_manager.Instance.has_quest:
		quest_manager.Instance.accept_new_quest(data)
		dialog_UI.Instance.display_dialog(data.name, data.quest_dialog)
		return	
	#Can't take two quest at same time
	if quest_manager.Instance.current_quest_giver_name != data.name:
		dialog_UI.Instance.display_dialog(data.name, quest_manager.Instance.get_wrong_NPC_line())
		return
	#Check if quest completed
	if quest_manager.Instance.check_validate_quest():
		dialog_UI.Instance.display_dialog(data.name, quest_manager.Instance.get_quest_finished_line())
	else:
		dialog_UI.Instance.display_dialog(data.name, quest_manager.Instance.get_quest_not_finished_line())
