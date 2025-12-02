class_name NPC extends Node

@export var data : NPC_data

func _init_NPC() -> void:
	data = QuestManager.Instance.create_NPC_data()

func _on_player_entered(_body: Node2D) -> void:
	if _body.name == "Player":
		if QuestManager.Instance.has_quest:
			if QuestManager.Instance.check_validate_quest():
				push_warning("good job !")
			else:
				push_warning("not finished!")
		else:
			QuestManager.Instance.accept_new_quest(data)
			print(data.name)
			print(data.quest_dialog)
