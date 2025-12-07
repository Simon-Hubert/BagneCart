extends Node2D

const END_SCENE_PATH : String = "res://scenes/end_scene.tscn"

@onready var _quest_manager : quest_manager = $QuestManager

func _ready() -> void:
	_quest_manager.on_all_quest_completed.connect(_load_end_scene)
	
func _load_end_scene() -> void:
	get_tree().change_scene_to_file(END_SCENE_PATH)
