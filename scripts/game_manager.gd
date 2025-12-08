class_name game_manager extends Node2D

static var Instance : game_manager = null

const GAME_OVER_SCENE_PATH : String = "res://scenes/game_over_scene.tscn"
const END_SCENE_PATH : String = "res://scenes/end_scene.tscn"

const PLAYER_SCENE_PATH : String = "res://scenes/player.tscn"
const PLAYER_SCENE : PackedScene = preload(PLAYER_SCENE_PATH)

const CART_SCENE_PATH : String = "res://scenes/Cart.tscn"
const CART_SCENE : PackedScene = preload(CART_SCENE_PATH)

const CAMERA_SCENE_PATH : String = "res://scenes/camera.tscn"
const CAMERA_SCENE : PackedScene = preload(CAMERA_SCENE_PATH)

@onready var _quest_manager : quest_manager = $QuestManager
@onready var _respawn_timer : Timer = $Timer

@export var _maximum_quest_failed : int = 3

var _number_quest_failed : int = 0
var _player_ref : Player
signal on_respawn
signal on_quest_failed
signal on_game_over

func _ready() -> void:
	if Instance != null:
		push_error("quest_manager instance already exists")
		return
	Instance = self
	
	_quest_manager.on_all_quest_completed.connect(_load_end_scene)
	
##Spawn player & camera
func spawn_player_and_camera(spawn_position : Vector2) -> void:
	await get_tree().create_timer(.1).timeout
	#Spawn player and camera
	var camera_ref : camera_zelda_style = CAMERA_SCENE.instantiate()
	get_tree().current_scene.add_child(camera_ref)
	_player_ref = PLAYER_SCENE.instantiate()
	get_tree().current_scene.add_child(_player_ref)
	_player_ref.position = spawn_position

	#Setup camera
	camera_ref.player_ref = _player_ref
	camera_ref.position = spawn_position
	camera_ref.setup()
	
##Spawn the cart
func spawn_cart() -> void:
	await get_tree().create_timer(.1).timeout
	#Spawn cart
	var cart_ref : Cart = CART_SCENE.instantiate()
	get_tree().current_scene.add_child(cart_ref)
	#Setup cart
	cart_ref.player = _player_ref
	
##Load end scene
func _load_end_scene() -> void:
	get_tree().change_scene_to_file(END_SCENE_PATH)
	
##Launch a timer to rRespawn the player and camera
func respawn_player() -> void:
	_respawn_timer.start()

##Send respaw when timer ends
func _on_respawn_timer_ended() -> void:
	on_respawn.emit()

##Fail a quest, and launch game over if number of tries have expired
func failed_quest() -> void:
	_number_quest_failed += 1
	quest_manager.Instance.has_quest = false
	if _number_quest_failed >= _maximum_quest_failed:
		#Load game over scene
		on_game_over.emit()
		get_tree().change_scene_to_file(GAME_OVER_SCENE_PATH)
	else:
		on_quest_failed.emit()
