class_name NPC extends Node

@export var data : NPC_data

func _init_NPC() -> void:
	data = quest_manager.Instance.create_NPC_data()

func _on_player_entered(_body: Node2D) -> void:
	if _body.name != "Player":
		return
		
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
