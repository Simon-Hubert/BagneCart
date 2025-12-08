class_name enemy_group_spawner extends Node2D

const ENEMY_SCENE_PATH : String = "res://scenes/Enemy/enemy.tscn" 
const ENEMY_SCENE : PackedScene = preload(ENEMY_SCENE_PATH)

@export_category("Spawner")
@export var _enemy_spawner_list : Array[Node2D]

@export_category("Random")
@export var _min_number_of_enemies : int = 1
@export var _max_number_of_enemies : int = 5
@export_range(0,100) var _spawn_chance : float = 30

var _has_spawned_enemies : bool = false

##Spawn the enemies when the enemy group is visible
##being visible is considered as "entered the room"
func _on_enter_room() -> void:
	#Can only spawn once
	if _has_spawned_enemies:
		return
	_has_spawned_enemies = true
	
	#Random chance of enemies spawning
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if (rng.randi() % 100) > _spawn_chance:
		return
	
	var available_point : Array[Node2D] = _enemy_spawner_list.duplicate()
	var number_of_enemies = clampi(rng.randi(), _min_number_of_enemies, _max_number_of_enemies)
	for i in range(number_of_enemies):
		var newEnemy : enemy = ENEMY_SCENE.instantiate()
		add_child(newEnemy)
		#Set position and setup references
		var position_index := rng.randi() % available_point.size()
		newEnemy.global_position = available_point[position_index].global_position
		available_point.remove_at(position_index)
		newEnemy.player_ref = game_manager.Instance.player_ref
		newEnemy.cart_ref = game_manager.Instance.cart_ref
