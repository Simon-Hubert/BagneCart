class_name NPC extends Node

@export var data : NPC_data

func _init_NPC() -> void:
	data = quest_manager.Instance.create_NPC_data()

func _on_player_entered(_body: Node2D) -> void:
	if _body.name == "Player":
		if quest_manager.Instance.has_quest:
			if quest_manager.Instance.check_validate_quest():
				push_warning("good job !")
			else:
				push_warning("not finished!")
		else:
			quest_manager.Instance.accept_new_quest(data)
			dialog_UI.Instance.display_dialog(data.name, data.quest_dialog)
