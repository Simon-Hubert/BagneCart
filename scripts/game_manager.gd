class_name game_manager extends Node2D

static var Instance : game_manager = null

const END_SCENE_PATH : String = "res://scenes/end_scene.tscn"

@onready var _quest_manager : quest_manager = $QuestManager
@onready var _respawn_timer : Timer = $Timer

@export var _maximum_quest_failed : int = 3

var _number_quest_failed : int = 0

signal on_respawn
signal on_quest_failed
signal on_game_over

func _ready() -> void:
	if Instance != null:
		push_error("quest_manager instance already exists")
		return
	Instance = self
	
	_quest_manager.on_all_quest_completed.connect(_load_end_scene)
	
func _load_end_scene() -> void:
	get_tree().change_scene_to_file(END_SCENE_PATH)

##Launch a timer to rRespawn the player and camera
func respawn_player() -> void:
	_respawn_timer.start()
	
func _on_respawn_timer_ended() -> void:
	on_respawn.emit()

##Fail a quest, and launch game over if number of tries have expired
func failed_quest() -> void:
	_number_quest_failed += 1
	if _number_quest_failed >= _maximum_quest_failed:
		on_game_over.emit()
	else:
		on_quest_failed.emit()
